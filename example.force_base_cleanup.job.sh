#!/bin/bash

###################################
#     Global Settings section     #
###################################

# THIS SETTINGS SHOULD BE IDENTICAL FOR DIFFERENT PROJECTS ON THIS SERVER. #

# path to folder with CI scripts
CI_SCRIPT_PATH=/usr/local/share/jenkins_ci_drupal

###################################
#          Action section         #
###################################

rm -rf $CI_SCRIPT_PATH/base_dumps/$PROJECT_NAME
echo "Databse dump of $PROJECT_NAME project was deleted."