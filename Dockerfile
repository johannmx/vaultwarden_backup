FROM alpine:latest

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    CRON_TIME="0 2 * * *" \
    UID=1000 \
    GID=1000 \
    DELETE_AFTER=30

# Install dependencies and setup user
RUN apk add --no-cache \
    bash \
    busybox-suid \
    su-exec \
    xz \
    tzdata \
    sqlite \
    python3 \
    py3-pip \
    && pip3 install --no-cache-dir --break-system-packages apprise \
    && addgroup -g ${GID} app \
    && adduser -u ${UID} -G app -D app \
    && mkdir -p /app/log /backups /data \
    && chown -R app:app /app /backups /data

# Copy scripts
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chmod=755 script.sh /app/script.sh

WORKDIR /app

ENTRYPOINT ["entrypoint.sh"]