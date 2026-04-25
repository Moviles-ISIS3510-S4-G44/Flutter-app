import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:marketplace_flutter_application/data/domains/favorites/favorite_listings.dart';

class FavoritesDb {
  static const _dbName = 'favorites.db';
  static const _tableName = 'favorites';
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE $_tableName (
          id       TEXT PRIMARY KEY,
          title    TEXT NOT NULL,
          price    INTEGER NOT NULL,
          imageUrl TEXT NOT NULL,
          category TEXT NOT NULL,
          location TEXT
        )
      '''),
    );
  }

  Future<List<FavoriteListing>> getAll() async {
    final db = await database;
    final rows = await db.query(_tableName);
    return rows.map(FavoriteListing.fromMap).toList();
  }

  Future<bool> isFavorite(String id) async {
    final db = await database;
    final rows = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> insert(FavoriteListing listing) async {
    final db = await database;
    await db.insert(
      _tableName,
      listing.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(String id) async {
    final db = await database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}