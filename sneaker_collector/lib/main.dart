import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sneaker_collector/home_screen.dart';
import 'package:sneaker_collector/theme/theme.dart';
import 'pages/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    )
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sneaker Collector',
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen()
      },
    );
  }
}
