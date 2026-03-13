# What is This Project?

## Overview

**Z.ai API Proxy** is a FastAPI-based proxy server that acts as a bridge between standard AI clients and Z.ai's web-based chat API.

```mermaid
graph LR
    A[AI Client] --> B[Z.ai Proxy]
    B --> C[Z.ai Server]
    
    subgraph "Your Machine"
        A
        B
    end
    
    subgraph "Remote"
        C
    end
```

## The Problem It Solves

Z.ai provides a powerful AI chat interface through their website (chat.z.ai), but using their API directly from standard AI clients (like Cursor, XibeCode, or SDKs) is blocked by robust security measures:

| Challenge | Description |
|-----------|-------------|
| **426 Upgrade Required** | Server rejects outdated client versions |
| **403 Forbidden** | HMAC-SHA256 signature verification fails for unauthorized clients |
| **Bot Detection** | Cloudflare and TLS fingerprinting block automated requests |

This proxy bypasses these restrictions and provides a clean, standard API interface.

## Architecture

```mermaid
flowchart TB
    subgraph Client["AI Client (Cursor/XibeCode/SDK)"]
        A1[OpenAI Format]
        A2[Anthropic Format]
    end
    
    subgraph Proxy["Z.ai Proxy (This App)"]
        B1["/v1/chat/completions"]
        B2["/v1/messages"]
        B3["/v1/models"]
        B4[Signature Generator]
        B5[Stream Transformer]
    end
    
    subgraph Zai["Z.ai Server"]
        C1[Web API Endpoint]
        C2[Security Layer]
        C3[AI Models]
    end
    
    A1 --> B1
    A2 --> B2
    
    B1 --> B4
    B2 --> B4
    B4 --> C1
    C1 --> C2
    C2 --> C3
    
    C3 --> B5
    B5 --> B1
    B5 --> B2
```

## How It Works

### Request Flow

```mermaid
sequenceDiagram
    participant Client as AI Client
    participant Proxy as Z.ai Proxy
    participant Zai as Z.ai Server
    
    Client->>Proxy: POST /v1/chat/completions<br/>(OpenAI format)
    
    Note over Proxy: 1. Extract messages
    Note over Proxy: 2. Generate HMAC signature
    Note over Proxy: 3. Spoof browser fingerprint
    Note over Proxy: 4. Add JWT + Cookie headers
    
    Proxy->>Zai: Transformed request<br/>with x-signature
    
    Zai-->>Proxy: SSE Stream Response
    
    Note over Proxy: Convert to OpenAI<br/>SSE format
    
    Proxy-->>Client: Standard SSE stream
```

### Signature Generation Process

```mermaid
flowchart LR
    A[Timestamp] --> D[HMAC Key]
    B[Fixed Salt] --> D
    D --> E[Signing Key]
    
    F[Request Params] --> G[Sorted & Flattened]
    G --> H[Payload String]
    I[Base64 Message] --> H
    J[Timestamp] --> H
    
    H --> K[HMAC-SHA256]
    E --> K
    K --> L[x-signature Header]
```

## Key Features

### 🔄 Dual API Compatibility

```mermaid
graph TD
    subgraph "Supported Formats"
        O[OpenAI SDK] --> OC["/v1/chat/completions"]
        A[Anthropic SDK] --> AC["/v1/messages"]
    end
    
    subgraph "Internal"
        OC --> Z[Z.ai Chat API]
        AC --> Z
    end
    
    Z --> Response["Response (Streaming or JSON)"]
```

- **OpenAI Format**: `/v1/chat/completions` endpoint
- **Anthropic Format**: `/v1/messages` endpoint
- Use any existing SDK or client that supports OpenAI or Anthropic APIs

### 🔐 Security Bypass Components

| Component | Implementation |
|-----------|----------------|
| **Signature Generation** | Reverse-engineers Z.ai's `x-signature` header using HMAC-SHA256 with a 5-minute windowed key derived from a fixed internal salt |
| **Device Fingerprint** | Spoofs Chrome browser parameters (user agent, viewport, timezone, screen resolution) |
| **TLS Fingerprint** | Uses `curl_cffi` with `chrome124` impersonation to match real browser TLS signatures |
| **Cookie/JWT Passthrough** | Forwards your authenticated session to Z.ai |

### ⚡ Real-Time Streaming

```mermaid
flowchart LR
    Z[Z.ai SSE Stream] --> P[Proxy Parser]
    P --> O{Format?}
    O -->|OpenAI| OC["data: {...chat.completion.chunk...}"]
    O -->|Anthropic| AC["event: content_block_delta<br/>data: {...}"]
    
    OC --> C[Client]
    AC --> C
```

- Full Server-Sent Events (SSE) support
- Token-by-token streaming response
- Reasoning stream extraction for `<details type="reasoning">` thinking blocks
- Works identically to OpenAI/Anthropic streaming APIs

## Project Structure

```mermaid
graph TB
    subgraph Files
        M[main.py] --> F[FastAPI Endpoints]
        F --> OC[/v1/chat/completions]
        F --> AC[/v1/messages]
        F --> ML[/v1/models]
        F --> ROOT[/ - Landing Page]
        
        M --> SG[Signature Logic]
        M --> ST[Stream Transformer]
        
        D[Dockerfile] --> CONTAINER[Container Image]
        R[requirements.txt] --> DEPS[Dependencies]
        E[.env] --> CREDS[Credentials]
    end
```

| File | Purpose |
|------|---------|
| `main.py` | FastAPI application with all endpoints and signature logic |
| `Dockerfile` | Container configuration for easy deployment |
| `requirements.txt` | Python dependencies (FastAPI, curl_cffi, uvicorn, dotenv) |
| `.env` | Your JWT_TOKEN and COOKIE credentials |

## API Endpoints

| Endpoint | Method | Description | Format |
|----------|--------|-------------|--------|
| `/` | GET | Beautiful landing page (HTML) | N/A |
| `/v1/chat/completions` | POST | OpenAI-compatible chat endpoint | OpenAI |
| `/v1/messages` | POST | Anthropic-compatible messages endpoint | Anthropic |
| `/v1/models` | GET | List available models | OpenAI |

## Available Models

| Model ID | Provider | Description |
|----------|----------|-------------|
| `glm-5` | Z.ai | Z.ai's primary language model |
| `claude-3-5-sonnet-20241022` | Anthropic | Claude 3.5 Sonnet via Z.ai |

## Setup Requirements

To use this proxy, you need credentials extracted from your browser:

```mermaid
flowchart LR
    subgraph Browser["Browser DevTools"]
        N[Network Tab] --> R[completions Request]
        R --> H[Headers]
        H --> JWT["Authorization: Bearer &lt;TOKEN&gt;"]
        H --> CK["Cookie: &lt;COOKIE&gt;"]
    end
    
    JWT --> ENV[.env File]
    CK --> ENV
    
    ENV --> PROXY[Z.ai Proxy]
```

### Required Credentials

1. **JWT_TOKEN** - Your authentication token from Z.ai website (found in browser DevTools > Network tab > Authorization header)
2. **COOKIE** - Your session cookie from Z.ai website (found in browser DevTools > Network tab > Cookie header)

These are stored in a `.env` file:

```env
JWT_TOKEN="eyJhbGciOi..."
COOKIE="__stripe_mid=..."
```

## Quick Start

```bash
# Install dependencies
pip install -r requirements.txt

# Create .env file with your credentials
echo 'JWT_TOKEN="your-jwt-token-here"' > .env
echo 'COOKIE="your-cookie-string-here"' >> .env

# Run the proxy
uvicorn main:app --host 0.0.0.0 --port 8000
```

Then configure your AI client to use `http://localhost:8000/v1` as the API endpoint.

### Docker Deployment

```bash
# Build image
docker build -t zai-proxy .

# Run container
docker run -d -p 8000:8000 --env-file .env --name zai-proxy zai-proxy
```

## Use Cases

```mermaid
mindmap
  root((Use Cases))
    AI Code Editors
      Cursor
      XibeCode
      Cline
      Continue.dev
    Development
      Python Scripts
      Node.js Apps
      API Testing
    Integration
      OpenAI SDK
      Anthropic SDK
      Custom Clients
```

- **AI Code Editors**: Use Z.ai with Cursor, XibeCode, Cline, or any OpenAI-compatible editor
- **Scripting**: Integrate Z.ai into Python/Node/other scripts using standard SDKs
- **Testing**: Test AI functionality without using official API calls
- **Prototyping**: Quick integration without learning new API formats

## Security Note

> ⚠️ **Warning**: This proxy uses YOUR authentication credentials. Keep your `.env` file secure and never share your JWT token or cookies publicly.

## Technical Deep Dive

### Signature Algorithm

```mermaid
flowchart TD
    A["Timestamp (ms)"] --> B["Window Index = timestamp // 300000"]
    B --> C["HMAC(FIXED_KEY, window_index)"]
    C --> D["Signing Key E"]
    
    E["Request Parameters"] --> F["Sort alphabetically"]
    F --> G["Flatten to key,value,key,value..."]
    G --> H["Join with commas"]
    
    I["User Message"] --> J["Base64 Encode"]
    
    H --> K["payload_string | base64_msg | timestamp"]
    J --> K
    K --> L["HMAC(E, K)"]
    L --> M["Final Signature"]
    M --> N["x-signature Header"]
```

The proxy calculates a complex HMAC-SHA256 signature by:

1. Generating a 5-minute windowed HMAC key using a fixed internal salt
2. Sorting and flattening key request parameters (timestamp, request ID, user ID)
3. Hashing the flattened metadata along with the base64-encoded user message

---

*This project is for educational and personal use only. Use at your own risk and respect Z.ai's Terms of Service.*