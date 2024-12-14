import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty/giftDetails_page.dart';

class GiftListPage extends StatefulWidget {
  const GiftListPage({Key? key}) : super(key: key);

  @override
  State<GiftListPage> createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  late String userId;
  late String eventId;
  String? eventName;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid; // Already correct
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Access route arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;

    if (args != null) {
      eventId = args['eventId'] ?? '';
      eventName=args['eventName']??'';// Safely set eventId

      // Fetch the event name from Firestore
      _fetchEventName();
    } else {
      print('No arguments passed or eventId is missing');
    }
  }

  Future<void> _fetchEventName() async {
    try {
      final eventDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .get();

      if (eventDoc.exists) {
        setState(() {
          eventName = eventDoc.data()?['name'] ?? 'Event';
        });
      }
    } catch (e) {
      print('Error fetching event name: $e');
    }
  }

  void _editGift(String giftId) {
    Navigator.pushNamed(
      context,
      '/editgift',
      arguments: {
        'eventId': eventId,
        'giftId': giftId,
      },
    );
  }

  void _deleteGift(String giftId) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('events')
        .doc(eventId)
        .collection('gifts')
        .doc(giftId)
        .delete()
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift deleted successfully!')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete gift.')),
      );
    });
  }

  Future<void> _addGift() async {
    final newGift = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateGift(
          eventId: eventId,
          userId: userId,
        ),
      ),
    );

    if (newGift != null) {
      setState(() {
        // Handle the newly created gift, if necessary
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown, // Ensures text scales down if needed
          child: Text(
            eventName != null ? "$eventName Gift List" : "Loading...",
            style: const TextStyle(color: Colors.white, fontFamily: "Lobster"),
          ),
        ),


        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addGift,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
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

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text(
                    giftData['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: (giftData['pledged'] ?? false) ? Colors.grey : const Color(0xFFB03565),
                      decoration: (giftData['pledged'] ?? false) ? TextDecoration.lineThrough :TextDecoration.none,
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFFB03565)),
                        onPressed: () => _editGift(giftId),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.black54),
                        onPressed: () => _deleteGift(giftId),
                      ),
                    ],
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
