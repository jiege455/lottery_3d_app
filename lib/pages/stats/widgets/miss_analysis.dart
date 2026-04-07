import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class MissAnalysis extends StatefulWidget {
  const MissAnalysis({super.key});

  @override
  State<MissAnalysis> createState() => _MissAnalysisState();
}

class _MissAnalysisState extends State<MissAnalysis> {
  int _periods = 30;

  static List<Map<String, String>> _generateSampleDraws(int count) {
    final draws = <Map<String, String>>[];
    for (var i = 0; i < count; i++) {
      final a = (i * 3 + 1) % 10;
      final b = (i * 5 + 2) % 10;
      final c = (i * 7 + 4) % 10;
      draws.add({'numbers': '$a$b$c'});
    }
    return draws;
  }

  @override
  Widget build(BuildContext context) {
    final draws = _generateSampleDraws(_periods);
    final appeared = <String>{};
    for (final d in draws) {
      for (final c in d['numbers']!.split('')) {
        appeared.add(c);
      }
    }
    final missing = List.generate(10, (i) => i.toString()).where((d) => !appeared.contains(d)).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppStyles.radiusSm), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('遗漏分析', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          DropdownButton<int>(value: _periods, items: [10, 20, 30, 50, 100].map((v) => DropdownMenuItem(value: v, child: Text('${v}期'))).toList(), onChanged: (v) => setState(() => _periods = v!)),
        ]),
        const SizedBox(height: 12),
        Text('最近$_periods期开奖中，以下号码未出现：', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        if (missing.isEmpty)
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.08), borderRadius: BorderRadius.circular(AppStyles.radiusXs)), child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.check_circle, color: AppColors.success), const SizedBox(width: 8), Text('全部号码都已出现过！', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
          ]))
        else
          Wrap(spacing: 8, runSpacing: 8, children: missing.map((d) => Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.danger.withOpacity(0.3))), child: Text(d, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.danger)))).toList()),
        const SizedBox(height: 8),
        Text('（注：遗漏分析基于内置模拟数据，实际使用需导入真实开奖数据）', style: TextStyle(fontSize: 10, color: AppColors.textLight, fontStyle: FontStyle.italic)),
      ]),
    );
  }
}
