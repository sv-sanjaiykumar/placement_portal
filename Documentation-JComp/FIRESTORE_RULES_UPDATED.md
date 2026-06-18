# Updated Firestore Security Rules - Admin-Based User Creation

## Database Collection Structure

### 1. `users/{userId}` - User Account & Role Mapping
```
{
  userId: "firebase-auth-uid",
  email: "user@example.com",
  role: "student|placementCell|recruiter",
  department: "CSE",
  createdAt: timestamp,
  createdBy: "admin-uid",
  isActive: true
}
```

### 2. `admin_created_users/{docId}` - Admin User Access Credentials
This collection stores users created by admins with their assigned roles.

```
{
  email: "student@example.com" (unique),
  role: "student|placementCell|recruiter",
  department: "CSE",
  employeeCode: "STU001", (optional)
  createdAt: timestamp,
  createdBy: "admin-uid",
  isActive: true,
  fullName: "Student Name"
}
```

### 3. `students/{studentId}` - Student Profile
```
{
  userId: "firebase-auth-uid",
  email: "student@example.com",
  name: "Student Name",
  department: "CSE",
  semester: "5",
  cgpa: "8.5",
  skills: ["Java", "Python"],
  resume: "url-to-resume",
  createdAt: timestamp
}
```

### 4. `recruiters/{recruiterId}` - Recruiter Profile
```
{
  userId: "firebase-auth-uid",
  email: "recruiter@company.com",
  name: "Recruiter Name",
  company: "Tech Corp",
  position: "HR Manager",
  phone: "+91-XXXXXXXXXX",
  createdAt: timestamp
}
```

### 5. `jobs/{jobId}` - Job Postings
```
{
  title: "Software Engineer",
  company: "Tech Corp",
  description: "...",
  requirements: [...],
  salary: "8LPA",
  createdBy: "recruiter-uid",
  createdAt: timestamp,
  isActive: true
}
```

### 6. `applications/{applicationId}` - Job Applications
```
{
  jobId: "job-doc-id",
  studentId: "student-uid",
  studentEmail: "student@example.com",
  recruiterId: "recruiter-uid",
  status: "applied|shortlisted|rejected|accepted",
  appliedAt: timestamp,
  updatedAt: timestamp
}
```

### 7. `admins/{adminId}` - Admin Profiles
```
{
  userId: "firebase-auth-uid",
  email: "admin@example.com",
  name: "Admin Name",
  permissions: ["manage_users", "manage_jobs", "view_reports"],
  createdAt: timestamp
}
```

## Updated Firestore Security Rules

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
    // USERS COLLECTION - Dynamic role management
    // ═════════════════════════════════════════════════════════
    match /users/{userId} {
      // Admin can create/read/update all user documents
      allow create, update: if isAdmin();
      allow read: if isOwner(userId) || isAdmin();
      allow delete: if false; // Never delete, just deactivate
    }

    // ═════════════════════════════════════════════════════════
    // ADMIN_CREATED_USERS COLLECTION
    // This tracks which users were created by admins
    // ═════════════════════════════════════════════════════════
    match /admin_created_users/{docId} {
      // Only admins can create user access credentials
      allow create, update: if isAdmin();
      // Admins can read all created users
      allow read: if isAdmin();
      // Users can read their own created record (by email lookup)
      allow read: if signedIn() && request.auth.email == resource.data.email;
      // Only admins can delete
      allow delete: if isAdmin();
    }

    // ═════════════════════════════════════════════════════════
    // STUDENTS COLLECTION - Student Profile
    // ═════════════════════════════════════════════════════════
    match /students/{studentId} {
      // Student can create/read/update their own profile
      allow create, read, update: if isOwner(studentId);
      // Admin can read all student profiles
      allow read: if isAdmin();
      // Recruiter can read student profiles (for job matching)
      allow read: if isPlacementCell();
      // Student cannot delete their profile
      allow delete: if false;
    }

    // ═════════════════════════════════════════════════════════
    // RECRUITERS COLLECTION - Recruiter Profile
    // ═════════════════════════════════════════════════════════
    match /recruiters/{recruiterId} {
      // Recruiter can create/read/update their own profile
      allow create, read, update: if isOwner(recruiterId);
      // Admin can read all recruiter profiles
      allow read: if isAdmin();
      // Recruiter cannot delete their profile
      allow delete: if false;
    }

    // ═════════════════════════════════════════════════════════
    // ADMINS COLLECTION - Admin Profiles
    // ═════════════════════════════════════════════════════════
    match /admins/{adminId} {
      // Admin can read/update their own profile
      allow read, update: if isOwner(adminId) || isAdmin();
      // Only super-admins can create new admins (restricted)
      allow create: if false; // Create manually or via backend
      allow delete: if false;
    }

    // ═════════════════════════════════════════════════════════
    // JOBS COLLECTION - Job Postings
    // ═════════════════════════════════════════════════════════
    match /jobs/{jobId} {
      // Anyone signed in can read jobs
      allow read: if signedIn();
      // Only placement cell/recruiter can create jobs
      allow create, update: if isPlacementCell() || isAdmin();
      // Placement cell can delete their own jobs
      allow delete: if resource.data.createdBy == request.auth.uid && isPlacementCell();
    }

    // ═════════════════════════════════════════════════════════
    // APPLICATIONS COLLECTION - Job Applications
    // ═════════════════════════════════════════════════════════
    match /applications/{applicationId} {
      // Student can create applications
      allow create: if isStudent();
      // Student can read their own applications
      allow read: if resource.data.studentId == request.auth.uid;
      // Recruiter can read applications for their jobs
      allow read: if resource.data.recruiterId == request.auth.uid;
      // Admin can read all applications
      allow read: if isAdmin();
      // Recruiter can update application status
      allow update: if resource.data.recruiterId == request.auth.uid;
      allow delete: if false;
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

## Key Changes from Previous Rules

1. **Admin Control**: Admins now control user creation and role assignment
2. **Admin_Created_Users Collection**: Tracks which users were created by which admin
3. **Role-Based Access**: More granular permissions based on user roles
4. **Students & Recruiters**: Can only modify their own profiles
5. **Job Management**: Only placement cell and admins can post jobs
6. **Application Management**: Strict access control based on user roles
7. **No Self-Signup**: Users cannot create their own accounts in the users collection

## Security Considerations

1. Admins can create Firebase Auth accounts for users (requires backend implementation)
2. Users must authenticate with credentials provided by admin
3. Once logged in, their role is resolved from the `users` collection
4. The `admin_created_users` collection serves as an audit trail
5. All sensitive operations require admin authentication first
