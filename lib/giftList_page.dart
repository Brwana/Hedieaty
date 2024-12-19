import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty/createGift_page.dart';
import 'giftDetailsPage.dart';

class GiftListPage extends StatefulWidget {
  const GiftListPage({Key? key}) : super(key: key);

  @override
  State<GiftListPage> createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  late String userId;
  late String eventId;
  String? eventName;
  late DocumentSnapshot<Map<String, dynamic>> eventDoc;
  String _sortBy = 'name';


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
      eventName = args['eventName'] ?? ''; // Safely set eventId

      // Fetch the event name from Firestore
      _fetchEventName();
    } else {
      print('No arguments passed or eventId is missing');
    }
  }

  Future<void> _fetchEventName() async {
    try {
    eventDoc = await FirebaseFirestore.instance
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
  void _sortGifts(List<QueryDocumentSnapshot> gifts) {
    gifts.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;

      if (_sortBy == 'status') {
        final aStatus = aData['status'] ?? 'Available';
        final bStatus = bData['status'] ?? 'Available';
        return aStatus.compareTo(bStatus);
      } else {
        return aData['name'].toString().compareTo(bData['name'].toString());
      }
    });
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
      body:Column(
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
      Expanded(child: StreamBuilder<QuerySnapshot>(
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
          _sortGifts(gifts);

          return ListView.builder(
            itemCount: gifts.length,
            itemBuilder: (context, index) {
              final gift = gifts[index];
              final giftId = gift.id;
              final giftData = gift.data() as Map<String, dynamic>;
              final imageUrl = giftData['imagePath'];
              // final pledged = giftData['pledged'] ?? false;
              final status = giftData['status'] ?? 'Available';

              return GestureDetector(
                onTap: () {
                  // Navigate to the GiftDetailsPage on tap
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GiftDetailsPage(
                        eventId: eventId,
                        giftId: gift.id,
                        userId: userId,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 4, // Increase elevation for a thicker card shadow
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0), // Increased vertical margin
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0), // Increase padding for larger height
                    leading: CircleAvatar(
                      backgroundImage: imageUrl != null
                          ? AssetImage(imageUrl)
                          : const AssetImage('asset/present.jpg') as ImageProvider, // default image if no URL
                      radius: 40, // Increase radius for a larger avatar
                    ),
                    title: Text(
                      giftData['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22, // Increase font size for the title
                        color: status == 'Pledged' ? Colors.grey : const Color(0xFFB03565),
                        decoration: status == 'Pledged' ? TextDecoration.lineThrough : null
                        ,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Category: ${giftData['category'] ?? 'N/A'}",
                          style: const TextStyle(fontSize: 18, color: Color(0xFFB03565)),
                        ),
                        Text(
                              "Gift Status: $status",
                          style: const TextStyle(fontSize: 18, color: Color(0xFFB03565)),
                        ),
                        Text(
                          "Event Status: ${eventDoc['status']}",
                          style: const TextStyle(fontSize: 18, color: Color(0xFFB03565)),
                        ),
                      ],
                    ),
                    trailing: status == 'Pledged'
                        ? null // Don't show the icons if pledged
                        : Row(
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
                ),
              );
            },
          );
        },
      ),),
    ],),);

  }
}


