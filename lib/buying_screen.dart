import 'package:flutter/material.dart';
import 'package:sneaker_collector/models/sneaker.dart';

class BuyingScreen extends StatelessWidget {
  final Sneaker sneaker;

  const BuyingScreen({required this.sneaker});

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
              const SizedBox(height: 200),
              Container(
                width: 300,
                height: 70,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'StockX',
                    style: TextStyle(
                        color: Color(0xFF6F2DFF),
                        fontWeight: FontWeight.bold,
                        fontFamily: "Future",
                        fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 300,
                height: 70,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'GOAT',
                    style: TextStyle(
                        color: Color(0xFF6F2DFF),
                        fontWeight: FontWeight.bold,
                        fontFamily: "Future",
                        fontSize: 24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
