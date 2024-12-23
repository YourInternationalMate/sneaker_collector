import 'package:flutter/material.dart';

class ShoeSizeDropdown extends StatefulWidget {
  final Function(String) onSizeSelected;
  final String? initialSize;

  const ShoeSizeDropdown({
    Key? key, 
    required this.onSizeSelected,
    this.initialSize,
  }) : super(key: key);

  @override
  _ShoeSizeDropdownState createState() => _ShoeSizeDropdownState();
}

class _ShoeSizeDropdownState extends State<ShoeSizeDropdown> {
  String? _selectedSize;
  
  @override
  void initState() {
    super.initState();
    _initializeSize();
  }

  void _initializeSize() {
    if (widget.initialSize != null) {
      try {
        double? sizeValue = double.tryParse(widget.initialSize!);
        if (sizeValue != null) {
          _selectedSize = sizeValue.toStringAsFixed(sizeValue.truncateToDouble() == sizeValue ? 0 : 1);
        }
      } catch (e) {
        debugPrint('Error parsing initial size: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200, 
      child: DropdownButtonFormField<String>(
        value: _selectedSize,
        hint: const Text('Select Size'),
        isExpanded: true,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        menuMaxHeight: 150,
        items: <String>[
          '6', '6.5', '7', '7.5', '8', '8.5', '9', '9.5', '10', 
          '10.5', '11', '11.5', '12', '12.5', '13', '13.5', '14',
          '14.5', '15', '16', '17', '18'
        ].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'future',
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedSize = newValue;
          });
          if (newValue != null) {
            widget.onSizeSelected(newValue);
          }
        },
      ),
    );
  }
}