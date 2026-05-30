import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, placementCell, student, unknown }

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserRole _parseRole(String? roleStr) {
    switch ((roleStr ?? '').trim()) {
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

  Future<UserRole> _resolveRoleFromFirestore({
    required String uid,
    required String email,
  }) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return _parseRole(doc.data()?['role'] as String?);
    }

    final byEmail = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (byEmail.docs.isNotEmpty) {
      return _parseRole(byEmail.docs.first.data()['role'] as String?);
    }

    return UserRole.unknown;
  }

  Future<UserRole> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = credential.user;
    if (user == null) return UserRole.unknown;

    try {
      return await _resolveRoleFromFirestore(
        uid: user.uid,
        email: (user.email ?? email).trim().toLowerCase(),
      );
    } catch (_) {
      return UserRole.unknown;
    }
  }

  Future<UserRole> resolveCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return UserRole.unknown;

    try {
      return await _resolveRoleFromFirestore(
        uid: user.uid,
        email: (user.email ?? '').trim().toLowerCase(),
      );
    } catch (_) {
      return UserRole.unknown;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
