# 💾 Vaultwarden Backup

A robust backup solution for Vaultwarden with support for multiple notification services (Gotify, Slack, Discord). This tool automatically backs up your Vaultwarden data and provides notifications about backup status.

## 🚀 Features

- Automatic scheduled backups using cron
- Multiple notification services support:
  - Gotify
  - Slack
  - Discord
- Configurable backup retention
- Secure file handling
- Health checks and monitoring
- Multi-architecture support (ARM, x86, etc.)
- Timezone configuration
- Detailed logging

## 📦 Backed Up Files

The following files and directories are backed up:
- `db.sqlite3` - Main database
- `config.json` - Configuration file
- `rsa_key*` - RSA key files
- `/attachments` - User attachments
- `/sends` - Send items

## 🛠️ Usage

### Quick Start

1. Create a `.env` file with your configuration:
```env
GOTIFY_TOKEN=your_token
GOTIFY_SERVER=your_server
SLACK_WEBHOOK=your_webhook
DISCORD_WEBHOOK_ID=your_id
DISCORD_WEBHOOK_TOKEN=your_token
```

2. Use the provided `docker-compose.yml`:
```yaml
version: '3.8'

services:
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: always
    environment:
      - WEBSOCKET_ENABLED=true
    volumes:
      - /path/to/bitwarden/data:/data
    ports:
      - 8088:80
      - 3012:3012
    networks:
      - vaultwarden_net
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:80/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  backup:
    image: ghcr.io/johannmx/vaultwarden_backup:main
    container_name: vaultwarden_backup
    restart: unless-stopped
    network_mode: none
    volumes:
      - /path/to/bitwarden/data:/data:ro
      - /path/to/backups:/backups
      - /etc/localtime:/etc/localtime:ro
    environment:
      - DELETE_AFTER=30
      - CRON_TIME=00 14 * * *
      - UID=1000
      - GID=1000
      - TZ=America/Argentina/Buenos_Aires
      - GOTIFY_TOKEN=${GOTIFY_TOKEN}
      - GOTIFY_SERVER=${GOTIFY_SERVER}
      - SLACK_WEBHOOK=${SLACK_WEBHOOK}
      - DISCORD_WEBHOOK_ID=${DISCORD_WEBHOOK_ID}
      - DISCORD_WEBHOOK_TOKEN=${DISCORD_WEBHOOK_TOKEN}
    depends_on:
      vaultwarden:
        condition: service_healthy

networks:
  vaultwarden_net:
    driver: bridge
```

### Manual Backup

To run a manual backup:
```bash
docker-compose run --rm backup manual
```

## ⚙️ Configuration

### Environment Variables

#### Required
| Variable | Description | Example |
|----------|-------------|---------|
| `UID` | User ID for the backup process | `1000` |
| `GID` | Group ID for the backup process | `1000` |

#### Optional
| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `CRON_TIME` | Backup schedule (cron format) | `*/5 * * * *` | `0 3 * * *` |
| `DELETE_AFTER` | Days to keep backups | `0` (keep all) | `30` |
| `TZ` | Timezone | System default | `Europe/London` |

#### Notification Services
| Variable | Description | Required |
|----------|-------------|----------|
| `GOTIFY_TOKEN` | Gotify application token | Yes |
| `GOTIFY_SERVER` | Gotify server URL | Yes |
| `SLACK_WEBHOOK` | Slack webhook URL | No |
| `DISCORD_WEBHOOK_ID` | Discord webhook ID | No |
| `DISCORD_WEBHOOK_TOKEN` | Discord webhook token | No |

### Volumes

| Path | Description | Permissions |
|------|-------------|------------|
| `/data` | Vaultwarden data directory | Read-only |
| `/backups` | Backup storage location | Read/Write |
| `/etc/localtime` | Host timezone | Read-only |

## 🔧 Building

### Multi-architecture Build

```bash
# Create buildx builder
docker buildx create --name mybuilder --use

# Build for multiple platforms
docker buildx build -t your-registry/vaultwarden_backup:latest \
  --platform linux/amd64,linux/arm64,linux/ppc64le,linux/s390x,linux/386,linux/arm/v7,linux/arm/v6 \
  --push .
```

## 🔍 Troubleshooting

### Common Issues

1. **Permission Denied**
   - Ensure correct UID/GID in environment variables
   - Check volume permissions

2. **Timezone Issues**
   - Mount `/etc/localtime` or set `TZ` environment variable
   - Verify timezone format

3. **Backup Failures**
   - Check disk space
   - Verify source directory permissions
   - Check logs: `docker-compose logs backup`

### Logs

- Backup logs: `/app/log/log.log`
- Cron logs: `/app/log/cron.log`

## 📚 Resources

- [Cron Format Guide](https://www.ibm.com/docs/en/db2oc?topic=task-unix-cron-format)
- [Cron Expression Editor](https://crontab.guru/)
- [Timezone Database](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)
- [Docker Multi-arch Build Guide](https://andrewlock.net/creating-multi-arch-docker-images-for-arm64-from-windows/)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
