# Quick Start

## 1 min setup

### Backend
```bash
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# Edit .env with your TELEGRAM_BOT_TOKEN from @BotFather
uvicorn app.main:app --reload
```

### iOS App
- Open `ios/TelegramBridge` in Xcode
- Set signing team
- Build and run

### watchOS App
- Open `watchos/TelegramBridgeWatch` in Xcode
- Set signing team
- Build and run

## Get Telegram Bot Token

1. Open Telegram, find @BotFather
2. `/newbot`
3. Choose name, username
4. Copy token → paste in `.env`

## Verify It Works

Backend running → iPhone connects → Send a test message → Watch receives it

See [DEVELOPMENT.md](DEVELOPMENT.md) for full details.
