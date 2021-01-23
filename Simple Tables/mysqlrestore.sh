#!/bin/bash
# https://github.com/BenjaminB31/SQL-Backup-Restore

# Location of backups
BACKUP_DIR="/home/save/sql"

# SQL user
MYSQL_USER="save"
MYSQL_PASSWORD="save"


echo "$(ls $BACKUP_DIR)"
read -p "Date of backup: " date

if [ -d "$BACKUP_DIR/$date" ];then
 echo -e "List of available bases :";
else
echo "The folder does not exist !";
exit;
fi

echo "$(cd $BACKUP_DIR/$date; for f in *.sql.gz; do printf "%s\n" "${f%.sql.gz}"; done)"
read -p "Name of the database to restore: " db

if [ -f "$BACKUP_DIR/$date/$db.sql.gz" ];then
 echo -e "\n";
else
echo "The base does not exist !";
exit;
fi

MYSQL=/usr/bin/mysql

if [[ `$MYSQL --user=$MYSQL_USER --password=$MYSQL_PASSWORD -e "USE ${db};" 2> /tmp/error.logextract ; cat /tmp/error.logextract` = "ERROR 1049 (42000) at line 1: Unknown database '${db}'" ]];then
	rm /tmp/error.logextract;
    echo "The base does not exist and will be created";
    gunzip $BACKUP_DIR/$date/$db.sql.gz;
    $MYSQL --force --user=$MYSQL_USER --password=$MYSQL_PASSWORD < "$BACKUP_DIR/$date/$db.sql";
    gzip $BACKUP_DIR/$date/$db.sql;
    echo "Import perform";
    exit;
else
    rm /tmp/error.logextract;
    echo "The base already exists";
     read -p "Do you want to delete the current data to reinsert the backup (y/n): " action
    
    if [ $action == "y" ]
    then
        $MYSQL --user=$MYSQL_USER --password=$MYSQL_PASSWORD -e "DROP DATABASE ${db};"
        gunzip $BACKUP_DIR/$date/$db.sql.gz;
        $MYSQL --force --user=$MYSQL_USER --password=$MYSQL_PASSWORD < "$BACKUP_DIR/$date/$db.sql";
        gzip $BACKUP_DIR/$date/$db.sql;
        echo "Import perform";
        exit;
    else
        exit;
    fi
fi
