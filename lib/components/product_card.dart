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

        // Product card for sneaker
        child: Card(
          color: Theme.of(context).colorScheme.primary,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            children: <Widget>[
              ListTile(
                // image of sneaker
                leading: SizedBox(
                    width: 140,
                    height: 100,
                    child: Image.asset(sneaker
                        .imageUrl) //TODO: Load pictues via network, not assets
                    ),
                // Name of the Sneaker
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

                // Sneaker Details
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
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Future",
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // Buttons to add sneaker to Collection or Favs
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
                    child: Icon(Icons.star,
                        color: Theme.of(context).colorScheme.secondary),
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
                    child: Icon(Icons.favorite,
                        color: Theme.of(context).colorScheme.secondary),
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
