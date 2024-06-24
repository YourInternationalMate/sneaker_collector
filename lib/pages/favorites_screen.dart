import 'package:flutter/material.dart';
import 'package:sneaker_collector/models/sneaker.dart';
import 'package:sneaker_collector/components/product_card.dart';
import 'package:sneaker_collector/pages/buying_screen.dart';

class Favorites extends StatelessWidget {
  Favorites({super.key});

  final List<Sneaker> sneakers = [];

  void addItemsTo() {
    // creating test list of element (needs to be removed)
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

  void navigateToBuyingScreen(BuildContext context, Sneaker sneaker) {
    // navigation to Detail Screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuyingScreen(sneaker: sneaker),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    addItemsTo();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Heading
              const Text(
                '"Favorites"',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'future',
                ),
              ),
              const SizedBox(height: 10),

              // List of all Sneakers saved as Favs
              Expanded(
                child: sneakers.isEmpty
                    ? const Text(
                        "You've not added any favorites yet.",
                        style: TextStyle(fontSize: 18),
                      )
                    : ListView.builder(
                        itemCount: sneakers.length,
                        itemBuilder: (context, index) {
                          return ProductCard(sneakers[index],
                              onTapFunction: () => navigateToBuyingScreen(
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
