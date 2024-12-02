import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendGiftListPage extends StatefulWidget {
  const FriendGiftListPage({Key? key}) : super(key: key);

  @override
  State<FriendGiftListPage> createState() => _FriendGiftListPageState();
}

class _FriendGiftListPageState extends State<FriendGiftListPage> {
  late String userId;
  late String friendId;
  late String eventId;
  late String eventName;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    friendId = args['friendId'] ?? ''; // Get friend's ID
    eventId = args['eventId'] ?? '';
    eventName=args['eventName']??'';// Get event ID
  }


  void _pledgeGift(String giftId) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(friendId) // Use friendId to access their data
        .collection('events')
        .doc(eventId)
        .collection('gifts')
        .doc(giftId)
        .update({
      'pledged': true, // Mark gift as pledged
      'pledgedBy': userId, // Record who pledged the gift
    })
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift pledged successfully!')),
      );
    })
        .catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pledge gift.')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Friend's Gift List",
          style: TextStyle(color: Colors.white, fontFamily: "Lobster"),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(friendId) // Use friendId to get the correct friend's data
            .collection('events')
            .doc(eventId)
            .collection('gifts')
            .orderBy('name', descending: false) // Sort by gift name
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No gifts available!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final gifts = snapshot.data!.docs;

          return Flexible(
            child: ListView.builder(
              itemCount: gifts.length,
              itemBuilder: (context, index) {
                final gift = gifts[index];
                final giftId = gift.id;
                final giftData = gift.data() as Map<String, dynamic>;

                // Check if the gift is pledged
                bool isPledged = giftData['pledged'] ?? false;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    title: Text(
                      giftData['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: isPledged ? Colors.grey : const Color(0xFFB03565), // Disable interaction if pledged
                        decoration: isPledged ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Category: ${giftData['category'] ?? 'N/A'}",
                          style: const TextStyle(fontSize: 16, color: Color(0xFFB03565)),
                        ),
                        Text(
                          "Status: ${giftData['status'] ?? 'N/A'}",
                          style: const TextStyle(fontSize: 16, color: Color(0xFFB03565)),
                        ),
                      ],
                    ),
                    trailing: isPledged
                        ? const Icon(Icons.check, color: Colors.green) // Show check icon if pledged
                        : ElevatedButton(
                      onPressed: () => _pledgeGift(giftId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                      ),
                      child: const Text("Pledge"),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
