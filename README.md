# 💾 Vaultwarden Backup

A robust backup solution for Vaultwarden with support for multiple notification services (Gotify, Slack, Discord). This tool automatically backs up your Vaultwarden data and provides notifications about backup status.

## 🚀 Features

- **Automatic scheduled backups** using cron
- **Multiple notification services** support:
  - Gotify
  - Slack
  - Discord
- **Configurable backup retention** with automatic cleanup
- **Security hardened** containers with minimal privileges
- **Health checks and monitoring** with improved endpoints
- **Multi-architecture support** (ARM, x86, etc.)
- **Timezone configuration** with proper handling
- **Detailed logging** and error handling
- **Named volumes** with configurable paths
- **Optional auto-updates** with Watchtower integration
- **Environment-based configuration** for easy deployment

## 📦 Backed Up Files

The following files and directories are backed up:
- `db.sqlite3` - Main database
- `config.json` - Configuration file
- `rsa_key*` - RSA key files
- `/attachments` - User attachments
- `/sends` - Send items

## 🛠️ Usage

### Quick Start

1. **Copy the environment template**:
```bash
cp .env.example .env
```

2. **Edit the `.env` file** with your configuration:
```env
# Core settings
DOMAIN=http://localhost:8088
ADMIN_TOKEN=your-secure-admin-token-here

# Security
SIGNUPS_ALLOWED=false
INVITATIONS_ALLOWED=true

# Paths (relative to docker-compose.yml)
VAULTWARDEN_DATA_PATH=./data
BACKUP_DATA_PATH=./backups

# Backup settings
BACKUP_DELETE_AFTER=30
BACKUP_CRON_TIME=0 2 * * *

# Notifications
GOTIFY_TOKEN=your_token
GOTIFY_SERVER=your_server
SLACK_WEBHOOK=your_webhook
DISCORD_WEBHOOK_ID=your_id
DISCORD_WEBHOOK_TOKEN=your_token
```

3. **Start the services**:
```bash
# Basic setup (Vaultwarden + Backup)
docker-compose up -d

# With auto-updates enabled
docker-compose --profile watchtower up -d
```

4. **Verify everything is running**:
```bash
docker-compose ps
docker-compose logs -f
```

### Advanced Usage

#### Manual Backup
```bash
docker-compose run --rm backup manual
```

#### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f vaultwarden
docker-compose logs -f backup
```

#### Update Services
```bash
# Pull latest images
docker-compose pull

# Restart with new images
docker-compose up -d
```

#### Backup Management
```bash
# List current backups
ls -la ./backups/

# Restore from backup (example)
docker-compose down
tar -Jxf ./backups/2024-01-15_02-00-00.tar.xz -C ./data/
docker-compose up -d
```

## ⚙️ Configuration

### Environment Variables

#### Core Vaultwarden Settings
| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `DOMAIN` | Public domain for Vaultwarden | `http://localhost:8088` | `https://vault.example.com` |
| `ADMIN_TOKEN` | Admin panel access token | - | `secure-random-token` |
| `SIGNUPS_ALLOWED` | Allow new user registrations | `false` | `true` |
| `INVITATIONS_ALLOWED` | Allow user invitations | `true` | `false` |
| `WEB_VAULT_ENABLED` | Enable web vault interface | `true` | `false` |

#### Security & Performance
| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `SHOW_PASSWORD_HINT` | Show password hints | `false` | `true` |
| `DATABASE_MAX_CONNS` | Max database connections | `10` | `20` |
| `LOGIN_RATELIMIT_SECONDS` | Rate limit window | `60` | `120` |
| `LOGIN_RATELIMIT_MAX_BURST` | Max login attempts | `10` | `5` |
| `ATTACHMENT_LIMIT` | Max attachment size (KB) | `10240` | `20480` |
| `SEND_LIMIT` | Max send size (KB) | `1048576` | `2097152` |

#### Network & Ports
| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `VAULTWARDEN_PORT` | Main HTTP port | `8088` | `8080` |
| `WEBSOCKET_PORT` | WebSocket port | `3012` | `3013` |

#### Data Paths
| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `VAULTWARDEN_DATA_PATH` | Vaultwarden data directory | `./data` | `/opt/vaultwarden/data` |
| `BACKUP_DATA_PATH` | Backup storage directory | `./backups` | `/opt/backups` |

#### Email Configuration (Optional)
| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `SMTP_HOST` | SMTP server hostname | - | `smtp.gmail.com` |
| `SMTP_FROM` | From email address | - | `vault@example.com` |
| `SMTP_PORT` | SMTP server port | `587` | `465` |
| `SMTP_SECURITY` | SMTP security method | `starttls` | `force_tls` |
| `SMTP_USERNAME` | SMTP username | - | `user@example.com` |
| `SMTP_PASSWORD` | SMTP password | - | `app-password` |

#### Backup Settings
| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `BACKUP_DELETE_AFTER` | Days to keep backups | `30` | `7` |
| `BACKUP_CRON_TIME` | Backup schedule (cron) | `0 2 * * *` | `0 3 * * 0` |
| `BACKUP_UID` | Backup process user ID | `1000` | `1001` |
| `BACKUP_GID` | Backup process group ID | `1000` | `1001` |
| `TZ` | Timezone | `America/Argentina/Buenos_Aires` | `Europe/London` |

#### Logging
| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `LOG_LEVEL` | Vaultwarden log level | `warn` | `info` |
| `EXTENDED_LOGGING` | Enable extended logging | `true` | `false` |

#### Notification Services
| Variable | Description | Required | Example |
|----------|-------------|----------|---------|
| `GOTIFY_TOKEN` | Gotify application token | No | `AbCdEf123456` |
| `GOTIFY_SERVER` | Gotify server URL | No | `https://gotify.example.com` |
| `SLACK_WEBHOOK` | Slack webhook URL | No | `https://hooks.slack.com/...` |
| `DISCORD_WEBHOOK_ID` | Discord webhook ID | No | `123456789` |
| `DISCORD_WEBHOOK_TOKEN` | Discord webhook token | No | `webhook-token` |

### Docker Compose Profiles

The docker-compose.yml includes optional services that can be enabled using profiles:

#### Watchtower (Auto-updates)
```bash
# Enable automatic container updates
docker-compose --profile watchtower up -d
```

Watchtower will:
- Check for image updates daily
- Automatically update containers with the `watchtower.enable=true` label
- Send notifications via Gotify when updates occur
- Clean up old images after updates

### Volumes

| Path | Description | Permissions | Configurable Via |
|------|-------------|------------|------------------|
| `/data` | Vaultwarden data directory | Read-only (backup) | `VAULTWARDEN_DATA_PATH` |
| `/backups` | Backup storage location | Read/Write | `BACKUP_DATA_PATH` |
| `/etc/localtime` | Host timezone | Read-only | System mount |

### Security Features

The improved docker-compose includes several security hardening measures:

- **No new privileges**: Containers cannot escalate privileges
- **Capability dropping**: Removes unnecessary Linux capabilities
- **Non-root execution**: Services run as non-root users
- **Read-only mounts**: Data volumes mounted read-only where possible
- **Network isolation**: Backup service runs without network access
- **Resource limits**: Configurable limits for attachments and sends

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
