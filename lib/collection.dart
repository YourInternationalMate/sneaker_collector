import 'package:flutter/material.dart';
import 'package:sneaker_collector/components/navbar.dart';
import 'package:sneaker_collector/models/sneaker.dart';

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
      sneakers.add(Sneaker(name: "test", imageUrl: "https://i.ibb.co/jgX3RtP/adidas-Ultra-Boost-Disney-Goofy-Product.jpg", price:  320, size:  42, purchasePrice:  250, inCollection:  true, inFavorites:  false));
    }
  }

}

//ProductCard Widget

class ProductCard extends StatelessWidget {
  final Sneaker sneaker;

  const ProductCard(this.sneaker);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
        child: Card(
          color: Colors.white,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
          
              ListTile(
                leading: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 140,
                    minHeight: 100,
                    maxWidth: 140,
                    maxHeight: 100,
                  ),
                  child: Image.network(sneaker.imageUrl, fit: BoxFit.cover),
                ),
                title: Text(sneaker.name, style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('\$${sneaker.price.toStringAsFixed(2)}', style: TextStyle(color: const Color(0xFF6F2DFF))),
                
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  // Add to Collection
                },
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(10)
                ),
                child: Icon(Icons.star, color: const Color(0xFF6F2DFF)),
              ),
              ElevatedButton(
                onPressed: () {
                  // Add to Favs
                },
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(), 
                  padding: EdgeInsets.all(10), 
                ),
                child: Icon(Icons.favorite, color: const Color(0xFF6F2DFF)),
              ),
            ],
          )
            ],
          ),
        ),
    );

  }
}

