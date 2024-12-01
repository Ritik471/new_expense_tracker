import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "ChatDatabase.db";
  static const _databaseVersion = 1;

  static const table = 'chat_messages';

  static const columnId = 'id';
  static const columnSenderId = 'sender_id';
  static const columnReceiverId = 'receiver_id';
  static const columnMessage = 'message';
  static const columnTimestamp = 'timestamp';
  static const columnIsSent = 'is_sent';
  static const columnIsDelivered = 'is_delivered';

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnSenderId TEXT NOT NULL,
        $columnReceiverId TEXT NOT NULL,
        $columnMessage TEXT NOT NULL,
        $columnTimestamp TEXT NOT NULL,
        $columnIsSent INTEGER DEFAULT 0,
        $columnIsDelivered INTEGER DEFAULT 0
      )
    ''');
  }


}
