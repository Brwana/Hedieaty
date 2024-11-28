import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateEvent extends StatefulWidget {
  const CreateEvent({Key? key}) : super(key: key);

  @override
  State<CreateEvent> createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
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

  Future<void> _createEvent() async {
    if (_formKey.currentState!.validate() && selectedCategory != null) {
      _formKey.currentState!.save();

      try {
        final userId = FirebaseAuth.instance.currentUser!.uid;
        final userEventsRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('events'); // Save under the current user's events collection

        await userEventsRef.add({
          'name': eventName,
          'location': eventLocation,
          'description': eventDescription,
          'date': eventDate,
          'category': selectedCategory,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event created successfully!')),
        );
        Navigator.pop(context); // Navigate back to the previous screen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create event.')),
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
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
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
                            labelText: 'Event Date',labelStyle: TextStyle(color: Color(0xFF4D4953),),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(color: Color(0xFF4D4953)), // Match the default color
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(color: Color(0xFF4D4953)), // Ensure sharp corners for disabled state
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(color: Color(0xFFE91E63)), // Match theme color
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
                          onPressed: _createEvent,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE91E63),
                          ),
                          child: const Text(
                            'Create Event',
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
