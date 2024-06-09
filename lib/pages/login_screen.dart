import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

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
            Container(
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
                      controller: usernameController,
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
                      controller: passwordController,
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
            ),
          ],
        ),
      ),
    );
  }

  void checkLogin(BuildContext context) {
    //Login Check
    if (usernameController.text == 'admin' &&
        passwordController.text == 'admin') {
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
}
