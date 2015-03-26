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

# Setup: once and for all run: echo "@hourly php /var/www/production/extensions/FlaggedRevs/maintenance/updateStats.php" | crontab -u www-data

## How to update the installation

# Prepare the directory (remove testing)

rm -rf /var/www/testing
rm -rf /var/www/extensions-testing

# Update the core


cd /var/www/core
git pull
git branch -d wikifm-production
git branch wikifm-production $(git tag -l | sort -V|tail -n1)

# Update extensions

cd /var/www/extensions
git pull
git submodule update --init

# Snapshot a testing image

cd /var/www
git clone --depth 1 --branch wikifm-production file:///var/www/core /var/www/testing
rm -rf /var/www/testing/.git*

cp -r /var/www/extensions /var/www/extensions-testing
rm -rf /var/www/extensions-testing/.git*

# Link in themes, images and extensions, copy config

rm -r /var/www/testing/extensions
rm -r /var/www/testing/images
ln -s /var/www/images /var/www/testing/
ln -s /var/www/extensions-testing /var/www/testing/extensions

# Add (our) Neverland
cd /var/www/testing/skins/
rm -rf *everland*
rm -rf .git
git clone git://github.com/WikiFM/Neverland.git
mv Neverland/.git .
git reset --hard
rm -rf Neverland/

# ...and CategorySuggest
cd /var/www/testing/extensions/
git clone git://github.com/middlebury/CategorySuggest.git
rm -rf /var/www/testing/extensions/CategorySuggest/.git/

# ...and our MathJax configuration
cd /var/www/testing/extensions/Math/modules/MathJax/config/local
git clone git://github.com/WikiFM/MathJaxConfig.git
mv /var/www/testing/extensions/Math/modules/MathJax/config/local/MathJaxConfig/* /var/www/testing/extensions/Math/modules/MathJax/config/local/
/var/www/testing/extensions/Math/modules/MathJax/config/local/config.sh
rm -rf /var/www/testing/extensions/Math/modules/MathJax/config/local/MathJaxConfig

# ...and EmbedVideo
cd /var/www/testing/extensions/
git clone git://github.com/Whiteknight/mediawiki-embedvideo.git /var/www/testing/extensions/EmbedVideo/
rm -rf /var/www/testing/extensions/EmbedVideo/.git/

# Fix permissione for FlaggedRevs
chmod o+r /var/www/testing/extensions/FlaggedRevs/frontend/modules

# Copy LocalSettings.php over
cp /var/www/production/LocalSettings.php /var/www/testing/
echo "\$wgReadOnly = 'Upgrading MediaWiki';" >> /var/www/testing/LocalSettings.php
echo "\$wgSecureLogin  = false; // DELETE ME IN PRODUCTION" >> /var/www/testing/LocalSettings.php
sed -i s,"/var/www/production","/var/www/testing",g /var/www/testing/LocalSettings.php


#### Step 2: Roll testing over and make it production
## All modifications to production not backported to testing will be lost.

################################
################################
################################
# Test that everything works!  #
# Run php update.php as needed #
################################
################################
################################

## CODE NOT SAFE FROM HERE
## PRODUCTION WILL NOW DIE AND WILL BE FULLY REPLACED BY TESTING!
## MAKE SURE APACHE IS STOPPED OR TAKE A SIMILAR PRECAUTION

# MAKE A BACKUP

service apache2 stop

rm -rf /var/www/extensions-production
mv /var/www/extensions-testing /var/www/extensions-production

# Update the extensions link
rm /var/www/testing/extensions
ln -s /var/www/extensions-production /var/www/testing/extensions

# The final step:
mv production production-old
mv /var/www/testing /var/www/production
sed -i s,"/var/www/testing/","/var/www/production/",g /var/www/production/LocalSettings.php

service apache2 start
# Remove read-only mode now.

# Clean old production
rm -rf /var/www/production-old