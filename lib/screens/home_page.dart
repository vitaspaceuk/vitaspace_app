import 'package:flutter/material.dart';
import 'my_account_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VitaSpace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Navigate to the "My Account" page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyAccountPage()),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome to VitaSpace!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
