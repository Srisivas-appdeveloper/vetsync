import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'schema_v3_2_0.dart';

class SQLiteService {
  static const int DATABASE_VERSION = 4;
  static const String DATABASE_NAME = 'vetsync_clinical.db';

  static final SQLiteService _instance = SQLiteService._internal();

  factory SQLiteService() => _instance;

  SQLiteService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, DATABASE_NAME);

    return await openDatabase(
      path,
      version: DATABASE_VERSION,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Basic tables creation if starting from scratch
    // Assuming implicit previous versions 1-3 existed, but we can't recreate them perfectly without code.
    // However, v3.2.0 migration might catch up if designed well, or this is a fresh install.
    // For now, we will allow onUpgrade to handle migrations if possible, or initialize basic structure here.
    // Given we don't have v1-3 schema, we will try to run the v3.2.0 migration which creates tables IF NOT EXISTS.

    // We will simulate a migration from 0 to 4
    await SchemaV3_2_0.migrate(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('[SQLite] Upgrading from $oldVersion to $newVersion');

    if (oldVersion < 4) {
      await SchemaV3_2_0.migrate(db);
    }
  }
}
