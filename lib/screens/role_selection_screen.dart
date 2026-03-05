import 'package:flutter/material.dart';
import 'package:placement_portal_app/screens/student_dashboard.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  Widget roleCard(
      IconData icon,
      String title,
      String subtitle,
      Color color,
      VoidCallback onTap) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300),
        ),

        child: Row(
          children: [

            /// ICON
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 30),
            ),

            const SizedBox(width: 20),

            /// TEXT AREA (FIXED OVERFLOW HERE)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    subtitle,
                    style: const TextStyle(
                        color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xffECECF1),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Text(
                "Select Your Role",
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              const Text(
                "Choose how you want to use PlacementHub",
                style: TextStyle(color: Colors.black54),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              roleCard(
                Icons.school,
                "Student",
                "Browse jobs, apply, and track applications",
                Colors.blue,
                    () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const StudentDashboard(),
                    ),
                  );
                },
              ),

              roleCard(
                Icons.work,
                "Recruiter",
                "Post jobs and manage candidates",
                Colors.purple,
                    () {},
              ),

              roleCard(
                Icons.security,
                "Administrator",
                "Manage placement process and analytics",
                Colors.green,
                    () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}