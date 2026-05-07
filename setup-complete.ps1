#!/usr/bin/env pwsh

Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Z.ai Proxy - Deployment Complete!   ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Host "✅ All deployment files created!" -ForegroundColor Green
Write-Host ""

Write-Host "📦 Files Created:" -ForegroundColor Yellow
Write-Host "  • render.yaml       - Render configuration" -ForegroundColor Gray
Write-Host "  • Procfile          - Process definition" -ForegroundColor Gray
Write-Host "  • runtime.txt       - Python version" -ForegroundColor Gray
Write-Host "  • DEPLOY.md         - Quick deploy guide" -ForegroundColor Gray
Write-Host "  • RENDER_DEPLOY.md  - Detailed guide" -ForegroundColor Gray
Write-Host "  • QUICKSTART.md     - Quick reference" -ForegroundColor Gray
Write-Host ""

Write-Host "🚀 Next Steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Commit and push to GitHub:" -ForegroundColor White
Write-Host "   git add ." -ForegroundColor Cyan
Write-Host "   git commit -m 'Add Render deployment'" -ForegroundColor Cyan
Write-Host "   git push origin main" -ForegroundColor Cyan
Write-Host ""

Write-Host "2. Deploy to Render:" -ForegroundColor White
Write-Host "   • Go to https://render.com" -ForegroundColor Cyan
Write-Host "   • Click 'New +' → 'Web Service'" -ForegroundColor Cyan
Write-Host "   • Connect your GitHub repo" -ForegroundColor Cyan
Write-Host "   • Render auto-detects render.yaml" -ForegroundColor Cyan
Write-Host "   • Add JWT_TOKEN and COOKIE" -ForegroundColor Cyan
Write-Host "   • Click 'Create Web Service'" -ForegroundColor Cyan
Write-Host ""

Write-Host "3. Get your credentials:" -ForegroundColor White
Write-Host "   • Open https://chat.z.ai" -ForegroundColor Cyan
Write-Host "   • Press F12 → Network tab" -ForegroundColor Cyan
Write-Host "   • Send a message" -ForegroundColor Cyan
Write-Host "   • Copy JWT token and Cookie" -ForegroundColor Cyan
Write-Host ""

Write-Host "📖 Documentation:" -ForegroundColor Yellow
Write-Host "   • DEPLOY.md - Quick start" -ForegroundColor Gray
Write-Host "   • RENDER_DEPLOY.md - Full guide" -ForegroundColor Gray
Write-Host "   • QUICKSTART.md - Reference card" -ForegroundColor Gray
Write-Host ""

Write-Host "🎉 Your proxy will be live in 2-3 minutes!" -ForegroundColor Green
Write-Host ""
