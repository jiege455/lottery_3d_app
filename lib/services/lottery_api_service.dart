import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/draw_record.dart';
import 'db_service.dart';

class LotteryApiService {
  static const String _baseUrl = 'https://www.mxnzp.com/api';
  static const String _appId = 'mkpnhppwki8qckna';
  static const String _appSecret = 'nisM90bxTLIUBoIpViKFwNmMMyT7aVrF';

  static const Map<int, String> _lotteryCodes = {
    1: 'fc3d',
    2: 'pl3',
  };

  static Future<List<DrawRecord>> fetchLatestDraws({required int lotteryType, int count = 10}) async {
    try {
      final code = _lotteryCodes[lotteryType] ?? 'fc3d';
      final url = '$_baseUrl/lottery/common/latest?code=$code&app_id=$_appId&app_secret=$_appSecret';

      print('请求 API: $url');

      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      print('响应状态码：${response.statusCode}');
      print('响应内容：${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('解析后的数据：$data');
        
        final msg = data['msg'];
        if (msg != null && msg.toString().contains('不合法')) {
          throw Exception('API 密钥验证失败，请检查 app_id 和 app_secret 是否正确');
        }
        
        return _parseDrawData(data, lotteryType);
      } else {
        print('API 请求失败，状态码：${response.statusCode}');
        throw Exception('API 请求失败：${response.statusCode}');
      }
    } catch (e) {
      print('LotteryApiService.fetchLatestDraws error: $e');
      rethrow;
    }
  }

  static List<DrawRecord> _parseDrawData(dynamic data, int lotteryType) {
    final results = <DrawRecord>[];
    try {
      print('开始解析数据：$data');
      
      if (data is Map) {
        final code = data['code'];
        print('API 返回 code: $code');
        
        if (code == 1) {
          final dataObj = data['data'];
          if (dataObj is Map) {
            final openCode = dataObj['openCode'] ?? '';
            final expect = dataObj['expect'] ?? '';
            final time = dataObj['time'] ?? '';

            print('解析数据 - 期号：$expect, 号码：$openCode');

            String cleanNum = openCode.toString().replaceAll(' ', '').replaceAll(',', '');
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
            } else {
              print('号码格式不正确：$cleanNum');
            }
          } else {
            print('data 不是 Map 类型');
          }
        } else {
          print('API 返回失败，code != 1');
          throw Exception('API 返回错误：${data['msg'] ?? '未知错误'}');
        }
      } else {
        print('返回数据不是 Map 类型');
      }
    } catch (e) {
      print('LotteryApiService._parseDrawData error: $e');
      rethrow;
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