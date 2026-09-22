#!/usr/bin/env bash
set -euo pipefail

version="1.21.8"
pack_name=""
namespace=""
output_dir=""

show_usage() {
  cat <<'USAGE'
Usage:
  ./create_datapack_scaffold.sh --pack-name <name> --namespace <ns> --output-dir <path> [--version 1.21.8]
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) show_usage; exit 0 ;;
    --version) version="${2:-}"; shift 2 ;;
    --pack-name) pack_name="${2:-}"; shift 2 ;;
    --namespace) namespace="${2:-}"; shift 2 ;;
    --output-dir) output_dir="${2:-}"; shift 2 ;;
    *) echo "[ERROR] unknown argument: $1" >&2; show_usage; exit 1 ;;
  esac
done

if [[ "$version" != "1.21.8" ]]; then
  echo "[ERROR] this bundle supports Minecraft Java 1.21.8 only" >&2
  exit 1
fi
if [[ -z "$pack_name" || -z "$namespace" || -z "$output_dir" ]]; then
  echo "[ERROR] --pack-name, --namespace, and --output-dir are required" >&2
  exit 1
fi
if ! [[ "$namespace" =~ ^[a-z0-9_-]+$ ]]; then
  echo "[ERROR] namespace must use lowercase letters, digits, underscore, or hyphen" >&2
  exit 1
fi

pack_dir="$output_dir/$pack_name"
[[ ! -e "$pack_dir" ]] || { echo "[ERROR] target already exists: $pack_dir" >&2; exit 1; }

mkdir -p "$pack_dir/data/minecraft/tags/function" \
  "$pack_dir/data/$namespace/function/init" \
  "$pack_dir/data/$namespace/function/loop" \
  "$pack_dir/data/$namespace/function/feature" \
  "$pack_dir/data/$namespace/advancement" \
  "$pack_dir/data/$namespace/loot_table" \
  "$pack_dir/data/$namespace/recipe" \
  "$pack_dir/data/$namespace/predicate" \
  "$pack_dir/data/$namespace/structure" \
  "$pack_dir/data/$namespace/worldgen"

cat > "$pack_dir/pack.mcmeta" <<EOF
{
  "pack": {
    "description": "$pack_name (1.21.8)",
    "pack_format": 81
  }
}
EOF

cat > "$pack_dir/data/minecraft/tags/function/load.json" <<EOF
{ "replace": false, "values": ["$namespace:init/load"] }
EOF
cat > "$pack_dir/data/minecraft/tags/function/tick.json" <<EOF
{ "replace": false, "values": ["$namespace:loop/tick"] }
EOF
cat > "$pack_dir/data/$namespace/function/init/load.mcfunction" <<EOF
# initialization entrypoint
EOF
cat > "$pack_dir/data/$namespace/function/loop/tick.mcfunction" <<EOF
# keep recurring work bounded; call feature functions only when needed
EOF

echo "[OK] created Minecraft 1.21.8 datapack scaffold: $pack_dir"
