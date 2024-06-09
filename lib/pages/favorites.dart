import 'package:flutter/material.dart';
import 'package:sneaker_collector/components/navbar.dart';
import 'package:sneaker_collector/models/sneaker.dart';
import 'package:sneaker_collector/components/product_card.dart';
import 'package:sneaker_collector/pages/buying_screen.dart';

class Favorites extends StatelessWidget {
  Favorites({super.key});

  final List<Sneaker> sneakers = [];
  


  @override
  Widget build(BuildContext context) {
    addItemsTo();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 70),
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
            const SizedBox(height: 100)
          ],
        ),
      ),

      // Navigation Bar
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: 65,
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: const Color(0xFF6F2DFF),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: NavBar(1),
        ),
      ),
    );
  }

  void addItemsTo(){ // Hier können Produkte hinzugefügt werden
    for (int i = 0; i < 10; i++){
      sneakers.add(Sneaker(brand: "Adidas", model: "Ultraboost", name: "Disney Goofy", imageUrl: "assets/images/adidas-Ultra-Boost-Disney-Goofy-Product.jpg", price:  320, count: 1, size:  42, purchasePrice:  250, inCollection:  true, inFavorites:  false));
    }
  }

  void navigateToBuyingScreen(BuildContext context, Sneaker sneaker) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuyingScreen(sneaker: sneaker),
      ),
    );
  }

}