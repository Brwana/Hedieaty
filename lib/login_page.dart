import 'dart:convert'; // For utf8 encoding
import 'package:crypto/crypto.dart'; // For hashing
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hedieaty/database.dart';
import 'package:hedieaty/DataSyncService.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  final DatabaseClass dbHelper = DatabaseClass();
  final DataSyncService syncService=DataSyncService();

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _isOnline() async {
      var connectivityResult = await Connectivity().checkConnectivity();

      // Return true if the device is connected to WiFi, Mobile, or Ethernet
      return connectivityResult == ConnectivityResult.wifi ||
          connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.ethernet;

  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      bool online = await _isOnline();
      print("am i online $online");


      if (online) {
        await _loginOnline();
      } else {
        await _loginOffline();
      }
    }
  }

  Future<void> _loginOnline() async {
    try {
      // Authenticate with Firebase
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        // Fetch user data from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          print('User Data: $userData');

          syncService.syncFirestoreToSQLite(user.uid);
          print("sync completed successfully");
          await syncService.queryAndPrintTable('Users');
          await syncService.queryAndPrintTable('Friends');
          await syncService.queryAndPrintTable('Events');
          await syncService.queryAndPrintTable('Gifts');
          // Sync data to local SQLite database

          // Navigate to the home screen
          Navigator.pushNamed(context, '/home');
        }
      }
    } catch (e) {
      print('Online login failed: $e');
      _showError(e.toString());
    }
  }



  Future<void> _loginOffline() async {
    print("ana offline");
    // Hash the entered password
    String hashedPassword = sha256.convert(utf8.encode(password)).toString();

    // Check the local SQLite database for the email and hashed password
    var result = await dbHelper.readData('''
      SELECT * FROM Users WHERE Email = '$email' AND Password = '$hashedPassword'
    ''');

    if (result.isNotEmpty) {
      print("logged in offline successfully");
      // Store user data globally or locally as needed
      // Example: FirebaseAuth-like simulation for offline access
      await _simulateAuthStateForOffline(result[0]);

      // Navigate to the home screen
      Navigator.pushNamed(context, '/home');
    } else {
      // Invalid credentials
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid email or password for offline login.')),
      );
    }
  }

  Future<void> _simulateAuthStateForOffline(Map<String, dynamic> userData) async {
    // Simulate a "current user" state for offline access
    // For example, you can use SharedPreferences or a similar mechanism to store user info
    print("Simulating auth state for offline user: ${userData['Email']}");
  }


  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log In'),
        toolbarHeight: 70.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blueAccent.shade100,
                    child: ClipOval(
                      child: Image.asset(
                        'asset/signup.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                    fontFamily: "Caveat",
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    prefixIcon: Icon(Icons.email, color: Colors.pink),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    email = value!;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    prefixIcon: Icon(Icons.lock, color: Colors.pink),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    password = value!;
                  },
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'Log In',
                    style: TextStyle(fontSize: 18, color: Colors.pink),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: TextStyle(fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.pink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
