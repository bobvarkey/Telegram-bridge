# Creating Xcode Projects - Step by Step

## iOS App Project Setup

### Step 1: Create iOS Project in Xcode

1. **Open Xcode**
2. File → New → Project (or Cmd+Shift+N)
3. Select **iOS** tab
4. Choose **App** template
5. Click **Next**

### Step 2: Configure Project

Fill in these fields:

| Field | Value |
|-------|-------|
| **Product Name** | `Tele-Agent` |
| **Team** | Select your Apple Developer Team |
| **Organization Identifier** | `com.yourcompany` (e.g., `com.teleagent`) |
| **Bundle Identifier** | Auto-fills: `com.yourcompany.teleagent` |
| **Language** | Swift |
| **Interface** | SwiftUI |
| **Use Core Data** | ❌ (unchecked) |
| **Include Tests** | ✅ (optional) |

Click **Next** → Select folder → **Create**

### Step 3: Add Swift Files

Copy these files from repo into Xcode project:

**In Xcode:**
1. Right-click **Tele-Agent** (project) in navigator
2. Add Files to "Tele-Agent"...
3. Navigate to `ios/TelegramBridge/`
4. Select all `.swift` files:
   - `TelegramBridgeApp.swift` 
   - `TelegramClient.swift`
   - `ContentView.swift`
5. Check: ✅ Copy items if needed
6. Check: ✅ Add to target "Tele-Agent"
7. Click **Add**

### Step 4: Update App Entry Point

Replace content of **TelegramBridgeApp.swift** (Xcode-generated) with:

```swift
import SwiftUI

@main
struct TelegramBridgeApp: App {
    @StateObject private var telegramClient = TelegramClient()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(telegramClient)
        }
    }
}
```

### Step 5: Add App Icon

1. **Assets.xcassets** (in navigator)
2. Click **AppIcon** set
3. Drag 1024×1024 PNG to "App Icon" box (top right)
4. Xcode auto-scales to all sizes ✓

### Step 6: Create Launch Screen

1. File → New → File (Cmd+N)
2. Select **Storyboard**
3. Name: `LaunchScreen`
4. Target: Tele-Agent ✅
5. Click **Create**
6. Design your launch screen (optional, blank is fine)

### Step 7: Configure Info.plist

1. **Tele-Agent** project (in navigator)
2. **Build Settings** tab
3. Search: `launch`
4. Find: **Launch Screen Interface File Base Name**
5. Set value: `LaunchScreen` (no .storyboard)

### Step 8: Add Capabilities

1. **Tele-Agent** project
2. **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add: **App Groups**
   - Check: ✅ Tele-Agent
   - Container: `group.com.yourcompany.teleagent`

### Step 9: Update Info.plist Directly

1. **Tele-Agent** project
2. **Info** tab
3. Add these keys (click + to add):

| Key | Type | Value |
|-----|------|-------|
| `NSLocalNetworkUsageDescription` | String | "Telegram Bridge needs local network for messaging" |
| `NSBonjourServices` | Array | (empty) |
| `NSLocalNetworkUsageDescription` | String | "To communicate with relay server" |

### Step 10: Fix Code Issues

In **TelegramClient.swift**, you may need to update:

```swift
// Change this:
private let backendURL = UserDefaults.standard.string(forKey: "backendURL") ?? "http://localhost:8000"

// To hardcode for now:
private let backendURL = "https://api.yourserver.com"  // Your deployed backend

// Change this:
private let relaySecret = UserDefaults.standard.string(forKey: "relaySecret") ?? "your-secret-key"

// To use Keychain (secure):
private let relaySecret = loadSecureToken() ?? "your-secret-key"

// Add this function:
func loadSecureToken() -> String? {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: "relay_secret",
        kSecReturnData as String: true
    ]
    var result: AnyObject?
    SecItemCopyMatching(query as CFDictionary, &result)
    if let data = result as? Data {
        return String(data: data, encoding: .utf8)
    }
    return nil
}
```

### Step 11: Build & Test

1. Select **iPhone 15 Pro** simulator (top)
2. Product → Build (Cmd+B)
3. Fix any errors
4. Product → Run (Cmd+R) to test
5. Verify app launches without crashes

---

## watchOS Companion App

### Step 1: Add watchOS Target

1. **Tele-Agent** project (in navigator)
2. File → New → Target (Cmd+Shift+N for shortcut)
3. Select **watchOS** tab
4. Choose **App** template
5. Click **Next**

### Step 2: Configure Watch Target

| Field | Value |
|-------|-------|
| **Product Name** | `Tele-Agent Watch` |
| **Team** | Same as iOS app |
| **Organization Identifier** | `com.yourcompany` |
| **Bundle Identifier** | Auto-fills: `com.yourcompany.teleagent.watchkit` |
| **Language** | Swift |
| **Interface** | SwiftUI |

Click **Next** → Embed in "Tele-Agent" → **Create**

### Step 3: Add Watch Swift Files

1. Right-click **Tele-Agent Watch** in navigator
2. Add Files to "Tele-Agent Watch"...
3. Navigate to `watchos/TelegramBridgeWatch/`
4. Select:
   - `WatchClient.swift`
   - `WatchContentView.swift`
5. ✅ Copy items if needed
6. ✅ Add to target "Tele-Agent Watch"
7. Click **Add**

### Step 4: Update Watch App Entry

Replace **TelegramBridgeWatchApp.swift** with:

```swift
import SwiftUI

@main
struct TelegramBridgeWatchApp: App {
    @StateObject private var watchClient = WatchClient()

    var body: some Scene {
        WindowGroup {
            WatchContentView()
                .environmentObject(watchClient)
        }
    }
}
```

### Step 5: Add Watch App Icon

1. **Tele-Agent Watch** target
2. **Build Settings** tab → Search: `app icon`
3. Or: Assets.xcassets → **AppIcon** (watch)
4. Add 1024×1024 PNG
5. Xcode scales automatically ✓

### Step 6: Update Watch Info.plist

1. **Tele-Agent Watch** target
2. **Info** tab
3. Add if missing:

| Key | Type | Value |
|-----|------|-------|
| `WKWatchKitVersion` | String | Latest (auto) |

### Step 7: Build Watch App

1. Scheme selector (top, next to ▶️)
2. Edit Scheme → **Tele-Agent Watch**
3. Product → Build (Cmd+B)
4. Fix any errors

### Step 8: Test Watch Simulator

1. Scheme: **Tele-Agent Watch**
2. Device: **Apple Watch simulator**
3. Product → Run (Cmd+R)
4. Verify watch app launches

---

## Configure Signing

### iOS App

1. **Tele-Agent** project
2. **Signing & Capabilities** tab
3. **Automatically manage signing**: ✅
4. Team: Your Apple Developer Team
5. Bundle Identifier: Verify it matches

### watchOS App

1. **Tele-Agent Watch** target
2. **Signing & Capabilities**
3. **Automatically manage signing**: ✅
4. Team: Same as iOS app
5. Bundle ID: `com.yourcompany.teleagent.watchkit`

---

## Update Backend URL

Before testing, update your backend URL in the code:

### In TelegramClient.swift

```swift
// Change:
private let backendURL = "http://localhost:8000"

// To your deployed URL:
private let backendURL = "https://api.yourserver.com"

// And:
private let relaySecret = "your-secret-key"

// To load from Keychain or environment
```

### In WatchClient.swift

```swift
// Change:
private let backendURL = "http://localhost:8000"

// To:
private let backendURL = "https://api.yourserver.com"
```

---

## Test Both Apps

### Test Flow

1. **Start backend server**
   ```bash
   cd backend
   uvicorn app.main:app --reload
   ```

2. **Run iOS app** (Cmd+R)
   - Should show "🔴 Disconnected"
   - Tap "Connect" button
   - Should show "🟢 Connected"

3. **Run watchOS app** (Cmd+R with watch target)
   - Should also show connected status
   - Test message relay between them

4. **Send test message**
   ```bash
   curl -X POST http://localhost:8000/api/send-message \
     -H "Content-Type: application/json" \
     -H "X-Relay-Token: your_secret_key" \
     -d '{
       "chat_id": 123456,
       "message_text": "Test from iPhone",
       "from_device": "iphone"
     }'
   ```

---

## Fix Common Xcode Issues

### "Cannot find target in scope"
- Delete derived data: Cmd+Shift+K
- Product → Clean Build Folder: Cmd+Shift+Alt+K
- Product → Build: Cmd+B

### "Module not found: CryptoKit"
- **Build Settings** → Search: `import paths`
- Add any missing framework search paths

### SwiftUI previews not working
- Click **Resume** button in canvas
- Or: View → Inspectors → Canvas

### Signing errors
- Product → Clean Build Folder
- Xcode Preferences → Accounts → Re-add Apple ID
- Delete derived data: `~/Library/Developer/Xcode/DerivedData/`

### Port 8000 already in use
- Find process: `lsof -i :8000`
- Kill it: `kill -9 <PID>`
- Or use different port: `--port 8001`

---

## Version Numbers

Before App Store submission, set:

1. **Tele-Agent** project
2. Build Settings (All)
3. Search: `version`

Set these:
- **Marketing Version**: `1.0.0`
- **Current Project Version**: `1`

Same for **Tele-Agent Watch** target.

---

## Next Steps

1. ✅ Create iOS project in Xcode
2. ✅ Add watchOS companion target
3. ✅ Copy Swift files
4. ✅ Add app icons
5. ✅ Update backend URL
6. ✅ Build and test locally
7. → Deploy backend to production
8. → Create App Store Connect listings
9. → Submit for review

**Having issues?** Check Section 8 (Common Issues).
