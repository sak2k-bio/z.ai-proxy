# Deploy Z.ai Proxy to Render - Quick Guide

## One-Click Deploy

1. **Fork this repository** to your GitHub account

2. **Click the Deploy button:**

   [![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)

3. **Configure Environment Variables:**
   
   You'll be prompted to enter:
   - `JWT_TOKEN` - Your Z.ai JWT token
   - `COOKIE` - Your Z.ai cookie string

4. **Get Your Credentials:**
   
   Open https://chat.z.ai in your browser:
   - Press F12 (DevTools)
   - Go to Network tab
   - Send a message
   - Find the `completions` request
   - Copy `Authorization: Bearer <token>` → JWT_TOKEN
   - Copy entire `Cookie:` header → COOKIE

5. **Deploy!**
   
   Click "Apply" and wait 2-3 minutes.

## Your Proxy URL

After deployment, your proxy will be available at:
```
https://your-service-name.onrender.com
```

## Test It

```bash
curl https://your-service-name.onrender.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "glm-5", "messages": [{"role": "user", "content": "Hello"}]}'
```

## Use in AI Clients

- **Base URL:** `https://your-service-name.onrender.com/v1`
- **API Key:** Any value (not validated)
- **Model:** `glm-5`

## Free Tier Notes

- Spins down after 15 minutes of inactivity
- First request after spin-down takes ~30 seconds
- 750 hours/month free

## Keep Alive (Optional)

Use [UptimeRobot](https://uptimerobot.com) to ping your service every 10 minutes:
```
https://your-service-name.onrender.com/
```

## Troubleshooting

**500 Errors?**
- Check environment variables are set correctly
- Credentials might be expired - refresh them in Render dashboard

**Slow Response?**
- Free tier spins down - first request is slow
- Upgrade to Starter ($7/month) for always-on

## Full Documentation

See [RENDER_DEPLOY.md](RENDER_DEPLOY.md) for detailed instructions.
