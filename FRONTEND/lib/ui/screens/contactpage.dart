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
  late CustomSearch _searchDelegate;

  @override
  void initState() {
    super.initState();
    _fetchGetContacts();
    _searchDelegate = CustomSearch(
        currentUser: widget.currentUser, sessionToken: widget.sessionToken);
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
        _searchDelegate.updateSearchTerms(_contacts);
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
        actions: [
          IconButton(
            onPressed: () {
              showSearch(context: context, delegate: _searchDelegate);
            },
            icon: const Icon(Icons.search),
          )
        ],
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

class CustomSearch extends SearchDelegate {
  final User currentUser;
  final String sessionToken;

  List<String> searchTerms = [];
  List<dynamic> _contacts = [];

  CustomSearch({required this.currentUser, required this.sessionToken});

  void updateSearchTerms(List<dynamic> contacts) {
    _contacts = contacts;
    searchTerms.clear();
    for (var contact in _contacts) {
      searchTerms.add(contact['other_user_name']);
    }
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<dynamic> matchContacts = [];
    for (var contact in _contacts) {
      if (contact['other_user_name']
          .toLowerCase()
          .contains(query!.toLowerCase())) {
        matchContacts.add(contact);
      }
    }
    return ListView.builder(
      itemCount: matchContacts.length,
      itemBuilder: (context, index) {
        var result = matchContacts[index];
        return ListTile(
          title: Text(result['other_user_name']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  currentUser: currentUser,
                  convId: result['conversation_id'],
                  convName: result['conversation_name'],
                  sessionToken: sessionToken,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<dynamic> matchContacts = [];
    for (var contact in _contacts) {
      if (contact['other_user_name']
          .toLowerCase()
          .contains(query!.toLowerCase())) {
        matchContacts.add(contact);
      }
    }
    return ListView.builder(
      itemCount: matchContacts.length,
      itemBuilder: (context, index) {
        var result = matchContacts[index];
        return ListTile(
          title: Text(result['other_user_name']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  currentUser: currentUser,
                  convId: result['conversation_id'],
                  convName: result['conversation_name'],
                  sessionToken: sessionToken,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

