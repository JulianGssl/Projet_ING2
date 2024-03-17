import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Message {
  String text;
  DateTime time;
  bool isUserMessage;
  String? imageUrl;

  Message(this.text, this.time, this.isUserMessage, {this.imageUrl});
}

class ChatPage extends StatefulWidget {
  final String roomName;

  ChatPage(this.roomName);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> _messages = [
    Message('Hello Worlddd', DateTime.now(), false),
    Message('Lorem Ipsum\nttetette', DateTime.now().subtract(Duration(minutes: 1)), true),
  ];
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  void _addMessage(String text, {String? imageUrl}) {
    setState(() {
      _messages.insert(0, Message(text, DateTime.now(), true, imageUrl: imageUrl));
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
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      backgroundColor: Colors.white,
      title: Row(
        children: [
          CircleAvatar(
            // Assurez-vous que le chemin de l'image est correct
            backgroundImage: AssetImage('path/to/your/image.jpg'),
            radius: 16,
          ),
          SizedBox(width: 10),
          Text(
            widget.roomName,
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
              final message = _messages[index];
              return _buildMessage(message);
            },
          ),
        ),
        SizedBox(height: 10), // Ajoutez un espace avant la zone d'entrée de texte
        _buildMessageInput(),
      ],
    ),
  );
}


  Widget _buildMessage(Message message) {
    final bool isUserMessage = message.isUserMessage;
    final messageColor = isUserMessage ? Colors.blue : Colors.grey.shade300;
    final textColor = isUserMessage ? Colors.white : Colors.black87;
    final timeTextStyle = TextStyle(
      fontSize: 10.0,
      color: textColor.withOpacity(0.6),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUserMessage)
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: CircleAvatar(
                backgroundImage: AssetImage('path/to/your/avatar.jpg'), // Replace with your avatar image path
                radius: 16,
              ),
            ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            margin: isUserMessage ? EdgeInsets.only(right: 10.0) : EdgeInsets.only(left: 10.0),
            decoration: BoxDecoration(
              color: messageColor,
              borderRadius: BorderRadius.circular(18.0),
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            child: Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                Text(
                  message.text,
                  style: TextStyle(color: textColor),
                ),
                SizedBox(width: 8.0), // Space between message text and time
                Text(
                  "${message.time.hour.toString().padLeft(2, '0')}:${message.time.minute.toString().padLeft(2, '0')}",
                  style: timeTextStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 3.0,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.photo_camera, color: Colors.grey),
            onPressed: _sendImage,
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Type something...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.blueAccent),
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

