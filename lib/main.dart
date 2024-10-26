import 'package:flutter/material.dart';
import 'package:hedieaty/home_page.dart';
import 'package:hedieaty/theme_data.dart';
import 'package:hedieaty/profile_page.dart';
import 'package:hedieaty/eventList_page.dart';
import 'package:hedieaty/giftList_page.dart';
import 'package:hedieaty/giftDetails_page.dart';

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
    return MaterialApp(
      title: "Hedieaty",
      theme: ThemeClass.lightTheme,
      initialRoute: '/Home',
      routes: {
        "/Home":(context)=> HomePage(),
        '/Profile':(context)=> MyProfile(),
        '/EventList':(context)=>EventListPage(),
        '/GiftList':(context)=>GiftListPage(),
        '/GiftDetailsList':(context)=>GiftDetailsPage()
      },
      home: Scaffold(
        appBar: AppBar(
          title: Text("Hedieaty"),
        ),
        ));

  }
}
