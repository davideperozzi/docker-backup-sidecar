#!/bin/bash
BACKUP_NAME=${BACKUP_NAME:-backup}
TIMESTAMP=$(date +"%m_%d_%Y-%H_%M")
SQL_DUMP_NAME=databases.sql.gz
BACKUP_NAME=${BACKUP_NAME}-${TIMESTAMP}

# MYSQL dump
echo "Creating mysqldump"
mysqldump \
  -h $DATABASE_HOST \
  -P ${DATABASE_PORT:-3306} \
  -u ${DATABASE_USERNAME:-root} \
  --password="$DATABASE_PASSWORD" \
  --single-transaction \
  --routines \
  --triggers \
  --all-databases | gzip > /var/backup/$SQL_DUMP_NAME

if [ $? -eq 0 ]; then
  # Create archive
  echo "Creating archive $BACKUP_NAME"
  cd /var/archives && tar -zcvf $BACKUP_NAME.tar.gz -C /var/backup .
else
  echo "[ERROR] Backup failed during mysqldump!"
  exit $?
fi

if [ $? -eq 0 ]; then
  # Cleanup sqldump
  rm -rf /var/backup/$SQL_DUMP_NAME

  # Uploads to S3
  echo "Uploading archive to S3"
  aws s3 cp \
    /var/archives/$BACKUP_NAME.tar.gz \
    s3://${AWS_BUCKET_NAME}${AWS_BUCKET_PATH:-\/}
else
  echo "[ERROR] Backup failed during zipping!"
  exit $?
fi

if [ $? -eq 0 ]; then
  # Cleanup archive
  rm /var/archives/$BACKUP_NAME.tar.gz
else
  echo "[ERROR] Backup failed during S3 copy!"
  exit $?
fi