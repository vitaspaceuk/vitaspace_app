import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/device_provider.dart';

class DevicesPage extends StatefulWidget {
  final String spaceId;

  const DevicesPage({Key? key, required this.spaceId}) : super(key: key);

  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  @override
  Widget build(BuildContext context) {
    final deviceProvider = Provider.of<DeviceProvider>(context, listen: true);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      deviceProvider.fetchDevices(userId, widget.spaceId);
    }

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
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Color(0xFF4EAACC), size: 28),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Devices',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4EAACC),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.add,
                        color: Color(0xFF4EAACC), size: 28),
                    onPressed: () {
                      _showWiFiConnectionDialog();
                    },
                  ),
                ],
              ),
            ),

            // Devices List
            Expanded(
              child: Consumer<DeviceProvider>(
                builder: (context, provider, child) {
                  if (provider.devices.isEmpty) {
                    return const Center(
                      child: Text(
                        'No devices available.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: provider.devices.length,
                    itemBuilder: (context, index) {
                      final device = provider.devices[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(
                            device['name'],
                            style: const TextStyle(color: Colors.black87),
                          ),
                          tileColor: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show Wi-Fi credentials dialog with instructions
  void _showWiFiConnectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Connect to Device'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Instructions Text
              const Text(
                'Step 1: Open your phone’s Wi-Fi settings.\n\n'
                'Step 2: Connect to the Wi-Fi network named:\n'
                '"VitaSpace_<Device_ID>"\n\n'
                'Step 3: Reopen the VitaSpace app and enter the SSID and password of your home Wi-Fi network.\n\n'
                'Step 4: Press "Connect" to send the credentials.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              // TextField for SSID
              TextField(
                decoration: const InputDecoration(labelText: 'Enter SSID'),
                onChanged: (value) {
                  setState(() {
                    _ssid = value;
                  });
                },
              ),
              // TextField for Password
              TextField(
                decoration: const InputDecoration(labelText: 'Enter Password'),
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                },
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (_ssid.isNotEmpty && _password.isNotEmpty) {
                  _sendWiFiCredentials(_ssid, _password);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter valid credentials')),
                  );
                }
              },
              child: const Text('Connect'),
            ),
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text('Cancel'))
          ],
        );
      },
    );
  }

  String _ssid = '';
  String _password = '';

  // Send the Wi-Fi credentials to the IoT device
  Future<void> _sendWiFiCredentials(String ssid, String password) async {
    final url = Uri.parse('http://192.168.4.1/prov'); // Assuming the SoftAP IP
    try {
      final response =
          await http.post(url, body: {'ssid': ssid, 'password': password});

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wi-Fi credentials sent successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send Wi-Fi credentials.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
