#!/bin/sh
set -euo pipefail

# Configuration
SCRIPT_CMD="/sbin/su-exec ${UID}:${GID} /app/script.sh"
LOGS_FILE="/app/log/log.log"
CRON_LOG="/app/log/cron.log"

# Logging function
log() {
    echo "[$(date +"%F %r")] $1" | tee -a "$LOGS_FILE"
}

# Error handling function
handle_error() {
    log "ERROR: $1"
    exit 1
}

# Ensure log directory exists
mkdir -p "$(dirname "$LOGS_FILE")" || handle_error "Failed to create log directory"

# Manual execution mode
if [ "${1:-}" = "manual" ]; then
    log "Running in manual mode"
    $SCRIPT_CMD || handle_error "Manual execution failed"
    exit 0
fi

# Root user operations
if [ "$(id -u)" -eq 0 ]; then
    # Clear existing cron jobs
    crontab -l 2>/dev/null | grep -v "$SCRIPT_CMD" | crontab - || handle_error "Failed to clear cron jobs"
    log "Cron jobs cleared"

    # Validate CRON_TIME
    if [ -z "${CRON_TIME:-}" ]; then
        handle_error "CRON_TIME environment variable is not set"
    fi

    # Add script to cron jobs
    (crontab -l 2>/dev/null; echo "$CRON_TIME $SCRIPT_CMD >> $LOGS_FILE 2>&1") | crontab - || handle_error "Failed to add cron job"
    log "Added script to cron jobs"
fi

# Start crond if not running
if ! pgrep crond > /dev/null 2>&1; then
    /usr/sbin/crond -L "$CRON_LOG" || handle_error "Failed to start crond service"
    log "Started crond service"
fi

# Restart as non-root user
if [ "$(id -u)" -eq 0 ]; then
    log "Switching to non-root user"
    exec su-exec app:app "$0" "$@"
fi

# Main execution
log "Running automatically (${CRON_TIME})"
tail -F "$LOGS_FILE" # Keep terminal open and display logs
