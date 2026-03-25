# WORC Job Scraper

Automated bash script that fetches job postings from the Cayman Islands Workforce Opportunities Resource Centre (WORC) government portal. Designed for job seekers who want to track new opportunities with hourly automated scraping.

## Key Features

- **Automated Data Collection** - Fetches job postings from the WORC API endpoint
- **CSV Export** - Converts JSON responses to structured CSV format for easy analysis
- **Rate Limiting** - Implements random delays (10-45 seconds) to simulate human behavior
- **Comprehensive Logging** - Timestamped logs for monitoring and debugging
- **Cron-Ready** - Built to run hourly via cron for continuous job tracking
- **Error Handling** - Graceful failure with detailed error messages and exit codes

---

## Table of Contents

1. [Tech Stack](#tech-stack)
2. [Prerequisites](#prerequisites)
3. [Getting Started](#getting-started)
4. [Configuration](#configuration)
5. [How It Works](#how-it-works)
6. [Output Files](#output-files)
7. [Automation (Cron)](#automation-cron)
8. [Environment Variables](#environment-variables)
9. [Available Commands](#available-commands)
10. [Troubleshooting](#troubleshooting)
11. [Legal & Ethics](#legal--ethics)
12. [Project Structure](#project-structure)

---

## Tech Stack

- **Language**: Bash 4.0+
- **HTTP Client**: wget
- **JSON Processor**: jq
- **Target API**: WORC Job Portal (Cayman Islands Government)

---

## Prerequisites

Before running this scraper, ensure you have the following installed:

| Tool | Version | Purpose |
|------|---------|---------|
| **bash** | 4.0+ | Script execution |
| **wget** | Any | HTTP requests to WORC API |
| **jq** | 1.5+ | JSON parsing and CSV conversion |

### Install Dependencies

**Debian/Ubuntu:**
```bash
sudo apt-get update
sudo apt-get install wget jq
```

**Fedora/RHEL:**
```bash
sudo dnf install wget jq
```

**macOS (with Homebrew):**
```bash
brew install wget jq
```

**Arch Linux:**
```bash
sudo pacman -S wget jq
```

### Verify Installation

```bash
bash --version    # Should show 4.0 or higher
wget --version    # Should display version info
jq --version      # Should show 1.5 or higher
```

---

## Getting Started

### 1. Clone or Download

If you haven't already, place the script in your desired directory:

```bash
cd /home/god2/Downloads/WORC
```

### 2. Make Executable

```bash
chmod +x worc-job-scraper.sh
```

### 3. Run the Scraper

```bash
./worc-job-scraper.sh
```

### 4. View Results

After execution, check the output files:

```bash
# View the CSV data
cat WORC.csv

# View the execution log
cat worc-scraper.log

# Or monitor logs in real-time
tail -f worc-scraper.log
```

---

## Configuration

Edit these variables at the top of `worc-job-scraper.sh`:

```bash
# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="${SCRIPT_DIR}/WORC.csv"
LOG_FILE="${SCRIPT_DIR}/worc-scraper.log"
URL="https://my.egov.ky/o/worc-job-post-search/"
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36"
```

### Configuration Options

| Variable | Description | Default |
|----------|-------------|---------|
| `SCRIPT_DIR` | Directory where script is located | Auto-detected |
| `OUTPUT_FILE` | Path to output CSV file | `./WORC.csv` |
| `LOG_FILE` | Path to log file | `./worc-scraper.log` |
| `URL` | WORC API endpoint | `https://my.egov.ky/o/worc-job-post-search/` |
| `USER_AGENT` | Browser user agent string | Chrome 145 on Linux |
| `RANDOM_DELAY` | Delay range before request | 10-45 seconds |

### Customizing Rate Limiting

To adjust the delay range, modify this line:

```bash
RANDOM_DELAY=$((RANDOM % 36 + 10))  # Current: 10-45 seconds
```

**Examples:**

```bash
RANDOM_DELAY=$((RANDOM % 11 + 5))   # 5-15 seconds (faster)
RANDOM_DELAY=$((RANDOM % 61 + 30))  # 30-90 seconds (slower)
RANDOM_DELAY=$((RANDOM % 301 + 60)) # 60-360 seconds (very conservative)
```

---

## How It Works

### Execution Flow

```
┌─────────────────────────────────────────────────────────────┐
│  1. Script Starts                                           │
│     - Set error handling (set -e)                          │
│     - Configure paths and URLs                             │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  2. Rate Limiting                                           │
│     - Generate random delay (10-45s)                       │
│     - Log delay and sleep                                  │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  3. HTTP Request                                            │
│     - POST to WORC API with JSON payload                   │
│     - Include User-Agent header                            │
│     - 30s timeout, 2 retry attempts                        │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  4. Response Validation                                     │
│     - Check wget exit status                               │
│     - Log errors if request failed                         │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  5. JSON Processing                                         │
│     - Parse JSON with jq                                   │
│     - Extract field names dynamically                      │
│     - Convert arrays to pipe-separated strings             │
│     - Output as CSV format                                 │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  6. Output Verification                                     │
│     - Check if output file has content                     │
│     - Count lines and file size                            │
│     - Log success/failure                                  │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  7. Completion                                              │
│     - Calculate execution duration                         │
│     - Log final status                                     │
│     - Exit with appropriate code                           │
└─────────────────────────────────────────────────────────────┘
```

### Request Details

**Endpoint:** `https://my.egov.ky/o/worc-job-post-search/`

**Method:** POST

**Headers:**
```
Content-Type: application/json
User-Agent: Mozilla/5.0 (X11; Linux x86_64) ...
```

**Payload:**
```json
{"sortByColumnName":"Newest"}
```

**Response Format:**
```json
{
  "data": {
    "result": [
      {
        "field1": "value1",
        "field2": "value2",
        "arrayField": ["a", "b", "c"],
        ...
      }
    ]
  }
}
```

### jq Processing Logic

The script uses jq to:

1. Extract `.data.result` array
2. Dynamically detect all field names from the first record
3. Handle different data types:
   - **Arrays**: Joined with `" | "` separator
   - **Objects**: Converted to string
   - **Primitives**: Used as-is
4. Output as properly escaped CSV

---

## Output Files

### WORC.csv

**Format:** CSV (Comma-Separated Values)

**Structure:**
- First row: Header with field names
- Subsequent rows: Job posting data
- Encoding: UTF-8

**Example:**
```csv
"job_title","employer","location","posted_date","job_type","deadline"
"Administrative Assistant","Ministry of Education","George Town","2026-03-25","Full-time","2026-04-15"
"Software Developer","Tech Corp Ltd","Grand Cayman","2026-03-24","Contract","2026-04-10"
```

**Opening the CSV:**

```bash
# View in terminal
cat WORC.csv

# View with column alignment
column -t -s',' WORC.csv

# Open in spreadsheet (Linux)
libreoffice WORC.csv

# Open in spreadsheet (macOS)
open WORC.csv
```

### worc-scraper.log

**Format:** Plain text with timestamps

**Example Entries:**
```
[2026-03-25 10:30:15 EST] Waiting 23s before request (rate limiting)...
[2026-03-25 10:30:38 EST] === WORC Job Scraper Started ===
[2026-03-25 10:30:38 EST] Fetching job postings from: https://my.egov.ky/o/worc-job-post-search/
[2026-03-25 10:30:38 EST] User-Agent: Mozilla/5.0 (X11; Linux x86_64) ...
[2026-03-25 10:30:42 EST] SUCCESS: Saved 47 lines (4.0K) to /home/god2/Downloads/WORC/WORC.csv
[2026-03-25 10:30:42 EST] Total duration: 27s (including 23s delay)
[2026-03-25 10:30:42 EST] === WORC Job Scraper Completed ===
```

**Log Levels:**
- **INFO**: Normal operation messages
- **SUCCESS**: Successful completion
- **WARNING**: Non-fatal issues
- **ERROR**: Fatal errors causing script exit

---

## Automation (Cron)

### Setup Hourly Execution

1. **Open crontab editor:**
   ```bash
   crontab -e
   ```

2. **Add this line to run every hour:**
   ```cron
   0 * * * * /home/god2/Downloads/WORC/worc-job-scraper.sh
   ```

### Cron Schedule Examples

| Schedule | Cron Expression | Description |
|----------|-----------------|-------------|
| Every hour | `0 * * * *` | At minute 0 of every hour |
| Every 30 min | `*/30 * * * *` | At minutes 0 and 30 |
| Every 6 hours | `0 */6 * * *` | At midnight, 6am, noon, 6pm |
| Business hours only | `0 9-17 * * 1-5` | Every hour, 9am-5pm, Mon-Fri |
| Daily at 9am | `0 9 * * *` | Every day at 9:00 AM |
| Weekdays at 8am | `0 8 * * 1-5` | Monday-Friday at 8:00 AM |

### Cron Best Practices

**1. Use absolute paths:**
```cron
# Good
0 * * * * /home/god2/Downloads/WORC/worc-job-scraper.sh

# Bad (may not work in cron)
0 * * * * ./worc-job-scraper.sh
```

**2. Redirect cron output (optional):**
```cron
0 * * * * /home/god2/Downloads/WORC/worc-job-scraper.sh >> /home/god2/Downloads/WORC/cron.log 2>&1
```

**3. Set PATH in crontab:**
```cron
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
0 * * * * /home/god2/Downloads/WORC/worc-job-scraper.sh
```

**4. Monitor cron jobs:**
```bash
# View current cron jobs
crontab -l

# Check cron logs (systemd)
journalctl -u cron -f

# Check cron logs (traditional)
grep CRON /var/log/syslog
```

### Testing Cron Execution

Before relying on cron, test manually:

```bash
# Simulate cron environment
env -i PATH=/usr/local/bin:/usr/bin:/bin /home/god2/Downloads/WORC/worc-job-scraper.sh
```

---

## Environment Variables

The script uses these environment variables (all optional):

| Variable | Description | Default |
|----------|-------------|---------|
| `RANDOM` | Bash built-in for random numbers | Auto-generated |
| `BASH_SOURCE` | Script path detection | Auto-detected |

### Timeout Configuration

Network timeouts are hardcoded but can be modified:

```bash
# In the wget command:
--timeout=30 \   # Connection timeout in seconds
--tries=2 \      # Number of retry attempts
```

---

## Available Commands

| Command | Description |
|---------|-------------|
| `./worc-job-scraper.sh` | Run the scraper manually |
| `chmod +x worc-job-scraper.sh` | Make script executable |
| `tail -f worc-scraper.log` | Monitor logs in real-time |
| `grep ERROR worc-scraper.log` | Find error entries in logs |
| `wc -l WORC.csv` | Count job postings (including header) |
| `head WORC.csv` | Preview first 10 lines of CSV |
| `crontab -e` | Edit cron jobs |
| `crontab -l` | List current cron jobs |

---

## Troubleshooting

### wget Failed with Exit Code

**Error:**
```
[2026-03-25 10:30:38 EST] ERROR: wget failed with exit code 4
```

**Possible Causes:**

| Exit Code | Meaning | Solution |
|-----------|---------|----------|
| 1 | Generic error | Check network connectivity |
| 4 | Network failure | Verify internet connection |
| 5 | SSL verification error | Try `--no-check-certificate` |
| 8 | Server issued error | API may be down |

**Solutions:**

1. **Test network connectivity:**
   ```bash
   ping my.egov.ky
   ```

2. **Test URL accessibility:**
   ```bash
   wget --user-agent="Mozilla/5.0" --post-data='{"sortByColumnName":"Newest"}' "https://my.egov.ky/o/worc-job-post-search/"
   ```

3. **Check if site is reachable:**
   ```bash
   curl -I https://my.egov.ky/o/worc-job-post-search/
   ```

### jq Processing Failed

**Error:**
```
[2026-03-25 10:30:38 EST] ERROR: jq processing failed with exit code 5
```

**Possible Causes:**
- API response format changed
- Invalid JSON returned
- jq not installed

**Solutions:**

1. **Verify jq is installed:**
   ```bash
   jq --version
   ```

2. **Test JSON parsing manually:**
   ```bash
   echo '{"data":{"result":[]}}' | jq -r '.data.result'
   ```

3. **Check raw API response:**
   ```bash
   # Temporarily modify script to save raw response
   wget -qO- ... > raw_response.json
   cat raw_response.json | jq .
   ```

### Empty Output File

**Error:**
```
[2026-03-25 10:30:38 EST] WARNING: Output file is empty - possible API change or network issue
```

**Solutions:**

1. **Check if API returns data:**
   ```bash
   wget -qO- \
     --user-agent="Mozilla/5.0" \
     --header="Content-Type: application/json" \
     --post-data='{"sortByColumnName":"Newest"}' \
     "https://my.egov.ky/o/worc-job-post-search/" | jq '.data.result | length'
   ```

2. **Verify file permissions:**
   ```bash
   ls -la WORC.csv
   touch WORC.csv  # Create if doesn't exist
   chmod 644 WORC.csv
   ```

3. **Check disk space:**
   ```bash
   df -h .
   ```

### Script Permission Denied

**Error:**
```
bash: ./worc-job-scraper.sh: Permission denied
```

**Solution:**
```bash
chmod +x worc-job-scraper.sh
./worc-job-scraper.sh
```

### Cron Job Not Running

**Debug Steps:**

1. **Verify cron is running:**
   ```bash
   systemctl status cron    # Debian/Ubuntu
   systemctl status crond   # RHEL/Fedora
   ```

2. **Check cron logs:**
   ```bash
   grep CRON /var/log/syslog | grep worc
   ```

3. **Test with simplified command:**
   ```cron
   * * * * * echo "Cron is working" >> /tmp/cron-test.log
   ```

4. **Ensure script has execute permission:**
   ```bash
   ls -la worc-job-scraper.sh
   ```

### Rate Limiting Issues

**If you're being blocked by the server:**

1. **Increase delay:**
   ```bash
   RANDOM_DELAY=$((RANDOM % 301 + 60))  # 60-360 seconds
   ```

2. **Reduce cron frequency:**
   ```cron
   0 */4 * * *  # Every 4 hours instead of every hour
   ```

3. **Add jitter to cron:**
   ```cron
   7 * * * * /path/to/script.sh  # Run at minute 7 instead of 0
   ```

---

## Legal & Ethics

### Usage Guidelines

- **Personal Use Only** - This script is intended for individual job search purposes
- **Respectful Data Collection** - Rate limiting is implemented to avoid server overload
- **Terms of Service** - Review WORC's terms of service before automated access
- **Not for Commercial Redistribution** - Do not resell or redistribute scraped data

### Responsible Scraping

This script implements several best practices:

1. **Rate Limiting**: 10-45 second random delays between requests
2. **User-Agent Identification**: Uses standard browser user agent string
3. **Timeout Handling**: 30-second timeout prevents hanging connections
4. **Retry Logic**: Maximum 2 retry attempts before failing
5. **Error Logging**: All errors are logged for debugging

### Data Usage

- Scraped data should be used for personal job search purposes only
- Do not republish job postings without permission
- Respect employer privacy and intellectual property
- Comply with applicable data protection regulations

---

## Project Structure

```
WORC/
├── worc-job-scraper.sh    # Main scraper script (executable)
├── WORC.csv               # Output data (generated on each run)
├── worc-scraper.log       # Execution logs (appended on each run)
└── README.md              # This documentation file
```

### File Descriptions

| File | Type | Description |
|------|------|-------------|
| `worc-job-scraper.sh` | Bash Script | Main scraper logic |
| `WORC.csv` | Data File | Job postings in CSV format |
| `worc-scraper.log` | Log File | Timestamped execution history |
| `README.md` | Documentation | Project documentation |

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | March 2026 | Initial release with basic scraping functionality |

---

## Support

For questions about this script, contact the script owner.

---

## License

This script is provided as-is for personal job search purposes. No warranty is expressed or implied.

---

*Last updated: March 25, 2026*
