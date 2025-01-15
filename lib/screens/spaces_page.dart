import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/spaces_provider.dart';
import 'space_details_page.dart';

class SpacesPage extends StatefulWidget {
  @override
  _SpacesPageState createState() => _SpacesPageState();
}

class _SpacesPageState extends State<SpacesPage> {
  late Future<void> _fetchSpacesFuture;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      print('Authenticated user UID: ${user.uid}');
      final spacesProvider =
          Provider.of<SpacesProvider>(context, listen: false);
      _fetchSpacesFuture = spacesProvider.fetchSpaces();
    } else {
      print('Error: User is not authenticated. Redirecting to login.');
      _fetchSpacesFuture = Future.error('User not authenticated');
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacesProvider = Provider.of<SpacesProvider>(context, listen: true);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6A11CB),
              Color(0xFF2575FC),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<void>(
                future: _fetchSpacesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading spaces: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  if (spacesProvider.spaces.isEmpty) {
                    return const Center(
                      child: Text(
                        'No spaces available. Add your first space!',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: spacesProvider.spaces.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          spacesProvider.spaces[index],
                          style: const TextStyle(color: Colors.white),
                        ),
                        tileColor: Colors.black26,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SpaceDetailPage(
                                spaceName: spacesProvider.spaces[index],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    print('Adding space for user UID: ${user.uid}');
                    _showAddSpaceDialog(context, spacesProvider);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('You need to be logged in to add spaces'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2575FC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Add Space'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSpaceDialog(
      BuildContext context, SpacesProvider spacesProvider) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Space'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter space name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  try {
                    print('Trying to add space: ${controller.text}');
                    await spacesProvider.addSpace(controller.text);
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add space: $e')),
                    );
                  }
                } else {
                  print('Error: Space name cannot be empty.');
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
