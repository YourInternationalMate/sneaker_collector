import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sneaker_collector/pages/collection.dart';
import 'package:sneaker_collector/pages/favorites.dart';
import 'package:sneaker_collector/pages/profile.dart';
import 'package:sneaker_collector/pages/search.dart';
import 'pages/login_screen.dart';


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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: { // routing zwischen den Seiten
        '/': (context) => LoginScreen(),
        '/search': (context) => SearchScreen(),
        '/favorites': (context) => Favorites(),
        '/collection': (context) => Collection(),
        '/profile': (context) => const Profile(),
      },
    );
  }
}