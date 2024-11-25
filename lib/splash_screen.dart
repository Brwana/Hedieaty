import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hedieaty/signup_page.dart';// Update with the actual login page

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the login page after 2 seconds
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => SignUpPage()), // Update as needed
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'asset/present.jpg', // Path to your image file
              width: 150, // Adjust size as needed
              height: 150,
            ),
            SizedBox(height: 20), // Space between image and text
            Text(
              'Hedieaty',
              style: TextStyle(
                fontSize: 32, // Font size for the text
                fontWeight: FontWeight.bold, // Make the text bold
                color: Color(0xFF960944), // Set your desired text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
