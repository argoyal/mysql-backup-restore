#!/usr/bin/env sh

for dbName in ${DB_NAMES}; do
    logger -p user.info "restoring ${dbName}..."

    runny s3cmd get -f ${S3_BUCKET}/${dbName}.sql.gz /tmp/${dbName}.sql.gz
    runny gunzip -f /tmp/${dbName}.sql.gz

    start=$(date +%s)
    if [ "${DB_ENGINE}" -eq "mysql" ]; then
        runny $(mysql -h ${DB_HOST} -u ${DB_USER} -p"${DB_PASSWORD}" ${DB_OPTIONS} ${dbName} < /tmp/${dbName}.sql)
    elif [ "${DB_ENGINE}" -eq "postgresql" ]; then
        runny $(PGPASSWORD=${DB_PASSWORD} pg_restore --host=${DB_HOST} --username=${DB_USER} ${DB_OPTIONS} --dbname=${dbName} < /tmp/${dbName}.sql)
    else
        echo Unknown value for DB_ENGINE: ${DB_ENGINE}
        exit 1
    fi
    end=$(date +%s)

    logger -p user.info "${dbName} restored in $(expr ${end} - ${start}) seconds."
done
