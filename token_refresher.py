"""
Automatic token refresh for Z.ai proxy
Monitors token validity and refreshes when needed
"""
import os
import json
import time
import asyncio
from curl_cffi.requests import AsyncSession
from dotenv import load_dotenv, set_key

load_dotenv()

async def check_token_validity():
    """Check if current JWT token is still valid"""
    jwt_token = os.getenv("JWT_TOKEN")
    cookie = os.getenv("COOKIE")

    if not jwt_token or not cookie:
        return False

    # Test token by fetching chat list
    url = "https://chat.z.ai/api/v1/chats/?page=1&type=default"
    headers = {
        "authorization": f"Bearer {jwt_token}",
        "content-type": "application/json",
        "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
        "Cookie": cookie
    }

    session = AsyncSession()
    try:
        response = await session.get(url, headers=headers, impersonate="chrome120", timeout=10)
        return response.status_code == 200
    except Exception as e:
        print(f"[ERROR] Token validation failed: {e}")
        return False
    finally:
        await session.close()

async def refresh_tokens():
    """
    Refresh JWT_TOKEN and COOKIE

    This requires manual intervention - you need to:
    1. Open https://chat.z.ai in browser
    2. Open DevTools (F12) -> Application -> Cookies
    3. Copy the new JWT token and cookie values
    4. Update .env file or Render environment variables

    For automated refresh, you would need to implement:
    - Playwright/Selenium browser automation
    - Login flow automation
    - Cookie extraction
    """
    print("[WARNING] Tokens expired! Manual refresh required:")
    print("1. Visit https://chat.z.ai")
    print("2. Open DevTools (F12) -> Application -> Cookies")
    print("3. Copy JWT token and cookie")
    print("4. Update environment variables")
    return False

async def monitor_tokens(check_interval=3600):
    """
    Monitor token validity every hour
    Args:
        check_interval: seconds between checks (default 1 hour)
    """
    while True:
        print(f"[INFO] Checking token validity...")
        is_valid = await check_token_validity()

        if not is_valid:
            print("[ALERT] Tokens are invalid or expired!")
            await refresh_tokens()
        else:
            print("[INFO] Tokens are valid")

        await asyncio.sleep(check_interval)

if __name__ == "__main__":
    asyncio.run(monitor_tokens())
