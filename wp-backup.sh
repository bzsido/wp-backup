#!/bin/bash
# written by Balazs in 2018

# predefined variables
LOCATION="/mnt/work/test-backup"
SEP="/"
LOGDIR="/mnt/work/logs/"
LOGFILE=$LOGDIR"wp-backup.log"
CRED="/home/bzsido/scripts/wp-backup/cred"
DATE=$(date +%F-%H-%M)

# Make sure that directories exist
if [ ! -d $LOGDIR ]; then
    mkdir -p $LOGDIR
fi
if [ ! -d $LOCATION ]; then
    if mkdir -p $LOCATION; then
        echo "$DATE $LOCATION didn't exist, so it was created" >> $LOGFILE 
        else
            echo "$DATE couldn't create backup location $LOCATION" >> $LOGFILE
    fi
fi

# collecting all credentials from credential files and starting the backup

if cd $CRED; then
    CREDFILES=$(ls -l | tail -n +2 | cut --delimiter=' ' --fields=9)

    for CREDFILE in $CREDFILES; do
        while read -r SITENAME FTPUSER FTPADDR DOCROOT DBADDR DBUSER DBNAME DBPWD; do
            echo "sitename: $SITENAME"

            # Database dump
            if mysqldump -h $DBADDR -u $DBUSER -p$DBPWD $DBNAME > $LOCATION$SEP$SITENAME-db-$DATE.sql; then
                echo "mysqldump successful for $SITENAME"
                else
                    echo "$DATE mysqldump for $SITENAME $DBNAME was unsuccessful" >> $LOGFILE
            fi

            if [ "localhost" != "$FTPADDR" ]; then

                # Perform secure file backup with ssh, tar and gzip
                if ssh $FTPUSER@$FTPADDR "tar -cf - $DOCROOT | gzip -c" > $LOCATION$SEP$SITENAME-wp-$DATE.tar.gz; then
                    echo "file backup successful for $SITENAME"
                    else
                        echo "$DATE file backup for $SITENAME $FTPADDR was unsuccessful" >> $LOGFILE
                fi

                # Perform a local file backup
                else
                    if tar -cf - $DOCROOT | gzip -c > $LOCATION$SEP$SITENAME-wp-$DATE.tar.gz; then
                        echo "file backup successful for $SITENAME"
                        else
                            echo "$DATE file backup for $SITENAME $FTPADDR was unsuccessful" >> $LOGFILE
                    fi
            fi

        done < $CREDFILE
    done

    else 
        echo "Directory $CRED doesn't exist or is unaccessible" 

fi

# Check if there are only 4-5 backups saved and delete old ones
if cd $LOCATION; then
    find $LOCATION -mtime +62 -exec rm {} \;
    else
        echo "$DATE $LOCATION doesn't exist, deletion wasn't executed" >> $LOGFILE
fi
