import 'package:cloud_firestore/cloud_firestore.dart';
import 'database.dart';
import 'package:firebase_auth/firebase_auth.dart';// SQLite database handler

class DataSyncService {
  final DatabaseClass databaseHelper = DatabaseClass();

  Future<void> syncFirestoreToSQLite(String userId) async {
    try {
      // 1. Sync User Data
      // Fetch all users from Firestore
      final userCollection = FirebaseFirestore.instance.collection('users');
      final querySnapshot = await userCollection.get();

      for (var doc in querySnapshot.docs) {
        final userId = doc.id; // User's ID from Firestore
        final userData = doc.data(); // User data

        if (userData != null) {
          // Insert or update the user data in SQLite
          await databaseHelper.insertData('''
          INSERT OR REPLACE INTO Users (ID, Name, Email, Password ,PhoneNumber)
          VALUES (
            '${userId}', 
            '${userData['fullName']}', 
            '${userData['email']}',
            '${userData['password']}',
            '${userData['phoneNumber']}'
          );
        ''');
        }
      }

      // 2. Sync Friends
      final friendsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('friends')
          .get();
      for (var doc in friendsSnapshot.docs) {
        final friend = doc.data();
        await databaseHelper.insertData('''
        INSERT OR REPLACE INTO Friends (UserID, FriendID)
        VALUES (
          '${userId}', 
          '${doc.id}'
        );
      ''');

      }

      // 3. Sync Events
      final eventsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('events')
          .get();
      for (var doc in eventsSnapshot.docs) {
        final event = doc.data();
        await databaseHelper.insertData('''
        INSERT OR REPLACE INTO Events (ID, Name, Date, Location, Description, UserID)
        VALUES (
          '${doc.id}', 
          '${event['name']}', 
          '${event['date']}', 
          '${event['location']}', 
          '${event['description']}', 
          '${userId}'
        );
      ''');
        print('Syncing event: ${doc.id} -> ${event['name']}');
      }

      // 4. Sync Gifts
      for (var eventDoc in eventsSnapshot.docs) {
        final giftsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('events')
            .doc(eventDoc.id)
            .collection('gifts')
            .get();
        for (var giftDoc in giftsSnapshot.docs) {
          final gift = giftDoc.data();
          await databaseHelper.insertData('''
          INSERT OR REPLACE INTO Gifts (ID, Name, Description, Category, Price, Status, EventID)
          VALUES (
            '${giftDoc.id}', 
            '${gift['name']}', 
            '${gift['description']}', 
            '${gift['category']}', 
            ${gift['price']}, 
            '${gift['status']}', 
            '${eventDoc.id}'
          );
        ''');
          print('Syncing gift: ${giftDoc.id} -> ${gift['name']}');

        }

      }


    } catch (e) {
      print('Error syncing Firestore to SQLite: $e');
      // _showErrorDialog('Failed to sync data. Please try again.');
    }
  }

  Future<void> queryAndPrintTable(String tableName) async {
    final result = await databaseHelper.readData('SELECT * FROM $tableName');
    print('Table $tableName: $result');
  }




}
// void _showErrorDialog(String message) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(content: Text(message)),
//   );
// }
