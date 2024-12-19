import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hedieaty/offlineEvents.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({Key? key}) : super(key: key);

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  late String userId;
  bool isOnline = false;
  String _sortBy = 'name'; // Default sorting criteria

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    isOnline = connectivityResult != ConnectivityResult.none;

    if (!isOnline) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OfflineEventListPage(userId: userId),
        ),
      );
    }
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

  void _editEvent(String eventId, Map<String, dynamic> eventData) {
    Navigator.pushNamed(
      context,
      '/editEvent',
      arguments: {
        'eventId': eventId,
        'eventData': eventData,
      },
    );
  }

  void _navigateToGiftListPage(String eventId, String eventName) {
    Navigator.pushNamed(
      context,
      '/GiftList',
      arguments: {
        'eventId': eventId,
        'eventName': eventName,
      },
    );
  }

  void _sortEvents(List<QueryDocumentSnapshot> events) {
    events.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;

      if (_sortBy == 'status') {
        final aStatus = _determineEventStatus(aData['date']);
        final bStatus = _determineEventStatus(bData['date']);
        return aStatus.compareTo(bStatus);
      } else {
        return aData[_sortBy].toString().compareTo(bData[_sortBy].toString());
      }
    });
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
      body: Column(
        children: [
          // Dropdown Menu for Sorting
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: _sortBy,
                  dropdownColor: Colors.white,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB03565),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'name',
                      child: Text("Name"),
                    ),
                    DropdownMenuItem(
                      value: 'status',
                      child: Text("Status"),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sortBy = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('events')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No events found!',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                final events = snapshot.data!.docs;
                _sortEvents(events);

                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final eventId = event.id;
                    final eventData = event.data() as Map<String, dynamic>;

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
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
                              icon: const Icon(Icons.edit,
                                  color: Color(0xFFB03565)),
                              onPressed: () => _editEvent(eventId, eventData),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.black54),
                              onPressed: () => _deleteEvent(eventId),
                            ),
                          ],
                        ),
                        onTap: () => _navigateToGiftListPage(
                            eventId, eventData['name']),
                      ),
                    );
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
