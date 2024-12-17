import 'package:flutter/material.dart';
import 'package:hedieaty/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'offlineEvents.dart';

class OfflineHomePage extends StatefulWidget {
  final String currentUserId;

  const OfflineHomePage({required this.currentUserId, Key? key}) : super(key: key);

  @override
  State<OfflineHomePage> createState() => _OfflineHomePageState();
}

class _OfflineHomePageState extends State<OfflineHomePage> {
  final DatabaseClass databaseHelper = DatabaseClass();
  List<Map<String, dynamic>> offlineFriends = [];
  List<Map<String, dynamic>> filteredOfflineFriends = [];
  List<Map<String, dynamic>> userEvents = [];
  bool isOnline = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _fetchOfflineFriends();
    _fetchUserEvents();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      Navigator.pushNamed(context, '/home');
    }
  }

  Future<void> _fetchOfflineFriends() async {
    try {
      final friends = await databaseHelper.readData('''
      SELECT FriendID FROM Friends WHERE UserID = '${widget.currentUserId}';
    ''');

      if (friends.isEmpty) {
        setState(() {
          offlineFriends = [];
          filteredOfflineFriends = [];
        });
        return;
      }

      List<Map<String, dynamic>> friendDetails = [];
      for (var friend in friends) {
        final friendData = await databaseHelper.readData('''
        SELECT ID, Name, Email, PhoneNumber FROM Users WHERE ID = '${friend['FriendID']}';
      ''');

        if (friendData.isNotEmpty) {
          friendDetails.add(friendData[0]);
        }
      }

      setState(() {
        offlineFriends = friendDetails.map((row) {
          return {
            'id': row['ID'],
            'Name': row['Name'] ?? 'Unknown (Offline)',
            'email': row['Email'] ?? 'N/A',
            'phone': row['PhoneNumber'] ?? 'N/A',
          };
        }).toList();

        filteredOfflineFriends = offlineFriends;
      });
    } catch (e) {
      print('Error fetching offline friends: $e');
    }
  }

  Future<void> _fetchUserEvents() async {
    try {
      final events = await databaseHelper.readData('''
      SELECT EventID, EventName FROM Events WHERE UserID = '${widget.currentUserId}';
    ''');

      setState(() {
        userEvents = events;
      });
    } catch (e) {
      print('Error fetching user events: $e');
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
          actions: [
            IconButton(
              icon: Icon(Icons.event),
              onPressed: () {
                print(widget.currentUserId);
                // Navigate to the OfflineEventListPage when the icon is clicked
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OfflineEventListPage(userId: widget.currentUserId),
                  ),
                );
                print("Navigation triggered to OfflineEventListPage");
              },
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
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('asset/offline.jpg'),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              friend['Name'] ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB03565),
                              ),
                            ),
                            SizedBox(height: 5),
                            if (friend['email'] != null)
                              Text(
                                'Email: ${friend['email']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            if (friend['phone'] != null)
                              Text(
                                'Phone: ${friend['phone']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                          ],
                        ),
                      ),
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
