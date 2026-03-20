#!/bin/bash

set -e

### CONFIG
DATE=$(date +%F_%H-%M)
BACKUP_DIR="/backup/bookstack"

DB_CONTAINER="bookstack_db"       # nom du conteneur MySQL/MariaDB
APP_CONTAINER="bookstack_app"     # conteneur BookStack

DB_NAME="bookstack"
DB_USER="bookstack"
DB_PASS="PASSWORD"

BOOKSTACK_PATH="/var/www/bookstack"

RETENTION_DAYS=5

mkdir -p "$BACKUP_DIR"

echo "[$(date)] Starting Docker BookStack backup..."

### 1. BACKUP DATABASE
echo "[$(date)] Dumping database from container..."
docker exec "$DB_CONTAINER" \
  mysqldump -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" \
  > "$BACKUP_DIR/db_$DATE.sql"

### 2. BACKUP FILES (depuis le conteneur)
echo "[$(date)] Archiving BookStack files..."
docker exec "$APP_CONTAINER" \
  tar -czf /tmp/files_$DATE.tar.gz \
  "$BOOKSTACK_PATH/public/uploads" \
  "$BOOKSTACK_PATH/.env"

docker cp "$APP_CONTAINER:/tmp/files_$DATE.tar.gz" \
  "$BACKUP_DIR/files_$DATE.tar.gz"

docker exec "$APP_CONTAINER" rm -f "/tmp/files_$DATE.tar.gz"

### 3. ARCHIVE COMPLETE
echo "[$(date)] Creating final archive..."
tar -czf "$BACKUP_DIR/bookstack_backup_$DATE.tar.gz" \
  -C "$BACKUP_DIR" \
  "db_$DATE.sql" \
  "files_$DATE.tar.gz"

### 4. CLEAN TEMP FILES
rm -f "$BACKUP_DIR/db_$DATE.sql" "$BACKUP_DIR/files_$DATE.tar.gz"

### 5. PURGE (5 jours)
echo "[$(date)] Cleaning old backups..."
find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete

echo "[$(date)] Backup completed successfully."