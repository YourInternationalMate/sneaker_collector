import 'package:flutter/material.dart';
import 'package:sneaker_collector/models/sneaker.dart';
import 'package:sneaker_collector/components/product_card.dart';
import 'package:sneaker_collector/pages/buying_screen.dart';
import 'package:sneaker_collector/utilities/constants.dart';

class Favorites extends StatelessWidget {
  Favorites({super.key});

  final List<Sneaker> sneakers = [];
  


  @override
  Widget build(BuildContext context) {
    addItemsTo();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: Constants.isAndroid ? 30 : 70,),
            const Text(
              '"Favorites"',
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
                      "You've not added any favorites yet.",
                      style: TextStyle(fontSize: 18),
                    )
                  : ListView.builder(
                      itemCount: sneakers.length,
                      itemBuilder: (context, index) {
                        return ProductCard(sneakers[index], onTapFunction: () => navigateToBuyingScreen(context, sneakers[index]));
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void addItemsTo(){ // Hier können Produkte hinzugefügt werden
    for (int i = 0; i < 10; i++){
      sneakers.add(Sneaker(brand: "Adidas", model: "Ultraboost", name: "Disney Goofy", imageUrl: "assets/images/adidas-Ultra-Boost-Disney-Goofy-Product.jpg", price:  320, count: 1, size:  42, purchasePrice:  250, inCollection:  true, inFavorites:  false));
    }
  }

  void navigateToBuyingScreen(BuildContext context, Sneaker sneaker) { // Hier wird auf die Detailseite navigiert
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuyingScreen(sneaker: sneaker),
      ),
    );
  }

}