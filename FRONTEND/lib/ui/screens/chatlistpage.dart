import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'addfriendpage.dart';
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
  List<String> _contacts = []; // Liste des contacts

  @override
  void initState() {
    super.initState();
    print("----------------- ChatListPage - initState -----------------");
    _fetchContacts(); // Appel à la méthode pour récupérer les contacts
  }

  // Méthode pour récupérer les contacts depuis le serveur
  void _fetchContacts() async {
    final response = await http.get(
      Uri.parse('$url/contacts'),
      headers: {'Authorization': 'Bearer ${widget.sessionToken}'},
    );
    if (response.statusCode == 200) {
      final contentType = response.headers['content-type'];
      if (contentType != null && contentType.contains('application/json')) {
        final data = jsonDecode(response.body);
        setState(() {
          _contacts = List<String>.from(data['contacts']);
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
        title: Row(
          children: [
            const Text('Chats |'),
            const SizedBox(
                width: 8), // Ajoute un espacement entre le texte "Chats" et l'username
            Text(
              widget.username,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality here
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // Afficher tous les contacts récupérés de la même manière
          ..._contacts.map((contact) => _buildChatListItem(context, contact)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFriendPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildChatListItem(BuildContext context, String roomName) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.person), // Placeholder for user image
        ),
        title: Text(
          roomName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                roomName: roomName, 
                username: widget.username)),
          );
          print("/chatlistpage.dart - roomName: $roomName");
        },
      ),
    );
  }
}
