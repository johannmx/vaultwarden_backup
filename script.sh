#!/bin/bash
set -euo pipefail

# Configuration
EXTENSION="tar.xz"
BACKUP_FILES=(
    "db_backup.sqlite3"
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
    # Optional: notify on failure
    exit 1
}

# Create backup
log "Starting backup process"
cd /data || handle_error "Failed to access /data directory"

TIMESTAMP=$(date +"%F_%H-%M-%S")
BACKUP_LOCATION="/backups/${TIMESTAMP}.${EXTENSION}"

# Safe SQLite backup
if [ -f "db.sqlite3" ]; then
    log "Performing safe SQLite backup..."
    sqlite3 db.sqlite3 ".backup 'db_backup.sqlite3'" || handle_error "SQLite backup failed"
fi

log "Creating archive: $BACKUP_LOCATION"
# Create backup archive (excluding the live database)
if ! tar -Jcf "$BACKUP_LOCATION" "${BACKUP_FILES[@]}" --exclude="db.sqlite3" 2>/dev/null; then
    rm -f db_backup.sqlite3
    handle_error "Failed to create backup archive"
fi

# Cleanup temp backup file
rm -f db_backup.sqlite3

OUTPUT="Backup created: $(basename "$BACKUP_LOCATION")"
log "$OUTPUT"

# Cleanup old backups
if [[ -n "${DELETE_AFTER:-}" && "$DELETE_AFTER" -gt 0 ]]; then
    log "Cleaning up backups older than $DELETE_AFTER days..."
    
    # Efficient cleanup using find
    DELETED_COUNT=$(find /backups -name "*.${EXTENSION}" -type f -mtime +"$DELETE_AFTER" -exec rm -v {} \; | wc -l)
    
    if [ "$DELETED_COUNT" -gt 0 ]; then
        OUTPUT="${OUTPUT}. Deleted $DELETED_COUNT old archives."
        log "Deleted $DELETED_COUNT old backups."
    else
        log "No old backups to delete."
    fi
fi

# Send notifications
send_notification() {
    local title="$1"
    local message="$2"
    local url="$3"
    
    [[ -z "$url" ]] && return 0
    
    log "Sending notification via Apprise..."
    if ! apprise -t "$title" -b "$message" "$url"; then
        log "WARNING: Failed to send notification to $url"
    fi
}

# Gotify
if [[ -n "${GOTIFY_SERVER:-}" && -n "${GOTIFY_TOKEN:-}" ]]; then
    send_notification "Backup Vaultwarden" "☑️ 💾 ${OUTPUT}" \
        "gotifys://${GOTIFY_SERVER}/${GOTIFY_TOKEN}/?priority=high"
fi

# Slack
if [[ -n "${SLACK_WEBHOOK:-}" ]]; then
    send_notification "💾 Backup Vaultwarden" "☑️ ${OUTPUT}" "${SLACK_WEBHOOK}"
fi

# Discord
if [[ -n "${DISCORD_WEBHOOK_ID:-}" && -n "${DISCORD_WEBHOOK_TOKEN:-}" ]]; then
    send_notification "Info Status Backup" "💾 ${OUTPUT}" \
        "discord://${DISCORD_WEBHOOK_ID}/${DISCORD_WEBHOOK_TOKEN}/?avatar=No"
fi

log "Backup process completed successfully"