# Z.ai Proxy - Quick Reference

## 🚀 Deployment Options

### Render (Cloud - Recommended)
```bash
# 1. Push to GitHub
git add .
git commit -m "Deploy to Render"
git push origin main

# 2. Deploy
# Go to https://render.com
# Click "New +" → "Web Service"
# Connect repo → Auto-detects render.yaml
# Add JWT_TOKEN and COOKIE
# Deploy!
```

**Your URL:** `https://your-service.onrender.com`

### Local
```bash
# Start server
.\.venv\Scripts\Activate.ps1
uvicorn main:app --host 0.0.0.0 --port 8000
```

**Your URL:** `http://localhost:8000`

## 📡 API Endpoints

| Endpoint | Format | Status |
|----------|--------|--------|
| `POST /v1/chat/completions` | OpenAI | ✅ |
| `POST /v1/messages` | Anthropic | ✅ |
| `GET /v1/models` | OpenAI | ✅ |
| `GET /` | Landing Page | ✅ |

## 🔧 Configuration

### Environment Variables
```env
JWT_TOKEN=eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9...
COOKIE="_ga=GA1.1.1556569751.1766900090; ..."
```

### Get Fresh Credentials
1. Open https://chat.z.ai
2. F12 → Network tab
3. Send message
4. Find `completions` request
5. Copy `Authorization: Bearer <token>` → JWT_TOKEN
6. Copy `Cookie:` header → COOKIE

## 💻 Usage Examples

### cURL
```bash
# Streaming
curl -N -X POST https://your-service.onrender.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "glm-5", "stream": true, "messages": [{"role": "user", "content": "Hello"}]}'

# Non-streaming
curl -X POST https://your-service.onrender.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "glm-5", "stream": false, "messages": [{"role": "user", "content": "Hello"}]}'
```

### Python (OpenAI SDK)
```python
from openai import OpenAI

client = OpenAI(
    base_url="https://your-service.onrender.com/v1",
    api_key="any-value"  # Not validated
)

response = client.chat.completions.create(
    model="glm-5",
    messages=[{"role": "user", "content": "Hello"}],
    stream=True
)

for chunk in response:
    print(chunk.choices[0].delta.content, end="")
```

### Python (Anthropic SDK)
```python
from anthropic import Anthropic

client = Anthropic(
    base_url="https://your-service.onrender.com/v1",
    api_key="any-value"  # Not validated
)

response = client.messages.create(
    model="claude-3-5-sonnet-20241022",
    messages=[{"role": "user", "content": "Hello"}],
    max_tokens=1024,
    stream=True
)

for chunk in response:
    print(chunk.delta.text, end="")
```

### AI Clients (Cursor, Cline, Continue)
```
Base URL: https://your-service.onrender.com/v1
API Key: any-value
Model: glm-5
```

## 🔍 Troubleshooting

| Issue | Solution |
|-------|----------|
| 500 Error | Refresh credentials in .env or Render dashboard |
| Slow first request | Free tier spins down - upgrade or use UptimeRobot |
| INTERNAL_ERROR | Credentials expired - get fresh ones |
| Connection refused | Check server is running |

## 📊 Render Free Tier

- ✅ 750 hours/month free
- ⚠️ Spins down after 15 min inactivity
- 🐌 First request ~30s after spin-down
- 💰 Upgrade to Starter ($7/mo) for always-on

## 🔄 Keep Alive (Optional)

Use [UptimeRobot](https://uptimerobot.com):
- Monitor URL: `https://your-service.onrender.com/`
- Interval: 10 minutes
- Type: HTTP(s)

## 📁 Project Structure

```
z.ai-proxy/
├── main.py              # Main proxy server
├── requirements.txt     # Python dependencies
├── .env                 # Credentials (local only)
├── Dockerfile          # Docker deployment
├── render.yaml         # Render config
├── Procfile            # Process config
├── runtime.txt         # Python version
├── README.md           # Full documentation
├── DEPLOY.md           # Quick deploy guide
└── RENDER_DEPLOY.md    # Detailed Render guide
```

## 🆘 Support

- **Issues:** Check logs in Render dashboard
- **Credentials:** Follow UPDATE_CREDENTIALS.md
- **Questions:** See README.md for full docs

## ⚡ Quick Commands

```bash
# Local development
uvicorn main:app --reload

# Test endpoint
curl http://localhost:8000/v1/models

# Check logs (Render)
# Dashboard → Logs tab

# Update credentials (Render)
# Dashboard → Environment → Edit → Save
```

---

**Last Updated:** 2026-05-07  
**Version:** 1.0.0  
**Status:** ✅ Working
