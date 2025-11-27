# App Store Submission Checklist

## 📱 Apple App Store Requirements

### 1. App Information
- [x] App Name: **SiiPing**
- [ ] Bundle ID: `com.yourcompany.siiping` (تحتاج تعديل)
- [x] Version: 1.0.0
- [x] Category: Social Networking
- [x] Age Rating: 13+
- [x] Privacy Policy URL (required)
- [x] Terms of Service

### 2. App Store Connect
- [ ] Developer Account ($99/year)
- [ ] App ID created
- [ ] Certificates configured
- [ ] Provisioning profiles set up

### 3. Assets Required
- [ ] **App Icon** (1024x1024 PNG, no transparency)
- [ ] **Screenshots** (minimum 3, recommended 5-8):
  - iPhone 6.7" (1290 x 2796)
  - iPhone 6.5" (1284 x 2778)
  - iPhone 5.5" (1242 x 2208)
  - Optional: iPad screenshots
- [ ] **App Preview Videos** (optional but recommended)

### 4. Legal & Compliance
- [x] Privacy Policy (DONE)
- [x] Terms of Service (DONE)
- [ ] Data Collection Disclosure in App Store Connect
- [ ] Export Compliance (if using encryption - YES for you)
- [ ] Content Rights

### 5. Technical Requirements
- [ ] Build with latest Xcode
- [ ] Test on real iOS devices
- [ ] No crashes or major bugs
- [ ] Proper error handling
- [ ] Loading states for network requests

### 6. Permissions & Justifications
Add to `Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>نحتاج الكاميرا لالتقاط الصور والفيديوهات لمشاركتها</string>

<key>NSMicrophoneUsageDescription</key>
<string>نحتاج الميكروفون لتسجيل البايو الصوتي والرسائل الصوتية</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>نحتاج الوصول للصور لمشاركتها في المحادثات</string>
```

### 7. In-App Purchases (if applicable)
- [ ] Configure subscriptions in App Store Connect
- [ ] Test with sandbox accounts
- [ ] Restore purchases functionality

### 8. App Review Information
- [ ] Demo account credentials (for reviewers)
- [ ] Notes for reviewers
- [ ] Contact information

---

## 🤖 Google Play Store Requirements

### 1. App Information
- [x] App Name: **SiiPing**
- [ ] Package Name: `com.yourcompany.siiping` (تحتاج تعديل)
- [x] Version: 1.0.0 (versionCode: 1)
- [x] Category: Social
- [x] Content Rating: Teen (13+)

### 2. Google Play Console
- [ ] Developer Account ($25 one-time)
- [ ] App created
- [ ] Release signing configured

### 3. Assets Required
- [ ] **App Icon** (512x512 PNG)
- [ ] **Feature Graphic** (1024x500 PNG) - REQUIRED
- [ ] **Screenshots** (minimum 2, max 8):
  - Phone: 16:9 or 9:16 aspect ratio
  - Tablet: optional
- [ ] **Promo video** (YouTube link, optional)

### 4. Store Listing
- [x] Short description (80 chars max)
- [x] Full description (4000 chars max)
- [ ] Translated descriptions (optional: Arabic recommended)
- [ ] Contact email
- [ ] Privacy Policy URL

### 5. Legal & Compliance
- [x] Privacy Policy (DONE)
- [x] Terms of Service (DONE)
- [ ] Data Safety Form (REQUIRED in Play Console)
- [ ] Target API Level 33+ (Android 13)
- [ ] App content questionnaire

### 6. Permissions in AndroidManifest.xml
✅ Already added:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

### 7. Data Safety Declaration
Declare in Play Console:
- ✅ Collect: Username, Email, Profile Data
- ✅ Encryption: Yes (E2E for messages)
- ✅ Data Sharing: Only with necessary services
- ✅ Deletion: Users can delete accounts

### 8. Content Rating
- [ ] Complete IARC questionnaire
- Expected: Teen/PEGI 12

### 9. Technical Requirements
- [ ] Build AAB (Android App Bundle), not APK
- [ ] Test on multiple Android devices
- [ ] Target SDK 34 (Android 14)
- [ ] 64-bit support

---

## ⚠️ Critical Issues to Fix

### 1. Package/Bundle ID
Currently: `com.nixen.nixen`
**Change to**: `com.yourcompany.siiping` in:
- `android/app/build.gradle.kts`
- iOS project settings

### 2. Google Services
- [ ] Update `google-services.json` with new package name
- [ ] Reconfigure Firebase (if using)

### 3. Missing Assets
- [ ] Create Feature Graphic (1024x500) - Google Play
- [ ] Take high-quality screenshots
- [ ] Record demo video (optional)

### 4. Contact Information
Update everywhere:
- [ ] Support email: support@siiping.com
- [ ] Website: https://siiping.com
- [ ] Privacy: https://siiping.com/privacy
- [ ] Terms: https://siiping.com/terms

---

## 📝 Pre-Submission Testing

### Functionality
- [ ] User registration/login works
- [ ] Messaging send/receive works
- [ ] Image upload works
- [ ] Voice recording works
- [ ] Subscriptions work (test mode)
- [ ] All screens load properly

### Performance
- [ ] App launches in < 3 seconds
- [ ] No memory leaks
- [ ] Smooth scrolling
- [ ] Proper offline handling

### Security
- [ ] HTTPS only
- [ ] Encryption working
- [ ] No hardcoded secrets
- [ ] Secure API keys

---

## 🎯 Recommended Timeline

1. **Week 1**: Fix critical issues + assets
2. **Week 2**: Testing + screenshots
3. **Week 3**: Submit to both stores
4. **Week 4-6**: Review process (can take 1-3 weeks)

---

## 📞 Next Steps

1. ✅ Privacy Policy & Terms (DONE)
2. ⏳ Create app icon (waiting for image generation)
3. 🔧 Fix package names
4. 📸 Take screenshots
5. 📝 Fill store listings
6. 🚀 Submit!
