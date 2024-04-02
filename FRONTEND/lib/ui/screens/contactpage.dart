import 'package:flutter/material.dart';
import 'package:flutter_github_version/ui/screens/chatpage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/url.dart';
import '../../models/user.dart';

class ContactPage extends StatefulWidget {
  final String sessionToken;
  final User currentUser;

  const ContactPage(
      {super.key, required this.sessionToken, required this.currentUser});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<dynamic> _contacts = [];

  @override
  void initState() {
    super.initState();
    _fetchGetContacts();
  }

  void _fetchGetContacts() async {
    final response = await http.get(
      Uri.parse('$url/contacts'),
      headers: {'Authorization': 'Bearer ${widget.sessionToken}'},
    );
    if (response.statusCode == 200) {
      final contentType = response.headers['content-type'];
      if (contentType != null && contentType.contains('application/json')) {
        final data = jsonDecode(response.body);
        setState(() {
          _contacts = data['contacts'];
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
    Map<String, List<dynamic>> groupedContacts = {};

    for (var contact in _contacts) {
      String firstLetter = contact['other_user_name'][0].toUpperCase();
      groupedContacts.putIfAbsent(firstLetter, () => []);
      groupedContacts[firstLetter]!.add(contact);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Page'),
      ),
      body: ListView.builder(
        itemCount: groupedContacts.keys.length,
        itemBuilder: (context, index) {
          String key = groupedContacts.keys.elementAt(index);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  key,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Column(
                children: groupedContacts[key]!
                    .map((contact) => ListTile(
                          title: Text(contact['other_user_name']),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                    currentUser: widget.currentUser,
                                    convId: contact['conversation_id'],
                                    convName: contact['conversation_name'],
                                    sessionToken: widget.sessionToken),
                              ),
                            );
                          },
                        ))
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Assurez-vous que cette classe correspond à la page de votre liste de chat
class ChatList extends StatelessWidget {
  final int userId;

  const ChatList({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat List"),
      ),
      // Implémentez le reste de votre interface utilisateur ici
      body: Center(
        child: Text("Chat avec l'utilisateur ID: $userId"),
      ),
    );
  }
}
