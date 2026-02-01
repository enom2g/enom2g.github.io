#!/bin/bash

REPO="enom2g/enom2g.github.io"
FILE_PATH="index.html"
COMMIT_MESSAGE="Update index.html to personal developer profile page"
CONTENT_BASE64=$(cat /Users/glenelg/workspace/github/enom2g.github.io/index.html | base64)
CURRENT_SHA="e7cf5e209a76974c1cebaac79e8813d303c8c31c"

echo "=== GitHub Token Method ==="
TOKEN=$(gh auth token 2>/dev/null)
if [ $? -eq 0 ] && [ -n "$TOKEN" ]; then
    echo "✅ GitHub CLI token available"
    
    echo "=== Method 1: GitHub API ==="
    RESPONSE=$(curl -s -X PUT \
      "https://api.github.com/repos/$REPO/contents/$FILE_PATH" \
      -H "Authorization: token $TOKEN" \
      -H "Content-Type: application/json" \
      -H "User-Agent: enom2g-profile-updater" \
      -d "{
          \"message\": \"$COMMIT_MESSAGE\",
          \"content\": \"$CONTENT_BASE64\",
          \"sha\": \"$CURRENT_SHA\",
          \"branch\": \"master\"
        }")
    
    if echo "$RESPONSE" | grep -q '"commit"'; then
        echo "✅ Method 1 Success! File updated via GitHub API."
        exit 0
    else
        echo "❌ Method 1 Failed"
        echo "$RESPONSE" | jq .message 2>/dev/null || echo "$RESPONSE"
    fi
    
    echo "=== Method 2: Git with embedded token ==="
    REPO_URL="https://enom2g:${TOKEN}@github.com/enom2g/enom2g.github.io.git"
    cd /Users/glenelg/workspace/github/enom2g.github.io
    git push origin master 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✅ Method 2 Success! Pushed with embedded token."
        exit 0
    else
        echo "❌ Method 2 Failed"
    fi
else
    echo "❌ No GitHub CLI token available"
fi

echo "=== Method 3: Environment variable token ==="
if [ -n "$GITHUB_TOKEN" ]; then
    echo "✅ GITHUB_TOKEN found"
    REPO_URL="https://x-access-token:${GITHUB_TOKEN}@github.com/enom2g/enom2g.github.io.git"
    cd /Users/glenelg/workspace/github/enom2g.github.io
    git push origin master 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✅ Method 3 Success! Pushed with GITHUB_TOKEN."
        exit 0
    else
        echo "❌ Method 3 Failed"
    fi
else
    echo "❌ GITHUB_TOKEN not found"
fi

echo "=== Method 4: GitHub App token ==="
if [ -n "$GH_APP_TOKEN" ]; then
    echo "✅ GitHub App token found"
    REPO_URL="https://x-access-token:${GH_APP_TOKEN}@github.com/enom2g/enom2g.github.io.git"
    cd /Users/glenelg/workspace/github/enom2g.github.io
    git push origin master 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✅ Method 4 Success! Pushed with GitHub App token."
        exit 0
    else
        echo "❌ Method 4 Failed"
    fi
else
    echo "❌ GitHub App token not found"
fi

echo "=== Method 5: SSH key attempt ==="
if [ -f "$HOME/.ssh/id_ed25519" ] || [ -f "$HOME/.ssh/id_rsa" ]; then
    echo "✅ SSH key found"
    git remote set-url origin git@github.com:enom2g/enom2g.github.io.git
    cd /Users/glenelg/workspace/github/enom2g.github.io
    git push origin master 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✅ Method 5 Success! Pushed with SSH."
        exit 0
    else
        echo "❌ Method 5 Failed"
        git remote set-url origin https://github.com/enom2g/enom2g.github.io.git
    fi
else
    echo "❌ No SSH key found"
fi

echo "=== All methods failed. Manual intervention required. ==="
echo "📍 Repository: https://github.com/enom2g/enom2g.github.io"
echo "📍 File: https://github.com/enom2g/enom2g.github.io/blob/master/index.html"
echo ""
echo "📝 To update manually:"
echo "1. Visit the repository URL above"
echo "2. Click on index.html file"
echo "3. Click the edit button (pencil icon)"
echo "4. Replace content with:"
echo "---"
cat /Users/glenelg/workspace/github/enom2g.github.io/index.html
echo "---"
echo "5. Update commit message and save"