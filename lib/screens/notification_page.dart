import 'package:flutter/material.dart';
import 'my_account_page.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4EAACC), // Turquoise
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.account_circle,
                      color: Color(0xFF4EAACC), // Turquoise
                      size: 40,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyAccountPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Notifications List
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Placeholder for number of notifications
                itemBuilder: (context, index) {
                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(
                        'Notification ${index + 1}',
                        style: const TextStyle(color: Colors.black87),
                      ),
                      subtitle: const Text(
                        'This is a sample notification description.',
                        style: TextStyle(color: Colors.black54),
                      ),
                      tileColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onTap: () {
                        // Handle notification tap
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
