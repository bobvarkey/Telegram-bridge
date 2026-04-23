# Telegram Bridge: OpenClaw Edition

Production-ready iOS + watchOS Telegram mirroring app with FastAPI relay backend.

## What's included

- **iOS App** - SwiftUI with message filtering, priority indicators, connection status (`ios/OpenClawBridge`)
- **watchOS App** - Lightweight companion app for Apple Watch (`watchos/OpenClawBridgeWatch`)
- **Shared Models** - Unified `BridgeMessage`, `BridgeFilter`, `MessagePriority` types (`shared/BridgeCore`)
- **Backend** - FastAPI relay server with WebSocket sync and rate limiting (`backend/app/main.py`)
- **App Store Materials** - Metadata and submission copy (`appstore/metadata.md`)
- **Design Assets** - Apple Watch UI mockup (5.2 MB) with OPENCLAW branding (`assets/watchos-ui-openclaw.png`)
- **Documentation** - Complete setup, deployment, and security guides

## Quick start

1. **Install backend dependencies:**
   ```bash
   pip install -r backend/requirements.txt
   ```

2. **Configure environment:**
   ```bash
   cp backend/.env.example backend/.env
   # Edit with your Telegram Bot Token, Relay Secret
   ```

3. **Start FastAPI relay:**
   ```bash
   uvicorn backend.app.main:app --host 0.0.0.0 --port 8000
   ```

4. **Open in Xcode:**
   - Select `OpenClawBridge` target for iPhone
   - Select `OpenClawBridgeWatch` target for Apple Watch
   - Build & run

## Security

✅ CORS hardened (specific origins only)  
✅ Rate limiting enabled (10/minute)  
✅ Keychain token storage  
✅ TLS-only transport  
✅ Input validation & error handling  

See `SECURITY_SETUP.md` for hardening checklist.

## Documentation

- `QUICKSTART.md` - 1-minute setup
- `START_HERE.md` - 4-6 week roadmap
- `XCODE_SETUP.md` - Step-by-step Xcode config
- `APP_STORE_GUIDE.md` - Submission process
- `WATCHOS_UI_DESIGN.md` - Design specification
- `MERGED_ARCHITECTURE.md` - Full system overview

## Preview

View mockup in browser:
```bash
python -m http.server 4173 --directory mockup
# Visit http://localhost:4173
```

Or use Xcode Canvas with `#Preview` blocks in Swift files.

