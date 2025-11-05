import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../utils/app_logger.dart';
import '../models/location_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database1;
  static Database? _database2;

  DatabaseHelper._init();

  Future<Database> get database1 async {
    if (_database1 != null) return _database1!;
    appLogger.i('Initializing DB1: locations1.db');
    _database1 = await _initDB('locations1.db');
    return _database1!;
  }

  Future<Database> get database2 async {
    if (_database2 != null) return _database2!;
    appLogger.i('Initializing DB2: locations2.db');
    _database2 = await _initDB('locations2.db');
    return _database2!;
  }

  Future<Database> _initDB(String fileName) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, fileName);
      return await openDatabase(path, version: 1, onCreate: _createDB);
    } catch (e) {
      appLogger.e('Error initializing database $fileName: $e');
      rethrow;
    }
  }

  Future<void> _createDB(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE locations (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          timestamp TEXT NOT NULL,
          synced INTEGER DEFAULT 0
        )
      ''');
      appLogger.i('Table "locations" created successfully.');
    } catch (e) {
      appLogger.e('Error creating table: $e');
      rethrow;
    }
  }

  Future<void> initializeDatabases() async {
    await database1;
    await database2;
  }

  Future<int> insertToDatabase1(LocationModel location) async {
    try {
      final db = await database1;
      final id = await db.insert('locations', location.toMap());
      appLogger.d('Inserted to DB1 (id: $id): ${location.latitude}');
      return id;
    } catch (e) {
      appLogger.e('Error inserting to DB1: $e');
      rethrow;
    }
  }

  Future<List<LocationModel>> getAllFromDatabase1() async {
    final db = await database1;
    final result = await db.query('locations');
    appLogger.i('Fetched ${result.length} locations from DB1.');
    return result.map((map) => LocationModel.fromMap(map)).toList();
  }

  Future<void> clearDatabase1() async {
    final db = await database1;
    final count = await db.delete('locations');
    appLogger.i('DB1 cleared: $count rows deleted.');
  }

  Future<int> insertToDatabase2(LocationModel location) async {
    try {
      final db = await database2;
      final id = await db.insert('locations', location.toMap());
      appLogger.d('Inserted to DB2 (id: $id): ${location.latitude}');
      return id;
    } catch (e) {
      appLogger.e('Error inserting LocationModel to DB2: $e');
      rethrow;
    }
  }

  Future<List<LocationModel>> getAllFromDatabase2() async {
    final db = await database2;
    final result = await db.query('locations', orderBy: 'timestamp DESC');
    appLogger.i('Fetched ${result.length} locations from DB2.');
    return result.map((map) => LocationModel.fromMap(map)).toList();
  }

  Future<int> insertRawToDatabase2(Map<String, dynamic> data) async {
    try {
      final db = await database2;
      final id = await db.insert('locations', data);
      appLogger.d('Inserted raw map to DB2 (id: $id).');
      return id;
    } catch (e) {
      appLogger.e(
        'Error inserting raw data to DB2 (Primary Key conflict likely): $e',
      );
      rethrow;
    }
  }

  Future<void> clearDatabase2() async {
    final db = await database2;
    final count = await db.delete('locations');
    appLogger.i('DB2 cleared: $count rows deleted.');
  }

  Future<void> close() async {
    appLogger.i('Closing both databases.');
    final db1 = await database1;
    final db2 = await database2;
    await db1.close();
    await db2.close();
  }
}
