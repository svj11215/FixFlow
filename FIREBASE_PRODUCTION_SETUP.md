# Firebase Production Setup

## ✅ Current Configuration Status

Your Firebase integration is already configured with:
- ✅ Firebase Authentication (Google Sign-In)
- ✅ Cloud Firestore (Real-time database)
- ✅ Firebase Storage (for future image optimization)

## 🔧 Steps to Move to Production Firebase Project

### 1. Create Production Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project"
3. Enter name: `FixFlow-Production`
4. Select billing account
5. Enable Google Analytics (optional)
6. Create project

### 2. Update Firebase Configuration

#### For Android:
1. In Firebase Console → Project Settings → Your apps
2. Register Android app with package: `com.fixflow.app`
3. Download `google-services.json`
4. Replace: `android/app/google-services.json`

#### For iOS:
1. Register iOS app with Bundle ID: `com.fixflow.app`
2. Download `GoogleService-Info.plist`
3. Add to Xcode project (add to Runner target)

#### For Web:
1. Register Web app
2. Copy config and update `lib/firebase_options.dart`

### 3. Update Firestore Security Rules

Go to Firebase Console → Firestore → Rules

Replace with production rules:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }

    // Admins - protected collection
    match /admins/{adminId} {
      allow read: if request.auth != null && getAdminStatus(request.auth.uid);
      allow write: if request.auth != null && isAdmin(request.auth.uid);
    }

    // Complaints - role-based access
    match /complaints/{complaintId} {
      // Users can read their own complaints
      allow read: if request.auth.uid == resource.data.userId;
      // Admins can read complaints assigned to them
      allow read: if request.auth != null && resource.data.adminId == getAdminId(request.auth.uid);
      
      // Users can create complaints
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      
      // Admins can update complaint status
      allow update: if request.auth != null && resource.data.adminId == getAdminId(request.auth.uid);
      
      // Users can delete their pending complaints
      allow delete: if request.auth.uid == resource.data.userId && resource.data.status == 'Pending';
    }

    // Helper functions
    function isAdmin(uid) {
      return exists(/databases/$(database)/documents/admins/$(uid));
    }

    function getAdminId(uid) {
      return get(/databases/$(database)/documents/users/$(uid)).data.adminId;
    }

    function getAdminStatus(uid) {
      return get(/databases/$(database)/documents/admins/$(uid)).data != null;
    }
  }
}
```

Publish the rules.

### 4. Configure Firebase Authentication

1. Go to Firebase Console → Authentication → Sign-in method
2. Enable Google Sign-In (if not already)
3. Add authorized domains:
   - For Web: your domain (e.g., fixflow.example.com)
   - OAuth redirect URI will be auto-configured

### 5. Set Up Cloudinary (if not done)

1. Go to [Cloudinary](https://cloudinary.com)
2. Sign up for production account
3. Get API Key and Cloud Name
4. Update in your auth service:
   - In `lib/services/cloudinary_service.dart`
   - Update CLOUD_NAME and API_KEY with production credentials

### 6. Configure Environment

1. Create `.env.production` file (do not commit to git):
```
FIREBASE_PROJECT_ID=fixflow-production
FIREBASE_DATABASE_URL=https://fixflow-production.firebaseio.com
CLOUDINARY_CLOUD_NAME=your_production_cloud_name
CLOUDINARY_API_KEY=your_production_api_key
```

2. Update `.gitignore` to exclude sensitive files:
```
.env.production
google-services.json
GoogleService-Info.plist
app.jks
```

### 7. Enable Required Firebase Services

In Firebase Console:
- ✅ Authentication (Google Sign-In)
- ✅ Cloud Firestore
- ✅ Cloud Storage (for future enhancements)
- ✅ Hosting (for web deployment)

### 8. Set Up Monitoring

1. Go to Firebase Console → Performance Monitoring
2. Add to your app for monitoring
3. Set up Crash Reporting for issue tracking

### 9. Test Production Configuration

```bash
# Test build with production Firebase
flutter run --release

# Check logs
flutter logs
```

## 📋 Production Checklist

- [ ] Created Firebase production project
- [ ] Updated google-services.json (Android)
- [ ] Updated GoogleService-Info.plist (iOS)
- [ ] Configured Firestore security rules
- [ ] Enabled Google Sign-In authentication
- [ ] Set up Cloudinary production account
- [ ] Configured environment variables
- [ ] Updated .gitignore
- [ ] Tested release build
- [ ] Set up error monitoring
- [ ] Enabled performance monitoring

## 🚀 Deployment Order

1. ✅ Update Android package name → DONE
2. ⏳ Generate keystore file (see PRODUCTION_BUILD_GUIDE.md)
3. ⏳ Create Firebase production project
4. ⏳ Update Firebase configuration
5. ⏳ Implement Firestore security rules
6. ⏳ Build release APK/App Bundle
7. ⏳ Set up iOS signing
8. ⏳ Build iOS archive
9. ⏳ Deploy to app stores (Google Play, App Store)
10. ⏳ Deploy web version to Firebase Hosting

## 🔐 Security Checklist

- [ ] Never commit sensitive keys/passwords
- [ ] Use environment variables for secrets
- [ ] Enable Firestore security rules
- [ ] Configure CORS for Cloudinary
- [ ] Enable app signing verification
- [ ] Set up monitoring and alerting
- [ ] Enable two-factor auth on Firebase account
- [ ] Regular backup of data

## 📞 Support Resources

- [Firebase Production Setup](https://firebase.google.com/docs)
- [Flutter Release Documentation](https://flutter.dev/docs/deployment)
- [App Store Submission](https://developer.apple.com/app-store/)
- [Google Play Console](https://play.google.com/console)

---

Last Updated: March 19, 2026
Version: 1.0.0 (Production Ready)
