This document contains visual representations of the Placement Portal system. It utilizes Mermaid syntax to define Class, Sequence, Block, and Architecture diagrams.

See [[Architecture]] for textual explanations of these diagrams.

## Architecture Diagram

This diagram shows the high level components of the system and how the Flutter frontend interacts with Firebase Backend services.

```mermaid
flowchart TD
    Client["Flutter Application Node"]
    Auth["Firebase Auth Node"]
    DB["Cloud Firestore Node"]
    Storage["Firebase Storage Node"]

    Client -->|Authenticates Credentials| Auth
    Client -->|Reads/Writes Jobs & Applications| DB
    Client -->|Fetches Profile Images| Storage
    DB -->|Streams Live Data| Client
```

## Block Diagram

This block diagram demonstrates the module hierarchy and how the application routes users based on their authenticated role.

```mermaid
flowchart LR
    AppEntry["App Initialization"]
    Splash["Splash Screen"]
    Login["Login Node"]
    
    AdminRole["Admin Module"]
    PlacementRole["Placement Cell Module"]
    StudentRole["Student Module"]
    
    AppEntry --> Splash
    Splash --> Login
    
    Login -->|If Admin| AdminRole
    Login -->|If Placement Cell| PlacementRole
    Login -->|If Student| StudentRole
    
    AdminRole --> UsersList["User Management"]
    PlacementRole --> JobPost["Job Posting"]
    PlacementRole --> Track["Track Applications"]
    StudentRole --> JobFeeds["Job Feed"]
    StudentRole --> Applied["My Applications"]
```

## Sequence Diagram

This sequence diagram details the login process. It highlights how the application utilizes a local lookup map before relying on a database call.

```mermaid
sequenceDiagram
    participant User
    participant LoginScreen
    participant AuthService
    participant FirebaseAuth
    participant Firestore

    User->>LoginScreen: Enter Email and Password
    LoginScreen->>AuthService: Call signIn()
    AuthService->>FirebaseAuth: Authenticate User
    
    alt Authentication Failed
        FirebaseAuth-->>AuthService: Throw Exception
        AuthService-->>LoginScreen: Return Error Message
        LoginScreen-->>User: Show SnackBar Error
    else Authentication Success
        FirebaseAuth-->>AuthService: Return FirebaseUser
        AuthService->>AuthService: Check Local Hardcoded Role Map
        
        alt Found in Local Map
            AuthService-->>LoginScreen: Return UserRole Enum
        else Not Found in Local Map
            AuthService->>Firestore: Request User Document
            Firestore-->>AuthService: Return Role String
            AuthService-->>LoginScreen: Return UserRole Enum
        end
        
        LoginScreen->>User: Navigate to Specific Dashboard
    end
```

## Class Diagram

This diagram displays the relationship between primary classes, specifically focusing on the authentication service and the dashboard structures.

```mermaid
classDiagram
    class PlacementHubApp {
      +build(BuildContext context) Widget
    }

    class AuthService {
      -FirebaseAuth _auth
      -FirebaseFirestore _firestore
      -Map _hardcodedRoles
      +signIn(String email, String password) Future~UserRole~
      +signOut() Future~void~
      +currentUser User
    }
    
    class UserRole {
      <<enumeration>>
      admin
      placementCell
      student
      unknown
    }

    class AdminDashboard {
      -int _currentIndex
      -_signOut() Future~void~
      -_openCreateStudent() void
      +build(BuildContext context) Widget
    }

    class PlacementCellDashboard {
      -int _currentIndex
      -List _statusOptions
      -_updateStatus(String docId, String newStatus) Future~void~
      -_signOut() Future~void~
      +build(BuildContext context) Widget
    }

    class StudentDashboard {
      -int currentIndex
      +build(BuildContext context) Widget
    }

    PlacementHubApp ..> AuthService : Uses
    AuthService ..> UserRole : Returns
    PlacementHubApp ..> AdminDashboard : Routes To
    PlacementHubApp ..> PlacementCellDashboard : Routes To
    PlacementHubApp ..> StudentDashboard : Routes To
```
