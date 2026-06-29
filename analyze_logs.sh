#!/usr/bin/env bash
# =============================================================================
# Usage: ./analyze_logs.sh <path-to-log-file>
# =============================================================================

set -euo pipefail

# ── Argument validation ───────────────────────────────────────────────────────
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

# ── 1. Top 5 IP addresses ────────────────────────────────────────────────────
header "Top 5 IP addresses with the most requests:"
awk '{print $1}' "$LOG_FILE" \
  | sort \
  | uniq -c \
  | sort -rn \
  | head -5 \
  | awk '{printf "%s - %s requests\n", $2, $1}'

# ── 2. Top 5 most requested paths ───────────────────────────────────────────
header "Top 5 most requested paths:"
awk '{print $7}' "$LOG_FILE" \
  | sort \
  | uniq -c \
  | sort -rn \
  | head -5 \
  | awk '{printf "%s - %s requests\n", $2, $1}'

# ── 3. Top 5 response status codes ──────────────────────────────────────────
header "Top 5 response status codes:"
awk '{print $9}' "$LOG_FILE" \
  | grep -E '^[0-9]{3}$' \
  | sort \
  | uniq -c \
  | sort -rn \
  | head -5 \
  | awk '{printf "%s - %s requests\n", $2, $1}'

# ── 4. Top 5 user agents ────────────────────────────────────────────────────
header "Top 5 user agents:"
awk -F'"' '{print $6}' "$LOG_FILE" \
  | sort \
  | uniq -c \
  | sort -rn \
  | head -5 \
  | awk '{
      count = $1
      $1 = ""
      sub(/^ /, "")
      printf "%s - %s requests\n", $0, count
    }'

echo
