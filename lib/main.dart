import 'package:flutter/material.dart';
import 'package:hedieaty/home_page.dart';
import 'package:hedieaty/login_page.dart';
import 'package:hedieaty/theme_data.dart';
import 'package:hedieaty/profile_page.dart';
import 'package:hedieaty/eventList_page.dart';
import 'package:hedieaty/giftList_page.dart';
import 'package:hedieaty/giftDetails_page.dart';
import 'package:hedieaty/splash_screen.dart';
import 'package:hedieaty/signup_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
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
      initialRoute: '/Splash',
      routes: {
        "/Splash":(context)=> SplashScreen(),
        "/home":(context)=>HomePage(),
        '/Profile':(context)=> MyProfile(),
        '/EventList':(context)=>EventListPage(),
        '/GiftList':(context)=>GiftListPage(),
        '/GiftDetailsList':(context)=>GiftDetailsPage(),
        '/signup':(context)=>SignUpPage(),
        '/login':(context)=>LoginPage(),
      },
      home: Scaffold(
        appBar: AppBar(
          title: Text("Hedieaty"),
        ),
        ));

  }
}
