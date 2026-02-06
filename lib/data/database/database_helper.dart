import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // 🔒 Singleton حقيقي
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "plant_doctorv2.db");

    // ⚠️ أثناء التطوير فقط (للتأكد من التحديث)
    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    // احذف القاعدة القديمة
    await deleteDatabase(path);

    // انسخ القاعدة من assets
    await Directory(dirname(path)).create(recursive: true);

    ByteData data = await rootBundle.load("assets/database/plant_doctorv2.db");

    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );

    await File(path).writeAsBytes(bytes, flush: true);

    return await openDatabase(path);
  }

  // جلب الأصناف حسب اللغة
  Future<List<Map<String, dynamic>>> getCategories(String langCode) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT c.code, c.icon, t.name, t.description 
      FROM plant_categories c
      JOIN plant_category_translations t 
        ON c.code = t.category_code
      WHERE t.lang_code = ?
      ''',
      [langCode],
    );
  }
}
