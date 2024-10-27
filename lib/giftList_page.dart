import 'package:flutter/material.dart';
import 'package:hedieaty/theme_data.dart';


class GiftListPage extends StatefulWidget {
  const GiftListPage({super.key});

  @override
  State<GiftListPage> createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  final List<Map<String, dynamic>> gifts = [
    {'name': 'Watch', 'category': 'Accessories', 'status': 'Available', 'pledged': false},
    {'name': 'Book', 'category': 'Education', 'status': 'Pledged', 'pledged': true},
    {'name': 'Game Console', 'category': 'Electronics', 'status': 'Available', 'pledged': false},
    {'name': 'Gift Card', 'category': 'Finance', 'status': 'Pledged', 'pledged': true},
  ];

  late List<Map<String, dynamic>> filteredGifts;
  String _sortBy = 'name';

  @override
  void initState() {
    super.initState();
    filteredGifts = List.from(gifts);
  }

  void _sortGifts(String criteria) {
    setState(() {
      _sortBy = criteria;
      filteredGifts.sort((a, b) => a[criteria].compareTo(b[criteria]));
    });
  }

  void _addGift() {
    // Logic to add a new gift
    print("Add Gift button tapped!");
  }

  void _editGift(int index) {
    // Logic to edit a gift
    print("Edit Gift button tapped for ${filteredGifts[index]['name']}!");
  }

  void _deleteGift(int index) {
    setState(() {
      filteredGifts.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gift List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addGift,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(
                      value: 'name',
                      child: Text("Name", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: "Caveat", color: Color(0xFFB03565))),
                    ),
                    DropdownMenuItem(
                      value: 'category',
                      child: Text("Category", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: "Caveat", color: Color(0xFFB03565))),
                    ),
                    DropdownMenuItem(
                      value: 'status',
                      child: Text("Status", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: "Caveat", color: Color(0xFFB03565))),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _sortGifts(value);
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredGifts.length,
              itemBuilder: (context, index) {
                final gift = filteredGifts[index];
                final isPledged = gift['pledged'];
                return ListTile(
                  title: Text(
                    gift['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "Caveat",
                      fontSize: 30,
                      color: isPledged ? Colors.grey : Color(0xFFB03565),
                      decoration: isPledged ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Category: ${gift['category']}",
                        style: TextStyle(fontFamily: "Caveat", fontSize: 30, color: Color(0xFFB03565)),
                      ),
                      Text(
                        "Status: ${gift['status']}",
                        style: TextStyle(fontFamily: "Caveat", fontSize: 30, color: Color(0xFFB03565)),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFFB03565)),
                        onPressed: () => _editGift(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.black54),
                        onPressed: () => _deleteGift(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
