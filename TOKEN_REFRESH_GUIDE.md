# Token Refresh Solutions

**Problem:** JWT_TOKEN and COOKIE expire frequently, requiring manual updates in Render dashboard.

**Date:** 2026-05-09  
**Status:** Multiple solutions available

---

## Solution 1: Manual Refresh (Current Method)

### When Tokens Expire
**Symptoms:**
- 401 Unauthorized errors
- 500 Internal Server Error
- "INTERNAL_ERROR" in responses

### Steps to Refresh
1. Visit https://chat.z.ai in browser
2. Open DevTools (F12)
3. Go to Application → Cookies → https://chat.z.ai
4. Copy these values:
   - JWT token (usually named `token` or `auth_token`)
   - Cookie string (all cookies concatenated)
5. Update in Render:
   - Dashboard → Environment
   - Update `JWT_TOKEN` and `COOKIE`
   - Service auto-redeploys (~2 minutes)

**Frequency:** Every 7-30 days (varies)

---

## Solution 2: Token Validity Monitoring

Add health check that alerts when tokens expire:

### Implementation

```python
# Add to main.py
import asyncio
from datetime import datetime

TOKEN_LAST_CHECKED = None
TOKEN_IS_VALID = True

async def check_token_health():
    """Background task to monitor token validity"""
    global TOKEN_LAST_CHECKED, TOKEN_IS_VALID
    
    while True:
        try:
            # Test token by fetching chat list
            url = "https://chat.z.ai/api/v1/chats/?page=1&type=default"
            headers = {
                "authorization": f"Bearer {JWT_TOKEN}",
                "Cookie": COOKIE
            }
            
            session = AsyncSession()
            response = await session.get(url, headers=headers, impersonate="chrome120", timeout=10)
            await session.close()
            
            TOKEN_IS_VALID = (response.status_code == 200)
            TOKEN_LAST_CHECKED = datetime.utcnow()
            
            if not TOKEN_IS_VALID:
                print(f"[ALERT] Tokens expired at {TOKEN_LAST_CHECKED}", flush=True)
        
        except Exception as e:
            print(f"[ERROR] Token health check failed: {e}", flush=True)
            TOKEN_IS_VALID = False
        
        # Check every hour
        await asyncio.sleep(3600)

@app.on_event("startup")
async def startup_event():
    asyncio.create_task(check_token_health())

@app.get("/health")
async def health_check():
    return {
        "status": "healthy" if TOKEN_IS_VALID else "degraded",
        "token_valid": TOKEN_IS_VALID,
        "last_checked": TOKEN_LAST_CHECKED.isoformat() if TOKEN_LAST_CHECKED else None
    }
```

### Benefits
- `/health` endpoint shows token status
- Logs alert when tokens expire
- Can integrate with UptimeRobot for notifications

---

## Solution 3: Automated Browser Refresh (Advanced)

Use Playwright to automatically extract fresh tokens:

### Requirements
```bash
pip install playwright
playwright install chromium
```

### Implementation

```python
# token_auto_refresh.py
from playwright.async_api import async_playwright
import os
import json

async def auto_refresh_tokens():
    """
    Automatically refresh tokens using browser automation
    Requires: Playwright + saved browser session
    """
    async with async_playwright() as p:
        # Launch browser with persistent context (saves login)
        browser = await p.chromium.launch_persistent_context(
            user_data_dir="./browser_data",
            headless=True
        )
        
        page = await browser.new_page()
        
        # Navigate to Z.ai
        await page.goto("https://chat.z.ai")
        
        # Wait for page to load
        await page.wait_for_load_state("networkidle")
        
        # Extract cookies
        cookies = await browser.cookies()
        cookie_string = "; ".join([f"{c['name']}={c['value']}" for c in cookies])
        
        # Extract JWT from localStorage
        jwt_token = await page.evaluate("() => localStorage.getItem('token')")
        
        await browser.close()
        
        return jwt_token, cookie_string

# Run periodically
if __name__ == "__main__":
    import asyncio
    jwt, cookie = asyncio.run(auto_refresh_tokens())
    print(f"JWT: {jwt[:20]}...")
    print(f"Cookie: {cookie[:50]}...")
```

### Deployment on Render
```yaml
# render.yaml
services:
  - type: web
    name: zai-proxy
    env: python
    buildCommand: pip install -r requirements.txt && playwright install chromium
    startCommand: python main.py
```

**Note:** Requires Playwright buildpack and may need paid Render plan for browser automation.

---

## Solution 4: Reverse Proxy with Token Injection

Use a separate service to handle token refresh:

### Architecture
```
Client → Nginx/Caddy → Token Refresher → Z.ai Proxy → Z.ai
```

### Token Refresher Service
- Runs on separate server/container
- Monitors token validity
- Updates proxy environment variables via Render API
- Triggers redeployment when tokens refresh

### Render API Integration
```python
import requests

RENDER_API_KEY = os.getenv("RENDER_API_KEY")
SERVICE_ID = os.getenv("RENDER_SERVICE_ID")

def update_render_env_vars(jwt_token, cookie):
    """Update environment variables via Render API"""
    url = f"https://api.render.com/v1/services/{SERVICE_ID}/env-vars"
    headers = {
        "Authorization": f"Bearer {RENDER_API_KEY}",
        "Content-Type": "application/json"
    }
    
    payload = [
        {"key": "JWT_TOKEN", "value": jwt_token},
        {"key": "COOKIE", "value": cookie}
    ]
    
    response = requests.put(url, headers=headers, json=payload)
    return response.status_code == 200
```

---

## Solution 5: Use Z.ai API Directly (If Available)

Check if Z.ai offers:
- OAuth2 refresh tokens
- API keys (non-expiring)
- Service accounts

**Research:** Check Z.ai documentation for official API access methods.

---

## Recommended Approach

### For Free Tier (Current Setup)
**Solution 2: Token Monitoring**
- Add `/health` endpoint
- Set up UptimeRobot to monitor health
- Get email alerts when tokens expire
- Manually refresh (takes 2 minutes)

### For Production Use
**Solution 3 or 4: Automated Refresh**
- Playwright automation for token extraction
- Scheduled task (cron) runs every 6 hours
- Auto-updates Render environment variables
- Zero downtime

### Quick Win (Immediate)
**Add expiration detection to current code:**

```python
# Add to main.py after line 52
async def handle_token_expiration(response):
    """Detect token expiration from Z.ai response"""
    if response.status_code == 401:
        print("[CRITICAL] JWT_TOKEN expired! Update environment variables.", flush=True)
        raise HTTPException(
            status_code=503,
            detail="Service credentials expired. Administrator notified."
        )
```

---

## Implementation Priority

1. **Now:** Add token expiration detection (5 minutes)
2. **Today:** Add `/health` endpoint (10 minutes)
3. **This Week:** Set up UptimeRobot monitoring (free)
4. **Optional:** Implement Playwright auto-refresh (2-3 hours)

---

## Token Lifespan Research

**Test Plan:**
1. Note current token creation date
2. Monitor when it expires
3. Document lifespan pattern
4. Set refresh schedule accordingly

**Hypothesis:** Z.ai tokens likely expire:
- Every 7 days (common for JWT)
- Every 30 days (common for session cookies)
- On password change
- On logout from any device

---

## Cost Comparison

| Solution | Setup Time | Maintenance | Cost |
|----------|------------|-------------|------|
| Manual refresh | 0 min | 2 min/week | Free |
| Health monitoring | 10 min | 0 min | Free |
| Playwright automation | 2-3 hours | 0 min | $7/mo (Render Starter) |
| Separate refresh service | 4-6 hours | 0 min | $7-14/mo |

---

**Next Steps:**
1. Implement Solution 2 (health monitoring) - quick win
2. Test token lifespan
3. Decide on automation based on expiration frequency

