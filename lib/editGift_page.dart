import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditGift extends StatefulWidget {
  final String eventId; // Event ID to identify the event
  final String giftId;
  // Gift ID to identify the gift
  const EditGift({Key? key,required this.giftId ,required this.eventId}) : super(key: key);

  @override
  State<EditGift> createState() => _EditGiftState();
}

class _EditGiftState extends State<EditGift> {
  final _formKey = GlobalKey<FormState>();
  String giftName = '';
  String giftDescription = '';
  double giftPrice = 0.0;
  String? selectedCategory;
  bool isLoading = true;

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
    _loadGiftDetails();
  }

  /// Load the gift details from Firestore
  Future<void> _loadGiftDetails() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final giftRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(widget.eventId) // Event ID
          .collection('gifts')
          .doc(widget.giftId); // Gift ID

      final giftSnapshot = await giftRef.get();
      if (giftSnapshot.exists) {
        final giftData = giftSnapshot.data()!;
        setState(() {
          giftName = giftData['name'] ?? '';
          giftDescription = giftData['description'] ?? '';
          giftPrice = giftData['price']?.toDouble() ?? 0.0;
          selectedCategory = giftData['category'] ?? categories.first;
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gift not found.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load gift details.')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _updateGift() async {
    if (_formKey.currentState!.validate() && selectedCategory != null) {
      _formKey.currentState!.save();

      try {
        final userId = FirebaseAuth.instance.currentUser!.uid;
        final giftRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('events')
            .doc(widget.eventId) // Event ID
            .collection('gifts')
            .doc(widget.giftId); // Gift ID

        await giftRef.update({
          'name': giftName,
          'description': giftDescription,
          'price': giftPrice,
          'category': selectedCategory,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gift updated successfully!')),
        );
        Navigator.pop(context); // Navigate back to the previous screen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update gift.')),
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
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Gift'),
          backgroundColor: const Color(0xFFE91E63),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Gift'),
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
                        initialValue: giftName,
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
                        initialValue: giftDescription,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        maxLines: 3,
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
                        initialValue: giftPrice.toString(),
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
                          onPressed: _updateGift,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE91E63),
                          ),
                          child: const Text(
                            'Update Gift',
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
