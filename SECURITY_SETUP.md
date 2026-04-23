# Security Setup for App Store

## API Keys & Secrets (Critical)

**Never commit secrets to git or include in app binary!**

### What NOT to do ❌
```swift
// WRONG - Will be visible in App Store binary!
let botToken = "123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11"
let relaySecret = "super-secret-key-in-code"
```

### What TO do ✅

#### Option 1: Environment Variables (Recommended for App Store)

**Backend (.env file):**
```bash
TELEGRAM_BOT_TOKEN=your_actual_token
RELAY_SECRET=your_actual_secret
BACKEND_URL=https://api.teleagent.app
```

**iOS App (use remote config or secure backend):**
```swift
// Fetch from secure backend endpoint
func loadSecrets() async {
    let response = try await URLSession.shared.data(from: URL(string: "https://api.teleagent.app/config")!)
    let config = try JSONDecoder().decode(Config.self, from: response.0)
    self.relaySecret = config.relaySecret
}

struct Config: Codable {
    let relaySecret: String
    let backendURL: String
}
```

#### Option 2: Keychain Storage (iOS)

```swift
import Security

func saveToKeychain(key: String, value: String) {
    let data = value.data(using: .utf8)!
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key,
        kSecValueData as String: data
    ]
    SecItemDelete(query as CFDictionary)
    SecItemAdd(query as CFDictionary, nil)
}

func loadFromKeychain(key: String) -> String? {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key,
        kSecReturnData as String: true
    ]
    var result: AnyObject?
    SecItemCopyMatching(query as CFDictionary, &result)
    if let data = result as? Data {
        return String(data: data, encoding: .utf8)
    }
    return nil
}

// Usage:
saveToKeychain(key: "relay_secret", value: "abc123")
let secret = loadFromKeychain(key: "relay_secret")
```

#### Option 3: App Store Connect Secrets (Best for Production)

1. In App Store Connect, add environment variables
2. App can fetch from secure endpoint at launch
3. Never hardcoded anywhere

---

## Backend Security

### HTTPS Only
```python
# FastAPI - enforce HTTPS
from fastapi.middleware.httpsredirect import HTTPSRedirectMiddleware

app.add_middleware(HTTPSRedirectMiddleware)
```

### Authentication Token
```python
# Generate secure token
import secrets
RELAY_SECRET = secrets.token_urlsafe(32)  # Generates: "KJy4..."
```

### Rate Limiting
```python
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter

@app.post("/api/send-message")
@limiter.limit("10/minute")  # Max 10 requests/minute per IP
async def send_message(msg: Message, x_relay_token: str = Header(None)):
    ...
```

### CORS Restrictions
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://yourdomain.com"],  # Specific domain
    allow_credentials=True,
    allow_methods=["POST", "GET"],
    allow_headers=["*"],
)
```

### Input Validation
```python
from pydantic import BaseModel, Field, validator

class Message(BaseModel):
    chat_id: int = Field(..., gt=0)  # Must be positive
    message_text: str = Field(..., min_length=1, max_length=4096)
    from_device: str = Field(..., regex="^(iphone|apple-watch)$")
    
    @validator('message_text')
    def no_null_bytes(cls, v):
        if '\x00' in v:
            raise ValueError('Message contains null bytes')
        return v
```

---

## iOS App Security

### Remove Debug Logs in Production
```swift
// Use conditional compilation
#if DEBUG
print("Debug: \(telegramClient.isConnected)")
#else
// Production: no logging
#endif
```

### Secure Storage
```swift
// Store sensitive data in Keychain, not UserDefaults
// ❌ WRONG:
UserDefaults.standard.set("secret-token", forKey: "relay_secret")

// ✅ RIGHT:
saveToKeychain(key: "relay_secret", value: "secret-token")
```

### Certificate Pinning (Optional but Recommended)
```swift
class PinnedURLSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, 
                   didReceive challenge: URLAuthenticationChallenge,
                   completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Verify SSL certificate matches expected cert
        if let serverTrust = challenge.protectionSpace.serverTrust {
            var secResult = SecTrustResultType.invalid
            SecTrustEvaluate(serverTrust, &secResult)
            if secResult == .unspecified || secResult == .proceed {
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
                return
            }
        }
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}
```

---

## App Store Review Security Checks

**App Store reviewers will check:**

1. ✅ No hardcoded API keys visible in code
2. ✅ HTTPS enforced (no plain HTTP)
3. ✅ Token stored securely (Keychain)
4. ✅ Privacy policy accessible
5. ✅ No collection of unnecessary data
6. ✅ No security vulnerabilities
7. ✅ No ability to bypass security
8. ✅ Proper SSL/TLS usage

**Will cause rejection:**
- ❌ Hardcoded secrets
- ❌ HTTP endpoints (must be HTTPS)
- ❌ Plain text password storage
- ❌ Unencrypted transmission
- ❌ Missing privacy policy
- ❌ Security vulnerabilities (XSS, injection)
- ❌ Bypassing restrictions

---

## Pre-Submission Security Audit

### Code Review
- [ ] No API tokens in code
- [ ] No test credentials
- [ ] No debug endpoints
- [ ] No backdoors
- [ ] No private user data logging
- [ ] Input validation on all endpoints
- [ ] Output encoding on all responses
- [ ] No arbitrary code execution
- [ ] Error messages don't leak info

### Infrastructure
- [ ] HTTPS/TLS 1.3+ on backend
- [ ] Valid SSL certificate (not self-signed)
- [ ] Firewall rules in place
- [ ] Rate limiting enabled
- [ ] DDoS protection (if applicable)
- [ ] Monitoring & alerts active
- [ ] Backups configured
- [ ] Security headers set

### Data Security
- [ ] Encryption in transit (HTTPS)
- [ ] Encryption at rest (if stored)
- [ ] Secure token storage (Keychain on iOS)
- [ ] No logging of sensitive data
- [ ] Data retention policy documented
- [ ] User deletion implemented
- [ ] Export functionality if applicable

---

## Environment Variables Setup

### Development (.env.local)
```bash
TELEGRAM_BOT_TOKEN=dev_bot_token
RELAY_SECRET=dev_secret_key_12345
BACKEND_URL=http://localhost:8000
DEBUG=true
```

### Production (.env.prod)
```bash
TELEGRAM_BOT_TOKEN=[ACTUAL BOT TOKEN]
RELAY_SECRET=[ACTUAL SECRET]
BACKEND_URL=https://api.teleagent.app
DEBUG=false
```

### Never Commit
Add to `.gitignore`:
```
.env
.env.local
.env.prod
.env.*.local
*.key
*.pem
secrets/
```

---

## Telegram Bot Security

### Secure Bot Token
- Generated by @BotFather
- Treat like a password
- Can be revoked if compromised
- Limit bot permissions in BotFather settings
  - Only enable: Send Messages, Edit Messages
  - Disable: Manage group/channel
  - Disable: Delete messages

### Webhook Security (if using webhooks)
```python
# Verify Telegram signature on webhook
import hashlib
import hmac

def verify_telegram_signature(body: bytes, signature: str) -> bool:
    expected_signature = hmac.new(
        TELEGRAM_BOT_TOKEN.encode(),
        body,
        hashlib.sha256
    ).hexdigest()
    return hmac.compare_digest(signature, expected_signature)
```

---

## Summary Checklist

Before submitting to App Store:

- [ ] No hardcoded secrets in code
- [ ] Secrets in environment variables only
- [ ] HTTPS enforced (no HTTP)
- [ ] Tokens stored in Keychain (iOS)
- [ ] Input validation on all endpoints
- [ ] Rate limiting enabled
- [ ] Privacy policy accessible & accurate
- [ ] No unnecessary data collection
- [ ] Error messages don't leak info
- [ ] Code reviewed for vulnerabilities
- [ ] Backend security hardened
- [ ] SSL certificate valid (not self-signed)
- [ ] Security headers set
- [ ] Debug logs removed from production
- [ ] Test data removed

✅ **Only submit after completing all checks!**
