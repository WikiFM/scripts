#!/bin/bash
# Just set-up the various dirs

MYDIR="$(dirname "$(readlink -f "$0")")"
source "$MYDIR/dirs-config.sh"

echo ">>> Preparing the Filesystem structure..."
# Create the filesystem structure
mkdir -p $TESTING_DIR
mkdir -p $TESTING_EXT_DIR
mkdir -p $PRODUCTION_DIR
mkdir -p $PRODUCTION_EXT_DIR

echo ">>> Cloning the MediaWiki repositories (github clone)..."

# Clone the repositories
git clone git@github.com:wikimedia/mediawiki.git $MEDIAWIKI_CLONE
git clone git@github.com:wikimedia/mediawiki-extensions.git $MEDIAWIKI_EXT_CLONE

echo "@hourly php $PRODUCTION_DIR/extensions/FlaggedRevs/maintenance/updateStats.php" | crontab -u www-data

echo
echo
echo ">>> All done! Now run update.sh <<<"
echo
echo
