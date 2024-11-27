import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectPhotoPage extends StatelessWidget {
  final List<String> assetImages = [
    "asset/pp_1.jpg",
    "asset/pp_2.jpg",
    "asset/pp_3.jpg",
    "asset/pp_4.jpg",
    "asset/pp_5.jpg",
    "asset/pp_6.jpg",

    // Add more image paths here
  ];

  // Function to update profile image URL in Firestore
  Future<void> _updateProfileImage(String imageUrl, User currentUser) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'profileImage': imageUrl});
      print("Profile picture updated in Firestore.");
    } catch (e) {
      print("Error updating Firestore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Select Photo")),
        body: const Center(child: Text("No user is logged in.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select a Photo"),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Adjust as needed
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: assetImages.length,
        itemBuilder: (context, index) {
          String imagePath = assetImages[index];

          return GestureDetector(
            onTap: () async {
              // When an image is tapped, update the profile image in Firestore
              await _updateProfileImage(imagePath, currentUser);
              // You can also navigate back after updating the image
              Navigator.pop(context);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}
