#!/bin/bash

set -e

### CONFIG
DATE=$(date +%F_%H-%M)
BACKUP_DIR="/backup/bookstack"

DB_NAME="bookstack"
DB_USER="bookstack"
DB_PASS="PASSWORD"
DB_HOST="localhost"

BOOKSTACK_PATH="/var/www/bookstack"

RETENTION_DAYS=5

### CREATE BACKUP DIR
mkdir -p "$BACKUP_DIR"

echo "[$(date)] Starting backup..."

### 1. BACKUP DATABASE
echo "[$(date)] Dumping database..."
mysqldump -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" \
  > "$BACKUP_DIR/db_$DATE.sql"

### 2. BACKUP FILES
echo "[$(date)] Archiving files..."
tar -czf "$BACKUP_DIR/files_$DATE.tar.gz" \
  "$BOOKSTACK_PATH/public/uploads" \
  "$BOOKSTACK_PATH/.env"

### 3. OPTIONAL: MERGE INTO SINGLE ARCHIVE
echo "[$(date)] Creating full archive..."
tar -czf "$BACKUP_DIR/bookstack_backup_$DATE.tar.gz" \
  -C "$BACKUP_DIR" \
  "db_$DATE.sql" \
  "files_$DATE.tar.gz"

### 4. CLEAN TEMP FILES
rm -f "$BACKUP_DIR/db_$DATE.sql" "$BACKUP_DIR/files_$DATE.tar.gz"

### 5. PURGE OLD BACKUPS
echo "[$(date)] Cleaning backups older than $RETENTION_DAYS days..."
find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete

echo "[$(date)] Backup completed successfully."