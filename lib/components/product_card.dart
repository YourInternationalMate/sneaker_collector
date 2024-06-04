import 'package:flutter/material.dart';
import 'package:sneaker_collector/models/sneaker.dart';
import 'package:sneaker_collector/detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Sneaker sneaker;

  const ProductCard(this.sneaker);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DetailScreen(sneaker: sneaker)),
        );
      },
      child: Container(
        height: 160,
        child: Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Container(
                    width: 140,
                    height: 100,
                    child: Image.asset(sneaker.imageUrl)), // TODO: Bild zentrieren 
                title: Align(
                  alignment: Alignment.topLeft,
                  child: Text(sneaker.brand + " " + sneaker.model,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Future",
                          fontSize: 16)),
                ),
                subtitle: Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(sneaker.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: "Future",
                              fontSize: 16)),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text('\$${sneaker.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                              color: const Color(0xFF6F2DFF),
                              fontWeight: FontWeight.bold,
                              fontFamily: "Future",
                              fontSize: 16)),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      if (sneaker.inCollection) {
                        sneaker.setInCollection(false);
                      } else {
                        sneaker.setInCollection(true);
                      } //TOOO: Aktualisierung der Anzeige
                    },
                    style: ElevatedButton.styleFrom(
                        shape: CircleBorder(), padding: EdgeInsets.all(10)),
                    child: Icon(Icons.star, color: const Color(0xFF6F2DFF)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (sneaker.inFavorites) {
                        sneaker.setInFavorites(false);
                      } else {
                        sneaker.setInFavorites(true);
                      }
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
      ),
    );
  }
}
