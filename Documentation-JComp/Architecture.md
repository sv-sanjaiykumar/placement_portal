This document describes the technical foundation of the Placement Portal. 

Please see [[Diagrams]] for visual representations of this architecture.

## Overview

The Placement Portal is built as a Flutter mobile application communicating with Firebase as a Backend as a Service (BaaS). The architecture heavily utilizes reactive streams.

## Core Technologies

*   **Framework**: Flutter (Dart)
*   **Authentication**: Firebase Auth
*   **Database**: Cloud Firestore (NoSQL)
*   **Design Pattern**: Model View Controller (Implied architectural separation via `services` and `screens`)

## State Management

While BLoC and Provider are present in the dependency tree, the current implementation relies heavily on `StatefulWidget` and `StreamBuilder` widgets. 

### Why StreamBuilder?

Because the primary objective is to maintain a live connection to Firestore databases (e.g., jobs and applications), `StreamBuilder` naturally solves the data synchronization problem. 
*   **Pros**: Real time updates, requires minimal boilerplate, native Flutter integration.
*   **Cons**: Tightly couples UI with database instances.

## Data Structure

Firestore is broken into two primary collections:

1.  **users**: Stores custom claims or roles for dynamically created accounts. Document ID matches the Firebase Auth UID.
2.  **jobs**: Contains job postings created by the Placement Cell.
    *   Fields: `company`, `title`, `salary`, `location`, `status`, `createdAt`, `postedBy`.
3.  **applications**: Contains documents representing a student's application to a job.
    *   Fields: `jobId`, `studentUid`, `status` (Applied, Shortlisted, Review, Rejected), `appliedAt`.

## Authentication Flow

Authentication deviates slightly from a standard paradigm to accommodate fast logins for specific accounts.

1.  User enters credentials.
2.  `AuthService` queries Firebase Auth.
3.  Upon success, `AuthService` checks a local hardcoded map for admin and placement cell emails to bypass network latency.
4.  If the email is not found, `AuthService` queries the `users` Firestore collection.
5.  A `UserRole` enum is returned to the UI caller, dynamically pushing the correct `*Dashboard` route onto the Navigator.

Refer to [[Usage]] to see how users interact with this architecture.
