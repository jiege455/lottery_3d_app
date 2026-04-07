import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../services/db_service.dart';

class SettingsProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  AppSettings _settings = AppSettings();

  AppSettings get settings => _settings;
  double get defaultMultiplier => _settings.defaultMultiplier;
  int get defaultLotteryType => _settings.defaultLotteryType;

  Future<void> loadSettings() async {
    _settings = await _db.getSettings();
    notifyListeners();
  }

  Future<void> updateMultiplier(double value) async {
    _settings.defaultMultiplier = value;
    await _db.updateSettings(_settings);
    notifyListeners();
  }

  Future<void> updateLotteryType(int value) async {
    _settings.defaultLotteryType = value;
    await _db.updateSettings(_settings);
    notifyListeners();
  }

  Future<void> updateBackupTime(String time) async {
    _settings.lastBackupTime = time;
    await _db.updateSettings(_settings);
    notifyListeners();
  }
}
