import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:walk_and_fit/models/step_record.dart';
import 'package:walk_and_fit/models/workout_session.dart';
import 'package:walk_and_fit/models/food_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'walk_fit.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE step_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        steps INTEGER NOT NULL,
        calories REAL NOT NULL,
        distance REAL NOT NULL,
        UNIQUE(date)
      )
    ''');
    
    await db.execute('''
      CREATE TABLE workout_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        startTime INTEGER NOT NULL,
        endTime INTEGER,
        steps INTEGER NOT NULL,
        distance REAL NOT NULL,
        averageSpeed REAL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE food_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        name TEXT NOT NULL,
        calories REAL NOT NULL,
        protein REAL NOT NULL,
        carbs REAL NOT NULL,
        fat REAL NOT NULL,
        servingSize REAL NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE workout_sessions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          startTime INTEGER NOT NULL,
          endTime INTEGER,
          steps INTEGER NOT NULL,
          distance REAL NOT NULL,
          averageSpeed REAL
        )
      ''');
    }
    
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE food_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          name TEXT NOT NULL,
          calories REAL NOT NULL,
          protein REAL NOT NULL,
          carbs REAL NOT NULL,
          fat REAL NOT NULL,
          servingSize REAL NOT NULL,
          timestamp INTEGER NOT NULL
        )
      ''');
    }
  }

  Future<int> insertStepRecord(StepRecord record) async {
    final db = await database;
    return await db.insert(
      'step_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<StepRecord>> getStepRecords({int? limit}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'step_records',
      orderBy: 'date DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => StepRecord.fromMap(maps[i]));
  }

  Future<StepRecord?> getStepRecordByDate(String date) async {
    final db = await database;
    final maps = await db.query(
      'step_records',
      where: 'date = ?',
      whereArgs: [date],
    );
    if (maps.isEmpty) return null;
    return StepRecord.fromMap(maps.first);
  }

  Future<int> updateStepRecord(StepRecord record) async {
    final db = await database;
    return await db.update(
      'step_records',
      record.toMap(),
      where: 'date = ?',
      whereArgs: [record.date],
    );
  }

  Future<int> deleteStepRecord(String date) async {
    final db = await database;
    return await db.delete(
      'step_records',
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        SUM(steps) as totalSteps,
        AVG(steps) as avgSteps,
        SUM(calories) as totalCalories,
        SUM(distance) as totalDistance
      FROM step_records
    ''');
    return result.first;
  }

  Future<int> insertWorkoutSession(WorkoutSession session) async {
    final db = await database;
    return await db.insert('workout_sessions', session.toMap());
  }

  Future<int> updateWorkoutSession(WorkoutSession session) async {
    final db = await database;
    return await db.update(
      'workout_sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<List<WorkoutSession>> getWorkoutSessions({int? limit}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'workout_sessions',
      orderBy: 'startTime DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => WorkoutSession.fromMap(maps[i]));
  }

  Future<WorkoutSession?> getActiveWorkoutSession() async {
    final db = await database;
    final maps = await db.query(
      'workout_sessions',
      where: 'endTime IS NULL',
      orderBy: 'startTime DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return WorkoutSession.fromMap(maps.first);
  }

  Future<int> setDailyStepGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_step_goal', goal);
    return goal;
  }

  Future<int> getDailyStepGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('daily_step_goal') ?? 10000;
  }

  Future<int> insertFoodItem(FoodItem food) async {
    final db = await database;
    return await db.insert('food_items', food.toMap());
  }

  Future<List<FoodItem>> getFoodItemsByDate(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'food_items',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => FoodItem.fromMap(maps[i]));
  }

  Future<int> deleteFoodItem(int id) async {
    final db = await database;
    return await db.delete(
      'food_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalCaloriesConsumedByDate(String date) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(calories) as total
      FROM food_items
      WHERE date = ?
    ''', [date]);
    
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<void> setUserWeight(double weight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_weight', weight);
  }

  Future<double> getUserWeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('user_weight') ?? 70.0;
  }
}
