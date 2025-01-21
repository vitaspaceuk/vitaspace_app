import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Back Button
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Color(0xFF4EAACC), size: 28), // Turquoise
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
                      color: Color(0xFF4EAACC), // Turquoise
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.add,
                      color: Color(0xFF4EAACC), // Turquoise
                      size: 28,
                    ),
                    onPressed: () {
                      _showBluetoothScanDialog(context, deviceProvider, userId);
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
                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(
                        device['name'],
                        style: const TextStyle(color: Colors.black87),
                      ),
                      tileColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await _confirmDeleteDialog(context);
                          if (confirm) {
                            await deviceProvider.removeDevice(
                                userId!, spaceId, device['id']);
                          }
                        },
                      ),
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

  void _showBluetoothScanDialog(
      BuildContext context, DeviceProvider deviceProvider, String? userId) {
    if (userId == null) return;

    final FlutterBlue flutterBlue = FlutterBlue.instance;
    final List<BluetoothDevice> devicesList = [];

    flutterBlue.startScan(
        timeout: const Duration(seconds: 10)); // Start scanning

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Scanning for Devices'),
          content: StreamBuilder<List<ScanResult>>(
            stream: flutterBlue.scanResults,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final results = snapshot.data!;
                for (var result in results) {
                  final deviceName = result.device.name.isNotEmpty
                      ? result.device.name
                      : result.advertisementData.localName;

                  // Check for devices with "vitaspace" prefix
                  if (deviceName.toLowerCase().startsWith('vitaspace')) {
                    // Avoid duplicates in the list
                    if (!devicesList.contains(result.device)) {
                      devicesList.add(result.device);
                    }
                  }

                  print('Found device: $deviceName (${result.device.id})');
                }

                return SizedBox(
                  height: 300,
                  child: devicesList.isNotEmpty
                      ? ListView.builder(
                          itemCount: devicesList.length,
                          itemBuilder: (context, index) {
                            final device = devicesList[index];
                            return ListTile(
                              title: Text(device.name),
                              subtitle: Text(device.id.toString()),
                              onTap: () {
                                flutterBlue.stopScan();
                                Navigator.pop(context);
                                _connectToBluetoothDevice(
                                    deviceProvider, userId, device);
                              },
                            );
                          },
                        )
                      : const Center(
                          child: Text('No VitaSpace devices found'),
                        ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                flutterBlue.stopScan();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _connectToBluetoothDevice(DeviceProvider deviceProvider,
      String userId, BluetoothDevice device) async {
    try {
      await device.connect();
      deviceProvider.addDevice(userId, spaceId, device.name);
      print('Connected to ${device.name}');
    } catch (e) {
      print('Error connecting to device: $e');
    } finally {
      device.disconnect();
    }
  }

  Future<bool> _confirmDeleteDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Device'),
              content:
                  const Text('Are you sure you want to delete this device?'),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                ElevatedButton(
                  child: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
