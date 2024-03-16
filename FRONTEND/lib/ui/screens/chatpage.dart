import 'package:flutter/material.dart';
import '../../models/message.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatPage extends StatefulWidget {
  final String roomName;
  final String username;

  const ChatPage({super.key, required this.roomName, required this.username});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  IO.Socket? socket;

  void startChat(String user1, String user2) {
    socket?.emit('start_chat', {
      'user1': user1,
      'user2': user2,
    });
  }

  @override
  void initState() {
    super.initState();
    print("----------------- ChatPage - initState -----------------");
    // Initialisez la connexion SocketIO
    _initSocketIO();

    // On démarre la conversation
    startChat(widget.username, widget.roomName);
    print(
        "/chatpage.dart - roomName: ${widget.roomName} username: ${widget.username}");

    // On vérifie que la conversation est bien établie
    socket?.on('chatStarted', (data) {
      if (data != null) {
        print("/chatpage.dart - Canal de communication établie pour " +
            data +
            " V");
      } else {
        print(
            "/chatpage.dart - Erreur lors de l'établissement du canal de communication X");
      }
    });

    // Écoutez les nouveaux messages
    socket?.on('new_message', (data) {
      print("------- Receving message -------");
      print("/chatpage.dart - Message reçu : " + data['message']);
      // Ajoutez le message reçu à la liste des messages
      String newMessage = data['message'];
      setState(() {
        _messages.add(Message(newMessage, DateTime.now(), data['sender']));
      });
    });
  }

  void _addMessage(String text) {
    if (text.isEmpty) {
      return;
    }
    print("------- Sending message -------");
    print("/chatpage.dart - _addMessage called");
    print(
        "/chatpage.dart - text: $text | sender: ${widget.username} | recipient: ${widget.roomName}");

    // Émettez le message au serveur via SocketIO sans acknowledgment
    socket?.emit('private_message', {
      'sender': widget.username,
      'recipient': widget.roomName,
      'message': text,
    });

    _textController.clear();
    print("/chatpage.dart - end of _addMessage");
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
  final isCurrentUser = message.sender == widget.username;

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10.0),
    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
    decoration: BoxDecoration(
      color: isCurrentUser ? Colors.blueAccent : Colors.green, // Couleur différente pour les messages de l'utilisateur et de l'autre personne
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message.text,
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 4.0),
        Text(
          "${message.time.hour}:${message.time.minute}",
          style: const TextStyle(fontSize: 10.0, color: Colors.white),
        ),
      ],
    ),
  );
}


  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(labelText: 'Enter message'),
              onSubmitted: (text) {
                _addMessage(text);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              _addMessage(_textController.text);
            },
          ),
        ],
      ),
    );
  }

  void _initSocketIO() {
    // Initialisation de la connexion Socket.IO
    socket = IO.io('http://localhost:8000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    // Connexion au serveur Socket.IO
    socket?.connect();
    socket?.on('connectResponse', (data) {
      print('Connected to the server');
      print('Received message: $data');
    });
  }
}
