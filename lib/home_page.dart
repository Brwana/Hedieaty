import 'package:flutter/material.dart';
import 'package:hedieaty/theme_data.dart';
import 'package:hedieaty/profile_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> profiles = [
    {
      'name': 'Meiada',
      'imageUrl': 'asset/pp_2.jpg',
      'description': "No Upcoming Events",
      'eventCount': 0
    },
    {
      'name': 'JaneS',
      'imageUrl': 'asset/pp_3.jpg',
      'description': "Upcoming Events: 1",
      'eventCount': 1
    },
    {
      'name': 'Adele',
      'imageUrl': 'asset/pp_4.jpg',
      'description': "No Upcoming Events",
      'eventCount': 0
    },
    {
      'name': 'Brwana',
      'imageUrl': 'asset/pp_5.jpg',
      'description': "Upcoming Events: 2",
      'eventCount': 2
    },
    {
      'name': 'Farhan',
      'imageUrl': 'asset/pp_6.jpg',
      'description': "No Upcoming Events",
      'eventCount': 0
    },
  ];

  late List<Map<String, dynamic>> filteredProfiles;


  @override
  void initState() {
    super.initState();
    filteredProfiles = profiles;
  }

  void _filterFriends(String query) {
    setState(() {
      filteredProfiles = profiles.where((profile) =>
          profile['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _navigateToGiftList(String friendName) {
    // Add navigation logic to a gift list page here
    print("Navigating to $friendName's gift list...");
  }

  void _addFriend() {
    // Logic to add friends via phone numbers or from contact list goes here
    print("Add Friend button tapped!");
  }

  void _createNewEventOrList() {
    // Logic to create a new event or gift list goes here
    print("Create New Event/List button tapped!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hedieaty"),
        actions: [

          Padding(
            padding: const EdgeInsets.only(right: 8.0), // Add small padding to the right
            child:   IconButton(
                icon: Icon(Icons.account_circle, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, '/Profile');
                } // Profile icon// Replace with the function to open the profile
            ),

          ),


        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 25.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      prefixIconColor: Color(0xFF960944),
                      hintText: 'Search friends...',
                      hintStyle: TextStyle(color: Color(0xFF960944)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.person_add, color: Colors.pink),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProfiles.length,
              itemBuilder: (context, index) {
                final profile = filteredProfiles[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(profile['imageUrl']),
                  ),
                  title: GestureDetector(
                    onTap: () => _navigateToGiftList(profile['name']),
                    child: Text(
                      profile['name'],
                      style: TextStyle(fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(
                              0xFFB03565)),
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Icon(Icons.event, color: Color(0xFFB03565)),
                      SizedBox(width: 5),
                      Text(profile['eventCount'] > 0
                          ? "Upcoming Events: ${profile['eventCount']}"
                          : "No Upcoming Events", style: TextStyle(color: Color(
                          0xFFB03565)),),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: (){Navigator.pushNamed(context, '/EventList');},
              child: Text(
                "Show Event List", style: TextStyle(color: Color(
                  0xFFB03565)),),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: (){Navigator.pushNamed(context, '/GiftList');},
              child: Text(
                "Show Gift List", style: TextStyle(color: Color(
                  0xFFB03565)),),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: (){Navigator.pushNamed(context, '/GiftDetailsList');},
              child: Text(
                "Show Gift Details List", style: TextStyle(color: Color(
                  0xFFB03565)),),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _createNewEventOrList,
              child: Text(
                "Create Your Own Event/List", style: TextStyle(color: Color(
                  0xFFB03565)),),
            ),
          ),

        ],
      ),
    );
  }
}