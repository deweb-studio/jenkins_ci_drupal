#!/bin/bash
set -e

# Ensure curl exists.
command -v curl >/dev/null 2>&1 || {
  echo >&2 "You must have cURL installed for this command to work properly.";
  exit 1;
}

BB_USERNAME=$1
BB_REPO_NAME=$2
ISSUE_NUMBER=$3
BODY=$4

# Grab the pass from STDIN.
read BB_PASS

# Post a comment wia Bitbucket REST API
curl --user $BB_USERNAME:$BB_PASS https://bitbucket.org/api/1.0/repositories/$BB_USERNAME/$BB_REPO_NAME/pullrequests/$ISSUE_NUMBER/comments --data content="$BODY"
echo "Posted comment to Bitbucket."

# Check disk space.
df -H | grep -vE '^Filesystem' | awk '{ print $5 " " $1 }' | while read output;
do
  echo $output
  usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )
  partition=$(echo $output | awk '{ print $2 }' )
  if [ $usep -ge 85 ]; then
    WARNING="__WARNING:__ Running out of space \"$partition ($usep%)\" on $(hostname) as on $(date). Please make a request to the manager to start PR_CLEANUP �job in jenkins!"
    curl --user $BB_USERNAME:$BB_PASS https://bitbucket.org/api/1.0/repositories/$BB_USERNAME/$BB_REPO_NAME/pullrequests/$ISSUE_NUMBER/comments --data content="$WARNING"
  fi
done
