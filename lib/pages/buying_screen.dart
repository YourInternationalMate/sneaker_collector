import 'package:flutter/material.dart';
import 'package:sneaker_collector/components/retry_button.dart';
import 'package:sneaker_collector/components/size_selection_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sneaker_collector/models/sneaker.dart';
import 'package:sneaker_collector/services/api_service.dart';
import 'package:sneaker_collector/components/shoe_size_dropdown.dart';

class BuyingScreen extends StatefulWidget {
  final Sneaker sneaker;

  const BuyingScreen({super.key, required this.sneaker});

  @override
  _BuyingScreenState createState() => _BuyingScreenState();
}

class _BuyingScreenState extends State<BuyingScreen> {
  bool isAddingToCollection = false;
  bool isAddingToFavorites = false;
  bool isSizeSelected = false;
  double? selectedSize;
  bool showSizeError = false;

  Future<void> _launchURL(String? url, String platform) async {
    if (url == null) {
      _showErrorSnackbar('No $platform link available for this sneaker');
      return;
    }

    final Uri uri = Uri.parse(url);
    try {
      final canLaunch = await canLaunchUrl(uri);
      if (!canLaunch) {
        throw Exception('Could not launch URL');
      }
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Could not open $platform');
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _toggleCollection() async {
    if (!widget.sneaker.inCollection) {
      final selectedSize = await showSizeSelectionDialog(context);
      if (selectedSize == null) {
        return;
      }
      widget.sneaker.setSize(selectedSize);
    }

    setState(() => isAddingToCollection = true);

    try {
      final success = await ApiService.updateCollection(widget.sneaker);

      if (mounted) {
        if (success) {
          setState(() {
            widget.sneaker.setInCollection(!widget.sneaker.inCollection);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(
            e is ApiException ? e.message : 'Failed to update collection');
      }
    } finally {
      if (mounted) {
        setState(() => isAddingToCollection = false);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() => isAddingToFavorites = true);

    try {
      final success = await ApiService.toggleFavorite(widget.sneaker);

      if (mounted) {
        if (success) {
          setState(() {
            widget.sneaker.setInFavorites(!widget.sneaker.inFavorites);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(
            e is ApiException ? e.message : 'Failed to update favorites');
      }
    } finally {
      if (mounted) {
        setState(() => isAddingToFavorites = false);
      }
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isLoading,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  icon,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 24,
                ),
        ),
      ],
    );
  }

  Widget _buildBuyButton(String platform, VoidCallback onPressed) {
    return SizedBox(
      width: 300,
      height: 70,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          platform,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
            fontFamily: "Future",
            fontSize: 24,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.tertiary,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "${widget.sneaker.brand} ${widget.sneaker.model}",
          style: TextStyle(
            color: Theme.of(context).colorScheme.tertiary,
            fontWeight: FontWeight.bold,
            fontFamily: "Future",
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
          child: Column(
            children: <Widget>[
              // Sneaker Image
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  widget.sneaker.imageUrl,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              ),

              // Sneaker Details
              const SizedBox(height: 20),
              Text(
                widget.sneaker.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Future",
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                '\$${widget.sneaker.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Future",
                  fontSize: 24,
                ),
              ),

              const SizedBox(height: 40),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton(
                    icon: widget.sneaker.inCollection
                        ? Icons.star
                        : Icons.star_border,
                    onPressed: _toggleCollection,
                    isLoading: isAddingToCollection,
                  ),
                  const SizedBox(width: 20),
                  _buildActionButton(
                    icon: widget.sneaker.inFavorites
                        ? Icons.favorite
                        : Icons.favorite_border,
                    onPressed: _toggleFavorite,
                    isLoading: isAddingToFavorites,
                  ),
                ],
              ),

              const SizedBox(height: 80),

              // Buy Buttons
              _buildBuyButton(
                'StockX',
                () => _launchURL(widget.sneaker.stockXUrl, 'StockX'),
              ),
              const SizedBox(height: 20),
              _buildBuyButton(
                'GOAT',
                () => _launchURL(widget.sneaker.goatUrl, 'GOAT'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
