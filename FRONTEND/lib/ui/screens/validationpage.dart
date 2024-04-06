import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../models/constants.dart';
import '../../models/url.dart';
import 'loginpage.dart';


class ValidPage extends StatefulWidget {
  final int idUser;

  const ValidPage({Key? key, required this.idUser}) : super(key: key);

  @override
  ValidPageState createState() => ValidPageState();
}


class ValidPageState extends State<ValidPage> {
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(6, (_) => TextEditingController());
    focusNodes = List.generate(6, (_) => FocusNode());
  }

  void _handleCodeValidation() async {
  // Concatenate the values of each TextEditingController to form the code
  String code = controllers.map((controller) => controller.text).join('');

  // Send the HTTP POST request with the concatenated code
  var response = await http.post(
    Uri.parse('$url/emailConfirm'),
    body: jsonEncode({
      'idUser': widget.idUser,
      'code': code, // Use the concatenated code here
    }),
    headers: {'Content-Type': 'application/json'},
  );
  if (response.statusCode == 200) {
    print("Inscription is validated!");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AuthenticationScreen(),
      ),
    );
  } else {
    print("Invalid code, please try again!");
  }
}


  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }


  

  void _handleKeyEvent(RawKeyEvent event, int index) {
  if (event is RawKeyDownEvent) {
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (index < controllers.length - 1) {
        FocusScope.of(context).requestFocus(focusNodes[index + 1]);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (index > 0) {
        FocusScope.of(context).requestFocus(focusNodes[index - 1]);
      }
    }
  }
}






  Widget _buildCodeDigitField(int index) {
  return Expanded(
    child: RawKeyboardListener(
      focusNode: FocusNode(), // Dummy focus node for listening
      onKey: (event) => _handleKeyEvent(event, index),
      child: TextField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        autofocus: index == 0, // Autofocus the first text field
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
        decoration: InputDecoration(
          counterText: "", // Hides the counter widget
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(5.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(5.0),
          ),
          focusedBorder: OutlineInputBorder( // Make sure the border does not change on focus
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(5.0),
          ),
          hintText: '0',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C0F45), Color(0xFF6632C6)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Enter 6-Digit Code', style: TextStyle(fontFamily: fontLufga, color: Colors.white),),
          backgroundColor: Colors.transparent, // AppBar background is transparent
          elevation: 0, // Removes shadow
          centerTitle: true,
        ),
        body: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => _buildCodeDigitField(index)),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed:
                      _handleCodeValidation, // Appeler la fonction de validation du code
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 80.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: Text('Submit', style: TextStyle(fontSize: 16.0, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
