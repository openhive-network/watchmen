#!/bin/bash
# Validate community submissions in merge requests
# Non-blocking: provides warnings for contributors

set -euo pipefail

WARNINGS=0

warn() {
    echo "⚠ WARNING: $1"
    WARNINGS=$((WARNINGS + 1))
}

info() {
    echo "  $1"
}

normalize() {
    tr -d '\r' | sort -u
}

# Get changed community files
CHANGED=$(git diff --name-only origin/main...HEAD -- 'input/community/*.txt' 2>/dev/null || true)

if [ -z "$CHANGED" ]; then
    echo "No community files changed."
    exit 0
fi

echo "Checking community submissions..."
echo

for file in $CHANGED; do
    if [ ! -f "$file" ]; then
        continue
    fi

    echo "Checking: $file"

    normalize < "$file" > /tmp/new_sorted.txt
    new_count=$(wc -l < /tmp/new_sorted.txt)

    if git show origin/main:"$file" &>/dev/null 2>&1; then
        # Modified file: check diff vs actual new content
        git show origin/main:"$file" | normalize > /tmp/old_sorted.txt

        new_entries=$(comm -23 /tmp/new_sorted.txt /tmp/old_sorted.txt | wc -l)
        removed_entries=$(comm -13 /tmp/new_sorted.txt /tmp/old_sorted.txt | wc -l)

        diff_stats=$(git diff --numstat origin/main...HEAD -- "$file" | head -1)
        additions=$(echo "$diff_stats" | awk '{print $1}')
        deletions=$(echo "$diff_stats" | awk '{print $2}')
        total_diff=$((additions + deletions))

        info "New entries: $new_entries, Removed: $removed_entries"
        info "Diff lines: +$additions -$deletions (total: $total_diff)"

        if [ "$new_entries" -eq 0 ] && [ "$removed_entries" -eq 0 ] && [ "$total_diff" -gt 0 ]; then
            warn "$file has line changes but no actual content change (formatting/encoding only?)"
        elif [ "$new_entries" -gt 0 ] && [ "$total_diff" -gt $((new_entries * 5)) ]; then
            warn "$file diff ($total_diff lines) is excessive for $new_entries new entries"
            info "Consider appending new entries instead of reorganizing the file."
        fi
    else
        # New file: check overlap with existing files
        info "New file with $new_count entries"

        for existing in input/community/*.txt; do
            [ -f "$existing" ] || continue
            [ "$existing" = "$file" ] && continue

            normalize < "$existing" > /tmp/existing_sorted.txt
            overlap=$(comm -12 /tmp/new_sorted.txt /tmp/existing_sorted.txt | wc -l)

            if [ "$new_count" -gt 0 ] && [ "$overlap" -gt 0 ]; then
                overlap_pct=$((overlap * 100 / new_count))

                if [ "$overlap_pct" -gt 50 ]; then
                    warn "$file has ${overlap_pct}% overlap with $existing ($overlap of $new_count entries)"
                    info "Consider appending to existing file instead of creating a new one."
                fi
            fi
        done
    fi
    echo
done

rm -f /tmp/new_sorted.txt /tmp/old_sorted.txt /tmp/existing_sorted.txt

if [ "$WARNINGS" -gt 0 ]; then
    echo "Found $WARNINGS warning(s). Please review submission guidelines in README.md"
    exit 1
fi

echo "All checks passed."
exit 0
