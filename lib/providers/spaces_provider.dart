import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SpacesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _spaces = [];

  List<Map<String, dynamic>> get spaces => _spaces;

  Future<void> fetchSpaces() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('Error: User not authenticated.');
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('spaces')
          .get();

      _spaces = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'],
              })
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching spaces: $e');
      rethrow;
    }
  }

  Future<void> addSpace(String name) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || name.isEmpty) return;

    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('spaces')
          .add({'name': name});
      _spaces.add({'id': docRef.id, 'name': name});
      notifyListeners();
    } catch (e) {
      print('Error adding space: $e');
      rethrow;
    }
  }

  void clearSpaces() {
    _spaces = [];
    notifyListeners();
  }
}
