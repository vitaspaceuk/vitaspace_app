import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/spaces_provider.dart';
import 'devices_page.dart';

class SpacesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final spacesProvider = Provider.of<SpacesProvider>(context, listen: true);

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
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Spaces',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        _showAddSpaceDialog(context, spacesProvider);
                      },
                    ),
                  ],
                ),
              ),

              // Spaces List
              Expanded(
                child: ListView.builder(
                  itemCount: spacesProvider.spaces.length,
                  itemBuilder: (context, index) {
                    final space = spacesProvider.spaces[index];
                    return ListTile(
                      title: Text(
                        space['name'],
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DevicesPage(spaceId: space['id']),
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
      ),
    );
  }

  void _showAddSpaceDialog(
      BuildContext context, SpacesProvider spacesProvider) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Space'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter space name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await spacesProvider.addSpace(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
