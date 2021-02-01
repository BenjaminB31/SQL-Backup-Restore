#!/bin/bash
# https://github.com/BenjaminB31/SQL-Backup-Restore

# Location of backups
BACKUP_DIR="/home/save/sql"

# SQL user
MYSQL_USER="save"
MYSQL_PASSWORD="save"


MYSQL=/usr/bin/mysql

echo "$(ls $BACKUP_DIR)"
read -p "Date of backup: " date

if [ -d "$BACKUP_DIR/$date" ];then
 echo -e "List of available bases :";
else
echo "The folder does not exist !";
exit;
fi

echo "$(cd $BACKUP_DIR/$date; for f in *.sql.gz; do printf "%s\n" "${f%.sql.gz}"; done)";

if [ -d $BACKUP_DIR/$date/mysql/ ]; then
 echo "mysql";
fi
echo "All_Databases";

read -p "Name of the database to restore: " db

if [ -f "$BACKUP_DIR/$date/$db.sql.gz" ];then
 echo -e "\n";
else
    if [ $db ==  "mysql" ];
        then
        $MYSQL --force --user=$MYSQL_USER --password=$MYSQL_PASSWORD < "$BACKUP_DIR/$date/mysql/mysql_all_users_sql.sql";
        echo "Import effectuer";
        exit;
    elif [ $db ==  "All_Databases" ];
        then

        read -p "Do you want to delete the current data to reinsert the backup if databases already exist (y/n): " action
        if [ $action == "y" ]
        then
            cd $BACKUP_DIR/$date;
            for f in *.sql.gz;
            do 
                echo ${f%.sql.gz};
                if [[ `$MYSQL --user=$MYSQL_USER --password=$MYSQL_PASSWORD -e "USE ${f%.sql.gz};" 2> /tmp/error.logextract ; cat /tmp/error.logextract` = "ERROR 1049 (42000) at line 1: Unknown database '${db}'" ]];then
                    rm /tmp/error.logextract;
                    echo "The base does not exist and will be created";
                    gunzip $BACKUP_DIR/$date/$f;
                    $MYSQL --force --user=$MYSQL_USER --password=$MYSQL_PASSWORD < "$BACKUP_DIR/$date/${f%.sql.gz}.sql";
                    gzip $BACKUP_DIR/$date/${f%.sql.gz}.sql;
                    echo "Import perform";
                    exit;
                else
                    rm /tmp/error.logextract;
                    echo "The base already exists drop database";

                    $MYSQL --user=$MYSQL_USER --password=$MYSQL_PASSWORD -e "DROP DATABASE ${f%.sql.gz};"
                    gunzip $BACKUP_DIR/$date/$f;
                    $MYSQL --force --user=$MYSQL_USER --password=$MYSQL_PASSWORD < "$BACKUP_DIR/$date/${f%.sql.gz}.sql";
                    gzip $BACKUP_DIR/$date/${f%.sql.gz}.sql;
                    echo "Import perform";
                fi
            done;
            echo "All databases is imported";
            exit;
        else
            exit;
        fi 

    else
        echo "The base does not exist !";
        exit;
    fi
fi

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
