import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sneaker_collector/components/retry_button.dart';
import 'package:sneaker_collector/components/size_selection_dialog.dart';
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
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialSneakers();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialSneakers() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Lade nur die ersten 20 Sneaker, sortiert nach Neuheit
      final response = await ApiService.searchSneakers(
        '',
        page: 1,
        limit: 20,
        sort: 'newest'  // Diese Option müsste im Backend unterstützt werden
      );
      
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
          isLoading = false;
          error = e is ApiException ? e.message : 'Failed to load sneakers';
        });
        _showErrorSnackbar(error ?? 'Unknown error');
      }
    }
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
    // Cancel any previous search
    _debounce?.cancel();

    if (query.isEmpty) {
      _loadInitialSneakers();
      return;
    }

    // Debounce the search
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;

      setState(() {
        isLoading = true;
        error = null;
        lastQuery = query;
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
            isLoading = false;
            error = e is ApiException ? e.message : 'An error occurred. Please try again.';
            sneakers.clear();
          });
          _showErrorSnackbar(error ?? 'Unknown error');
        }
      }
    });
  }

  Future<void> _toggleCollection(Sneaker sneaker) async {
    if (!sneaker.inCollection) {
      final selectedSize = await showSizeSelectionDialog(context);
      if (selectedSize == null) {
        return;
      }
      sneaker.setSize(selectedSize);
    }

    try {
      final success = await ApiService.updateCollection(sneaker);
      if (mounted && success) {
        setState(() {
          sneaker.setInCollection(!sneaker.inCollection);
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(e);
      }
    }
  }

  Future<void> _toggleFavorite(Sneaker sneaker) async {
    try {
      final success = await ApiService.toggleFavorite(sneaker);
      if (mounted && success) {
        setState(() {
          sneaker.setInFavorites(!sneaker.inFavorites);
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(e);
      }
    }
  }

  void _showErrorSnackbar(dynamic error) {
    String message = 'An error occurred';
    if (error is ApiException) {
      message = error.message;
    } else if (error is String) {
      message = error;
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

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(error ?? 'An error occurred'),
          const SizedBox(height: 20),
          RetryButton(
            onRetry: () {
              setState(() {
                error = null;
                isLoading = true;
              });
              _performSearch(searchController.text);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        controller: searchController,
        onChanged: _performSearch,
        decoration: InputDecoration(
          labelText: "Search",
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.8),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
              width: 2,
            ),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.secondary,
          ),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    searchController.clear();
                    _performSearch('');
                  },
                )
              : null,
          floatingLabelStyle: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
          ),
          fillColor: Theme.of(context).colorScheme.surface,
          filled: true,
        ),
        cursorColor: Theme.of(context).colorScheme.secondary,
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
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => searchController.text.isEmpty 
                  ? _loadInitialSneakers()
                  : _performSearch(searchController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    if (sneakers.isEmpty && searchController.text.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No sneakers found.',
              style: TextStyle(fontSize: 18),
            ),
          ],
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
          onCollectionToggle: () => _toggleCollection(sneakers[index]),
          onFavoriteToggle: () => _toggleFavorite(sneakers[index]),
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                '"Search"',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'future',
                ),
              ),
            ),
            
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