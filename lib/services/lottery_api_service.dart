import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/draw_record.dart';
import 'db_service.dart';

class LotteryApiService {
  static const String _fc3dUrl = 'https://www.lottery.gov.cn/api/lottery_kj_detail_new.jspx?_ltype=dlt';
  static const String _plsUrl = 'https://www.lottery.gov.cn/api/lottery_kj_detail_new.jspx?_ltype=pls';

  static Future<List<DrawRecord>> fetchLatestDraws({required int lotteryType, int count = 10}) async {
    try {
      final url = lotteryType == 1 ? _fc3dUrl : _plsUrl;
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseDrawData(data, lotteryType, count);
      }
      return [];
    } catch (e) {
      print('LotteryApiService.fetchLatestDraws error: $e');
      return [];
    }
  }

  static List<DrawRecord> _parseDrawData(dynamic data, int lotteryType, int count) {
    final results = <DrawRecord>[];
    try {
      if (data is Map && data.containsKey('result')) {
        final list = data['result'] as List;
        for (var i = 0; i < list.length && i < count; i++) {
          final item = list[i];
          final issue = item['issue'] ?? item['code'] ?? '';
          final numbers = item['number'] ?? item['red'] ?? '';
          if (numbers is String && numbers.isNotEmpty) {
            final cleanNum = numbers.replaceAll(' ', '').replaceAll(',', '');
            if (RegExp(r'^[0-9]{3}$').hasMatch(cleanNum)) {
              results.add(DrawRecord(
                issue: issue.toString(),
                numbers: cleanNum,
                sumValue: DrawRecord.getSumValue(cleanNum),
                span: DrawRecord.getSpan(cleanNum),
                formType: DrawRecord.getFormType(cleanNum),
                drawDate: DateTime.now(),
                lotteryType: lotteryType,
              ));
            }
          }
        }
      } else if (data is List) {
        for (var i = 0; i < data.length && i < count; i++) {
          final item = data[i];
          final issue = item['issue'] ?? item['expect'] ?? '';
          final numbers = item['opencode'] ?? item['number'] ?? item['red'] ?? '';
          String cleanNum = numbers.toString().replaceAll(' ', '').replaceAll(',', '');
          if (cleanNum.length >= 3) {
            cleanNum = cleanNum.substring(0, 3);
          }
          if (RegExp(r'^[0-9]{3}$').hasMatch(cleanNum)) {
            results.add(DrawRecord(
              issue: issue.toString(),
              numbers: cleanNum,
              sumValue: DrawRecord.getSumValue(cleanNum),
              span: DrawRecord.getSpan(cleanNum),
              formType: DrawRecord.getFormType(cleanNum),
              drawDate: DateTime.now(),
              lotteryType: lotteryType,
            ));
          }
        }
      }
    } catch (e) {
      print('LotteryApiService._parseDrawData error: $e');
    }
    return results;
  }

  static Future<int> syncDraws({required int lotteryType, int count = 20}) async {
    final draws = await fetchLatestDraws(lotteryType: lotteryType, count: count);
    if (draws.isEmpty) return 0;

    final existingDraws = await DatabaseHelper.instance.getAllDraws(lotteryType: lotteryType);
    final existingIssues = existingDraws.map((d) => d.issue).toSet();

    int addedCount = 0;
    for (final draw in draws) {
      if (!existingIssues.contains(draw.issue)) {
        await DatabaseHelper.instance.insertDraw(draw);
        addedCount++;
      }
    }
    return addedCount;
  }
}
