#!/bin/bash
set -euo pipefail

# Configuration
SCRIPT_PATH="/app/script.sh"
LOGS_DIR="/app/log"
LOGS_FILE="${LOGS_DIR}/backup.log"

# Logging function
log() {
    echo "[$(date +"%F %r")] $1" | tee -a "$LOGS_FILE"
}

# Ensure directories exist
mkdir -p "$LOGS_DIR"

# Run manual backup if requested
if [[ "${1:-}" == "manual" ]]; then
    log "Running manual backup..."
    exec su-exec app:app bash "$SCRIPT_PATH"
fi

# Setup Cron as root
log "Configuring backup schedule: ${CRON_TIME}"
echo "${CRON_TIME} su-exec app:app /bin/bash ${SCRIPT_PATH} >> ${LOGS_FILE} 2>&1" | crontab -

# Start crond in foreground
log "Starting crond..."
exec crond -f -L /dev/stdout

