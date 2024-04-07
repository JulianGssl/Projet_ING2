import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


// Assurez-vous d'importer vos pages ici
import 'profilpage.dart';
import 'customebottomnavbar.dart';
import 'chatpage.dart';
import '../../models/user.dart';
import '../../models/url.dart';
import '../../models/constants.dart';

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
      List<dynamic> messages = data['recent_messages'];

      // Tri des conversations par la date du dernier message (du plus récent au plus ancien)
      messages.sort((a, b) {
        DateTime dateA = DateTime.parse(a['last_message_date']);
        DateTime dateB = DateTime.parse(b['last_message_date']);
        return dateB.compareTo(dateA); // Utilisez `compareTo` pour un tri décroissant
      });

      setState(() {
        recentMessages = messages;
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

  bool hasUnreadMessages(dynamic message, int currentUserId) {
    if (message['is_read'] == false && message['last_message_sender_id'] != currentUserId) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1C0F45),
            Color(0xFF6632C6),
          ],
        ),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Chats', style: TextStyle(fontFamily: fontLufga, color: Colors.white)),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent, // Now transparent to keep the gradient visible
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.account_circle, color: Colors.grey, size: 30.0), // Icon size increased
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage(currentUser: widget.currentUser, sessionToken: widget.sessionToken)),
                );
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
                  hintStyle: TextStyle(color: Colors.white70, fontFamily: fontLufga), // Style du texte indicateur
                  prefixIcon: Icon(Icons.search, color: Colors.white,),
                  filled: true,
                  fillColor: Colors.white24, // Couleur de fond du champ de saisie
                  border: OutlineInputBorder( // Définition de la bordure du champ de saisie
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder( // Bordure du champ de saisie lorsqu'il est activé mais pas encore sélectionné
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.deepPurple.shade100),
                  ),
                  focusedBorder: OutlineInputBorder( // Bordure du champ de saisie lorsqu'il est sélectionné
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.deepPurple.shade700),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0), // Padding intérieur du champ de saisie
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: recentMessages.length,
                itemBuilder: (context, index) {
                  final message = recentMessages[index];
                  return ListTile(
                      leading: CircleAvatar(
                      radius: 25, // Ajustez le rayon pour correspondre à la taille souhaitée
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        Icons.account_circle,
                        size: 50, // Ajustez la taille pour remplir le CircleAvatar
                        color: Colors.white,
                      ),
                    ),
                    title: Text(message['real_conv_name'], style: TextStyle(fontFamily: fontLufga, color: Colors.white),),
                    subtitle: Text(hasUnreadMessages(message, widget.currentUser.id) ? 'Nouveau message' : '', style: TextStyle(fontFamily: fontLufga, color: Colors.white, fontWeight: FontWeight.bold),),
                    trailing: Text(
                      DateFormat.Hm().format(DateTime.parse(message['last_message_date'])), // Formatage en heure et minute
                      style: TextStyle(fontFamily: fontLufga, color: Colors.white)
                    ),
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
                                realConvName: message['real_conv_name']
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
        bottomNavigationBar: CustomBottomAppBar(currentUser: widget.currentUser, sessionToken: widget.sessionToken, activeIndex: 1)
      )
    );
  }
}
