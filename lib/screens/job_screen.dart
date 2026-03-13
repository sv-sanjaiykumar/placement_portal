import 'package:flutter/material.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  /// Modern helper widget for tags (e.g., "Fulltime", "Remote")
  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Refined Modern Job Card
  Widget _buildJobCard({
    required String title,
    required String company,
    required String location,
    required String salary,
    required Color logoBgColor,
    required Color logoColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)), // Slate 100
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          /// TOP ROW: Logo, Title, Bookmark
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modern square-ish logo container
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: logoBgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.business_center_rounded, color: logoColor, size: 28),
              ),
              
              const SizedBox(width: 16),
              
              // Title & Company
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A), // Slate 900
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      company,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B), // Slate 500
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bookmark Button
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Icon(
                  Icons.bookmark_outline_rounded,
                  size: 20,
                  color: Color(0xFF94A3B8), // Slate 400
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// META ROW: Location & Salary
          Row(
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 6),
                  Text(
                    location,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  const Icon(Icons.monetization_on_outlined, size: 18, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 6),
                  Text(
                    salary,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// TAGS ROW
          Row(
            children: [
              _buildTag("Fulltime", const Color(0xFFEEF2FF), const Color(0xFF4F46E5)), // Indigo styles
              const SizedBox(width: 10),
              _buildTag("Min CGPA: 7.0", const Color(0xFFF1F5F9), const Color(0xFF475569)), // Slate styles
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Color(0xFFF1F5F9), thickness: 1.5, height: 1),
          ),

          /// ACTIONS ROW
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F172A),
                      side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "View Details",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5), // Indigo 600
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Apply Now",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
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
              top: MediaQuery.of(context).padding.top + 10, // Safe area top
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
              crossAxisAlignment: CrossAxisAlignment.start,
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

                const SizedBox(width: 16),

                /// TITLE & SUBTITLE
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        "Job Opportunities",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Find your dream job today",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          /// MODERN SEARCH/FILTER BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 16),
                        Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                        SizedBox(width: 12),
                        Text(
                          "Search jobs, roles...",
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.tune_rounded, color: Colors.white),
                ),
              ],
            ),
          ),

          /// SCROLLABLE JOB LIST
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildJobCard(
                  title: "Software Engineer",
                  company: "Google",
                  location: "Bangalore",
                  salary: "₹18-22 LPA",
                  logoBgColor: const Color(0xFFFEF2F2), // Red tint for Google
                  logoColor: const Color(0xFFEA4335),
                ),
                
                _buildJobCard(
                  title: "SDE Intern",
                  company: "Microsoft",
                  location: "Hyderabad",
                  salary: "₹80,000/month",
                  logoBgColor: const Color(0xFFEFF6FF), // Blue tint for Microsoft
                  logoColor: const Color(0xFF00A4EF),
                ),
                
                _buildJobCard(
                  title: "Data Analyst",
                  company: "Amazon",
                  location: "Mumbai",
                  salary: "₹12-15 LPA",
                  logoBgColor: const Color(0xFFFFF7ED), // Orange tint for Amazon
                  logoColor: const Color(0xFFFF9900),
                ),
                
                // Extra padding at bottom for scroll clearance
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
