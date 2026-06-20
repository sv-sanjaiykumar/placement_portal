# 🎓 PlacementHub - Campus Placement Portal

## 📌 Overview

**PlacementHub** is a full-stack, role-based mobile application developed using **Flutter** and **Firebase** to digitize and streamline the campus recruitment process. The platform provides a centralized ecosystem that connects **Administrators**, **Placement Officers**, and **Students**, enabling efficient management of placement activities, job opportunities, applications, and interview schedules.

The application focuses on security, scalability, and real-time communication, ensuring a seamless experience for all stakeholders involved in campus placements.

---

## ✨ Features

### 🔐 Secure Authentication & Access Control

* **Admin-Controlled Account Creation**

  * Student and staff accounts are created exclusively by the administrator.
  * Prevents unauthorized access and ensures only verified users can access the platform.

* **Role-Based Access Management**

  * Automatic dashboard navigation based on user roles.
  * Separate interfaces for:

    * Administrator
    * Placement Officer
    * Student

* **Secure Session Management**

  * Implemented using Firebase Authentication with secondary Firebase instances.
  * Allows administrators to manage user accounts without affecting their active session.

---

## 👨‍💼 Administrator Module

The Administrator serves as the central authority for managing the placement ecosystem.

### Key Functionalities

* User Creation and Management
* Account Activation / Deactivation
* Role Assignment and Permission Management
* Department-wise Staff Management
* System Monitoring and Analytics

### Dashboard Analytics

* Total Registered Users
* Active Job Postings
* Total Applications
* Placement Statistics
* Real-Time Platform Insights

---

## 🏢 Placement Officer Module

The Placement Officer manages recruitment activities and student applications.

### Job Management

* Create, Update, Delete, and Publish Job Opportunities
* Define Eligibility Criteria
* Configure CGPA Requirements
* Specify Salary Packages and Job Descriptions

### Applicant Tracking System

* View Applications in Real Time
* Track Candidate Progress
* Update Application Status:

  * Applied
  * Shortlisted
  * Interview Scheduled
  * Selected
  * Rejected

### Interview Scheduling

* Schedule Interviews
* Configure Date, Time, and Mode
* Send Automated Notifications to Students

---

## 🎓 Student Module

Students can explore opportunities and manage their placement activities through a personalized dashboard.

### Job Discovery

* Browse Available Opportunities
* Search and Filter Jobs
* View Eligibility Requirements

### Application Management

* One-Tap Job Application
* Duplicate Application Prevention
* Track Application Status in Real Time

### Profile Management

* Academic Information
* Department Details
* Contact Information
* Placement Eligibility Data

### Notifications

* New Job Alerts
* Interview Invitations
* Status Updates
* Placement Announcements

---

## 🏗️ Technology Stack

### Frontend

* **Flutter**
* **Dart**
* **Material Design 3**

### Backend & Cloud Services

#### Firebase Authentication

* Secure user authentication
* Role-based login system
* Session management

#### Cloud Firestore

* Real-time NoSQL database
* Scalable and cloud-hosted
* Optimized security rules

#### Firebase Storage

* Resume storage support
* Document management infrastructure

### State Management

* Reactive UI using **StreamBuilder**
* Real-time data synchronization
* Efficient state updates with minimal latency

---

## 📂 Project Architecture

```text
lib/
│
├── core/
│   ├── services/
│   ├── constants/
│   └── utilities/
│
├── features/
│   ├── authentication/
│   ├── admin/
│   ├── placement_cell/
│   └── student/
│
├── models/
├── repositories/
├── widgets/
└── main.dart
```
## ⚙️ Installation Guide

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/placementhub.git
cd placementhub
```

### 2. Configure Firebase

1. Create a Firebase Project.
2. Register Android and/or iOS applications.
3. Download configuration files:

   * `google-services.json`
   * `GoogleService-Info.plist`
4. Enable Email/Password Authentication.
5. Create a Cloud Firestore Database.
6. Configure Firestore Security Rules.

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run the Application

```bash
flutter run
```

---

## 🔒 Security Architecture

PlacementHub follows a **Secure-by-Default** approach.

### Student Permissions

* Read and update their own profile
* Apply for jobs
* View only their applications

### Placement Officer Permissions

* Manage jobs they created
* Access applications related to their postings
* Schedule interviews

### Administrator Permissions

* Full system access
* User management
* Role assignment
* Platform monitoring

---

## 🚀 Future Enhancements

* Resume Upload & Management
* ATS-Based Resume Screening
* Alumni Networking Module
* Company Portal Integration
* Placement Analytics Dashboard
* Push Notifications
* Multi-Department Placement Reports

---

## 👨‍💻 Developer

**Sanjaiykumar S V**

Flutter Developer | Firebase Enthusiast | Mobile App Developer

* Flutter
* Firebase
* MVVM Architecture
* BLoC State Management
* REST API Integration

---

## 📄 License

This project is licensed under the MIT License.

Feel free to fork, contribute, and enhance the project.
