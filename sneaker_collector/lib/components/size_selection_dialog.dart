import 'package:flutter/material.dart';
import 'package:sneaker_collector/components/shoe_size_dropdown.dart';

Future<double?> showSizeSelectionDialog(BuildContext context) async {
  String? selectedSize;
  
  final result = await showDialog<double>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          '"Select Size"',
          style: TextStyle(
            fontFamily: 'future',
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SizedBox(
              width: double.minPositive,
              height: 100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShoeSizeDropdown(
                    onSizeSelected: (size) {
                      selectedSize = size;
                    },
                  ),
                ],
              ),
            );
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text('CANCEL',
            style: TextStyle(color: Theme.of(context).colorScheme.tertiary),),
          ),
          TextButton(
            onPressed: () {
              if (selectedSize != null) {
                Navigator.of(context).pop(double.parse(selectedSize!));
              }
            },
            child: Text('CONFIRM',
            style: TextStyle(color: Theme.of(context).colorScheme.tertiary),),
          ),
        ],
      );
    },
  );

  return result;
}