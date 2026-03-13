import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_screen.dart';
import 'role_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool rememberMe = false;
  bool hidePassword = true;
  bool loading = false;

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

  Future<void> loginUser() async {
    // Validation: Check if email is empty
    if (emailController.text.trim().isEmpty) {
      showErrorDialog("Empty Email", "Please enter your email address");
      return;
    }

    // Validation: Check if password is empty
    if (passwordController.text.trim().isEmpty) {
      showErrorDialog("Empty Password", "Please enter your password");
      return;
    }

    // Validation: Check if email format is valid
    if (!emailController.text.contains("@")) {
      showErrorDialog("Invalid Email", "Please enter a valid email address");
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Navigate to Role Selection Screen if widget is still mounted
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => loading = false);
      String errorTitle = "Login Failed";
      String errorMessage = e.message ?? "An error occurred during login";

      // Customize error messages based on Firebase error codes
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        errorTitle = "User Not Found";
        errorMessage = "No account found or invalid credentials provided.";
      } else if (e.code == 'wrong-password') {
        errorTitle = "Wrong Password";
        errorMessage = "The password you entered is incorrect";
      } else if (e.code == 'invalid-email') {
        errorTitle = "Invalid Email";
        errorMessage = "The email format is invalid";
      } else if (e.code == 'user-disabled') {
        errorTitle = "Account Disabled";
        errorMessage = "This account has been disabled";
      } else if (e.code == 'too-many-requests') {
        errorTitle = "Too Many Attempts";
        errorMessage = "Too many failed login attempts. Please try again later";
      }

      showErrorDialog(errorTitle, errorMessage);
    } catch (e) {
      if (mounted) setState(() => loading = false);
      showErrorDialog("Error", "An unexpected error occurred");
    }
  }
  
  // Custom helper for modern text fields
  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
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
          obscureText: isPassword ? hidePassword : false,
          style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)), // Slate 400
            prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: const Color(0xFF94A3B8),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                  )
                : null,
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
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Modern slate-50 background

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                /// LOGO & GREETING
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF), // Indigo 50
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  ),
                  child: const Icon(
                    Icons.school_rounded, 
                    size: 40, 
                    color: Color(0xFF4F46E5) // Indigo 600
                  ),
                ),
                
                const SizedBox(height: 24),

                const Text(
                  "Welcome Back",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A), // Slate 900
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Login to continue your journey",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF64748B), // Slate 500
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 40),

                /// INPUT FIELDS
                _buildTextField(
                  label: "Email Address",
                  hint: "your.email@example.com",
                  icon: Icons.email_outlined,
                  controller: emailController,
                ),

                _buildTextField(
                  label: "Password",
                  hint: "Enter your password",
                  icon: Icons.lock_outline_rounded,
                  controller: passwordController,
                  isPassword: true,
                ),

                /// OPTIONS (Remember Me / Forgot Password)
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: rememberMe,
                        activeColor: const Color(0xFF4F46E5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Remember me",
                      style: TextStyle(
                        color: Color(0xFF475569), // Slate 600
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),

                    const Spacer(),

                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Color(0xFF4F46E5), // Indigo 600
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                /// LOGIN BUTTON
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      elevation: 0,
                      shadowColor: const Color(0xFF4F46E5).withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: loading ? null : loginUser,
                    child: loading
                        ? const SizedBox(
                            height: 24, 
                            width: 24, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 32),

                /// SIGN UP LINK
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: Color(0xFF64748B), // Slate 500
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign up",
                        style: TextStyle(
                          color: Color(0xFF4F46E5), // Indigo 600
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
