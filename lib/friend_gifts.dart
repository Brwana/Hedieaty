import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty/NotificationService.dart';

class FriendGiftListPage extends StatefulWidget {
  const FriendGiftListPage({Key? key}) : super(key: key);

  @override
  State<FriendGiftListPage> createState() => _FriendGiftListPageState();
}

class _FriendGiftListPageState extends State<FriendGiftListPage> {
  late String userId;
  late String userName;
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
      // Fetch the user document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users') // Replace 'users' with your collection name
          .doc(userId)
          .get();
      // Extract the 'fullName' field from the document
      if (userDoc.exists) {
        userName=userDoc.get('fullName');
        print("userName: $userName"); // Ensure 'fullName' exists in Firestore
      } else {
        print("User document does not exist");
        return null;
      }
      // Update the pledged status for the gift
      await FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(giftId)
          .update({
        'status': 'Pledged',
        'pledgedBy': userId,
      });
      // Get the friend's device token from Firestore
      DocumentSnapshot friendDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .get();


      String? friendDeviceToken = friendDoc['deviceToken'];  // Assuming device token is stored in the user's Firestore document
      print("friendDevice : $friendDeviceToken");

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
        'friendName': friendDoc['fullName'],
        'pledgedAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift pledged successfully!')),
      );
      if (friendDeviceToken != null) {
        // Send a notification to the friend
        await PushNotifications.SendNotificationToPledgedFriend(
          friendDeviceToken,
          context,
          giftId,
          giftName,
          eventName,
          userName ?? 'Unknown User',
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pledge gift.')),
      );
    }
  }

  void _unpledgeGift(String giftId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(giftId)
          .update({
        'status': 'Available',
        'pledgedBy': null,
      });

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
          fit: BoxFit.scaleDown,
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
              final imageUrl = giftData['imagePath'];
              final isPledgedByMe = giftData['pledgedBy'] == userId;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  leading: CircleAvatar(
                    backgroundImage: imageUrl != null
                        ? AssetImage(imageUrl)
                        : const AssetImage('asset/present.jpg') as ImageProvider,
                    radius: 40,
                  ),
                  title: Text(
                    giftData['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: isPledgedByMe ? Colors.grey : const Color(0xFFB03565),
                      decoration: isPledgedByMe ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text(
                    "Category: ${giftData['category'] ?? 'N/A'}",
                    style: const TextStyle(fontSize: 18, color: Color(0xFFB03565)),
                  ),
                  trailing: isPledgedByMe
                      ? ElevatedButton(
                    onPressed: () => _unpledgeGift(giftId),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    child: const Text("Unpledge"),
                  )
                      : ElevatedButton(
                    onPressed: () => _pledgeGift(giftId, giftData['name'], giftData['category'] ?? 'N/A'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
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
