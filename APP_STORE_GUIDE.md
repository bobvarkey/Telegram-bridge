# App Store Submission Guide

## Prerequisites

- **Apple Developer Account**: $99/year at developer.apple.com
- **Xcode 15+** with iOS & watchOS SDKs
- **Mac with Apple Silicon or Intel** for code signing
- **iPhone & Apple Watch** (for testing, or use simulators)

## Step 1: Create Xcode Projects

Since we have Swift files but need full projects, create them in Xcode:

### iOS Project
1. Xcode → File → New → Project
2. iOS → App template
3. Product Name: `Tele-Agent`
4. Team: Your Apple Developer Team
5. Organization Identifier: `com.yourcompany` (e.g., `com.teleagent`)
6. Bundle ID: `com.yourcompany.teleagent`
7. Language: Swift
8. Use SwiftUI
9. Copy the Swift files from `ios/TelegramBridge/` into the project

### watchOS Project (Companion)
1. Xcode → File → New → Target
2. watchOS → App template
3. Product Name: `Tele-Agent Watch`
4. Copy watchOS Swift files into new target

## Step 2: Configure App Icons & Launch Screens

### App Icons
1. Assets.xcassets → AppIcon
2. Add 1024×1024 image (Xcode auto-scales)
3. For watchOS: WatchKit App Icon (1024×1024)

### Launch Screen (iOS)
1. File → New → LaunchScreen.storyboard
2. Design your launch screen
3. In Build Settings, set "Launch Screen Interface File Base Name" to LaunchScreen

### Watch App Icon
- watchOS 10+: Uses app icon directly
- Xcode handles 1024×1024 auto-scaling

## Step 3: App Store Connect Setup

1. Go to **appstoreconnect.apple.com**
2. Click **"My Apps"** → **"+"** → **New App**
3. Fill in:
   - **Platform**: iOS
   - **Name**: Tele-Agent
   - **Primary Language**: English
   - **Bundle ID**: `com.yourcompany.teleagent`
   - **SKU**: `TA-001` (unique identifier)

4. Accept agreements and create app

## Step 4: App Information

In App Store Connect → **App Information**, fill:

- **Subtitle**: "Telegram on your wrist"
- **Category**: Productivity / Utilities
- **Privacy Policy URL**: Add your privacy policy
- **Support URL**: Your support website
- **Demo Account**: Not needed

## Step 5: Create Privacy Policy & Terms

Add to your backend or static site:

**Privacy Policy** must include:
- Data collection (messages, device info)
- Data usage (relay purposes only)
- Data retention (how long kept)
- User rights (deletion, export)
- Third parties (Telegram API usage)

**Terms of Service** must cover:
- License grant
- User responsibilities
- Limitation of liability
- Changes to service

Example structure:
```
https://yoursite.com/privacy
https://yoursite.com/terms
```

## Step 6: Screenshots & Descriptions

In App Store Connect → **Screenshots**:

1. **5-6 screenshots** showing:
   - Main messaging screen
   - Connection status
   - Message history
   - Quick reply (watch)
   - Settings

2. **First 2 Characters** of name limit in title
3. Include **key features** in description

Screenshot sizes:
- **iPhone 6.7"**: 1284×2778 pixels
- **iPhone 5.5"**: 1242×2208 pixels
- **iPad 12.9"**: 2048×2732 pixels
- **Apple Watch**: 368×448 pixels

## Step 7: App Metadata

Fill these fields:
- **Name**: Tele-Agent (30 chars)
- **Subtitle**: Telegram on your wrist (30 chars)
- **Promotional Text**: "Real-time message sync between iPhone & Apple Watch"
- **Description**: 4000 chars max
- **Keywords**: telegram, watch, messaging, notifications, sync, secure

## Step 8: Release Notes

```
Version 1.0.0 - Initial Release
- Real-time message mirroring
- Secure encrypted relay
- Quick reply from Apple Watch
- Smart message filtering
```

## Step 9: Signing & Capabilities

### In Xcode:

1. **Signing & Capabilities**
2. Select your **Team**
3. Automatically manage signing ✓
4. Capability: **App Groups** (for iPhone-Watch sharing)
5. Capability: **Network Extension** (if using VPN)

### Watch Companion Requirements:
- Add watchOS companion app target
- Link to main iOS app
- Same team ID required

## Step 10: Build & Archive

```bash
# In Xcode:
1. Select "iOS Device" (not simulator)
2. Product → Scheme → Select "Tele-Agent"
3. Product → Archive
4. Window → Organizer → Archives
5. Right-click archive → Distribute App
```

## Step 11: TestFlight (Beta Testing)

**Recommended before App Store submission:**

1. Create archive
2. Distribute → TestFlight (Internal Testing)
3. Add internal testers (Apple ID emails)
4. Run for **minimum 48 hours**
5. Get feedback, fix issues

External TestFlight:
- Add external testers
- Submit for review (24-48 hours)
- Share TestFlight link

## Step 12: App Review

**Before Submitting:**
- [ ] All required fields filled
- [ ] Screenshots added
- [ ] Privacy policy linked
- [ ] Terms of service linked
- [ ] App tested thoroughly
- [ ] No hardcoded API keys/tokens
- [ ] Uses official Telegram Bot API
- [ ] Explicit user consent for message access

**App Review Guidelines:**
- Read: developer.apple.com/app-store/review/guidelines/
- Common rejections:
  - Missing privacy policy
  - App crashes on launch
  - Unclear functionality
  - Security issues
  - Spam/scam detection

**Submit for Review:**
1. App Store Connect → Build
2. Select build for submission
3. Add phased release preference (optional)
4. Submit for Review

**Review Timeline:**
- Typical: 24-48 hours
- Can take up to 1 week
- Rejections require resubmission

## Step 13: Release & Updates

Once approved:
- **Phased Release**: Roll out 1%, 5%, 10%, 50%, 100% over time
- **Immediate Release**: Push to all users at once
- Monitor crash logs in Xcode Organizer

## Important: Backend Requirements

**For App Store:**
1. Your backend must be **secure** (HTTPS only)
2. Use **authentication tokens** (not hardcoded)
3. Implement **rate limiting**
4. Add **error handling**
5. Log suspicious activity

**Environment Variables:**
```
TELEGRAM_BOT_TOKEN=xxx (not in app binary)
RELAY_SECRET=xxx (not in app binary)
BACKEND_URL=https://api.teleagent.app
```

Store secrets in secure configuration:
- Use App Store Connect environment variables
- Or secure backend endpoint for auth

## Checklist Before Submission

- [ ] Xcode project builds without errors
- [ ] No warnings in build
- [ ] Tested on iPhone simulator (multiple sizes)
- [ ] Tested on Apple Watch simulator
- [ ] Privacy policy live and accessible
- [ ] Support contact email valid
- [ ] Screenshots meet size requirements
- [ ] App icon (1024×1024) added
- [ ] Launch screen created
- [ ] Backend API documented
- [ ] Error handling implemented
- [ ] Crash logs reviewed
- [ ] TestFlight beta passed

## Common Issues & Fixes

| Issue | Fix |
|-------|-----|
| App crashes on launch | Check NSLocalizedFailureReason in logs |
| Missing privacy policy | Add link to https://yoursite.com/privacy |
| Signing issues | Check team ID matches |
| Build fails | Update Xcode, clean build folder |
| Rejected for security | Remove hardcoded secrets, use secure tokens |

## Post-Launch Support

1. Monitor **Crash Logs** in Xcode Organizer
2. Read **Customer Reviews** in App Store Connect
3. Plan **Updates** for bug fixes & features
4. Maintain **Privacy Policy** accuracy

## Resources

- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Xcode Documentation](https://developer.apple.com/documentation/xcode/)
- [Swift UI Documentation](https://developer.apple.com/tutorials/SwiftUI/)

Next: Create your Apple Developer account and Xcode projects.
