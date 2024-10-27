import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Required for the File class

class GiftDetailsPage extends StatefulWidget {
  const GiftDetailsPage({super.key});

  @override
  State<GiftDetailsPage> createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  String giftName = '';
  String giftDescription = '';
  String giftCategory = 'Electronics';
  double giftPrice = 0.0;
  String giftStatus = 'Available';
  XFile? giftImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      giftImage = pickedFile;
    });
  }

  void _saveGift() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Logic to save the gift details
      print("Gift Name: $giftName");
      print("Description: $giftDescription");
      print("Category: $giftCategory");
      print("Price: \$${giftPrice.toStringAsFixed(2)}");
      print("Status: $giftStatus");
      print("Image Path: ${giftImage?.path}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gift Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveGift,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Gift Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a gift name';
                  }
                  return null;
                },
                onSaved: (value) => giftName = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) => giftDescription = value!,
              ),
              DropdownButtonFormField<String>(
                value: giftCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
                items: const [
                  DropdownMenuItem(value: 'Electronics', child: Text('Electronics')),
                  DropdownMenuItem(value: 'Books', child: Text('Books')),
                  DropdownMenuItem(value: 'Clothing', child: Text('Clothing')),
                  DropdownMenuItem(value: 'Accessories', child: Text('Accessories')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      giftCategory = value;
                    });
                  }
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price < 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
                onSaved: (value) => giftPrice = double.parse(value!),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Status:", style: TextStyle(fontSize: 18)),
                  DropdownButton<String>(
                    value: giftStatus,
                    items: const [
                      DropdownMenuItem(value: 'Available', child: Text('Available')),
                      DropdownMenuItem(value: 'Pledged', child: Text('Pledged')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          giftStatus = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: giftImage == null
                      ? const Center(child: Text("Tap to upload image"))
                      : Image.file(
                    File(giftImage!.path),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
