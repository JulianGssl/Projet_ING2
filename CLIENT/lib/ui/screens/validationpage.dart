import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/url.dart';
import 'loginpage.dart';

class ValidPage extends StatefulWidget {
  final int idUser;

  const ValidPage({Key? key, required this.idUser}) : super(key: key);

  @override
  ValidPageState createState() => ValidPageState();
}

class ValidPageState extends State<ValidPage> {
  late TextEditingController _controller1;
  late TextEditingController _controller2;
  late TextEditingController _controller3;
  late TextEditingController _controller4;
  late TextEditingController _controller5;
  late TextEditingController _controller6;

  @override
  void initState() {
    super.initState();
    _controller1 = TextEditingController();
    _controller2 = TextEditingController();
    _controller3 = TextEditingController();
    _controller4 = TextEditingController();
    _controller5 = TextEditingController();
    _controller6 = TextEditingController();
  }

  @override
  void dispose() {
    // Dispose des contrôleurs
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    _controller5.dispose();
    _controller6.dispose();
    super.dispose();
  }

  void _handleCodeValidation() async {
    // Récupération du code saisi par l'utilisateur
    String code = _controller1.text +
        _controller2.text +
        _controller3.text +
        _controller4.text +
        _controller5.text +
        _controller6.text;

    var response = await http.post(
      Uri.parse('$url/emailConfirm'),
      body: jsonEncode({
        'idUser': widget.idUser,
        'code': code,
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
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Enter 6-Digit Code'),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCodeDigitField(_controller1),
                    _buildCodeDigitField(_controller2),
                    _buildCodeDigitField(_controller3),
                    _buildCodeDigitField(_controller4),
                    _buildCodeDigitField(_controller5),
                    _buildCodeDigitField(_controller6),
                  ],
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed:
                      _handleCodeValidation, // Appeler la fonction de validation du code
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeDigitField(TextEditingController controller) {
    return Container(
      width: 40.0,
      height: 60.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2.0),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counter: SizedBox.shrink(),
          border: InputBorder.none,
          hintText: '0',
        ),
      ),
    );
  }
}
