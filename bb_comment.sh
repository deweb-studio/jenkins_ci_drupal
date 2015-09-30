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