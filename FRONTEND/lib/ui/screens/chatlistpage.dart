import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Assurez-vous d'importer vos pages ici
import 'profilpage.dart'; // Assurez-vous que cette page existe dans votre projet
import 'contactpage.dart'; // Assurez-vous que cette page existe dans votre projet
import 'addfriendpage.dart'; // Assurez-vous que cette page existe dans votre projet
import 'chatpage.dart';
import '../../models/user.dart';
import '../../models/url.dart';

class ChatListPage extends StatefulWidget {
  final String sessionToken;
  final User currentUser;
 

  const ChatListPage({
    super.key,
    required this.sessionToken,
    required this.currentUser,
  });

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> recentMessages = [];

  @override
  void initState() {
    super.initState();
    _fetchConversation();
  }

  void _fetchConversation() async {
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
          recentMessages = data['recent_messages'];
        });
      } else {
        print('Response is not in JSON format');
      }
    } else {
      print('Failed to load contacts: ${response.statusCode}');
    }
  }

  Future<User> fetchOtherUser(String otherUserId) async {
    final response = await http.get(
      Uri.parse('$url/fetchuser/$otherUserId'),
      headers: {'Authorization': 'Bearer ${widget.sessionToken}'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Failed to load user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Messages'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.grey),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.grey),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage(sessionToken: widget.sessionToken)),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text('Menu'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(sessionToken: widget.sessionToken)));
              },
            ),
            // ListTile(
            //   title: Text('Contacts'),
            //   onTap: () {
            //     Navigator.pop(context); // Close the drawer
            //     Navigator.push(context, MaterialPageRoute(builder: (context) => ContactPage(sessionToken: widget.sessionToken)));
            //   },
            // ),
            ListTile(
              title: Text('Add Friend'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddFriendPage(sessionToken: widget.sessionToken)));
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddFriendPage(sessionToken: widget.sessionToken)),
          );
        },
        child: const Icon(Icons.add),
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
                    color: Colors.grey,
                   /* image: DecorationImage(
                      image: AssetImage(
                          'assets/avatar_placeholder.png'
                          ), // Replace with your asset
                      fit: BoxFit.cover,
                    ),*/

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
                  onTap: () async {
                    try {
                      print("onTap Conversation");
                      // Naviguer vers la page de chat avec les informations nécessaires
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            // Imprimer toutes les données envoyées à la nouvelle page
                            print('Current User: ${widget.currentUser}');
                            print('Conv ID: ${message['conv_id']}');
                            print('Conv Name: ${message['conv_name']}');
                            print('Session Token: ${widget.sessionToken}');
                            
                            return ChatPage(
                              currentUser: widget.currentUser,
                              convId: message['conv_id'], 
                              convName: message['conv_name'],
                              sessionToken: widget.sessionToken,
                            );
                          },
                        ),
                      );
                    } catch (e) {
                      // Gérer les erreurs
                      print('Error: $e');
                    }
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
