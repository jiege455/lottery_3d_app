import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../services/db_service.dart';

class SettingsProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  AppSettings _settings = AppSettings();
  bool _isLoaded = false;

  AppSettings get settings => _settings;
  double get defaultMultiplier => _settings.defaultMultiplier;
  int get defaultLotteryType => _settings.defaultLotteryType;
  bool get isLoaded => _isLoaded;

  Future<void> loadSettings() async {
    try {
      _settings = await _db.getSettings();
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      print('SettingsProvider.loadSettings error: $e');
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> updateMultiplier(double value) async {
    try {
      _settings.defaultMultiplier = value;
      await _db.updateSettings(_settings);
      notifyListeners();
    } catch (e) {
      print('SettingsProvider.updateMultiplier error: $e');
      notifyListeners();
    }
  }

  Future<void> updateLotteryType(int value) async {
    try {
      _settings.defaultLotteryType = value;
      await _db.updateSettings(_settings);
      notifyListeners();
    } catch (e) {
      print('SettingsProvider.updateLotteryType error: $e');
      notifyListeners();
    }
  }

  Future<void> updateBackupTime(String time) async {
    try {
      _settings.lastBackupTime = time;
      await _db.updateSettings(_settings);
      notifyListeners();
    } catch (e) {
      print('SettingsProvider.updateBackupTime error: $e');
      notifyListeners();
    }
  }
}
