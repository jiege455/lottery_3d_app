import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../providers/bet_provider.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../services/db_service.dart';

class PlayTypeStats extends StatefulWidget {
  const PlayTypeStats({super.key});

  @override
  State<PlayTypeStats> createState() => _PlayTypeStatsState();
}

class _PlayTypeStatsState extends State<PlayTypeStats> {
  Map<String, int> _stats = {};
  bool _loading = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_loaded) {
        _loaded = true;
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final db = DatabaseHelper.instance;
      final stats = await db.getPlayTypeStats(lotteryType: Provider.of<SettingsProvider>(context, listen: false).defaultLotteryType);
      if (mounted) setState(() { _stats = stats; _loading = false; });
    } catch (e) {
      print('PlayTypeStats._loadData error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _stats.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    final sorted = _stats.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = sorted.isNotEmpty ? sorted.first.value : 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppStyles.radiusSm), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('玩法分布', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh, size: 18), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
        ]),
        const SizedBox(height: 12),
        ...sorted.take(10).map((e) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _buildBar(e.key, e.value, maxVal, total))),
      ]),
    );
  }

  Widget _buildBar(String playType, int count, int maxVal, int total) {
    final pct = total > 0 ? count / total * 100 : 0;
    final ratio = maxVal > 0 ? count / maxVal : 0;
    return Row(children: [
      Expanded(flex: 2, child: Text(playType, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
      Expanded(flex: 5, child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: ratio.toDouble(), minHeight: 8, backgroundColor: AppColors.border, valueColor: AlwaysStoppedAnimation(AppColors.cyan)))),
      const SizedBox(width: 8),
      SizedBox(width: 60, child: Text('$count (${pct.toStringAsFixed(1)}%)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary), textAlign: TextAlign.right)),
    ]);
  }
}
