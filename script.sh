#!/bin/sh
set -euo pipefail

# Configuration
EXTENSION="tar.xz"
BACKUP_FILES=(
    "db.sqlite3"
    "rsa_key*"
    "config.json"
    "attachments"
    "sends"
)

# Logging function
log() {
    echo "[$(date +"%F %r")] $1"
}

# Error handling function
handle_error() {
    log "ERROR: $1"
    exit 1
}

# Validate environment variables
[ -z "${GOTIFY_TOKEN:-}" ] && handle_error "GOTIFY_TOKEN is not set"
[ -z "${GOTIFY_SERVER:-}" ] && handle_error "GOTIFY_SERVER is not set"

# Create backup
log "Starting backup process"
cd /data || handle_error "Failed to change to /data directory"

BACKUP_LOCATION="/backups/$(date +"%F_%H-%M-%S").${EXTENSION}"
log "Creating backup at: $BACKUP_LOCATION"

# Create backup archive
if ! tar -Jcf "$BACKUP_LOCATION" "${BACKUP_FILES[@]}" 2>/dev/null; then
    handle_error "Failed to create backup archive"
fi

OUTPUT="New backup created: $(basename "$BACKUP_LOCATION")"
log "$OUTPUT"

# Cleanup old backups
if [ -n "${DELETE_AFTER:-}" ] && [ "$DELETE_AFTER" -gt 0 ]; then
    log "Checking for backups older than $DELETE_AFTER days"
    cd /backups || handle_error "Failed to change to /backups directory"

    TO_DELETE=$(find . -iname "*.${EXTENSION}" -type f -mtime +"$DELETE_AFTER")
    if [ -n "$TO_DELETE" ]; then
        log "Found $(echo "$TO_DELETE" | wc -l) old backups to delete"
        find . -iname "*.${EXTENSION}" -type f -mtime +"$DELETE_AFTER" -exec rm -f {} \;
        OUTPUT="${OUTPUT}, deleted $(echo "$TO_DELETE" | wc -l) archives older than ${DELETE_AFTER} days"
    else
        OUTPUT="${OUTPUT}, no archives older than ${DELETE_AFTER} days to delete"
    fi
fi

# Send notifications
send_notification() {
    local title="$1"
    local message="$2"
    local url="$3"
    
    log "Sending notification to $title"
    if ! apprise -vv -t "$title" -b "$message" "$url"; then
        log "WARNING: Failed to send $title notification"
    fi
}

# Gotify notification
send_notification "Backup Vaultwarden" "☑️ 💾 ${OUTPUT}" \
    "gotifys://${GOTIFY_SERVER}/${GOTIFY_TOKEN}/?priority=high"

# Slack notification
if [ -n "${SLACK_WEBHOOK:-}" ]; then
    send_notification "💾 Backup Vaultwarden" "☑️ ${OUTPUT}" "${SLACK_WEBHOOK}"
fi

# Discord notification
if [ -n "${DISCORD_WEBHOOK_ID:-}" ] && [ -n "${DISCORD_WEBHOOK_TOKEN:-}" ]; then
    send_notification "Info Status Backup" "💾 ${OUTPUT}" \
        "discord://${DISCORD_WEBHOOK_ID}/${DISCORD_WEBHOOK_TOKEN}/?avatar=No"
fi

log "Backup process completed successfully"