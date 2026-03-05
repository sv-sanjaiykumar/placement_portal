import 'package:flutter/material.dart';
import 'package:placement_portal_app/screens/application_screen.dart';
import 'package:placement_portal_app/screens/job_screen.dart';
import 'package:placement_portal_app/screens/notifications_screen.dart';
import 'package:placement_portal_app/screens/profile_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {

  int currentIndex = 0;

  /// STAT CARD
  Widget statCard(String title, String count, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(15),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [

          Icon(icon, color: Colors.white, size: 20),

          Text(
            title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12),
          ),

          Text(
            count,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          )
        ],
      ),
    );
  }

  /// QUICK ACTION
  Widget quickAction(IconData icon, String title, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),

          const SizedBox(height: 10),

          Text(title)
        ],
      ),
    );
  }

  /// JOB CARD
  Widget jobCard(String company, String role, String salary, String location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              const CircleAvatar(
                child: Icon(Icons.business),
              ),

              const SizedBox(width: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    role,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),

                  Text(company)
                ],
              )
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [

              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5),

                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Text(
                  salary,
                  style: const TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(width: 10),

              Text(location)
            ],
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              child: const Text("View Details"),
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

      /// BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(

        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,

        onTap: (index) {

          setState(() {
            currentIndex = index;
          });

          if(index == 1){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const JobsScreen(),
              ),
            );
          }

          if(index == 2){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ApplicationsScreen(),
              ),
            );
          }

          if(index == 3){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            );
          }

          if(index == 4){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          }

        },

        items: const [

          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home"),

          BottomNavigationBarItem(
              icon: Icon(Icons.work),
              label: "Jobs"),

          BottomNavigationBarItem(
              icon: Icon(Icons.description),
              label: "Applications"),

          BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: "Notifications"),

          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile"),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              /// HEADER
              Container(
                padding: const EdgeInsets.all(20),

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                      children: const [

                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [

                            Text(
                              "Welcome Back!",
                              style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),

                            Text(
                              "Student",
                              style: TextStyle(
                                  color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// STATS GRID
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.6,

                      children: [

                        statCard("Applications", "3", Icons.description),
                        statCard("Shortlisted", "1", Icons.check_circle),
                        statCard("Interviews", "2", Icons.calendar_today),
                        statCard("Jobs Available", "4", Icons.work),

                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// QUICK ACTIONS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Quick Actions",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    GridView.count(

                      shrinkWrap: true,
                      physics:
                      const NeverScrollableScrollPhysics(),

                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.2,

                      children: [

                        quickAction(
                            Icons.work,
                            "Browse Jobs",
                            Colors.blue),

                        quickAction(
                            Icons.description,
                            "My Applications",
                            Colors.purple),

                        quickAction(
                            Icons.person,
                            "My Profile",
                            Colors.green),

                        quickAction(
                            Icons.notifications,
                            "Notifications",
                            Colors.orange),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Latest Job Postings",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    jobCard(
                        "Google",
                        "Software Engineer",
                        "₹18-22 LPA",
                        "Bangalore"),

                    jobCard(
                        "Microsoft",
                        "SDE Intern",
                        "₹80,000/month",
                        "Hyderabad"),

                    jobCard(
                        "Amazon",
                        "Data Analyst",
                        "₹12-15 LPA",
                        "Mumbai"),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}