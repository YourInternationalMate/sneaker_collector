import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;

  // Controller für das Login-Panel
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Controller für das Registrierungs-Panel
  final TextEditingController _registerUsernameController =
      TextEditingController();
  final TextEditingController _registerPasswordController =
      TextEditingController();

  @override
  void dispose() {
    // Controller freigeben, wenn der Screen nicht mehr verwendet wird
    _usernameController.dispose();
    _passwordController.dispose();
    _registerUsernameController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, //TODO: Hintergrund Farbe anpassen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/logo/SneakerCollectorLogo.png',
                width: 200, height: 200),
            const SizedBox(height: 100),
            isLogin ? _loginPanel(context) : _registerPanel(context),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin =
                          !isLogin; // Wechselt den Zustand zwischen Login und Registrierung
                    });
                  },
                  child: isLogin
                      ? const Text(
                          'No account yet? Register here!',
                          style: TextStyle(
                              color: Colors.white, fontFamily: 'future'),
                        )
                      : const Text(
                          'Already have an account? Login here!',
                          style: TextStyle(
                              color: Colors.white, fontFamily: 'future'),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container _loginPanel(BuildContext context) {
    return Container(
      width: 300,
      height: 320,
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            '"LOGIN"',
            style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontFamily: 'future'),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 250,
            child: TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'USERNAME',
                labelStyle: TextStyle(fontFamily: 'future'),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 250,
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'PASSWORD',
                labelStyle: TextStyle(fontFamily: 'future'),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 250,
            child: ElevatedButton(
              onPressed: () {
                checkLogin(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6F2DFF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'LOGIN',
                style: TextStyle(
                    fontFamily: 'future', fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container _registerPanel(BuildContext context) {
    return Container(
      width: 300,
      height: 320,
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            '"REGISTER"',
            style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontFamily: 'future'),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 250,
            child: TextField(
              controller: _registerUsernameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'USERNAME',
                labelStyle: TextStyle(fontFamily: 'future'),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 250,
            child: TextField(
              controller: _registerPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'PASSWORD',
                labelStyle: TextStyle(fontFamily: 'future'),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 250,
            child: ElevatedButton(
              onPressed: () {
                checkRegistration(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6F2DFF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'REGISTER',
                style: TextStyle(
                    fontFamily: 'future', fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void checkLogin(BuildContext context) {
    //Login Check
    if (_usernameController.text == 'admin' &&
        _passwordController.text == 'admin') {
      // dispose();
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      showDialog(
        //Login Failed PopUp
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Login failed'),
            content: const Text('Username or password is incorrect.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void checkRegistration(BuildContext context) {
    print(_registerUsernameController.text +
        " " +
        _registerPasswordController.text);
  }
}
