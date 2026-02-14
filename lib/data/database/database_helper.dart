import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  //  Singleton حقيقي
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
    final path = join(databasesPath, "plant_doctorv4.db");

    //  أثناء التطوير فقط (للتأكد من التحديث)
    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    // احذف القاعدة القديمة
    await deleteDatabase(path);

    // انسخ القاعدة من assets
    await Directory(dirname(path)).create(recursive: true);

    ByteData data = await rootBundle.load("assets/database/plant_doctorv4.db");

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

  /// جلب جميع النباتات ضمن تصنيف معيّن مع الاسم + وصف قصير + صورة
  Future<List<Map<String, dynamic>>> getPlantsByCategoryCode({
    required String categoryCode,
    required String langCode,
  }) async {
    final db = await database;

    return await db.rawQuery(
      '''
    SELECT 
      p.code                AS plant_code,
      t.name                AS plant_name,
      t.description         AS plant_description,
      img.image_path        AS image_path
    FROM plants p
    JOIN plant_translations t 
      ON p.code = t.plant_code
     AND t.lang_code = ?
    LEFT JOIN plant_images img
      ON p.code = img.plant_code
     AND img.is_primary = 1
    WHERE p.category_code = ?
    ORDER BY t.name COLLATE NOCASE
    ''',
      [langCode, categoryCode],
    );
  }

  Future<Map<String, dynamic>?> getPlantFullDetails({
    required String plantCode,
    required String langCode,
    String countryCode = 'LY',
  }) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
  SELECT 
    p.code AS plant_code,
    t.name AS plant_name,
    t.description AS plant_description,

    CASE WHEN ? = 'ar' THEN tx.kingdom_ar     ELSE tx.kingdom     END AS kingdom,
    CASE WHEN ? = 'ar' THEN tx.phylum_ar      ELSE tx.phylum      END AS phylum,
    CASE WHEN ? = 'ar' THEN tx.class_ar       ELSE tx.class       END AS class,
    CASE WHEN ? = 'ar' THEN tx.plant_order_ar ELSE tx.plant_order END AS plant_order,
    CASE WHEN ? = 'ar' THEN tx.family_ar      ELSE tx.family_code END AS family,
    CASE WHEN ? = 'ar' THEN tx.genus_ar       ELSE tx.genus       END AS genus,

    img.image_path,
    ci.growth_regions,
    ci.notes AS country_notes,

    pc.min_temp,
    pc.max_temp,
    pc.soil,
    pc.sunlight,
    pc.watering,
    pc.care_tips,

    tr.notes AS treatment_notes

  FROM plants p
  JOIN plant_translations t 
    ON p.code = t.plant_code
   AND t.lang_code = ?

  LEFT JOIN plant_taxonomy tx
    ON p.taxonomy_id = tx.id

  LEFT JOIN plant_images img
    ON p.code = img.plant_code
   AND img.is_primary = 1

  LEFT JOIN plant_country_info ci
    ON p.code = ci.plant_code
   AND ci.lang_code = ?
   AND ci.country_code = ?

  LEFT JOIN plant_care pc
    ON p.code = pc.plant_code
   AND pc.lang_code = ?
   AND pc.country_code = ?

  LEFT JOIN treatments tr
    ON p.code = tr.plant_code
   AND tr.lang_code = ?
   AND tr.country_code = ?

  WHERE p.code = ?
  LIMIT 1
  ''',
      [
        // CASE taxonomy (6 مرات)
        langCode, // kingdom
        langCode, // phylum
        langCode, // class
        langCode, // plant_order
        langCode, // family
        langCode, // genus

        langCode, // plant_translations
        langCode, // plant_country_info
        countryCode,
        langCode, // plant_care
        countryCode,
        langCode, // treatments
        countryCode,
        plantCode,
      ],
    );

    if (result.isEmpty) return null;
    return result.first;
  }

  Future<List<Map<String, dynamic>>> getDiseaseNamesWithImages({
    required String plantCode,
    required String langCode,
  }) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
    SELECT
      d.code        AS disease_code,
      dt.name       AS disease_name,
      di.image_path AS image_path
    FROM diseases d

    JOIN disease_translations dt
      ON d.code = dt.disease_code
     AND d.plant_code = dt.plant_code
     AND dt.lang_code = ?

    LEFT JOIN disease_images di
      ON d.code = di.disease_code
     AND d.plant_code = di.plant_code

    WHERE d.plant_code = ?
    ORDER BY d.code
    ''',
      [langCode, plantCode],
    );

    return result;
  }

  Future<Map<String, dynamic>?> getDiseaseFullDetails({
    required String diseaseCode,
    required String plantCode,
    required String langCode,
    String countryCode = 'LY',
  }) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
    SELECT
      d.code                AS disease_code,
      dt.name               AS disease_name,
      dt.description        AS disease_description,

      di.image_path         AS image_path,

      tr.treatment,
      tr.prevention,
      tr.notes,

      pt.name               AS plant_name

    FROM diseases d

    JOIN disease_translations dt
      ON d.code = dt.disease_code
     AND d.plant_code = dt.plant_code
     AND dt.lang_code = ?

    LEFT JOIN disease_images di
      ON d.code = di.disease_code
     AND d.plant_code = di.plant_code

    LEFT JOIN treatments tr
      ON d.code = tr.disease_code
     AND d.plant_code = tr.plant_code
     AND tr.lang_code = ?
     AND tr.country_code = ?

    JOIN plant_translations pt
      ON pt.plant_code = d.plant_code
     AND pt.lang_code = ?

    WHERE d.code = ?
      AND d.plant_code = ?
    LIMIT 1
    ''',
      [langCode, langCode, countryCode, langCode, diseaseCode, plantCode],
    );

    if (result.isEmpty) return null;
    return result.first;
  }

  Future<List<Map<String, dynamic>>> getRandomDiseases({
    required String langCode,
    int limit = 6,
  }) async {
    final db = await database;

    return await db.rawQuery(
      '''
    SELECT
      d.code        AS disease_code,
      d.plant_code AS plant_code,
      dt.name      AS disease_name,
      di.image_path
    FROM diseases d
    JOIN disease_translations dt
      ON d.code = dt.disease_code
     AND d.plant_code = dt.plant_code
     AND dt.lang_code = ?
    LEFT JOIN disease_images di
      ON d.code = di.disease_code
     AND d.plant_code = di.plant_code
    ORDER BY RANDOM()
    LIMIT ?
    ''',
      [langCode, limit],
    );
  }

  Future<List<Map<String, dynamic>>> searchDiseases({
    required String query,
    required String langCode,
  }) async {
    final db = await database;

    return await db.rawQuery(
      '''
    SELECT DISTINCT
      d.code AS disease_code,
      d.plant_code,
      dt.name AS disease_name,
      di.image_path
    FROM diseases d
    JOIN disease_translations dt
      ON d.code = dt.disease_code
     AND d.plant_code = dt.plant_code
     AND dt.lang_code = ?
    LEFT JOIN disease_images di
      ON d.code = di.disease_code
     AND d.plant_code = di.plant_code
    JOIN plant_translations pt
      ON pt.plant_code = d.plant_code
     AND pt.lang_code = ?
    WHERE
      dt.name LIKE ?
      OR dt.description LIKE ?
      OR pt.name LIKE ?
    ORDER BY dt.name
    ''',
      [langCode, langCode, '%$query%', '%$query%', '%$query%'],
    );
  }
}
