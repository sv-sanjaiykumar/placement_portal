This guide explains how different types of users interact with the Placement Portal Application. 

For technical details, see the [[Architecture]] and [[Diagrams]] documents.

## User Roles

The application supports three primary roles:
1.  Admin
2.  Placement Cell
3.  Student

Authentication is handled via Firebase Authentication. The `AuthService` initially checks a predefined map for administrative accounts and then falls back to Firestore for dynamically created students.

### Admin Workflow

The Admin is responsible for platform oversight and user management.

1.  **Login**: Access the portal using the admin credentials.
2.  **Dashboard**: View high level statistics such as Total Users, Active Jobs, and Recent Activities.
3.  **User Management**: Navigate to the "Users" tab to view all registered students and Placement Cell accounts.
4.  **Create User**: Use the "Add Student" or Floating Action Button to manually register new students into the system. This action creates a secure account and maps their role in Firestore.

### Placement Cell Workflow

The Placement Cell manages job postings and interviews.

1.  **Login**: Access the portal using the placement cell credentials.
2.  **Dashboard**: View live metrics of Job Posts, Active Jobs, Applicants, and Shortlisted candidates.
3.  **Job Management**: Post new jobs or close existing ones directly from the dashboard.
4.  **Application Tracking**: Navigate to the "Applicants" tab. This page streams all student applications live. The Placement Cell can update application statuses (e.g., Shortlisted, Interview, Offer, Rejected).
5.  **Interview Scheduling**: View the upcoming interview schedules for shortlisted students in the "Schedule" tab.

### Student Workflow

Students use the app to browse and apply for jobs.

1.  **Login**: Access the portal using the credentials provided by the Admin.
2.  **Dashboard**: View application statistics and quick actions.
3.  **Browse Jobs**: Navigate to the "Jobs" tab to see all active postings.
4.  **Apply**: Select a job to view details and submit an application.
5.  **Track Status**: Check the "Applied" tab to monitor the live status of submitted applications.
6.  **Profile Management**: Update personal details and resume in the "Profile" tab.

Review the [[Features]] document for more specific functionalities.
