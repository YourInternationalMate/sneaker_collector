// lib/pages/detail_screen.dart

import 'package:flutter/material.dart';
import 'package:sneaker_collector/components/retry_button.dart';
import 'package:sneaker_collector/models/sneaker.dart';
import 'package:sneaker_collector/components/shoe_size_dropdown.dart';
import 'package:sneaker_collector/services/api_service.dart';

class DetailScreen extends StatefulWidget {
  final Sneaker sneaker;

  const DetailScreen({Key? key, required this.sneaker}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late TextEditingController _purchasePriceController;
  late TextEditingController _amountController;
  bool isSaving = false;
  String? error;
  String _selectedSize = '';
  bool hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _purchasePriceController = TextEditingController(
      text: widget.sneaker.purchasePrice.toString()
    );
    _amountController = TextEditingController(
      text: widget.sneaker.count.toString()
    );
    _selectedSize = widget.sneaker.size.toString();

    // Überwache Änderungen
    _purchasePriceController.addListener(_onFieldChanged);
    _amountController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _purchasePriceController.removeListener(_onFieldChanged);
    _amountController.removeListener(_onFieldChanged);
    _purchasePriceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    final newPurchasePrice = double.tryParse(_purchasePriceController.text) ?? 0.0;
    final newAmount = int.tryParse(_amountController.text) ?? 0;
    
    setState(() {
      hasUnsavedChanges = newPurchasePrice != widget.sneaker.purchasePrice ||
                         newAmount != widget.sneaker.count ||
                         (_selectedSize != widget.sneaker.size.toString() &&
                          _selectedSize.isNotEmpty);
    });
  }

  Future<bool> _onWillPop() async {
    if (!hasUnsavedChanges) return true;

    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes. Do you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'DISCARD',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _toggleFavorite() async {
    setState(() => isSaving = true);

    try {
      final success = await ApiService.toggleFavorite(widget.sneaker);
      if (mounted) {
        setState(() {
          widget.sneaker.setInFavorites(!widget.sneaker.inFavorites);
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(e);
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  void _showErrorSnackbar(dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error is ApiException ? error.message : 'An error occurred'),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  bool _validateInputs() {
    if (_amountController.text.isEmpty ||
        int.tryParse(_amountController.text) == null ||
        int.parse(_amountController.text) <= 0) {
      _showErrorSnackbar('Please enter a valid amount');
      return false;
    }

    if (_purchasePriceController.text.isNotEmpty) {
      final price = double.tryParse(_purchasePriceController.text);
      if (price == null || price < 0) {
        _showErrorSnackbar('Please enter a valid purchase price');
        return false;
      }
    }

    if (_selectedSize.isEmpty) {
      _showErrorSnackbar('Please select a size');
      return false;
    }

    return true;
  }

  Future<void> saveChanges() async {
    if (!_validateInputs()) return;

    setState(() {
      isSaving = true;
      error = null;
    });

    try {
      widget.sneaker
        ..setPurchasePrice(double.parse(_purchasePriceController.text))
        ..setCount(int.parse(_amountController.text))
        ..setSize(double.parse(_selectedSize));

      await ApiService.updateCollection(widget.sneaker);
      
      if (mounted) {
        setState(() {
          hasUnsavedChanges = false;
        });
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(e);
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(error ?? 'Failed to update sneaker'),
          const SizedBox(height: 20),
          RetryButton(
            onRetry: saveChanges,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: "Future",
            fontSize: 24,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
            fontFamily: "Future",
            fontSize: 24,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.tertiary,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
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
          actions: [
            if (hasUnsavedChanges)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: isSaving ? null : saveChanges,
                ),
              ),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
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
                          width: 200,
                          color: Colors.grey[200],
                          child: const Icon(Icons.error),
                        );
                      },
                    ),
                  ),

                  // Sneaker Name and Price
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
                    '\$${widget.sneaker.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Future",
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 80),

                  // Current Details
                  _buildDetailRow(
                    'Purchase Price:',
                    '\$${_purchasePriceController.text}',
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow(
                    'Amount:',
                    _amountController.text,
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow(
                    'Size:',
                    _selectedSize,
                  ),
                  const SizedBox(height: 80),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: isSaving ? null : _toggleFavorite,
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                        ),
                        child: Icon(
                          widget.sneaker.inFavorites
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 40),
                      ElevatedButton(
                        onPressed: isSaving ? null : () => _showEditDialog(context),
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Align(
            alignment: Alignment.center,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 20),
                
                // Purchase Price
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Price: ",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _purchasePriceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: const Icon(Icons.attach_money),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Amount
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Amount: ",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Size
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Size: ",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      ShoeSizeDropdown(
                        initialSize: widget.sneaker.size.toString(),
                        onSizeSelected: (String size) {
                          setState(() {
                            _selectedSize = size;
                            hasUnsavedChanges = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Save Button
                ElevatedButton(
                  onPressed: isSaving ? null : () {
                    saveChanges();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 10,
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "SAVE",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Future",
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}