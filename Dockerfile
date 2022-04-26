ARG ARCH=
FROM ${ARCH}alpine:latest

RUN addgroup -S app && adduser -S -G app app

RUN apk add --no-cache \
    busybox-suid \
    su-exec \
    xz \
    tzdata \
    curl

ENV CRON_TIME "0 */1 * * *"
ENV UID 100
ENV GID 100
ENV DELETE_AFTER 0
ENV GOTIFY_TOKEN 12345
ENV GOTIFY_SERVER server.com


COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY script.sh /app/

RUN mkdir /app/log/ \
    && chown -R app:app /app/ \
    && chmod -R 777 /app/ \
    && chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
