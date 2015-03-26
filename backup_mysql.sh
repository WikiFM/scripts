#!/bin/bash

MYDIR="$(dirname "$(readlink -f "$0")")"
source "$MYDIR/dirs-config.sh"

rm -rf $MYSQL_BACKUP_DIR-old
mv $MYSQL_BACKUP_DIR $MYSQL_BACKUP_DIR-old
mkdir -p $MYSQL_BACKUP_DIR

mysqldump --databases $DATABASES > $MYSQL_BACKUP_DIR/all_db.sql
