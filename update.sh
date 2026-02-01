#!/bin/bash

REPO="enom2g/enom2g.github.io"
FILE_PATH="index.html"
COMMIT_MESSAGE="Update index.html to personal developer profile page"
CONTENT_BASE64=$(cat /Users/glenelg/workspace/github/enom2g.github.io/index.html | base64)
CURRENT_SHA="e7cf5e209a76974c1cebaac79e8813d303c8c31c"

echo "Updating file via GitHub API..."

RESPONSE=$(curl -s -X PUT \
  "https://api.github.com/repos/$REPO/contents/$FILE_PATH" \
  -H "Content-Type: application/json" \
  -H "User-Agent: enom2g-profile-updater" \
  -d "{
    \"message\": \"$COMMIT_MESSAGE\",
    \"content\": \"$CONTENT_BASE64\",
    \"sha\": \"$CURRENT_SHA\",
    \"branch\": \"master\"
  }")

echo "Response: $RESPONSE"

if echo "$RESPONSE" | grep -q '"commit"'; then
  echo "✅ Success! File updated successfully."
else
  echo "❌ Failed. Response details:"
  echo "$RESPONSE" | jq .
fi