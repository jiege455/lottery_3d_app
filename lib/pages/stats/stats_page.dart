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
        try {
          Provider.of<BetProvider>(context, listen: false).loadBets();
        } catch (e) {
          print('StatsPage.loadBets error: $e');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final betProvider = Provider.of<BetProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);

    final totalAmount = betProvider.bets.fold<double>(0, (sum, b) => sum + b.multiplier * 2);
    final totalMultiplier = betProvider.bets.fold<double>(0, (sum, b) => sum + b.multiplier);

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
            _buildOverviewCard(betProvider, settings, totalAmount, totalMultiplier),
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

  Widget _buildOverviewCard(BetProvider provider, SettingsProvider settings, double totalAmount, double totalMultiplier) {
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
          _buildStatItem('总投注数', '${provider.totalBets}', Colors.white),
          _buildStatItem('总金额', '${totalAmount.toStringAsFixed(1)}元', Colors.yellowAccent),
          _buildStatItem('彩种', settings.defaultLotteryType == 1 ? '福彩3D' : '排列三', Colors.white70),
        ]),
        const SizedBox(height: 12),
        Container(height: 1, color: Colors.white24),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _buildStatItem('总倍数', '${totalMultiplier.toStringAsFixed(1)}', Colors.white70),
          _buildStatItem('玩法种类', '${provider.bets.map((b) => b.playType).toSet().length}', Colors.white70),
          _buildStatItem('平均倍数', provider.totalBets > 0 ? '${(totalMultiplier / provider.totalBets).toStringAsFixed(1)}' : '0', Colors.white70),
        ]),
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
