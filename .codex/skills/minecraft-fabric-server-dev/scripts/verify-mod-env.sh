#!/usr/bin/env bash
set -euo pipefail

show_usage() {
  cat <<'USAGE'
사용법:
  ./verify-mod-env.sh -ProjectDir <path>
  ./verify-mod-env.sh --project-dir <path>

기준:
  Minecraft Java Edition 1.21.8
  Java 21
USAGE
}

project_dir=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help|-Help|--Help) show_usage; exit 0 ;;
    -ProjectDir|--project-dir) project_dir="${2:-}"; shift 2 ;;
    *) echo "[ERROR] 알 수 없는 인자: $1" >&2; show_usage; exit 1 ;;
  esac
done

if [[ -z "$project_dir" ]]; then echo "[ERROR] -ProjectDir 인자가 필요합니다." >&2; exit 1; fi
if [[ ! -d "$project_dir" ]]; then echo "[ERROR] 프로젝트 경로가 존재하지 않습니다: $project_dir" >&2; exit 1; fi
if ! command -v python3 >/dev/null 2>&1; then echo "[ERROR] python3가 필요합니다." >&2; exit 1; fi

fail_count=0
warn_count=0
pass() { echo "[PASS] $1"; }
warn_msg() { echo "[WARN] $1"; warn_count=$((warn_count + 1)); }
fail_msg() { echo "[FAIL] $1"; fail_count=$((fail_count + 1)); }

check_file() {
  local path="$1"
  if [[ -f "$project_dir/$path" ]]; then pass "파일 존재: $path"; else fail_msg "파일 없음: $path"; fi
}

json_check() {
  local file="$1"
  if python3 - "$project_dir/$file" >/dev/null 2>&1 <<'PY'
import json, sys
with open(sys.argv[1], "r", encoding="utf-8") as fh:
    json.load(fh)
PY
  then pass "JSON 파싱 성공: $file"; else fail_msg "JSON 파싱 실패: $file"; fi
}

search_java() {
  local pattern="$1"
  local root="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -n "$pattern" "$root" >/dev/null 2>&1
  else
    grep -R -n -E --include='*.java' "$pattern" "$root" >/dev/null 2>&1
  fi
}

for f in build.gradle gradle.properties settings.gradle src/main/resources/fabric.mod.json; do
  check_file "$f"
done

if [[ -f "$project_dir/gradle.properties" ]]; then
  gp="$(cat "$project_dir/gradle.properties")"
  if grep -qE '^minecraft_version=1\.21\.8$' <<<"$gp"; then
    pass "minecraft_version=1.21.8 고정"
  else
    fail_msg "minecraft_version은 1.21.8이어야 합니다"
  fi
  for key in yarn_mappings loader_version fabric_api_version; do
    if grep -qE "^${key}=" <<<"$gp"; then pass "버전 키 확인: $key"; else fail_msg "버전 키 누락: $key"; fi
  done
  if grep -qE '^(loader_version|fabric_api_version|polymer_version)=TODO_' <<<"$gp"; then
    warn_msg "TODO 버전이 남아 있습니다. 빌드/배포 전 치환 필요"
  fi
fi

if [[ -f "$project_dir/build.gradle" ]]; then
  bg="$(cat "$project_dir/build.gradle")"
  if grep -q "fabric-loom" <<<"$bg"; then pass "fabric-loom 선언 확인"; else fail_msg "fabric-loom 선언 누락"; fi
  if grep -q "JavaLanguageVersion.of(21)" <<<"$bg"; then pass "Java 21 toolchain 선언 확인"; else fail_msg "Java 21 toolchain 선언을 찾지 못함"; fi
  for token in "fabric-loader" "fabric-api"; do
    if grep -q "$token" <<<"$bg"; then pass "의존성 키워드 확인: $token"; else fail_msg "의존성 키워드 누락: $token"; fi
  done

  has_polymer_prop=false
  has_polymer_dep=false
  grep -qE '^polymer_version=' "$project_dir/gradle.properties" && has_polymer_prop=true
  grep -q 'polymer-core' <<<"$bg" && has_polymer_dep=true

  if [[ "$has_polymer_prop" == true || "$has_polymer_dep" == true ]]; then
    if [[ "$has_polymer_prop" == true && "$has_polymer_dep" == true ]]; then
      pass "Polymer opt-in 설정 정합성 확인"
    else
      fail_msg "Polymer 설정이 부분적으로만 존재합니다 (version key/dependency 불일치)"
    fi
  else
    pass "Polymer 미사용 (선택 기능)"
  fi
fi

if [[ -f "$project_dir/src/main/resources/fabric.mod.json" ]]; then
  json_check "src/main/resources/fabric.mod.json"

  fm_env="$(python3 - "$project_dir/src/main/resources/fabric.mod.json" <<'PY'
import json, sys
obj=json.load(open(sys.argv[1], "r", encoding="utf-8"))
print(obj.get("environment", ""))
PY
)"
  if [[ "$fm_env" == "server" ]]; then pass "fabric.mod.json environment=server"; else fail_msg "fabric.mod.json environment가 server가 아님: ${fm_env:-<없음>}"; fi

  fm_version="$(python3 - "$project_dir/src/main/resources/fabric.mod.json" <<'PY'
import json, sys
obj=json.load(open(sys.argv[1], "r", encoding="utf-8"))
print(obj.get("version", ""))
PY
)"
  if [[ "$fm_version" == '${version}' ]]; then pass "fabric.mod.json 버전 템플릿 문자열 확인"; else warn_msg "fabric.mod.json version 값 확인 필요: $fm_version"; fi

  mapfile -t declared_mixins < <(python3 - "$project_dir/src/main/resources/fabric.mod.json" <<'PY'
import json, sys
obj=json.load(open(sys.argv[1], "r", encoding="utf-8"))
for item in obj.get("mixins", []):
    if isinstance(item, str):
        print(item)
    elif isinstance(item, dict) and isinstance(item.get("config"), str):
        print(item["config"])
PY
)

  if (( ${#declared_mixins[@]} == 0 )); then
    pass "Mixin 미사용 (선택 기능)"
  else
    for cfg_name in "${declared_mixins[@]}"; do
      cfg="$project_dir/src/main/resources/$cfg_name"
      rel="src/main/resources/$cfg_name"
      if [[ ! -f "$cfg" ]]; then
        fail_msg "fabric.mod.json이 참조하는 Mixin config 없음: $rel"
        continue
      fi
      if python3 - "$cfg" >/dev/null 2>&1 <<'PY'
import json, sys
obj=json.load(open(sys.argv[1], "r", encoding="utf-8"))
required=["package", "mixins", "injectors"]
if any(k not in obj for k in required) or not isinstance(obj.get("mixins"), list):
    raise SystemExit(1)
PY
      then
        pass "Mixin opt-in 설정 구조 확인: $rel"
      else
        fail_msg "Mixin 설정 구조 오류: $rel"
      fi
    done
  fi
fi

wrapper_files=("gradlew" "gradlew.bat" "gradle/wrapper/gradle-wrapper.jar" "gradle/wrapper/gradle-wrapper.properties")
wrapper_present=0
for f in "${wrapper_files[@]}"; do
  [[ -f "$project_dir/$f" ]] && wrapper_present=$((wrapper_present + 1))
done

if (( wrapper_present == 0 )); then
  warn_msg "Gradle wrapper가 없습니다. ./gradlew 실행 전에 공식 Fabric 1.21.8 wrapper를 추가하거나 로컬 Gradle로 생성하세요."
elif (( wrapper_present == ${#wrapper_files[@]} )); then
  pass "Gradle wrapper 파일 세트 확인"
  [[ -x "$project_dir/gradlew" ]] || warn_msg "gradlew 실행 비트가 없습니다. Linux/WSL에서는 chmod +x gradlew 필요"
else
  fail_msg "Gradle wrapper가 일부만 존재합니다 ($wrapper_present/${#wrapper_files[@]}). 전체 세트를 복구하세요."
fi

java_root="$project_dir/src/main/java"
if [[ -d "$java_root" ]]; then
  if search_java 'net\.minecraft\.client' "$java_root"; then warn_msg "서버 코드에서 net.minecraft.client import 흔적 발견"; else pass "클라이언트 전용 import 흔적 없음"; fi
  if search_java '@Mixin\(' "$java_root"; then pass "Mixin 클래스 흔적 확인"; else pass "Mixin 클래스 없음 (선택 기능)"; fi
else
  fail_msg "src/main/java 디렉터리가 없습니다"
fi

echo
echo "요약"
echo "  FAIL: $fail_count"
echo "  WARN: $warn_count"

if (( fail_count > 0 )); then
  exit 1
fi
exit 0
