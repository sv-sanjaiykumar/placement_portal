import 'package:flutter/material.dart';

class ApplicationsScreen extends StatelessWidget {
  const ApplicationsScreen({super.key});

  Widget applicationCard(
      String company,
      String role,
      String status,
      Color statusColor,
      String date) {

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),

      child: Row(
        children: [

          const CircleAvatar(
            radius: 28,
            child: Icon(Icons.business),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  role,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),

                Text(company),

                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4),

                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    status,
                    style: TextStyle(color: statusColor),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(width: 8),

          Text(
            date,
            style: const TextStyle(
                color: Colors.grey,
                fontSize: 12),
          )
        ],
      ),
    );
  }

  Widget filterChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Chip(
        label: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xffECECF1),

      /// APP BAR
      appBar: AppBar(
        title: const Text("My Applications"),
        backgroundColor: Colors.blue,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: Column(
        children: [

          /// FILTER TABS (FIXED OVERFLOW)
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(10),

            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,

              child: Row(
                children: [

                  filterChip("All"),
                  filterChip("Applied"),
                  filterChip("Shortlist"),
                  filterChip("Selected"),
                  filterChip("Rejected"),

                ],
              ),
            ),
          ),

          /// APPLICATION LIST
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15),

              child: ListView(
                children: [

                  applicationCard(
                    "Google",
                    "Software Engineer",
                    "Shortlisted",
                    Colors.green,
                    "Applied: 3/1/2026",
                  ),

                  applicationCard(
                    "Microsoft",
                    "SDE Intern",
                    "Applied",
                    Colors.blue,
                    "Applied: 3/2/2026",
                  ),

                  applicationCard(
                    "Amazon",
                    "Data Analyst",
                    "Selected",
                    Colors.purple,
                    "Applied: 2/28/2026",
                  ),

                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}