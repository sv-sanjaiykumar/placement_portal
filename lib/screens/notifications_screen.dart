import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  Widget notificationCard(
      IconData icon,
      Color iconColor,
      String title,
      String message,
      String date,
      bool isNew) {

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(
            color: iconColor,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
          )
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// ICON
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor),
          ),

          const SizedBox(width: 12),

          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  children: [

                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),

                    if(isNew)
                      const Icon(Icons.circle,
                          color: Colors.blue,
                          size: 8)
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  date,
                  style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12),
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

      backgroundColor: const Color(0xffECECF1),

      body: SafeArea(
        child: Column(
          children: [

            /// HEADER WITH BACK BUTTON
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(15, 20, 20, 20),

              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),

              child: Column(
                children: [

                  Row(
                    children: [

                      /// BACK BUTTON
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),

                      const SizedBox(width: 5),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              "Notifications",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),

                            SizedBox(height: 4),

                            Text(
                              "Stay updated with latest news",
                              style: TextStyle(color: Colors.white70),
                            )
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "2 new",
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// NOTIFICATION LIST
            Expanded(
              child: ListView(
                children: [

                  notificationCard(
                    Icons.work,
                    Colors.blue,
                    "New Job Posted",
                    "Apple has posted a new job opening for iOS Developer",
                    "3/2/2026",
                    true,
                  ),

                  notificationCard(
                    Icons.description,
                    Colors.green,
                    "Application Shortlisted",
                    "You have been shortlisted for Software Engineer at Google",
                    "3/3/2026",
                    true,
                  ),

                  notificationCard(
                    Icons.calendar_month,
                    Colors.purple,
                    "Interview Scheduled",
                    "Your interview for Google is scheduled on March 8, 2026 at 10:00 AM",
                    "3/4/2026",
                    false,
                  ),

                  notificationCard(
                    Icons.info,
                    Colors.grey,
                    "Placement Drive Announcement",
                    "TCS campus drive will be conducted on March 15, 2026",
                    "3/1/2026",
                    false,
                  ),

                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}