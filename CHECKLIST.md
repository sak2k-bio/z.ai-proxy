# Pre-Deployment Checklist

## ✅ Before You Deploy

### 1. Verify Local Setup
- [ ] Proxy works locally on port 8000
- [ ] Test streaming endpoint works
- [ ] Test non-streaming endpoint works
- [ ] Credentials are valid and working

### 2. Git Repository
- [ ] All files committed
- [ ] .env is NOT committed (check .gitignore)
- [ ] Pushed to GitHub/GitLab
- [ ] Repository is public or Render has access

### 3. Credentials Ready
- [ ] Fresh JWT_TOKEN from Z.ai
- [ ] Fresh COOKIE from Z.ai
- [ ] Both copied and ready to paste

### 4. Render Account
- [ ] Signed up at https://render.com
- [ ] GitHub account connected
- [ ] Ready to create new Web Service

---

## 🚀 Deployment Steps

### Step 1: Push to Git
```bash
git add .
git commit -m "Ready for Render deployment"
git push origin main
```

### Step 2: Create Render Service
1. Go to https://render.com/dashboard
2. Click **"New +"** → **"Web Service"**
3. Select your repository
4. Render auto-detects `render.yaml`

### Step 3: Configure Service
**Name:** `zai-proxy` (or your choice)
**Region:** Choose closest to you
**Branch:** `main`
**Build Command:** `pip install -r requirements.txt`
**Start Command:** `uvicorn main:app --host 0.0.0.0 --port $PORT`

### Step 4: Add Environment Variables
Click **"Environment"** tab:
- **JWT_TOKEN** = `<paste your token>`
- **COOKIE** = `<paste your cookie>`

### Step 5: Deploy
Click **"Create Web Service"**
Wait 2-3 minutes for deployment

---

## ✅ Post-Deployment Verification

### 1. Check Deployment Status
- [ ] Build completed successfully
- [ ] Service is "Live" (green indicator)
- [ ] No errors in logs

### 2. Test Endpoints
```bash
# Replace YOUR_SERVICE with your actual service name

# Test landing page
curl https://YOUR_SERVICE.onrender.com/

# Test models endpoint
curl https://YOUR_SERVICE.onrender.com/v1/models

# Test chat completions
curl -X POST https://YOUR_SERVICE.onrender.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "glm-5", "messages": [{"role": "user", "content": "Hello"}]}'
```

### 3. Verify Responses
- [ ] Landing page loads
- [ ] Models endpoint returns JSON
- [ ] Chat endpoint streams responses
- [ ] No INTERNAL_ERROR messages

---

## 🔧 Configure AI Clients

### Cursor / Cline / Continue
```
Base URL: https://YOUR_SERVICE.onrender.com/v1
API Key: any-value
Model: glm-5
```

### Test in Client
- [ ] Connection successful
- [ ] Can send messages
- [ ] Receives responses
- [ ] Streaming works

---

## 📊 Monitoring

### Check Logs
Render Dashboard → Your Service → **Logs** tab
- [ ] No error messages
- [ ] Requests are being processed
- [ ] Chat IDs are being fetched

### Performance
- [ ] First request after spin-down: ~30s (normal)
- [ ] Subsequent requests: <2s
- [ ] Streaming is smooth

---

## 🆘 Troubleshooting

### Build Fails
- [ ] Check `requirements.txt` is correct
- [ ] Verify Python version in `runtime.txt`
- [ ] Check build logs for errors

### 500 Errors
- [ ] Verify JWT_TOKEN is set correctly
- [ ] Verify COOKIE is set correctly
- [ ] Check service logs for details
- [ ] Try refreshing credentials

### Slow Performance
- [ ] Normal on free tier (spins down)
- [ ] Consider upgrading to Starter plan
- [ ] Or set up UptimeRobot to keep alive

### INTERNAL_ERROR
- [ ] Credentials expired - refresh them
- [ ] Update in Render dashboard
- [ ] Redeploy service

---

## 🎯 Success Criteria

Your deployment is successful when:
- ✅ Service shows "Live" status
- ✅ Landing page loads
- ✅ API endpoints respond
- ✅ Streaming works
- ✅ AI clients can connect
- ✅ No errors in logs

---

## 📚 Documentation Reference

- **SETUP_COMPLETE.md** - Full summary
- **QUICKSTART.md** - Quick reference
- **DEPLOY.md** - Deploy guide
- **RENDER_DEPLOY.md** - Detailed instructions
- **UPDATE_CREDENTIALS.md** - Refresh credentials

---

## 🔄 Maintenance

### When Credentials Expire
1. Get fresh JWT_TOKEN and COOKIE from Z.ai
2. Go to Render Dashboard → Environment
3. Update both variables
4. Click **"Save Changes"**
5. Service auto-redeploys

### Keep Service Alive (Optional)
Use [UptimeRobot](https://uptimerobot.com):
- Monitor: `https://YOUR_SERVICE.onrender.com/`
- Interval: 10 minutes
- Type: HTTP(s)

### Upgrade Plan (Optional)
Free tier limitations:
- Spins down after 15 min
- 750 hours/month

Starter plan ($7/mo):
- Always-on
- Better performance
- No spin-down

---

## ✨ You're Ready!

Everything is set up and ready to deploy. Follow the steps above and you'll have your Z.ai proxy running in the cloud in minutes!

**Good luck! 🚀**
