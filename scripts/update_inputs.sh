#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
project_root="$(dirname "$script_dir")"
input_root="$project_root/input"

for dir in "$input_root"/*; do
  if [[ -d "$dir" && -f "$dir/sources.list" ]]; then
    echo "Updating inputs in $dir..."
    while IFS= read -r url; do
      [[ -z "$url" || "${url:0:1}" == "#" ]] && continue
      filename="$(basename "$url")"
      wget -q -O "$dir/$filename" "$url"
    done < "$dir/sources.list"
  fi
done

echo "All input sources updated."
