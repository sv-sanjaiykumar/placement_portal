import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool showCurrentPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;
  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(color: Color(0xFF64748B))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> changePassword() async {
    // Validation: Check if current password is empty
    if (currentPasswordController.text.isEmpty) {
      showErrorDialog("Empty Field", "Please enter your current password");
      return;
    }

    // Validation: Check if new password is empty
    if (newPasswordController.text.isEmpty) {
      showErrorDialog("Empty Field", "Please enter your new password");
      return;
    }

    // Validation: Check if confirm password is empty
    if (confirmPasswordController.text.isEmpty) {
      showErrorDialog("Empty Field", "Please confirm your new password");
      return;
    }

    // Validation: Check if new password is at least 6 characters
    if (newPasswordController.text.length < 6) {
      showErrorDialog(
        "Weak Password",
        "Password must be at least 6 characters long",
      );
      return;
    }

    // Validation: Check if new passwords match
    if (newPasswordController.text != confirmPasswordController.text) {
      showErrorDialog("Password Mismatch", "New passwords do not match");
      return;
    }

    // Validation: Check if new password is same as current password
    if (newPasswordController.text == currentPasswordController.text) {
      showErrorDialog(
        "Same Password",
        "New password cannot be the same as current password",
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      User? user = _auth.currentUser;

      if (user != null && user.email != null) {
        // Re-authenticate user with current password
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPasswordController.text,
        );

        await user.reauthenticateWithCredential(credential);

        // Update password
        await user.updatePassword(newPasswordController.text);

        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password changed successfully'),
            backgroundColor: const Color(0xFF10B981), // Emerald Green
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        // Clear fields
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();

        // Navigate back after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });

      String errorMessage = e.message ?? 'An error occurred';
      String errorTitle = 'Error';

      // Handle specific Firebase Auth errors
      if (e.code == 'wrong-password') {
        errorTitle = 'Wrong Password';
        errorMessage = 'The current password you entered is incorrect';
      } else if (e.code == 'weak-password') {
        errorTitle = 'Weak Password';
        errorMessage = 'The new password is too weak';
      } else if (e.code == 'requires-recent-login') {
        errorTitle = 'Re-authentication Required';
        errorMessage = 'Please logout and login again to change your password';
      }

      showErrorDialog(errorTitle, errorMessage);
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      showErrorDialog('Error', 'Failed to change password: $e');
    }
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  /// Helper to build modern text fields
  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isObscure,
    required VoidCallback toggleObscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A), // Slate 900
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure,
          style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)), // Slate 400
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF94A3B8), size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF94A3B8),
                size: 20,
              ),
              onPressed: toggleObscure,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)), // Slate 200
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5), // Indigo
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Modern slate-50 background

      appBar: AppBar(
        title: const Text(
          "Change Password",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Color(0xFF0F172A), // Slate 900
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F172A), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              
              /// SECURITY INFO BANNER
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF), // Blue 50
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: Color(0xFF3B82F6), size: 24), // Blue 500
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'For security purposes, you need to verify your current password.',
                        style: TextStyle(
                          color: const Color(0xFF1E3A8A).withOpacity(0.8), // Blue 900
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              _buildTextField(
                label: "Current Password",
                hint: "Enter your current password",
                controller: currentPasswordController,
                isObscure: !showCurrentPassword,
                toggleObscure: () => setState(() => showCurrentPassword = !showCurrentPassword),
              ),

              _buildTextField(
                label: "New Password",
                hint: "Enter your new password",
                controller: newPasswordController,
                isObscure: !showNewPassword,
                toggleObscure: () => setState(() => showNewPassword = !showNewPassword),
              ),

              _buildTextField(
                label: "Confirm New Password",
                hint: "Confirm your new password",
                controller: confirmPasswordController,
                isObscure: !showConfirmPassword,
                toggleObscure: () => setState(() => showConfirmPassword = !showConfirmPassword),
              ),

              const SizedBox(height: 12),

              /// CHANGE PASSWORD BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5), // Indigo 600
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: isLoading ? null : changePassword,
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Update Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              /// CANCEL BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B), // Slate 500
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
