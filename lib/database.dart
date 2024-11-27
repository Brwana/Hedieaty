import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<String> getDatabasePath() async {
  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'my_database.db');
  return path;
}
Future<Database> openDatabaseConnection() async {
  String path = await getDatabasePath();
  return openDatabase(
    path,
    version: 1, // Increment this if the schema changes
    onCreate: (Database db, int version) async {
      // This is where you create the table(s)
    },
  );
}

Future<Database> initializeDatabase() async {
  String path = join(await getDatabasesPath(), 'app_database.db');

  return openDatabase(
    path,
    version: 1,
    onCreate: (Database db, int version) async {
      // Create Users table
      await db.execute('''
        CREATE TABLE Users (
          ID INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT UNIQUE NOT NULL,
          preferences TEXT
        )
      ''');

      // Create Events table
      await db.execute('''
        CREATE TABLE Events (
          ID INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          date TEXT NOT NULL,
          location TEXT,
          description TEXT,
          userID INTEGER,
          FOREIGN KEY (userID) REFERENCES Users (ID)
        )
      ''');

      // Create Gifts table
      await db.execute('''
        CREATE TABLE Gifts (
          ID INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          category TEXT,
          price REAL,
          status TEXT,
          eventID INTEGER,
          FOREIGN KEY (eventID) REFERENCES Events (ID)
        )
      ''');

      // Create Friends table
      await db.execute('''
        CREATE TABLE Friends (
          userID INTEGER NOT NULL,
          friendID INTEGER NOT NULL,
          PRIMARY KEY (userID, friendID),
          FOREIGN KEY (userID) REFERENCES Users (ID),
          FOREIGN KEY (friendID) REFERENCES Users (ID)
        )
      ''');
    },
  );
}


