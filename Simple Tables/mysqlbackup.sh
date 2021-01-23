#!/bin/bash
# https://github.com/BenjaminB31/SQL-Backup-Restore

#Localisation des backups
BACKUP_DIR="/home/save/sql"

# Utilisateur SQL
MYSQL_USER="save"
MYSQL_PASSWORD="save"

# Bases de données MySQL à ne pas enregistrer
SKIPDATABASES="information_schema|mysql|performance_schema|Database"

# Durée en jour des rétention des backups
RETENTION=30


MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump

DATE=$(date +"%Y-%m-%d-%H-%M")

mkdir -p $BACKUP_DIR/$DATE

databases=`$MYSQL -u$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" | grep -Ev "($SKIPDATABASES)"`

for db in $databases; do
echo $db
$MYSQLDUMP --force --opt --user=$MYSQL_USER -p$MYSQL_PASSWORD --skip-lock-tables --events --databases $db | gzip > "$BACKUP_DIR/$DATE/$db.sql.gz"
done

find $BACKUP_DIR/* -mtime +$RETENTION -delete