import 'package:flutter/material.dart';

class AddFriendPage extends StatelessWidget {
  const AddFriendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friend'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const TextField(
              decoration: InputDecoration(labelText: 'Enter username'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add friend logic here
                Navigator.pop(context); // Go back to previous page
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}