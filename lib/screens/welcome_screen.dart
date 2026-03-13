import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Widget _buildFeatureTile(IconData icon, String title, String subtitle, Color color, Color bgColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16), // Squircle shape
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A), // Slate 900
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B), // Slate 500
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                /// BRAND LOGO
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF), // Indigo 50
                    borderRadius: BorderRadius.circular(28), // Large squircle
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withOpacity(0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      )
                    ]
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.school_rounded,
                      size: 44,
                      color: Color(0xFF4F46E5), // Indigo 600
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                /// TITLE
                const Text(
                  "Welcome to\nPlacementHub",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A), // Slate 900
                    letterSpacing: -0.5,
                    height: 1.2, // Tighter line height
                  ),
                ),

                const SizedBox(height: 12),

                /// SUBTITLE
                const Text(
                  "Your complete solution for campus\nplacement management",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF64748B), // Slate 500
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 48),

                /// FEATURES
                _buildFeatureTile(
                  Icons.business_center_outlined,
                  "Find Jobs",
                  "Browse and apply to top companies",
                  const Color(0xFF3B82F6), // Blue 500
                  const Color(0xFFEFF6FF), // Blue 50
                ),

                _buildFeatureTile(
                  Icons.people_outline_rounded,
                  "Track Applications",
                  "Manage all your applications in one place",
                  const Color(0xFF8B5CF6), // Purple 500
                  const Color(0xFFF5F3FF), // Purple 50
                ),

                _buildFeatureTile(
                  Icons.rocket_launch_outlined,
                  "Get Placed",
                  "Land your dream job with our guidance",
                  const Color(0xFF10B981), // Emerald 500
                  const Color(0xFFECFDF5), // Emerald 50
                ),

                const SizedBox(height: 48),

                /// LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5), // Indigo 600
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: const Color(0xFF4F46E5).withOpacity(0.4), // Glowing shadow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// SIGNUP BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5), // Slate 200
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      foregroundColor: const Color(0xFF0F172A), // Slate 900
                      backgroundColor: Colors.white, // Keep background white on tap
                    ),
                    child: const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
