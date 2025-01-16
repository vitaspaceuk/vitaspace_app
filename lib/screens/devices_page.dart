import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';

class DevicesPage extends StatelessWidget {
  final String spaceId;

  const DevicesPage({Key? key, required this.spaceId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceProvider = Provider.of<DeviceProvider>(context, listen: true);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      deviceProvider.fetchDevices(userId, spaceId);
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with Back Button
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 28),
                      onPressed: () {
                        Navigator.pop(context); // Navigate back to SpacesPage
                      },
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Devices',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        _showAddDeviceDialog(context, deviceProvider, userId);
                      },
                    ),
                  ],
                ),
              ),

              // Devices List
              Expanded(
                child: ListView.builder(
                  itemCount: deviceProvider.devices.length,
                  itemBuilder: (context, index) {
                    final device = deviceProvider.devices[index];
                    return ListTile(
                      title: Text(
                        device['name'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      tileColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddDeviceDialog(
      BuildContext context, DeviceProvider deviceProvider, String? userId) {
    if (userId == null) return;
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Device'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter device name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await deviceProvider.addDevice(userId, spaceId, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
