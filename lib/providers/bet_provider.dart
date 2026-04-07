import 'package:flutter/material.dart';
import '../models/bet_record.dart';
import '../services/db_service.dart';

class BetProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<BetRecord> _bets = [];
  bool _isLoading = false;

  List<BetRecord> get bets => _bets;
  bool get isLoading => _isLoading;

  Future<void> loadBets({int? lotteryType}) async {
    _isLoading = true;
    notifyListeners();
    _bets = await _db.getAllBets(lotteryType: lotteryType);
    _isLoading = false;
    notifyListeners();
  }

  Future<int> addBet(BetRecord bet) async {
    final id = await _db.insertBet(bet);
    await loadBets();
    return id;
  }

  Future<void> addBetsBatch(List<BetRecord> bets) async {
    await _db.insertBetsBatch(bets);
    await loadBets();
  }

  Future<void> deleteBet(int id) async {
    await _db.deleteBet(id);
    _bets.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  Future<void> deleteAllBets() async {
    await _db.deleteAllBets();
    _bets.clear();
    notifyListeners();
  }

  int get totalBets => _bets.length;

  int getBetCountByPlayType(String playType) {
    return _bets.where((b) => b.playType == playType).length;
  }
}
