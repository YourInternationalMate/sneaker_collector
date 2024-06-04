import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sneaker_collector/collection.dart';
import 'package:sneaker_collector/favorites.dart';
import 'login_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sneaker Collector',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: { // routing zwischen den Seiten
        '/': (context) => LoginScreen(),
        '/login': (context) => LoginScreen(),
        '/favorites': (context) => Favorites(),
        '/collection': (context) => Collection(),
      },
    );
  }
}