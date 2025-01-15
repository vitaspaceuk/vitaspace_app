import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SpacesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _spaces = [];

  List<String> get spaces => _spaces;

  // Fetch spaces for the authenticated user
  Future<void> fetchSpaces() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('Error: User not authenticated.');
      return;
    }

    // Force token refresh
    await FirebaseAuth.instance.currentUser?.getIdToken(true);

    print('Fetching spaces for user: $userId');
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('spaces')
          .get();

      print('Query successful. Documents: ${snapshot.docs.length}');
      _spaces = snapshot.docs.map((doc) => doc['name'] as String).toList();
      print('Fetched spaces: $_spaces');
      notifyListeners();
    } catch (e) {
      print('Error fetching spaces: $e');
      rethrow;
    }
  }

  // Add a new space for the authenticated user
  Future<void> addSpace(String name) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('Error: User not authenticated.');
      return;
    }

    if (name.isEmpty) {
      print('Error: Space name cannot be empty.');
      return;
    }

    final document = {'name': name};
    print('Attempting to add space: $document');

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('spaces')
          .add(document);
      print('Space added successfully.');
      _spaces.add(name);
      notifyListeners();
    } catch (e) {
      print('Error adding space: $e');
      rethrow;
    }
  }

  // Clear spaces (e.g., on sign-out)
  void clearSpaces() {
    _spaces = [];
    notifyListeners();
    print('Spaces cleared');
  }
}
