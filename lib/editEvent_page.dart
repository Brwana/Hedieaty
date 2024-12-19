import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditEvent extends StatefulWidget {
  final String eventId;
  final Map<String, dynamic>? eventData; // Optional, if needed

  const EditEvent({
    Key? key,
    required this.eventId,
    this.eventData,
  }) : super(key: key);

  @override
  State<EditEvent> createState() => _EditEventState();
}


class _EditEventState extends State<EditEvent> {
  final _formKey = GlobalKey<FormState>();
  String eventName = '';
  String eventLocation = '';
  String eventDescription = '';
  DateTime? eventDate;
  String? selectedCategory;

  final List<String> categories = [
    'Birthday',
    'Wedding',
    'Baby Shower',
  ];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEventDetails();
  }
  String determineEventStatus(DateTime eventDate) {
    final currentDate = DateTime.now();
    final eventEndDate = eventDate.add(const Duration(days: 1));

    if (currentDate.isBefore(eventDate)) {
      return 'Upcoming';
    } else if (currentDate.isAfter(eventEndDate)) {
      return 'Past';
    } else {
      return 'Current';
    }
  }


  /// Load the event details from Firestore
  Future<void> _loadEventDetails() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final eventRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(widget.eventId); // Access eventId passed through constructor

      final eventSnapshot = await eventRef.get();
      if (eventSnapshot.exists) {
        final eventData = eventSnapshot.data()!;
        setState(() {
          eventName = eventData['name'] ?? '';
          eventLocation = eventData['location'] ?? '';
          eventDescription = eventData['description'] ?? '';
          eventDate = (eventData['date'] as Timestamp).toDate();
          selectedCategory = eventData['category'] ?? categories.first;
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event not found.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load event details.')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _updateEvent() async {
    if (_formKey.currentState!.validate() && selectedCategory != null) {
      _formKey.currentState!.save();

      try {
        final userId = FirebaseAuth.instance.currentUser!.uid;
        final eventRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('events')
            .doc(widget.eventId);

        final eventStatus = determineEventStatus(eventDate!);

        await eventRef.update({
          'name': eventName,
          'location': eventLocation,
          'description': eventDescription,
          'date': eventDate,
          'category': selectedCategory,
          'status': eventStatus, // Update status
          'updatedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event updated successfully!')),
        );
        Navigator.pop(context); // Navigate back to the previous screen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update event.')),
        );
        print('Error: $e');
      }
    } else if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
      );
    }
  }


  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: eventDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        eventDate = selectedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Event'),
          backgroundColor: const Color(0xFFE91E63),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Event'),
        backgroundColor: const Color(0xFFE91E63),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        initialValue: eventName,
                        decoration: InputDecoration(
                          labelText: 'Event Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onSaved: (value) {
                          eventName = value!.trim();
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the event name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        initialValue: eventLocation,
                        decoration: InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onSaved: (value) {
                          eventLocation = value!.trim();
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        initialValue: eventDescription,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        maxLines: 3,
                        onSaved: (value) {
                          eventDescription = value!.trim();
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _selectDate,
                        child: TextFormField(
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: 'Event Date',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today, color: Color(0xFFE91E63)),
                              onPressed: _selectDate,
                            ),
                          ),
                          controller: TextEditingController(
                            text: eventDate != null
                                ? '${eventDate!.toLocal()}'.split(' ')[0]
                                : '',
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        value: selectedCategory,
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(
                              category,
                              style: const TextStyle(fontFamily: "Caveat", fontSize: 20),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updateEvent,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE91E63),
                          ),
                          child: const Text(
                            'Update Event',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
