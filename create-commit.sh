#!/bin/bash
set -e

# Commit messsage
message="${1}"

# Generate payload
payload=$( mktemp )
jq --null-input \
  --arg tree_sha "$TREE_SHA" \
  --arg parent_sha "$HEAD_SHA" \
  --arg message "$message" \
  '{"message": $message, "tree": $tree_sha, "parents": [$parent_sha]}' > $payload

# Create commit
response=$( curl --request POST \
  --url https://api.github.com/repos/$GITHUB_REPOSITORY/git/commits \
  --header "authorization: Bearer $GH_TOKEN" \
  --header 'content-type: application/json' \
  --data @$payload )

# Export environment variables with object ids
echo COMMIT_SHA=$( jq -r '.sha' <<< "${response}" ) >> $GITHUB_ENV

# Set 'commit-sha' output
echo "::set-output name=commit-sha::$COMMIT_SHA"
