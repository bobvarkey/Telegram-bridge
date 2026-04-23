# Tele-Agent: Telegram Bridge for Apple Watch

Mirror your Telegram messages between iPhone and Apple Watch in real-time with end-to-end encryption.

## Quick Links

**🚀 Getting Started:**
- **[START HERE](START_HERE.md)** ← Begin here! 4-6 week roadmap to App Store
- **[QUICKSTART](QUICKSTART.md)** - 1 minute backend setup
- **[DEVELOPMENT](DEVELOPMENT.md)** - Full development guide

**📱 Building the App:**
- **[XCODE_SETUP](XCODE_SETUP.md)** - Create Xcode projects step-by-step
- **[APP_STORE_GUIDE](APP_STORE_GUIDE.md)** - Complete App Store submission guide
- **[APPSTORE_CHECKLIST](APPSTORE_CHECKLIST.md)** - Submit checklist (detailed)

**🔒 Security:**
- **[SECURITY_SETUP](SECURITY_SETUP.md)** - Harden security before App Store

**📋 Legal:**
- **[Privacy Policy](legal/PRIVACY_POLICY.md)** - Copy & customize
- **[Terms of Service](legal/TERMS_OF_SERVICE.md)** - Copy & customize

**🎨 Design:**
- **[WATCHOS_UI_DESIGN](WATCHOS_UI_DESIGN.md)** - Complete watchOS UI specification with design assets
- **[APP_SUBMISSION_PACKAGE](APP_SUBMISSION_PACKAGE.md)** - Full app store submission guide
- **[CODE_QUALITY_CHECKLIST](CODE_QUALITY_CHECKLIST.md)** - Security & code quality audit
- **[SINKING_SHIP_CHECKLIST](SINKING_SHIP_CHECKLIST.md)** - Pre-launch verification checklist

---

## 🎨 Design Preview

![Tele-Agent Apple Watch UI - OPENCLAW Design](./assets/watchos-ui-openclaw.png)

**Features Shown:**
- Sage green sport band with space gray case
- Real-time message synchronization indicator
- 3D robot mascot character
- Connection status (OPEN/CLOSED)
- Message count and battery indicators
- Intuitive navigation ring interface

---

## What's Included

### Backend (Python/FastAPI)
```
backend/
├── app/main.py           # FastAPI relay server
├── requirements.txt      # Python dependencies
└── .env.example         # Configuration template
```

**Features:**
- WebSocket relay for real-time sync
- REST API for message sending
- Telegram Bot integration
- End-to-end encryption support

### iOS App (Swift/SwiftUI)
```
ios/TelegramBridge/
├── TelegramBridgeApp.swift    # App entry point
├── ContentView.swift           # Main UI
└── TelegramClient.swift        # Backend communication
```

**Features:**
- Real-time message display
- Connection status indicator
- Send messages to Telegram
- Sync with Apple Watch

### watchOS App (Swift/SwiftUI)
```
watchos/TelegramBridgeWatch/
├── TelegramBridgeWatchApp.swift  # Watch app entry
├── WatchContentView.swift         # Compact UI
└── WatchClient.swift              # Relay communication
```

**Features:**
- Compact message display (last 5)
- Quick reply sheet
- Connection status
- Haptic feedback

---

## Architecture

```
iPhone (iOS)
    ↓ (WebSocket + REST)
Backend Relay Server
    ↑ ↓ (Telegram Bot API)
Telegram            Apple Watch (watchOS)
    ↑ (WebSocket)
```

---

## 30-Second Overview

1. **Your Telegram account** sends messages to backend
2. **Backend relay** receives and encrypts them
3. **iPhone** displays messages in real-time
4. **Apple Watch** mirrors them with sync
5. **Replies** from either device sent back via Telegram

---

## Requirements

### To Develop
- macOS 12+ with Xcode 15+
- Python 3.10+
- Apple Developer Account ($99/year)

### To Deploy
- Linux/Mac/Windows server with Python 3.10+
- HTTPS domain (required for App Store)
- Telegram Bot (free from @BotFather)

### To Submit to App Store
- All of above, plus:
- App icons (1024×1024 PNG)
- Screenshots (5-6 images)
- Privacy policy URL
- Terms of service URL

---

## Getting Started (Quick Path)

### Week 1-2: Backend
```bash
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# Add TELEGRAM_BOT_TOKEN and deploy to production
uvicorn app.main:app --reload
```

### Week 2-3: iOS & watchOS
1. Open Xcode
2. File → New → Project
3. Follow **[XCODE_SETUP.md](XCODE_SETUP.md)**
4. Copy Swift files into Xcode
5. Build and test

### Week 4: App Store
1. Create Apple Developer Account
2. Follow **[APP_STORE_GUIDE.md](APP_STORE_GUIDE.md)**
3. Submit build to TestFlight
4. Submit for App Store review

**Full timeline:** See **[START_HERE.md](START_HERE.md)**

---

## API Endpoints

### WebSocket
- **Connect**: `ws://localhost:8000/ws/sync/{device_id}`
- Send/receive messages in real-time
- Devices: `iphone`, `apple-watch`

### REST API
- **POST** `/api/send-message` - Send to Telegram
- **GET** `/api/messages/{chat_id}` - Get messages
- **GET** `/health` - Health check

### Webhooks
- **POST** `/webhook/telegram` - Receive from Telegram

See **[DEVELOPMENT.md](DEVELOPMENT.md)** for full API docs.

---

## Security Features

✅ **End-to-End Encryption** - AES-256 in transit  
✅ **Secure Token Storage** - Keychain on iOS/watchOS  
✅ **HTTPS Only** - No plaintext transmission  
✅ **Rate Limiting** - Prevent abuse  
✅ **Input Validation** - Sanitize all inputs  
✅ **Token Isolation** - No secret leaks  

See **[SECURITY_SETUP.md](SECURITY_SETUP.md)** for hardening guide.

---

## Troubleshooting

### Backend Won't Start
- Check `TELEGRAM_BOT_TOKEN` is valid
- Ensure port 8000 is available
- See **[DEVELOPMENT.md](DEVELOPMENT.md)** → Troubleshooting

### Xcode Build Fails
- Clean build folder: Cmd+Shift+Alt+K
- Delete derived data: `~/Library/Developer/Xcode/DerivedData/`
- See **[XCODE_SETUP.md](XCODE_SETUP.md)** → Fix Common Issues

### App Not Connecting
- Check backend is running
- Verify HTTPS URL in app code
- Check firewall allows WebSocket
- See **[DEVELOPMENT.md](DEVELOPMENT.md)** → Testing

### App Store Rejection
- Check privacy policy is accessible
- Remove all hardcoded secrets
- Verify HTTPS on backend
- See **[APP_STORE_GUIDE.md](APP_STORE_GUIDE.md)** → Common Rejections

---

## Support Resources

| Issue | See |
|-------|-----|
| How do I get started? | **[START_HERE.md](START_HERE.md)** |
| How do I deploy the backend? | **[DEVELOPMENT.md](DEVELOPMENT.md)** |
| How do I create Xcode projects? | **[XCODE_SETUP.md](XCODE_SETUP.md)** |
| How do I submit to App Store? | **[APP_STORE_GUIDE.md](APP_STORE_GUIDE.md)** |
| How do I make it secure? | **[SECURITY_SETUP.md](SECURITY_SETUP.md)** |
| What's my checklist before submitting? | **[APPSTORE_CHECKLIST.md](APPSTORE_CHECKLIST.md)** |
| What should my privacy policy say? | **[legal/PRIVACY_POLICY.md](legal/PRIVACY_POLICY.md)** |
| What should my terms say? | **[legal/TERMS_OF_SERVICE.md](legal/TERMS_OF_SERVICE.md)** |

---

## File Structure

```
Telegram-bridge/
├── README.md                        # This file
├── START_HERE.md                    # 4-6 week roadmap ← START HERE
├── QUICKSTART.md                    # 1 min setup
├── DEVELOPMENT.md                   # Full guide
├── XCODE_SETUP.md                   # Create projects
├── APP_STORE_GUIDE.md              # App Store submission
├── APPSTORE_CHECKLIST.md           # Detailed checklist
├── SECURITY_SETUP.md               # Security hardening
│
├── backend/
│   ├── app/
│   │   └── main.py                 # FastAPI relay server
│   ├── requirements.txt            # Dependencies
│   └── .env.example                # Config template
│
├── ios/
│   └── TelegramBridge/
│       ├── TelegramBridgeApp.swift
│       ├── ContentView.swift
│       └── TelegramClient.swift
│
├── watchos/
│   └── TelegramBridgeWatch/
│       ├── TelegramBridgeWatchApp.swift
│       ├── WatchContentView.swift
│       └── WatchClient.swift
│
├── legal/
│   ├── PRIVACY_POLICY.md          # Copy & customize
│   └── TERMS_OF_SERVICE.md        # Copy & customize
│
├── index.html                      # Marketing landing page
└── style.css                       # Landing page styles
```

---

## Next Steps

### 🚀 Ready to start?
1. **[Read START_HERE.md](START_HERE.md)** (5 mins)
2. Follow Week 1 tasks
3. Build, test, submit!

### 🤔 Have questions?
- Check the relevant guide above
- All documentation is self-contained
- No external dependencies needed

### ✅ Already familiar?
- Jump to **[APPSTORE_CHECKLIST.md](APPSTORE_CHECKLIST.md)**
- Or **[XCODE_SETUP.md](XCODE_SETUP.md)**
- Or specific section you need

---

## Legal

This project includes template privacy policy and terms of service. **You must customize these with your company information before submitting to App Store.**

- **Privacy Policy**: [legal/PRIVACY_POLICY.md](legal/PRIVACY_POLICY.md)
- **Terms of Service**: [legal/TERMS_OF_SERVICE.md](legal/TERMS_OF_SERVICE.md)

**Important:** Your privacy policy must be accessible at a public URL for App Store approval.

---

## License & Attribution

Tele-Agent is configured for App Store submission.

- Uses official **Telegram Bot API**
- Complies with **App Store Guidelines**
- Follows **GDPR** and **CCPA** best practices
- Includes **end-to-end encryption**

---

## FAQ

**Q: Do I need a Telegram premium account?**  
A: No, works with any Telegram account using our Telegram Bot.

**Q: Is my data safe?**  
A: Yes! End-to-end encryption (AES-256), secure token storage, HTTPS only.

**Q: Can I use this commercially?**  
A: Yes! Customize privacy policy and terms of service for your company.

**Q: How much does it cost?**  
A: Apple Developer Account ($99/year) + server hosting ($10-100/month).

**Q: How long to App Store?**  
A: 4-6 weeks if you follow the guides and stay on schedule.

**Q: Will it be rejected?**  
A: Not if you follow [SECURITY_SETUP.md](SECURITY_SETUP.md) and include proper privacy policy.

---

## Support

- **Questions?** See the guide for your topic above
- **Issues?** Check [DEVELOPMENT.md](DEVELOPMENT.md) → Troubleshooting
- **Stuck?** Review [START_HERE.md](START_HERE.md) for your current week

---

**Ready to build? [Start here →](START_HERE.md)**

---

*Last Updated: April 2025*  
*Tele-Agent v1.0 - Ready for App Store*
