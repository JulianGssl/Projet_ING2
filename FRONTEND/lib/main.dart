import 'dart:io';
import 'package:flutter/material.dart';

import 'ui/screens/loginpage.dart';

final String url = 'http://localhost:8000';

// Créez un objet SecurityContext
SecurityContext securityContext = SecurityContext();

void main() {
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
      home: LoginPage(), // CALL LOGIN PAGE -> ui/screens/loginpage.dart
    );
  }
}