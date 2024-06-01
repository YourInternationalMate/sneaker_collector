import 'package:flutter/material.dart';
import 'package:sneaker_collector/models/sneaker.dart';

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
                  child: Center(
                    child: Image.asset(sneaker.imageUrl),
                  ),
                ),
                title: Align(
                  alignment: Alignment.topLeft,
                  child: Text(sneaker.brand + " " + sneaker.model, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Future", fontSize: 16)),
                  ),
                subtitle: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                    Text('${sneaker.name}', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Future", fontSize: 16)),
                    Text('\$${sneaker.price.toStringAsFixed(0)}', style: TextStyle(color: const Color(0xFF6F2DFF), fontWeight: FontWeight.bold, fontFamily: "Future", fontSize: 16)),
                    ],
                  ),
                ),
                
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

