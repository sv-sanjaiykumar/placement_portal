import 'package:flutter/material.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  String selectedFilter = "All";
  final List<String> filters = [
    "All",
    "Applied",
    "Shortlisted",
    "Interview",
    "Selected",
    "Rejected"
  ];

  // Dummy Application Data for the modern UI presentation
  final List<Map<String, dynamic>> applications = [
    {
      "company": "Google",
      "role": "Software Engineer",
      "status": "Shortlisted",
      "statusColor": const Color(0xFF10B981), // Emerald
      "date": "Mar 1, 2026",
      "logoColor": const Color(0xFFEA4335),
    },
    {
      "company": "Microsoft",
      "role": "SDE Intern",
      "status": "Applied",
      "statusColor": const Color(0xFF3B82F6), // Blue
      "date": "Mar 2, 2026",
      "logoColor": const Color(0xFF00A4EF),
    },
    {
      "company": "Amazon",
      "role": "Data Analyst",
      "status": "Selected",
      "statusColor": const Color(0xFF8B5CF6), // Purple
      "date": "Feb 28, 2026",
      "logoColor": const Color(0xFFFF9900),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Modern slate-50 background
      
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                        "My Applications",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Track your application status",
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
          
          _buildFilterSection(),
          const SizedBox(height: 10),
          
          /// APPLICATION LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: applications.length,
              itemBuilder: (context, index) {
                final app = applications[index];
                
                // Filtering Logic
                if (selectedFilter != "All" && app["status"] != selectedFilter) {
                  return const SizedBox.shrink();
                }
                
                return _buildApplicationCard(app);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// SCROLLABLE FILTER CHIPS
  Widget _buildFilterSection() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 10),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(
                filter,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF64748B), // Slate 500
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedFilter = filter;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF4F46E5), // Indigo 600
              side: BorderSide(
                color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Smooth rounded pills
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              showCheckmark: false, // Cleaner look without the checkmark
            ),
          );
        },
      ),
    );
  }

  /// MODERN APPLICATION CARD
  Widget _buildApplicationCard(Map<String, dynamic> app) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)), // Slate 100 border
      ),
      child: Column(
        children: [
          // Top Section: Info & Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // Custom Colored Logo Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: app["logoColor"].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16), // Squircle shape
                ),
                child: Icon(
                  Icons.business_center_rounded,
                  color: app["logoColor"],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Job Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app["role"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      app["company"],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: app["statusColor"].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  app["status"],
                  style: TextStyle(
                    color: app["statusColor"],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFF1F5F9), thickness: 1.5),
          ),
          
          // Bottom Section: Date & Action arrow
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 6),
                  Text(
                    "Applied: ${app['date']}",
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFCBD5E1)),
            ],
          ),
        ],
      ),
    );
  }
}
