import 'package:flutter/material.dart';

class AddFriendPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Friend'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Enter username'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add friend logic here
                Navigator.pop(context); // Go back to previous page
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}