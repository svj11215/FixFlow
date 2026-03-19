# FixFlow - Product Requirements Document

## Document Information
- **Product Name:** FixFlow
- **Product Type:** Mobile & Web Application (Flutter)
- **Version:** 1.0.0
- **Date Created:** March 19, 2026
- **Status:** Active Development

---

## 1. Executive Summary

**FixFlow** is a digital complaint management system designed to streamline the process of lodging, tracking, and resolving complaints across an organization. The platform facilitates a two-role ecosystem where regular users can submit complaints to designated administrators, and administrators can manage, review, and resolve those complaints. The system leverages Firebase for authentication and cloud data management, providing real-time updates and secure user interactions.

---

## 2. Product Overview

### 2.1 Product Vision
Create an efficient, user-friendly complaint management platform that bridges the gap between complaint lodgers and resolvers, enabling transparent tracking and faster resolution of issues through a digital-first approach.

### 2.2 Problem Statement
- Manual complaint handling is time-consuming and error-prone
- Lack of transparency in complaint status and resolution timelines
- Difficulty in categorizing and assigning complaints to appropriate administrators
- No centralized system for tracking complaint history and resolutions

### 2.3 Solution
FixFlow provides:
- Digital complaint submission with image attachments
- Real-time status tracking for complainants
- Admin dashboard for complaint management and resolution
- Role-based access control (User vs. Admin)
- Categorized complaint organization
- Direct communication through resolution notes

---

## 3. Target Users

### 3.1 Primary Users
1. **Regular Users / Complainants**
   - Citizens, employees, or customers
   - Need to submit and track complaints
   - Want transparency in resolution process
   - Expected frequency: Occasional to regular usage

2. **Administrators / Complaint Resolvers**
   - Designated department heads or support staff
   - Responsible for reviewing, assigning, and resolving complaints
   - Need dashboard overview of all complaints
   - Expected frequency: Regular to continuous usage

### 3.2 User Personas
- **User Persona:** Average citizen with basic smartphone literacy
- **Admin Persona:** Administrative staff with moderate technical proficiency

---

## 4. Core Features & Functionality

### 4.1 Authentication System

#### User Sign-In / Sign-Up
- **Google Sign-In Integration**
  - Single sign-on (SSO) option
  - Auto-populate user email and name
  - Secure token management via Firebase Auth
  
- **Role Selection Flow**
  - Explicit login mode selection (User vs. Admin at login screen)
  - Prevents ambiguous role determination
  - Manual role-based experience routing

#### Authentication State Management
- Auto-login on app restart if session is active
- Role restoration from persisted auth state
- Logout functionality with auth state cleanup

---

### 4.2 User Role: Complaint Submission & Tracking

#### 4.2.1 Complaint Submission
**Screen:** Submit Complaint Screen
- **Input Fields:**
  - Title (text)
  - Description (multi-line text)
  - Category (dropdown selection)
  - Location (text input)
  - Image attachment (optional)
  - Administrator assignment (dropdown)
  
- **Functionality:**
  - Form validation before submission
  - Image upload via Cloudinary service
  - Complaint saved to Firestore with metadata
  - Real-time upload progress feedback
  
- **Metadata Captured:**
  - User ID and Name
  - Submission timestamp
  - Initial Status: "Pending"
  - Image URL (if provided)

#### 4.2.2 View My Complaints
**Screen:** My Complaints Screen
- **Features:**
  - Stream of all complaints submitted by logged-in user
  - Display complaint list with:
    - Complaint title
    - Current status (Pending/In Progress/Resolved)
    - Category
    - Location
    - Submission date
    - Admin assigned
  - Real-time updates as status changes
  
- **Actions:**
  - View full complaint details
  - View admin's resolution note
  - Delete own complaints (if status is still Pending)
  - Track complaint through resolution pipeline

#### 4.2.3 Complaint Details
- Full complaint information display
- Status timeline
- Admin's resolution notes
- Image preview
- Contact information of assigned administrator

#### 4.2.4 User Profile
**Screen:** User Profile Screen
- Display user information:
  - Name
  - Email address
  - Total complaints submitted
  - Profile picture (if available)
- Logout functionality
- Account information management

---

### 4.3 Admin Role: Complaint Management

#### 4.3.1 Admin Dashboard
**Screen:** Admin Dashboard Screen
- **Overview Metrics:**
  - Total complaints assigned to admin
  - Count of complaints by status:
    - Pending
    - In Progress
    - Resolved
  - Average resolution time (future enhancement)

- **Quick Actions:**
  - View complaints needing attention
  - Filter by status
  - Priority indicator

#### 4.3.2 Manage Complaints
**Screen:** Admin Complaints Screen (Admin Home)
- **List View:**
  - All complaints assigned to the admin
  - Real-time stream updates
  - Display per complaint:
    - Title
    - Submitted by (user name)
    - Status
    - Category
    - Location
    - Submission date
    - Current assigned admin

- **Complaint Actions:**
  - **View Details:** Full complaint information and user details
  - **Update Status:** Change complaint status
    - Pending → In Progress → Resolved
  - **Add Resolution Note:** Document the resolution or next steps
  - **View Submitted Image:** Review attached evidence
  - **Contact User:** Display user contact information

#### 4.3.3 Complaint Resolution Workflow
- **Status Management:**
  - Pending: Initial state after submission
  - In Progress: Admin has started working on the complaint
  - Resolved: Complaint has been addressed

- **Resolution Documentation:**
  - Admin can add resolution notes at any status stage
  - Notes visible to the submitting user
  - Timestamped for audit trail

#### 4.3.4 Admin Profile
**Screen:** Admin Profile Screen
- Display admin information:
  - Name
  - Email
  - Department
  - Admin ID (6-digit formatted)
  - Total complaints assigned
  - Complaints by status breakdown
- Logout functionality

---

### 4.4 General Features

#### Navigation
- **Role-Based Routing:**
  - Different navigation flows for users vs. admins
  - Splash screen during app initialization
  - Automatic role detection on app launch

#### About Screen
- App information and version details
- Feature overview
- Help documentation links (future)

#### Image Management
- Image upload to Cloudinary CDN
- Image validation before upload
- Cached network image display for performance
- Image preview functionality

---

## 5. Data Models

### 5.1 User Model
```
UserModel
├── uid (String) - Firebase Auth UID
├── name (String)
├── email (String)
├── role (String) - "user" or "admin"
└── adminId (String) - Reference to admin (empty for regular users)
```

### 5.2 Admin Model
```
AdminModel
├── docId (String) - Firestore document ID
├── adminID (Integer) - Unique admin number
├── name (String)
├── email (String)
├── department (String)
└── createdAt (Timestamp)
```

### 5.3 Complaint Model
```
ComplaintModel
├── id (String) - Unique identifier
├── title (String)
├── description (String)
├── category (String)
├── location (String)
├── adminId (String) - Assigned administrator
├── imageUrl (String) - Cloudinary URL
├── status (String) - "Pending" / "In Progress" / "Resolved"
├── createdAt (Timestamp)
├── userId (String) - Submitting user
├── userName (String) - User's name
└── resolutionNote (String) - Admin's notes
```

---

## 6. Technical Architecture

### 6.1 Frontend Framework
- **Flutter** (Dart)
  - Cross-platform support (iOS, Android, Web)
  - Material Design implementation
  - Multi-platform code sharing

### 6.2 State Management
- **Provider Package**
  - AuthProvider for authentication state
  - ComplaintProvider for complaint operations
  - ImageUploadProvider for image uploads
  - Reactive state updates across widgets

### 6.3 Backend Services

#### Firebase Services
1. **Firebase Authentication**
   - Google Sign-In integration
   - Session management
   - Auth state persistence

2. **Cloud Firestore**
   - Real-time database
   - Collections:
     - users
     - admins
     - complaints
   - Real-time streaming updates

#### Third-Party Services
1. **Cloudinary**
   - Image upload and CDN hosting
   - Image optimization
   - URL generation for stored images

2. **Google Sign-In**
   - OAuth 2.0 authentication
   - Web-based secure login

### 6.4 Key Dependencies
- `firebase_core` - Firebase initialization
- `firebase_auth` - Authentication
- `cloud_firestore` - Cloud database
- `google_sign_in` - Google authentication
- `go_router` - Navigation and routing
- `provider` - State management
- `image_picker_web` - Image selection
- `http` - HTTP requests
- `cached_network_image` - Image caching
- `flutter_animate` - UI animations
- `google_fonts` - Typography
- `intl` - Internationalization

---

## 7. User Flows

### 7.1 User Registration & Login Flow
```
App Launch
    ↓
[Check Auth State]
    ↓ (No user logged in)
[Splash Screen]
    ↓
[Login Screen - Role Selection]
    ├→ [Select "User"] → Google Sign-In → Create/Fetch User Doc → [User Home]
    └→ [Select "Admin"] → Check Admin Collection → [Admin Home]
    ↓ (User logged in)
[Restore Role] → [Navigate to appropriate dashboard]
```

### 7.2 User Complaint Submission Flow
```
[User Home]
    ↓
[Submit Complaint Button]
    ↓
[Complaint Form]
    ├─ Title Input
    ├─ Description Input
    ├─ Category Selection
    ├─ Location Input
    ├─ Image Attachment
    ├─ Admin Selection
    └─ Submit Button
    ↓
[Validate Form]
    ↓ (Upload image if provided)
[Cloudinary Upload]
    ↓
[Create Complaint Document in Firestore]
    ↓
[Success Notification]
    ↓
[My Complaints - View submitted complaint]
```

### 7.3 Admin Complaint Management Flow
```
[Admin Home/Dashboard]
    ↓
[View Complaint List]
    ├→ [Click Complaint]
    │    ↓
    │    [View Full Details]
    │    ↓
    │    [Select Action]
    │    ├─ Update Status (Pending → In Progress → Resolved)
    │    ├─ Add Resolution Note
    │    └─ View User Info
    │    ↓
    │    [Save Changes]
    │    ↓
    │    [Back to List]
    │
    └→ [Apply Filters/Search]
```

---

## 8. Screens & Navigation Structure

### 8.1 Splash Screen
- Loading state when app initializes
- Check authentication and role
- Redirect to appropriate login or home screen

### 8.2 Authentication Screens
**Login Screen**
- Role selection buttons (User / Admin)
- Google Sign-In button
- Application branding

### 8.3 User Screens
1. **User Home Screen** - Dashboard with options to submit or view complaints
2. **Submit Complaint Screen** - Form to lodge new complaints
3. **My Complaints Screen** - List of submitted complaints
4. **Complaint Details** - Full complaint information and status
5. **User Profile Screen** - User account information

### 8.4 Admin Screens
1. **Admin Home Screen / Dashboard** - Overview and complaint list
2. **Admin Complaints Screen** - Detailed complaint management
3. **Complaint Details** - Full details with edit/update options
4. **Admin Profile Screen** - Admin account information

### 8.5 Common Screens
- **About Screen** - Application information

---

## 9. Design & UX Considerations

### 9.1 Design System
- **Color Scheme:** Material Design with custom theming
- **Typography:** Google Fonts for modern appearance
- **Components:** Material Design components
- **Animations:** Flutter Animate for smooth transitions and micro-interactions

### 9.2 UX Principles
- **Simplicity:** Clear, intuitive complaint submission process
- **Transparency:** Real-time status updates for users
- **Accessibility:** Readable fonts, high contrast, touch-friendly buttons
- **Feedback:** Loading states, success/error messages, animations
- **Performance:** Cached images, efficient data streaming

### 9.3 Loading States
- Shimmer loading for lists
- Spinning indicators during form submission
- Skeleton screens for data placeholders

---

## 10. Data Security & Privacy

### 10.1 Authentication Security
- Firebase Auth handles secure token management
- Google Sign-In for verified identity
- Auto-logout on app close (recommended)

### 10.2 Data Protection
- Firestore security rules (to be configured):
  - Users can only view/edit their own complaints
  - Admins can view complaints assigned to them
  - Authentication required for all data access

### 10.3 Image Security
- Images uploaded to Cloudinary (third-party CDN)
- No sensitive data in images
- URL expiration policies (if applicable)

### 10.4 Privacy Compliance
- User data stored securely in Firestore
- User email used only for authentication and contact
- No data sharing with third parties
- User has right to delete account and associated data

---

## 11. Performance Metrics

### 11.1 Key Performance Indicators (KPIs)
- **User Adoption:** Number of registered users
- **Complaint Volume:** Total complaints submitted
- **Resolution Rate:** Percentage of resolved complaints
- **Average Resolution Time:** Time from submission to resolution
- **User Satisfaction:** App rating and user feedback

### 11.2 Technical Metrics
- **App Load Time:** < 3 seconds
- **Form Submission Time:** < 2 seconds
- **Image Upload:** < 5 seconds for typical images
- **List Load:** Real-time streaming (latency < 1 second)
- **Crash Rate:** < 0.1%

---

## 12. Future Enhancements

### 12.1 Planned Features
- **Complaint Categories Management:** Dynamic category creation by admins
- **Escalation System:** Automatic escalation if complaint not resolved in SLA time
- **Notification System:** Push notifications for status updates
- **Advanced Analytics:** Dashboard with charts and statistics
- **Bulk Actions:** Admins can manage multiple complaints
- **Comment/Chat:** Conversations between users and admins
- **Rating System:** Users can rate complaint resolution
- **Export Functionality:** Export complaints data to PDF/Excel
- **Mobile App Optimization:** Native Android/iOS refinements
- **Web Portal:** Full-featured web version

### 12.2 Potential Enhancements
- **QR Code Generation:** For complaint tracking verification
- **SMS Notifications:** Status updates via SMS
- **Voice Recording:** Upload voice complaints
- **Multi-language Support:** Localization for different regions
- **Video Recording:** Support for video complaint submissions
- **Geolocation:** Auto-capture location of complaint
- **Social Media Integration:** Share complaint status

---

## 13. Deployment & Release Plan

### 13.1 Platforms
- **iOS:** Apple App Store
- **Android:** Google Play Store
- **Web:** Browser-based PWA or web application

### 13.2 Current Version
- **Version 1.0.0** - MVP (Minimum Viable Product)
  - Core complaint submission and management
  - Role-based access
  - Image attachment support
  - Real-time status tracking

### 13.3 Release Strategy
- Beta testing with selected admin users
- User feedback collection
- Iterative improvements
- Phased rollout to larger user base

---

## 14. Success Criteria

### 14.1 For Users
- ✅ Easy complaint submission (< 2 minutes)
- ✅ Real-time status tracking
- ✅ Transparent resolution process
- ✅ Image attachment capability

### 14.2 For Admins
- ✅ Centralized complaint dashboard
- ✅ Easy status management
- ✅ Communication through resolution notes
- ✅ Filter and view assigned complaints

### 14.3 For Organization
- ✅ Reduce manual complaint handling
- ✅ Improve complaint resolution time
- ✅ Increase transparency and accountability
- ✅ Create audit trail of all complaints

---

## 15. Appendix

### 15.1 Glossary
- **Complaint:** A formal expression of dissatisfaction regarding a service or issue
- **Administrator (Admin):** Staff member responsible for reviewing and resolving complaints
- **Status:** Current state of a complaint in the resolution process
- **Resolution Note:** Documentation by admin regarding complaint resolution steps
- **Firebase:** Google's cloud platform for authentication and data storage
- **Firestore:** NoSQL cloud database by Google
- **Cloudinary:** Cloud-based image management service

### 15.2 References
- Firebase Documentation: https://firebase.google.com/docs
- Flutter Documentation: https://flutter.dev/docs
- Material Design: https://material.io/design

---

**Document End**

*Last Updated: March 19, 2026*
*Version: 1.0*
