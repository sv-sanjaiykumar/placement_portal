import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController();
  final rollNumberController = TextEditingController();
  final emailController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;
  bool hasError = false;
  String errorMessage = '';

  late User? currentUser;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Always set email from Firebase Auth
        if (mounted) {
          setState(() {
            emailController.text = currentUser!.email ?? '';
          });
        }

        try {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.uid)
              .get();

          if (userDoc.exists) {
            Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

            if (mounted) {
              setState(() {
                nameController.text = data['name'] ?? '';
                rollNumberController.text = data['rollNumber'] ?? '';
                emailController.text = data['email'] ?? currentUser!.email ?? '';
                isLoading = false;
                hasError = false;
              });
            }
          } else {
            // If document doesn't exist, allow editing with auth email
            if (mounted) {
              setState(() {
                isLoading = false;
                hasError = false;
              });
            }
          }
        } on FirebaseException catch (e) {
          // Firestore error - allow user to continue with Firebase Auth data
          print('Firestore Error: $e');
          if (mounted) {
            setState(() {
              isLoading = false;
              hasError = true;
              errorMessage =
                  'Cloud Firestore is unavailable. You can still edit your profile with your current email.';
            });
          }
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = 'Error loading profile. Please try again.';
        });
      }
    }
  }

  Future<void> saveProfile() async {
    // Validation
    if (nameController.text.trim().isEmpty) {
      showErrorDialog("Empty Name", "Please enter your name");
      return;
    }

    if (rollNumberController.text.trim().isEmpty) {
      showErrorDialog("Empty Roll Number", "Please enter your roll number");
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      if (currentUser != null) {
        // Update Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .update({
              'name': nameController.text.trim(),
              'rollNumber': rollNumberController.text.trim(),
              'email': emailController.text.trim(),
              'updatedAt': DateTime.now(),
            });

        // Update Firebase Auth email if it changed
        if (emailController.text.trim() != currentUser!.email) {
          await currentUser!.verifyBeforeUpdateEmail(
            emailController.text.trim(),
          );
        }

        if (mounted) {
          setState(() {
            isSaving = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile updated successfully'),
              backgroundColor: const Color(0xFF10B981), // Emerald Green
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );

          // Navigate back after a short delay
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) Navigator.pop(context);
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => isSaving = false);
      String errorMessage = e.message ?? 'Authentication error occurred';
      showErrorDialog('Authentication Error', errorMessage);
    } catch (e) {
      if (mounted) setState(() => isSaving = false);
      showErrorDialog('Error', 'Failed to save profile: $e');
    }
  }

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

  @override
  void dispose() {
    nameController.dispose();
    rollNumberController.dispose();
    emailController.dispose();
    super.dispose();
  }

  /// Helper to build modern text fields efficiently
  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
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
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)), // Slate 400
              prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Modern slate-50 background

      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Color(0xFF0F172A),
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
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    
                    /// MODERN AVATAR HEADER
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
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
                              Icons.person_rounded, 
                              size: 50, 
                              color: Color(0xFF4F46E5)
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF4F46E5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                            ),
                          )
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),

                    /// ERROR BANNER
                    if (hasError)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2), // Red 50
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444)), // Red 500
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    errorMessage,
                                    style: const TextStyle(
                                      color: Color(0xFF991B1B), // Red 800
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton.icon(
                                icon: const Icon(Icons.refresh_rounded, size: 18),
                                label: const Text('Retry'),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFFEF4444),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: loadUserData,
                              ),
                            ),
                          ],
                        ),
                      ),

                    _buildTextField(
                      label: "Full Name",
                      hint: "Enter your full name",
                      icon: Icons.person_outline_rounded,
                      controller: nameController,
                    ),

                    _buildTextField(
                      label: "Roll Number",
                      hint: "Enter your roll number",
                      icon: Icons.badge_outlined,
                      controller: rollNumberController,
                    ),

                    _buildTextField(
                      label: "Email Address",
                      hint: "Enter your email",
                      icon: Icons.email_outlined,
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 12),

                    /// SAVE BUTTON
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
                        onPressed: isSaving ? null : saveProfile,
                        child: isSaving
                            ? const SizedBox(
                                height: 24, 
                                width: 24, 
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              )
                            : const Text(
                                'Save Changes',
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
