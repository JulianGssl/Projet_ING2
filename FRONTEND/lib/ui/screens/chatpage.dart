import 'dart:async';
import 'dart:convert';
 
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/url.dart';
import '../../models/message.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
 
import 'chatlistpage.dart';
 
class ChatPage extends StatefulWidget {
  final int convId;
  final String convName;
  final String sessionToken;
  final User currentUser;
  final String realConvName;

  const ChatPage({
    required this.currentUser,
    required this.convId,
    required this.convName,
    required this.sessionToken,
    required this.realConvName
  });
  
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<dynamic> _messages = [];
  final TextEditingController _textController = TextEditingController();
  late IO.Socket socket;
  // - IO.socket socket : Déclare une variable de type IO.Socket pouvant être null.
  // - late IO.Socket socket : Déclare une variable de type IO.Socket qui doit être initialisée avant utilisation. Déclenche une erreur si non initialisée.
  final ScrollController _scrollController = ScrollController();
  late String _csrfToken;

  Future<void> _initSocketIO() async {
    // Initialisation de la connexion socket.IO
    socket = IO.io(url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    // Connexion au serveur socket.IO
    print("   - _initSocketIO : trying to connect..");
    socket.connect();
    socket.on('connectResponse', (data) {
      print('Connected to the server');
      print('Received message: $data');
    });
  }

  @override
  void dispose() {
    // Arrêtez les timers ou les écouteurs d'événements ici
    if (socket.connected) {
      socket.disconnect(); // Déconnecte le socket
      socket.destroy(); // Détruit le socket
    }
    super.dispose();
  }

  void startChat(groupName) {
    print("Starting chat");
    socket.emit('start_chat', {
      'groupName': groupName
      });
  }
Future<String> _fetchCSRFToken(String formRoute) async {
  // FormRoute représente la route spécifique pour obtenir le jeton CSRF
  final response = await http.get(
    Uri.parse('$url/$formRoute'), // Utilisez la route spécifique passée en paramètre
    headers: {
      'Authorization': 'Bearer ${widget.sessionToken}',
      'Content-Type': 'application/json'
    },
  );
  if (response.statusCode == 200) {
    var responseData = json.decode(response.body);
    String csrfToken = responseData['csrf_token'];
    setState(() {
      _csrfToken = csrfToken;
    });
    return response.body;
  } else {
    throw Exception('Failed to load CSRF token');
  }
}


  Future<void> _fetchMessages(int conversationId) async {
    try {
     final response = await http.post(
        Uri.parse('$url/getmessages'),
        body: jsonEncode({
          'conversation_id': conversationId,
          'id_sender': widget.currentUser.id,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        final messages = responseData.map((data) => Message.fromJson(data)).toList();
        setState(() {
          _messages.addAll(messages);
        });
      } else {
        throw Exception('Failed to fetch conversation messages');
      }
    } catch (error) {
      print('Error fetching conversation data: $error');
    }
  }

  void _addMessage(String text) async {
    if (text.isEmpty) {
      return;
    }
    print("------- Sending message -------");
    print("/chatpage.dart - _addMessage called");

        Map<String, dynamic> messageData = {
        'id_conv': widget.convId, // Remplacez 1 par l'ID de la conversation appropriée
        'recipient': widget.convName,
        'sender_name': widget.currentUser.username,
        'id_sender': widget.currentUser.id,
        'content': text,
        'date': DateTime.now().toIso8601String(),
        'is_read': false, // Le message envoyé est par défaut non lu
        'X-CSRF-TOKEN': _csrfToken,
        'Authorization': 'Bearer ${widget.sessionToken}',
      };

      // Envoi du message via socket.IO pour une communication en temps réel
      socket.emit('private_message', messageData);

      try {
      // Envoi de la requête POST avec les données JSON
      final response = await http.post(
        Uri.parse('$url/private_message'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'X-CSRF-TOKEN': _csrfToken,
          'Authorization': 'Bearer ${widget.sessionToken}',
        },
        body: jsonEncode(messageData),
      );
      // Vérification de la réponse de la requête
      if (response.statusCode == 200) {
        print('Message envoyé avec succès');
        // Vous pouvez éventuellement traiter la réponse ici si nécessaire
      } else {
        print('Erreur lors de l\'envoi du message: ${response.body}');
        // Gestion de l'erreur si la requête a échoué
      }
    } catch (error) {
      print('Erreur: $error');
    }

    _textController.clear();
    print("/chatpage.dart - end of _addMessage");
    _scrollToBottom();
  }

  void _scrollToBottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  void initState() {
    super.initState();
    _fetchCSRFToken('get_CSRF/private_message/3'); // Récupérer le jeton csrf
    print("----------------- ChatPage - initState -----------------");
    // Initialisez la connexion SocketIO
    print("Calling _initSocketIO");
    _initSocketIO();
    print("End call _initSocketIO");
    _fetchMessages(widget.convId);
    
    // On démarre la conversation
    startChat(widget.convName);
    print("/chatpage.dart - roomName: ${widget.convName} username: ${widget.currentUser.username}");

    // On vérifie que la conversation est bien établie
    socket.on('chatStarted', (data) {
      if (data != null) {
        print("/chatpage.dart - Canal de communication établie pour " + data + " V");
      } else {
        print("/chatpage.dart - Erreur lors de l'établissement du canal de communication X");
      }
    });

    socket.emit("TEST");
    socket.on('testResponse', (data) {
      print("TEST RESPONSE : $data");
    });
    // Écoutez les nouveaux messages
    socket.on('new_message', (data) {
      print("------- Receving message -------");
      print("/chatpage.dart - 'new_message' event received");
      print("/chatpage.dart - Message reçu : " + data['content']);

      // Ajout du message reçu à la liste des messages dynamiquement dans l'affichage
      if (mounted) { //! Permet d'éviter des erreurs si le widget n'est pas monté
        setState(() { 
          _messages.add(Message(
            idConv: data['id_conv'], // Utilisation de 'idConv' au lieu de 'id_conv'
            idSender: data['id_sender'], // Utilisation de 'idSender' au lieu de 'id_sender'
            content: data['content'],
            date: DateTime.parse(data['date']),
            isRead: data['is_read'], // Utilisation directe de la valeur booléenne
          ));
          _scrollToBottom();
        });
      }
      print("/chatpage.dart - end of event 'new_message'");
    });
  }


  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
 
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C0F45), Color(0xFF6632C6)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Important pour voir le gradient
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ChatListPage(sessionToken: widget.sessionToken, currentUser: widget.currentUser)),
              );
            },
          ),
          backgroundColor: Colors.transparent, // AppBar transparente pour voir le gradient
          title: Row(
            children: [
              CircleAvatar(
                radius: 25, // Ajustez le rayon pour correspondre à la taille souhaitée
                backgroundColor: Colors.transparent,
                child: Icon(
                  Icons.account_circle,
                  size: 50, // Ajustez la taille pour remplir le CircleAvatar
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 10),
              Text(
                widget.realConvName,
                style: TextStyle(color: Colors.white), // Texte de l'AppBar en blanc
              ),
            ],
          ),
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(4.0),
            child: Divider(
              color: Colors.white24, // La couleur de la barre séparatrice
              height: 1.0, // La hauteur de la barre séparatrice
              thickness: 1.0, // L'épaisseur de la barre séparatrice
            ),
          ),
        ),
        body: Column(
          children: [
            SizedBox(height: 24), // Espace entre la AppBar et le premier message
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                reverse: false,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessage(message); // Votre méthode pour construire chaque message
                },
              ),
            ),
            _buildMessageInput(), // Votre méthode pour l'input de message
          ],
        ),
      ),
    );
  }
 
  Widget _buildMessage(Message message) {
    final bool isUserMessage = message.idSender == widget.currentUser.id;
    final messageColor = isUserMessage ?Color.fromARGB(255, 119, 67, 215) : Color.fromARGB(255, 34, 18, 62);
    final textColor = isUserMessage ? Colors.white : Colors.white;
 
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: messageColor,
          borderRadius: isUserMessage
              ? BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                )
              : BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                  topLeft: Radius.circular(15),
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(color: textColor),
            ),
            SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
 
  Widget _buildMessageInput() {
  return Column(
    children: [
      Divider(
        height: 1,
        thickness: 1,
        color: Colors.white30, // Couleur de la barre pour contraster avec le fond
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Type something...',
                  hintStyle: TextStyle(color: Colors.white60), // Texte indicatif en gris clair/blanc
                  border: InputBorder.none, // Aucune bordure autour du TextField
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
                style: TextStyle(color: Colors.white), // Texte en blanc pour la saisie
              ),
            ),
            IconButton(
              icon: Icon(Icons.send, color: Colors.white), // Icône d'envoi en blanc
              onPressed: () {
                if (_textController.text.trim().isNotEmpty) {
                  _addMessage(_textController.text.trim());
                  _textController.clear(); // Nettoyer le champ après l'envoi
                }
              },
            ),
          ],
        ),
      ),
    ],
  );
}
 
}
