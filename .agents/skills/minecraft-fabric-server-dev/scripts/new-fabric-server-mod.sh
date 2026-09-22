#!/usr/bin/env bash
set -euo pipefail

show_usage() {
  cat <<'USAGE'
사용법:
  ./new-fabric-server-mod.sh -ProjectName <name> -PackageBase <pkg> -OutputDir <path> [옵션]
  ./new-fabric-server-mod.sh --project-name <name> --package-base <pkg> --output-dir <path> [옵션]

기준:
  Minecraft Java Edition 1.21.8
  Java 21

옵션:
  --mod-id <id>                    mod id 직접 지정 (미지정 시 ProjectName 기반 자동 생성)
  --yarn-mappings <ver>            기본값: 1.21.8+build.1
  --loom-version <ver>             기본값: 1.8-SNAPSHOT
  --loader-version <ver>           기본값: TODO_LOADER_VERSION
  --fabric-api-version <ver>       기본값: TODO_FABRIC_API_VERSION
  --with-mixin                     Mixin config를 opt-in으로 생성
  --with-polymer                   Polymer 의존성을 opt-in으로 추가
  --polymer-version <ver>          --with-polymer와 함께 사용

이 scaffold는 Gradle wrapper 바이너리를 생성하지 않는다.
생성 후 공식 Fabric 1.21.8 템플릿의 wrapper를 사용하거나 신뢰할 수 있는
로컬 Gradle로 wrapper를 생성한 뒤 ./gradlew을 사용한다.
USAGE
}

project_name=""
package_base=""
output_dir=""
mod_id=""
minecraft_version="1.21.8"
yarn_mappings="1.21.8+build.1"
loom_version="1.8-SNAPSHOT"
loader_version="TODO_LOADER_VERSION"
fabric_api_version="TODO_FABRIC_API_VERSION"
polymer_version=""
with_mixin=false
with_polymer=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help|-Help|--Help) show_usage; exit 0 ;;
    -ProjectName|--project-name) project_name="${2:-}"; shift 2 ;;
    -PackageBase|--package-base) package_base="${2:-}"; shift 2 ;;
    -OutputDir|--output-dir) output_dir="${2:-}"; shift 2 ;;
    --mod-id) mod_id="${2:-}"; shift 2 ;;
    --minecraft-version)
      if [[ "${2:-}" != "1.21.8" ]]; then
        echo "[ERROR] 이 번들의 기준 버전은 Minecraft 1.21.8입니다." >&2
        exit 1
      fi
      shift 2
      ;;
    --yarn-mappings) yarn_mappings="${2:-}"; shift 2 ;;
    --loom-version) loom_version="${2:-}"; shift 2 ;;
    --loader-version) loader_version="${2:-}"; shift 2 ;;
    --fabric-api-version) fabric_api_version="${2:-}"; shift 2 ;;
    --with-mixin) with_mixin=true; shift ;;
    --with-polymer) with_polymer=true; shift ;;
    --polymer-version) polymer_version="${2:-}"; shift 2 ;;
    *) echo "[ERROR] 알 수 없는 인자: $1" >&2; show_usage; exit 1 ;;
  esac
done

if [[ -z "$project_name" || -z "$package_base" || -z "$output_dir" ]]; then
  echo "[ERROR] 필수 인자가 부족합니다." >&2
  show_usage
  exit 1
fi
if [[ "$with_polymer" == false && -n "$polymer_version" ]]; then
  echo "[ERROR] --polymer-version은 --with-polymer와 함께 사용해야 합니다." >&2
  exit 1
fi
if [[ "$with_polymer" == true && -z "$polymer_version" ]]; then polymer_version="TODO_POLYMER_VERSION"; fi

if ! [[ "$project_name" =~ ^[a-zA-Z0-9._-]+$ ]]; then echo "[ERROR] ProjectName 형식이 잘못됐습니다." >&2; exit 1; fi
if ! [[ "$package_base" =~ ^[a-zA-Z_][a-zA-Z0-9_]*(\.[a-zA-Z_][a-zA-Z0-9_]*)+$ ]]; then echo "[ERROR] PackageBase 형식이 잘못됐습니다. 예: com.example.mod" >&2; exit 1; fi

if [[ -z "$mod_id" ]]; then mod_id="$(echo "$project_name" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9_-]+/-/g; s/-+/-/g; s/^-+//; s/-+$//')"; fi
if ! [[ "$mod_id" =~ ^[a-z][a-z0-9_-]{1,63}$ ]]; then echo "[ERROR] mod id 형식이 잘못됐습니다." >&2; exit 1; fi

camel_name="$(echo "$project_name" | sed -E 's/[^a-zA-Z0-9]+/ /g' | awk '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) tolower(substr($i,2)) } printf "%s", $0}' | tr -d ' ')"
if [[ "$camel_name" == *Mod ]]; then main_class_name="$camel_name"; else main_class_name="${camel_name}Mod"; fi

project_dir="$output_dir/$project_name"
if [[ -e "$project_dir" ]]; then echo "[ERROR] 프로젝트 디렉터리가 이미 존재합니다: $project_dir" >&2; exit 1; fi

package_path="${package_base//./\/}"
java_root="$project_dir/src/main/java/$package_path"
resources_dir="$project_dir/src/main/resources"
mkdir -p "$java_root" "$resources_dir"

cat > "$project_dir/settings.gradle" <<EOF_SET
rootProject.name = '$project_name'
EOF_SET

cat > "$project_dir/gradle.properties" <<EOF_PROP
org.gradle.jvmargs=-Xmx2G
minecraft_version=$minecraft_version
yarn_mappings=$yarn_mappings
loader_version=$loader_version
fabric_api_version=$fabric_api_version
maven_group=$package_base
archives_base_name=$project_name
EOF_PROP
if [[ "$with_polymer" == true ]]; then printf 'polymer_version=%s\n' "$polymer_version" >> "$project_dir/gradle.properties"; fi

polymer_repo=""
polymer_dep=""
if [[ "$with_polymer" == true ]]; then
  polymer_repo=$'\n    maven { url = '\''https://maven.nucleoid.xyz/'\'' }'
  polymer_dep=$'\n    modImplementation "eu.pb4:polymer-core:${project.polymer_version}"'
fi

cat > "$project_dir/build.gradle" <<EOF_BUILD
plugins {
    id 'fabric-loom' version '$loom_version'
    id 'maven-publish'
}

version = '0.1.0'
group = project.maven_group

base {
    archivesName = project.archives_base_name
}

repositories {
    mavenCentral()
    maven { url = 'https://maven.fabricmc.net/' }$polymer_repo
}

dependencies {
    minecraft "com.mojang:minecraft:\${project.minecraft_version}"
    mappings "net.fabricmc:yarn:\${project.yarn_mappings}:v2"
    modImplementation "net.fabricmc:fabric-loader:\${project.loader_version}"
    modImplementation "net.fabricmc.fabric-api:fabric-api:\${project.fabric_api_version}"$polymer_dep
}

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
    withSourcesJar()
}

processResources {
    inputs.property 'version', project.version
    filesMatching('fabric.mod.json') {
        expand 'version': project.version
    }
}

tasks.withType(JavaCompile).configureEach {
    options.encoding = 'UTF-8'
}
EOF_BUILD

mixins_block=""
if [[ "$with_mixin" == true ]]; then
  mixins_block=$(cat <<EOF_MIXIN_BLOCK
,
  "mixins": [
    "$mod_id.mixins.json"
  ]
EOF_MIXIN_BLOCK
)
fi

cat > "$resources_dir/fabric.mod.json" <<EOF_MOD
{
  "schemaVersion": 1,
  "id": "$mod_id",
  "version": "\${version}",
  "name": "$project_name",
  "description": "Fabric 1.21.8 서버사이드 모드",
  "authors": ["your-name"],
  "license": "MIT",
  "environment": "server",
  "entrypoints": {
    "main": [
      "$package_base.$main_class_name"
    ]
  }$mixins_block,
  "depends": {
    "fabricloader": ">=0.16.0",
    "minecraft": "~1.21.8",
    "fabric-api": "*"
  }
}
EOF_MOD

if [[ "$with_mixin" == true ]]; then
  cat > "$resources_dir/$mod_id.mixins.json" <<EOF_MIXINS
{
  "required": true,
  "package": "$package_base.mixin",
  "compatibilityLevel": "JAVA_21",
  "mixins": [],
  "injectors": {
    "defaultRequire": 1
  }
}
EOF_MIXINS
fi

cat > "$java_root/$main_class_name.java" <<EOF_MAIN
package $package_base;

import net.fabricmc.api.ModInitializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class $main_class_name implements ModInitializer {
    public static final String MOD_ID = "$mod_id";
    public static final Logger LOGGER = LoggerFactory.getLogger(MOD_ID);

    @Override
    public void onInitialize() {
        LOGGER.info("[{}] initialized", MOD_ID);
    }
}
EOF_MAIN

cat > "$project_dir/.gitignore" <<'EOF_GITIGNORE'
.gradle/
build/
run/
out/
*.iml
*.ipr
*.iws
EOF_GITIGNORE

mixin_status="disabled"; polymer_status="disabled"
[[ "$with_mixin" == true ]] && mixin_status="enabled"
[[ "$with_polymer" == true ]] && polymer_status="enabled"

cat > "$project_dir/README.md" <<EOF_README
# $project_name

## 기준
- Minecraft: 1.21.8
- Java: 21
- Fabric Loader: $loader_version
- Fabric API: $fabric_api_version
- Mixin scaffold: $mixin_status
- Polymer dependency: $polymer_status

## 시작 순서
1. gradle.properties의 TODO 버전을 실제 1.21.8 호환 버전으로 교체
2. Gradle wrapper가 없다면 공식 Fabric 1.21.8 템플릿에서 version-matched wrapper를 가져오거나 신뢰할 수 있는 로컬 Gradle로 생성
3. wrapper 전체(gradlew, gradlew.bat, gradle/wrapper/gradle-wrapper.jar, gradle-wrapper.properties)를 커밋
4. ./gradlew clean build
5. 개발 서버 부팅 후 핵심 시나리오 검증
EOF_README

echo "[OK] 생성 완료: $project_dir"
echo "[INFO] mod id: $mod_id"
echo "[INFO] Mixin: $mixin_status / Polymer: $polymer_status"
echo "[INFO] 다음 단계: verify-mod-env.sh -ProjectDir $project_dir"
echo "[INFO] Gradle wrapper는 scaffold가 생성하지 않습니다. ./gradlew 전에 wrapper를 준비하세요."
if [[ "$loader_version" == TODO_* || "$fabric_api_version" == TODO_* || "$polymer_version" == TODO_* ]]; then echo "[WARN] TODO 버전이 남아 있습니다. 빌드/배포 전 반드시 교체하세요."; fi
