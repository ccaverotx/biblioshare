import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'local_review.dart';
import 'local_saved_books.dart';

class LocalDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'biblio_share.db');

    return await openDatabase(
      path,
      version: 4, // ⬅️ Versión incrementada
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE local_reviews (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            bookId TEXT,
            content TEXT,
            createdAt TEXT,
            userId TEXT,
            rating INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE saved_books (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            author TEXT,
            publishedYear INTEGER,
            coverUrl TEXT,
            savedAt TEXT,
            userId TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
              'ALTER TABLE local_reviews ADD COLUMN rating INTEGER DEFAULT 0');
        }
        if (oldVersion < 3) {
          await db.execute('DROP TABLE IF EXISTS saved_books');
          await db.execute('''
            CREATE TABLE saved_books (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT,
              author TEXT,
              publishedYear INTEGER,
              coverUrl TEXT,
              savedAt TEXT,
              userId TEXT
            )
          ''');
        }
        if (oldVersion < 4) {
          await db.execute(
              'ALTER TABLE saved_books ADD COLUMN userId TEXT'); // Para migración suave
        }
      },
    );
  }

  // 📝 Reseñas
  static Future<void> insertReview(LocalReview review) async {
    final db = await database;
    await db.insert('local_reviews', review.toMap());
  }

  static Future<List<LocalReview>> getAllReviews() async {
    final db = await database;
    final maps = await db.query('local_reviews', orderBy: 'createdAt DESC');
    return maps.map((map) => LocalReview.fromMap(map)).toList();
  }

  static Future<void> deleteReview(int id) async {
    final db = await database;
    await db.delete('local_reviews', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearAllReviews() async {
    final db = await database;
    await db.delete('local_reviews');
  }

  static Future<void> updateReview(int id, String newContent) async {
    final db = await database;
    await db.update(
      'local_reviews',
      {'content': newContent},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> updateReviewContentAndRating({
    required int id,
    required String newContent,
    required int newRating,
  }) async {
    final db = await database;
    await db.update(
      'local_reviews',
      {
        'content': newContent,
        'rating': newRating,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 📚 Libros guardados
  static Future<void> insertSavedBook(LocalSavedBook book) async {
    final db = await database;
    await db.insert(
      'saved_books',
      book.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<LocalSavedBook>> getSavedBooks() async {
    final db = await database;
    final maps = await db.query('saved_books', orderBy: 'savedAt DESC');
    return maps.map((map) => LocalSavedBook.fromMap(map)).toList();
  }

  static Future<List<LocalSavedBook>> getSavedBooksForUser(
      String userId) async {
    final db = await database;
    final maps = await db.query(
      'saved_books',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'savedAt DESC',
    );
    return maps.map((map) => LocalSavedBook.fromMap(map)).toList();
  }

  static Future<void> deleteSavedBook(int id) async {
    final db = await database;
    await db.delete('saved_books', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearAllSavedBooks() async {
    final db = await database;
    await db.delete('saved_books');
  }
}
