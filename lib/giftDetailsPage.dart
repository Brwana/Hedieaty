import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GiftDetailsPage extends StatelessWidget {
  final String eventId;
  final String giftId;
  final String userId;

  const GiftDetailsPage({
    Key? key,
    required this.eventId,
    required this.giftId,
    required this.userId,
  }) : super(key: key);

  Stream<DocumentSnapshot> _getGiftDetailsStream() {
    // Stream gift details from Firestore
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('events')
        .doc(eventId)
        .collection('gifts')
        .doc(giftId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift Details'),
        backgroundColor: const Color(0xFFE91E63),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/editgift',
                arguments: {
                  'eventId': eventId,
                  'giftId': giftId,
                },
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _getGiftDetailsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No gift data found.'));
          }

          final giftData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  'Gift Name: ${giftData['name'] ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB03565),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Description: ${giftData['description'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                Text(
                  'Price: \$${giftData['price']?.toStringAsFixed(2) ?? 'N/A'}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                Text(
                  'Category: ${giftData['category'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                Text(
                  'Status: ${giftData['status'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    // Handle image selection
                  },
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: giftData['imagePath'] != null
                          ? Image.asset(
                        giftData['imagePath'],
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: 150,
                      )
                          : const Center(
                        child: Text('No image available'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
