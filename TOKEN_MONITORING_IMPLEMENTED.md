# Token Monitoring Implementation

**Date:** 2026-05-09  
**Status:** ✅ Implemented Locally | ⏳ Deploying to Production  
**Commit:** 5463146

---

## Problem Solved

**Issue:** JWT_TOKEN and COOKIE expire frequently, causing service outages without warning.

**Solution:** Automatic token health monitoring with alerts and status endpoint.

---

## What Was Added

### 1. Background Token Health Monitor

**Function:** `check_token_health()`
- Runs every hour (3600 seconds)
- Tests token validity by calling Z.ai chat list API
- Logs critical alerts when tokens expire
- Updates global health status variables

**Implementation:**
```python
async def check_token_health():
    """Background task to monitor token validity every hour"""
    global TOKEN_LAST_CHECKED, TOKEN_IS_VALID, TOKEN_LAST_ERROR

    while True:
        try:
            # Test token by fetching chat list
            url = "https://chat.z.ai/api/v1/chats/?page=1&type=default"
            headers = {
                "authorization": f"Bearer {JWT_TOKEN}",
                "content-type": "application/json",
                "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
                "Cookie": COOKIE
            }

            session = AsyncSession()
            response = await session.get(url, headers=headers, impersonate="chrome120", timeout=10)
            await session.close()

            TOKEN_IS_VALID = (response.status_code == 200)
            TOKEN_LAST_CHECKED = datetime.utcnow()

            if not TOKEN_IS_VALID:
                TOKEN_LAST_ERROR = f"HTTP {response.status_code}"
                print(f"[CRITICAL] Tokens expired or invalid! Status: {response.status_code}", flush=True)
                print(f"[ACTION] Update JWT_TOKEN and COOKIE in Render dashboard", flush=True)
            else:
                TOKEN_LAST_ERROR = None
                print(f"[INFO] Token health check passed at {TOKEN_LAST_CHECKED}", flush=True)

        except Exception as e:
            TOKEN_IS_VALID = False
            TOKEN_LAST_ERROR = str(e)
            TOKEN_LAST_CHECKED = datetime.utcnow()
            print(f"[ERROR] Token health check failed: {e}", flush=True)

        # Check every hour
        await asyncio.sleep(3600)
```

### 2. Health Check Endpoint

**Endpoint:** `GET /health`

**Response Format:**
```json
{
  "status": "healthy",
  "token_valid": true,
  "last_checked": "2026-05-09T12:35:23.991440",
  "last_error": null,
  "message": "Service operational"
}
```

**When Tokens Expire:**
```json
{
  "status": "degraded",
  "token_valid": false,
  "last_checked": "2026-05-09T12:40:15.123456",
  "last_error": "HTTP 401",
  "message": "Credentials expired - update JWT_TOKEN and COOKIE"
}
```

### 3. Enhanced Error Detection

**Modified:** `get_or_create_chat_id()`
- Detects 401 Unauthorized responses
- Returns 503 Service Unavailable to clients
- Logs critical alerts
- Updates token health status

**Implementation:**
```python
elif response.status_code == 401:
    # Token expired
    TOKEN_IS_VALID = False
    TOKEN_LAST_ERROR = "401 Unauthorized"
    print(f"[CRITICAL] JWT_TOKEN expired! Update environment variables.", flush=True)
    raise HTTPException(
        status_code=503,
        detail="Service credentials expired. Please contact administrator."
    )
```

### 4. Startup Hook

**Function:** `startup_event()`
- Starts background monitoring on server startup
- Runs as async task (non-blocking)

**Implementation:**
```python
@app.on_event("startup")
async def startup_event():
    """Start background token health monitoring"""
    asyncio.create_task(check_token_health())
    print("[INFO] Token health monitoring started", flush=True)
```

---

## Testing Results

### Local Testing (Port 8001) ✅

**Health Endpoint:**
```bash
curl http://localhost:8001/health
```
**Response:**
```json
{
  "status": "healthy",
  "token_valid": true,
  "last_checked": "2026-05-09T12:35:23.991440",
  "last_error": null,
  "message": "Service operational"
}
```

**Server Logs:**
```
[INFO] Token health monitoring started
[INFO] Token health check passed at 2026-05-09 12:35:23.991440
```

### Production Testing (Render) ⏳

**Status:** Deployment in progress
**Expected URL:** https://zai-proxy-lqau.onrender.com/health
**Current Status:** 404 Not Found (deployment may still be processing)

---

## How to Use

### 1. Monitor Token Health

**Manual Check:**
```bash
curl https://zai-proxy-lqau.onrender.com/health
```

**Automated Monitoring (UptimeRobot):**
1. Create new monitor
2. Monitor Type: HTTP(s)
3. URL: https://zai-proxy-lqau.onrender.com/health
4. Monitoring Interval: 5 minutes
5. Alert Contacts: Your email
6. Keyword Alert: Set to alert if response doesn't contain `"token_valid":true`

### 2. Check Render Logs

When tokens expire, you'll see:
```
[CRITICAL] Tokens expired or invalid! Status: 401
[ACTION] Update JWT_TOKEN and COOKIE in Render dashboard
```

### 3. Refresh Tokens

When alerted:
1. Visit https://chat.z.ai
2. Open DevTools (F12) → Application → Cookies
3. Copy JWT token and cookie values
4. Update in Render Dashboard → Environment
5. Service auto-redeploys (~2 minutes)

---

## Benefits

### Before
- ❌ Tokens expire silently
- ❌ Service fails with no warning
- ❌ Users get cryptic errors
- ❌ Manual checking required

### After
- ✅ Hourly token validation
- ✅ Critical alerts in logs
- ✅ Health endpoint for monitoring
- ✅ 503 errors when credentials expire
- ✅ Clear error messages
- ✅ Can integrate with UptimeRobot

---

## Monitoring Schedule

| Time | Action |
|------|--------|
| Every hour | Background health check runs |
| On startup | Initial health check |
| On 401 error | Immediate alert + status update |
| On request | Health endpoint available anytime |

---

## Next Steps

### Immediate
1. ✅ Code implemented
2. ✅ Tested locally
3. ✅ Committed to git
4. ✅ Pushed to GitHub
5. ⏳ Render deployment in progress

### Optional Enhancements
1. Set up UptimeRobot monitoring (free)
2. Add email alerts for token expiration
3. Implement Playwright auto-refresh (advanced)
4. Add Slack/Discord webhook notifications

---

## Files Changed

1. **main.py**
   - Added `check_token_health()` function
   - Added `/health` endpoint
   - Added `startup_event()` hook
   - Enhanced `get_or_create_chat_id()` error handling
   - Added global health status variables

2. **TOKEN_REFRESH_GUIDE.md** (new)
   - Comprehensive guide for all token refresh solutions
   - Manual, automated, and advanced approaches

3. **token_refresher.py** (new)
   - Standalone token monitoring script
   - Can be run separately for testing

---

## Deployment Status

**Commit:** 5463146  
**Branch:** main  
**Pushed:** 2026-05-09 12:38 UTC  
**Render Status:** Deploying (usually takes 2-3 minutes)

**Verify Deployment:**
```bash
# Should return health status (not 404)
curl https://zai-proxy-lqau.onrender.com/health

# Should show "Token health monitoring started" in logs
# Check Render Dashboard → Logs tab
```

---

## Troubleshooting

### Health Endpoint Returns 404
- Render deployment may still be in progress
- Check Render Dashboard → Logs for deployment status
- Verify main.py was pushed correctly: `git show 5463146:main.py | tail -20`

### Token Health Check Fails
- Check JWT_TOKEN and COOKIE are set in Render environment
- Verify credentials are still valid at https://chat.z.ai
- Check Render logs for error messages

### Background Task Not Running
- Check startup logs for "[INFO] Token health monitoring started"
- Verify asyncio import is present
- Check for Python errors in Render logs

---

**Implementation Complete!** 🎉

The proxy now has automatic token monitoring with:
- Hourly health checks
- Critical alerts when tokens expire
- Public health endpoint for monitoring
- Clear error messages for users

