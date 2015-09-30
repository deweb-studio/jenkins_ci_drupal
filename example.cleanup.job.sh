#!/bin/bash

# Location of the parent directory of the web root this site will be hosted at.
# Defaults to the job workspace. Note, the Jenkins user must have write
# permissions to this directory.
WEBROOT=/var/www/pull-requests

# path to folder with CI scripts
CI_SCRIPT_PATH=/usr/local/share/jenkins_ci_drupal

# MYSQL usermane with writes to drop databases
CI_DB_USER="root"

$CI_SCRIPT_PATH/cleanup.sh $WEBROOT $CI_DB_USER <<< $CI_DB_PASS
