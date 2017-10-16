#!/usr/bin/env sh

for dbName in ${DB_NAMES}; do
    logger -p user.info "backing up ${dbName}..."

    start=$(date +%s)
    if [ "${DB_ENGINE}" = "mysql" ]; then
        runny $(mysqldump -h ${DB_HOST} -u ${DB_USER} -p"${DB_PASSWORD}" ${DB_OPTIONS} ${dbName} > /tmp/${dbName}.sql)
    elif [ "${DB_ENGINE}" = "postgresql" ]; then
        runny $(PGPASSWORD=${DB_PASSWORD} pg_dump --host=${DB_HOST} --username=${DB_USER} ${DB_OPTIONS} --dbname=${dbName} > /tmp/${dbName}.sql)
    else
        echo Unknown value for DB_ENGINE: ${DB_ENGINE}
        exit 1
    fi
    end=$(date +%s)
    logger -p user.info "${dbName} backed up ($(stat -c %s /tmp/${dbName}.sql) bytes) in $(expr ${end} - ${start}) seconds."

    runny gzip -f /tmp/${dbName}.sql
    runny s3cmd put /tmp/${dbName}.sql.gz ${S3_BUCKET}

    logger -p user.info "${dbName} backup stored in ${S3_BUCKET}."
done
