#!/bin/bash
set -e

# The directory this script is in.
REAL_PATH=`readlink -f "${BASH_SOURCE[0]}"`
SCRIPT_DIR=`dirname "$REAL_PATH"`

DATE=`date "+%Y-%m-%d"`

PROJECT_NAME=$1
REMOTE_PORT=$2
REMOTE_USER=$3
REMOTE_SERVER=$4
PATH_TO_DOCROOT=$5
WEBROOT=$6
ISSUE_NUMBER=$7
STAGE_SITE_ADRESS=$8
SITEADMIN=$9
JENKINS_DB_USER=${10}

# Grab the pass from STDIN.
read CI_DB_PASS

DB_NAME="jnk_${PROJECT_NAME}_${ISSUE_NUMBER}"

SQL="CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8 COLLATE utf8_general_ci;"

mysql -u"$JENKINS_DB_USER" -p"$CI_DB_PASS" -e "$SQL"

#echo $DB_NUMBER > "$SCRIPT_DIR/base_dumps/last_used_db"

# create folder for base dump of this project
if [ ! -d "$SCRIPT_DIR/base_dumps/$PROJECT_NAME" ]; then
    echo "Created folder for project dumps"
    mkdir "$SCRIPT_DIR/base_dumps/$PROJECT_NAME"
fi

# check if todays base dump exists
if [ ! -e "$SCRIPT_DIR/base_dumps/$PROJECT_NAME/${DATE}_${PROJECT_NAME}.sql.gz" ]; then
    echo "rm old base dumps"
    rm -f $SCRIPT_DIR/base_dumps/$PROJECT_NAME/*
    echo "create base dump on stage site"
    ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_SERVER "cd $PATH_TO_DOCROOT; drush sql-dump --gzip --result-file=./${DATE}_${PROJECT_NAME}.sql"
    echo "copy base dump"
    scp -P $REMOTE_PORT $REMOTE_USER@$REMOTE_SERVER:$PATH_TO_DOCROOT/${DATE}_${PROJECT_NAME}.sql.gz $SCRIPT_DIR/base_dumps/$PROJECT_NAME/
    echo "delete dump on remote"
    ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_SERVER "cd $PATH_TO_DOCROOT; rm ${DATE}_${PROJECT_NAME}.sql.gz"
fi

# restore site dump on build
cd $WEBROOT/$PROJECT_NAME/build-${ISSUE_NUMBER}
cp ./sites/default/default.settings.php ./sites/default/settings.php
# create private files directory.
mkdir -p ./sites/default/files/private

BASE_CODNFIG="\$databases = array (
  'default' =>
    array (
      'default' =>
        array (
          'database' => '${DB_NAME}',
          'username' => '${JENKINS_DB_USER}',
          'password' => '${CI_DB_PASS}',
          'host' => 'localhost',
          'port' => '',
          'driver' => 'mysql',
          'prefix' => '',
        ),
    ),
);"

echo -e "$BASE_CODNFIG" >> ./sites/default/settings.php
drush sql-drop -y
gunzip < $SCRIPT_DIR/base_dumps/$PROJECT_NAME/${DATE}_${PROJECT_NAME}.sql.gz | drush sql-cli
# Rebuilds registry in case if any module was deleted or moved.
drush rr
drush dl stage_file_proxy
drush en -y stage_file_proxy
drush variable-set stage_file_proxy_origin "$STAGE_SITE_ADRESS"
drush upwd $SITEADMIN --password="$PROJECT_NAME"
drush updb -y
drush cc all
