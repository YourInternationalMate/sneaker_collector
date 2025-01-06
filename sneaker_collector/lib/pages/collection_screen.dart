// lib/pages/collection_screen.dart

import 'package:flutter/material.dart';
import 'package:sneaker_collector/components/retry_button.dart';
import 'package:sneaker_collector/components/size_selection_dialog.dart';
import 'package:sneaker_collector/models/sneaker.dart';
import 'package:sneaker_collector/components/product_card.dart';
import 'package:sneaker_collector/pages/detail_screen.dart';
import 'package:sneaker_collector/services/api_service.dart';

class Collection extends StatefulWidget {
  const Collection({super.key});

  @override
  _CollectionState createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  List<Sneaker> sneakers = [];
  bool isLoading = true;
  String? error;
  int currentPage = 1;
  int totalPages = 1;
  bool isLoadingMore = false;
  double totalValue = 0.0;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCollection();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreItems();
    }
  }

  Future<void> _loadMoreItems() async {
    if (isLoadingMore || currentPage >= totalPages) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final response = await ApiService.getCollection(page: currentPage + 1);
      if (mounted) {
        setState(() {
          sneakers.addAll(response.items);
          currentPage = response.page;
          totalPages = response.pages;
          isLoadingMore = false;
          _updateTotalValue();
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

  Future<void> _loadCollection() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await ApiService.getCollection(page: 1);
      if (mounted) {
        print('DEBUG: Loaded collection items:');
        for (var sneaker in response.items) {
          print('DEBUG: Sneaker - ID: ${sneaker.id}, Model: ${sneaker.model}, Brand: ${sneaker.brand}');
        }
        setState(() {
          sneakers = response.items;
          currentPage = response.page;
          totalPages = response.pages;
          isLoading = false;
          _updateTotalValue();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
    }
  }

  void _updateTotalValue() {
    totalValue = sneakers.fold(0.0, (total, sneaker) {
      double itemTotal = (sneaker.price * sneaker.count);
      return total + itemTotal;
    });
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

  Future<void> _removeFromCollection(Sneaker sneaker, int index) async {
    final sneakersCopy = List<Sneaker>.from(sneakers);
    setState(() {
      sneakers.removeAt(index);
      _updateTotalValue();
    });

    try {
      await ApiService.removeFromCollection(sneaker);
    } catch (e) {
      if (mounted) {
        setState(() {
          sneakers = sneakersCopy;
          _updateTotalValue();
        });
        _showErrorSnackbar(e);
      }
    }
  }

  Future<void> _removeFromCollectionWithConfirmation(Sneaker sneaker) async {
    print('DEBUG: Attempting to remove sneaker: ${sneaker.toString()}'); // Add this line
    print('DEBUG: Sneaker ID: ${sneaker.id}'); // Add this line

    if (sneaker.id == null) {
      _showErrorSnackbar('Invalid sneaker ID');
      return;
    }

    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove from Collection'),
          content: const Text(
              'Are you sure you want to remove this sneaker from your collection?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('CANCEL',
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
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

    if (shouldRemove == true) {
      try {
        print('DEBUG: Making API call to remove sneaker ID: ${sneaker.id}');
        await ApiService.removeFromCollection(sneaker);
        if (mounted) {
          setState(() {
            print('DEBUG: Removing sneaker from state, ID: ${sneaker.id}');
            sneakers.removeWhere((s) => s.id == sneaker.id);
            _updateTotalValue();
          });
        }
      } catch (e) {
        if (mounted) {
          print('DEBUG: Error removing sneaker: $e');
          _showErrorSnackbar(e);
        }
      }
    }
  }

  void navigateToDetailScreen(BuildContext context, Sneaker sneaker) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(sneaker: sneaker),
      ),
    );

    if (result == true && mounted) {
      _loadCollection();
    }
  }

  Widget _buildErrorView() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(error ?? 'An error occurred'),
        const SizedBox(height: 20),
        RetryButton(
          onRetry: _loadCollection,
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
            Icons.star_border,
            size: 64,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your collection is empty.\nAdd sneakers from the search page!',
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
      _showErrorSnackbar(e);
    }
  }

  Widget _buildCollectionList() {
    return RefreshIndicator(
      onRefresh: _loadCollection,
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

          return ProductCard(
            sneakers[index],
            onTapFunction: () => navigateToDetailScreen(
              context,
              sneakers[index],
            ),
            onCollectionToggle: () =>
                _removeFromCollectionWithConfirmation(sneakers[index]),
            onFavoriteToggle: () => _toggleFavorite(sneakers[index]),
          );
        },
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('Total Pairs', sneakers.length.toString()),
          _buildStat(
            'Total Value',
            '\$${totalValue.toStringAsFixed(2)}',
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
                '"Collection"',
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
                          : _buildCollectionList(),
            ),
            if (!isLoading && error == null && sneakers.isNotEmpty)
              _buildStats(),
          ],
        ),
      ),
    );
  }
}
