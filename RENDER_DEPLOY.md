# Z.ai Proxy - Render Deployment Guide

## Quick Deploy to Render

### 1. Prepare Your Repository

Make sure your code is pushed to GitHub:

```bash
git add .
git commit -m "Prepare for Render deployment"
git push origin main
```

### 2. Create Render Account

1. Go to https://render.com
2. Sign up with GitHub
3. Authorize Render to access your repositories

### 3. Create New Web Service

1. Click **"New +"** → **"Web Service"**
2. Connect your GitHub repository
3. Configure the service:

   **Basic Settings:**
   - **Name:** `zai-proxy` (or your preferred name)
   - **Region:** Choose closest to you
   - **Branch:** `main`
   - **Root Directory:** Leave empty (or set if in subdirectory)
   - **Runtime:** `Python 3`
   - **Build Command:** `pip install -r requirements.txt`
   - **Start Command:** `uvicorn main:app --host 0.0.0.0 --port $PORT`

   **Instance Type:**
   - **Free** (for testing)
   - **Starter** ($7/month - recommended for production)

### 4. Add Environment Variables

In the Render dashboard, go to **Environment** tab and add:

```
JWT_TOKEN=your_jwt_token_here
COOKIE=your_cookie_here
```

**Important:** Get fresh credentials from Z.ai:
1. Go to https://chat.z.ai
2. Open DevTools (F12) → Network tab
3. Send a message
4. Find the `completions` request
5. Copy `Authorization: Bearer <token>` → This is your JWT_TOKEN
6. Copy the entire `Cookie:` header → This is your COOKIE

### 5. Deploy

1. Click **"Create Web Service"**
2. Wait for deployment (2-3 minutes)
3. Your proxy will be available at: `https://your-service-name.onrender.com`

### 6. Test Your Deployment

```bash
curl -X POST https://your-service-name.onrender.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "glm-5", "stream": false, "messages": [{"role": "user", "content": "Hello"}]}'
```

## Using Your Deployed Proxy

**Base URL:** `https://your-service-name.onrender.com/v1`

**In AI Clients:**
- Cursor, Cline, Continue, etc.
- Set custom API endpoint to your Render URL
- API Key: Any value (not validated)
- Model: `glm-5` or `claude-3-5-sonnet-20241022`

## Important Notes

### Free Tier Limitations
- ⚠️ **Spins down after 15 minutes of inactivity**
- First request after spin-down takes ~30 seconds
- 750 hours/month free (enough for personal use)

### Keeping It Alive (Optional)
Use a service like UptimeRobot or Cron-job.org to ping your service every 10 minutes:
```
https://your-service-name.onrender.com/
```

### Credential Refresh
Z.ai credentials expire periodically. When you get errors:
1. Get fresh JWT_TOKEN and COOKIE from browser
2. Update environment variables in Render dashboard
3. Click **"Manual Deploy"** → **"Clear build cache & deploy"**

### Security
- Your credentials are stored as environment variables (secure)
- Don't commit `.env` file to GitHub (already in `.gitignore`)
- Consider using Render's paid plan for better security and uptime

## Troubleshooting

### Deployment Fails
- Check build logs in Render dashboard
- Verify `requirements.txt` is correct
- Ensure Python version compatibility

### 500 Errors
- Check environment variables are set correctly
- View logs in Render dashboard
- Credentials might be expired - refresh them

### Slow Response
- Free tier spins down - first request is slow
- Upgrade to Starter plan for always-on service
- Or use UptimeRobot to keep it alive

## Alternative: Docker Deployment

If you prefer Docker on Render:

1. Use the existing `Dockerfile`
2. In Render, select **"Docker"** as runtime
3. Build command: (leave empty)
4. Start command: (leave empty - uses Dockerfile CMD)

## Cost Estimate

- **Free Tier:** $0/month (with spin-down)
- **Starter:** $7/month (always-on, better performance)
- **Standard:** $25/month (production-grade)

For personal use, Free tier is sufficient. For team/production use, Starter is recommended.

## Next Steps

After deployment:
1. Test all endpoints (`/v1/chat/completions`, `/v1/messages`, `/v1/models`)
2. Configure your AI clients to use the new URL
3. Set up monitoring (optional)
4. Add custom domain (optional, paid plans only)

Your Z.ai proxy is now accessible from anywhere! 🚀
