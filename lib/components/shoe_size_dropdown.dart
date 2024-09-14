import 'package:flutter/material.dart';

class ShoeSizeDropdown extends StatefulWidget {
  final Function(String) onSizeSelected;

  const ShoeSizeDropdown({Key? key, required this.onSizeSelected}) : super(key: key);

  @override
  _ShoeSizeDropdownState createState() => _ShoeSizeDropdownState();
}

class _ShoeSizeDropdownState extends State<ShoeSizeDropdown> {
  String? _selectedSize;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedSize,
      hint: Text('Select Size'),
      items: <String>['6', '6.5', '7', '7.5', '8', '8.5', '9', '9.5', '10', '10.5', '11', '11.5', '12', '12.5', '13', '13.5', '14', '14.5', '15', '16', '17', '18'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedSize = newValue;
        });
        widget.onSizeSelected(newValue!);
      },
    );
  }
}