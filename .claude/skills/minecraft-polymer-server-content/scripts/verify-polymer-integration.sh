#!/usr/bin/env bash
set -euo pipefail

project_dir=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-dir|-ProjectDir) project_dir="${2:-}"; shift 2 ;;
    -h|--help) echo "Usage: verify-polymer-integration.sh --project-dir <path>"; exit 0 ;;
    *) echo "[ERROR] unknown argument: $1" >&2; exit 1 ;;
  esac
done
[[ -n "$project_dir" && -d "$project_dir" ]] || { echo "[ERROR] valid --project-dir is required" >&2; exit 1; }

fail=0
pass(){ echo "[PASS] $1"; }
bad(){ echo "[FAIL] $1" >&2; fail=$((fail+1)); }

gp="$project_dir/gradle.properties"
[[ -f "$gp" ]] || bad "missing gradle.properties"
build=""
[[ -f "$project_dir/build.gradle" ]] && build="$project_dir/build.gradle"
[[ -z "$build" && -f "$project_dir/build.gradle.kts" ]] && build="$project_dir/build.gradle.kts"
[[ -n "$build" ]] || bad "missing build.gradle or build.gradle.kts"

if [[ -f "$gp" ]]; then
  grep -qE '^minecraft_version=1\.21\.8$' "$gp" && pass "minecraft_version=1.21.8" || bad "minecraft_version must be 1.21.8"
  grep -qF 'polymer_version=0.13.13+1.21.8' "$gp" && pass "polymer_version=0.13.13+1.21.8" || bad "polymer_version must be 0.13.13+1.21.8"
fi

if [[ -n "$build" ]]; then
  bg="$(cat "$build")"
  grep -Fq 'maven.nucleoid.xyz' <<<"$bg" && pass "Nucleoid Maven repository present" || bad "missing maven.nucleoid.xyz repository"
  modules=(polymer-core polymer-resource-pack polymer-blocks polymer-virtual-entity polymer-networking)
  found=()
  for m in "${modules[@]}"; do grep -Fq "eu.pb4:$m:" <<<"$bg" && found+=("$m"); done
  (( ${#found[@]} > 0 )) && pass "Polymer modules: ${found[*]}" || bad "no supported eu.pb4 Polymer module found"
  if printf '%s\n' "${found[@]}" | grep -qx 'polymer-blocks'; then
    printf '%s\n' "${found[@]}" | grep -qx 'polymer-core' || bad "polymer-blocks requires explicit polymer-core integration"
    printf '%s\n' "${found[@]}" | grep -qx 'polymer-resource-pack' || bad "polymer-blocks requires explicit polymer-resource-pack integration"
  fi
  grep -qE 'JavaLanguageVersion\.of\(21\)|jvmToolchain\(21\)' <<<"$bg" && pass "Java 21 toolchain detected" || bad "Java 21 toolchain declaration not found"
fi

echo "Summary: FAIL=$fail"
(( fail == 0 ))
