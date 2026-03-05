import 'package:flutter/material.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  Widget jobCard(String title, String company, String location, String salary) {
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
                    title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),

                  Text(company)
                ],
              ),

              const Spacer(),

              const Icon(Icons.bookmark_border)
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16),
              const SizedBox(width: 5),
              Text(location),

              const SizedBox(width: 20),

              const Icon(Icons.attach_money, size: 16),
              Text(salary)
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [

              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(20)),
                child: const Text("Fulltime"),
              ),

              const SizedBox(width: 10),

              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20)),
                child: const Text("Min CGPA: 7"),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [

              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text("View Details"),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  onPressed: () {},
                  child: const Text("Apply Now"),
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
      backgroundColor: const Color(0xffECECF1),

      appBar: AppBar(
        title: const Text("Job Opportunities"),
        backgroundColor: Colors.blue,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [

            jobCard(
              "Software Engineer",
              "Google",
              "Bangalore",
              "₹18-22 LPA",
            ),

            jobCard(
              "SDE Intern",
              "Microsoft",
              "Hyderabad",
              "₹80,000/month",
            ),

            jobCard(
              "Data Analyst",
              "Amazon",
              "Mumbai",
              "₹12-15 LPA",
            ),
          ],
        ),
      ),
    );
  }
}