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
  late CustomSearch _searchDelegate;
 
  @override
  void initState() {
    super.initState();
    _fetchGetContacts();
    _searchDelegate = CustomSearch(currentUser: widget.currentUser, sessionToken: widget.sessionToken);
  }
 
  void _fetchGetContacts() async {
    // Remplacer '$url/contacts' par votre URL réelle
    final response = await http.get(Uri.parse('$url/contacts'), headers: {'Authorization': 'Bearer ${widget.sessionToken}'});
 
    if (response.statusCode == 200) {
      final contentType = response.headers['content-type'];
      if (contentType != null && contentType.contains('application/json')) {
        final data = jsonDecode(response.body);
        setState(() {
          _contacts = data['contacts'];
        });
        _searchDelegate.updateSearchTerms(_contacts);
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
          actions: [
            IconButton(
              onPressed: () {
                showSearch(context: context, delegate: _searchDelegate);
              },
              icon: const Icon(Icons.search, color: Colors.white),
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: sortedKeys.length,  // Use sortedKeys for itemCount
          itemBuilder: (context, index) {
          String key = sortedKeys[index];  // Get the key from sortedKeys
          List<dynamic> sortedContacts = groupedContacts[key]!;
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
                  children: groupedContacts[key]!
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
        // Assurez-vous d'implémenter CustomBottomAppBar ou de le supprimer si inutile
        bottomNavigationBar: CustomBottomAppBar(
          currentUser: widget.currentUser,
          sessionToken: widget.sessionToken,
          activeIndex: 0,
        ),
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
ThemeData appBarTheme(BuildContext context) {
  final ThemeData theme = Theme.of(context);
  return theme.copyWith(
    textTheme: theme.textTheme.copyWith(
      // This will ensure the text color is white for the search text input
      subtitle1: theme.textTheme.subtitle1?.copyWith(color: Colors.white),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF6632C6),
      elevation: 0,
      iconTheme: theme.primaryIconTheme.copyWith(color: Colors.white),
      toolbarTextStyle: theme.textTheme.bodyText2?.copyWith(color: Colors.white),
      titleTextStyle: theme.textTheme.headline6?.copyWith(color: Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      // Make sure hint text color is white
      hintStyle: TextStyle(color: Colors.white),
      // Make sure the input text color is white
      labelStyle: TextStyle(color: Colors.white),
      fillColor: Colors.transparent,
      filled: true,
      border: InputBorder.none,
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white), // Ensure this is white
      ),
    ),
  );
}
 
 
 
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
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
 
  Widget buildGroupedListView(Map<String, List<dynamic>> groupedContacts) {
    return ListView.builder(
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: fontLufga),
              ),
            ),
            Column(
              children: groupedContacts[key]!
                  .map((contact) => ListTile(
                        title: Text(contact['other_user_name'], style: TextStyle(color: Colors.white, fontFamily: fontLufga)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                currentUser: currentUser,
                                convId: contact['conversation_id'],
                                convName: contact['conversation_name'],
                                realConvName: contact['other_user_name'],
                                sessionToken: sessionToken,
                              ),
                            ),
                          );
                        },
                      ))
                  .toList(),
            ),
          ],
        );
      },
    );
  }
 
  @override
Widget buildResults(BuildContext context) {
  List<dynamic> matchContacts = [];
  for (var contact in _contacts) {
    if (contact['other_user_name'].toLowerCase().contains(query.toLowerCase())) {
      matchContacts.add(contact);
    }
  }
 
  return Theme(
    data: ThemeData(
      brightness: Brightness.dark, // Utilisez Brightness.dark pour un thème sombre général
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF6632C6), // Couleur de fond de l'appBar
        iconTheme: IconThemeData(color: Colors.white), // Couleur des icônes de l'appBar
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white, fontFamily: fontLufga), // Couleur du texte indicatif
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white), // Couleur de la bordure lors de la saisie
        ),
      ),
    ),
    child: ListView.builder(
      itemCount: matchContacts.length,
      itemBuilder: (context, index) {
        var result = matchContacts[index];
        return ListTile(
          title: Text(result['other_user_name'], style: TextStyle(color: Colors.white, fontFamily: fontLufga)),
          onTap: () {
            // Action lors de la sélection d'un contact
          },
        );
      },
    ),
  );
}
 
 
  @override
Widget buildSuggestions(BuildContext context) {
  Map<String, List<dynamic>> groupedContacts = {};
  for (var contact in _contacts) {
    if (contact['other_user_name'].toLowerCase().contains(query.toLowerCase())) {
      String firstLetter = contact['other_user_name'][0].toUpperCase();
      groupedContacts.putIfAbsent(firstLetter, () => []);
      groupedContacts[firstLetter]!.add(contact);
    }
  }
 
  // Sort the section titles
  List<String> sectionTitles = groupedContacts.keys.toList()..sort();
 
  // Sort contacts within each section
  for (var key in sectionTitles) {
    groupedContacts[key]?.sort((a, b) =>
      a['other_user_name'].toLowerCase().compareTo(b['other_user_name'].toLowerCase()));
  }
 
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1C0F45), Color(0xFF6632C6)],
      ),
    ),
    child: Scaffold(
      backgroundColor: Colors.transparent, // Make the Scaffold transparent to see the gradient
      bottomNavigationBar: CustomBottomAppBar(currentUser: currentUser, sessionToken: sessionToken),
      body: ListView.builder(
        itemCount: sectionTitles.length,
        itemBuilder: (context, index) {
          String key = sectionTitles[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  key,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: fontLufga),
                ),
              ),
              Column(
                children: groupedContacts[key]!
                    .map((contact) => ListTile(
                          title: Text(
                            contact['other_user_name'],
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: fontLufga
                            )
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  currentUser: currentUser,
                                  convId: contact['conversation_id'],
                                  convName: contact['conversation_name'],
                                  realConvName: contact['other_user_name'],
                                  sessionToken: sessionToken,
                                ),
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
  );
}
 
}