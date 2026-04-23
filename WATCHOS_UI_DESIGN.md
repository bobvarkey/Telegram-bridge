# Tele-Agent: Apple Watch UI Design Reference

## OpenClaw Watch Interface Concept

![Apple Watch UI - OpenClaw Design](./assets/watchos-ui-openclaw.png)

**Design Reference:** Apple Watch with custom watchOS app interface - OPENCLAW Edition

### Design Elements

#### Visual Layout
- **Device**: Apple Watch (Series 8 or later)
- **Band Color**: Sage green sport band
- **Case**: Space gray aluminum
- **Screen**: Always-on Retina display

#### User Interface Components

**App Title**
- "OPENCLAW" header with cyan accent line
- Clean, modern sans-serif typography
- Positioned at top of display

**Status Indicator**
- Message count: "2/3" (upper left)
- Battery indicator: "0%" icon (upper right)
- Large cyan icon for notifications

**Central Element**
- 3D-rendered red robot/character mascot
- Represents active connection/status
- Mechanical arms in operational position
- Glowing cyan eyes indicating active state
- Spherical red body with sleek design

**Status Bar**
- "STATUS: OPEN" in large text
- Cyan text for active state
- Timestamp: "10:09 AM"
- Positioned at bottom of display

**Navigation Ring**
- Circular progress indicator around edges
- Four cardinal direction buttons (customizable)
- Left/right swipe for navigation
- Bottom button for actions

#### Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| Sage Green | #9CA385 | Watch band |
| Space Gray | #6B6B6D | Watch case |
| White/Off-White | #F5F5F7 | Background |
| Cyan/Turquoise | #00B4D8 | Accents, active states |
| Red | #FF6B6B | Robot character |
| Dark Gray | #1C1C1E | Text, icons |

#### Typography

- **Display Font**: SF Pro Display (Apple's system font)
- **App Title**: 18pt, Medium weight
- **Status Text**: 16pt, Regular weight
- **Timestamp**: 14pt, Regular weight
- **Message Count**: 12pt, Light weight

#### Interactions

**Tap Actions**
- Tap robot character → Open message thread
- Tap status bar → Refresh/reconnect
- Tap buttons on edges → Navigate menu

**Swipe Gestures**
- Left swipe → Previous message
- Right swipe → Next message
- Swipe down → Close app / return to watch face
- Swipe up → Show notification history

**Digital Crown**
- Rotate to scroll through messages
- Press to activate Siri
- Long press to power off

#### Information Hierarchy

1. **Primary**: Connection status (STATUS: OPEN/CLOSED/CONNECTING)
2. **Secondary**: Latest message count (2/3)
3. **Tertiary**: Timestamp (10:09 AM)
4. **Quaternary**: Battery status (0%)

### Implementation Notes

#### SwiftUI Components

```swift
// StatusIndicator view
VStack(spacing: 12) {
    HStack {
        Text("2/3")
            .font(.system(size: 12, weight: .light))
            .foregroundColor(.gray)
        
        Spacer()
        
        Image(systemName: "battery.0")
            .font(.system(size: 12))
            .foregroundColor(.cyan)
    }
    
    // Robot/mascot placeholder
    Image("robot-mascot")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(height: 120)
    
    VStack(spacing: 4) {
        Text("STATUS: OPEN")
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.cyan)
        
        Text("10:09 AM")
            .font(.system(size: 14))
            .foregroundColor(.gray)
    }
}
.padding()
```

#### Design System

**Spacing**
- Standard padding: 12pt
- Component spacing: 8pt
- Edge spacing: 16pt

**Corner Radius**
- Large elements: 20pt
- Medium elements: 12pt
- Small elements: 6pt

**Shadows**
- None (flat design aesthetic)
- Uses color saturation for depth

**Icons**
- SF Symbols 5.0+ for consistency
- Size variants: Small (12pt), Medium (16pt), Large (24pt)

#### Accessibility

- ✅ High contrast between text and background
- ✅ Minimum touch target size: 44x44pt
- ✅ VoiceOver support for all interactive elements
- ✅ Support for Dynamic Type (text size adjustments)
- ✅ Reduced transparency option supported

### Animation & Transitions

**Loading State**
- Animated pulse on robot character
- Rotating loading indicator on badge
- Smooth fade-in when message arrives

**State Changes**
- Status color transition: Gray → Cyan (when connected)
- Haptic feedback on state changes (light tap)
- Message count update animation

**Navigation**
- Slide transition between views
- 300ms duration for smooth UX
- No bouncy physics (flat animation curve)

### Dark Mode Support

All colors automatically adjust for dark mode:
- White background → Dark gray (#1C1C1E)
- Dark text → Light text
- Cyan accents remain constant

### Device Compatibility

- ✅ Apple Watch Series 6+
- ✅ Apple Watch SE (2nd gen)+
- ✅ All watch sizes (40mm, 44mm, 45mm)
- ✅ watchOS 9.0+

### Performance Considerations

- **Rendering**: Lightweight 3D model for robot
- **Memory**: Optimized for watch constraints (<25MB per app)
- **Battery**: Always-on support without excessive drain
- **Network**: Efficient WebSocket for sync

### Future Enhancements

1. **Custom Complications**
   - Add watch face widget showing latest message
   - Display "Unread" count on complications

2. **Siri Shortcuts**
   - "Send message to Telegram"
   - "Show latest messages"

3. **Rich Interactions**
   - Haptic feedback on message arrival
   - Voice reply support

4. **Themes**
   - Light/Dark mode variants
   - Custom accent color picker

5. **Widgets**
   - Lock screen widget (watchOS 17+)
   - Dynamic Island support (future)

---

## Design Inspiration

This design combines:
- **Modern minimalism**: Clean, focused interface
- **Playful elements**: Mascot character adds personality
- **Functional design**: All information easily scannable
- **Apple Watch conventions**: Respects system design language
- **Real-time status**: Clear connection indication
- **Accessibility first**: High contrast, scalable typography

---

## Asset Files

When implementing this design, include:
- `robot-mascot.png` - 3D robot character (512x512px)
- `robot-mascot-light.png` - Light mode variant
- `icon-status-open.png` - Status indicator icons
- `icon-status-closed.png` - Disconnected state

---

**Design System Version**: 1.0  
**Last Updated**: April 2026  
**Target Platform**: watchOS 9.0+  
**Status**: Ready for implementation
