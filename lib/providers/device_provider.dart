import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _devices = [];

  List<Map<String, dynamic>> get devices => _devices;

  Future<void> fetchDevices(String userId, String spaceId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('spaces')
          .doc(spaceId)
          .collection('devices')
          .get();

      _devices =
          snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching devices: $e');
    }
  }

  Future<void> addDevice(String userId, String spaceId, String name) async {
    final document = {'name': name, 'status': 'off'};
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('spaces')
          .doc(spaceId)
          .collection('devices')
          .add(document);

      _devices.add({'id': docRef.id, ...document});
      notifyListeners();
    } catch (e) {
      print('Error adding device: $e');
    }
  }

  Future<void> removeDevice(
      String userId, String spaceId, String deviceId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('spaces')
          .doc(spaceId)
          .collection('devices')
          .doc(deviceId)
          .delete();
      _devices.removeWhere((device) => device['id'] == deviceId);
      notifyListeners();
    } catch (e) {
      print('Error removing device: $e');
    }
  }

  Future<void> renameDevice(
      String userId, String spaceId, String deviceId, String newName) async {
    try {
      // Update the device's name in Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('spaces')
          .doc(spaceId)
          .collection('devices')
          .doc(deviceId)
          .update({'name': newName});

      // Update the local list
      final deviceIndex =
          _devices.indexWhere((device) => device['id'] == deviceId);
      if (deviceIndex != -1) {
        _devices[deviceIndex]['name'] = newName;
        notifyListeners();
      }
    } catch (e) {
      print('Error renaming device: $e');
    }
  }

  void clearDevices() {
    _devices = [];
    notifyListeners();
  }
}
