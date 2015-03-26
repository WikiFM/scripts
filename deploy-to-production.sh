#!/bin/bash

MYDIR="$(dirname "$(readlink -f "$0")")"
source "$MYDIR/dirs-config.sh"

service $WEBSERVER stop

OLD_PRODUCTION_EXT_DIR="$PRODUCTION_EXT_DIR-old"
OLD_PRODUCTION_DIR="$PRODUCTION_DIR-old"

OLD_OLD_PRODUCTION_EXT_DIR="$PRODUCTION_EXT_DIR-old-old"
OLD_OLD_PRODUCTION_DIR="$PRODUCTION_DIR-old-old"

# Clean old-old production
mv $OLD_PRODUCTION_DIR $OLD_OLD_PRODUCTION_DIR
mv $OLD_PRODUCTION_EXT_DIR $OLD_OLD_PRODUCTION_EXT_DIR

# Move production to old dirs
mv $PRODUCTION_DIR $OLD_PRODUCTION_DIR
mv $PRODUCTION_EXT_DIR $OLD_PRODUCTION_EXT_DIR

# Move testing to production
mv $TESTING_DIR $PRODUCTION_DIR
mv $TESTING_EXT_DIR $PRODUCTION_EXT_DIR

# Update the extensions symlink
rm $PRODUCTION_DIR/extensions
ln -s $PRODUCTION_EXT_DIR $PRODUCTION_DIR/extensions
# Note: the images symlink needs not to be updated

# The final steps, change config:
sed -i s,"$TESTING_DIR","$PRODUCTION_DIR",g $PRODUCTION_DIR/LocalSettings.php
# And update database
php $PRODUCTION_DIR/maintenance/update.php

service $WEBSERVER start
# Remove read-only mode now.

# Clean old-old production
rm -rf $OLD_OLD_PRODUCTION_DIR
rm -rf $OLD_OLD_PRODUCTION_EXT_DIR

echo
echo
echo ">>> All done! Don't forget to make WikiFM RW again <<<"
echo
echo
