import 'package:flutter/material.dart';
import 'my_account_page.dart';
import 'spaces_page.dart';
import 'notification_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Pages for each tab
  static final List<Widget> _pages = <Widget>[
    Center(
      child: Text(
        'Home Page',
        style: TextStyle(fontSize: 24, color: Colors.black87),
      ),
    ),
    SpacesPage(), // SpacesPage
    NotificationPage(), // NotificationPage
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white, // Solid white background
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Show Header only on the Home Page
              if (_selectedIndex == 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'VitaSpace',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4EAACC), // Turquoise
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.account_circle,
                          size: 40,
                          color: Color(0xFF4EAACC), // Turquoise
                        ),
                        onPressed: () {
                          // Navigate to the "My Account" page
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
              const SizedBox(height: 5),

              // Main Content Area
              Expanded(
                child: _pages[_selectedIndex],
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar with Theme to remove splash effect
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent, // Remove splash color
          highlightColor: Colors.transparent, // Remove highlight color
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white, // Solid white background
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, -1),
                blurRadius: 8,
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.space_dashboard_outlined),
                activeIcon: Icon(Icons.space_dashboard),
                label: 'Spaces',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_outlined),
                activeIcon: Icon(Icons.notifications),
                label: 'Notifications',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Color(0xFF4EAACC), // Turquoise
            unselectedItemColor: Colors.black54, // Dark gray for unselected
            selectedFontSize: 14,
            unselectedFontSize: 12,
            type: BottomNavigationBarType.fixed,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
