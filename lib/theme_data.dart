import 'dart:ffi';

import 'package:flutter/material.dart';

class ThemeClass{
  static ThemeData lightTheme = ThemeData(
    appBarTheme: AppBarTheme(color: Colors.pink,titleTextStyle: TextStyle(fontSize: 45,fontFamily:"Lobster" ),)

  );
}
ThemeClass _themeClass=ThemeClass();