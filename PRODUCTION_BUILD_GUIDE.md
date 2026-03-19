# Production Build Configuration

## Android Keystore Setup

To build for production, you need to create a keystore file and set environment variables:

### 1. Generate a Keystore File (One-time setup)
```bash
keytool -genkey -v -keystore ./app.jks \
  -keyalg RSA -keysize 2048 -validity 10950 \
  -alias fixflow_app_release
```

When prompted, enter:
- Password (e.g., YourSecurePassword123)
- First and last name: Your Name
- Organization: Your Organization
- Location: Your City
- State: Your State
- Country: Your Country Code (e.g., US)

### 2. Set Environment Variables

Export these before building:
```bash
export KEYSTORE_PATH="/path/to/app.jks"
export KEYSTORE_PASSWORD="YourSecurePassword123"
export KEY_ALIAS="fixflow_app_release"
export KEY_PASSWORD="YourSecurePassword123"
```

Or add to your shell profile (~/.zshrc):
```bash
export KEYSTORE_PATH="$HOME/Library/Android/fixflow_keystore/app.jks"
export KEYSTORE_PASSWORD="your_password_here"
export KEY_ALIAS="fixflow_app_release"
export KEY_PASSWORD="your_password_here"
```

### 3. Build Release APK
```bash
flutter build apk --release
```

### 4. Build Release App Bundle (for Google Play)
```bash
flutter build appbundle --release
```

## iOS Release Configuration

### 1. Update iOS Bundle Identifier
In Xcode:
- Open `ios/Runner.xcworkspace`
- Select "Runner" project
- Select "Runner" target
- Under "General" tab, update Bundle Identifier to: `com.fixflow.app`

### 2. Configure Signing & Capabilities
- Select a Team ID
- Enable "Automatically manage signing"
- Verify certificate is valid

### 3. Build iOS App
```bash
flutter build ios --release
```

### 4. Archive for App Store
```bash
flutter build ios --release && open ios/Runner.xcworkspace
```
Then use Xcode to archive and upload to App Store.

## Web Build

### 1. Build Web Release
```bash
flutter build web --release
```

### 2. Output Location
Built files are in: `build/web/`

### 3. Deploy to Hosting
- Firebase Hosting: `firebase deploy`
- Or any static hosting provider

## Environment Variables Safety

⚠️ **IMPORTANT**: Never commit sensitive information:
- Store `app.jks` outside the project
- Use environment variables for passwords
- Update `.gitignore` if needed
- Consider using GitHub Secrets for CI/CD

## Checking Build Info

### Find your keystore information:
```bash
keytool -list -v -keystore ./app.jks
```

### View APK details:
```bash
aapt dump badging build/app/outputs/apk/release/app-release.apk | grep package
```

## Next Steps

1. ✅ Update package name: `com.fixflow.app`
2. ✅ Generate keystore file
3. ✅ Configure signing
4. ⏳ Build and test release APK
5. ⏳ Set up Firebase project for production
6. ⏳ Configure iOS Code Signing
7. ⏳ Submit to app stores

---

Version: 1.0.0 (Production)
