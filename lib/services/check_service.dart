import '../models/bet_record.dart';
import '../models/draw_record.dart';

class CheckResult {
  final BetRecord bet;
  final bool isWin;
  final String winType;
  final double winAmount;
  final double betAmount;

  const CheckResult({
    required this.bet,
    required this.isWin,
    required this.winType,
    required this.winAmount,
    required this.betAmount,
  });
}

class CheckService {
  static const Map<String, double> oddsMap = {
    'single': 1000.0,
    'group3': 333.33,
    'group6': 166.67,
    'dan': 10.0,
    'pos1': 10.0,
    'pos2': 100.0,
    'shuangfei_g3': 333.33,
    'shuangfei_g6': 166.67,
    'g3_2': 166.67, 'g3_3': 55.56, 'g3_4': 27.78, 'g3_5': 16.67,
    'g3_6': 11.11, 'g3_7': 7.94, 'g3_8': 5.95, 'g3_9': 4.76, 'g3_all': 3.70,
    'g6_4': 41.67, 'g6_5': 16.67, 'g6_6': 8.33, 'g6_7': 4.76,
    'g6_8': 2.97, 'g6_9': 2.08, 'g6_all': 1.39,
    'fs_3': 333.33, 'fs_4': 125.0, 'fs_5': 50.0, 'fs_6': 22.22,
    'fs_7': 10.71, 'fs_8': 5.49, 'fs_9': 2.96, 'fs_all': 1.0,
    'span0': 1000.0, 'span1': 200.0, 'span2': 66.67, 'span3': 33.33,
    'span4': 20.0, 'span5': 13.33, 'span6': 9.52, 'span7': 7.14,
    'span8': 5.56, 'span9': 4.44,
    'sum_val': 10.0,
    'bigsmall': 2.0,
    'oddeven': 2.0,
  };

  static List<CheckResult> checkAll(List<BetRecord> bets, DrawRecord draw) {
    return bets.map((bet) => checkSingle(bet, draw)).toList();
  }

  static CheckResult checkSingle(BetRecord bet, DrawRecord draw) {
    final nums = draw.numbers;
    if (nums.length != 3 || bet.number.isEmpty) {
      return CheckResult(bet: bet, isWin: false, winType: '', winAmount: 0, betAmount: bet.multiplier * 2);
    }

    bool isWin = false;
    String winType = '';
    double odds = 0;

    switch (bet.playType) {
      case 'single':
        isWin = bet.number == nums;
        break;
      case 'group3':
        isWin = _isGroup3(bet.number) && _isSameGroup(bet.number, nums);
        break;
      case 'group6':
        isWin = _isGroup6(bet.number) && _isSameGroup(bet.number, nums);
        break;
      case 'dan':
        isWin = nums.contains(bet.number);
        break;
      case 'pos1':
        final parts = bet.number.split(',');
        if (parts.length == 2) {
          final pos = parts[0];
          final digit = parts[1];
          int idx = pos == '百位' ? 0 : (pos == '十位' ? 1 : 2);
          isWin = nums[idx] == digit;
        }
        break;
      case 'pos2':
        final parts = bet.number.split(',');
        if (parts.length == 2) {
          final pos = parts[0];
          final digits = parts[1];
          if (pos == '前两位') isWin = '${nums[0]}${nums[1]}' == digits;
          else if (pos == '后两位') isWin = '${nums[1]}${nums[2]}' == digits;
          else if (pos == '首尾') isWin = '${nums[0]}${nums[2]}' == digits;
        }
        break;
      case 'shuangfei_g3':
        if (DrawRecord.getFormType(nums) == '组三') {
          final betDigits = bet.number.replaceAll(RegExp(r'[^0-9]'), '').split('').toSet();
          final drawDigits = nums.split('').toSet();
          isWin = betDigits.every((d) => drawDigits.contains(d));
        }
        break;
      case 'shuangfei_g6':
        if (DrawRecord.getFormType(nums) == '组六') {
          final betDigits = bet.number.replaceAll(RegExp(r'[^0-9]'), '').split('').toSet();
          final drawDigits = nums.split('').toSet();
          isWin = betDigits.every((d) => drawDigits.contains(d));
        }
        break;
      case var pt when pt.startsWith('span'):
        final spanVal = int.tryParse(pt.replaceAll('span', '')) ?? 0;
        isWin = DrawRecord.getSpan(nums) == spanVal;
        break;
      case 'sum_val':
        final sumVal = int.tryParse(bet.number) ?? 0;
        isWin = DrawRecord.getSumValue(nums) == sumVal;
        break;
      case 'bigsmall':
        final sum = DrawRecord.getSumValue(nums);
        isWin = (bet.number == '大' && sum >= 14) || (bet.number == '小' && sum <= 13);
        break;
      case 'oddeven':
        final sum = DrawRecord.getSumValue(nums);
        isWin = (bet.number == '单' && sum % 2 == 1) || (bet.number == '双' && sum % 2 == 0);
        break;
      default:
        isWin = _checkComplexPlay(bet, nums);
        break;
    }

    if (isWin) {
      odds = oddsMap[bet.playType] ?? 0;
      winType = bet.playTypeName;
    }

    return CheckResult(
      bet: bet,
      isWin: isWin,
      winType: winType,
      winAmount: odds * bet.multiplier,
      betAmount: bet.multiplier * 2,
    );
  }

  static bool _isSameGroup(String a, String b) {
    return Set.from(a.split('')) == Set.from(b.split(''));
  }

  static bool _isGroup3(String s) {
    return s.split('').toSet().length < s.length;
  }

  static bool _isGroup6(String s) {
    return s.split('').toSet().length == s.length;
  }

  static bool _checkComplexPlay(BetRecord bet, String nums) {
    if (bet.playType.startsWith('g3_') || bet.playType.startsWith('g6_')) {
      final digitSet = bet.number.split('').toSet();
      final numSet = nums.split('').toSet();
      if (bet.playType.startsWith('g3_')) {
        return _isGroup3(nums) && digitSet.every((d) => numSet.contains(d));
      } else {
        return _isGroup6(nums) && digitSet.every((d) => numSet.contains(d));
      }
    }
    if (bet.playType.startsWith('fs_')) {
      final digitSet = bet.number.split('').toSet();
      final numSet = nums.split('').toSet();
      return digitSet.every((d) => numSet.contains(d));
    }
    return false;
  }

  static double calculateTotalProfit(List<CheckResult> results) {
    return results.fold<double>(0, (sum, r) => sum + r.winAmount - r.betAmount);
  }

  static int getWinCount(List<CheckResult> results) {
    return results.where((r) => r.isWin).length;
  }

  static int getLoseCount(List<CheckResult> results) {
    return results.where((r) => !r.isWin).length;
  }
}
