import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
class SQLDB{
  static Database? _db;
  Future<Database?> get db async{
    if(_db==null){
      _db=await initialdb();
      return _db;
    }else{
      return _db;
    }
  }
  var path;
  initialdb()async{
    // sqfliteFfiInit();
    var database=await getDatabasesPath();
    // path=join(database,"chatbot.db");
    path=join(database,"check.db");
    var mydb=await openDatabase(path,onCreate: create,version:2,onUpgrade: upgrade);
    print("database created");
    return mydb;
  }
  upgrade(Database db,int oldversion,int newversion)async{
    await db.execute('''
     CREATE TABLE 'checklist'(
     'exsit' BOOLEAN
      )
     ''');
    // inserttable();
    print("CREATE WAS DONE");
    print("------------ upgrade -----------");
  }
  create(Database db,int version)async{
    await db.execute('''
     CREATE TABLE 'chatbot'(
     'content' TEXT,
     'time' TEXT,
     'role' TEXT
      )
     ''');
    // inserttable();
    print("CREATE WAS DONE");

  }
  insert(var content)async{
    Database? mydb=await db;
    // var res= await mydb?.insert('chatbot', {
    //   "content":content,
    //   'time':time,
    //   'role':role,
    // });
    var res= await mydb?.insert('checklist', {
      "exist":content,
    });
    print("inserted WAS DONE");
    return res;
  }
  read(String table)async{
    Database? mydb=await db;
    var res= await mydb?.query(table);
    print("readdata WAS DONE");
    return res;
  }readbyid(int id)async{
    Database? mydb=await db;
    var res= await mydb?.rawQuery("SELECT * FROM chatbot WHERE id=$id");
    print("readdata WAS DONE");
    return res;
  }selectimg(int id)async{
    Database? mydb=await db;
    var res= await mydb?.rawQuery("SELECT image FROM chatbot WHERE id=$id");
    print("readdata WAS DONE");
    return res;
  }selectuser()async{
    Database? mydb=await db;
    var res= await mydb?.rawQuery("SELECT user FROM chatbot");
    print("readdata WAS DONE");
    return res;
  }selectphone()async{
    Database? mydb=await db;
    var res= await mydb?.rawQuery("SELECT phone FROM chatbot");
    print("seleced WAS DONE");
    return res;
  }selectstored()async{
    Database? mydb=await db;
    var res= await mydb?.rawQuery("SELECT exsit FROM checklist");
    print("seleced WAS DONE");
    return res;
  }
  update(var value)async{
    Database? mydb=await db;
    var res= await mydb?.update('checklist',value );
    // var res= await mydb?.rawUpdate(sql);
    print("updated WAS DONE");
    return res;
  } updatetoall(var value)async{
    Database? mydb=await db;
    var res= await mydb?.update('chatbot',value,);
    // var res= await mydb?.rawUpdate(sql);
    print("updated WAS DONE");
    return res;
  }
  delete(int id)async{
    Database? mydb=await db;
    var res= await mydb?.delete("chatbot",where: "id=$id");
    print("DELETE WAS DONE");
    return res;
  }
  mydeletedatabase()async{
    var database=await getDatabasesPath();
    path=join(database,"untitle3.db");
    await deleteDatabase(path);
    print("database deleted");
  }
}