import 'package:flutter/material.dart';
import 'dart:async';

import 'loginpage.dart'; // Assurez-vous que la classe AuthenticationScreen est définie ici

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoadingHomePage(),
    );
  }
}

class LoadingHomePage extends StatefulWidget {
  @override
  _LoadingHomePageState createState() => _LoadingHomePageState();
}

class _LoadingHomePageState extends State<LoadingHomePage> {
  double _progress = 0.0; // Initial progress value

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() {
    Timer.periodic(Duration(milliseconds: 20), (timer) {
      setState(() {
        _progress += 0.01; // Augmente la progression
        if (_progress >= 1) {
          timer.cancel(); // Arrête le timer
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuthenticationScreen())); // Navigue vers la page de connexion
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.center,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1C0F45),
            Color(0xFF6632C6),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset('assets/images/logo.png', width: 300), // Assurez-vous que le chemin d'accès et le nom du fichier sont corrects
              ),
              Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 200, // Largeur de la barre de chargement
                height: 10, // Hauteur de la barre de chargement
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5), // Rayon de bordure arrondie
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Couleur de la barre de chargement
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
