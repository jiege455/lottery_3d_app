import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../widgets/empty_state.dart';

class DrawDataList extends StatefulWidget {
  const DrawDataList({super.key});

  @override
  State<DrawDataList> createState() => _DrawDataListState();
}

class _DrawDataListState extends State<DrawDataList> {
  static final List<Map<String, dynamic>> _sampleData = _generateSampleData(30);

  static List<Map<String, dynamic>> _generateSampleData(int count) {
    final data = <Map<String, dynamic>>[];
    for (var i = 0; i < count; i++) {
      final nums = '${i % 10}${(i + 3) % 10}${(i + 7) % 10}';
      data.add({
        'issue': '${2024001 + i}',
        'numbers': nums,
        'sumValue': _calcSum(nums),
        'span': _calcSpan(nums),
        'formType': _getFormType(nums),
      });
    }
    return data.reversed.toList();
  }

  static int _calcSum(String numbers) {
    return numbers.split('').map(int.parse).reduce((a, b) => a + b);
  }

  static int _calcSpan(String numbers) {
    final digits = numbers.split('').map(int.parse).toList();
    return digits.reduce((a, b) => a > b ? a : b) - digits.reduce((a, b) => a < b ? a : b);
  }

  static String _getFormType(String numbers) {
    if (numbers[0] == numbers[1] && numbers[1] == numbers[2]) return '豹子';
    if (numbers[0] == numbers[1] || numbers[1] == numbers[2] || numbers[0] == numbers[2]) return '组三';
    return '组六';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppStyles.radiusSm),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('开奖数据', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 16),
                label: const Text('添加', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._sampleData.take(10).map((item) => _buildItem(item)),
          Center(child: TextButton(onPressed: () {}, child: const Text('查看更多 →'))),
        ],
      ),
    );
  }

  Widget _buildItem(Map<String, dynamic> item) {
    final nums = item['numbers'] as String;
    final sum = item['sumValue'] as int;
    final span = item['span'] as int;
    final formType = item['formType'] as String;

    Color formColor;
    switch (formType) {
      case '豹子':
        formColor = AppColors.danger;
        break;
      case '组三':
        formColor = AppColors.warning;
        break;
      default:
        formColor = AppColors.success;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(item['issue'], style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            flex: 2,
            child: Text(nums, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: 4)),
          ),
          Expanded(
            child: Text('$sum', style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
          ),
          Expanded(
            child: Text('$span跨', style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(color: formColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(formType, style: TextStyle(fontSize: 11, color: formColor), textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );
  }
}
