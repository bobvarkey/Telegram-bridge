# OpenClaw Bridge

OpenClaw Bridge is a starter architecture for an iOS + watchOS Telegram mirroring app with an optional lightweight backend.

## What is included

- App Store-ready product copy and metadata (`appstore/metadata.md`)
- iOS SwiftUI app skeleton (`ios/OpenClawBridge`)
- watchOS SwiftUI companion skeleton (`watch/OpenClawBridgeWatch`)
- Shared bridge/domain models (`shared/BridgeCore`)
- Optional Python Telegram relay starter (`backend/bot_listener.py`)
- Asset placement instructions for the provided OpenClaw logo (`assets/README.md`)

## Quick start

1. Create a new Xcode iOS + watchOS project named **OpenClawBridge**.
2. Copy the Swift files from this repository into your iOS and watchOS targets.
3. Add your Telegram credentials in app settings or secure keychain flow.
4. If you need server-side bridging, run the Python bot listener in `backend/`.

## Security notes

- Store Telegram tokens in Keychain / secure enclave-backed storage.
- Avoid long-term message persistence unless explicitly enabled by the user.
- Use TLS-only transport and signed requests for relay endpoints.

## Status

This is a clean scaffold intended to accelerate implementation and App Store packaging.
## Preview

Use `PREVIEW.md` plus SwiftUI `#Preview` blocks in iOS/watch files to inspect the UI quickly in Xcode Canvas.
## Local browser mockup

Run a local static server and open the mockup in your browser:

```bash
python -m http.server 4173 --directory mockup
```

Then visit `http://localhost:4173`.

