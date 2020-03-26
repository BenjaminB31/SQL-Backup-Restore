#!/bin/bash

#Localisation des backups
BACKUP_DIR="/home/save/sql"

# Utilisateur SQL
MYSQL_USER="save"
MYSQL_PASSWORD="save"



echo "$(ls $BACKUP_DIR)"
read -p "Date de la backup: " date

if [ -d "$BACKUP_DIR/$date" ];then
 echo "Le dossier $date existe";
else
echo "Le dossier n'existe pas !";
exit;
fi

echo "$(cd $BACKUP_DIR/$date; for f in *.sql.gz; do printf "%s\n" "${f%.sql.gz}"; done)"
read -p "Nom de la base à restaurer: " db


if [ -f "$BACKUP_DIR/$date/$db.sql.gz" ];then
 echo "La base $db existe";
else
echo "La base n'existe pas !";
exit;
fi

MYSQL=/usr/bin/mysql

gunzip $BACKUP_DIR/$date/$db.sql.gz
$MYSQL --force --user=$MYSQL_USER --password=$MYSQL_PASSWORD < "$BACKUP_DIR/$date/$db.sql"
gzip $BACKUP_DIR/$date/$db.sql