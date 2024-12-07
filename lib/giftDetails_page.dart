import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateGift extends StatefulWidget {
  final String eventId; // Event ID under which the gift will be created
  final String userId;  // User ID associated with the gift creation

  // Constructor to accept eventId and userId
  const CreateGift({Key? key, required this.eventId, required this.userId}) : super(key: key);

  @override
  State<CreateGift> createState() => _CreateGiftState();
}


class _CreateGiftState extends State<CreateGift> {
  final _formKey = GlobalKey<FormState>();
  String giftName = '';
  String giftDescription = '';
  double giftPrice = 0.0;
  String? selectedCategory;

  final List<String> categories = [
    'Electronics',
    'Books',
    'Clothing',
    'Accessories',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    print('User ID: ${widget.userId}');
    print('Event ID: ${widget.eventId}');
  }


  Future<void> _createGift() async {
    if (widget.userId.isEmpty || widget.eventId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID or Event ID is invalid!')),
      );
      return;
    }

    if (_formKey.currentState!.validate() && selectedCategory != null) {
      _formKey.currentState!.save();

      try {
        // Access gifts through the userId -> events -> eventId -> gifts structure
        final giftsRef = FirebaseFirestore.instance
            .collection('users') // Reference the users collection
            .doc(widget.userId)  // User document (userId)
            .collection('events') // Events subcollection under the user
            .doc(widget.eventId)  // Event document (eventId)
            .collection('gifts'); // Gifts subcollection under the event

        await giftsRef.add({
          'name': giftName,
          'description': giftDescription,
          'price': giftPrice,
          'category': selectedCategory,
          'createdBy': widget.userId, // Track the user who created the gift
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gift added successfully!')),
        );
        Navigator.pop(context); // Navigate back to the previous screen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add gift.')),
        );
        print('Error: $e');
      }
    } else if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Gift'),
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
                          labelText: 'Gift Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onSaved: (value) {
                          giftName = value!.trim();
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the gift name';
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
                        onSaved: (value) {
                          giftDescription = value!.trim();
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Price',
                          prefixText: '\$',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onSaved: (value) {
                          giftPrice = double.parse(value!.trim());
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the price';
                          }
                          final parsed = double.tryParse(value.trim());
                          if (parsed == null || parsed < 0) {
                            return 'Please enter a valid price';
                          }
                          return null;
                        },
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
                            selectedCategory = value;
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
                          onPressed: _createGift,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE91E63),
                          ),
                          child: const Text(
                            'Add Gift',
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
