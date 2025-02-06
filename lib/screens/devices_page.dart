import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:http/http.dart' as http;
import '../providers/device_provider.dart';
import 'dart:async';

class DevicesPage extends StatefulWidget {
  final String spaceId;

  const DevicesPage({Key? key, required this.spaceId}) : super(key: key);

  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  List<String> _foundDevices = [];
  bool _isSearching = false;

  @override
  void dispose() {
    super.dispose();
  }

  void _showDeviceOptionsDialog(
      BuildContext context,
      DeviceProvider deviceProvider,
      String userId,
      Map<String, dynamic> device) {
    TextEditingController renameController =
        TextEditingController(text: device['name']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(device['name']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: renameController,
                decoration: const InputDecoration(labelText: 'Rename Device'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deviceProvider.renameDevice(userId, widget.spaceId,
                    device['id'], renameController.text);
              },
              child: const Text('Rename', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deviceProvider.removeDevice(
                    userId, widget.spaceId, device['id']);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

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
                    icon: _isSearching
                        ? const Icon(Icons.stop, color: Colors.red, size: 28)
                        : const Icon(Icons.add,
                            color: Color(0xFF4EAACC), size: 28),
                    onPressed: () {
                      if (_isSearching) {
                        setState(() => _isSearching = false);
                      } else {
                        _startSearching();
                      }
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
                          trailing: IconButton(
                            icon: const Icon(Icons.more_vert,
                                color: Colors.grey, size: 28),
                            onPressed: () {
                              _showDeviceOptionsDialog(
                                  context, deviceProvider, userId!, device);
                            },
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

  void _startSearching() async {
    setState(() {
      _isSearching = true;
      _foundDevices = [];
    });

    // Request necessary permissions
    if (await _requestPermissions()) {
      final canScan = await WiFiScan.instance.canStartScan();
      if (canScan != CanStartScan.yes) {
        print("❌ Wi-Fi scanning is not allowed.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Wi-Fi scanning is not allowed. Grant permissions in settings.")),
        );
        return;
      }

      await WiFiScan.instance.startScan();
      final networks = await WiFiScan.instance.getScannedResults();

      setState(() {
        _foundDevices = networks
            .where((net) =>
                net.ssid.startsWith("VitaSpace_")) // Only ESP32 SoftAPs
            .map((net) => net.ssid)
            .toList();
        _isSearching = false;
      });

      _showWiFiSelectionDialog();
    } else {
      print("❌ Permissions denied.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Wi-Fi scan requires location permission.")),
      );
    }
  }

  void _showWiFiSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a Device'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _foundDevices.map((device) {
              return ListTile(
                title: Text(device),
                onTap: () {
                  Navigator.pop(context);
                  _startSoftAPProvisioning(device);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text('Cancel'))
          ],
        );
      },
    );
  }

  Future<bool> _requestPermissions() async {
    // Request location permissions for iOS and Android
    final locationWhenInUse = await Permission.locationWhenInUse.request();
    final locationAlways = await Permission.locationAlways.request();

    // Check final permissions
    return locationWhenInUse.isGranted && locationAlways.isGranted;
  }

  Future<void> _startSoftAPProvisioning(String ssid) async {
    final url = Uri.parse('http://192.168.4.1/prov');
    await http
        .post(url, body: {'ssid': 'MyHomeSSID', 'password': 'MyHomePassword'});
  }
}
