// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:cookie_jar/cookie_jar.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:crypto/crypto.dart';         // ATTENTION cette bibliothèque n'as pas été tester par des pro de securité
// //import 'package:pointycastle/export.dart';
// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'dart:convert';  
// import 'package:http/http.dart' as http;
// import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';



// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:cookie_jar/cookie_jar.dart';
// import 'package:http/io_client.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';


import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';


final String url = 'http://localhost:8000';



// Créez un objet SecurityContext
SecurityContext securityContext = SecurityContext();

// Désactivez la vérification du certificat
// securityContext.setTrustedCertificatesBytes([]);

void main() {
  // Désactiver la vérification du certificat TLS
  // HttpClient httpClient = HttpClient()
  //   ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  
  //http.Client client = http.Client(context: securityContext);



  // Pour la gestion des cookie , ne fonctionne pas 
  // // Créez un objet CookieJar
  // final cookieJar = CookieJar();

  // // Créez un client HTTP avec le CookieJar
  // final client = http.Client();
  // client.cookieJar = cookieJar;


  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Messenger',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () async {
                print("Trying to login...");
                var response = await http.post(
                  Uri.parse('$url/login'),
                  body: jsonEncode({
                    'username': _usernameController.text,
                    'password': _passwordController.text
                  }),
                  headers: {'Content-Type': 'application/json'},
                );
                //var response2 = await http.get( Uri.parse('$url/test'));
                print("Received response: ${response.statusCode}");
                print("Response body: ${response.body}");
                if (response.statusCode == 200) {
                  print("Login successful, navigating to ChatListPage");
                  var responseData = json.decode(response.body);
                  String sessionToken = responseData['access_token'];
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ChatListPage(sessionToken)),
                  );
                } else {
                  print("Invalid credentials received, updating error message");
                  setState(() {
                    _errorMessage = 'Identifiants invalides. Veuillez réessayer.';
                  });
                }
              },
              child: Text('Login'),
            ),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatListPage extends StatefulWidget {  // Modif pr renouv token sessionToken plus final
  String sessionToken; 

  ChatListPage(this.sessionToken);
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<String> _contacts = []; // Liste des contacts
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _fetchContacts(); // Appel à la méthode pour récupérer les contacts
    _startTokenRefreshTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }


  // Méthode pour démarrer le timer pour le renouvellement automatique du token
  void _startTokenRefreshTimer() {
    const refreshThreshold = Duration(minutes: 1); // Temps d'intervalle pour le renouvellement du token
    _timer = Timer.periodic(refreshThreshold, (timer) {
      _refreshTokenIfNeeded(); // Vérifie si le token doit être renouvelé
    });
  }

  // Méthode pour renouveler le token si nécessaire
  void _refreshTokenIfNeeded() async {
    print('Refreshing token...');
    var response = await http.post(
      Uri.parse('$url/refresh_token'),
      headers: {'Authorization': 'Bearer ${widget.sessionToken}'},
    );
    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      String newToken = responseData['access_token'];
      // Met à jour le token avec le nouveau token renouvelé
      setState(() {
        widget.sessionToken = newToken;
      });
      print('Token refreshed successfully');
    } else {
      print('Failed to refresh token: ${response.statusCode}');
    }
  }

  // Méthode pour récupérer les contacts depuis le serveur
 void _fetchContacts() async {
  final response = await http.get(
      Uri.parse('$url/contacts'),
      headers: {'Authorization': 'Bearer ${widget.sessionToken}'},);
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


  // Méthode pour se déconnecter
  void _logout() async {
    final response = await http.post(
      Uri.parse('$url/logout'),
      headers: {'Authorization': 'Bearer ${widget.sessionToken}'},
    );
    if (response.statusCode == 200) {
      // Rediriger vers la page de connexion
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      print('log out succesful');
    } else {
      print('Failed to logout: ${response.statusCode}');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search functionality here
            },
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: _logout,
        ),
      ),
      body: ListView(
        children: [
          _buildChatListItem(context, "Moi"), // Chat "Moi"
          // Afficher tous les contacts récupérés de la même manière
          ..._contacts.map((contact) => _buildChatListItem(context, contact)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddFriendPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildChatListItem(BuildContext context, String roomName) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.person), // Placeholder for user image
        ),
        title: Text(
          roomName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatPage(roomName)),
          );
        },
      ),
    );
  }
}

// AddFriendPage and ChatPage classes remain the same





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

class ChatPage extends StatefulWidget {
  final String roomName;

  ChatPage(this.roomName);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  bool _isBlueBackground = true;

  void _addMessage(String text) {
    setState(() {
      _messages.add(Message(text, DateTime.now(), _isBlueBackground));
      _isBlueBackground = !_isBlueBackground; // Toggle background color
      _textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessage(message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessage(Message message) {
    Color? backgroundColor = message.isBlueBackground ? Colors.blueAccent : Colors.grey[300];

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.text,
            style: TextStyle(color: Colors.black),
          ),
          SizedBox(height: 4.0),
          Text(
            "${message.time.hour}:${message.time.minute}",
            style: TextStyle(fontSize: 10.0, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(labelText: 'Enter message'),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              _addMessage(_textController.text);
            },
          ),
        ],
      ),
    );
  }
}

class Message {
  final String text;
  final DateTime time;
  final bool isBlueBackground; // Added property

  Message(this.text, this.time, this.isBlueBackground);
}
