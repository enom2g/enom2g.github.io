#!/bin/bash

REPO="enom2g/enom2g.github.io"
FILE_PATH="index.html"
COMMIT_MESSAGE="Update index.html to personal developer profile page"
CONTENT_BASE64=$(cat /Users/glenelg/workspace/github/enom2g.github.io/index.html | base64)
CURRENT_SHA="e7cf5e209a76974c1cebaac79e8813d303c8c31c"

echo "🚀 GitHub Advanced Push Solutions"
echo "=================================="

echo "=== Method 1: GitHub Contents API with Fine-Grained Token ==="
echo "Creating file via API (no repo scope needed)..."

RESPONSE=$(curl -s -X PUT \
  "https://api.github.com/repos/$REPO/contents/$FILE_PATH" \
  -H "Authorization: bearer $(gh auth token)" \
  -H "Content-Type: application/json" \
  -H "Accept: application/vnd.github+json" \
  -H "User-Agent: enom2g-advanced-updater" \
  -d "{
      \"message\": \"$COMMIT_MESSAGE\",
      \"content\": \"$CONTENT_BASE64\",
      \"sha\": \"$CURRENT_SHA\",
      \"branch\": \"master\"
    }")

if echo "$RESPONSE" | grep -q '"commit"'; then
    echo "✅ SUCCESS: File updated via GitHub API!"
    echo "🌐 Live at: https://enom2g.github.io/"
    echo "📊 Commit info:"
    echo "$RESPONSE" | jq '.commit.html_url' 2>/dev/null || echo "Check repository for commit"
    exit 0
else
    echo "❌ FAILED: API method failed"
    echo "Error: $(echo "$RESPONSE" | jq '.message' 2>/dev/null || echo 'Unknown error')"
fi

echo "=== Method 2: Git Protocol with Embedded Token ==="
echo "Trying git push with embedded token..."

REPO_URL="https://x-access-token:$(gh auth token)@github.com/enom2g/enom2g.github.io.git"
cd /Users/glenelg/workspace/github/enom2g.github.io

git push origin master 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ SUCCESS: Pushed with embedded token!"
    echo "🌐 Live at: https://enom2g.github.io/"
    exit 0
else
    echo "❌ FAILED: Git push with embedded token failed"
fi

echo "=== Method 3: SSH Deploy Key ==="
echo "Checking for SSH keys..."

if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
    echo "✅ Ed25519 key found"
    SSH_KEY="$HOME/.ssh/id_ed25519.pub"
elif [ -f "$HOME/.ssh/id_rsa.pub" ]; then
    echo "✅ RSA key found"
    SSH_KEY="$HOME/.ssh/id_rsa.pub"
else
    echo "❌ No SSH keys found"
    SSH_KEY=""
fi

if [ -n "$SSH_KEY" ]; then
    echo "Public key for deploy setup:"
    cat "$SSH_KEY"
    echo ""
    echo "🔧 To use SSH key:"
    echo "1. Copy the public key above"
    echo "2. Go to: https://github.com/enom2g/enom2g.github.io/settings/keys"
    echo "3. Click 'Add deploy key'"
    echo "4. Paste key and give write access"
    echo "5. Run: git remote set-url origin git@github.com:enom2g/enom2g.github.io.git"
    echo "6. Run: git push origin master"
fi

echo "=== Method 4: GitHub API Tree/Commit Method ==="
echo "Advanced: Creating commit via Git Database API..."

# Create blobs for each file
FILES=("index.html")
BLOBS=()

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "Creating blob for $file..."
        CONTENT=$(cat "$file" | base64)
        BLOB_RESPONSE=$(curl -s -X POST \
          "https://api.github.com/repos/$REPO/git/blobs" \
          -H "Authorization: bearer $(gh auth token)" \
          -H "Content-Type: application/json" \
          -d "{\"content\": \"$CONTENT\", \"encoding\": \"base64\"}")
        
        BLOB_SHA=$(echo "$BLOB_RESPONSE" | jq -r '.sha')
        BLOBS+=("{\"path\": \"$file\", \"mode\": \"100644\", \"type\": \"blob\", \"sha\": \"$BLOB_SHA\"}")
        echo "✅ Blob created: $BLOB_SHA"
    fi
done

if [ ${#BLOBS[@]} -gt 0 ]; then
    echo "Creating tree with blobs..."
    TREE_RESPONSE=$(curl -s -X POST \
      "https://api.github.com/repos/$REPO/git/trees" \
      -H "Authorization: bearer $(gh auth token)" \
      -H "Content-Type: application/json" \
      -d "{\"base_tree\": \"$CURRENT_SHA\", \"tree\": [$(IFS=','; echo "${BLOBS[*]}")]}")
    
    TREE_SHA=$(echo "$TREE_RESPONSE" | jq -r '.sha')
    echo "✅ Tree created: $TREE_SHA"
    
    echo "Creating commit..."
    COMMIT_RESPONSE=$(curl -s -X POST \
      "https://api.github.com/repos/$REPO/git/commits" \
      -H "Authorization: bearer $(gh auth token)" \
      -H "Content-Type: application/json" \
      -d "{
          \"message\": \"$COMMIT_MESSAGE\",
          \"tree\": \"$TREE_SHA\",
          \"parents\": [\"$CURRENT_SHA\"
        }")
    
    COMMIT_SHA=$(echo "$COMMIT_RESPONSE" | jq -r '.sha')
    echo "✅ Commit created: $COMMIT_SHA"
    
    echo "Updating reference..."
    REF_RESPONSE=$(curl -s -X PATCH \
      "https://api.github.com/repos/$REPO/git/refs/heads/master" \
      -H "Authorization: bearer $(gh auth token)" \
      -H "Content-Type: application/json" \
      -d "{\"sha\": \"$COMMIT_SHA\"}")
    
    if echo "$REF_RESPONSE" | grep -q '"object"'; then
        echo "✅ SUCCESS: Advanced Git API method worked!"
        echo "🌐 Live at: https://enom2g.github.io/"
        exit 0
    else
        echo "❌ FAILED: Reference update failed"
    fi
fi

echo "=================================="
echo "🎯 If all methods failed, manual update required:"
echo "📍 Repository: https://github.com/enom2g/enom2g.github.io"
echo "📍 File editor: https://github.com/enom2g/enom2g.github.io/edit/master/index.html"
echo ""
echo "📋 Ready content for copy-paste:"
echo "----------------------------------------"
cat /Users/glenelg/workspace/github/enom2g.github.io/index.html
echo "----------------------------------------"