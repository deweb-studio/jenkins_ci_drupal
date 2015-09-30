#!/bin/bash
set -e

# The directory this script is in.
REAL_PATH=`readlink -f "${BASH_SOURCE[0]}"`
SCRIPT_DIR=`dirname "$REAL_PATH"`

# Grab arguments
WEBROOT=$1
CI_DB_USER=$2

#Grab the pass from STDIN.
read CI_DB_PASS

# TODO: or not to do, decide if we need to cleanup everyday or only
# after disk space will be over some percentage e.g. 80% or 90%.
# Check if disk should be cleaned
#DISK_USED=$(df -h / | grep -v Filesystem | awk '{print $5}')
#DISK_USED=$(echo $DISK_USED | tr -cd '[[:digit:]]')

# Delete all build's folders
for project in $WEBROOT/*/ ; do
    for build in ${project}*/ ; do
        # get build nubmer from path
        BUILD_NUMBER=$(echo $build | tr -cd '[[:digit:]]')
        # get project name with basename
        PROJECT_NAME=`basename $project`
        DB_NAME="jnk_${PROJECT_NAME}_${BUILD_NUMBER}"
        # delete database and build folder
        SQL="DROP DATABASE IF EXISTS ${DB_NAME}"
        mysql -u"$CI_DB_USER" -p"$CI_DB_PASS" -e "$SQL"
        echo "$DB_NAME was destroyed."
        rm -rf $build
        echo "$build folder was deleted"
    done
done

# Delete all project's folders
rm -rf $WEBROOT/*
