import 'package:flutter/material.dart';
import 'package:hedieaty/theme_data.dart';
void main() {
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
@override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Hedieaty",
        theme: ThemeClass.lightTheme,
        home: Scaffold(appBar:AppBar(title:Text("Hedieaty"),),),



    );

}
}
