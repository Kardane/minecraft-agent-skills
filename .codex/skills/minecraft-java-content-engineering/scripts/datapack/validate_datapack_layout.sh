#!/usr/bin/env bash
set -euo pipefail

pack_dir=""
version="1.21.8"

show_usage() {
  cat <<'USAGE'
Usage:
  ./validate_datapack_layout.sh --pack-dir <path> [--version 1.21.8]
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) show_usage; exit 0 ;;
    --pack-dir) pack_dir="${2:-}"; shift 2 ;;
    --version) version="${2:-}"; shift 2 ;;
    *) echo "[ERROR] unknown argument: $1" >&2; show_usage; exit 1 ;;
  esac
done

[[ -n "$pack_dir" ]] || { echo "[ERROR] --pack-dir is required" >&2; exit 1; }
[[ "$version" == "1.21.8" ]] || { echo "[ERROR] this bundle supports Minecraft Java 1.21.8 only" >&2; exit 1; }

fail=0
check_file() {
  if [[ -f "$1" ]]; then echo "[PASS] file: $1"; else echo "[FAIL] missing file: $1"; fail=$((fail + 1)); fi
}

check_file "$pack_dir/pack.mcmeta"
check_file "$pack_dir/data/minecraft/tags/function/load.json"
check_file "$pack_dir/data/minecraft/tags/function/tick.json"
[[ -d "$pack_dir/data" ]] || { echo "[FAIL] missing data directory"; fail=$((fail + 1)); }

if [[ -f "$pack_dir/pack.mcmeta" ]]; then
  if grep -q '"pack_format"[[:space:]]*:[[:space:]]*81' "$pack_dir/pack.mcmeta"; then
    echo "[PASS] Minecraft 1.21.8 pack_format: 81"
  else
    echo "[FAIL] Minecraft 1.21.8 requires pack_format: 81"
    fail=$((fail + 1))
  fi
  if grep -qE '"(min_format|max_format)"' "$pack_dir/pack.mcmeta"; then
    echo "[FAIL] later-version min_format/max_format keys are not part of this 1.21.8 baseline"
    fail=$((fail + 1))
  fi
fi

if find "$pack_dir/data" -type f -name '*.mcfunction' -print -quit | grep -q .; then
  echo "[PASS] mcfunction present"
else
  echo "[WARN] no mcfunction files found"
fi

(( fail == 0 ))
