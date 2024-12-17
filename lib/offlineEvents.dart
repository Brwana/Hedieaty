import 'package:flutter/material.dart';
import 'package:hedieaty/database.dart';
class OfflineEventListPage extends StatefulWidget {
  final String userId;

  const OfflineEventListPage({Key? key,required this.userId}) : super(key: key);

  @override
  State<OfflineEventListPage> createState() => _OfflineEventListPageState();
}

class _OfflineEventListPageState extends State<OfflineEventListPage> {
  List<Map<String, dynamic>> offlineEvents = [];
  late DatabaseClass databaseHelper;
  // final String userId = ModalRoute.of(context)!.settings.arguments as String;

  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseClass(); // Initialize your SQLite helper class
    _fetchOfflineEvents();
  }

  Future<void> _fetchOfflineEvents() async {
    try {
      final events = await databaseHelper.readData('''
        SELECT * FROM Events WHERE UserID = '${widget.userId}' ORDER BY Date ASC;
      ''');

      setState(() {
        offlineEvents = events.map((row) {
          return {
            'id': row['ID'],
            'name': row['Name'],
            'category': row['Category'],
            'date': row['Date'], // Assume this is stored in ISO format
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching offline events: $e');
    }
  }

  String _determineEventStatus(String eventDateStr) {
    DateTime eventDate = DateTime.parse(eventDateStr);
    final now = DateTime.now();
    final difference = eventDate.difference(now).inDays;

    if (difference > 2) {
      return "Upcoming";
    } else if (difference >= 0) {
      return "Current";
    } else {
      return "Past";
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Offline Event List"),
        backgroundColor: const Color(0xFFE91E63),
      ),
      body: offlineEvents.isEmpty
          ? const Center(
        child: Text(
          'No events found!',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: offlineEvents.length,
        itemBuilder: (context, index) {
          final event = offlineEvents[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: ListTile(
              title: Text(
                event['name'],
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
                    "Category: ${event['category'] ?? 'N/A'}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFB03565),
                    ),
                  ),
                  Text(
                    "Status: ${_determineEventStatus(event['date'])}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFB03565),
                    ),
                  ),
                  Text(
                    "Date: ${event['date'].split(' ')[0]}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFB03565),
                    ),
                  ),
                ],
              ),
              onTap: () =>
                  _navigateToGiftListPage(event['id'], event['name']),
            ),
          );
        },
      ),
    );
  }
}
