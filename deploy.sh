#!/bin/bash

# ============================================
# Deploy script for Breathing App (Flutter Web)
# ============================================
# Энэ скрипт нь Flutter web аппыг GitHub Pages руу deploy хийнэ
# 
# Ашиглах заавар:
# 1. Эхлээд GitHub дээр repository үүсгээд push хийх
# 2. Дараах командыг ажиллуулах:
#    chmod +x deploy.sh
#    ./deploy.sh
#
# Эсвэл VS Code дээр Ctrl+Shift+D дарж автоматаар ажиллуулах
# ============================================

set -e

echo "🚀 Breathing App Deploy Script"
echo "================================"

# GitHub repository URL (өөрийн repository-гаар солино)
REPO_URL="https://github.com/khangai83/clock.git"
BRANCH="gh-pages"

# 1. Flutter web build
echo ""
echo "📦 Building Flutter web..."
flutter build web --release --base-href="/clock/"

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build successful!"

# 2. Deploy to GitHub Pages
echo ""
echo "🚀 Deploying to GitHub Pages ($BRANCH branch)..."

cd build/web

# Git repository үүсгэх
git init
git add -A
git commit -m "deploy: $(date +'%Y-%m-%d %H:%M:%S')"

# Branch-ийг gh-pages болгох
git branch -M $BRANCH

# Remote нэмээд push хийх
git remote add origin $REPO_URL
git push -f origin $BRANCH

cd ../..

echo ""
echo "✅ Deploy complete!"
echo "📱 Your app is now live at:"
echo "   https://YOUR_USERNAME.github.io/YOUR_REPO/"
echo ""
echo "⚠️  Дараах зүйлсийг шалгах:"
echo "   1. GitHub Repository Settings → Pages → Source: gh-pages branch"
echo "   2. Эсвэл автоматаар ажиллах ёстой"
