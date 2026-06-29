#!/usr/bin/env bash
# =============================================================================
# analyze_logs.sh — Nginx Access Log Analyser (awk + sort + uniq approach)
# Usage: ./analyze_logs.sh <path-to-log-file>
# =============================================================================

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <nginx-access-log>" >&2
  exit 1
fi

LOG_FILE="$1"

if [[ ! -f "$LOG_FILE" ]]; then
  echo "Error: File '$LOG_FILE' not found." >&2
  exit 1
fi

# ── Helper: pretty section header ────────────────────────────────────────────
header() { printf '\n\033[1;34m%s\033[0m\n' "$1"; }

# ── Helper: read ranked "count value" lines, align into "value - count requests"
# $1 = optional max label width (truncates with ... beyond this)
print_aligned() {
  local max_width="${1:-0}"
  local -a counts labels
  local width=0

  while read -r count label; do
    counts+=("$count")
    labels+=("$label")
    (( ${#label} > width )) && width=${#label}
  done

  # Cap width for truncation mode
  [[ $max_width -gt 0 && $max_width -lt $width ]] && width=$max_width

  for i in "${!labels[@]}"; do
    local lbl="${labels[$i]}"
    if [[ $max_width -gt 0 && ${#lbl} -gt $max_width ]]; then
      lbl="${lbl:0:$(( max_width - 3 ))}..."
    fi
    printf "%-${width}s - %s requests\n" "$lbl" "${counts[$i]}"
  done
}

# ── 1. Top 5 IP addresses ────────────────────────────────────────────────────
header "Top 5 IP addresses with the most requests:"
awk '{print $1}' "$LOG_FILE" \
  | sort | uniq -c | sort -rn | head -5 \
  | print_aligned

# ── 2. Top 5 most requested paths ───────────────────────────────────────────
header "Top 5 most requested paths:"
awk '{print $7}' "$LOG_FILE" \
  | sort | uniq -c | sort -rn | head -5 \
  | print_aligned

# ── 3. Top 5 response status codes ──────────────────────────────────────────
header "Top 5 response status codes:"
awk '{print $9}' "$LOG_FILE" \
  | grep -E '^[0-9]{3}$' \
  | sort | uniq -c | sort -rn | head -5 \
  | print_aligned

# ── 4. Top 5 user agents (truncated to 60 chars) ────────────────────────────
header "Top 5 user agents:"
awk -F'"' '{print $6}' "$LOG_FILE" \
  | sort | uniq -c | sort -rn | head -5 \
  | print_aligned 60

echo
