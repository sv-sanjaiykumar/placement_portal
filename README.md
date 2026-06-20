PlacementHub - Campus Placement Portal 🎓💼
PlacementHub is a full-stack, role-based mobile application built with Flutter and Firebase. It is designed to streamline and automate the recruitment process for educational institutions, connecting Administrators, Placement Officers, and Students in a single, secure ecosystem.
🚀 Key Features
🔐 Admin-Controlled Security
•
Restricted Access: No self-signup. All user accounts are created by the system administrator to ensure only verified students and staff can access the portal.
•
Role-Based Navigation: Users are automatically redirected to specific dashboards (Admin, Placement Cell, or Student) upon login.
•
Secure Sessions: Advanced implementation using secondary Firebase instances to allow admins to manage users without losing their own session.
👑 Administrator Dashboard
•
Real-time Analytics: Visual overview of platform statistics (Total Users, Active Jobs, Placements).
•
User Management: Centralized hub to create, manage, and deactivate/reactivate student and staff accounts.
•
Staff Delegation: Dedicated tools to assign roles and department-specific permissions.
🏢 Placement Cell Dashboard
•
Job Management: Complete CRUD operations for job postings including salary, eligibility criteria, and job descriptions.
•
Applicant Tracking: Live stream of student applications with real-time status updates (Applied, Shortlisted, Interview, etc.).
•
Interview Scheduler: Dedicated scheduling tool to set interview dates, times, and modes (Online/On-site) with automatic notifications to students.
🎓 Student Dashboard
•
Live Job Board: Browse and search for active job openings tailored to specific departments and CGPA requirements.
•
One-Tap Apply: Quick application process with built-in checks to prevent duplicate applications.
•
Personalized Alerts: Real-time in-app notifications for job invitations and interview schedules.
•
Profile Hub: Manage academic details, department info, and contact credentials.
🛠 Technical Stack
•
Frontend: Flutter (Dart)
•
Design: Material Design 3 (Modern Slate & Indigo UI)
•
Backend: Firebase
◦
Firebase Auth: Secure authentication and session management.
◦
Cloud Firestore: Real-time NoSQL database with optimized security rules.
◦
Firebase Storage: Infrastructure ready for student resume management.
•
State Management: Reactive UI with StreamBuilder for zero-latency data syncing.
📸 Screenshots
Admin Dashboard
Placement Cell
Student View
Admin
Placement
Student
(Note: Add your screenshots to a /screenshots folder in the repository)
⚙️ Configuration & Installation
1.
Clone the repository:
Shell Script
git clone https://github.com/yourusername/placement_portal_app.git
2.
Setup Firebase:
◦
Create a project on the Firebase Console.
◦
Add an Android/iOS app and download the google-services.json or GoogleService-Info.plist.
◦
Enable Email/Password Authentication.
◦
Create a Firestore Database and apply the security rules provided in the project documentation.
3.
Install Dependencies:
Shell Script
flutter pub get
4.
Run the App:
Shell Script
flutter run
🛡 Security Policy
The platform implements a "Secure by Default" database policy:
•
Students can only read their own applications and profiles.
•
Placement Officers are restricted to viewing and managing data for jobs they personally posted.
•
Admins maintain global read/write authority for system maintenance and account authorization.
