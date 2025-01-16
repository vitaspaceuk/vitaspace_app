import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('spaces')
          .doc(spaceId)
          .collection('devices')
          .add(document);
      _devices.add(document);
      notifyListeners();
    } catch (e) {
      print('Error adding device: $e');
    }
  }
}
