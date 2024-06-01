import 'package:flutter/material.dart';
import 'package:sneaker_collector/components/navbar.dart';
import 'package:sneaker_collector/models/sneaker.dart';
import 'package:sneaker_collector/components/product_card.dart';

class Collection extends StatelessWidget {
  Collection({super.key});

  // Eine Beispiel-Liste mit Produkten (diese kann auch leer sein)
  final List<Sneaker> sneakers = [];
  


  @override
  Widget build(BuildContext context) {
    addItemsTo();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 70),
            Text(
              'Collection',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontFamily: 'future',
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: sneakers.isEmpty
                  ? Text(
                      'Your collection is empty.',
                      style: TextStyle(fontSize: 18),
                    )
                  : ListView.builder(
                      itemCount: sneakers.length,
                      itemBuilder: (context, index) {
                        return ProductCard(sneakers[index]);
                      },
                    ),
            ),
            SizedBox(height: 100)
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
          child: NavBar(2),
        ),
      ),
    );
  }

  void addItemsTo(){ // Hier können Produkte hinzugefügt werden
    for (int i = 0; i < 10; i++){
      sneakers.add(Sneaker(brand: "Adidas", model: "Ultraboost", name: "Disney Goofy", imageUrl: "assets/images/adidas-Ultra-Boost-Disney-Goofy-Product.jpg", price:  320, size:  42, purchasePrice:  250, inCollection:  true, inFavorites:  false));
    }
  }

}