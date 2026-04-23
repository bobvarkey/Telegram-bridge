# START HERE - Complete Telegram Bridge Setup

## Your Path to App Store in 4-6 Weeks

### Week 1: Foundation

#### Day 1-2: Get Resources
- [ ] **Apple Developer Account**: developer.apple.com ($99/year)
- [ ] **Telegram Bot Token**: Message @BotFather → `/newbot`
- [ ] **Design App Icon**: 1024×1024 PNG (or use placeholder)
- [ ] **Web Hosting**: Heroku, AWS, DigitalOcean, or own server

#### Day 3-4: Deploy Backend
```bash
# In backend folder
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env

# Edit .env with:
TELEGRAM_BOT_TOKEN=your_bot_token_from_botfather
RELAY_SECRET=generate_a_random_string
```

**Deploy to production** (follow your host's guide):
- Set environment variables
- Deploy FastAPI app
- Test: `curl https://yourserver.com/health`

#### Day 5-7: Create Xcode Projects
Follow **`XCODE_SETUP.md`** exactly:
1. Create iOS app project
2. Add watchOS companion target
3. Copy Swift files into Xcode
4. Add app icons
5. Test builds (no errors)

See: `XCODE_SETUP.md` - Full step-by-step with screenshots

---

### Week 2: Security & Configuration

#### Day 1-2: Security Setup
Follow **`SECURITY_SETUP.md`**:
- [ ] Remove hardcoded secrets
- [ ] Use Keychain for tokens
- [ ] Ensure HTTPS only
- [ ] Add rate limiting
- [ ] Verify input validation

#### Day 3: Update URLs
In Xcode, change:
```swift
// In TelegramClient.swift (iOS)
private let backendURL = "https://yourserver.com"

// In WatchClient.swift (watchOS)
private let backendURL = "https://yourserver.com"
```

#### Day 4-5: Test Locally
```bash
# Terminal 1: Run backend
cd backend
uvicorn app.main:app --reload

# Terminal 2: Build iOS app
# In Xcode: Product → Run
# Should connect and sync messages

# Terminal 3: Build watchOS app
# In Xcode: Switch to Watch target → Run
```

Test message flow:
1. iPhone app connects ✓
2. Watch app connects ✓
3. Send test message via curl ✓
4. Both receive it ✓

#### Day 6-7: TestFlight Beta
```bash
# In Xcode:
1. Product → Archive
2. Window → Organizer
3. Right-click → Distribute App
4. Choose "TestFlight Internal Testing"
5. Add your email as tester
6. Wait 24 hours
7. Test on real device if possible
```

---

### Week 3: App Store Connect

#### Day 1-2: Create App on App Store Connect
1. Sign in: appstoreconnect.apple.com
2. "My Apps" → "+"
3. Fill in:
   - Name: `Tele-Agent`
   - Bundle ID: `com.yourcompany.teleagent`
   - SKU: `TA-001`
   - Platforms: iOS, watchOS
4. Accept agreements → Create

#### Day 3-4: App Metadata
Fill in all fields:

**App Information:**
- Subtitle: "Telegram on your wrist"
- Category: Productivity
- Support URL: https://yoursite.com/support
- Privacy Policy URL: https://yoursite.com/privacy
- Terms URL: https://yoursite.com/terms

**Localization:**
- Name: Tele-Agent
- Subtitle: Telegram on your wrist
- Description: (use from `APP_STORE_GUIDE.md`)
- Keywords: telegram,watch,messaging,sync,encryption

**Version Information:**
- Version Number: 1.0.0
- What's New: "Initial release with real-time sync"

#### Day 5-7: Screenshots & Images
Create 5-6 screenshots:
1. Main message screen
2. Connection status
3. Watch message view
4. Quick reply screen
5. Settings/Info
6. Call to action

Sizes:
- iPhone 6.7": 1284×2778 pixels
- Apple Watch: 368×448 pixels

---

### Week 4: Finalization & Submission

#### Day 1-2: Final Testing
- [ ] Run through TestFlight again
- [ ] Check all links work (support, privacy, terms)
- [ ] Verify no crash logs
- [ ] Test message sync 10 times
- [ ] Check offline handling
- [ ] Verify Telegram integration

#### Day 3-4: Privacy & Legal
- [ ] Privacy Policy published and accessible
- [ ] Terms of Service published and accessible
- [ ] Privacy policy mentions encryption
- [ ] Terms reference Telegram ToS
- [ ] Contact email listed

Create website pages:
```
https://yoursite.com/privacy
https://yoursite.com/terms
https://yoursite.com/support
```

(Can be simple HTML files)

#### Day 5: Pre-Submission Review
- [ ] No hardcoded secrets ✓
- [ ] HTTPS only ✓
- [ ] Keychain for tokens ✓
- [ ] App crashes resolved ✓
- [ ] All links working ✓
- [ ] Privacy policy accessible ✓
- [ ] Terms of service accessible ✓
- [ ] Screenshots professional ✓
- [ ] Version 1.0.0, Build 1 ✓

#### Day 6-7: Submit!

**In Xcode:**
```
Product → Archive
Window → Organizer → Archives
Right-click → Distribute App
Select "App Store Connect"
Select "Upload"
```

**In App Store Connect:**
```
Apps → Tele-Agent
Build → Select your build
Submit for Review
```

**Add review notes:**
```
Tele-Agent is a relay service that mirrors Telegram messages
between iPhone and Apple Watch using official Telegram Bot API.
No test account needed - works with any Telegram account.
Uses end-to-end encryption for all message relay.
```

---

## File Reference

| File | Purpose |
|------|---------|
| `QUICKSTART.md` | 1-min backend setup |
| `DEVELOPMENT.md` | Full development guide |
| `XCODE_SETUP.md` | Create Xcode projects step-by-step |
| `APP_STORE_GUIDE.md` | Full App Store submission guide |
| `APPSTORE_CHECKLIST.md` | Complete submission checklist |
| `SECURITY_SETUP.md` | Security hardening & fixes |
| `legal/PRIVACY_POLICY.md` | Copy and customize |
| `legal/TERMS_OF_SERVICE.md` | Copy and customize |

---

## Timeline at a Glance

```
Week 1: Setup & Deploy
  Day 1-2: Get resources, Telegram bot
  Day 3-4: Deploy backend
  Day 5-7: Create Xcode projects

Week 2: Secure & Test
  Day 1-2: Security setup
  Day 3: Update backend URLs
  Day 4-7: Local testing & TestFlight

Week 3: App Store Setup
  Day 1-2: Create app on App Store Connect
  Day 3-4: Add metadata & screenshots
  Day 5-7: Legal documents

Week 4: Submit!
  Day 1-2: Final testing
  Day 3-4: Privacy & legal review
  Day 5-7: Submit & wait (24-48 hours)
```

---

## Critical Reminders ⚠️

### Before You Start
1. ✅ **Get Apple Developer Account** - $99/year
2. ✅ **Get Telegram Bot Token** - From @BotFather
3. ✅ **Have a server ready** - For backend deployment

### During Development
1. ✅ **No hardcoded secrets** - Use environment variables
2. ✅ **HTTPS only** - HTTP will be rejected
3. ✅ **Test thoroughly** - Local, TestFlight, real device
4. ✅ **Follow guidelines** - App Store will reject violations

### Before Submission
1. ✅ **Privacy policy accessible** - Must be at public URL
2. ✅ **No API keys in code** - Binary will be inspected
3. ✅ **No crash logs** - Xcode Organizer should be empty
4. ✅ **All links work** - Support, privacy, terms

---

## Support & Troubleshooting

### Backend Issues
- See: `DEVELOPMENT.md` → Troubleshooting
- Check logs: `backend/` console output

### Xcode Issues
- See: `XCODE_SETUP.md` → Fix Common Issues
- Common: Clean build folder (Cmd+Shift+Alt+K)

### App Store Issues
- See: `APP_STORE_GUIDE.md` → Common Issues
- Common: Missing privacy policy

### Security Issues
- See: `SECURITY_SETUP.md` → Pre-Submission Audit
- All checks must pass before submitting

---

## Next Step: Choose Your Path

### Option A: Follow Week-by-Week (Recommended)
- Most reliable
- Best for learning
- Follow `START_HERE.md` (this file)
- Each week has clear tasks

### Option B: Go Faster (If Experienced)
- Skip to relevant sections
- Use checklists as reference
- Self-manage timeline

### Option C: Get Help
- Check specific guide for your issue
- Search filenames above for topic
- Review `DEVELOPMENT.md` troubleshooting

---

## Final Checklist Before Submission

- [ ] **Backend live** at HTTPS URL
- [ ] **iOS app** builds without errors
- [ ] **watchOS app** builds without errors
- [ ] **Message sync** works end-to-end
- [ ] **TestFlight** tested for 48+ hours
- [ ] **App Store Connect** all fields filled
- [ ] **Screenshots** high quality, 6+
- [ ] **Privacy policy** at public URL
- [ ] **Terms of service** at public URL
- [ ] **No crash logs** in Xcode Organizer
- [ ] **No hardcoded secrets** anywhere
- [ ] **Version 1.0.0, Build 1** set
- [ ] **Icons & launch screen** added
- [ ] **Signing team** set correctly
- [ ] **Reviewed App Store guidelines**

✅ **Completed everything?** → Submit for Review!

---

## Need Help?

1. **Setup questions?** → Check `XCODE_SETUP.md`
2. **Backend issues?** → Check `DEVELOPMENT.md`
3. **Security concerns?** → Check `SECURITY_SETUP.md`
4. **App Store questions?** → Check `APP_STORE_GUIDE.md`
5. **Something else?** → Check relevant file above

**Good luck! 🚀**

Questions about these instructions?
See the specific guide for that topic.
