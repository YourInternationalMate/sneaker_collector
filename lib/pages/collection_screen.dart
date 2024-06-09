import 'package:flutter/material.dart';
import 'package:sneaker_collector/models/sneaker.dart';
import 'package:sneaker_collector/components/product_card.dart';
import 'package:sneaker_collector/pages/detail_screen.dart';

class Collection extends StatelessWidget {
  Collection({super.key});

  final List<Sneaker> sneakers = [];
  


  @override
  Widget build(BuildContext context) {
    addItemsTo(); // aktuell nur Beispiel-Produkte
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 70),
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
                        return ProductCard(sneakers[index], onTapFunction: () => navigateToDetailScreen(context, sneakers[index]));
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

  void navigateToDetailScreen(BuildContext context, Sneaker sneaker) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(sneaker: sneaker),
      ),
    );
  }

}