import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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

  // Sample data for the charts
  List<FlSpot> temperatureData = [
    FlSpot(0, 22),
    FlSpot(1, 23),
    FlSpot(2, 21),
    FlSpot(3, 24),
    FlSpot(4, 22)
  ];

  List<FlSpot> humidityData = [
    FlSpot(0, 45),
    FlSpot(1, 50),
    FlSpot(2, 55),
    FlSpot(3, 52),
    FlSpot(4, 48)
  ];

  List<FlSpot> dustData = [
    FlSpot(0, 12),
    FlSpot(1, 14),
    FlSpot(2, 10),
    FlSpot(3, 15),
    FlSpot(4, 13)
  ];

  Widget _buildGraph(String title, List<FlSpot> data, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: data,
                        isCurved: true,
                        color: color,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                            show: true, color: color.withOpacity(0.3)),
                      )
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  static final List<Widget> _pages = <Widget>[
    SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10), // Add spacing if needed
          _HomePageState()._buildGraph('Room Temperature (°C)',
              _HomePageState().temperatureData, Colors.red),
          _HomePageState()._buildGraph(
              'Room Humidity (%)', _HomePageState().humidityData, Colors.blue),
          _HomePageState()._buildGraph('Dust Concentration (µg/m³)',
              _HomePageState().dustData, Colors.green),
        ],
      ),
    ),
    SpacesPage(),
    NotificationPage(),
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
        decoration: const BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: Column(
            children: [
              if (_selectedIndex == 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'VitaSpace',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4EAACC)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.account_circle,
                            size: 40, color: Color(0xFF4EAACC)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyAccountPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 5),
              Expanded(child: _pages[_selectedIndex]),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Theme(
        data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black26, offset: Offset(0, -1), blurRadius: 8)
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.space_dashboard_outlined),
                  activeIcon: Icon(Icons.space_dashboard),
                  label: 'Spaces'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_outlined),
                  activeIcon: Icon(Icons.notifications),
                  label: 'Notifications'),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Color(0xFF4EAACC),
            unselectedItemColor: Colors.black54,
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
