#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
project_root="$(dirname "$script_dir")"
input_root="$project_root/input"
output_dir="$project_root/output/flat"
mkdir -p "$output_dir"
output_file="$output_dir/badactors.txt"

# Source files to process
files=(
  "$input_root/condenser/BadActorList.js"
  "$input_root/condenser-wallet/BadActorList.js"
  "$input_root/denser/bad-actor-list.ts"
  "$input_root/ecency/bad-actors.json"
)

{
  for file in "${files[@]}"; do
    if [[ ! -f "$file" ]]; then
      echo "Warning: $file not found, skipping." >&2
      continue
    fi

    ext="${file##*.}"
    if [[ "$ext" == "js" || "$ext" == "ts" ]]; then
      tail -n +2 "$file" | head -n -5
    elif [[ "$ext" == "json" ]]; then
      grep -Eo '"[^"]+"' "$file" | tr -d '"'
    else
      echo "Skipping unsupported file: $file" >&2
    fi
  done
} | sort -u > "$output_file"

echo "Generated flat list: $output_file"
