import 'package:flutter/material.dart';
import 'package:hedieaty/theme_data.dart';
void main() {
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  final List<Map<String, String>> profiles = [
    {'name': 'Meiada', 'imageUrl': 'asset/pp_2.jpg','description':"no Upcoming Events"},
    {'name': 'JaneS', 'imageUrl': 'asset/pp_3.jpg','description':"no Upcoming Events"},
    {'name': 'Adele', 'imageUrl': 'asset/pp_4.jpg','description':"no Upcoming Events"},
    {'name': 'Brwana', 'imageUrl': 'asset/pp_5.jpg','description':"no Upcoming Events"},
    {'name': 'Farhan', 'imageUrl': 'asset/pp_6.jpg','description':"no Upcoming Events"},

  ];
@override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Hedieaty",
        theme: ThemeClass.lightTheme,
        home: Scaffold(appBar:AppBar(title:Text("Hedieaty"),),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: profiles.map((profile) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: AssetImage(profile['imageUrl']!),
                          ),
                          SizedBox(width: 10),
                          Text(
                            profile['name']!,
                            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold,color: Colors.pinkAccent),
                          ),
                        ],
                      ),
                      SizedBox(height: 5,), // Space between name and description
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0), // Shift description to the left
                        child: Text(
                          profile['description']!,
                          style: TextStyle(fontSize: 20, color: Colors.pinkAccent),
                        ),
                      ),

                    ],
                  ),
                );
            }).toList(),
          ),
        ),
        ),
    );


}
}
