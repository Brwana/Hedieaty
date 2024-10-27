import 'package:flutter/material.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final List<Map<String, dynamic>> events = [
    {'name': 'Birthday Party', 'category': 'Personal', 'status': 'Upcoming'},
    {'name': 'Conference', 'category': 'Work', 'status': 'Current'},
    {'name': 'Anniversary', 'category': 'Personal', 'status': 'Past'},
    {'name': 'Team Meeting', 'category': 'Work', 'status': 'Upcoming'},
  ];

  late List<Map<String, dynamic>> filteredEvents;
  String _sortBy = 'name';

  @override
  void initState() {
    super.initState();
    filteredEvents = List.from(events);
  }

  void _sortEvents(String criteria) {
    setState(() {
      _sortBy = criteria;
      filteredEvents.sort((a, b) => a[criteria].compareTo(b[criteria]));
    });
  }

  void _addEvent() {
    // Logic to add a new event
    print("Add Event button tapped!");
  }

  void _editEvent(int index) {
    // Logic to edit an event
    print("Edit Event button tapped for ${filteredEvents[index]['name']}!");
  }

  void _deleteEvent(int index) {
    setState(() {
      filteredEvents.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addEvent,
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
                    DropdownMenuItem(value: 'name', child: Text("Name",
                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,fontFamily: "Caveat",color: Color(0xFFB03565),),)),
                    DropdownMenuItem(value: 'category', child: Text("Category",
                        style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,fontFamily: "Caveat",color: Color(0xFFB03565),),),),
                    DropdownMenuItem(value: 'status', child: Text("Status"
                        ,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,fontFamily: "Caveat",color: Color(0xFFB03565)),),)
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _sortEvents(value);
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                return ListTile(
                  title: Text(
                    event['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold,fontFamily: "Caveat",
                        fontSize: 30,color: Color(0xFFB03565),),
                      ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Category: ${event['category']}",
                        style: TextStyle(fontFamily: "Caveat",fontSize: 30,color: Color(0xFFB03565)),),
                      Text("Status: ${event['status']}",
                          style: TextStyle(fontFamily: "Caveat",fontSize: 30,color: Color(0xFFB03565))),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFFB03565)),
                        onPressed: () => _editEvent(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.black54),
                        onPressed: () => _deleteEvent(index),
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
