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
  --mod-id <id>
  --loom-version <ver>             기본값: 1.8-SNAPSHOT
  --loader-version <ver>           기본값: TODO_LOADER_VERSION
  --fabric-api-version <ver>       기본값: TODO_FABRIC_API_VERSION
  --with-mixin                     Mixin config를 opt-in으로 생성

Polymer integration은 minecraft-polymer-server-content가 소유한다.
USAGE
}

project_name=""; package_base=""; output_dir=""; mod_id=""
minecraft_version="1.21.8"; loom_version="1.8-SNAPSHOT"
loader_version="TODO_LOADER_VERSION"; fabric_api_version="TODO_FABRIC_API_VERSION"; with_mixin=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help|-Help|--Help) show_usage; exit 0 ;;
    -ProjectName|--project-name) project_name="${2:-}"; shift 2 ;;
    -PackageBase|--package-base) package_base="${2:-}"; shift 2 ;;
    -OutputDir|--output-dir) output_dir="${2:-}"; shift 2 ;;
    --mod-id) mod_id="${2:-}"; shift 2 ;;
    --minecraft-version) [[ "${2:-}" == "1.21.8" ]] || { echo "[ERROR] 기준 버전은 Minecraft 1.21.8입니다." >&2; exit 1; }; shift 2 ;;
    --loom-version) loom_version="${2:-}"; shift 2 ;;
    --loader-version) loader_version="${2:-}"; shift 2 ;;
    --fabric-api-version) fabric_api_version="${2:-}"; shift 2 ;;
    --with-mixin) with_mixin=true; shift ;;
    *) echo "[ERROR] 알 수 없는 인자: $1" >&2; show_usage; exit 1 ;;
  esac
done

[[ -n "$project_name" && -n "$package_base" && -n "$output_dir" ]] || { echo "[ERROR] 필수 인자가 부족합니다." >&2; exit 1; }
[[ "$project_name" =~ ^[a-zA-Z0-9._-]+$ ]] || { echo "[ERROR] ProjectName 형식 오류" >&2; exit 1; }
[[ "$package_base" =~ ^[a-zA-Z_][a-zA-Z0-9_]*(\.[a-zA-Z_][a-zA-Z0-9_]*)+$ ]] || { echo "[ERROR] PackageBase 형식 오류" >&2; exit 1; }

if [[ -z "$mod_id" ]]; then mod_id="$(echo "$project_name" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9_-]+/-/g; s/-+/-/g; s/^-+//; s/-+$//')"; fi
[[ "$mod_id" =~ ^[a-z][a-z0-9_-]{1,63}$ ]] || { echo "[ERROR] mod id 형식 오류" >&2; exit 1; }

camel_name="$(echo "$project_name" | sed -E 's/[^a-zA-Z0-9]+/ /g' | awk '{for(i=1;i<=NF;i++){$i=toupper(substr($i,1,1)) tolower(substr($i,2))} printf "%s",$0}' | tr -d ' ')"
[[ "$camel_name" == *Mod ]] && main_class_name="$camel_name" || main_class_name="${camel_name}Mod"
project_dir="$output_dir/$project_name"
[[ ! -e "$project_dir" ]] || { echo "[ERROR] 프로젝트 디렉터리가 이미 존재합니다: $project_dir" >&2; exit 1; }

package_path="${package_base//./\/}"
java_root="$project_dir/src/main/java/$package_path"; resources_dir="$project_dir/src/main/resources"
mkdir -p "$java_root" "$resources_dir"

printf "rootProject.name = '%s'\n" "$project_name" > "$project_dir/settings.gradle"
cat > "$project_dir/gradle.properties" <<EOF
org.gradle.jvmargs=-Xmx2G
minecraft_version=$minecraft_version
loader_version=$loader_version
fabric_api_version=$fabric_api_version
maven_group=$package_base
archives_base_name=$project_name
EOF

cat > "$project_dir/build.gradle" <<EOF
plugins {
    id 'fabric-loom' version '$loom_version'
    id 'maven-publish'
}
version = '0.1.0'
group = project.maven_group
base { archivesName = project.archives_base_name }
repositories {
    mavenCentral()
    maven { url = 'https://maven.fabricmc.net/' }
}
dependencies {
    minecraft "com.mojang:minecraft:\${project.minecraft_version}"
    mappings "net.fabricmc:yarn:\${project.yarn_mappings}:v2"
    modImplementation "net.fabricmc:fabric-loader:\${project.loader_version}"
    modImplementation "net.fabricmc.fabric-api:fabric-api:\${project.fabric_api_version}"
}
java {
    toolchain { languageVersion = JavaLanguageVersion.of(21) }
    withSourcesJar()
}
processResources {
    inputs.property 'version', project.version
    filesMatching('fabric.mod.json') { expand 'version': project.version }
}
tasks.withType(JavaCompile).configureEach { options.encoding = 'UTF-8' }
EOF

mixins_block=""
if [[ "$with_mixin" == true ]]; then
  mixins_block=$(cat <<EOF
,
  "mixins": ["$mod_id.mixins.json"]
EOF
)
fi

cat > "$resources_dir/fabric.mod.json" <<EOF
{
  "schemaVersion": 1,
  "id": "$mod_id",
  "version": "\${version}",
  "name": "$project_name",
  "description": "Fabric 1.21.8 서버사이드 모드",
  "license": "MIT",
  "environment": "server",
  "entrypoints": {"main": ["$package_base.$main_class_name"]}$mixins_block,
  "depends": {"fabricloader": ">=0.16.0", "minecraft": "~1.21.8", "fabric-api": "*"}
}
EOF

if [[ "$with_mixin" == true ]]; then
cat > "$resources_dir/$mod_id.mixins.json" <<EOF
{
  "required": true,
  "package": "$package_base.mixin",
  "compatibilityLevel": "JAVA_21",
  "mixins": [],
  "injectors": {"defaultRequire": 1}
}
EOF
fi

cat > "$java_root/$main_class_name.java" <<EOF
package $package_base;
import net.fabricmc.api.ModInitializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
public class $main_class_name implements ModInitializer {
    public static final String MOD_ID = "$mod_id";
    public static final Logger LOGGER = LoggerFactory.getLogger(MOD_ID);
    @Override public void onInitialize() { LOGGER.info("[{}] initialized", MOD_ID); }
}
EOF

cat > "$project_dir/.gitignore" <<'EOF'
.gradle/
build/
run/
out/
*.iml
*.ipr
*.iws
EOF

echo "[OK] 생성 완료: $project_dir"
echo "[INFO] mod id: $mod_id"
echo "[INFO] Mixin: $with_mixin"
echo "[INFO] Polymer가 필요하면 minecraft-polymer-server-content를 사용하세요."
