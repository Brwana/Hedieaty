import 'package:flutter/material.dart';
import 'package:hedieaty/theme_data.dart';
import 'dart:io';

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
  File? giftImage;
  bool isPledged = false;

  void _selectLocalImage() {
    const imagePath = 'path/to/local/image.png';
    setState(() {
      giftImage = File(imagePath);
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
        title: Text("Gift Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveGift,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Gift Name',
                  labelStyle: TextStyle(fontFamily: "Caveat", color: Color(0xFFB03565),fontSize: 40)
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a gift name';
                  }
                  return null;
                },
                onSaved: (value) => giftName = value!,
                enabled: !isPledged,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                    labelStyle:
                    TextStyle(fontFamily: "Caveat", color: Color(0xFFB03565),fontSize: 40)
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) => giftDescription = value!,
                enabled: !isPledged,
              ),
              DropdownButtonFormField<String>(
                value: giftCategory,
                decoration: const InputDecoration(

                  labelText: 'Category',
                    labelStyle:
                    TextStyle(fontFamily: "Caveat", color: Color(0xFFB03565),fontSize: 40),
                ),
                items: const [
                  DropdownMenuItem(value: 'Electronics', child: Text('Electronics',
                    style:TextStyle(fontFamily: "Caveat", color: Color(0xFFB03565),fontSize: 20),)),
                  DropdownMenuItem(value: 'Books', child: Text('Books',
                    style:TextStyle(fontFamily: "Caveat", color: Color(0xFFB03565),fontSize: 20),)),
                  DropdownMenuItem(value: 'Clothing', child: Text('Clothing',
                    style:TextStyle(fontFamily: "Caveat", color: Color(0xFFB03565),fontSize: 20),)),
                  DropdownMenuItem(value: 'Accessories', child: Text('Accessories',
                    style:TextStyle(fontFamily: "Caveat", color: Color(0xFFB03565),fontSize: 20),)),
                ],
                onChanged: isPledged
                    ? null
                    : (value) {
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
                  labelStyle:
                  TextStyle(fontFamily: "Caveat", color: Color(0xFFB03565),fontSize: 40),
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
                enabled: !isPledged,
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Status:", style: TextStyle(fontSize: 40,fontFamily: "Caveat", color: Color(0xFFB03565)),)
      ,
                  DropdownButton<String>(
                    value: giftStatus,
                    items: const [
                      DropdownMenuItem(value: 'Available', child: Text('Available',
                        style:TextStyle(fontFamily: "Caveat", color: Color(0xFFB03565),fontSize: 40),)),
                      DropdownMenuItem(value: 'Pledged', child: Text('Pledged',
                        style:TextStyle(fontFamily: "Caveat", color: Color(0xFFB03565),fontSize: 40),)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          giftStatus = value;
                          isPledged = value == 'Pledged';
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              GestureDetector(
                onTap: _selectLocalImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: giftImage == null
                      ? const Center(child: Text("Tap to upload image",style: TextStyle(color: Color(0xFFB03565),
                  )
                    ,)
                    ,)
                      : Image.file(
                    giftImage!,
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
