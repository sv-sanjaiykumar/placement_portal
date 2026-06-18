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

  /// ════════════════════════════════════════════════════════════════
  /// ADMIN SECTION: Create users with specified roles
  /// ════════════════════════════════════════════════════════════════

  /// Create a new user with admin-provided credentials
  /// Only admins should be able to call this method
  Future<bool> createUserByAdmin({
    required String email,
    required String password,
    required String role,
    required String fullName,
    required String department,
    String? employeeCode,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('You must be logged in as admin to create users');
      }

      // Verify user is admin by checking Firestore
      final adminDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (!adminDoc.exists || adminDoc.data()?['role'] != 'admin') {
        throw Exception('Only admins can create users');
      }

      // Step 1: Create Firebase Auth account for the new user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password.trim(),
      );

      final newUserId = userCredential.user?.uid;
      if (newUserId == null) throw Exception('Failed to create user account');

      final now = DateTime.now();

      // Step 2: Create user document in 'users' collection with role mapping
      await _firestore.collection('users').doc(newUserId).set({
        'email': email.trim().toLowerCase(),
        'role': role.trim(),
        'department': department.trim(),
        'fullName': fullName.trim(),
        'createdAt': now,
        'createdBy': currentUser.uid,
        'isActive': true,
      });

      // Step 3: Create record in 'admin_created_users' for tracking
      await _firestore.collection('admin_created_users').add({
        'email': email.trim().toLowerCase(),
        'role': role.trim(),
        'department': department.trim(),
        'fullName': fullName.trim(),
        'employeeCode': employeeCode?.trim() ?? '',
        'createdAt': now,
        'createdBy': currentUser.uid,
        'isActive': true,
      });

      return true;
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  /// Get all users created by admin (with pagination support)
  Future<List<Map<String, dynamic>>> getAdminCreatedUsers({
    int limit = 50,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('admin_created_users')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('Error fetching admin created users: $e');
      rethrow;
    }
  }

  /// Deactivate a user (soft delete)
  Future<void> deactivateUser(String userId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Not authenticated');

      // Verify current user is admin
      final adminDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (adminDoc.data()?['role'] != 'admin') {
        throw Exception('Only admins can deactivate users');
      }

      await _firestore.collection('users').doc(userId).update({
        'isActive': false,
      });
    } catch (e) {
      print('Error deactivating user: $e');
      rethrow;
    }
  }

  /// Reactivate a deactivated user
  Future<void> reactivateUser(String userId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Not authenticated');

      // Verify current user is admin
      final adminDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (adminDoc.data()?['role'] != 'admin') {
        throw Exception('Only admins can reactivate users');
      }

      await _firestore.collection('users').doc(userId).update({
        'isActive': true,
      });
    } catch (e) {
      print('Error reactivating user: $e');
      rethrow;
    }
  }

  /// ════════════════════════════════════════════════════════════════
  /// USER SECTION: Login with admin-created credentials
  /// ════════════════════════════════════════════════════════════════

  /// Resolve user role from Firestore
  Future<UserRole> _resolveRoleFromFirestore({
    required String uid,
    required String email,
  }) async {
    try {
      // First, try to get user by UID
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data?['isActive'] == false) {
          return UserRole.unknown; // User is deactivated
        }
        return _parseRole(data?['role'] as String?);
      }

      // Fallback: try to find by email
      final byEmail = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase())
          .limit(1)
          .get();

      if (byEmail.docs.isNotEmpty) {
        final data = byEmail.docs.first.data();
        if (data['isActive'] == false) {
          return UserRole.unknown; // User is deactivated
        }
        return _parseRole(data['role'] as String?);
      }

      return UserRole.unknown;
    } catch (e) {
      print('Error resolving role: $e');
      return UserRole.unknown;
    }
  }

  /// Sign in with admin-provided credentials
  /// The user must exist in admin_created_users collection
  Future<UserRole> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();

      // Step 1: Verify user exists in admin_created_users
      final createdUserSnapshot = await _firestore
          .collection('admin_created_users')
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();

      if (createdUserSnapshot.docs.isEmpty) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Your account was not created by an administrator. Please contact support.',
        );
      }

      final createdUserData = createdUserSnapshot.docs.first.data();
      if (createdUserData['isActive'] != true) {
        throw FirebaseAuthException(
          code: 'user-disabled',
          message: 'Your account has been deactivated. Please contact an administrator.',
        );
      }

      // Step 2: Authenticate with Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password.trim(),
      );

      final user = credential.user;
      if (user == null) return UserRole.unknown;

      // Step 3: Resolve and return user role
      try {
        return await _resolveRoleFromFirestore(
          uid: user.uid,
          email: normalizedEmail,
        );
      } catch (_) {
        return UserRole.unknown;
      }
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      print('Unexpected error during login: $e');
      throw FirebaseAuthException(
        code: 'internal-error',
        message: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Resolve the current logged-in user's role
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

  /// ════════════════════════════════════════════════════════════════
  /// GENERAL SECTION: Authentication utilities
  /// ════════════════════════════════════════════════════════════════

  /// Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get the current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Get current user's email
  String? get currentUserEmail => _auth.currentUser?.email;

  /// Check if user is currently authenticated
  bool get isAuthenticated => _auth.currentUser != null;
}
