Backs up vaultwarden files and directories to `tar.xz` archives automatically. `tar.xz` archives can be opened using data compression programs like [7-Zip](https://www.7-zip.org/) and [WinRAR](https://www.win-rar.com/).

Docker image for all platforms, like ARM (Raspberry Pi) [Docker Hub](https://hub.docker.com/r/johannmx/vaultwarden_backup)

Files and directories that are backed up:
- db.sqlite3
- config.json
- rsa_key.der
- rsa_key.pem
- rsa_key.pub.der
- /attachments
- /sends

## Usage

#### Automatic Backups
Refer to the `docker-compose` section below. By default, backing up is automatic.

#### Manual Backups
Pass `manual` to `docker run` or `docker-compose` as a `command`.

## docker-compose
```
services:
  vaultwarden:
    # Vaultwarden configuration here.
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: always
    environment:
      - WEBSOCKET_ENABLED=true  # Enable WebSocket notifications.
    volumes:
      - /folder-to/bitwarden/data:/data
    ports:
      - 8088:80
      - 3012:3012
  backup:
    image: johannmx/vaultwarden_backup:latest
    container_name: vaultwarden_backup
    network_mode: none
    volumes:
      - /folder-to/bitwarden/data:/data:ro # Read-only
      - /folder-to/backups:/backups
      #- /etc/localtime:/etc/localtime:ro # Container uses date from host.
    environment:
      - DELETE_AFTER=30
      #- CRON_TIME=* */24 * * * # Runs at 12:00 AM.
      - CRON_TIME=00 14 * * * # Runs at 10:15 AM.
      - UID=1000
      - GID=1000
      - TZ=America/Argentina/Buenos_Aires # Specify a timezone to use EG Europe/London.
```

## Volumes _(permissions required)_
`/data` _(read)_- Vaultwarden's `/data` directory. Recommend setting mount as read-only.

`/backups` _(write)_ - Where to store backups to.

## Environment Variables
#### ⭐Required, 👍 Recommended
| Environment Variable | Info                                                                                                                                  |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| UID                ⭐| User ID to run the cron job as.                                                                                                       |
| GID                ⭐| Group ID to run the cron job as.                                                                                                      |
| CRON_TIME          👍| When to run _(default is every 12 hours)_. Info [here][cron-format-wiki] and editor [here][cron-editor]. |
| DELETE_AFTER       👍| _(exclusive to automatic mode)_ Delete backups _X_ days old. Requires `read` and `write` permissions.                                 |

#### Optional
| Environment Variable | Info                                                                                         |
| -------------------- | -------------------------------------------------------------------------------------------- |
| TZ ¹                 | Timezone inside the container. Can mount `/etc/localtime` instead as well _(recommended)_.   |

¹ See <https://en.wikipedia.org/wiki/List_of_tz_database_time_zones> for more information

## build docker --platforms
```
docker buildx create --name mybuilder --use
```

```
docker buildx build -t test/vaultwarden_backup:latest --platform linux/amd64,linux/arm64,linux/ppc64le,linux/s390x,linux/386,linux/arm/v7,linux/arm/v6 --push .
```
## Errors
#### Unexpected timestamp
Mount `/etc/localtime` _(recommend mounting as read-only)_ or set `TZ` environment variable.

## Info
[cron-format-wiki] https://www.ibm.com/docs/en/db2oc?topic=task-unix-cron-format
<br>
[cron-editor]: https://crontab.guru/
<br>
[Docker Build Arch]: https://andrewlock.net/creating-multi-arch-docker-images-for-arm64-from-windows/
