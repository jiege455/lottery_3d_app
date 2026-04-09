import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/draw_record.dart';
import 'db_service.dart';

class LotteryApiService {
  static const Map<int, String> _lotteryCodes = {
    1: 'fc3d',
    2: 'pls',
  };

  static final List<Map<String, dynamic>> _apiEndpoints = [
    {
      'name': '福彩官网API',
      'baseUrl': 'https://www.cwl.gov.cn/cwl_admin/front/cwlkj/search/kjxx/findDrawNotice',
      'params': 'name={code}&issueCount={count}&systemType=PC',
      'headers': {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'application/json, text/plain, */*',
        'Referer': 'https://www.cwl.gov.cn/',
        'Origin': 'https://www.cwl.gov.cn',
      },
    },
    {
      'name': '备用API - 500彩票网',
      'baseUrl': 'https://datachart.500.com/pl3/history/newinc/history.php',
      'params': 'limit={count}&sort=1',
      'headers': {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Referer': 'https://datachart.500.com/',
      },
    },
  ];

  static int _currentApiIndex = 0;
  static http.Client? _client;

  static http.Client get _httpClient => _client ??= http.Client();

  static Future<String> _fetchUrl(String url, Map<String, String>? headers) async {
    try {
      final response = await _httpClient.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 20));
      
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('请求超时');
    }
  }

  static Future<List<DrawRecord>> fetchLatestDraws({required int lotteryType, int count = 10}) async {
    final code = _lotteryCodes[lotteryType] ?? 'fc3d';
    
    for (int attempt = 0; attempt < _apiEndpoints.length; attempt++) {
      try {
        final api = _apiEndpoints[_currentApiIndex];
        final url = '${api['baseUrl']}?${api['params']}'.replaceAll('{code}', code).replaceAll('{count}', count.toString());
        final headers = api['headers'] != null ? Map<String, String>.from(api['headers']) : null;

        print('[LotteryApi] 尝试 ${api['name']} (${attempt + 1}/${_apiEndpoints.length})');

        final responseBody = await _fetchUrl(url, headers);

        if (responseBody.contains('异常') || responseBody.contains('检测到') || responseBody.contains('nginx') || responseBody.isEmpty) {
          throw Exception('响应无效');
        }

        final data = json.decode(responseBody);
        final results = _parseDrawData(data, lotteryType, api['name']);
        
        if (results.isNotEmpty) {
          print('[LotteryApi] ${api['name']} 成功获取 ${results.length} 条');
          return results;
        } else {
          throw Exception('无有效数据');
        }
      } catch (e) {
        print('[LotteryApi] ${_apiEndpoints[_currentApiIndex]['name']} 失败: $e');
        _currentApiIndex = (_currentApiIndex + 1) % _apiEndpoints.length;
        if (attempt < _apiEndpoints.length - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }

    throw Exception('所有 API 均无法获取开奖数据');
  }

  static List<DrawRecord> _parseDrawData(dynamic data, int lotteryType, String? apiName) {
    final results = <DrawRecord>[];
    
    try {
      if (data is! Map) return results;

      var dataList = <dynamic>[];
      
      if (apiName?.contains('福彩') == true) {
        dataList = data['result'] ?? data['data'] ?? [];
      } else if (data['data'] is List) {
        dataList = data['data'];
      } else if (data['result'] is List) {
        dataList = data['result'];
      } else if (data['list'] is List) {
        dataList = data['list'];
      } else if (data['rows'] is List) {
        dataList = data['rows'];
      }

      for (var item in dataList) {
        if (item is Map) {
          String issue = '';
          String openCode = '';
          String time = '';

          issue = (item['expect'] ?? item['issue'] ?? item['code'] ?? item['period'] ?? item['issueNo'] ?? '').toString();
          
          openCode = (item['red'] ?? item['drawResult'] ?? item['drawNum'] ?? 
                     item['openCode'] ?? item['opencode'] ?? item['number'] ?? '').toString();
          
          if (openCode.isEmpty || !RegExp(r'^[\d,|+\-]+$').hasMatch(openCode)) {
            final one = item['one'] ?? item['n1'] ?? item['num1'] ?? '';
            final two = item['two'] ?? item['n2'] ?? item['num2'] ?? '';
            final three = item['three'] ?? item['n3'] ?? item['num3'] ?? '';
            
            if (one.isNotEmpty && two.isNotEmpty && three.isNotEmpty) {
              openCode = '$one$two$three';
            } else {
              continue;
            }
          }
          
          time = (item['date'] ?? item['drawTime'] ?? item['opentime'] ?? 
                 item['open_time'] ?? item['time'] ?? '').toString();

          String cleanNum = openCode.replaceAll(RegExp(r'[^0-9]'), '');
          
          if (cleanNum.length >= 3 && cleanNum.length <= 4) {
            cleanNum = cleanNum.substring(0, 3);
          }

          if (RegExp(r'^[0-9]{3}$').hasMatch(cleanNum) && issue.isNotEmpty) {
            DateTime drawDate = DateTime.now();
            try {
              if (time.isNotEmpty) {
                if (time.contains('-')) {
                  drawDate = DateTime.parse(time.split(' ')[0]);
                } else if (time.contains('/')) {
                  final parts = time.split('/');
                  if (parts.length >= 3) {
                    drawDate = DateTime(
                      int.tryParse(parts[0]) ?? DateTime.now().year,
                      int.tryParse(parts[1]) ?? 1,
                      int.tryParse(parts[2].split(' ')[0]) ?? 1,
                    );
                  }
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
    } catch (e) {
      print('[LotteryApi] 解析错误: $e');
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
      
      print('[LotteryApi] 同步完成: 新增 $addedCount 条');
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

  static void dispose() {
    _client?.close();
    _client = null;
  }
}