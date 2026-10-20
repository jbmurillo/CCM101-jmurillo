#!/bin/bash
set -euo pipefail

PROJECT_DIR="/home/pogi/ccmfinal"
BACKUP_DIR="$PROJECT_DIR/backups"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_FILE="$BACKUP_DIR/wordpress_${TIMESTAMP}.sql"

cd "$PROJECT_DIR"
mkdir -p "$BACKUP_DIR"

docker compose exec -T db sh -c \
  'exec mysqldump -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"' > "$BACKUP_FILE"

if [ -s "$BACKUP_FILE" ]; then
    echo "Database backup successful: $BACKUP_FILE"
else
    echo "ERROR: Backup file is empty!"
    rm -f "$BACKUP_FILE"
    exit 1
fi
