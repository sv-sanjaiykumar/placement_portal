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
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
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

      // Navigate to Role Selection Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String errorTitle = "Login Failed";
      String errorMessage = e.message ?? "An error occurred during login";

      // Customize error messages based on Firebase error codes
      if (e.code == 'user-not-found') {
        errorTitle = "User Not Found";
        errorMessage = "No account found with this email address";
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
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffECECF1),

      body: Padding(
        padding: const EdgeInsets.all(25),

        child: ListView(
          children: [
            const SizedBox(height: 40),

            const Icon(Icons.school, size: 80, color: Colors.blue),

            const SizedBox(height: 20),

            const Text(
              "Welcome Back",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            const Text(
              "Login to continue your journey",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 30),

            const Text("Email Address"),

            const SizedBox(height: 5),

            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: "your.email@example.com",
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            const Text("Password"),

            const SizedBox(height: 5),

            TextField(
              controller: passwordController,
              obscureText: hidePassword,
              decoration: InputDecoration(
                hintText: "Enter your password",
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    hidePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      hidePassword = !hidePassword;
                    });
                  },
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Checkbox(
                  value: rememberMe,
                  onChanged: (value) {
                    setState(() {
                      rememberMe = value!;
                    });
                  },
                ),

                const Text("Remember me"),

                const Spacer(),

                TextButton(
                  onPressed: () {},
                  child: const Text("Forgot Password?"),
                ),
              ],
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.all(15),
                ),

                onPressed: loading ? null : loginUser,

                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Login"),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                const Text("Don't have an account? "),

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
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
