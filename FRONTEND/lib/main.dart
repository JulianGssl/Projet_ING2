import 'dart:io';
import 'package:flutter/material.dart';

import 'ui/screens/loginpage.dart';

// Créez un objet SecurityContext
SecurityContext securityContext = SecurityContext();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {  
    return MaterialApp(
      title: 'Flutter Messenger',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthenticationScreen(), // CALL LOGIN PAGE -> ui/screens/loginpage.dart
    );
  }
}
