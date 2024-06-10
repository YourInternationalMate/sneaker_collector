import 'package:flutter/material.dart';
import 'package:sneaker_collector/models/user.dart';
import 'package:sneaker_collector/utilities/constants.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final User user = User(
      // Test User
      name: "Max Musterman",
      email: "test.test@test.de",
      password: "123456",
      since: "01.01.2021");

  void saveData(BuildContext context) {
    print(_usernameController.text +
        " " +
        _passwordController.text); //TODO: Daten speichern
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: Constants.isAndroid ? 30 : 70,
            ),
            const Text(
              '"Profile"',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontFamily: 'future',
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: <Widget>[
                const SizedBox(height: 30),
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(
                          "assets/images/logo/SneakerCollectorLogo.png"), // TODO: Bild in DB
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(user.name,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6F2DFF))),
                Text(user.since, style: const TextStyle(fontSize: 15)),
                Padding(
                  padding: const EdgeInsets.only(bottom: 50, left: 25, right: 25, top: 50),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 500,
                    alignment: Alignment.topCenter,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        //Username
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 50, bottom: 5),
                            child: Text("USERNAME",
                                style: TextStyle(
                                    fontSize: 15, color: Color(0xFF6F2DFF))),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50.0),
                          child: TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFF6F2DFF),
                                ),
                              ),
                              suffixIcon: const Icon(Icons.person),
                              hintText: user.name,
                            ),
                          ),
                        ),
                  
                        //Passwort
                        const SizedBox(height: 20),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 50, bottom: 5),
                            child: Text("PASSWORD",
                                style: TextStyle(
                                    fontSize: 15, color: Color(0xFF6F2DFF))),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50.0),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFF6F2DFF),
                                ),
                              ),
                              suffixIcon: const Icon(Icons.lock),
                              hintText: "•" * user.password.length,
                            ),
                          ),
                        ),
                  
                        //Save Button
                        const SizedBox(height: 30),
                        SizedBox(
                          width: 250,
                          child: ElevatedButton(
                            onPressed: () {
                              saveData(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6F2DFF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'SAVE',
                              style: TextStyle(
                                  fontFamily: 'future',
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20,)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
