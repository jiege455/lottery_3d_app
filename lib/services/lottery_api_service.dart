import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/draw_record.dart';
import 'db_service.dart';

class LotteryApiService {
  static const String _baseUrl = 'https://www.mxnzp.com/api';
  static const String _appId = 'mkpnhppwki8qckna';
  static const String _appSecret = 'nisM90bxTLIUBoI';

  static const Map<int, String> _lotteryCodes = {
    1: 'fc3d',
    2: 'pl3',
    3: 'pl5',
  };

  static Future<List<DrawRecord>> fetchLatestDraws({required int lotteryType, int count = 10}) async {
    try {
      final code = _lotteryCodes[lotteryType] ?? 'fc3d';
      final url = '$_baseUrl/lottery/$code/lottery_list?page=1&limit=$count';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'app_id': _appId,
          'app_secret': _appSecret,
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseDrawData(data, lotteryType);
      }
      return [];
    } catch (e) {
      print('LotteryApiService.fetchLatestDraws error: $e');
      return [];
    }
  }

  static List<DrawRecord> _parseDrawData(dynamic data, int lotteryType) {
    final results = <DrawRecord>[];
    try {
      if (data is Map) {
        final code = data['code'];
        if (code == 1) {
          final dataObj = data['data'];
          if (dataObj is Map) {
            final list = dataObj['list'] as List? ?? [];
            for (final item in list) {
              final openCode = item['openCode'] ?? '';
              final expect = item['expect'] ?? '';
              final time = item['time'] ?? '';

              String cleanNum = openCode.toString().replaceAll(' ', '').replaceAll(',', '').replaceAll('+', '');
              if (cleanNum.length >= 3) {
                cleanNum = cleanNum.substring(0, 3);
              }

              if (RegExp(r'^[0-9]{3}$').hasMatch(cleanNum)) {
                DateTime drawDate = DateTime.now();
                try {
                  if (time.isNotEmpty) {
                    drawDate = DateTime.parse(time);
                  }
                } catch (_) {}

                results.add(DrawRecord(
                  issue: expect.toString(),
                  numbers: cleanNum,
                  sumValue: DrawRecord.getSumValue(cleanNum),
                  span: DrawRecord.getSpan(cleanNum),
                  formType: DrawRecord.getFormType(cleanNum),
                  drawDate: drawDate,
                  lotteryType: lotteryType,
                ));
              }
            }
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