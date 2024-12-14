import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseClass {
  static Database? _myDatabase;

  Future<Database?> get myDatabase async {
    if (_myDatabase == null) {
      _myDatabase = await initialize();
      return _myDatabase;
    } else {
      return _myDatabase;
    }
  }

  int version = 1;

  initialize() async {
    String myPath = await getDatabasesPath();
    String path = join(myPath, 'myDatabase.db');

    Database myDb = await openDatabase(
      path,
      version: version,
      onCreate: (db, version) async {
        // Initial table creation
        await db.execute('''
        CREATE TABLE IF NOT EXISTS Users (
          ID TEXT NOT NULL PRIMARY KEY,
          Name TEXT NOT NULL,
          Email TEXT NOT NULL,
          Password TEXT NOT NULL,
          PhoneNumber TEXT NOT NULL
        )
      ''');

        await db.execute('''
        CREATE TABLE IF NOT EXISTS Events (
          ID TEXT NOT NULL PRIMARY KEY,
          Name TEXT NOT NULL,
          Date TEXT NOT NULL,
          Location TEXT NOT NULL,
          Description TEXT NOT NULL,
          UserID TEXT NOT NULL,
          FOREIGN KEY (UserID) REFERENCES Users (ID)
        )
      ''');

        await db.execute('''
        CREATE TABLE IF NOT EXISTS Gifts (
          ID TEXT NOT NULL PRIMARY KEY,
          Name TEXT NOT NULL,
          Description TEXT NOT NULL,
          Category TEXT NOT NULL,
          Price TEXT NOT NULL,
          Status TEXT NOT NULL,
          EventID TEXT NOT NULL,
          FOREIGN KEY (EventID) REFERENCES Events (ID)
        )
      ''');

        await db.execute('''
        CREATE TABLE IF NOT EXISTS Friends (
          UserID TEXT NOT NULL,
          FriendID TEXT NOT NULL,
          PRIMARY KEY (UserID, FriendID),
          FOREIGN KEY (UserID) REFERENCES Users (ID),
          FOREIGN KEY (FriendID) REFERENCES Users (ID)
        )
      ''');

        print("Database and tables have been created.");
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Handle migrations
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE Users ADD COLUMN PIN TEXT NOT NULL DEFAULT ''");
          print("Database upgraded to include PIN column in Users table.");
        }
      },
    );

    return myDb;
  }


  Future<List<Map<String, dynamic>>> readData(String sql) async {
    Database? myData = await myDatabase;
    var response = await myData!.rawQuery(sql);
    return response;
  }

  Future<int> insertData(String sql) async {
    Database? myData = await myDatabase;
    int response = await myData!.rawInsert(sql);
    return response;
  }

  Future<int> deleteData(String sql) async {
    Database? myData = await myDatabase;
    int response = await myData!.rawDelete(sql);
    return response;
  }

  Future<int> updateData(String sql) async {
    Database? myData = await myDatabase;
    int response = await myData!.rawUpdate(sql);
    return response;
  }

  Future<void> deleteDatabaseInstance() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'myDatabase.db');
    bool exists = await databaseExists(path);
    if (exists) {
      print('Database exists and will be deleted.');
      await deleteDatabase(path);
      print("Database has been deleted.");
    } else {
      print("Database does not exist.");
    }
  }
}
