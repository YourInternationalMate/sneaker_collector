import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sneaker_collector/models/sneaker.dart';
import 'package:sneaker_collector/services/api_service.dart';
import 'package:sneaker_collector/components/product_card.dart';
import 'package:sneaker_collector/pages/buying_screen.dart';

class Search extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<Search> {
  List<Sneaker> sneakers = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  String lastQuery = '';
  int currentPage = 1;
  int totalPages = 1;
  String? error;
  TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Debouncer für die Suche
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = searchController.text;
      if (query != lastQuery) {
        lastQuery = query;
        _performSearch(query);
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreItems();
    }
  }

  Future<void> _loadMoreItems() async {
    if (isLoadingMore || currentPage >= totalPages || lastQuery.isEmpty) return;

    setState(() {
      isLoadingMore = true;
      error = null;
    });

    try {
      final response = await ApiService.searchSneakers(
        lastQuery,
        page: currentPage + 1,
      );
      
      if (mounted) {
        setState(() {
          sneakers.addAll(response.items);
          currentPage = response.page;
          totalPages = response.pages;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingMore = false;
          error = e is ApiException ? e.message : 'Failed to load more results';
        });
        _showErrorSnackbar(e);
      }
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        sneakers = [];
        error = null;
        currentPage = 1;
        totalPages = 1;
      });
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await ApiService.searchSneakers(query, page: 1);
      if (mounted) {
        setState(() {
          sneakers = response.items;
          currentPage = response.page;
          totalPages = response.pages;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          sneakers = [];
          error = e is ApiException ? e.message : 'Search failed';
          isLoading = false;
        });
        _showErrorSnackbar(e);
      }
    }
  }

  void _showErrorSnackbar(dynamic error) {
    String message = 'An error occurred';
    if (error is ApiException) {
      message = error.message;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    setState(() {
                      sneakers = [];
                      lastQuery = '';
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _performSearch(lastQuery),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (sneakers.isEmpty) {
      return Center(
        child: Text(
          searchController.text.isEmpty
              ? "Search for sneakers"
              : "No sneakers found.",
          style: const TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: sneakers.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == sneakers.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return ProductCard(
          sneakers[index],
          onTapFunction: () => navigateToBuyingScreen(
            context,
            sneakers[index],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const Text(
              '"Search"',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontFamily: 'future',
              ),
            ),
            const SizedBox(height: 20),
            
            _buildSearchBar(),
            const SizedBox(height: 20),
            
            Expanded(
              child: _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }
}