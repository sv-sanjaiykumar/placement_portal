This document catalogs the primary UI screens implemented within the Placement Portal. 

For the underlying structural flow, refer to the Block Diagram in [[Diagrams]].

## Role Selection & Authentication

*   **SplashScreen**: The initial screen that routes users based on their existing authentication state.
*   **RoleSelectionScreen**: Displays available roles to users before invoking specific login flows (currently simplified).
*   **LoginScreen**: Unified entry point handling credential validation. Uses `AuthService` to redirect to the appropriate dashboard.
*   **SignupScreen**: Standard registration form.

## Dashboards

### AdminDashboard

*   **Layout**: Uses a bottom navigation bar (`IndexedStack`) containing Dashboard, Users, and Settings tabs.
*   **Home Tab**: Displays aggregated platform statistics and a static recent activity feed.
*   **Users Tab**: Lists existing admins, placement cells, and students.
*   **Settings Tab**: Houses the logout trigger and placeholder configurations.

### PlacementCellDashboard

*   **Layout**: Bottom navigation containing Dashboard, Applicants, and Schedule.
*   **Dashboard Tab**: Shows "Post a New Job" button, overarching metrics, and a dynamic feed of active job postings.
*   **Applicants Tab**: Streams applications from Firestore, providing a dropdown to update individual application states.
*   **Schedule Tab**: Displays upcoming interview schedules.

### StudentDashboard

*   **Layout**: Bottom navigation containing Home, Jobs, Applied, Alerts, and Profile.
*   **Home Tab**: A personalized view showing the user's application stats and quick access cards.
*   **Jobs Tab**: Retrieves and displays active job listings available for application.
*   **Applied Tab**: Shows jobs the student has explicitly applied to.
*   **Profile Tab**: Contains editable user information.

## Sub-Screens

*   **CreateStudentScreen**: Used uniquely by the Admin to provision a new user account into Firebase Authentication and map it in Firestore.
*   **PostJobScreen**: Allows the Placement Cell to input job requirements and push the new document to the `jobs` collection.
*   **JobDetailsScreen**: A read only view allowing a student to review a specific job before clicking the "Apply" button.

See [[Architecture]] for data handling mechanisms behind these screens.
