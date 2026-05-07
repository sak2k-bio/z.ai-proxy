#!/usr/bin/env pwsh

Write-Host "🚀 Z.ai Proxy - Render Deployment Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if git is initialized
if (-not (Test-Path .git)) {
    Write-Host "❌ Git repository not initialized" -ForegroundColor Red
    Write-Host "Run: git init" -ForegroundColor Yellow
    exit 1
}

# Check if .env exists
if (-not (Test-Path .env)) {
    Write-Host "❌ .env file not found" -ForegroundColor Red
    Write-Host "Please create .env with JWT_TOKEN and COOKIE" -ForegroundColor Yellow
    exit 1
}

# Load credentials
$envContent = Get-Content .env
$jwtToken = ($envContent | Select-String "JWT_TOKEN=").ToString().Split("=")[1]
$cookie = ($envContent | Select-String "COOKIE=").ToString().Split("=")[1]

if ([string]::IsNullOrEmpty($jwtToken) -or [string]::IsNullOrEmpty($cookie)) {
    Write-Host "❌ JWT_TOKEN or COOKIE not set in .env" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Credentials found" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Push to GitHub:" -ForegroundColor White
Write-Host "   git add ." -ForegroundColor Gray
Write-Host "   git commit -m 'Deploy to Render'" -ForegroundColor Gray
Write-Host "   git push origin main" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Go to https://render.com" -ForegroundColor White
Write-Host "3. Click 'New +' → 'Web Service'" -ForegroundColor White
Write-Host "4. Connect your GitHub repository" -ForegroundColor White
Write-Host "5. Render will auto-detect render.yaml" -ForegroundColor White
Write-Host "6. Add environment variables:" -ForegroundColor White
Write-Host "   JWT_TOKEN=<your_token>" -ForegroundColor Gray
Write-Host "   COOKIE=<your_cookie>" -ForegroundColor Gray
Write-Host "7. Click 'Create Web Service'" -ForegroundColor White
Write-Host ""
Write-Host "🎉 Your proxy will be live in 2-3 minutes!" -ForegroundColor Green
Write-Host ""
Write-Host "📖 Full guide: RENDER_DEPLOY.md" -ForegroundColor Cyan
