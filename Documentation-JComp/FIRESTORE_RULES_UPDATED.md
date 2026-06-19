# Updated Firestore Security Rules - Admin-Based User Creation

## Database Collection Structure

### 1. `users/{userId}` - User Account & Role Mapping
```json
{
  "userId": "firebase-auth-uid",
  "email": "user@example.com",
  "role": "student|placementCell|admin",
  "department": "CSE",
  "name": "Full Name",
  "createdAt": "timestamp",
  "createdBy": "admin-uid",
  "isActive": true
}
```

### 2. `admin_created_users/{docId}` - Admin User Access Credentials
```json
{
  "email": "student@example.com",
  "role": "student|placementCell",
  "department": "CSE",
  "employeeCode": "STU001",
  "createdAt": "timestamp",
  "createdBy": "admin-uid",
  "isActive": true,
  "name": "Full Name"
}
```

### 3. `students/{studentId}` - Student Profile
```json
{
  "userId": "firebase-auth-uid",
  "email": "student@example.com",
  "name": "Student Name",
  "department": "CSE",
  "semester": "5",
  "cgpa": "8.5",
  "skills": ["Java", "Python"],
  "resume": "url-to-resume",
  "createdAt": "timestamp"
}
```

### 4. `placementCell_profiles/{profileId}` - Placement Cell Profile
```json
{
  "userId": "firebase-auth-uid",
  "email": "placement@example.com",
  "name": "Placement Officer",
  "department": "Placement Cell",
  "phone": "+91-XXXXXXXXXX",
  "createdAt": "timestamp"
}
```

### 5. `jobs/{jobId}` - Job Postings
```json
{
  "title": "Software Engineer",
  "company": "Tech Corp",
  "description": "...",
  "requirements": [...],
  "salary": "8LPA",
  "postedBy": "placement-cell-uid",
  "createdAt": "timestamp",
  "isActive": true
}
```

### 6. `applications/{applicationId}` - Job Applications
```json
{
  "jobId": "job-doc-id",
  "jobTitle": "...",
  "company": "...",
  "postedBy": "placement-cell-uid",
  "studentUid": "student-uid",
  "studentName": "...",
  "studentEmail": "...",
  "status": "Applied|Shortlisted|Rejected|Accepted",
  "appliedAt": "timestamp"
}
```

### 7. `notifications/{notificationId}` - System Notifications
```json
{
  "title": "New Job Posted",
  "message": "...",
  "type": "job",
  "targetUserId": "all",
  "createdAt": "timestamp",
  "isNew": true
}
```

## Updated Firestore Security Rules

**COPY AND PASTE THESE RULES INTO YOUR FIREBASE CONSOLE:**

```firebase-security-rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ═════════════════════════════════════════════════════════
    // HELPER FUNCTIONS
    // ═════════════════════════════════════════════════════════

    function signedIn() {
      return request.auth != null;
    }

    function isOwner(uid) {
      return signedIn() && request.auth.uid == uid;
    }

    function isAdmin() {
      return signedIn() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    function isPlacementCell() {
      return signedIn() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'placementCell';
    }

    function isStudent() {
      return signedIn() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'student';
    }

    // ═════════════════════════════════════════════════════════
    // USERS COLLECTION
    // ═════════════════════════════════════════════════════════
    match /users/{userId} {
      allow create, update: if isAdmin();
      allow read: if isOwner(userId) || isAdmin();
      allow delete: if false;
    }

    // ═════════════════════════════════════════════════════════
    // ADMIN_CREATED_USERS COLLECTION
    // ═════════════════════════════════════════════════════════
    match /admin_created_users/{docId} {
      allow create, update, delete: if isAdmin();
      allow read: if isAdmin() || (signedIn() && request.auth.email == resource.data.email);
    }

    // ═════════════════════════════════════════════════════════
    // STUDENTS COLLECTION
    // ═════════════════════════════════════════════════════════
    match /students/{studentId} {
      allow create, read, update: if isOwner(studentId) || isAdmin() || isPlacementCell();
      allow delete: if false;
    }

    // ═════════════════════════════════════════════════════════
    // PLACEMENT_CELL_PROFILES COLLECTION
    // ═════════════════════════════════════════════════════════
    match /placementCell_profiles/{profileId} {
      allow create, read, update: if isOwner(profileId) || isAdmin();
      allow delete: if false;
    }

    // ═════════════════════════════════════════════════════════
    // JOBS COLLECTION
    // ═════════════════════════════════════════════════════════
    match /jobs/{jobId} {
      allow read: if signedIn();
      allow create, update: if isPlacementCell() || isAdmin();
      allow delete: if isPlacementCell() && resource.data.postedBy == request.auth.uid;
    }

    // ═════════════════════════════════════════════════════════
    // APPLICATIONS COLLECTION
    // ═════════════════════════════════════════════════════════
    match /applications/{applicationId} {
      allow create: if isStudent();
      allow read: if isAdmin() || 
                    (isStudent() && resource.data.studentUid == request.auth.uid) || 
                    (isPlacementCell() && resource.data.postedBy == request.auth.uid);
      allow update: if isAdmin() || (isPlacementCell() && resource.data.postedBy == request.auth.uid);
      allow delete: if false;
    }

    // ═════════════════════════════════════════════════════════
    // NOTIFICATIONS COLLECTION
    // ═════════════════════════════════════════════════════════
    match /notifications/{notificationId} {
      allow read: if signedIn();
      allow create: if isPlacementCell() || isAdmin();
      allow update, delete: if isAdmin();
    }

    // ═════════════════════════════════════════════════════════
    // DEFAULT DENY RULE
    // ═════════════════════════════════════════════════════════
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

## Critical Fixes Applied:

1. **Consistent Field Names**: Changed `createdBy` to `postedBy` to match the Flutter app's logic.
2. **Notification Rules**: Added permissions for `notifications` collection so job alerts can be saved.
3. **Application Visibility**: Fixed rules so Placement Cell users can only see applications for the jobs they posted.
4. **UID-Based Authorization**: Rules rely on the user document being at `/users/{UID}`. 

**REMINDER**: Ensure you recreate any accounts made before the "UID mismatch fix" to ensure these rules work correctly.
