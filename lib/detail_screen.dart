import 'package:flutter/material.dart';
import 'package:sneaker_collector/models/sneaker.dart';

class DetailScreen extends StatelessWidget {
  final Sneaker sneaker;

  const DetailScreen({required this.sneaker});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            sneaker.brand + " " + sneaker.model,
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: "Future",
                fontSize: 24),
          )),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
          child: Column(
            children: <Widget>[
              Image.asset(sneaker.imageUrl),
              Text(sneaker.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "Future",
                      fontSize: 24)),
              Text('\$${sneaker.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: Color(0xFF6F2DFF),
                      fontWeight: FontWeight.bold,
                      fontFamily: "Future",
                      fontSize: 24)),
              const SizedBox(height: 70),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('You Paid:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Future",
                          fontSize: 24)),
                  Text('\$${sneaker.purchasePrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: Color(0xFF6F2DFF),
                          fontWeight: FontWeight.bold,
                          fontFamily: "Future",
                          fontSize: 24)),
                ],
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('You Own:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Future",
                          fontSize: 24)),
                  Text(sneaker.count.toStringAsFixed(0),
                      style: const TextStyle(
                          color: Color(0xFF6F2DFF),
                          fontWeight: FontWeight.bold,
                          fontFamily: "Future",
                          fontSize: 24)),
                ],
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Your Size:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Future",
                          fontSize: 24)),
                  Text('${sneaker.size.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: Color(0xFF6F2DFF),
                          fontWeight: FontWeight.bold,
                          fontFamily: "Future",
                          fontSize: 24)),
                ],
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (sneaker.inFavorites) {
                        sneaker.setInFavorites(false);
                      } else {
                        sneaker.setInFavorites(true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20)),
                    child: Icon(Icons.favorite, color: const Color(0xFF6F2DFF)),
                  ),
                  const SizedBox(width: 40),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const AlertDialog(
                            //TODO: Änderungsmenü einfügen
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: Icon(Icons.edit, color: const Color(0xFF6F2DFF)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
