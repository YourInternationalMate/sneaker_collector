import 'package:flutter/material.dart';
import 'package:sneaker_collector/models/sneaker.dart';

class ProductCard extends StatelessWidget {
  final Sneaker sneaker;
  final Function onTapFunction;

  const ProductCard(this.sneaker, {super.key, required this.onTapFunction});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTapFunction();
      },
      child: SizedBox(
        height: 160,
        child: Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            children: <Widget>[
              ListTile(
                leading: SizedBox(
                    width: 140,
                    height: 100,
                    child: Image.asset(
                        sneaker.imageUrl) //TODO: Bild über URL laden
                    ),
                title: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "${sneaker.brand} ${sneaker.model}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "Future",
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      sneaker.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "Future",
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      '\$${sneaker.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFF6F2DFF),
                        fontWeight: FontWeight.bold,
                        fontFamily: "Future",
                        fontSize: 16,
                      ),
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
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(10),
                    ),
                    child: const Icon(Icons.star, color: Color(0xFF6F2DFF)),
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
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(10),
                    ),
                    child: const Icon(Icons.favorite, color: Color(0xFF6F2DFF)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
