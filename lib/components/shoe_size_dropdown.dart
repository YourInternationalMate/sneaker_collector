import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('US Schuhgrößen Dropdown'),
        ),
        body: ShoeSizeDropdown(
          initialSize: '10', // Beispiel für die Übergabe einer Schuhgröße
        ),
      ),
    );
  }
}

class ShoeSizeDropdown extends StatefulWidget {
  final String initialSize;

  ShoeSizeDropdown({required this.initialSize});

  @override
  _ShoeSizeDropdownState createState() => _ShoeSizeDropdownState();
}

class _ShoeSizeDropdownState extends State<ShoeSizeDropdown> {
  // Liste der amerikanischen Schuhgrößen
  final List<String> usShoeSizes = [
    '4', '4.5', '5', '5.5', '6', '6.5', '7', '7.5', '8', '8.5', '9', '9.5',
    '10', '10.5', '11', '11.5', '12', '12.5', '13', '13.5', '14', '14.5',
    '15', '15.5', '16', '16.5', '17', '17.5', '18'
  ];

  String? selectedSize;

  @override
  void initState() {
    super.initState();
    // Überprüfen, ob initialSize in der Liste der Schuhgrößen enthalten ist
    if (usShoeSizes.contains(widget.initialSize)) {
      selectedSize = widget.initialSize;
    } else {
      selectedSize = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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