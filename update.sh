#!/bin/sh

## Updating the MediaWiki installation of WikiFM
#
# setup: (in /var/www)
#
#   production:
#       where the production installation stays
#   testing:
#       temporary directory where the new code is put for testing
#   extensions-production:
#       snapshot of the extensions used for production codebase
#   extensions-testing:
#       snapshot of the extensions used for testing
#   images:
#       www-data writable, storage for wiki data (pdfs, ...)
#
# repos:
#   extensions: submodule containing all the extensions
#               https://gerrit.wikimedia.org/r/p/mediawiki/extensions.git
#   core: contains the MediaWiki code
#               https://gerrit.wikimedia.org/r/p/mediawiki/core.git
#

MYDIR="$(dirname "$(readlink -f "$0")")"
source "$MYDIR/dirs-config.sh"

echo ">>> Backing up MySQL..."

$MYDIR/backup_mysql.sh

# Remove the old testing
rm -rf $TESTING_DIR
rm -rf $TESTING_EXT_DIR


echo ">>> Updating repos..."

# Update the core
cd $MEDIAWIKI_CLONE
git pull
git branch -d wikifm-production
git branch wikifm-production $(git tag -l | sort -V|tail -n1)

# Update extensions
cd $MEDIAWIKI_EXT_CLONE
git pull
git submodule update --init


echo ">>> Creating new testing site..."

# Snapshot a testing image
git clone --depth 1 --branch wikifm-production file://$MEDIAWIKI_CLONE $TESTING_DIR
rm -rf $TESTING_DIR/.git*

cp -r $MEDIAWIKI_EXT_CLONE $TESTING_EXT_DIR
rm -rf $TESTING_EXT_DIR/.git*

# Link in themes, images and extensions, copy config

rm -r $TESTING_DIR/extensions
rm -r $TESTING_DIR/images
ln -s $SHARED_IMAGES $TESTING_DIR/
ln -s $TESTING_EXT_DIR $TESTING_DIR/extensions

echo ">>> Pulling in external configuration..."

# Add (our) Neverland
cd $TESTING_DIR/skins/
rm -rf *everland*
rm -rf .git
git clone git://github.com/WikiFM/Neverland.git
mv Neverland/.git .
git reset --hard
rm -rf Neverland/
rm -rf .git

# ...and CategorySuggest
cd $TESTING_DIR/extensions/
git clone git://github.com/middlebury/CategorySuggest.git
rm -rf $TESTING_DIR/extensions/CategorySuggest/.git/

# ...and our MathJax configuration
cd $TESTING_DIR/extensions/Math/modules/MathJax/config/local
git clone git://github.com/WikiFM/MathJaxConfig.git
mv $TESTING_DIR/extensions/Math/modules/MathJax/config/local/MathJaxConfig/* $TESTING_DIR/extensions/Math/modules/MathJax/config/local/
$TESTING_DIR/extensions/Math/modules/MathJax/config/local/config.sh
rm -rf $TESTING_DIR/extensions/Math/modules/MathJax/config/local/MathJaxConfig

# ...and EmbedVideo
cd $TESTING_DIR/extensions/
git clone git://github.com/Whiteknight/mediawiki-embedvideo.git $TESTING_DIR/extensions/EmbedVideo/
rm -rf $TESTING_DIR/extensions/EmbedVideo/.git/

# Fix permissione for FlaggedRevs
chmod o+r $TESTING_DIR/extensions/FlaggedRevs/frontend/modules


echo ">>> Fixing settings..."

# Copy LocalSettings.php over
cp $PRODUCTION_DIR/LocalSettings.php $TESTING_DIR/
echo "// **** DELETE THE FOLLOWING LINES IN PRODUCTION: ***" >> $TESTING_DIR/LocalSettings.php
echo "\$wgReadOnly = 'Upgrading MediaWiki';" >> $TESTING_DIR/LocalSettings.php
echo "\$wgAllowSchemaUpdates" >> $TESTING_DIR/LocalSettings.php
echo "\$wgSecureLogin  = false; // DELETE ME IN PRODUCTION" >> $TESTING_DIR/LocalSettings.php
sed -i s,"$PRODUCTION_DIR","$TESTING_DIR",g $TESTING_DIR/LocalSettings.php


echo ">>> All done!!!"

