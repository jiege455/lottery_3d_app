import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import '../models/bet_record.dart';
import '../models/draw_record.dart';
import '../models/app_settings.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static Completer<Database>? _initCompleter;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    if (_initCompleter != null) {
      return _initCompleter!.future;
    }
    _initCompleter = Completer<Database>();
    try {
      _database = await _initDB('lottery3d.db');
      _initCompleter!.complete(_database!);
      return _database!;
    } catch (e) {
      print('Database initialization error: $e');
      _initCompleter!.completeError(e);
      _initCompleter = null;
      _database = null;
      rethrow;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
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
        base_amount REAL DEFAULT 2.0,
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
    await db.execute('''
      CREATE TABLE play_type_amounts (
        play_type TEXT PRIMARY KEY,
        amount REAL NOT NULL
      )
    ''');
    await db.insert('settings', {'id': 1, 'default_multiplier': 1.0, 'default_lottery_type': 1, 'last_backup_time': ''}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<int> insertBet(BetRecord record) async {
    try {
      final db = await database;
      return await db.insert('bet_records', record.toMap());
    } catch (e) {
      print('insertBet error: $e');
      return -1;
    }
  }

  Future<List<BetRecord>> getAllBets({int? lotteryType}) async {
    try {
      final db = await database;
      if (lotteryType != null) {
        final result = await db.query('bet_records', where: 'lottery_type = ?', whereArgs: [lotteryType], orderBy: 'create_time DESC');
        return result.map((e) => BetRecord.fromMap(e)).toList();
      }
      final result = await db.query('bet_records', orderBy: 'create_time DESC');
      return result.map((e) => BetRecord.fromMap(e)).toList();
    } catch (e) {
      print('getAllBets error: $e');
      return [];
    }
  }

  Future<int> getBetCount({int? lotteryType}) async {
    try {
      final db = await database;
      if (lotteryType != null) {
        final result = await db.rawQuery('SELECT COUNT(*) as count FROM bet_records WHERE lottery_type = ?', [lotteryType]);
        return Sqflite.firstIntValue(result) ?? 0;
      }
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM bet_records');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      print('getBetCount error: $e');
      return 0;
    }
  }

  Future<int> deleteBet(int id) async {
    try {
      final db = await database;
      return await db.delete('bet_records', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('deleteBet error: $e');
      return 0;
    }
  }

  Future<int> deleteAllBets() async {
    try {
      final db = await database;
      return await db.delete('bet_records');
    } catch (e) {
      print('deleteAllBets error: $e');
      return 0;
    }
  }

  Future<int> deleteAllDraws() async {
    try {
      final db = await database;
      return await db.delete('draw_records');
    } catch (e) {
      print('deleteAllDraws error: $e');
      return 0;
    }
  }

  Future<void> insertBetsBatch(List<BetRecord> records) async {
    try {
      final db = await database;
      final batch = db.batch();
      for (final record in records) {
        batch.insert('bet_records', record.toMap());
      }
      await batch.commit(noResult: true);
    } catch (e) {
      print('insertBetsBatch error: $e');
    }
  }

  Future<int> insertDraw(DrawRecord record) async {
    try {
      final db = await database;
      return await db.insert('draw_records', record.toMap());
    } catch (e) {
      print('insertDraw error: $e');
      return -1;
    }
  }

  Future<List<DrawRecord>> getAllDraws({int? lotteryType, int? limit}) async {
    try {
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
    } catch (e) {
      print('getAllDraws error: $e');
      return [];
    }
  }

  Future<int> deleteDraw(int id) async {
    try {
      final db = await database;
      return await db.delete('draw_records', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('deleteDraw error: $e');
      return 0;
    }
  }

  Future<AppSettings> getSettings() async {
    try {
      final db = await database;
      final result = await db.query('settings', where: 'id = 1');
      if (result.isNotEmpty) {
        return AppSettings.fromMap(result.first);
      }
      await db.insert('settings', {'id': 1, 'default_multiplier': 1.0, 'default_lottery_type': 1, 'last_backup_time': ''}, conflictAlgorithm: ConflictAlgorithm.replace);
      return AppSettings();
    } catch (e) {
      print('getSettings error: $e');
      return AppSettings();
    }
  }

  Future<void> updateSettings(AppSettings settings) async {
    try {
      final db = await database;
      await db.update('settings', settings.toMap(), where: 'id = 1');
    } catch (e) {
      print('updateSettings error: $e');
    }
  }

  Future<Map<String, int>> getPlayTypeStats({int? lotteryType}) async {
    try {
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
    } catch (e) {
      print('getPlayTypeStats error: $e');
      return {};
    }
  }

  Future<Map<String, int>> getDigitFrequency({int? lotteryType}) async {
    try {
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
    } catch (e) {
      print('getDigitFrequency error: $e');
      return {};
    }
  }

  Future<Map<String, double>> getPlayTypeAmounts() async {
    try {
      final db = await database;
      final result = await db.query('play_type_amounts');
      Map<String, double> amounts = {};
      for (final row in result) {
        final playType = row['play_type'] as String?;
        final amount = row['amount'] as double?;
        if (playType != null && amount != null) {
          amounts[playType] = amount;
        }
      }
      return amounts;
    } catch (e) {
      print('getPlayTypeAmounts error: $e');
      return {};
    }
  }

  Future<void> setPlayTypeAmount(String playType, double amount) async {
    try {
      final db = await database;
      await db.insert('play_type_amounts', {'play_type': playType, 'amount': amount}, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print('setPlayTypeAmount error: $e');
    }
  }

  Future<void> resetPlayTypeAmounts() async {
    try {
      final db = await database;
      await db.delete('play_type_amounts');
    } catch (e) {
      print('resetPlayTypeAmounts error: $e');
    }
  }

  Future<void> close() async {
    try {
      if (_database != null) {
        await _database!.close();
        _database = null;
        _initCompleter = null;
      }
    } catch (e) {
      print('close error: $e');
    }
  }
}
