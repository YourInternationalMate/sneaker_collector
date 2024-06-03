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
        iconTheme: IconThemeData(
          color: Colors.black
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            sneaker.name,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: "Future",
              fontSize: 24
            ),
          )
      ),
      body: Center(
        child: Center(
          child: Column(
            children: <Widget>[
              Image.asset(sneaker.imageUrl),
              Text(sneaker.brand + " " + sneaker.model, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Future", fontSize: 24)),
              Text(sneaker.name, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Future", fontSize: 24)),
              Text('\$${sneaker.price.toStringAsFixed(0)}', style: TextStyle(color: const Color(0xFF6F2DFF), fontWeight: FontWeight.bold, fontFamily: "Future", fontSize: 24)),
            ],
            ),
          ),
      ),
    );
  }
}