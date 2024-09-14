import 'package:flutter/material.dart';
import 'package:sneaker_collector/models/sneaker.dart';
import 'package:sneaker_collector/components/product_card.dart';
import 'package:sneaker_collector/pages/buying_screen.dart';

class Search extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<Search> {
  List<Sneaker> sneakers = [];
  List<Sneaker> filteredSneakers = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    addItemsTo();
    searchController.addListener(() {
      filterSneakers();
    });
  }

  void filterSneakers() {
    // list that adapts to search parameters
    List<Sneaker> _sneakers = [];
    _sneakers.addAll(sneakers);
    if (searchController.text.isNotEmpty) {
      List<String> searchTerms = searchController.text.toLowerCase().split(' ');
      _sneakers.retainWhere((sneaker) {
        String sneakerName = sneaker.name.toLowerCase();
        String sneakerBrand = sneaker.brand.toLowerCase();
        String sneakerModel = sneaker.model.toLowerCase();
        return searchTerms.every((term) =>
            sneakerName.contains(term) ||
            sneakerBrand.contains(term) ||
            sneakerModel.contains(term));
      });
    }
    setState(() {
      filteredSneakers = _sneakers;
    });
  }

  void navigateToBuyingScreen(BuildContext context, Sneaker sneaker) {
    // Navigation to Detail Screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuyingScreen(sneaker: sneaker),
      ),
    );
  }

  void addItemsTo() {
    // list of shoes that gets shown on the page (currently mock data)
    // TODO: replace with actual data

    sneakers.add(Sneaker(
        brand: "Adidas",
        model: "Ultraboost",
        name: "Disney Goofy",
        imageUrl: "assets/images/adidas-Ultra-Boost-Disney-Goofy-Product.jpg",
        price: 320,
        count: 1,
        size: 42,
        purchasePrice: 250,
        inCollection: true,
        inFavorites: false));

    sneakers.add(Sneaker(
        brand: "Nike",
        model: "SB Dunk low",
        name: "Supreme Rammellzee",
        imageUrl: "assets/images/sbdunklow.png",
        price: 320,
        count: 1,
        size: 42,
        purchasePrice: 250,
        inCollection: true,
        inFavorites: false));

    filteredSneakers = sneakers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                // Heading
                '"Search"',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'future',
                ),
              ),
              const SizedBox(height: 20),
              Theme(
                data: ThemeData(
                    primaryColor: Theme.of(context).colorScheme.secondary),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),

                  // Search field
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: "Search",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ),

              // list of trending sneakers or filtered list
              Expanded(
                child: filteredSneakers.isEmpty
                    ? const Column(children: <Widget>[
                        SizedBox(height: 20),
                        Text(
                          "No sneakers found.",
                          style: TextStyle(fontSize: 18),
                        ),
                      ])
                    : ListView.builder(
                        itemCount: filteredSneakers.length,
                        itemBuilder: (context, index) {
                          return ProductCard(filteredSneakers[index],
                              onTapFunction: () => navigateToBuyingScreen(
                                  context, sneakers[index]));
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
