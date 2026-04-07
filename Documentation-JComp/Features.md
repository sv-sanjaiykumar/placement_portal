This document outlines the core functional requirements implemented in the Placement Portal application.

See [[Screens]] for visual structure and [[Diagrams]] for data flow.

## Authentication and Authorization

*   **Role Based Access Control**: Users are routed to distinct dashboards based on their role (Admin, Placement Cell, Student).
*   **Secure Login**: Powered by Firebase Authentication using email and password.
*   **Dynamic Role Resolution**: Custom `AuthService` handles immediate resolution for static admins and asynchronous resolution via Firestore for dynamically added students.

## Job Management (Placement Cell)

*   **Create Job Postings**: Placement cell can define job title, company, salary, and location.
*   **Toggle Job Status**: Jobs can be marked as "Active" or "Closed".
*   **Live Metrics**: Dashboard streams live updates of applicants per job without manual refreshes.

## Application Tracking

*   **Live Application Feed**: The Placement Cell sees incoming applications instantly via Firestore snapshot streams.
*   **Status Updates**: Applications traverse through states: Applied, Shortlisted, Interview, Offer, and Rejected.
*   **Student Visibility**: Students can view exactly where they stand in the hiring pipeline.

## User Management (Admin)

*   **Student Creation**: Admins can onboard new students, provisioning them with access to the platform.
*   **System Analytics**: Admins can monitor overall platform health, recent activities, and user statistics.

## UI and UX Elements

*   **Modern Aesthetics**: Glassmorphism, gradients, and custom SVGs are prominent across the application.
*   **Responsive Index Stacks**: Bottom navigators utilize `IndexedStack` to maintain screen state during tab switches.
*   **Real Time UIs**: `StreamBuilder` widgets ensure that any database update is immediately reflected on the user interface.

See the [[Setup]] guide to run the application locally.
