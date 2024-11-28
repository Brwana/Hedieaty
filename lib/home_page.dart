import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late User? currentUser;
  late CollectionReference friendsRef;
  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> filteredFriends = [];

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    friendsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('friends');
    _fetchFriends();
  }
  void _handleMenuSelection(String value) {
    switch (value) {
      case 'Show Event List':
        Navigator.pushNamed(context, '/EventList');
        break;
      case 'Show Gift List':
        Navigator.pushNamed(context, '/GiftList');
        break;
      case 'Show Gift Details List':
        Navigator.pushNamed(context, '/GiftDetailsList');
        break;
      case 'Create Your Own Event/List':
        Navigator.pushNamed(context, '/createEvent');

        break;
    }
  }
  Future<void> _deleteFriend(String phoneNumber) async {
    try {
      // Find the friend's document ID in the "friends" subcollection
      final friendSnapshot = await friendsRef
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      if (friendSnapshot.docs.isNotEmpty) {
        // Get the document ID of the friend to delete
        final friendDocId = friendSnapshot.docs.first.id;

        // Remove the friend from Firestore
        await friendsRef.doc(friendDocId).delete();

        // Update the UI
        setState(() {
          friends.removeWhere((friend) => friend['phoneNumber'] == phoneNumber);
          filteredFriends.removeWhere((friend) => friend['phoneNumber'] == phoneNumber);
        });

        print('Friend deleted successfully!');
      }
    } catch (e) {
      print('Error deleting friend: $e');
      _showErrorDialog('Failed to delete friend. Please try again.');
    }
  }


  Future<void> _fetchFriends() async {
    friendsRef.snapshots().listen((snapshot) {
      setState(() {
        friends = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        filteredFriends = friends; // Initially, filtered = all friends
      });
    });
    Expanded(
      child: friends.isEmpty
          ? Center(
        child: Text(
          'No friends added yet.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: filteredFriends.length,
        itemBuilder: (context, index) {
          final friend = filteredFriends[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(friend['profileImage'] ??
                  'asset/default_profile.jpg'), // Fallback image
            ),
            title: Text(
              friend['fullName'] ?? 'Unknown',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB03565),
              ),
            ),
            subtitle: Text(
              friend['eventCount'] != null && friend['eventCount'] > 0
                  ? "Upcoming Events: ${friend['eventCount']}"
                  : "No Upcoming Events",
              style: TextStyle(color: Color(0xFFB03565)),
            ),
          );
        },
      ),
    );

  }

  void _filterFriends(String query) {
    setState(() {
      filteredFriends = friends
          .where((friend) =>
          friend['fullName']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
    friendsRef.snapshots().listen((snapshot) {
      setState(() {
        friends = snapshot.docs.map((doc) {
          print(doc.data()); // Debugging: Print the fetched friend data
          return doc.data() as Map<String, dynamic>;
        }).toList();
        filteredFriends = friends; // Initially, filtered = all friends
      });
    });

  }

  void _addFriendManually() {
    String phoneNumber = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Friend'),
          content: TextField(
            decoration: InputDecoration(labelText: 'Enter Phone Number'),
            onChanged: (value) {
              phoneNumber = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (phoneNumber.isNotEmpty) {
                  // Search for the user by phone number
                  try {
                    QuerySnapshot snapshot = await FirebaseFirestore.instance
                        .collection('users')
                        .where('phoneNumber', isEqualTo: phoneNumber)
                        .get();

                    if (snapshot.docs.isNotEmpty) {
                      // Get the user's data
                      final friendData = snapshot.docs.first.data() as Map<String, dynamic>;
                      final friendId = snapshot.docs.first.id;

                      // Add the friend to the current user's friends collection
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser!.uid)
                          .collection('friends')
                          .doc(friendId)
                          .set({
                        'fullName': friendData['fullName'],
                        'phoneNumber': friendData['phoneNumber'],
                        'profileImage': friendData['profileImage'],
                        'eventCount': 0, // Default value
                      });

                      // Update the UI
                      Navigator.pop(context);
                      print('Friend added successfully!');
                    } else {
                      // No user found with this phone number
                      Navigator.pop(context);
                      _showErrorDialog('No user found with this phone number.');
                    }
                  } catch (e) {
                    Navigator.pop(context);
                    _showErrorDialog('Failed to add friend. Please try again.');
                    print('Error: $e');
                  }
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

// Helper function to display error dialogs
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hedieaty"),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/Profile');
            },
          ),


        PopupMenuButton<String>(
          onSelected: _handleMenuSelection,
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              value: 'Show Event List',
              child: Text('Show Event List'),
            ),
            PopupMenuItem(
              value: 'Show Gift List',
              child: Text('Show Gift List'),
            ),
            PopupMenuItem(
              value: 'Show Gift Details List',
              child: Text('Show Gift Details List'),
            ),
            PopupMenuItem(
              value: 'Create Your Own Event/List',
              child: Text('Create Your Own Event/List'),
            ),
          ],
          icon: Icon(Icons.more_vert, color: Colors.white),
        ),
        ],
      ),

        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 25.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search friends...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: _filterFriends,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.person_add, color: Colors.pink),
                    onPressed: _addFriendManually,
                  ),
                ],
              ),
            ),
            Expanded(
              child: friends.isEmpty
                  ? Center(
                child: Text(
                  'No friends added yet.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: filteredFriends.length,
                itemBuilder: (context, index) {
                  final friend = filteredFriends[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: (friend['profileImage'] != null && friend['profileImage'].isNotEmpty)
                          ? AssetImage(friend['profileImage']) // Use the friend's profile image from Firestore
                          : AssetImage('asset/default_profile.jpg') as ImageProvider, // Fallback to default image
                    ),
                    title: Text(
                      friend['fullName'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB03565),
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(Icons.event, color: Color(0xFFB03565)),
                        SizedBox(width: 5),
                        Text(
                          friend['eventCount'] != null && friend['eventCount'] > 0
                              ? "Upcoming Events: ${friend['eventCount']}"
                              : "No Upcoming Events",
                          style: TextStyle(color: Color(0xFFB03565)),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        // Call the delete friend method
                        await _deleteFriend(friend['phoneNumber']);
                      },
                    ),
                    onTap: () {
                      // Navigate to friend's details (e.g., gift list)
                      Navigator.pushNamed(context, '/FriendDetails', arguments: friend['uid']);
                    },
                  );

                },
              ),
            ),
          ],
        ),

    );
  }
}
