# 🎨 Play Store Assets Creation Guide

## Required Assets Checklist

- [ ] App Icon (512 x 512 px)
- [ ] Feature Graphic (1024 x 500 px)
- [ ] Phone Screenshots (2-8 images)
- [ ] 7-inch Tablet Screenshots (optional)
- [ ] 10-inch Tablet Screenshots (optional)
- [ ] Promotional Video (optional)

---

## 1. App Icon (512 x 512 px)

### Specifications
- **Size:** 512 x 512 pixels
- **Format:** PNG (32-bit)
- **No transparency:** Must have solid background
- **Full bleed:** No padding or borders
- **File size:** Under 1MB

### Design Tips
- Use your app's launcher icon as base
- Ensure it's recognizable at small sizes
- Avoid text (hard to read when small)
- Use bold, simple shapes
- Match your brand colors

### Tools to Create
- **Canva:** https://www.canva.com/ (Free templates)
- **Figma:** https://www.figma.com/ (Professional design)
- **Adobe Express:** https://www.adobe.com/express/
- **GIMP:** Free alternative to Photoshop

### Current Icon Location
Your app icon is at: `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`

To create 512x512 version:
```bash
# If you have ImageMagick installed
magick android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png -resize 512x512 play-store-icon.png
```

---

## 2. Feature Graphic (1024 x 500 px)

### Specifications
- **Size:** 1024 x 500 pixels
- **Format:** PNG or JPEG
- **File size:** Under 1MB
- **Safe zone:** Keep important content in center 924 x 400 px

### Design Ideas for Uptop Careers

**Option 1: Hero Image with Text**
```
[Background: Gradient blue/purple]
[Left side: Phone mockup showing app]
[Right side: Text]
  "Refer & Earn"
  "Campus Ambassador Program"
  "Earn up to ₹20,000 per referral"
```

**Option 2: Feature Showcase**
```
[Background: Modern gradient]
[Icons showing:]
  📱 Share Links | 💰 Earn Rewards | 📊 Track Progress
[Bottom: "Uptop Careers - Campus Ambassador"]
```

**Option 3: Student-Focused**
```
[Background: Education-themed]
[Center: "Help Students, Earn Rewards"]
[Icons: Referral → Application → Enrollment → Rewards]
```

### Tools
- **Canva Template:** Search "Google Play Feature Graphic"
- **Figma Community:** Free templates available
- **Adobe Express:** Pre-sized templates

### Quick Creation Steps
1. Go to Canva.com
2. Search "Google Play Feature Graphic" or create custom 1024x500
3. Choose template or start blank
4. Add your app name "Uptop Careers"
5. Add tagline: "Refer & Earn Campus Ambassador Program"
6. Add key features or benefits
7. Use brand colors (blue, purple, or your choice)
8. Download as PNG

---

## 3. Screenshots (Phone)

### Specifications
- **Minimum:** 2 screenshots required
- **Maximum:** 8 screenshots allowed
- **Aspect ratio:** 16:9 or 9:16
- **Minimum dimension:** 320px
- **Maximum dimension:** 3840px
- **Format:** PNG or JPEG

### Recommended Screenshots for Uptop Careers

#### Screenshot 1: Home/Dashboard
- Shows main navigation
- Highlights key features
- Clean, professional look

#### Screenshot 2: Programs Listing
- Display available programs
- Show search/filter options
- Demonstrate variety

#### Screenshot 3: Referral System
- Show "Share" button
- Display referral link generation
- Highlight ease of sharing

#### Screenshot 4: Referral Tracker
- Show active referrals
- Display status tracking
- Highlight rewards earned

#### Screenshot 5: Application Journey
- Show application progress
- Display status updates
- Demonstrate tracking

#### Screenshot 6: Rewards/Earnings
- Show earnings breakdown
- Display reward milestones
- Highlight payment info

#### Screenshot 7: Profile
- User profile screen
- Settings and preferences
- Account management

#### Screenshot 8: Program Details
- Detailed program view
- Application process
- Benefits and features

### How to Capture Screenshots

#### On Android Device
1. Install the app on device
2. Navigate to each screen
3. Press Power + Volume Down to screenshot
4. Transfer to computer

#### On Android Emulator
1. Run app in emulator
2. Use emulator's screenshot tool
3. Or use Android Studio's screenshot feature

#### Using Flutter DevTools
```bash
# Run app in debug mode
flutter run

# Use Flutter DevTools to capture screens
```

### Enhancing Screenshots

**Add Device Frame:**
- Use https://mockuphone.com/
- Upload screenshot
- Select device (Pixel, Samsung, etc.)
- Download with frame

**Add Annotations:**
- Use Canva or Figma
- Add text overlays explaining features
- Highlight important UI elements
- Add arrows or callouts

**Example Annotation:**
```
Screenshot 3 (Referral System):
- Arrow pointing to Share button: "One-tap sharing"
- Highlight referral link: "Unique link for each program"
- Badge: "Track every referral"
```

---

## 4. Creating Professional Screenshots

### Method 1: Device Frames + Annotations

1. **Capture clean screenshots** from app
2. **Add device frame** at mockuphone.com
3. **Create composite in Canva:**
   - Canvas: 1080 x 1920 px (9:16)
   - Add gradient background
   - Place framed screenshot
   - Add title at top (e.g., "Track Your Referrals")
   - Add brief description
   - Add feature highlights

### Method 2: Side-by-Side Comparison

```
[Canvas: 1920 x 1080 px (16:9)]
[Left: Before screenshot]
[Right: After screenshot]
[Center: Arrow or "→"]
[Top: Feature title]
```

### Method 3: Feature Showcase

```
[Canvas: 1080 x 1920 px]
[Top 30%: Feature title + description]
[Middle 60%: Screenshot]
[Bottom 10%: Key benefit]
```

---

## 5. Quick Asset Creation Workflow

### Using Canva (Recommended for Beginners)

1. **Create Account:** https://www.canva.com/
2. **App Icon:**
   - Search "App Icon" template
   - Customize with your brand
   - Download as PNG (512x512)

3. **Feature Graphic:**
   - Search "Google Play Feature Graphic"
   - Customize template
   - Download as PNG (1024x500)

4. **Screenshots:**
   - Create design (1080x1920)
   - Upload your screenshots
   - Add device frames
   - Add text overlays
   - Download all

### Using Figma (Professional)

1. **Create Account:** https://www.figma.com/
2. **Use Community Templates:**
   - Search "Google Play Assets"
   - Duplicate template
   - Customize for your app
3. **Export:**
   - Select frames
   - Export as PNG
   - Choose appropriate resolution

---

## 6. Asset Checklist Before Upload

### App Icon
- [ ] Exactly 512 x 512 px
- [ ] PNG format, 32-bit
- [ ] No transparency
- [ ] Under 1MB
- [ ] Looks good at small sizes

### Feature Graphic
- [ ] Exactly 1024 x 500 px
- [ ] PNG or JPEG
- [ ] Under 1MB
- [ ] Important content in safe zone
- [ ] Text is readable

### Screenshots
- [ ] At least 2 screenshots
- [ ] Correct aspect ratio (16:9 or 9:16)
- [ ] High quality, not blurry
- [ ] Show key features
- [ ] No personal/sensitive data visible
- [ ] Consistent style across all

---

## 7. Sample Asset Descriptions

### For Designers/Freelancers

**Brief for Feature Graphic:**
```
App Name: Uptop Careers
Tagline: Refer & Earn Campus Ambassador Program
Size: 1024 x 500 px
Style: Modern, professional, education-focused
Colors: Blue (#2196F3), Purple (#9C27B0), White
Elements:
- App name prominently displayed
- Tagline or key benefit
- Icons or illustrations showing: referral, tracking, rewards
- Optional: Phone mockup showing app interface
Mood: Trustworthy, energetic, student-friendly
```

**Brief for Screenshots:**
```
Need 6-8 screenshots with device frames and annotations
Size: 1080 x 1920 px (portrait)
Device: Modern Android phone (Pixel or Samsung)
Style: Clean background, minimal text overlay
Screens needed:
1. Home/Dashboard
2. Programs listing
3. Referral sharing
4. Referral tracker
5. Application journey
6. Rewards/earnings
Each with title and 1-2 line description
```

---

## 8. Free Resources

### Stock Images
- **Unsplash:** https://unsplash.com/ (Free high-quality images)
- **Pexels:** https://www.pexels.com/ (Free stock photos)

### Icons
- **Material Icons:** https://fonts.google.com/icons
- **Flaticon:** https://www.flaticon.com/ (Free with attribution)

### Mockups
- **Mockuphone:** https://mockuphone.com/ (Device frames)
- **Smartmockups:** https://smartmockups.com/ (Free tier available)

### Design Tools
- **Canva:** https://www.canva.com/ (Free tier)
- **Figma:** https://www.figma.com/ (Free for individuals)
- **GIMP:** https://www.gimp.org/ (Free Photoshop alternative)

---

## 9. Timeline

- **App Icon:** 30 minutes - 1 hour
- **Feature Graphic:** 1-2 hours
- **Screenshots (capture):** 30 minutes
- **Screenshots (enhance):** 2-3 hours
- **Total:** 4-7 hours (if doing yourself)

**Alternatively:** Hire on Fiverr/Upwork for $20-50 for complete asset package

---

## ✅ Ready to Create!

Follow this guide to create professional Play Store assets for Uptop Careers. Take your time to make them look polished - they're the first impression users will have of your app!

