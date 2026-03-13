import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:placement_portal_app/screens/settings_page.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User? currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isUploadingResume = false;
  String? resumeFileName;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .get();

        if (userDoc.exists && mounted) {
          setState(() {
            userData = userDoc.data() as Map<String, dynamic>;
            resumeFileName = userData?['resumeFileName'];
            isLoading = false;
          });
        } else if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> uploadResume() async {
    try {
      // Pick a PDF file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          isUploadingResume = true;
        });

        String fileName = '${currentUser!.uid}_resume.pdf';
        String fileSize =
            '${(result.files.single.size / 1024 / 1024).toStringAsFixed(2)} MB';

        // Upload to Firebase Storage
        await FirebaseStorage.instance
            .ref('resumes/$fileName')
            .putFile(File(result.files.single.path!));

        // Update Firestore with resume info
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .update({
              'resumeFileName': result.files.single.name,
              'resumePath': 'resumes/$fileName',
              'resumeUploadedAt': DateTime.now(),
              'fileSize': fileSize,
            });

        if (mounted) {
          setState(() {
            isUploadingResume = false;
            resumeFileName = result.files.single.name;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Resume uploaded successfully'),
              backgroundColor: const Color(0xFF10B981), // Emerald 500
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }

        // Refresh user data
        await fetchUserData();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isUploadingResume = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading resume: $e'),
            backgroundColor: const Color(0xFFEF4444), // Red 500
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> deleteResume() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Resume', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to delete your resume?',
          style: TextStyle(color: Color(0xFF64748B)), // Slate 500
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await performDelete();
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> performDelete() async {
    try {
      setState(() {
        isUploadingResume = true;
      });

      String fileName = '${currentUser!.uid}_resume.pdf';

      // Delete from Firebase Storage
      await FirebaseStorage.instance.ref('resumes/$fileName').delete();

      // Update Firestore to remove resume info
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({
            'resumeFileName': '',
            'resumePath': '',
            'resumeUploadedAt': null,
            'fileSize': '',
          });

      if (mounted) {
        setState(() {
          isUploadingResume = false;
          resumeFileName = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Resume deleted successfully'),
            backgroundColor: const Color(0xFF10B981), // Emerald 500
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }

      // Refresh user data
      await fetchUserData();
    } catch (e) {
      if (mounted) {
        setState(() {
          isUploadingResume = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting resume: $e'),
            backgroundColor: const Color(0xFFEF4444), // Red 500
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50

      body: Column(
        children: [
          /// MODERN HEADER
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              left: 20,
              right: 20,
              bottom: 30,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6366F1), // Indigo 500
                  Color(0xFF4F46E5), // Indigo 600
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                
                /// BACK BUTTON
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const Text(
                  "My Profile",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                /// SETTINGS NAVIGATION
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// PROFILE CONTENT
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        
                        /// PROFILE CARD
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: Column(
                            children: [
                              
                              // MODERN AVATAR
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFEEF2FF), // Indigo 50
                                  border: Border.all(color: Colors.white, width: 4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4F46E5).withOpacity(0.15),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    )
                                  ]
                                ),
                                child: Center(
                                  child: Text(
                                    (userData?['name'] ?? 'U')[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4F46E5), // Indigo 600
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              Text(
                                userData?['name'] ?? 'User Name',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A), // Slate 900
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                userData?['rollNumber'] ?? 'Roll Number',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF475569), // Slate 600
                                ),
                              ),
                              
                              const SizedBox(height: 4),

                              Text(
                                userData?['email'] ?? currentUser?.email ?? 'email@student.edu',
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8), // Slate 400
                                  fontSize: 14,
                                ),
                              ),

                              const SizedBox(height: 20),

                              // ROLE BADGE
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF), // Indigo 50
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Role: ${userData?['role'] ?? 'Student'}',
                                  style: const TextStyle(
                                    color: Color(0xFF4F46E5), // Indigo 600
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// RESUME SECTION
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.description_outlined,
                                    color: Color(0xFF3B82F6), // Blue 500
                                    size: 24,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Resume',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              if (resumeFileName == null || resumeFileName!.isEmpty)
                                // EMPTY STATE
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC), // Slate 50
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0), // Slate 200
                                      width: 1.5,
                                      // Ideally use a dashed border package here, but solid is fine for basic Flutter
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.05),
                                              blurRadius: 10,
                                            )
                                          ]
                                        ),
                                        child: const Icon(
                                          Icons.cloud_upload_outlined,
                                          color: Color(0xFF94A3B8), // Slate 400
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'No Resume Uploaded',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1E293B), // Slate 800
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Upload a PDF resume to apply for jobs',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Color(0xFF64748B), // Slate 500
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                // UPLOADED STATE
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5), // Emerald 50
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFA7F3D0), // Emerald 200
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.picture_as_pdf_rounded,
                                          color: Color(0xFF10B981), // Emerald 500
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              resumeFileName!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                            if (userData?['fileSize'] != null && userData?['fileSize']!.isNotEmpty)
                                              ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${userData?['fileSize']} • PDF document',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                              ]
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 24),

                              /// UPLOAD/REPLACE BUTTON
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  icon: isUploadingResume 
                                    ? const SizedBox(
                                        width: 20, 
                                        height: 20, 
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                      )
                                    : const Icon(Icons.cloud_upload_outlined, size: 20),
                                  label: Text(
                                    isUploadingResume 
                                      ? 'Processing...' 
                                      : (resumeFileName == null || resumeFileName!.isEmpty ? 'Upload Resume' : 'Replace Resume'),
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4F46E5), // Indigo 600
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: isUploadingResume ? null : uploadResume,
                                ),
                              ),

                              if (resumeFileName != null && resumeFileName!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: OutlinedButton.icon(
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Color(0xFFE11D48), // Rose 600
                                        size: 20,
                                      ),
                                      label: const Text(
                                        'Delete Resume',
                                        style: TextStyle(
                                          color: Color(0xFFE11D48),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Color(0xFFFECDD3)), // Rose 200
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        backgroundColor: const Color(0xFFFFF1F2), // Rose 50
                                      ),
                                      onPressed: isUploadingResume ? null : deleteResume,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
