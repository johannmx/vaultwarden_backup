#!/bin/sh

# --------------- [ PREREQUISITES ] ---------------

EXTENSION="tar.xz"


# ------------------ [ BACKUP ] ------------------

cd /data

BACKUP_LOCATION="/backups/$(date +"%F_%H-%M-%S").${EXTENSION}"

BACKUP_DB="db.sqlite3" # file
BACKUP_RSA="rsa_key*" # files
BACKUP_CONFIG="config.json" # file
BACKUP_ATTACHMENTS="attachments" # directory
BACKUP_SENDS="sends" # directory

# Back up files and folders.
tar -Jcf $BACKUP_LOCATION $BACKUP_DB $BACKUP_RSA $BACKUP_CONFIG $BACKUP_ATTACHMENTS $BACKUP_SENDS 2>/dev/null

OUTPUT="${OUTPUT}New backup created"


# ------------------ [ DELETE ] ------------------

if [ -n "$DELETE_AFTER" ] && [ "$DELETE_AFTER" -gt 0 ]; then
    cd /backups

    # Find all archives older than x days, store them in a variable, delete them.
    TO_DELETE=$(find . -iname "*.${EXTENSION}" -type f -mtime +$DELETE_AFTER)
    find . -iname "*.${EXTENSION}" -type f -mtime +$DELETE_AFTER -exec rm -f {} \;

    OUTPUT="${OUTPUT}, $([ ! -z "$TO_DELETE" ] \
                       && echo "deleted $(echo "$TO_DELETE" | wc -l) archives older than ${DELETE_AFTER} days" \
                       || echo "no archives older than ${DELETE_AFTER} days to delete")"
fi


# ------------------ [ EXIT ] ------------------

echo "[$(date +"%F %r")] ${OUTPUT}."

# ------------------ [ Gotify Notifications ] ------------------
echo "[$(date +"%F %r")] Sending notification to Gotify Server."
#curl "https://${GOTIFY_SERVER}/message?token=${GOTIFY_TOKEN}" -F "title=Vaultwarden Backup" -F "message=${OUTPUT}" -F "priority=5" # Send message to Gotify
apprise -vv -t "Backup Vaultwarden" -b "☑️ 💾 ${OUTPUT}" \
   "gotifys://${GOTIFY_SERVER}/${GOTIFY_TOKEN}/?priority=high"

# ------------------ [ Slack Notifications ] ------------------
echo "[$(date +"%F %r")] Sending notification to Slack."
apprise -vv -t "💾 Backup Vaultwarden" -b "☑️ ${OUTPUT}" \
   "${SLACK_WEBHOOK}"

# ------------------ [ Slack Notifications ] ------------------
echo "[$(date +"%F %r")] Sending notification to Slack."
apprise -vv -t "💾 Backup Vaultwarden" -b "☑️ ${OUTPUT}" \
   "https://hooks.slack.com/services/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/?footer=no"

# ------------------ [ Telegram Notifications ] ------------------
# echo "[$(date +"%F %r")] Sending notification to Telegram."
# apprise -vv -t "💾 Backup Vaultwarden" -b "☑️ ${OUTPUT}" \
#    "tgram://${TGRAM_BOT_TOKEN}/${TGRAM_CHAT_ID}"