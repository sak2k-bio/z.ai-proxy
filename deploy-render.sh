#!/bin/bash

echo "🚀 Z.ai Proxy - Render Deployment Setup"
echo "========================================"
echo ""

# Check if git is initialized
if [ ! -d .git ]; then
    echo "❌ Git repository not initialized"
    echo "Run: git init"
    exit 1
fi

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ .env file not found"
    echo "Please create .env with JWT_TOKEN and COOKIE"
    exit 1
fi

# Load credentials
source .env

if [ -z "$JWT_TOKEN" ] || [ -z "$COOKIE" ]; then
    echo "❌ JWT_TOKEN or COOKIE not set in .env"
    exit 1
fi

echo "✅ Credentials found"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Push to GitHub:"
echo "   git add ."
echo "   git commit -m 'Deploy to Render'"
echo "   git push origin main"
echo ""
echo "2. Go to https://render.com"
echo "3. Click 'New +' → 'Web Service'"
echo "4. Connect your GitHub repository"
echo "5. Render will auto-detect render.yaml"
echo "6. Add environment variables:"
echo "   JWT_TOKEN=$JWT_TOKEN"
echo "   COOKIE=$COOKIE"
echo "7. Click 'Create Web Service'"
echo ""
echo "🎉 Your proxy will be live in 2-3 minutes!"
