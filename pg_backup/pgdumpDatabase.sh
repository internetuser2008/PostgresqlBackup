#!/bin/sh

date1=$(date +%Y%m%d-%H%M)
mkdir -p $PGBACKUPVOLUME/dump/
BACKUP_DIR=$PGBACKUPVOLUME/dump/
DAYS_TO_KEEP=$DAYS_TO_KEEP
FILE_SUFFIX=.dump
#export PGPASSWORD="$PG_PASS"

#pg_dumpall -h postgresql-postgresql.devtroncd -p 5432 -U postgres -U postgres > pg-backup/postgres-db.tar

#Retrieve list of db's to backup
echo "Getting list of databases to dump"
DATABASE=`psql -Atc "select datname from pg_database where datname not like '%template%' and not datname like '%:%';"`

#Dump db's from list
for db in ${DATABASE}
do
  FILE=`date +"%Y%m%d%H%M"`_${db}${FILE_SUFFIX}
  FILE2=`date +"%Y%m%d"`_${db}${FILE_SUFFIX}
  OUTPUT_FILE=${BACKUP_DIR}${FILE}
  echo "Creating dump file for ${db} db"
  pg_dump -U ${PGUSER} -Fc ${db} > ${OUTPUT_FILE}
  gzip $OUTPUT_FILE
  if [ $? -ne 0 ]; then
    rm $OUTPUT_FILE
    echo "Back up not created, check db connection settings"
    exit 1
  fi
  echo "${OUTPUT_FILE}/.gz Successfully Backed Up"
#  exit 0

done

# prune old backups only if today file exists
echo "Checking old backups to clean up"
EXP_SEARCH=`find $BACKUP_DIR -maxdepth 1 -mtime +$DAYS_TO_KEEP -name "*${FILE_SUFFIX}.gz"`
#if [ -f "${BACKUP_DIR}/`date +"%Y%m%d"`"*postgres.dump.gz ]
if [ -f "${OUTPUT_FILE}.gz" ]
then
   echo "Removing expired backup ${EXP_SEARCH}"
   find $BACKUP_DIR -maxdepth 1 -mtime +$DAYS_TO_KEEP -name "*${FILE_SUFFIX}.gz" -exec rm -rf {} \;
   if [ $? -ne 0 ]; then
     rm $OUTPUT_FILE
     echo "Clean up error, check file settings"
     exit 1
   fi
   echo '${FILE_SUFFIX}.gz Successfully cleaned Up'
   exit 0
fi


#S3 file copy
if [ "${s3backup}" == yes ]
then
   ./tmp/pgs3copy.sh
fi
---------------------
pgs3copy.sh
#!/bin/bash

#!/bin/bash

date1=`date +%Y%m%d-%H%M`
date2=`date +%Y%m%d`
BACKUP_DIR=$PGBACKUPVOLUME/dump/
FILE_SUFFIX=.dump


file_name=`find $BACKUP_DIR -maxdepth 2 -mtime -1 -name "*${FILE_SUFFIX}.gz"`
if [ "${s3backup}" == yes ]
then
   if [ -f "${BACKUP_DIR}/${date2}*postgres.dump.gz" ]
   then
#      filesize=$(stat -c %s $file_name)
#      mfs=10
#      if [[ "$filesize" -gt "$mfs" ]]; then
         echo "Uploading following files to S3 ${file_name}"
         find $BACKUP_DIR -maxdepth 2 -mtime -1 -name "*${FILE_SUFFIX}.gz" |  aws s3 cp - $S3_BUCKET;
         echo "Upload Completed "
#      fi
   else
      echo "No backup file found to copy S3"
   fi
fi
