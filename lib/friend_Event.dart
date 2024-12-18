import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendEventPage extends StatefulWidget {
  const FriendEventPage({Key? key}) : super(key: key);

  @override
  State<FriendEventPage> createState() => _FriendEventPageState();
}

class _FriendEventPageState extends State<FriendEventPage> {
  late String friendId;
  late String friendName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the friend's ID and name from the navigation arguments
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    friendId = arguments['friendId'] ?? '';
    friendName = arguments['friendName'] ?? 'Unknown';
  }


  String _determineEventStatus(dynamic eventDate) {
    if (eventDate == null) return "N/A";

    DateTime eventDateTime;
    if (eventDate is Timestamp) {
      eventDateTime = eventDate.toDate();
    } else if (eventDate is DateTime) {
      eventDateTime = eventDate;
    } else {
      return "Invalid Date";
    }

    final now = DateTime.now();
    final difference = eventDateTime.difference(now).inDays;

    if (difference > 2) {
      return "Upcoming";
    } else if (difference >= 0) {
      return "Current";
    } else {
      return "Past";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("$friendName's Events"),
          backgroundColor: const Color(0xFFE91E63),
        ),
        body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
        .doc(friendId)
        .collection('events')
        .orderBy('date', descending: false)
        .snapshots(),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return const Center(child: CircularProgressIndicator());
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
    return const Center(
    child: Text(
    'No events found!',
    style: TextStyle(
    fontSize: 18,
    color: Colors.grey,
    ),
    ),
    );
    }

    final events = snapshot.data!.docs;

    return ListView.builder(
    itemCount: events.length,
    itemBuilder: (context, index) {
    final event = events[index];
    final eventData = event.data() as Map<String, dynamic>;

    return Card(
    elevation: 2,
    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    child: ListTile(
    title: Text(
    eventData['name'],
    style: const TextStyle(
    fontWeight: FontWeight.bold,
      color: Color(0xFFB03565),
    ),
    ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Category: ${eventData['category'] ?? 'N/A'}",
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFFB03565),
            ),
          ),
          Text(
            "Status: ${_determineEventStatus(eventData['date'])}",
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFFB03565),
            ),
          ),
          Text(
            "Date: ${eventData['date']?.toDate().toLocal().toString().split(' ')[0] ?? 'N/A'}",
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFFB03565),
            ),
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.event, color: Colors.pink),
        onPressed: () {
          // Navigate to the Gift List page for the selected event
          Navigator.pushNamed(
            context,
            '/friend_gifts', // Replace with the correct route name for the gift list page
            arguments: {
              'eventId': event.id,  // The Firestore document ID of the event
              'friendId': friendId, // The ID of the friend
              'eventName': eventData['name'], // Event name, or other data you want to pass
            },
          );

        },
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
