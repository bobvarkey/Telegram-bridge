# App Store Submission Checklist

## Phase 1: Preparation (Week 1-2)

### Account Setup
- [ ] Create Apple Developer Account ($99/year)
- [ ] Verify email and payment method
- [ ] Enroll in Apple Developer Program
- [ ] Complete legal agreements

### Get Resources
- [ ] Design app icon (1024×1024 PNG)
- [ ] Create 5-6 screenshots (iPhone 6.7" & Watch)
- [ ] Write app description (4000 chars max)
- [ ] Write privacy policy
- [ ] Write terms of service
- [ ] Get bot token from @BotFather (Telegram)

### Development
- [ ] Build backend with FastAPI
- [ ] Test backend locally
- [ ] Build iOS app in Xcode
- [ ] Build watchOS companion app
- [ ] Test on iPhone simulator (multiple sizes)
- [ ] Test on Watch simulator

## Phase 2: Project Setup (Week 2)

### Xcode iOS Project
- [ ] Create new iOS app project in Xcode
- [ ] Set bundle ID: `com.yourcompany.teleagent`
- [ ] Set team ID to your developer account
- [ ] Copy Swift files from `ios/TelegramBridge/`
- [ ] Add app icon to Assets.xcassets
- [ ] Create LaunchScreen.storyboard
- [ ] Add App Groups capability
- [ ] Fix any build errors

### Xcode watchOS Companion
- [ ] Create watchOS target in same project
- [ ] Copy watchOS Swift files
- [ ] Set watch app icon
- [ ] Link to iOS app
- [ ] Fix build errors

### Test Builds
- [ ] Build for iOS (no errors/warnings)
- [ ] Build for watchOS (no errors/warnings)
- [ ] Test on iPhone 15 Pro simulator
- [ ] Test on iPhone 16 Pro Max simulator
- [ ] Test on Apple Watch simulator
- [ ] Verify message relay works

## Phase 3: Backend Deployment (Week 2)

### Choose Hosting
- [ ] Heroku OR
- [ ] AWS Lambda OR
- [ ] DigitalOcean OR
- [ ] Your own server

### Deploy Backend
- [ ] Set up secure HTTPS endpoint
- [ ] Configure `.env` with production secrets
- [ ] Test API endpoints with curl
- [ ] Verify WebSocket connections work
- [ ] Set up rate limiting
- [ ] Enable error logging
- [ ] Get SSL certificate

### Configure App
- [ ] Update `backendURL` in iOS app to production
- [ ] Update `backendURL` in watchOS app
- [ ] Remove hardcoded test secrets
- [ ] Use secure token storage (Keychain)

## Phase 4: App Store Connect Setup (Week 3)

### Create App
- [ ] Go to appstoreconnect.apple.com
- [ ] Sign in with Apple ID
- [ ] Create new app
- [ ] Set app name: "Tele-Agent"
- [ ] Set bundle ID (must match Xcode)
- [ ] Select iOS & watchOS platforms
- [ ] Create SKU: `TA-001` (unique)

### Fill App Information
- [ ] Primary category: Productivity
- [ ] Secondary category: Utilities
- [ ] Support URL: `https://yoursite.com/support`
- [ ] Privacy policy URL: `https://yoursite.com/privacy`
- [ ] Add contact email
- [ ] Describe data collection if needed

## Phase 5: App Content (Week 3)

### Screenshots
- [ ] 5-6 high-quality screenshots
- [ ] iPhone 6.7" (1284×2778)
- [ ] Highlight key features
- [ ] Show message syncing
- [ ] Show Watch interface
- [ ] Add descriptive captions
- [ ] 2 characters for title max
- [ ] Add Watch screenshots (368×448)

### Metadata
- [ ] App name: "Tele-Agent" (max 30 chars)
- [ ] Subtitle: "Telegram on your wrist" (max 30 chars)
- [ ] Promotional text: Feature summary (max 170 chars)
- [ ] Description: Full feature list (max 4000 chars)
- [ ] Keywords: telegram,watch,messaging,sync (max 100 chars)
- [ ] Support URL: Support page link
- [ ] Privacy policy: Legal/privacy-policy page

### Release Notes
```
Version 1.0.0 - First Release
• Real-time message mirroring between iPhone and Apple Watch
• Secure end-to-end encrypted relay
• Quick reply options from your wrist
• Smart notification filtering
• Haptic feedback for new messages
```

## Phase 6: Compliance & Testing (Week 3-4)

### Privacy & Legal
- [ ] Privacy policy accessible at URL
- [ ] Terms of service written
- [ ] Privacy policy includes:
  - [ ] Data collection explanation
  - [ ] How data is used
  - [ ] Data retention period
  - [ ] User rights (access, deletion)
  - [ ] Third-party services (Telegram)
  - [ ] Contact information
- [ ] Mention encryption in policy
- [ ] No sensitive data stored

### Build & Signing
- [ ] Update version number: 1.0.0
- [ ] Update build number: 1
- [ ] Set signing team to your account
- [ ] Enable automatic signing
- [ ] Add necessary capabilities:
  - [ ] App Groups
  - [ ] Network (if needed)
  - [ ] Keychain (for secure token storage)
- [ ] Build archive (Product → Archive)

### TestFlight (Recommended)
- [ ] Create archive in Xcode
- [ ] Distribute app → TestFlight
- [ ] Add internal testers (your Apple ID)
- [ ] Test for 48 hours minimum
- [ ] Fix any crash logs
- [ ] Verify all features work
- [ ] Optionally: External testers (if help testing)

## Phase 7: Final Review (Week 4)

### Before Submitting
- [ ] No hardcoded API keys in code
- [ ] No test/dummy data
- [ ] No placeholder text
- [ ] HTTPS only (no HTTP)
- [ ] No ads or in-app purchases
- [ ] Complies with Telegram ToS
- [ ] No inappropriate content
- [ ] No spam features
- [ ] Help text is clear
- [ ] Error messages are user-friendly

### Documentation
- [ ] API endpoints documented
- [ ] Data flow explained
- [ ] Encryption method mentioned
- [ ] Retention period specified
- [ ] User controls described (opt-outs, etc.)

### Security Review
- [ ] No passwords hardcoded
- [ ] Secrets in environment variables only
- [ ] HTTPS/TLS 1.3+ enforced
- [ ] Tokens stored in Keychain (iOS)
- [ ] No logs containing PII
- [ ] Rate limiting enabled
- [ ] Input validation implemented
- [ ] No arbitrary code execution

## Phase 8: App Store Submission (Week 4)

### Prepare Build
- [ ] Final version number: 1.0.0
- [ ] Final build number: 1
- [ ] Clean build folder: Cmd+Shift+K
- [ ] Build archive: Product → Archive
- [ ] Window → Organizer → Archives

### Submit Build
- [ ] Select build from Organizer
- [ ] Click "Distribute App"
- [ ] Choose "App Store Connect"
- [ ] Select "Upload"
- [ ] Sign with distribution certificate
- [ ] Wait for upload completion (~5 mins)
- [ ] Go to App Store Connect
- [ ] Select build for submission

### Submit for Review
- [ ] Fill Phased Release (optional)
  - [ ] Start small rollout (1%) OR Full release
- [ ] Select export compliance (if needed)
- [ ] Indicate encryption usage (yes)
- [ ] Confirm category accuracy
- [ ] Add custom review notes if needed:
  ```
  Tele-Agent is a relay service for Telegram messages
  between iPhone and Apple Watch. Uses official
  Telegram Bot API with end-to-end encryption.
  Test account not needed - works with any Telegram
  account.
  ```
- [ ] Click "Submit for Review"

## Phase 9: App Review (Week 4-5)

### Wait Period
- Typical: 24-48 hours
- Can be up to 1 week
- Longer during high volume

### Monitor Status
- [ ] Check App Store Connect daily
- [ ] Status changes: In Review → Approved/Rejected
- [ ] Review notifications sent via email

### If Approved
- [ ] App goes to TestFlight first
- [ ] Then available in App Store
- [ ] Send launch announcement
- [ ] Monitor crash logs
- [ ] Respond to user reviews

### If Rejected
- [ ] Read rejection reason carefully
- [ ] Note specific violations
- [ ] Fix issues in code
- [ ] Submit new build
- [ ] Resubmit for review

## Phase 10: Post-Launch (Ongoing)

### First Week
- [ ] Monitor App Store Connect
- [ ] Check crash logs in Xcode Organizer
- [ ] Read user reviews
- [ ] Respond to critical issues
- [ ] Track download numbers
- [ ] Monitor ratings

### First Month
- [ ] Fix critical bugs (submit update)
- [ ] Respond to reviews
- [ ] Track analytics
- [ ] Plan v1.1 improvements
- [ ] Gather user feedback

### Ongoing
- [ ] Release updates quarterly
- [ ] Keep privacy policy current
- [ ] Maintain backend reliability
- [ ] Monitor for security issues
- [ ] Stay compliant with Apple guidelines

## Timeline Summary

| Phase | Duration | Key Dates |
|-------|----------|-----------|
| Preparation | 1-2 weeks | Week 1-2 |
| Project Setup | 1 week | Week 2 |
| Backend Deploy | 1 week | Week 2 |
| App Store Connect | 1 week | Week 3 |
| Testing & Compliance | 1-2 weeks | Week 3-4 |
| Submission | 1 day | Week 4 |
| Review | 1-7 days | Week 4-5 |
| **Total** | **4-6 weeks** | |

## Estimated Costs

- Apple Developer Account: $99/year
- Backend hosting: $10-100/month (depends)
- Domain name: $10-15/year
- SSL certificate: Free (Let's Encrypt) or $0-200/year
- **First year total: ~$300-400**

## Key Contacts & Links

- **App Store Connect**: https://appstoreconnect.apple.com
- **Apple Developer**: https://developer.apple.com
- **App Store Review Guidelines**: https://developer.apple.com/app-store/review/guidelines/
- **Your Privacy Policy**: https://yoursite.com/privacy
- **Your Support Email**: support@teleagent.app
- **Your Backend URL**: https://api.teleagent.app

---

✅ **Complete this checklist to submit your app!**

Questions? See `APP_STORE_GUIDE.md` for detailed instructions.
