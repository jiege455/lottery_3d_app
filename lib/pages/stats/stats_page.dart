import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/bet_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/empty_state.dart';
import 'widgets/hot_numbers.dart';
import 'widgets/miss_analysis.dart';
import 'widgets/playtype_stats.dart';
import 'widgets/export_panel.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<BetProvider>(context, listen: false).loadBets());
  }

  @override
  Widget build(BuildContext context) {
    final betProvider = Provider.of<BetProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
            child: const Text('统计分析', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          _buildOverviewCard(betProvider, settings),
          const HotNumbers(),
          const MissAnalysis(),
          const PlayTypeStats(),
          const ExportPanel(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(BetProvider provider, SettingsProvider settings) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppStyles.radiusSm), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _buildStatItem('总投注数', '${provider.totalBets}', AppColors.primary),
        _buildStatItem('彩种', settings.defaultLotteryType == 1 ? '福彩3D' : '排列三', AppColors.purple),
        _buildStatItem('玩法种类', '${provider.bets.map((b) => b.playType).toSet().length}', AppColors.cyan),
      ]),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(children: [
      Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
    ]);
  }
}
