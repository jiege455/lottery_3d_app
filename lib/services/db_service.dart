import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/bet_record.dart';
import '../models/draw_record.dart';
import '../models/app_settings.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('lottery3d.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bet_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        number TEXT NOT NULL,
        play_type TEXT NOT NULL,
        play_type_name TEXT NOT NULL,
        lottery_type INTEGER DEFAULT 1,
        multiplier REAL DEFAULT 1.0,
        create_time TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE draw_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        issue TEXT NOT NULL,
        numbers TEXT NOT NULL,
        sum_value INTEGER DEFAULT 0,
        span INTEGER DEFAULT 0,
        form_type TEXT DEFAULT '',
        draw_date TEXT NOT NULL,
        lottery_type INTEGER DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        default_multiplier REAL DEFAULT 1.0,
        default_lottery_type INTEGER DEFAULT 1,
        last_backup_time TEXT DEFAULT ''
      )
    ''');
    await db.insert('settings', AppSettings().toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertBet(BetRecord record) async {
    final db = await database;
    return await db.insert('bet_records', record.toMap());
  }

  Future<List<BetRecord>> getAllBets({int? lotteryType}) async {
    final db = await database;
    if (lotteryType != null) {
      final result = await db.query('bet_records', where: 'lottery_type = ?', whereArgs: [lotteryType], orderBy: 'create_time DESC');
      return result.map((e) => BetRecord.fromMap(e)).toList();
    }
    final result = await db.query('bet_records', orderBy: 'create_time DESC');
    return result.map((e) => BetRecord.fromMap(e)).toList();
  }

  Future<int> getBetCount({int? lotteryType}) async {
    final db = await database;
    if (lotteryType != null) {
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM bet_records WHERE lottery_type = ?', [lotteryType]);
      return Sqflite.firstIntValue(result) ?? 0;
    }
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM bet_records');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> deleteBet(int id) async {
    final db = await database;
    return await db.delete('bet_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllBets() async {
    final db = await database;
    return await db.delete('bet_records');
  }

  Future<void> insertBetsBatch(List<BetRecord> records) async {
    final db = await database;
    final batch = db.batch();
    for (final record in records) {
      batch.insert('bet_records', record.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<int> insertDraw(DrawRecord record) async {
    final db = await database;
    return await db.insert('draw_records', record.toMap());
  }

  Future<List<DrawRecord>> getAllDraws({int? lotteryType, int? limit}) async {
    final db = await database;
    String query = 'SELECT * FROM draw_records';
    List<dynamic> args = [];
    if (lotteryType != null) {
      query += ' WHERE lottery_type = ?';
      args.add(lotteryType);
    }
    query += ' ORDER BY draw_date DESC';
    if (limit != null) {
      query += ' LIMIT ?';
      args.add(limit);
    }
    final result = await db.rawQuery(query, args.isEmpty ? null : args);
    return result.map((e) => DrawRecord.fromMap(e)).toList();
  }

  Future<int> deleteDraw(int id) async {
    final db = await database;
    return await db.delete('draw_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<AppSettings> getSettings() async {
    final db = await database;
    final result = await db.query('settings', where: 'id = 1');
    if (result.isNotEmpty) {
      return AppSettings.fromMap(result.first);
    }
    return AppSettings();
  }

  Future<void> updateSettings(AppSettings settings) async {
    final db = await database;
    await db.update('settings', settings.toMap(), where: 'id = 1');
  }

  Future<Map<String, int>> getPlayTypeStats({int? lotteryType}) async {
    final db = await database;
    String query = 'SELECT play_type, play_type_name, COUNT(*) as count FROM bet_records';
    if (lotteryType != null) {
      query += ' WHERE lottery_type = ?';
    }
    query += ' GROUP BY play_type ORDER BY count DESC';
    final result = await db.rawQuery(query, lotteryType != null ? [lotteryType] : null);
    Map<String, int> stats = {};
    for (final row in result) {
      final playType = row['play_type'];
      final count = row['count'];
      if (playType != null && count != null) {
        stats[playType as String] = count as int;
      }
    }
    return stats;
  }

  Future<Map<String, int>> getDigitFrequency({int? lotteryType}) async {
    final db = await database;
    String query = 'SELECT number FROM bet_records';
    if (lotteryType != null) {
      query += ' WHERE lottery_type = ?';
    }
    final result = await db.rawQuery(query, lotteryType != null ? [lotteryType] : null);
    Map<String, int> freq = {};
    for (var i = 0; i < 10; i++) freq[i.toString()] = 0;
    for (final row in result) {
      final num = row['number'];
      if (num == null) continue;
      final numStr = num as String;
      for (final char in numStr.split('')) {
        if (RegExp(r'[0-9]').hasMatch(char)) {
          freq[char] = (freq[char] ?? 0) + 1;
        }
      }
    }
    return freq;
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
