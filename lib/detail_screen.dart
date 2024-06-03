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
          iconTheme: IconThemeData(color: Colors.black),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            sneaker.brand + " " + sneaker.model,
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: "Future",
                fontSize: 24),
          )),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            children: <Widget>[
              Image.asset(sneaker.imageUrl),
              Text(sneaker.name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "Future",
                      fontSize: 24)),
              Text('\$${sneaker.price.toStringAsFixed(0)}',
                  style: TextStyle(
                      color: const Color(0xFF6F2DFF),
                      fontWeight: FontWeight.bold,
                      fontFamily: "Future",
                      fontSize: 24)),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 50),
                    Text('You Paid:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: "Future",
                            fontSize: 24)),
                    SizedBox(height: 50),
                    Text('You own:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: "Future",
                            fontSize: 24)),
                    SizedBox(height: 50),
                    Text('Your size:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: "Future",
                            fontSize: 24)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
