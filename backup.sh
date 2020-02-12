#!/bin/sh
S3_OUT_FOLDER=${S3_FOLDER:-\/var\/out\/s3\/}
START_SCRIPTS=/opt/scripts/start
END_SCRIPTS=/opt/scripts/end

function execute_script {
  if [[ -x "$1" ]]; then
    source $1
  else
    echo "[BACKUP][WARNING] Script '$1' is not exectuable: ignoring"
  fi
}

# Execute start scripts
if [ "$(ls -A $START_SCRIPTS)" ]; then
  for script in "$START_SCRIPTS"/*; do
    echo "[BACKUP][Notice] Executing script '$script'"
    execute_script $script
  done
fi

# Upload to S3
if [ "$(ls -A $S3_OUT_FOLDER)" ]; then
  echo "[BACKUP][Notice] Start uploading to S3"
  aws s3 cp --recursive ${S3_OUT_FOLDER} s3://${AWS_BUCKET_NAME}${AWS_BUCKET_PATH:-\/}

  # Cleanup
  if [ $? -eq 0 ]; then
    rm -rf ${S3_OUT_FOLDER}{*,.*}
  else
    echo "[BACKUP][ERROR] Backup failed during s3 copy. Will exit with code '$?'"
    exit $?
  fi
else
  echo "[BACKUP][Notice] Folder '${S3_OUT_FOLDER}' is empty: skipped s3 upload"
fi

# Execute end scripts
if [ "$(ls -A $END_SCRIPTS)" ]; then
  for script in "$END_SCRIPTS"/*; do
    echo "[BACKUP][Notice] Executing script '$script'"
    execute_script $script
  done
fi
