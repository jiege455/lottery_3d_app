import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/play_types.dart';
import '../../providers/bet_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/empty_state.dart';
import 'widgets/hot_numbers.dart';
import 'widgets/miss_analysis.dart';
import 'widgets/playtype_stats.dart';
import 'widgets/export_panel.dart';
import 'widgets/kill_number_tool.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_loaded) {
        _loaded = true;
        _reloadData();
      }
    });
  }

  void _reloadData() {
    try {
      final lotteryType = Provider.of<SettingsProvider>(context, listen: false).defaultLotteryType;
      Provider.of<BetProvider>(context, listen: false).loadBets(lotteryType: lotteryType);
    } catch (e) {
      print('StatsPage._reloadData error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final betProvider = Provider.of<BetProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final lotteryType = settings.defaultLotteryType;

    final filteredBets = betProvider.bets.where((b) => b.lotteryType == lotteryType).toList();
    final totalAmount = filteredBets.fold<double>(0, (sum, b) => sum + b.multiplier * 2);
    final totalMultiplier = filteredBets.fold<double>(0, (sum, b) => sum + b.multiplier);
    final playTypeCount = filteredBets.map((b) => b.playType).toSet().length;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('统计分析', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text('开发者：杰哥网络科技', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                ],
              ),
            ),
            _buildLotterySwitcher(settings),
            const SizedBox(height: 8),
            _buildOverviewCard(filteredBets, totalAmount, totalMultiplier, playTypeCount, lotteryType),
            const SizedBox(height: 8),
            if (filteredBets.isNotEmpty) _buildNumberStats(filteredBets),
            const HotNumbers(),
            const MissAnalysis(),
            const KillNumberTool(),
            const PlayTypeStats(),
            const ExportPanel(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLotterySwitcher(SettingsProvider settings) {
    final current = settings.defaultLotteryType;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppStyles.radiusSm)),
      child: Row(children: [
        Expanded(child: GestureDetector(
          onTap: () { settings.updateLotteryType(1); _reloadData(); },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: current == 1 ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(AppStyles.radiusXs)),
            child: Text('福彩 3D', textAlign: TextAlign.center, style: TextStyle(color: current == 1 ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        )),
        Expanded(child: GestureDetector(
          onTap: () { settings.updateLotteryType(2); _reloadData(); },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: current == 2 ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(AppStyles.radiusXs)),
            child: Text('排列三', textAlign: TextAlign.center, style: TextStyle(color: current == 2 ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        )),
      ]),
    );
  }

  Widget _buildOverviewCard(List filteredBets, double totalAmount, double totalMultiplier, int playTypeCount, int lotteryType) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(AppStyles.radiusSm),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _buildStatItem('总投注数', '${filteredBets.length}', Colors.white),
          _buildStatItem('总金额', '${totalAmount.toStringAsFixed(1)}元', Colors.yellowAccent),
          _buildStatItem('彩种', lotteryType == 1 ? '福彩3D' : '排列三', Colors.white70),
        ]),
        const SizedBox(height: 12),
        Container(height: 1, color: Colors.white24),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _buildStatItem('总倍数', '${totalMultiplier.toStringAsFixed(1)}', Colors.white70),
          _buildStatItem('玩法种类', '$playTypeCount', Colors.white70),
          _buildStatItem('平均倍数', filteredBets.isNotEmpty ? '${(totalMultiplier / filteredBets.length).toStringAsFixed(1)}' : '0', Colors.white70),
        ]),
      ]),
    );
  }

  Widget _buildNumberStats(List filteredBets) {
    final playTypeMap = <String, List<dynamic>>{};
    for (final bet in filteredBets) {
      final key = '${bet.playType}|${bet.playTypeName}';
      playTypeMap.putIfAbsent(key, () => []);
      playTypeMap[key]!.add(bet);
    }

    final entries = playTypeMap.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppStyles.radiusSm), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('号码统计', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text('按玩法分组', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
        ]),
        const SizedBox(height: 12),
        ...entries.map((e) {
          final parts = e.key.split('|');
          final playTypeCode = parts[0];
          final playTypeName = parts[1];
          final bets = e.value;
          final config = PlayTypes.getByCode(playTypeCode);
          final color = config?.color ?? AppColors.primary;
          final amount = bets.fold<double>(0, (sum, b) => sum + b.multiplier * 2);
          final totalForType = bets.length;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.04), borderRadius: BorderRadius.circular(AppStyles.radiusXs), border: Border.all(color: color.withOpacity(0.15))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)), child: Text(playTypeName, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600))),
                  const SizedBox(width: 8),
                  Text('$totalForType注', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ]),
                Text('${amount.toStringAsFixed(1)}元', style: TextStyle(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 8),
              Wrap(spacing: 4, runSpacing: 4, children: bets.take(20).map((b) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(4)),
                child: Text('${b.number}${b.multiplier != 1.0 ? "×${b.multiplier}" : ""}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color, fontFamily: 'monospace')),
              )).toList()),
              if (bets.length > 20) Padding(padding: const EdgeInsets.only(top: 4), child: Text('...还有${bets.length - 20}条', style: TextStyle(fontSize: 10, color: AppColors.textLight)))),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(children: [
      Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: valueColor)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.white60)),
    ]);
  }
}
