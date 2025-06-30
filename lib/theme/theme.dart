import 'package:flutter/material.dart';

/// ThemeData using Material 3 and shared colors
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  primarySwatch: Colors.indigo,
  checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      checkColor: MaterialStateProperty.all(Colors.black),
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.lightBlueAccent; // Color when selected
        }
        if (states.contains(MaterialState.disabled)) {
          return Colors.grey.shade800; // Color when disabled
        }
        return Colors.transparent; // Color when unselected
      }),
      side: BorderSide(color: Colors.grey.shade600, width: 2),
    ),

 
  scaffoldBackgroundColor: Colors.transparent,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFF1B263B), // Use dark blue seed
    brightness: Brightness.dark,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.brown,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Color.fromARGB(255, 14, 0, 2),
    ),
  ),
  drawerTheme: DrawerThemeData(
    backgroundColor: const Color.fromARGB(255, 86, 66, 175),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color.fromARGB(255, 176, 221, 187),
      foregroundColor: const Color.fromARGB(255, 86, 66, 175),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ), 
  listTileTheme: const ListTileThemeData(
    textColor: Color.fromARGB(255, 123, 47, 211),
    iconColor: Colors.white,
  ),
);

