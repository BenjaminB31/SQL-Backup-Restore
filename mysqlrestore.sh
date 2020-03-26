#!/bin/bash
# https://github.com/BenjaminB31/SQL-Backup-Restore

#Localisation des backups
BACKUP_DIR="/home/save/sql"

# Utilisateur SQL
MYSQL_USER="save"
MYSQL_PASSWORD="save"


echo "$(ls $BACKUP_DIR)"
read -p "Date de la backup: " date

if [ -d "$BACKUP_DIR/$date" ];then
 echo -e "Liste des bases disponnible :";
else
echo "Le dossier n'existe pas !";
exit;
fi

echo "$(cd $BACKUP_DIR/$date; for f in *.sql.gz; do printf "%s\n" "${f%.sql.gz}"; done)"
read -p "Nom de la base à restaurer: " db

if [ -f "$BACKUP_DIR/$date/$db.sql.gz" ];then
 echo -e "\n";
else
echo "La base n'existe pas !";
exit;
fi

MYSQL=/usr/bin/mysql

if [[ `$MYSQL --user=$MYSQL_USER --password=$MYSQL_PASSWORD -e "USE ${db};" 2> /tmp/error.logextract ; cat /tmp/error.logextract` = "ERROR 1049 (42000) at line 1: Unknown database '${db}'" ]];then
	rm /tmp/error.logextract;
    echo "La base n'existe pas et va être crée";
    gunzip $BACKUP_DIR/$date/$db.sql.gz;
    $MYSQL --force --user=$MYSQL_USER --password=$MYSQL_PASSWORD < "$BACKUP_DIR/$date/$db.sql";
    gzip $BACKUP_DIR/$date/$db.sql;
    echo "Import effectuer";
    exit;
else
    rm /tmp/error.logextract;
    echo "La base existe déja";
    read -p "Voulez vous supprimer les données actuelles pour réinsérer la backup (y/n): " action
    
    if [ $action == "y" ]
    then
        $MYSQL --user=$MYSQL_USER --password=$MYSQL_PASSWORD -e "DROP DATABASE ${db};"
        gunzip $BACKUP_DIR/$date/$db.sql.gz;
        $MYSQL --force --user=$MYSQL_USER --password=$MYSQL_PASSWORD < "$BACKUP_DIR/$date/$db.sql";
        gzip $BACKUP_DIR/$date/$db.sql;
        echo "Import effectuer";
        exit;
    else
        exit;
    fi
fi
