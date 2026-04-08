import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../services/db_service.dart';
import '../core/constants/play_types.dart';

class SettingsProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  AppSettings _settings = AppSettings();
  bool _isLoaded = false;
  Map<String, double> _playTypeAmounts = {};
  Map<String, double> _defaultAmounts = {};
  Map<String, double> _playTypePayoutRates = {};
  List<Map<String, dynamic>> _customPlayTypes = [];

  AppSettings get settings => _settings;
  double get defaultMultiplier => _settings.defaultMultiplier;
  int get defaultLotteryType => _settings.defaultLotteryType;
  bool get isLoaded => _isLoaded;
  Map<String, double> get playTypeAmounts => _playTypeAmounts;
  Map<String, double> get playTypePayoutRates => _playTypePayoutRates;
  List<Map<String, dynamic>> get customPlayTypes => _customPlayTypes;

  SettingsProvider() {
    _initDefaultAmounts();
  }

  void _initDefaultAmounts() {
    _defaultAmounts = {
      for (final pt in PlayTypes.all) pt.code: pt.baseAmount,
    };
  }

  double getPlayTypeAmount(String playType) {
    return _playTypeAmounts[playType] ?? _defaultAmounts[playType] ?? 2.0;
  }

  double getPlayTypePayoutRate(String playType) {
    return _playTypePayoutRates[playType] ?? 0.0;
  }

  Future<void> loadSettings() async {
    try {
      _settings = await _db.getSettings();
      _playTypeAmounts = await _db.getPlayTypeAmounts();
      _playTypePayoutRates = await _db.getPlayTypePayoutRates();
      _customPlayTypes = await _db.getCustomPlayTypes();
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

  Future<void> updatePlayTypeAmount(String playType, double amount, double payoutRate) async {
    try {
      await _db.setPlayTypeAmount(playType, amount, payoutRate);
      _playTypeAmounts[playType] = amount;
      _playTypePayoutRates[playType] = payoutRate;
      notifyListeners();
    } catch (e) {
      print('SettingsProvider.updatePlayTypeAmount error: $e');
      notifyListeners();
    }
  }

  Future<void> resetPlayTypeAmounts() async {
    try {
      await _db.resetPlayTypeAmounts();
      _playTypeAmounts.clear();
      _playTypePayoutRates.clear();
      notifyListeners();
    } catch (e) {
      print('SettingsProvider.resetPlayTypeAmounts error: $e');
      notifyListeners();
    }
  }

  Future<void> addCustomPlayType(String code, String name, String category, double amount, double payoutRate, String color) async {
    try {
      await _db.addCustomPlayType(code, name, category, amount, payoutRate, color);
      _customPlayTypes = await _db.getCustomPlayTypes();
      _playTypeAmounts[code] = amount;
      _playTypePayoutRates[code] = payoutRate;
      notifyListeners();
    } catch (e) {
      print('SettingsProvider.addCustomPlayType error: $e');
      notifyListeners();
    }
  }

  Future<void> deleteCustomPlayType(String code) async {
    try {
      await _db.deleteCustomPlayType(code);
      _customPlayTypes = await _db.getCustomPlayTypes();
      _playTypeAmounts.remove(code);
      _playTypePayoutRates.remove(code);
      notifyListeners();
    } catch (e) {
      print('SettingsProvider.deleteCustomPlayType error: $e');
      notifyListeners();
    }
  }
}
