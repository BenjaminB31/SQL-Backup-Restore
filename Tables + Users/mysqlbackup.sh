#!/bin/bash
# https://github.com/BenjaminB31/SQL-Backup-Restore

BACKUP_DIR="/home/save/sql"

MYSQL_USER="save"
MYSQL_PASSWORD="save"

SKIPDATABASES="information_schema|mysql|performance_schema|Database"

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
echo "Utilisateurs et droits"
mkdir "$BACKUP_DIR/$DATE/mysql"
$MYSQL -usave -psave -e "select * from mysql.user " | sed 's/\t/,/g' > "$BACKUP_DIR/$DATE/mysql/user.csv"
$MYSQL -usave -psave -e "select * from mysql.db " | sed 's/\t/,/g' > "$BACKUP_DIR/$DATE/mysql/db.csv"

find $BACKUP_DIR/* -mtime +$RETENTION -delete
