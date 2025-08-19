#!/bin/bash
# AutoFish Pro - Quick Update Script (Linux/Mac)
# Simple one-liner update script

echo "🚀 AutoFish Pro - Quick Update"
echo "=============================="

# Check if git is available
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed!"
    exit 1
fi

# Check if in git repository
if [ ! -d ".git" ]; then
    echo "❌ Not a git repository!"
    exit 1
fi

# Check for changes
if [ -z "$(git status --porcelain)" ]; then
    echo "✅ No changes detected. Repository is up to date."
    exit 0
fi

# Show changes
echo "📝 Changed files:"
git status --short

# Generate timestamp
timestamp=$(date '+%Y-%m-%d %H:%M:%S')
commit_message="🔄 Auto-update: Quick update - $timestamp"

echo ""
echo "📝 Commit message: $commit_message"
echo ""

# Confirm update
read -p "Proceed with update? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Update cancelled."
    exit 0
fi

# Perform update
echo "📦 Staging changes..."
git add .

echo "💾 Committing changes..."
git commit -m "$commit_message"

echo "🚀 Pushing to remote..."
git push origin main

if [ $? -eq 0 ]; then
    echo "✅ Repository updated successfully!"
    echo "🌐 Remote: $(git remote get-url origin)"
else
    echo "❌ Push failed! Check your connection and permissions."
    exit 1
fi
