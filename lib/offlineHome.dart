import 'package:flutter/material.dart';
import 'package:hedieaty/database.dart';
import 'package:firebase_auth/firebase_auth.dart';


class OfflineHomePage extends StatefulWidget {
  final String currentUserId;

  const OfflineHomePage({required this.currentUserId, Key? key}) : super(key: key);

  @override
  State<OfflineHomePage> createState() => _OfflineHomePageState();
}


class _OfflineHomePageState extends State<OfflineHomePage> {
  final DatabaseClass databaseHelper = DatabaseClass();
  // User? currentUser = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> offlineFriends = [];
  List<Map<String, dynamic>> filteredOfflineFriends = [];

  @override
  void initState() {
    super.initState();
    _fetchOfflineFriends();
  }

  Future<void> _fetchOfflineFriends() async {
    try {
      // Step 1: Fetch Friend IDs for the current user
      print("Current UserID: ${widget.currentUserId}");
      final friends = await databaseHelper.readData('''
      SELECT FriendID FROM Friends WHERE UserID = '${widget.currentUserId}';
    ''');

      // Check if any friends were retrieved
      if (friends.isEmpty) {
        print("No friends found for UserID: ${widget.currentUserId}");
        setState(() {
          offlineFriends = [];
          filteredOfflineFriends = [];
        });
        return; // Exit if no friends found
      }

      print("Friend IDs: $friends");

      // Step 2: Fetch details for each FriendID from the Users table
      List<Map<String, dynamic>> friendDetails = [];
      for (var friend in friends) {
        final friendData = await databaseHelper.readData('''
        SELECT ID, Name, Email, PhoneNumber FROM Users WHERE ID = '${friend['FriendID']}';
      ''');

        if (friendData.isNotEmpty) {
          friendDetails.add(friendData[0]); // Add the first row of result
        }
      }

      // Debug log for friend details
      print("Friend Details: $friendDetails");

      // Step 3: Format data for the UI
      setState(() {
        offlineFriends = friendDetails.map((row) {
          return {
            'id': row['ID'], // Friend's unique ID
            'Name': row['Name'] ?? 'Unknown (Offline)', // Friend's name
            'email': row['Email'] ?? 'N/A', // Friend's email
            'phone': row['PhoneNumber'] ?? 'N/A', // Friend's phone
          };
        }).toList();

        // Initialize the filtered list
        filteredOfflineFriends = offlineFriends;
      });
    } catch (e) {
      print('Error fetching offline friends: $e');
    }
  }



  void _filterOfflineFriends(String query) {
    setState(() {
      filteredOfflineFriends = offlineFriends
          .where((friend) => friend['Name'] != null &&
          friend['Name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Offline Friends"),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 25.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search offline friends...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onChanged: _filterOfflineFriends,
                  ),
                ),
              ],
            ),
          ),
          // Friends list
          Expanded(
            child: offlineFriends.isEmpty
                ? Center(
              child: Text(
                'No offline friends available.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: filteredOfflineFriends.length,
              itemBuilder: (context, index) {
                final friend = filteredOfflineFriends[index];
                return Container(
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
                      // Friend avatar
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('asset/offline.jpg'),
                      ),
                      SizedBox(width: 15),
                      // Friend details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Friend's name
                            Text(
                              friend['Name'] ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB03565),
                              ),
                            ),
                            SizedBox(height: 5),
                            // Friend's email
                            if (friend['email'] != null) ...[
                              Text(
                                'Email: ${friend['email']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 5),
                            ],
                            // Friend's phone number
                            if (friend['phone'] != null) ...[
                              Text(
                                'Phone: ${friend['phone']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 5),
                            ],
                            // Friend's event count
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
                                  style: TextStyle(
                                      color: Color(0xFFB03565)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Navigation arrow
                      Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    ],
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
