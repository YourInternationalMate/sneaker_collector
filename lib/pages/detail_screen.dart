import 'package:flutter/material.dart';
import 'package:sneaker_collector/models/sneaker.dart';
import 'package:sneaker_collector/components/shoe_size_dropdown.dart';

class DetailScreen extends StatefulWidget {
  final Sneaker sneaker;

  const DetailScreen ({ Key? key, required this.sneaker }): super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late TextEditingController _purchasePriceController;
  late TextEditingController _amountController;
  late double purchasePrice;
  late int count;
  late double size;
  String _selectedSize = '';
  

  @override
  void initState() {
    super.initState();
    _purchasePriceController = TextEditingController();
    _amountController = TextEditingController();
    purchasePrice = widget.sneaker.purchasePrice;
    count = widget.sneaker.count;
    size = widget.sneaker.size;
  }

  @override
  void dispose() {
    _purchasePriceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void saveChanges() {
    if (_purchasePriceController.text.isNotEmpty) {
      widget.sneaker.setPurchasePrice(double.parse(_purchasePriceController.text));
    }
    if (_amountController.text.isNotEmpty) {
      widget.sneaker.setCount(int.parse(_amountController.text));
    }
    if (_selectedSize.isNotEmpty) {
      widget.sneaker.setSize(double.parse(_selectedSize));
    }
    setState(() {
      purchasePrice = widget.sneaker.purchasePrice;
      count = widget.sneaker.count;
      size = widget.sneaker.size;
    });

    //TODO: Datenbank update
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme:
              IconThemeData(color: Theme.of(context).colorScheme.tertiary),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          // Sneaker name on top of Page as Heading
          title: Text(
            "${widget.sneaker.brand} ${widget.sneaker.model}",
            style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
                fontWeight: FontWeight.bold,
                fontFamily: "Future",
                fontSize: 24),
          )),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
            child: Column(
              children: <Widget>[
                // Picture of Sneaker + Details
                Image.asset(
                    widget.sneaker.imageUrl), //TODO: Load images from URL not assets
                Text(widget.sneaker.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "Future",
                        fontSize: 24)),
                Text('\$${widget.sneaker.price.toStringAsFixed(0)}',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Future",
                        fontSize: 24)),
                const SizedBox(height: 70),
        
                // Details the of the owned shoe; Personal to user
                // How much user spend
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text('You Paid:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: "Future",
                            fontSize: 24)),
                    Text('\$$purchasePrice',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Future",
                            fontSize: 24)),
                  ],
                ),
                const SizedBox(height: 50),
        
                // How many user owns
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text('You Own:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: "Future",
                            fontSize: 24)),
                    Text(count.toStringAsFixed(0),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Future",
                            fontSize: 24)),
                  ],
                ),
                const SizedBox(height: 50),
        
                // What size it is
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text('Your Size:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: "Future",
                            fontSize: 24)),
                    Text(size.toStringAsFixed(0),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Future",
                            fontSize: 24)),
                  ],
                ),
                const SizedBox(height: 50),
        
                // Buttons to edit details and to add to Favs
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Add to Favs
                    ElevatedButton(
                      onPressed: () {
                        if (widget.sneaker.inFavorites) {
                          widget.sneaker.setInFavorites(false);
                        } else {
                          widget.sneaker.setInFavorites(true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20)),
                      child: Icon(Icons.favorite,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                    const SizedBox(width: 40),
                    // Edit Details
                    ElevatedButton(
                      onPressed: () {
                        editDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                      ),
                      child: Icon(Icons.edit,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Menu to edit sneaker details
  Future<dynamic> editDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Align(
            alignment: Alignment.center,
            // Heading
            child: Text(
              '"Edit Sneaker"',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: "Future",
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  // Edit paid amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text("You Paid: ",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary)),
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
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary)),
                            suffixIcon: const Icon(Icons.attach_money),
                            hintText: widget.sneaker.purchasePrice.toStringAsFixed(0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
            
                  // Edit quantity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text("You Own: ",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary)),
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
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary)),
                            hintText: widget.sneaker.count.toStringAsFixed(0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
            
                  // Edit size
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text("Your Size: ",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary)),
                      ShoeSizeDropdown(
                          onSizeSelected: (String size) {
                            setState(() {
                              _selectedSize = size;
                            });
                          }),
                    ],
                  ),
                  const SizedBox(height: 20),
            
                  // Save Changes
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 10),
                    ),
                    child: Text("SAVE",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
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
  }
}
