import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;

  // TextField Controller
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _registerUsernameController =
      TextEditingController();
  final TextEditingController _registerPasswordController =
      TextEditingController();

  void checkLogin(BuildContext context) {
    //Login Check
    if (_usernameController.text == 'admin' &&
        _passwordController.text == 'admin') {
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
    // Registration process
    print(_registerUsernameController.text +
        " " +
        _registerPasswordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Logo
              Image.asset('assets/images/logo/SneakerCollectorLogo.png',
                  width: 200, height: 200),
              const SizedBox(height: 50),

              // Display login panel or registration panel
              isLogin ? _loginPanel(context) : _registerPanel(context),
              const SizedBox(height: 20),

              // Change between login and registration on tap
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
                        ? Text(
                            'No account yet? Register here!',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary,
                                fontFamily: 'future'),
                          )
                        : Text(
                            'Already have an account? Login here!',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary,
                                fontFamily: 'future'),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Panel to login the app
  Container _loginPanel(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Heading
          const Text(
            '"LOGIN"',
            style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontFamily: 'future'),
          ),
          const SizedBox(height: 20),

          // Username input
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                  width: 1.0,
                ),
              ),
              labelText: 'USERNAME',
              labelStyle: TextStyle(
                  fontFamily: 'future',
                  color: Theme.of(context).colorScheme.tertiary),
            ),
          ),
          const SizedBox(height: 20),

          // Password input
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                  width: 1.0,
                ),
              ),
              labelText: 'PASSWORD',
              labelStyle: TextStyle(
                  fontFamily: 'future',
                  color: Theme.of(context).colorScheme.tertiary),
            ),
          ),
          const SizedBox(height: 20),

          // Login Button
          ElevatedButton(
            onPressed: () {
              checkLogin(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.tertiary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'LOGIN',
              style:
                  TextStyle(fontFamily: 'future', fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Panel to register a new Acc
  Container _registerPanel(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Heading
          const Text(
            '"REGISTER"',
            style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontFamily: 'future'),
          ),
          const SizedBox(height: 20),

          // Username input
          TextField(
            controller: _registerUsernameController,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                  width: 1.0,
                ),
              ),
              labelText: 'USERNAME',
              labelStyle: TextStyle(
                  fontFamily: 'future',
                  color: Theme.of(context).colorScheme.tertiary),
            ),
          ),
          const SizedBox(height: 20),

          // Password input
          TextField(
            controller: _registerPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                  width: 1.0,
                ),
              ),
              labelText: 'PASSWORD',
              labelStyle: TextStyle(
                  fontFamily: 'future',
                  color: Theme.of(context).colorScheme.tertiary),
            ),
          ),
          const SizedBox(height: 20),

          // Registration button
          ElevatedButton(
            onPressed: () {
              checkRegistration(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.tertiary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'REGISTER',
              style:
                  TextStyle(fontFamily: 'future', fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
