import 'package:flutter/material.dart';
import 'package:sneaker_collector/models/sneaker.dart';
import 'package:sneaker_collector/components/shoe_size_dropdown.dart';

class DetailScreen extends StatelessWidget {
  final Sneaker sneaker;
  final TextEditingController _purchasePriceController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  DetailScreen({super.key, required this.sneaker});

  void saveChanges() {
    print(double.parse(_purchasePriceController.text));
    print(int.parse(_amountController.text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Theme.of(context).colorScheme.tertiary),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            "${sneaker.brand} ${sneaker.model}",
            style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
                fontWeight: FontWeight.bold,
                fontFamily: "Future",
                fontSize: 24),
          )),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
          child: Column(
            children: <Widget>[
              Image.asset(sneaker.imageUrl), //TODO: Bild über URL laden
              Text(sneaker.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "Future",
                      fontSize: 24)),
              Text('\$${sneaker.price.toStringAsFixed(0)}',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Future",
                      fontSize: 24)),
              const SizedBox(height: 70),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('You Paid:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Future",
                          fontSize: 24)),
                  Text('\$${sneaker.purchasePrice.toStringAsFixed(0)}',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Future",
                          fontSize: 24)),
                ],
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('You Own:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Future",
                          fontSize: 24)),
                  Text(sneaker.count.toStringAsFixed(0),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Future",
                          fontSize: 24)),
                ],
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Your Size:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Future",
                          fontSize: 24)),
                  Text(sneaker.size.toStringAsFixed(0),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Future",
                          fontSize: 24)),
                ],
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                        padding: const EdgeInsets.all(20)),
                    child: Icon(Icons.favorite, color: Theme.of(context).colorScheme.secondary),
                  ),
                  const SizedBox(width: 40),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 200),
                            child: AlertDialog(
                              title: const Align(
                                alignment: Alignment.center,
                                child: Text('"Edit Sneaker"', style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Future",
                                ),),
                              ),
                              content: Container(
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                      Text("You Paid: ", style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.secondary
                                      )),
                                      SizedBox(
                                        width: 100,
                                        height: 50,
                                        child: TextField(
                                          controller: _purchasePriceController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: Theme.of(context).colorScheme.secondary,
                                              ),
                                            ),
                                            suffixIcon: const Icon(Icons.attach_money),
                                            hintText: sneaker.purchasePrice.toStringAsFixed(0),
                                          ),
                                        ),
                                      ),
                                        ],
                                        ),
                                        const SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                      Text("You Own: ", style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.secondary
                                      )),
                                      SizedBox(
                                        width: 100,
                                        height: 50,
                                        child: TextField(
                                          controller: _amountController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: Theme.of(context).colorScheme.secondary,
                                              ),
                                            ),
                                            hintText: sneaker.count.toStringAsFixed(0),
                                          ),
                                        ),
                                      ),
                                        ],
                                        ),
                                        const SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Text("Your Size: ", style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).colorScheme.secondary
                                          )),
                                          SizedBox(
                                            width: 100,
                                            height: 50,
                                            child: ShoeSizeDropdown(initialSize: sneaker.size.toStringAsFixed(1)),
                                          ),
                                    ],
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () {
                                        saveChanges();
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.secondary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                                      ),
                                      child: Text("SAVE", style: TextStyle(
                                        color: Theme.of(context).colorScheme.tertiary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Future",
                                      )),
                                    ),
                                  ],
                                  ),
                              ),
                                ),
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: Icon(Icons.edit, color: Theme.of(context).colorScheme.secondary),
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
