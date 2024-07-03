import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLDB {
  static Database? _db;

  Future<Database?> get db async {
    if (_db == null) {
      _db = await initialdb();
      return _db;
    } else {
      return _db;
    }
  }

  var path;

  initialdb() async {
    var database = await getDatabasesPath();
    path = join(database, "check.db");
    var mydb = await openDatabase(path, onCreate: create, version: 3, onUpgrade: upgrade);
    print("database created");
    return mydb;
  }

  upgrade(Database db, int oldversion, int newversion) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS databasee (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        isBlock INTEGER DEFAULT 0
      )
    ''');
    print("CREATE WAS DONE");
    print("------------ upgrade -----------");
  }

  create(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS databasee (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        isBlock INTEGER DEFAULT 0
      )
    ''');
    print("CREATE WAS DONE");
  }

  Future<int?> insert(bool isblock) async {
    Database? mydb = await db;
    var res = await mydb?.insert('databasee', {
      'isBlock': isblock ? 1 : 0
    });
    print("inserted WAS DONE");
    return res;
  }

  Future<List<Map<String, dynamic>>?> read(String table) async {
    Database? mydb = await db;
    var res = await mydb?.query(table);
    print("readdata WAS DONE");
    return res;
  }

  Future<List<Map<String, dynamic>>?> readbyid(int id) async {
    Database? mydb = await db;
    var res = await mydb?.rawQuery("SELECT * FROM databasee WHERE id=$id");
    print("readdata WAS DONE");
    return res;
  }

   selectisblock() async {
    Database? mydb = await db;
    var res = await mydb?.rawQuery("SELECT isBlock FROM databasee");
    print("readdata WAS DONE");
    return res;
  }


  Future<int?> update_isblock(bool value) async {
    Database? mydb = await db;
    // Check if any record exists
    var count = Sqflite.firstIntValue(
        await mydb!.rawQuery('SELECT COUNT(*) FROM databasee'));
    if (count == 0) {
      // Insert if no record exists
      var res = await mydb.insert('databasee', {
        'isBlock': value ? 1 : 0,
      });
      print("inserted WAS DONE");
      return res;
    } else {
      // Update if record exists
      var res = await mydb.update(
          'databasee',
          {'isBlock': value ? 1 : 0},
          where: 'id = ?',
          whereArgs: [1] // Update this to match the correct record
      );
      print("updated WAS DONE");
      return res;
    }
  }

  Future<int?> update_isnotify(bool value) async {
    Database? mydb = await db;
    var res = await mydb?.update(
        'databasee',
        {'notificationsEnabled': value ? 1 : 0},
        where: 'id = ?',
        whereArgs: [1] // Update this to match the correct record
    );
    print("updated WAS DONE");
    return res;
  }
}
