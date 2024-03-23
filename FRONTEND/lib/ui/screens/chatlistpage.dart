import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_github_version/models/conversation.dart'; // Make sure this path matches the location of your ChatConversation model
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'chatpage.dart';

const String url = 'http://localhost:8000';

class ChatListPage extends StatefulWidget {
  final String sessionToken;
  final String username;
  final IO.Socket socket;

  const ChatListPage({super.key, required this.sessionToken, required this.username, required this.socket});

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {

  List<dynamic> recentMessages = []; // Variable pour stocker les messages récents

  @override
  void initState() {
    super.initState();
    _fetchContacts(); // Appel à la méthode pour récupérer les contacts
  }

  void _fetchContacts() async {
    final response = await http.get(
      Uri.parse('$url/recent_messages'),
      headers: {'Authorization': 'Bearer ${widget.sessionToken}'},
    );
    if (response.statusCode == 200) {
      final contentType = response.headers['content-type'];
      if (contentType != null && contentType.contains('application/json')) {
        final data = jsonDecode(response.body);
        print(data);
        setState(() {
          recentMessages = data['recent_messages']; // Affectation des données à la variable d'état
        });
      } else {
        print('Response is not in JSON format');
      }
    } else {
      print('Failed to load contacts: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.grey),
          onPressed: () {
            // Handle your action
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.blue),
            onPressed: () {
              // Handle your action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for user',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active users',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Handle your action
                  },
                  child: Text('see all'),
                ),
              ],
            ),
          ),
          // Placeholder for active user circles
          Container(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5, // The number of active circles you want
              itemBuilder: (context, index) {
                return Container(
                  width: 60,
                  height: 60,
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/avatar_placeholder.png'), // Replace with your asset
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: recentMessages.length,
              itemBuilder: (context, index) {
                final message = recentMessages[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: message['avatar'],
                  ),
                  title: Text(message['conv_name']),
                  subtitle: Text(message['last_message_content']),
                  trailing: Text(message['last_message_date']),
                  onTap: () => {
                     Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              message['conv_id'], // Assurez-vous que c'est la bonne manière d'accéder à l'ID du groupe
                              message['conv_name'],
                        )
                      )
                    ),
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
