# Nginx Log Analyser

A command-line tool that parses Nginx access logs and surfaces the top-5 ranked entries across four key dimensions: IP addresses, request paths, response status codes, and user agents.

---

## Files

| File | Description |
|---|---|
| `analyze_logs.sh` | — uses `awk`, `sort`, `uniq`, `head` |

---

## Usage

```bash
# Make executable (first time only)
chmod +x analyze_logs.sh

# Run the script with the path to your log file
./analyze_logs.sh nginx-access.log
```

---

## Sample output

```
Top 5 IP addresses with the most requests:
178.128.94.113 - 1087 requests
142.93.136.176 - 1087 requests
138.68.248.85  - 1087 requests
159.89.185.30  - 1086 requests
86.134.118.70  - 277 requests

Top 5 most requested paths:
/v1-health           - 4560 requests
/                    - 270 requests
/v1-me               - 232 requests
/v1-list-workspaces  - 127 requests
/v1-list-timezone-teams - 75 requests

Top 5 response status codes:
200 - 5740 requests
404 - 937 requests
304 - 621 requests
400 - 260 requests
403 - 23 requests

Top 5 user agents:
DigitalOcean Uptime Probe 0.22.0 (https://digitalocean.com) - 4347 requests
Mozilla/5.0 (Windows NT 10.0; Win64; x64) ... Chrome/129.0.0.0 - 513 requests
Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) ... Chrome/129.0.0.0 - 332 requests
Custom-AsyncHttpClient - 294 requests
Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) ... Chrome/128.0.0.0 - 282 requests
```

---

## Requirements

| Tool | Needed by |
|---|---|
| `bash` ≥ 3.2
| `awk` (gawk / mawk / nawk) | `analyze_logs.sh` |

---

## How it works

### Log format

Each line in a standard Nginx combined-log looks like:

```
<IP> - - [date] "METHOD /path HTTP/x.x" <status> <size> "referrer" "user-agent"
```

Field positions (1-indexed, space-delimited):

| Field | Position | Notes |
|---|---|---|
| IP address | `$1` | First token |
| Request path | `$7` | 7th space-delimited token (inside the quoted request string) |
| Status code | `$9` | Follows the closing `"` of the request |
| User agent | last `"…"` | Sixth `"`-delimited field |

---

### Solution

```
awk '{print $FIELD}' log | sort | uniq -c | sort -rn | head -5 | awk '{format}'
```

- `awk` extracts the target field from every line.
- `sort` groups identical values together.
- `uniq -c` counts consecutive duplicates, prepending the count.
- `sort -rn` re-sorts numerically in descending order.
- `head -5` keeps only the top 5.
- A final `awk` reformats `count value` → `value - count requests`.
