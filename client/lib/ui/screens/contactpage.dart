import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
 
import 'chatpage.dart';
import 'customebottomnavbar.dart';
import '../../models/url.dart';
import '../../models/user.dart';
import '../../models/constants.dart';

 
class ContactPage extends StatefulWidget {
  final String sessionToken;
  final User currentUser;

  const ContactPage({Key? key, required this.sessionToken, required this.currentUser}) : super(key: key);

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<dynamic> _contacts = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchGetContacts();
  }

  void _fetchGetContacts() async {
    final response = await http.get(Uri.parse('$url/contacts'), headers: {'Authorization': 'Bearer ${widget.sessionToken}'});

    if (response.statusCode == 200) {
      final contentType = response.headers['content-type'];
      if (contentType != null && contentType.contains('application/json')) {
        final data = jsonDecode(response.body);
        setState(() {
          _contacts = data['contacts'];
        });
      } else {
        print('La réponse n\'est pas au format JSON');
      }
    } else {
      print('Échec du chargement des contacts : ${response.statusCode}');
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

    List<String> sortedKeys = groupedContacts.keys.toList()..sort();

    // Filter contacts based on search query
    List<dynamic> filteredContacts = _contacts.where((contact) {
      return contact['other_user_name'].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1C0F45), Color(0xFF6632C6)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Contacts', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                style: TextStyle(color: Colors.white), // Adjusted text color to white
                decoration: InputDecoration(
                  hintText: 'Rechercher un contact',
                  hintStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.white24,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.deepPurple.shade100),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.deepPurple.shade700),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: sortedKeys.length,
                itemBuilder: (context, index) {
                  String key = sortedKeys[index];
                  List<dynamic> contactsForKey = groupedContacts[key]!.where((contact) =>
                      contact['other_user_name'].toLowerCase().contains(searchQuery.toLowerCase())).toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          key,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      Column(
                        children: contactsForKey
                            .map((contact) => ListTile(
                                  title: Text(contact['other_user_name'], style: TextStyle(color: Colors.white)),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatPage(
                                            currentUser: widget.currentUser,
                                            convId: contact['conversation_id'],
                                            convName: contact['conversation_name'],
                                            realConvName: contact['other_user_name'],
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
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomAppBar(
          currentUser: widget.currentUser,
          sessionToken: widget.sessionToken,
          activeIndex: 0,
        ),
      ),
    );
  }
}
