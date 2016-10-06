#!/bin/bash
set -e

WEBROOT=$1
PROJECT=$2
BUILD_NUMBER=$3
DB_NAME="jnk_${PROJECT}_${BUILD_NUMBER}"
BUILD_DIR="$WEBROOT/$PROJECT/build-$BUILD_NUMBER"

CI_DB_USER=$2
#Grab the pass from STDIN.
read CI_DB_PASS

echo "Start delete $BUILD_DIR"
# delete database and build folder
SQL="DROP DATABASE IF EXISTS ${DB_NAME}"
mysql -u"$CI_DB_USER" -p"$CI_DB_PASS" -e "$SQL"
echo "$DB_NAME was destroyed."
echo "Start delete project directory"
chmod 777 -R $BUILD_DIR
rm -rf $BUILD_DIR
echo "$BUILD_DIR folder was deleted"

