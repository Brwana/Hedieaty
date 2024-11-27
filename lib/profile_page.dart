import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'selectphoto_page.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  User? currentUser;
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> events = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    try {
      currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .get();

        if (userDoc.exists) {
          print("Fetched user data: ${userDoc.data()}"); // Debug log
          setState(() {
            userData = userDoc.data() as Map<String, dynamic>;
            events = List<Map<String, dynamic>>.from(userData!['events'] ?? []);
          });
        } else {
          print("User document not found in Firestore.");
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }


  // Update the profile image URL in Firestore
  Future<void> _updateProfileImage(String imageUrl) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({'profileImage': imageUrl});

      print("Profile picture updated successfully.");
    } catch (e) {
      print("Error updating Firestore: $e");
    }
  }



  // Generate a random query parameter to bypass image caching
  String _getCacheBustingUrl(String url) {
    final randomQuery = Random().nextInt(100000).toString();
    return "$url?cb=$randomQuery";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Page"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Navigate to settings (add your settings page logic here)
            },
          ),
        ],
      ),
      body: currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .snapshots(),  // Listen to real-time updates from Firestore
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle errors
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Handle case where the user data does not exist
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User data not found."));
          }

          // Get the user data from Firestore
          final userDoc = snapshot.data!;
          userData = userDoc.data() as Map<String, dynamic>;
          events = List<Map<String, dynamic>>.from(userData!['events'] ?? []);

          return Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 50.0), // Increase top padding as needed
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: (userData!['profileImage'] != null && userData!['profileImage'].isNotEmpty)
                            ? AssetImage(userData!['profileImage']) // For images saved in Firestore
                            : const AssetImage('asset/default_profile.jpg')  // Fallback image
                      ),
                    ),

                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () async {
                          // Navigate to SelectPhotoPage and get selected image URL
                          final selectedImageUrl = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SelectPhotoPage(),
                            ),
                          );

                          if (selectedImageUrl != null) {
                            // Update Firestore with the selected image URL
                            await _updateProfileImage(selectedImageUrl);
                          }
                        },
                        child: const CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFFB03565),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
,
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      userData!['fullName'] ?? 'User Name',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // IconButton(
                    //   icon: const Icon(Icons.edit, color: Color(0xFFB03565)),
                    //   onPressed: () {
                    //     // Logic to edit profile name (can be added later)
                    //   },
                    // ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      child: ListTile(
                        title: Text(event['title'] ?? 'Event Title'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List<String>.from(event['gifts'] ?? [])
                              .map((gift) => Text("• $gift"))
                              .toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Logic to view pledged gifts (can be added later)
                },
                child: const Text("My Pledged Gifts",style: TextStyle(color: Colors.pink),),
              ),
            ],
          );
        },
      ),
    );
  }

}
