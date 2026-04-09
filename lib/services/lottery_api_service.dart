import 'dart:convert';
import 'dart:async';
import 'dart:io' as io;
import '../models/draw_record.dart';
import 'db_service.dart';

class LotteryApiService {
  static const Map<int, String> _lotteryCodes = {
    1: 'fc3d',
    2: 'pls',
  };

  static final List<Map<String, String>> _apiEndpoints = [
    {
      'name': '彩鸟API',
      'baseUrl': 'http://api.huiniao.top/interface/home',
      'historyPath': '/lotteryHistory',
      'params': 'type={code}&page=1&limit={count}',
    },
    {
      'name': '备用API - 起零数据',
      'baseUrl': 'https://api.istero.com/resource/v1/lottery',
      'historyPath': '/{code}/history',
      'params': 'count={count}',
    },
  ];

  static int _currentApiIndex = 0;

  static Future<String> _fetchUrl(String url) async {
    final client = io.HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close().timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final content = await response.transform(utf8.decoder).join();
        return content;
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } finally {
      client.close();
    }
  }

  static Future<List<DrawRecord>> fetchLatestDraws({required int lotteryType, int count = 10}) async {
    final code = _lotteryCodes[lotteryType] ?? 'fc3d';
    
    for (int attempt = 0; attempt < _apiEndpoints.length; attempt++) {
      try {
        final api = _apiEndpoints[_currentApiIndex];
        final url = '${api['baseUrl']}${api['historyPath']}?${api['params']}'.replaceAll('{code}', code).replaceAll('{count}', count.toString());

        print('[LotteryApi] 尝试使用 ${api['name']} (${attempt + 1}/${_apiEndpoints.length})');
        print('[LotteryApi] 请求 URL: $url');

        final responseBody = await _fetchUrl(url);
        print('[LotteryApi] 响应成功，长度: ${responseBody.length}');

        final data = json.decode(responseBody);
        final results = _parseDrawData(data, lotteryType);
        
        if (results.isNotEmpty) {
          print('[LotteryApi] ${api['name']} 成功获取 ${results.length} 条数据');
          return results;
        } else {
          throw Exception('解析后无有效数据');
        }
      } catch (e) {
        print('[LotteryApi] ${_apiEndpoints[_currentApiIndex]['name']} 失败: $e');
        
        _currentApiIndex = (_currentApiIndex + 1) % _apiEndpoints.length;
        
        if (attempt < _apiEndpoints.length - 1) {
          print('[LotteryApi] 切换到备用 API: ${_apiEndpoints[_currentApiIndex]['name']}');
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }

    throw Exception('所有 API 均无法获取开奖数据');
  }

  static List<DrawRecord> _parseDrawData(dynamic data, int lotteryType) {
    final results = <DrawRecord>[];
    
    try {
      if (data is! Map) return results;

      final code = data['code'];
      
      if (code == 1 || code == 200 || code == '0000' || data['status'] == true || data['success'] == true) {
        var dataList = <dynamic>[];
        
        if (data['data'] is Map) {
          final dataObj = data['data'];
          dataList = dataObj['list'] ?? dataObj['data'] ?? dataObj['result'] ?? [];
        } else if (data['data'] is List) {
          dataList = data['data'];
        } else if (data['result'] is List) {
          dataList = data['result'];
        } else if (data['list'] is List) {
          dataList = data['list'];
        }

        if (dataList.isEmpty && data['data'] != null) {
          dataList = [data['data']];
        }

        for (var item in dataList) {
          if (item is Map) {
            String issue = '';
            String openCode = '';
            String time = '';

            issue = (item['expect'] ?? item['issue'] ?? item['code'] ?? item['period'] ?? '').toString();
            
            final one = item['one'] ?? item['red'] ?? item['number1'] ?? item['n1'] ?? 0;
            final two = item['two'] ?? item['blue'] ?? item['number2'] ?? item['n2'] ?? 0;
            final three = item['three'] ?? item['green'] ?? item['number3'] ?? item['n3'] ?? 0;
            
            if (one != 0 && two != 0 && three != 0) {
              openCode = '$one$two$three';
            } else {
              openCode = (item['open_code'] ?? item['opencode'] ?? item['drawnum'] ?? item['number'] ?? item['winNumber'] ?? '').toString();
            }
            
            time = (item['opentime'] ?? item['open_time'] ?? item['time'] ?? item['date'] ?? item['drawTime'] ?? '').toString();

            String cleanNum = openCode.replaceAll(RegExp(r'[^\d]'), '');
            if (cleanNum.length >= 3) {
              cleanNum = cleanNum.substring(0, 3);
            }

            if (RegExp(r'^[0-9]{3}$').hasMatch(cleanNum) && issue.isNotEmpty) {
              DateTime drawDate = DateTime.now();
              try {
                if (time.isNotEmpty) {
                  if (time.contains('-') || time.contains('/')) {
                    drawDate = DateTime.parse(time);
                  } else if (RegExp(r'^\d{14}$').hasMatch(time)) {
                    drawDate = DateTime(
                      int.tryParse(time.substring(0, 4)) ?? DateTime.now().year,
                      int.tryParse(time.substring(4, 6)) ?? 1,
                      int.tryParse(time.substring(6, 8)) ?? 1,
                      int.tryParse(time.substring(8, 10)) ?? 0,
                      int.tryParse(time.substring(10, 12)) ?? 0,
                      int.tryParse(time.substring(12, 14)) ?? 0,
                    );
                  }
                }
              } catch (_) {}

              results.add(DrawRecord(
                issue: issue,
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
    } catch (e) {
      print('[LotteryApi] 解析数据错误: $e');
    }
    
    return results;
  }

  static Future<int> syncDraws({required int lotteryType, int count = 10}) async {
    try {
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
      
      print('[LotteryApi] 同步完成: 新增 $addedCount 条数据');
      return addedCount;
    } catch (e) {
      print('[LotteryApi] syncDraws error: $e');
      return 0;
    }
  }

  static Future<DrawRecord?> getLatestDraw({required int lotteryType}) async {
    try {
      final draws = await fetchLatestDraws(lotteryType: lotteryType, count: 1);
      return draws.isNotEmpty ? draws.first : null;
    } catch (e) {
      print('[LotteryApi] getLatestDraw error: $e');
      return null;
    }
  }
}