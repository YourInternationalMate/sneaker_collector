import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    surface: Color(0xffF1F1F1),
    primary: Colors.white,
    secondary: Color(0xFF6F2DFF),
    tertiary: Colors.black
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    surface: Colors.black,
    primary: Color(0xff232323),
    secondary: Color(0xFF6F2DFF),
    tertiary: Colors.white
  ),
);