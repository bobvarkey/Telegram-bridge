# Telegram Bridge Development Guide

## Architecture

```
iPhone (iOS App) <---> Backend Relay <---> Telegram Bot API
                            |
                      Apple Watch (watchOS App)
```

## Setup

### 1. Backend (FastAPI)

**Prerequisites:**
- Python 3.10+
- pip

**Installation:**

```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

**Configuration:**

Create `.env` file:
```bash
cp .env.example .env
```

Add your Telegram bot token:
```
TELEGRAM_BOT_TOKEN=your_bot_token_from_botfather
RELAY_SECRET=your_secure_relay_secret_key
BACKEND_URL=http://localhost:8000
```

**Get Telegram Bot Token:**
1. Message @BotFather on Telegram
2. Send `/newbot`
3. Follow prompts, copy the token

**Run Backend:**
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Backend will be available at `http://localhost:8000`

### 2. iOS App

**Prerequisites:**
- Xcode 15+
- iOS 16+

**Setup:**
1. Open `ios/TelegramBridge` in Xcode
2. Select your development team in Signing & Capabilities
3. Update bundle identifier if needed
4. Build and run on simulator or device

**Xcode Project Structure:**
```
ios/
├── TelegramBridge/
│   ├── TelegramBridgeApp.swift      # App entry point
│   ├── ContentView.swift             # Main UI
│   ├── TelegramClient.swift          # Backend communication
│   └── Assets/                       # Images, colors
```

### 3. watchOS App

**Prerequisites:**
- Xcode 15+
- watchOS 10+

**Setup:**
1. Open `watchos/TelegramBridgeWatch` in Xcode
2. Select your development team
3. Build and run on watch simulator or device

**Features:**
- Compact message display (last 5 messages)
- Quick reply sheet
- Connection status indicator
- Haptic feedback on new messages

## API Endpoints

### WebSocket
**Connect:** `ws://localhost:8000/ws/sync/{device_id}`
- `device_id`: "iphone" or "apple-watch"
- Receives real-time message updates

### HTTP Endpoints

**Send Message**
```
POST /api/send-message
Headers: X-Relay-Token: {RELAY_SECRET}
Body: {
  "chat_id": 123456,
  "message_text": "Hello",
  "from_device": "iphone"
}
```

**Get Messages**
```
GET /api/messages/{chat_id}
Headers: X-Relay-Token: {RELAY_SECRET}
```

**Health Check**
```
GET /health
```

## Communication Flow

1. **iPhone receives message:**
   - WebSocket connection to backend
   - Backend receives from Telegram webhook
   - Relays to both iPhone and Apple Watch

2. **iPhone sends message:**
   - HTTP POST to `/api/send-message`
   - Backend forwards to Telegram via Bot API
   - Acknowledges to Apple Watch

3. **Apple Watch mirrors:**
   - WebSocket to backend
   - Receives all updates from iPhone
   - Compact UI display

## Development Tips

### Logging
Add to `TelegramClient.swift` for debugging:
```swift
print("Message received: \(msg)")
```

### Testing WebSocket
```bash
wscat -c ws://localhost:8000/ws/sync/iphone
```

### Test Message via curl
```bash
curl -X POST http://localhost:8000/api/send-message \
  -H "Content-Type: application/json" \
  -H "X-Relay-Token: your_secret_key" \
  -d '{
    "chat_id": 12345,
    "message_text": "Test",
    "from_device": "test"
  }'
```

## Deployment

### Backend
- Use Gunicorn for production: `gunicorn -w 4 -k uvicorn.workers.UvicornWorker app.main:app`
- Deploy to Heroku, AWS Lambda, or your server
- Update `backendURL` in iOS/watchOS apps

### iOS/watchOS
- Create Apple Developer account
- Add signing certificates
- Build with App Store Connect
- Submit to App Store

## Troubleshooting

**Backend won't start:**
- Check TELEGRAM_BOT_TOKEN is valid
- Ensure port 8000 is available: `lsof -i :8000`

**No messages received:**
- Verify WebSocket connection in Xcode console
- Check backend logs for errors
- Ensure Telegram bot is active

**iPhone/Watch not syncing:**
- Verify both devices connect to same backend
- Check RELAY_SECRET matches
- Confirm WiFi connectivity

## Next Steps

1. Set environment variables properly
2. Get Telegram bot token from @BotFather
3. Start backend server
4. Build iOS app and test message flow
5. Build watchOS app and test mirroring
