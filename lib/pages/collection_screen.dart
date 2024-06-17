import 'package:flutter/material.dart';
import 'package:sneaker_collector/models/sneaker.dart';
import 'package:sneaker_collector/components/product_card.dart';
import 'package:sneaker_collector/pages/detail_screen.dart';
import 'package:sneaker_collector/utilities/constants.dart';

class Collection extends StatelessWidget {
  Collection({super.key});

  final List<Sneaker> sneakers = [];

  void addItemsTo() {
    // Hier können Produkte hinzugefügt werden
    for (int i = 0; i < 10; i++) {
      sneakers.add(Sneaker(
          brand: "Adidas",
          model: "Ultraboost",
          name: "Disney Goofy",
          imageUrl: "assets/images/adidas-Ultra-Boost-Disney-Goofy-Product.jpg",
          price: 320,
          count: 1,
          size: 42,
          purchasePrice: 250,
          inCollection: true,
          inFavorites: false));
    }
  }

  void navigateToDetailScreen(BuildContext context, Sneaker sneaker) {
    // Hier wird auf die Detailseite navigiert
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(sneaker: sneaker),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    addItemsTo(); // aktuell nur Beispiel-Produkte
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                '"Collection"',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'future',
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: sneakers.isEmpty
                    ? const Text(
                        'Your collection is empty.',
                        style: TextStyle(fontSize: 18),
                      )
                    : ListView.builder(
                        itemCount: sneakers.length,
                        itemBuilder: (context, index) {
                          return ProductCard(sneakers[index],
                              onTapFunction: () => navigateToDetailScreen(
                                  context, sneakers[index]));
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
