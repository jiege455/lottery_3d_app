import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../providers/bet_provider.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../services/db_service.dart';
import '../../../../widgets/empty_state.dart';

class HotNumbers extends StatefulWidget {
  const HotNumbers({super.key});

  @override
  State<HotNumbers> createState() => _HotNumbersState();
}

class _HotNumbersState extends State<HotNumbers> {
  Map<String, int> _freq = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final db = DatabaseHelper.instance;
    final freq = await db.getDigitFrequency(lotteryType: Provider.of<SettingsProvider>(context, listen: false).defaultLotteryType);
    if (mounted) setState(() { _freq = freq; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final total = _freq.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) return EmptyState(message: '暂无投注数据', icon: Icons.bar_chart);

    final sorted = _freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = sorted.isNotEmpty ? sorted.first.value : 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppStyles.radiusSm), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('热门号码排行', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh, size: 18), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
        ]),
        const SizedBox(height: 12),
        ...sorted.asMap().entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _buildBar(e.key + 1, e.value.key, e.value.value, maxVal, total))),
      ]),
    );
  }

  Widget _buildBar(int rank, String digit, int count, int maxVal, int total) {
    final pct = total > 0 ? (count / total * 100) : 0;
    final ratio = maxVal > 0 ? count / maxVal : 0;
    return Row(children: [
      SizedBox(width: 24, child: Text('#$rank', style: TextStyle(fontSize: 12, color: rank <= 3 ? AppColors.danger : AppColors.textSecondary, fontWeight: FontWeight.w600))),
      Container(width: 32, height: 32, alignment: Alignment.center, decoration: BoxDecoration(color: rank <= 3 ? AppColors.danger.withOpacity(0.1) : AppColors.primaryLight, borderRadius: BorderRadius.circular(8)), child: Text(digit, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: rank <= 3 ? AppColors.danger : AppColors.primary))),
      const SizedBox(width: 10),
      Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: ratio.toDouble(), minHeight: 8, backgroundColor: AppColors.border, valueColor: AlwaysStoppedAnimation(rank <= 3 ? AppColors.danger : AppColors.primary)))),
      const SizedBox(width: 8),
      SizedBox(width: 50, child: Text('$count次($pct.toStringAsFixed(1)%)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary), textAlign: TextAlign.right)),
    ]);
  }
}
