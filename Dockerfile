ARG ARCH=
FROM ${ARCH}alpine:latest

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    CRON_TIME="*/5 * * * *" \
    UID=100 \
    GID=100 \
    DELETE_AFTER=0 \
    GOTIFY_TOKEN=12345 \
    GOTIFY_SERVER=server.com \
    SLACK_WEBHOOK=slackwebhook \
    DISCORD_WEBHOOK_ID=discordwebhookid \
    DISCORD_WEBHOOK_TOKEN=discordwebhooktoken

# Create non-root user
RUN addgroup -S app && adduser -S -G app app

# Install system dependencies
RUN apk add --no-cache \
    busybox-suid \
    su-exec \
    xz \
    tzdata \
    python3 \
    && ln -sf python3 /usr/bin/python \
    && python3 -m ensurepip \
    && pip3 install --no-cache --upgrade pip setuptools \
    && pip3 install apprise \
    && rm -rf /var/cache/apk/*

# Create necessary directories
RUN mkdir -p /app/log

# Copy scripts
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY script.sh /app/script.sh

# Set permissions
RUN chown -R app:app /app \
    && chmod -R 755 /app \
    && chmod +x /usr/local/bin/entrypoint.sh \
    && chmod +x /app/script.sh

# Switch to non-root user
USER app

# Set working directory
WORKDIR /app

ENTRYPOINT ["entrypoint.sh"]