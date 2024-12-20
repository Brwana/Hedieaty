import 'package:flutter/material.dart';
import 'package:hedieaty/database.dart';

class offlineGiftListPage extends StatefulWidget {
  final String eventId;

  const offlineGiftListPage({Key? key, required this.eventId}) : super(key: key);

  @override
  State<offlineGiftListPage> createState() => _offlineGiftListPageState();
}

class _offlineGiftListPageState extends State<offlineGiftListPage> {
  List<Map<String, dynamic>> gifts = [];
  late DatabaseClass databaseHelper;

  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseClass(); // Initialize your SQLite helper class
    _fetchGifts();
  }

  Future<void> _fetchGifts() async {
    try {
      final giftList = await databaseHelper.readData('''
        SELECT * FROM Gifts WHERE EventID = '${widget.eventId}' ORDER BY name ASC;
      ''');

      setState(() {
        gifts = giftList.map((row) {
          return {
            'id': row['ID'],
            'name': row['Name'],
            'category': row['Category'],
            'price': row['Price'],
            'status': row['Status'],
            'description': row['Description'],
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching gifts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gift List"),
        backgroundColor: const Color(0xFFE91E63),
      ),
      body: gifts.isEmpty
          ? const Center(
        child: Text(
          'No gifts found!',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: gifts.length,
        itemBuilder: (context, index) {
          final gift = gifts[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: ListTile(
              title: Text(
                gift['name'],
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
                    "Category: ${gift['category'] ?? 'N/A'}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFB03565),
                    ),
                  ),
                  Text(
                    "Price: \$${gift['price']}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFB03565),
                    ),
                  ),
                  Text(
                    "Status: ${gift['status'] ?? 'N/A'}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFB03565),
                    ),
                  ),
                  Text(
                    "Description: ${gift['description'] ?? 'N/A'}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFB03565),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
