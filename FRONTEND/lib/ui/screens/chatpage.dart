import 'package:flutter/material.dart';
import '../../models/message.dart';

class ChatPage extends StatefulWidget {
  final String roomName;

  ChatPage(this.roomName);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();

  void _addMessage(String text) {
    setState(() {
      _messages.add(Message(text, DateTime.now()));
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
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.text,
            style: TextStyle(color: Colors.white),
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