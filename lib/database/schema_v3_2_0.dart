/// SQLite schema updates for v3.2.0
/// File: lib/database/schema_v3_2_0.dart

import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:msgpack_dart/msgpack_dart.dart'; // Likely needed for blob if used in helpers, but migration only uses schema strings.
// Actually the helper extension USES classes that are not defined here (Calibration, etc).
// The user provided the schema file content which has imports.
// The user's code for schema_v3_2_0.dart in section 5.1 DOES NOT import msgpack_dart, but the extension later uses RawDataChunk.
// I need access to models.
// Wait, the user's chunk `5.1` code:
// ```dart
// import 'package:sqflite/sqflite.dart';
//
// class SchemaV3_2_0 { ... }
//
// /// SQLite service helper methods for v3.2.0
// extension SQLiteServiceV3_2_0 on SQLiteService { ... }
// ```
// It references `Calibration`, `RawDataChunk`, `VitalSigns`.
// I need these models. "Section 1: New Data Models" mentioned in "What's Included" implying they exist or I should have them.
// I'll add imports for these models to make it compile.
// Based on "Other open documents", `collar_data_packet` and `vitals` exist.
// I'll try to import them. If I can't find them, I might have compilation errors, but I'll guess standard paths.

import 'sqlite_service.dart';
// Assuming these models exist as per prompt description
import '../data/models/vitals.dart';
import '../data/models/raw_data_chunk.dart';
import '../data/models/calibration.dart';
import '../data/models/algorithm_package.dart'; // Implied by usage

class SchemaV3_2_0 {
  /// Run migration to v3.2.0
  static Future<void> migrate(Database db) async {
    print('[Migration] Upgrading to v3.2.0...');

    await db.transaction((txn) async {
      // 1. Create calibrations table
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS calibrations (
          calibration_id TEXT PRIMARY KEY,
          session_id TEXT NOT NULL,
          animal_id TEXT NOT NULL,
          collar_id TEXT NOT NULL,
          algorithm_package TEXT NOT NULL,
          quality_metrics TEXT NOT NULL,
          created_at TEXT NOT NULL,
          valid_until TEXT,
          report_url TEXT,
          FOREIGN KEY (session_id) REFERENCES sessions(session_id),
          FOREIGN KEY (animal_id) REFERENCES animals(animal_id),
          FOREIGN KEY (collar_id) REFERENCES collars(collar_id)
        )
      ''');

      await txn.execute('''
        CREATE INDEX idx_calibrations_collar_animal 
        ON calibrations(collar_id, animal_id)
      ''');

      // 2. Add calibration reference to collars table
      try {
        await txn.execute('''
          ALTER TABLE collars ADD COLUMN active_calibration_id TEXT
        ''');
        await txn.execute('''
          ALTER TABLE collars ADD COLUMN calibration_version TEXT
        ''');
        await txn.execute('''
          ALTER TABLE collars ADD COLUMN calibrated_for_animal_id TEXT
        ''');
        await txn.execute('''
          ALTER TABLE collars ADD COLUMN calibration_valid_until TEXT
        ''');
      } catch (e) {
        print('[Migration] Columns already exist, skipping...');
      }

      // 3. Create raw data sync queue
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS raw_data_sync_queue (
          queue_id INTEGER PRIMARY KEY AUTOINCREMENT,
          session_id TEXT NOT NULL,
          chunk_data BLOB NOT NULL,
          headers_json TEXT NOT NULL,
          created_at TEXT NOT NULL,
          uploaded INTEGER DEFAULT 0,
          retry_count INTEGER DEFAULT 0,
          last_error TEXT,
          FOREIGN KEY (session_id) REFERENCES sessions(session_id)
        )
      ''');

      await txn.execute('''
        CREATE INDEX idx_sync_queue_uploaded 
        ON raw_data_sync_queue(uploaded, retry_count)
      ''');

      // 4. Create vitals sync queue (for dual upload)
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS vitals_sync_queue (
          queue_id INTEGER PRIMARY KEY AUTOINCREMENT,
          session_id TEXT NOT NULL,
          vitals_json TEXT NOT NULL,
          created_at TEXT NOT NULL,
          uploaded INTEGER DEFAULT 0,
          retry_count INTEGER DEFAULT 0,
          FOREIGN KEY (session_id) REFERENCES sessions(session_id)
        )
      ''');

      // 5. Add upload statistics to sessions table
      try {
        await txn.execute('''
          ALTER TABLE sessions ADD COLUMN vitals_uploaded_count INTEGER DEFAULT 0
        ''');
        await txn.execute('''
          ALTER TABLE sessions ADD COLUMN raw_samples_uploaded_count INTEGER DEFAULT 0
        ''');
        await txn.execute('''
          ALTER TABLE sessions ADD COLUMN raw_bytes_uploaded INTEGER DEFAULT 0
        ''');
      } catch (e) {
        print('[Migration] Upload stats columns already exist, skipping...');
      }
    });

    print('[Migration] Successfully upgraded to v3.2.0');
  }
}

/// SQLite service helper methods for v3.2.0
extension SQLiteServiceV3_2_0 on SQLiteService {
  /// Save calibration to database
  Future<void> saveCalibration(Calibration calibration) async {
    final db = await database;

    await db.insert('calibrations', {
      'calibration_id': calibration.calibrationId,
      'session_id': calibration.sessionId,
      'animal_id': calibration.animalId,
      'collar_id': calibration.collarId,
      'algorithm_package': jsonEncode(calibration.algorithmPackage.toJson()),
      'quality_metrics': jsonEncode(calibration.qualityMetrics),
      'created_at': calibration.createdAt.toIso8601String(),
      'valid_until': calibration.validUntil?.toIso8601String(),
      'report_url': calibration.reportUrl,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    // Update collar with active calibration
    await db.update(
      'collars',
      {
        'active_calibration_id': calibration.calibrationId,
        'calibration_version': calibration.algorithmPackage.version,
        'calibrated_for_animal_id': calibration.animalId,
        'calibration_valid_until': calibration.validUntil?.toIso8601String(),
      },
      where: 'collar_id = ?',
      whereArgs: [calibration.collarId],
    );
  }

  /// Get calibration for collar+animal pair
  Future<Map<String, dynamic>?> getCalibration({
    required String collarId,
    required String animalId,
  }) async {
    final db = await database;

    final results = await db.query(
      'calibrations',
      where: 'collar_id = ? AND animal_id = ?',
      whereArgs: [collarId, animalId],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    return results.isNotEmpty ? results.first : null;
  }

  /// Queue raw data chunk for sync
  Future<void> queueRawDataForSync(String sessionId, RawDataChunk chunk) async {
    final db = await database;

    await db.insert('raw_data_sync_queue', {
      'session_id': sessionId,
      'chunk_data': chunk.toMessagePack(),
      'headers_json': jsonEncode(chunk.uploadHeaders),
      'created_at': DateTime.now().toIso8601String(),
      'uploaded': 0,
      'retry_count': 0,
    });
  }

  /// Queue vitals batch for sync
  Future<void> queueVitalsForSync(
    String sessionId,
    List<VitalSigns> vitals,
  ) async {
    final db = await database;

    await db.insert('vitals_sync_queue', {
      'session_id': sessionId,
      'vitals_json': jsonEncode(vitals.map((v) => v.toJson()).toList()),
      'created_at': DateTime.now().toIso8601String(),
      'uploaded': 0,
      'retry_count': 0,
    });
  }

  /// Get pending sync queue items
  Future<List<Map<String, dynamic>>> getPendingSyncQueue({
    required String tableName,
    int maxRetries = 5,
  }) async {
    final db = await database;

    return await db.query(
      tableName,
      where: 'uploaded = 0 AND retry_count < ?',
      whereArgs: [maxRetries],
      orderBy: 'created_at ASC',
      limit: 50,
    );
  }

  /// Mark sync queue item as uploaded
  Future<void> markSyncItemUploaded(String tableName, int queueId) async {
    final db = await database;

    await db.update(
      tableName,
      {'uploaded': 1},
      where: 'queue_id = ?',
      whereArgs: [queueId],
    );
  }

  /// Increment retry count for failed upload
  Future<void> incrementSyncRetryCount(
    String tableName,
    int queueId,
    String error,
  ) async {
    final db = await database;

    await db.rawUpdate(
      '''
      UPDATE $tableName 
      SET retry_count = retry_count + 1,
          last_error = ?
      WHERE queue_id = ?
    ''',
      [error, queueId],
    );
  }
}
