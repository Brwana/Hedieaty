import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({Key? key}) : super(key: key);

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  String _determineEventStatus(dynamic eventDate) {
    if (eventDate == null) return "N/A";

    DateTime eventDateTime;
    // Ensure compatibility with Timestamp and DateTime
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

  Future<void> _deleteEvent(String eventId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete event.')),
      );
    }
  }

  void _editEvent(String eventId, Map<String, dynamic> event) {
    Navigator.pushNamed(
      context,
      '/editEvent',
      arguments: {
        'eventId': eventId,
        'eventData': event,
      },
    );
  }

  void _navigateToGiftListPage(Map<String, dynamic> eventData) {
    Navigator.pushNamed(
      context,
      '/GiftList',
      arguments: eventData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event List"),
        backgroundColor: const Color(0xFFE91E63),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/createEvent');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
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

          return Flexible(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                final eventId = event.id;
                final eventData = event.data() as Map<String, dynamic>;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    title: Text(
                      eventData['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFFB03565)),
                          onPressed: () => _editEvent(eventId, eventData),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.black54),
                          onPressed: () => _deleteEvent(eventId),
                        ),
                      ],
                    ),
                    onTap: () => _navigateToGiftListPage(eventData),
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
