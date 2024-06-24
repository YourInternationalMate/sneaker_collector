import 'package:flutter/material.dart';
import 'package:sneaker_collector/models/sneaker.dart';
import 'package:url_launcher/url_launcher.dart';

class BuyingScreen extends StatelessWidget {
  final Sneaker sneaker;

  const BuyingScreen({super.key, required this.sneaker});

  _launchStockX() async {
    final Uri url = Uri.parse(
        'https://stockx.com'); //TODO: Custom URL to direct User to the shoe
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  _launchGoat() async {
    final Uri url = Uri.parse(
        'https://goat.com'); //TODO: Custom URL to direct User to the shoe
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme:
              IconThemeData(color: Theme.of(context).colorScheme.tertiary),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          // Name of Sneaker on top of the Page
          title: Text(
            "${sneaker.brand} ${sneaker.model}",
            style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
                fontWeight: FontWeight.bold,
                fontFamily: "Future",
                fontSize: 24),
          )),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
          child: Column(
            children: <Widget>[
              // Picture of Sneaker + Details
              Image.asset(
                  sneaker.imageUrl), //TODO: load image via URL not assets
              Text(sneaker.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "Future",
                      fontSize: 24)),
              Text('\$${sneaker.price.toStringAsFixed(0)}',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Future",
                      fontSize: 24)),
              const SizedBox(height: 200),

              // Links to StockX and Goat to buy the Sneaker
              SizedBox(
                width: 300,
                height: 70,
                child: ElevatedButton(
                  onPressed: () {
                    _launchStockX();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'StockX',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Future",
                        fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                height: 70,
                child: ElevatedButton(
                  onPressed: () {
                    _launchGoat();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'GOAT',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
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
