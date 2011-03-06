#!/bin/bash
# name of database to dump and username and password with access to that database
MYSQL_DB="--all-databases"
MYSQL_USER=""
MYSQL_PASS=""

#create output file name with database name, date and time
OUTPUT_PATH="/backup/mysql"
NOW=$(date +"%Y-%m-%d")
FILE=${MYSQL_DB}.$NOW-$(date +"%H-%M-%S").sql.gz

CLOUDFILES_CONTAINER=""
export CLOUDFILES_USERNAME=
export CLOUDFILES_APIKEY=
export PASSPHRASE=

# dump the database and gzip it
mysqldump ${MYSQL_DB} -u ${MYSQL_USER} -p${MYSQL_PASS} | gzip -9 > ${OUTPUT_PATH}/${FILE}
duplicity ${OUTPUT_PATH} cf+http://${CLOUDFILES_CONTAINER}
