// ============================================================
// auth_service.dart
// Handles Firebase Authentication and role-based navigation.
//
// Strategy:
//   1. Authenticate with Firebase Auth (email + password).
//   2. Check hardcoded map first (fast, covers admin & placement cell).
//   3. If not in hardcoded map, query Firestore /users/{uid}
//      — this covers students created via the Admin "Create Student" page.
//   4. Return UserRole so the login screen can navigate correctly.
// ============================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ── Enum: All possible user roles ────────────────────────────
enum UserRole { admin, placementCell, student, unknown }

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Hardcoded role map ─────────────────────────────────────
  // Used for the 3 initial accounts only.
  // All students created via the Admin panel are resolved via Firestore.
  static const Map<String, UserRole> _hardcodedRoles = {
    'admin@gmail.com':   UserRole.admin,
    'company@gmail.com': UserRole.placementCell,
    'sanjaiy@gmail.com': UserRole.student,
  };

  // ── signIn ─────────────────────────────────────────────────
  // Authenticates with Firebase, then resolves the user's role.
  // Throws [FirebaseAuthException] on auth failure.
  Future<UserRole> signIn({
    required String email,
    required String password,
  }) async {
    // Step 1: Firebase authentication ─────────────────────────
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final normalizedEmail = email.trim().toLowerCase();

    // Step 2: Check hardcoded map first ────────────────────────
    // This instantly resolves admin & placement cell without a
    // Firestore round-trip.
    final hardcoded = _hardcodedRoles[normalizedEmail];
    if (hardcoded != null) return hardcoded;

    // Step 3: Firestore lookup for dynamically-created users ───
    // Students created by the Admin are stored in Firestore with
    // their UID as the document ID under /users/{uid}.
    try {
      final uid = credential.user!.uid;
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        final roleStr = doc.data()?['role'] as String? ?? 'unknown';

        switch (roleStr) {
          case 'admin':
            return UserRole.admin;
          case 'placementCell':
            return UserRole.placementCell;
          case 'student':
            return UserRole.student;
          default:
            return UserRole.unknown;
        }
      }
    } catch (_) {
      // Firestore read failed — treat as unknown rather than crash
    }

    // Step 4: Fallback ─────────────────────────────────────────
    // Email authenticated successfully but has no role assigned.
    return UserRole.unknown;
  }

  // ── signOut ────────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── currentUser ───────────────────────────────────────────
  User? get currentUser => _auth.currentUser;
}
