import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:sneaker_collector/components/navbar.dart';
import 'package:sneaker_collector/models/sneaker.dart';
import 'package:sneaker_collector/components/product_card.dart';
import 'package:sneaker_collector/pages/buying_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
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
  List<Sneaker> _sneakers = [];
  _sneakers.addAll(sneakers);
  if (searchController.text.isNotEmpty) {
    List<String> searchTerms = searchController.text.toLowerCase().split(' ');
    _sneakers.retainWhere((sneaker) {
      String sneakerName = sneaker.name.toLowerCase();
      String sneakerBrand = sneaker.brand.toLowerCase();
      String sneakerModel = sneaker.model.toLowerCase();
      return searchTerms.every((term) =>
        sneakerName.contains(term) || sneakerBrand.contains(term) || sneakerModel.contains(term));
    });
  }
  setState(() {
    filteredSneakers = _sneakers;
  });
}

  void addItemsTo() {
    
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 70),
            const Text(
              '"Search"',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontFamily: 'future',
              ),
            ),
            const SizedBox(height: 10),
            Theme(
              data: ThemeData(primaryColor: const Color(0xFF6F2DFF)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: "Search",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF6F2DFF),
                      ),
                    ),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            ),
            Expanded(
              child: filteredSneakers.isEmpty
                  ? const Text(
                      "No sneakers found.",
                      style: TextStyle(fontSize: 18),
                    )
                  : ListView.builder(
                      itemCount: filteredSneakers.length,
                      itemBuilder: (context, index) {
                        return ProductCard(filteredSneakers[index], onTapFunction: () => navigateToBuyingScreen(context, sneakers[index]));
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
          child: NavBar(0),
        ),
      ),
    );
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