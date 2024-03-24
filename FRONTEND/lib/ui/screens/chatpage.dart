import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;


const String url = 'http://localhost:8000';


class ChatPage extends StatefulWidget {
  final int groupId;
  final String groupName;
  final String sessionToken;


  ChatPage(this.groupId, this.groupName, this.sessionToken);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  // final List<Message> _messages = [
  //   Message('Hello Worlddd', DateTime.now(), false),
  //   Message('Lorem Ipsum\nttetette', DateTime.now().subtract(Duration(minutes: 1)), true),
  // ];
  List<dynamic> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();


  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }


 void _fetchMessages() async {
  final response = await http.post(
    Uri.parse('$url/messages'),
    body: jsonEncode({
       "id_conv": widget.groupId 
    }),
    headers: {'Authorization': 'Bearer ${widget.sessionToken}', 
              'Content-Type': 'application/json'
    },
  );
  if (response.statusCode == 200) {
    final contentType = response.headers['content-type'];
    if (contentType != null && contentType.contains('application/json')) {
        final data = jsonDecode(response.body);
        print(data);
        setState(() {
          _messages = data['messages'];
        });
        print("OKOKKOKKO");
    } else {
      print('Response is not in JSON format');
    }
  } else {
    print('Failed to load contacts: ${response.statusCode}');
  }
}

  void _addMessage(String text, {String? imageUrl}) {
    final newMessage = {
      'content': text,
      'date': DateTime.now().toIso8601String(), // Format ISO pour la cohérence avec le backend
      'current_user': true, // Supposons que c'est un message de l'utilisateur actuel
      'imageUrl': imageUrl, // Si l'image est nulle, ce champ peut être omis ou rester nul
    };
    
    setState(() {
      _messages.insert(0, newMessage);
      _textController.clear();
    });
  }

  Future<void> _sendImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _addMessage('', imageUrl: image.path);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('path/to/your/image.jpg'), // Assurez-vous que le chemin de l'image est correct
              radius: 16,
            ),
            SizedBox(width: 10),
            Text(
              widget.groupName,
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessage(dynamic message) {
    final bool isUserMessage = message['current_user'];
    final messageColor = isUserMessage ? Colors.blue : Colors.grey.shade300;
    final textColor = isUserMessage ? Colors.white : Colors.black87;
    final DateTime time = DateTime.parse(message['date']);

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
              message['content'],
              style: TextStyle(color: textColor),
            ),
            SizedBox(height: 5),
            // Text(
            //   DateFormat('h:mm a').format(time), // Formattez l'heure correctement
            //   style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 10),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.photo_camera, color: Colors.grey),
            onPressed: _sendImage,
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration.collapsed(
                hintText: 'Type something...',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.blue),
            onPressed: () {
              if (_textController.text.trim().isNotEmpty) {
                _addMessage(_textController.text.trim());
              }
            },
          ),
        ],
      ),
    );
  }
}

