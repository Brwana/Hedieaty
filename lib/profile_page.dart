import 'package:flutter/material.dart';
import 'package:hedieaty/theme_data.dart';

void main() {
  runApp(const MyProfile());
}

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final List<Map<String, dynamic>> events = [
    {'title': 'Birthday Party', 'gifts': ['Gift Card', 'Perfume']},
    {'title': 'Wedding Anniversary', 'gifts': ['Watch', 'Chocolates']},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Page"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Profile Picture with Edit Icon
          Center(
            child: Stack(
              children: [
                SizedBox(height: 20,),
                CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage("asset/pp_1.jpg"),
                ),
                // Edit Icon overlay
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      // Logic to edit profile picture
                      print("Edit Profile Picture tapped!");
                    },
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFFB03565),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Profile Name
          Padding(

            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Centers the content horizontally
              children: [
                Text(
                  'Brwana',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Lobster",
                  ),
                ),
                SizedBox(width: 1), // Adds some spacing between the text and the icon
                IconButton(
                  icon: Icon(Icons.edit, color: Color(0xFFB03565)),
                  onPressed: () {
                    // Add your edit action here
                  },
                ),
              ],
            ),
          ),

          // Events List
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Container(color: Colors.white,
                    child: ListTile(
                    title: Text(
                      event['title'],
                      style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold,fontFamily: "Caveat",color:Color(0xFFB03565) ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Associated Gifts:",style: TextStyle(fontFamily: "Caveat",fontSize: 30,color: Color(0xFFB03565)),),
                        ...event['gifts'].map((gift) => Text("• $gift",style: TextStyle(fontFamily: "Caveat",fontSize: 25,color: Color(0xFFB03565)),)).toList(),
                      ],
                    ),
                  ),
                  ),
                );
              },
            ),
          ),

          // Pledged Gifts Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {},
              child: Text("My Pledged Gifts", style: TextStyle(color: Color(0xFFB03565))),
            ),
          ),
        ],
      ),
    );
  }
}
