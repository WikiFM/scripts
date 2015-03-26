#!/bin/bash

# Setup paths for WikiFM

# NOTE don't add trailing /

TESTING_DIR="/srv/www/testing"
TESTING_EXT_DIR="/srv/www/extensions-testing"
PRODUCTION_DIR="/srv/www/production"
PRODUCTION_EXT_DIR="/srv/www/extensions-production"

MYSQL_BACKUP_DIR="/root/mysql-backup"
DATABASES="wikifm"

SHARED_IMAGES="/srv/www/images"

# repos:
#   extensions: submodule containing all the extensions
#               https://gerrit.wikimedia.org/r/p/mediawiki/extensions.git
#   core: contains the MediaWiki code
#               https://gerrit.wikimedia.org/r/p/mediawiki/core.git
MEDIAWIKI_CLONE="/srv/www/core"
MEDIAWIKI_EXT_CLONE="/srv/www/extensions"

# Name of the webserver to give service commands (i.e. service NAME start)
WEBSERVER="nginx"