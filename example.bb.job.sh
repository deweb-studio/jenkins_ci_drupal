#!/bin/bash
set -e

###################################
#     Global Settings section     #
###################################

# THIS SETTINGS SHOULD BE IDENTICAL FOR DIFFERENT PROJECTS ON THIS SERVER. #

# Location of the parent directory of the web root this site will be hosted at.
# Defaults to the job workspace. Note, the Jenkins user must have write
# permissions to this directory.
WEBROOT=/var/www/pull-requests

# The parent URL that the destination site will be visible at.
# The domain name the site will be set up at. Note, the site
# will be in a subdirectory of this domain using the Pull Request ID, so if the
# Pull Request ID is 234, and you pass https://www.example.com/foo, the site
# will be at https://www.example.com/foo/234. You can get around that with URL
# rewriting in your webserver such that pr.234.example.com points to your site.
URL=http://example.com

# path to folder with CI scripts
CI_SCRIPT_PATH=/usr/local/share/jenkins_ci_drupal

# MYSQL usermane with writes to drop databases
CI_DB_USER="root"

###################################
#     Project Settings section    #
###################################

# Project name
# all specific things will be prefixed with it
# must be less than 54 characters (to avoid database naming limitations)
# alowed only letters and "_" symbol
# example: my_project or myproject
PROJECT_NAME="drupal_sample_bitbucket"

#The origin website. For example: 'http://example.com' with no trailing slash.
# If the site is using HTTP Basic Authentication (the browser popup for username
# and password) you can embed those in the url. Be sure to URL encode any
# special characters: http://myusername:pass@example.com
STAGE_SITE_ADRESS="http://stage.example.com"

# For this user password will be set to $PROJECT_NAME
SITEADMIN="webmaster"

# Settings for ssh connetion to stage site (to grab database dump)
REMOTE_SERVER="111.111.111.111"
REMOTE_USER="username"
REMOTE_PORT="22"
PATH_TO_DOCROOT="/home/username/public_html"


###################################
#          Action section         #
###################################

# Get information from Bitbucket pull request builder.
REPO_ACCOUNT=$repositoryOwner
REPO_NAME=$repositoryName
ISSUE_NUMBER=$pullRequestId

#Configure build URL
BUILD_URL="$URL/$PROJECT_NAME/build-$ISSUE_NUMBER"

# If you're using something like the Description Setter plugin, you can use this
# line to set the build description. Just set your regex to \[BUILD\] (.*)
echo "[BUILD] Pull Request #$ISSUE_NUMBER"


# Test whether this pull request already exists.
EXISTING=false
if [[ -d $WEBROOT/$PROJECT_NAME/build-$ISSUE_NUMBER ]]; then
  EXISTING=true
fi

# This does all the work of merging to master, and symlinking the directory to
# the webroot specified above.
$CI_SCRIPT_PATH/prepare_dir.sh $ISSUE_NUMBER $WEBROOT $PROJECT_NAME

# Execute the actual command to clone the site.
$CI_SCRIPT_PATH/clone_site.sh $PROJECT_NAME $REMOTE_PORT $REMOTE_USER $REMOTE_SERVER $PATH_TO_DOCROOT $WEBROOT $ISSUE_NUMBER $STAGE_SITE_ADRESS $SITEADMIN $JENKINS_DB_USER <<< $CI_DB_PASS

# Comment on github or bitbucket with a URL to the new environment below:
BODY="This pull request's testing environment is ready at $BUILD_URL"
#If the environment already existed, just comment that it has been updated.
if $EXISTING; then
  BODY="The testing environment has been updated with the latest code at $BUILD_URL."
fi

# $BB_PASS - password for the bot user. It is recommended to use the Jenkins EnvInject
# Plugin, and use the Inject Passwords option in your job, rather than
# specificying this here.
$CI_SCRIPT_PATH/bb_comment.sh $REPO_ACCOUNT $REPO_NAME $ISSUE_NUMBER "$BODY" <<< $BB_PASS
