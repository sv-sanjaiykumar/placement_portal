import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_dashboard.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool loading = false;
  String role = "student";

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Signup Error', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          message,
          style: const TextStyle(color: Color(0xFF64748B)), // Slate 500
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)), // Indigo 600
          ),
        ],
      ),
    );
  }

  Future<void> signupUser() async {
    if (passwordController.text != confirmPasswordController.text) {
      showErrorDialog("Passwords do not match.");
      return;
    }

    if (nameController.text.trim().isEmpty || emailController.text.trim().isEmpty) {
      showErrorDialog("Please fill in all fields.");
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      await _firestore.collection("users").doc(uid).set({
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "role": role,
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const StudentDashboard(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        showErrorDialog(e.message ?? "An error occurred during signup.");
      }
    } catch (e) {
      if (mounted) {
        showErrorDialog("An unexpected error occurred. Please try again.");
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  /// Modern helper widget for text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onVisibilityToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF334155), // Slate 700
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)), // Slate 400
            prefixIcon: Icon(prefixIcon, color: const Color(0xFF64748B), size: 22), // Slate 500
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: const Color(0xFF64748B),
                      size: 20,
                    ),
                    onPressed: onVisibilityToggle,
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)), // Slate 200
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2), // Indigo 600
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                const SizedBox(height: 20),

                /// BRAND LOGO
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF), // Indigo 50
                    borderRadius: BorderRadius.circular(24), // Squircle
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ]
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.school_rounded,
                      size: 40,
                      color: Color(0xFF4F46E5), // Indigo 600
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                /// TITLE & SUBTITLE
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A), // Slate 900
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Join PlacementHub today",
                  style: TextStyle(
                    color: Color(0xFF64748B), // Slate 500
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 48),

                /// FULL NAME
                _buildTextField(
                  controller: nameController,
                  label: "Full Name",
                  hint: "John Doe",
                  prefixIcon: Icons.person_outline_rounded,
                ),

                const SizedBox(height: 20),

                /// EMAIL
                _buildTextField(
                  controller: emailController,
                  label: "Email Address",
                  hint: "your.email@example.com",
                  prefixIcon: Icons.email_outlined,
                ),

                const SizedBox(height: 20),

                /// PASSWORD
                _buildTextField(
                  controller: passwordController,
                  label: "Password",
                  hint: "Create a strong password",
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  obscureText: hidePassword,
                  onVisibilityToggle: () {
                    setState(() {
                      hidePassword = !hidePassword;
                    });
                  },
                ),

                const SizedBox(height: 20),

                /// CONFIRM PASSWORD
                _buildTextField(
                  controller: confirmPasswordController,
                  label: "Confirm Password",
                  hint: "Confirm your password",
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  obscureText: hideConfirmPassword,
                  onVisibilityToggle: () {
                    setState(() {
                      hideConfirmPassword = !hideConfirmPassword;
                    });
                  },
                ),

                const SizedBox(height: 40),

                /// SIGNUP BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: loading ? null : signupUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5), // Indigo 600
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: const Color(0xFF4F46E5).withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text(
                            "Create Account",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 32),

                /// BACK TO LOGIN
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: Color(0xFF64748B), // Slate 500
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Color(0xFF4F46E5), // Indigo 600
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
