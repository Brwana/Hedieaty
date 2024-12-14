import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  // The constructor now passes the `key` parameter to the superclass (StatefulWidget) constructor
  const HomePage({super.key});  // shorthand
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
  Future<void> _signout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      print('Error during logout: $e');
      _showErrorDialog('Failed to log out. Please try again.');
    }
  }


  void _handleMenuSelection(String value) {
    switch (value) {
      case 'Show Event List':
        Navigator.pushNamed(context, '/EventList');
        break;
      case 'Show Gift List':
        Navigator.pushNamed(context, '/GiftList');
        break;
      case 'Create Your Own Event/List':
        Navigator.pushNamed(context, '/createEvent');
        break;
      case'Log out':
        _signout();
    }
  }

  Future<void> _deleteFriend(String phoneNumber) async {
    try {
      final friendSnapshot = await friendsRef
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      if (friendSnapshot.docs.isNotEmpty) {
        final friendDocId = friendSnapshot.docs.first.id;
        await friendsRef.doc(friendDocId).delete();

        setState(() {
          friends.removeWhere((friend) => friend['phoneNumber'] == phoneNumber);
          filteredFriends.removeWhere(
                  (friend) => friend['phoneNumber'] == phoneNumber);
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
        friends = snapshot.docs.map((doc) {
          // Add the document ID (doc.id) to the friend data
          final friendData = doc.data() as Map<String, dynamic>;
          friendData['id'] = doc.id; // Add the auto-generated document ID
          return friendData;
        }).toList();

        // Initialize filtered friends
        filteredFriends = friends;
      });
    });
  }


  void _filterFriends(String query) {
    setState(() {
      filteredFriends = friends
          .where((friend) => friend['fullName']!
          .toLowerCase()
          .contains(query.toLowerCase()))
          .toList();
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
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.pink),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (phoneNumber.isNotEmpty) {
                  try {
                    QuerySnapshot snapshot = await FirebaseFirestore.instance
                        .collection('users')
                        .where('phoneNumber', isEqualTo: phoneNumber)
                        .get();

                    if (snapshot.docs.isNotEmpty) {
                      final friendData =
                      snapshot.docs.first.data() as Map<String, dynamic>;
                       final friendId = snapshot.docs.first.id;

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser!.uid)
                          .collection('friends')
                          .doc(friendId)
                          .set({
                        'id':friendId,
                        'fullName': friendData['fullName'],
                        'phoneNumber': friendData['phoneNumber'],
                        'profileImage': friendData['profileImage'],
                        'eventCount': 0,
                      });

                      Navigator.pop(context);
                      print('Friend added successfully!');
                    } else {
                      Navigator.pop(context);
                      _showErrorDialog(
                          'No user found with this phone number.');
                    }
                  } catch (e) {
                    Navigator.pop(context);
                    _showErrorDialog('Failed to add friend. Please try again.');
                    print('Error: $e');
                  }
                }
              },
              child: Text(
                'Add',
                style: TextStyle(color: Colors.pink),
              ),
            ),
          ],
        );
      },
    );
  }

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
        automaticallyImplyLeading: false,
        title: Text("Hedieaty"),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/Profile');
            },
          ),
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
                  value: 'Show Gift List',
                  child: Text('Show Gift List'),
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
                        borderRadius: BorderRadius.circular(25),
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
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/friend_event',
                      arguments: {
                        'friendId': friend['id'],
                        'friendName': friend['fullName'],
                      },
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: (friend['profileImage'] != null &&
                              friend['profileImage'].isNotEmpty)
                              ? AssetImage(friend['profileImage'])
                              : AssetImage('asset/pp_1.jpg')
                          as ImageProvider,
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                friend['fullName'] ?? 'Unknown',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB03565),
                                ),
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.event,
                                      color: Color(0xFFB03565), size: 18),
                                  SizedBox(width: 5),
                                  Text(
                                    friend['eventCount'] != null &&
                                        friend['eventCount'] > 0
                                        ? "Upcoming Events: ${friend['eventCount']}"
                                        : "No Upcoming Events",
                                    style:
                                    TextStyle(color: Color(0xFFB03565)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.pink),
                          onPressed: () =>
                              _deleteFriend(friend['phoneNumber']),
                        ),
                        Icon(Icons.arrow_forward_ios, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
