#!/bin/bash
set -e

# The directory this script is in.
REAL_PATH=`readlink -f "${BASH_SOURCE[0]}"`
SCRIPT_DIR=`dirname "$REAL_PATH"`

# Parse the arguments.
GHPRID=$1
WEBROOT=$2
PROJECT_NAME=$3

# This is the directory of the checked out pull request, from Jenkins.
ORIGINAL_DIR="${WEBROOT}/${PROJECT_NAME}/new_pull_request"
# The directory where the checked out pull request will reside.
ACTUAL_DIR="${WEBROOT}/${PROJECT_NAME}/build-${GHPRID}"
# The directory where the docroot will be symlinked to.
DOCROOT=$WEBROOT/$PROJECT_NAME/$GHPRID
# The command will attempt to merge master with the pull request.
BRANCH="$PROJECT_NAME-pull-request-$GHPRID"

# create folder for build if it doesn't exist
mkdir -p $ACTUAL_DIR
# Remove build git directory if it already exists.
rm -rf $ACTUAL_DIR/.git

# TODO: Change docroot with variable
rsync -a --delete $WORKSPACE/docroot/ $ACTUAL_DIR

rm -rf $WORKSPACE/*
rm -rf $WORKSPACE/.[!.]*

echo "All site files are now at ."
