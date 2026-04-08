import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/play_types.dart';
import '../../../providers/bet_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../services/db_service.dart';

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

  String _getPlayTypeName(String code) {
    final config = PlayTypes.getByCode(code);
    return config?.name ?? code;
  }

  Color _getPlayTypeColor(String code) {
    final config = PlayTypes.getByCode(code);
    return config?.color ?? AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final total = _stats.values.fold<int>(0, (a, b) => a + b);
    if (total == 0 && !_loading) return const SizedBox.shrink();
    if (_loading) return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));

    final sorted = _stats.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = sorted.isNotEmpty ? sorted.first.value : 1;
    final totalAmount = _stats.entries.fold<double>(0, (sum, e) {
      final config = PlayTypes.getByCode(e.key);
      final baseAmount = config?.baseAmount ?? 2.0;
      return sum + e.value * baseAmount;
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppStyles.radiusSm), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('玩法分布', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Row(children: [
            Text('${totalAmount.toStringAsFixed(0)}元', style: TextStyle(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh, size: 18), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          ]),
        ]),
        const SizedBox(height: 12),
        ...sorted.take(10).map((e) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _buildBar(e.key, e.value, maxVal, total))),
      ]),
    );
  }

  Widget _buildBar(String playType, int count, int maxVal, int total) {
    final pct = total > 0 ? count / total * 100 : 0;
    final ratio = maxVal > 0 ? count / maxVal : 0;
    final name = _getPlayTypeName(playType);
    final color = _getPlayTypeColor(playType);
    final baseAmount = PlayTypes.getByCode(playType)?.baseAmount ?? 2.0;
    final amount = (count * baseAmount).toStringAsFixed(1);

    return Row(children: [
      Container(
        width: 56,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
        child: Text(name, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      const SizedBox(width: 8),
      Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: ratio.toDouble(), minHeight: 8, backgroundColor: AppColors.border, valueColor: AlwaysStoppedAnimation(color)))),
      const SizedBox(width: 8),
      SizedBox(width: 72, child: Text('$count注 ${amount}元(${pct.toStringAsFixed(1)}%)', style: TextStyle(fontSize: 10, color: AppColors.textSecondary), textAlign: TextAlign.right, overflow: TextOverflow.ellipsis, maxLines: 1)),
    ]);
  }
}
