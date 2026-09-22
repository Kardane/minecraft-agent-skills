#!/usr/bin/env bash
set -euo pipefail
project_dir=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help|-Help|--Help) echo "Usage: verify-mod-env.sh --project-dir <path>"; exit 0 ;;
    -ProjectDir|--project-dir) project_dir="${2:-}"; shift 2 ;;
    *) echo "[ERROR] 알 수 없는 인자: $1" >&2; exit 1 ;;
  esac
done
[[ -n "$project_dir" && -d "$project_dir" ]] || { echo "[ERROR] valid project dir required" >&2; exit 1; }

fail=0; warn=0
pass(){ echo "[PASS] $1"; }
bad(){ echo "[FAIL] $1" >&2; fail=$((fail+1)); }
warn_msg(){ echo "[WARN] $1"; warn=$((warn+1)); }

for f in build.gradle gradle.properties settings.gradle src/main/resources/fabric.mod.json; do
  [[ -f "$project_dir/$f" ]] && pass "파일 존재: $f" || bad "파일 없음: $f"
done

gp="$project_dir/gradle.properties"
if [[ -f "$gp" ]]; then
  grep -qE '^minecraft_version=1\.21\.8$' "$gp" && pass "minecraft_version=1.21.8 고정" || bad "minecraft_version은 1.21.8이어야 합니다"
  for key in loader_version fabric_api_version; do grep -qE "^$key=" "$gp" && pass "버전 키 확인: $key" || bad "버전 키 누락: $key"; done
  if grep -qE '^yarn_mappings=' "$gp"; then bad "Yarn mapping property is not allowed; use official Mojang mappings"; else pass "Yarn mapping property 없음"; fi
  grep -qE '^(loader_version|fabric_api_version)=TODO_' "$gp" && warn_msg "TODO 버전이 남아 있습니다." || true
fi

if [[ -f "$project_dir/build.gradle" ]]; then
  bg="$(cat "$project_dir/build.gradle")"
  grep -q "fabric-loom" <<<"$bg" && pass "fabric-loom 선언 확인" || bad "fabric-loom 선언 누락"
  if grep -Fq "mappings loom.officialMojangMappings()" <<<"$bg"; then pass "official Mojang mappings 선언 확인"; else bad "mappings loom.officialMojangMappings() 선언 누락"; fi
  if grep -Eq "net\.fabricmc:yarn|yarn_mappings" <<<"$bg"; then bad "Yarn mapping dependency/reference is not allowed"; else pass "Yarn mapping dependency/reference 없음"; fi
  grep -q "JavaLanguageVersion.of(21)" <<<"$bg" && pass "Java 21 toolchain 선언 확인" || bad "Java 21 toolchain 누락"
  for token in fabric-loader fabric-api; do grep -q "$token" <<<"$bg" && pass "의존성 키워드 확인: $token" || bad "의존성 키워드 누락: $token"; done
fi

fm="$project_dir/src/main/resources/fabric.mod.json"
if [[ -f "$fm" ]]; then
  python3 - "$fm" <<'PY' >/dev/null 2>&1 || bad "fabric.mod.json JSON 파싱 실패"
import json,sys
json.load(open(sys.argv[1],encoding="utf-8"))
PY
  env_value="$(python3 - "$fm" <<'PY'
import json,sys
print(json.load(open(sys.argv[1],encoding="utf-8")).get("environment",""))
PY
)"
  [[ "$env_value" == "server" ]] && pass "fabric.mod.json environment=server" || bad "fabric.mod.json environment가 server가 아님"
fi

wrapper_files=("gradlew" "gradlew.bat" "gradle/wrapper/gradle-wrapper.jar" "gradle/wrapper/gradle-wrapper.properties")
present=0; for f in "${wrapper_files[@]}"; do [[ -f "$project_dir/$f" ]] && present=$((present+1)); done
if (( present == 0 )); then warn_msg "Gradle wrapper가 없습니다."
elif (( present == ${#wrapper_files[@]} )); then pass "Gradle wrapper 파일 세트 확인"
else bad "Gradle wrapper가 일부만 존재합니다 ($present/${#wrapper_files[@]})"; fi

echo "요약: FAIL=$fail WARN=$warn"
(( fail == 0 ))
