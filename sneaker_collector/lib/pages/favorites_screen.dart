// lib/pages/favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:sneaker_collector/components/retry_button.dart';
import 'package:sneaker_collector/models/sneaker.dart';
import 'package:sneaker_collector/services/api_service.dart';
import 'package:sneaker_collector/components/product_card.dart';
import 'package:sneaker_collector/pages/buying_screen.dart';

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  List<Sneaker> sneakers = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  String? error;
  int currentPage = 1;
  int totalPages = 1;
  
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreItems();
    }
  }

  Future<void> _toggleCollection(Sneaker sneaker) async {
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
          _loadFavorites();
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(e);
      }
    }
  }

  Future<void> _loadMoreItems() async {
    if (isLoadingMore || currentPage >= totalPages) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final response = await ApiService.getFavorites(page: currentPage + 1);
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
        });
        _showErrorSnackbar(e);
      }
    }
  }

  Future<void> _loadFavorites() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await ApiService.getFavorites(page: 1);
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
          error = e is ApiException ? e.message : 'Failed to load favorites';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _removeFavorite(Sneaker sneaker, int index) async {
    final sneakersCopy = List<Sneaker>.from(sneakers);
    setState(() {
      sneakers.removeAt(index);
    });

    try {
      await ApiService.removeFromFavorites(sneaker);
    } catch (e) {
      if (mounted) {
        setState(() {
          sneakers = sneakersCopy;
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

  void navigateToBuyingScreen(BuildContext context, Sneaker sneaker) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuyingScreen(sneaker: sneaker),
      ),
    );

    if (result == true && mounted) {
      _loadFavorites();
    }
  }

Widget _buildErrorView() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(error ?? 'Failed to load favorites'),
        const SizedBox(height: 20),
        RetryButton(
          onRetry: _loadFavorites,
        ),
      ],
    ),
  );
}

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your favorites list is empty.\nAdd sneakers from the search page!',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'future',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList() {
    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
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

          return Dismissible(
            key: Key(sneakers[index].id.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              color: Colors.red,
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Remove from Favorites'),
                    content: const Text(
                      'Are you sure you want to remove this sneaker from your favorites?'
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('CANCEL'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text(
                          'REMOVE',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            onDismissed: (direction) => _removeFavorite(sneakers[index], index),
            child: ProductCard(
              sneakers[index],
              onTapFunction: () => navigateToBuyingScreen(
                context,
                sneakers[index],
              ),
              onCollectionToggle: () => _toggleCollection(sneakers[index]),
              onFavoriteToggle: () => _toggleFavorite(sneakers[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStats() {
    if (sneakers.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('Favorites', sneakers.length.toString()),
          _buildStat(
            'Average Price',
            '\$${_calculateAveragePrice().toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 14,
            fontFamily: 'future',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'future',
          ),
        ),
      ],
    );
  }

  double _calculateAveragePrice() {
    if (sneakers.isEmpty) return 0;
    final total = sneakers.fold(
      0.0,
      (sum, sneaker) => sum + sneaker.price,
    );
    return total / sneakers.length;
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
                '"Favorites"',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'future',
                ),
              ),
            ),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                      ? _buildErrorView()
                      : sneakers.isEmpty
                          ? _buildEmptyView()
                          : _buildFavoritesList(),
            ),

            _buildStats(),
          ],
        ),
      ),
    );
  }
}