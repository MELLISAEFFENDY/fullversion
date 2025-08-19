#!/bin/bash
# AutoFish Pro - One-liner Update Script
# Usage: ./update.sh [commit-message]

GIT_PATH="C:/Git/cmd/git.exe"
REPO_PATH="D:/ssciprtgame/New folder"
BRANCH="main"

cd "$REPO_PATH" || exit 1

if [ -z "$1" ]; then
    COMMIT_MSG="Auto-update: $(date '+%Y-%m-%d %H:%M:%S')"
else
    COMMIT_MSG="$1"
fi

echo "🎣 AutoFish Pro - Quick Update"
echo "💬 Message: $COMMIT_MSG"

# Check if there are changes
if [ -z "$("$GIT_PATH" status --porcelain)" ]; then
    echo "✅ No changes detected"
    exit 0
fi

echo "📊 Changes detected, updating..."
"$GIT_PATH" add . && \
"$GIT_PATH" commit -m "$COMMIT_MSG" && \
"$GIT_PATH" push origin "$BRANCH" && \
echo "✅ Update completed successfully!" || \
echo "❌ Update failed!"
