#!/bin/bash
#
# WORC Job Scraper
# Fetches job postings from Cayman Islands government portal
# Runs hourly via cron to track new opportunities
#
# For questions about this script, contact the script owner.
# Personal use only - respectful data collection for job search purposes.
#

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="${SCRIPT_DIR}/WORC.csv"
LOG_FILE="${SCRIPT_DIR}/worc-scraper.log"
URL="https://my.egov.ky/o/worc-job-post-search/"
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36"

# Logging function
log() {
    local TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S %Z')
    echo "[$TIMESTAMP] $1" | tee -a "$LOG_FILE"
}

# Random delay between 10-45 seconds (simulates human behavior)
RANDOM_DELAY=$((RANDOM % 36 + 10))
log "Waiting ${RANDOM_DELAY}s before request (rate limiting)..."
sleep "$RANDOM_DELAY"

# Start timing
START_TIME=$(date +%s)

log "=== WORC Job Scraper Started ==="
log "Fetching job postings from: $URL"
log "User-Agent: $USER_AGENT"

# Fetch data and convert to CSV
RESPONSE=$(wget -qO- \
  --user-agent="$USER_AGENT" \
  --header="Content-Type: application/json" \
  --post-data='{"sortByColumnName":"Newest"}' \
  --timeout=30 \
  --tries=2 \
  "$URL" 2>&1)

WGET_STATUS=$?

if [ $WGET_STATUS -ne 0 ]; then
    log "ERROR: wget failed with exit code $WGET_STATUS"
    log "Response: $RESPONSE"
    exit 1
fi

# Process with jq
echo "$RESPONSE" | \
  jq -r '.data.result | 
    (.[0] | keys_unsorted) as $keys | 
    $keys, 
    (.[] | [.[$keys[]] | 
      if type == "array" then join(" | ") 
      elif type == "object" then tostring 
      else . end
    ]) | @csv' > "$OUTPUT_FILE"

JQ_STATUS=$?

if [ $JQ_STATUS -ne 0 ]; then
    log "ERROR: jq processing failed with exit code $JQ_STATUS"
    exit 1
fi

# Calculate duration
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Verify output
if [ -s "$OUTPUT_FILE" ]; then
    LINE_COUNT=$(wc -l < "$OUTPUT_FILE")
    FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
    log "SUCCESS: Saved $LINE_COUNT lines ($FILE_SIZE) to $OUTPUT_FILE"
    log "Total duration: ${DURATION}s (including ${RANDOM_DELAY}s delay)"
else
    log "WARNING: Output file is empty - possible API change or network issue"
    exit 1
fi

log "=== WORC Job Scraper Completed ==="
log ""
