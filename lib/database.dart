import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ContactDatabase {
  static final ContactDatabase instance = ContactDatabase._init();

  static Database? _database;

  ContactDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('contacts.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
      CREATE TABLE contacts (
        id $idType,
        name $textType,
        email $textType,
        phone $textType
      )
    ''');
  }

  Future<void> createContact(Map<String, String> contact) async {
    final db = await instance.database;

    await db.insert(
      'contacts',
      contact,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateContact(int id, Map<String, String> contact) async {
    final db = await instance.database;

    await db.update(
      'contacts',
      contact,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteContact(int id) async {
    final db = await instance.database;

    await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> readAllContacts() async {
    final db = await instance.database;

    final result = await db.query('contacts');

    return result;
  }

  Future<void> close() async {
    final db = await instance.database;

    db.close();
  }
}
