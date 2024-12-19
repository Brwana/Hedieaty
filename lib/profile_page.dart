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
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  bool notificationsEnabled = false; // Default to false

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
          setState(() {
            userData = userDoc.data() as Map<String, dynamic>;
            events = List<Map<String, dynamic>>.from(userData!['events'] ?? []);

            // Populate the controllers with current user data
            nameController.text = userData!['fullName'] ?? '';
            phoneController.text = userData!['phoneNumber'] ?? '';
            notificationsEnabled = userData!['notificationsEnabled'] ?? false;
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }


  // Update user data in Firestore
  Future<void> _updateFullName(String newName) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
        'fullName': newName,
      });
      print("Profile updated successfully.");
    } catch (e) {
      print("Error updating Firestore: $e");
    }
  }
  // Update user data in Firestore
  Future<void> _updatePhoneNumber(String newNumber) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
        'phoneNumber': newNumber,
      });
      print("Profile updated successfully.");
    } catch (e) {
      print("Error updating Firestore: $e");
    }
  }


  // Show edit dialog for name and phone number
  void _editFullName() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Profile"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String newName = nameController.text;
                if (newName.isNotEmpty ) {
                  await _updateFullName(newName);
                  Navigator.pop(context);
                  _fetchUserData(); // Refresh the user data after update
                } else {
                  // Show an error message if fields are empty
                  _showErrorDialog('Please fill out both fields.');
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
  void _editPhoneNumber() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Profile"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String newPhone = phoneController.text;
                if (newPhone.isNotEmpty) {
                  await _updatePhoneNumber(newPhone);
                  Navigator.pop(context);
                  _fetchUserData(); // Refresh the user data after update
                } else {
                  // Show an error message if fields are empty
                  _showErrorDialog('Please fill out both fields.');
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
  Future<void> _signout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      print('Error during logout: $e');
      _showErrorDialog('Failed to log out. Please try again.');
    }
  }
  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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
  void _handleMenuSelection(String value) {
    switch (value) {
      case 'Show Event List':
        Navigator.pushNamed(context, '/EventList');
        break;
      case 'Show My Pledged Gifts':
        Navigator.pushNamed(context, '/pledged_gifts');
        break;
      case 'Create Your Own Event/List':
        Navigator.pushNamed(context, '/createEvent');
        break;
      case'Log out':
        _signout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Page"),
        actions: [
          Theme(
            data: Theme.of(context).copyWith(
              popupMenuTheme: PopupMenuThemeData(
                color: Colors.white, // Background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25), // Rounded border
                ),
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.pink, // Default text color
                ),
              ),
            ),
            child: PopupMenuButton<String>(
              onSelected: _handleMenuSelection,
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'Show Event List',
                  child: Text('Show Event List'),
                ),
                PopupMenuItem(
                  value: 'Show My Pledged Gifts',
                  child: Text('My pledged Gifts'),
                ),
                PopupMenuItem(
                  value: 'Create Your Own Event/List',
                  child: Text('Create Your Own Event/List'),
                ),
                PopupMenuItem(
                  value: 'Log out',
                  child: Text('Log out', style: TextStyle(color: Colors.pink)),
                ),
              ],
              icon: Icon(Icons.more_vert, color: Colors.white),
            ),
          )
        ],
      ),
      body: currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .snapshots(), // Listen to real-time updates from Firestore
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
              // Profile Image
              Center(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: (userData!['profileImage'] != null && userData!['profileImage'].isNotEmpty)
                            ? AssetImage(userData!['profileImage'])
                            : AssetImage('asset/profile.jpg'),
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
              ),
              // Profile Fields
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Full Name Field
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Full Name',
                              ),
                              readOnly: true, // Prevent editing
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: _editFullName,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Phone Number Field
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: phoneController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Phone Number',
                              ),
                              keyboardType: TextInputType.phone,
                              readOnly: true, // Prevent editing
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: _editPhoneNumber,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height:16),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
