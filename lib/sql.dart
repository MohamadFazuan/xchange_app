import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    String path = join(await getDatabasesPath(), 'xchange.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  static Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY,
            username TEXT NOT NULL,
            email TEXT NOT NULL,
            password TEXT NOT NULL
          )
        ''');
    await db.execute('''
          CREATE TABLE friends (
            id INTEGER PRIMARY KEY,
            user_id INTEGER NOT NULL,
            friend_id INTEGER NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id),
            FOREIGN KEY (friend_id) REFERENCES users (id)
          )
        ''');
    await db.execute('''
          CREATE TABLE cards (
            id INTEGER PRIMARY KEY,
            user_id INTEGER NOT NULL,
            card_number TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id)
          )
        ''');
  }

  static Future<void> register(String username, String email, String password) async {
    final db = await database;
    await db.insert('users', {
      'username': username,
      'email': email,
      'password': password,
    });
  }

  static Future<void> login(String email, String password) async {
    final db = await database;
    final user = await db.query('users', where: 'email = ? AND password = ?', whereArgs: [email, password]);
    if (user.isEmpty) {
      throw Exception('Invalid email or password');
    }
  }

  static Future<void> addFriend(int userId, int friendId) async {
    final db = await database;
    await db.insert('friends', {
      'user_id': userId,
      'friend_id': friendId,
    });
  }

  static Future<void> addCard(int userId, String cardNumber) async {
    final db = await database;
    await db.insert('cards', {
      'user_id': userId,
      'card_number': cardNumber,
    });
  }
}