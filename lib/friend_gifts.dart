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
    friendId = args['friendId'] ?? '';
    eventId = args['eventId'] ?? '';
    eventName = args['eventName'] ?? '';
  }

  void _pledgeGift(String giftId, String giftName, String category) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(giftId)
          .update({
        'pledged': true,
        'pledgedBy': userId,
      });

      // Save pledge details to the current user's "pledged_gifts" collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('pledged_gifts')
          .doc(giftId)
          .set({
        'giftName': giftName,
        'category': category,
        'eventId': eventId,
        'eventName': eventName,
        'friendId': friendId,
        'pledgedAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift pledged successfully!')),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pledge gift.')),
      );
    }
  }

  void _unpledgeGift(String giftId) async {
    try {
      // Update the gift status in the friend's collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(giftId)
          .update({
        'pledged': false,
        'pledgedBy': null,
      });

      // Remove the gift from the current user's "pledged_gifts"
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('pledged_gifts')
          .doc(giftId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift unpledged successfully!')),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to unpledge gift.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown, // Scales the text to fit the available space
          child: Text(
            "$eventName - Gifts",
            style: const TextStyle(color: Colors.white, fontFamily: "Lobster"),
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(friendId)
            .collection('events')
            .doc(eventId)
            .collection('gifts')
            .orderBy('name', descending: false)
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

          return ListView.builder(
            itemCount: gifts.length,
            itemBuilder: (context, index) {
              final gift = gifts[index];
              final giftId = gift.id;
              final giftData = gift.data() as Map<String, dynamic>;

              bool isPledged = giftData['pledged'] ?? false;
              bool isPledgedByMe = giftData['pledgedBy'] == userId;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text(
                    giftData['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: isPledgedByMe ? Colors.green : const Color(0xFFB03565),
                      decoration: isPledgedByMe ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text(
                    "Category: ${giftData['category'] ?? 'N/A'}",
                    style: const TextStyle(fontSize: 16, color: Color(0xFFB03565)),
                  ),
                  trailing: isPledgedByMe
                      ? ElevatedButton(
                    onPressed: () => _unpledgeGift(giftId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    child: const Text("Unpledge"),
                  )
                      : ElevatedButton(
                    onPressed: () => _pledgeGift(
                      giftId,
                      giftData['name'],
                      giftData['category'] ?? 'N/A',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                    ),
                    child: const Text("Pledge"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
