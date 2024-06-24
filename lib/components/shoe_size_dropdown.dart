import 'package:flutter/material.dart';

class ShoeSizeDropdown extends StatefulWidget {
  final String initialSize;

  ShoeSizeDropdown({required this.initialSize});

  @override
  _ShoeSizeDropdownState createState() => _ShoeSizeDropdownState();
}

class _ShoeSizeDropdownState extends State<ShoeSizeDropdown> {
  // list of all american men sizes
  final List<String> usShoeSizes = [
    '4',
    '4.5',
    '5',
    '5.5',
    '6',
    '6.5',
    '7',
    '7.5',
    '8',
    '8.5',
    '9',
    '9.5',
    '10',
    '10.5',
    '11',
    '11.5',
    '12',
    '12.5',
    '13',
    '13.5',
    '14',
    '14.5',
    '15',
    '15.5',
    '16',
    '16.5',
    '17',
    '17.5',
    '18'
  ];

  String? selectedSize;

  @override
  void initState() {
    super.initState();
    if (usShoeSizes.contains(widget.initialSize)) {
      selectedSize = widget.initialSize;
    } else {
      selectedSize = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      // DropDownMenu for size selection in editing menu
      child: DropdownButton<String>(
        value: selectedSize,
        hint: Text(widget.initialSize),
        onChanged: (String? newValue) {
          setState(() {
            selectedSize = newValue;
          });
        },
        items: usShoeSizes.map<DropdownMenuItem<String>>((String size) {
          return DropdownMenuItem<String>(
            value: size,
            child: Text(size),
          );
        }).toList(),
      ),
    );
  }
}
