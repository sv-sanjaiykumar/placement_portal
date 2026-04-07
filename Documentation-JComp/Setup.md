This document outlines the steps required to configure and run the Placement Portal application locally. 

Before proceeding, ensure you have reviewed the [[Architecture]] and [[Usage]] sections.

## Prerequisites

1.  Flutter SDK (v3.11.0 or higher)
2.  Dart SDK
3.  Firebase CLI
4.  Android Studio or VS Code with Flutter extension installed.

## Environment Setup

1.  Clone the repository and navigate into the `placement_portal_app` directory:
    ```bash
    git clone <repository_url>
    cd placement_portal_app
    ```

2.  Install dependencies:
    ```bash
    flutter pub get
    ```

## Firebase Configuration

The project uses Firebase for Authentication, Firestore Database, and Storage.

1.  Initialize Firebase in your project:
    ```bash
    flutterfire configure
    ```
2.  Select your Firebase project and the target platforms (Android, iOS, Web).
3.  This command will generate `firebase_options.dart` inside the `lib/` directory.

### Firestore Security Rules

Ensure your Firestore rules allow authenticated users to read and write data as needed. A basic rule set for development might look like this:

```text
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Running the Application

To run the application on an emulator or a connected device:

```bash
flutter run
```

## Build Release

To build a release APK for Android:

```bash
flutter build apk --release
```

For more details on features, refer to the [[Features]] document.
