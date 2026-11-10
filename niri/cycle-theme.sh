#!/usr/bin/env bash
# Cycle Noctalia 5.x color schemes.
# Usage: cycle-theme.sh next | prev

set -euo pipefail

BUILTIN_DIR="$HOME/.config/noctalia/Assets/ColorScheme"
CUSTOM_DIR="$HOME/.config/noctalia/colorschemes"

direction="${1:-next}"
if [[ "$direction" != "next" && "$direction" != "prev" ]]; then
    echo "Usage: $0 <next|prev>" >&2
    exit 1
fi

declare -a kinds=()
declare -a names=()

while IFS=$'\t' read -r kind name; do
    kinds+=("$kind")
    names+=("$name")
done < <(
    {
        find -L "$BUILTIN_DIR" -mindepth 2 -maxdepth 2 -name "*.json" -type f -printf 'builtin\t%f\n' 2>/dev/null
        find -L "$CUSTOM_DIR" -mindepth 2 -maxdepth 2 -name "*.json" -type f -printf 'custom\t%f\n' 2>/dev/null
    } | sed 's/\.json$//' | sort -f -t$'\t' -k2 | uniq -f1 -i
)

if [[ ${#names[@]} -eq 0 ]]; then
    echo "No color schemes found under $BUILTIN_DIR or $CUSTOM_DIR" >&2
    exit 1
fi

current_line="$(noctalia msg color-scheme-get 2>/dev/null || true)"
current="${current_line#* }"

idx=-1
for i in "${!names[@]}"; do
    if [[ "${names[$i],,}" == "${current,,}" ]]; then
        idx=$i
        break
    fi
done

count=${#names[@]}
if (( idx < 0 )); then
    if [[ "$direction" == "next" ]]; then
        idx=0
    else
        idx=$((count - 1))
    fi
elif [[ "$direction" == "next" ]]; then
    idx=$(((idx + 1) % count))
else
    idx=$(((idx - 1 + count) % count))
fi

noctalia msg color-scheme-set "${kinds[$idx]}" "${names[$idx]}"
