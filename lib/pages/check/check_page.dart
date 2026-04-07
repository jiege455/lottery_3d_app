import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/bet_record.dart';
import '../../../models/draw_record.dart';
import '../../../providers/bet_provider.dart';
import '../../../services/check_service.dart';
import '../../../widgets/toast.dart';

class CheckPage extends StatefulWidget {
  const CheckPage({super.key});

  @override
  State<CheckPage> createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage> {
  final TextEditingController _issueController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  List<CheckResult> _results = [];
  bool _checking = false;
  bool _betsLoaded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_betsLoaded) {
      _betsLoaded = true;
      Provider.of<BetProvider>(context, listen: false).loadBets();
    }
  }

  @override
  void dispose() {
    _issueController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  void _startCheck() {
    final issue = _issueController.text.trim();
    final numbers = _numberController.text.trim();

    if (numbers.length != 3 || !RegExp(r'^[0-9]{3}$').hasMatch(numbers)) {
      ToastUtil.warning(context, '请输入3位有效开奖号码');
      return;
    }

    final bets = Provider.of<BetProvider>(context, listen: false).bets;
    if (bets.isEmpty) {
      ToastUtil.warning(context, '暂无投注记录');
      return;
    }

    setState(() => _checking = true);

    final draw = DrawRecord(
      issue: issue.isEmpty ? '手动录入' : issue,
      numbers: numbers,
      sumValue: DrawRecord.getSumValue(numbers),
      span: DrawRecord.getSpan(numbers),
      formType: DrawRecord.getFormType(numbers),
      drawDate: DateTime.now(),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final results = CheckService.checkAll(bets, draw);
      setState(() {
        _results = results;
        _checking = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(20, 28, 20, 16), child: const Text('中奖校验', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
        _buildInputCard(),
        if (_checking) const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
        if (!_checking && _results.isNotEmpty) ...[
          _buildSummaryCard(),
          const SizedBox(height: 8),
          ..._buildResultList(),
        ],
        if (!_checking && _results.isEmpty)
          Padding(padding: const EdgeInsets.all(32), child: Column(children: [
            Icon(Icons.verified_outlined, size: 64, color: AppColors.textLight),
            const SizedBox(height: 12),
            Text('输入开奖号码开始校验', style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
          ])),
      ]),
    );
  }

  Widget _buildInputCard() {
    return Container(margin: const EdgeInsets.symmetric(horizontal: 16), padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppStyles.radiusSm), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)]), child: Column(children: [
      Row(children: [
        Expanded(child: TextField(controller: _issueController, decoration: InputDecoration(hintText: '期号(可选)', isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)))),
        const SizedBox(width: 12),
        SizedBox(width: 120, child: TextField(controller: _numberController, maxLength: 3, keyboardType: TextInputType.number, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 6), decoration: InputDecoration(hintText: '号码', counterText: '', isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)))),
      ]),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(onPressed: _startCheck, icon: Icon(_checking ? Icons.hourglass_empty : Icons.search, size: 18), label: Text(_checking ? '校验中...' : '开始校验', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)))),
    ]));
  }

  Widget _buildSummaryCard() {
    final totalBet = _results.fold<double>(0, (sum, r) => sum + r.betAmount);
    final totalWin = _results.fold<double>(0, (sum, r) => sum + r.winAmount);
    final profit = totalWin - totalBet;
    final winCount = CheckService.getWinCount(_results);
    final loseCount = CheckService.getLoseCount(_results);

    return Container(margin: const EdgeInsets.symmetric(horizontal: 16), padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppStyles.radiusSm), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)]), child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _buildStatItem('总投注', '${totalBet.toStringAsFixed(1)}元', AppColors.primary),
        _buildStatItem('总中奖', '${totalWin.toStringAsFixed(1)}元', AppColors.success),
        _buildStatItem(profit >= 0 ? '盈利' : '亏损', '${profit.abs().toStringAsFixed(1)}元', profit >= 0 ? AppColors.success : AppColors.danger),
      ]),
      const Divider(height: 24),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _buildStatItem2('$winCount', '中奖注数', AppColors.success),
        _buildStatItem2('$loseCount', '未中注数', AppColors.textLight),
        _buildStatItem2('${_results.length}', '总注数', AppColors.primary),
      ]),
    ]));
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(children: [
      Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      const SizedBox(height: 4), Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
    ]);
  }

  Widget _buildStatItem2(String value, String label, Color color) {
    return Column(children: [
      Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
      const SizedBox(height: 4), Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
    ]);
  }

  List<Widget> _buildResultList() {
    final winResults = _results.where((r) => r.isWin).toList();
    final loseResults = _results.where((r) => !r.isWin).toList();

    return [
      if (winResults.isNotEmpty) ...[
        _buildSectionHeader('🎉 中奖记录 (${winResults.length})', AppColors.success),
        ...winResults.map((r) => _buildResultItem(r, true)),
      ],
      if (loseResults.isNotEmpty) ...[
        _buildSectionHeader('❌ 未中记录 (${loseResults.length})', AppColors.textLight),
        ...loseResults.take(30).map((r) => _buildResultItem(r, false)),
        if (loseResults.length > 30) Center(child: Padding(padding: const EdgeInsets.all(12), child: Text('... 还有 ${loseResults.length - 30} 条未中记录', style: TextStyle(fontSize: 12, color: AppColors.textLight)))),
      ],
    ];
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Container(margin: const EdgeInsets.fromLTRB(16, 12, 16, 4), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(AppStyles.radiusXs)), child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)));
  }

  Widget _buildResultItem(CheckResult result, bool isWin) {
    return Container(margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: isWin ? AppColors.success.withOpacity(0.06) : Colors.transparent, borderRadius: BorderRadius.circular(AppStyles.radiusXs)), child: Row(children: [
      Expanded(flex: 2, child: Text(result.bet.number, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'monospace'))),
      Expanded(child: Text(result.bet.playTypeName, style: TextStyle(fontSize: 11, color: AppColors.textSecondary))),
      SizedBox(width: 50, child: Text('${result.betAmount}注', style: TextStyle(fontSize: 11, color: AppColors.textSecondary), textAlign: TextAlign.right)),
      if (isWin) ...[
        const SizedBox(width: 8),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.15), borderRadius: BorderRadius.circular(6)), child: Text('+${result.winAmount.toStringAsFixed(1)}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.success))),
      ] else ...[
        const SizedBox(width: 8),
        Text('-${result.betAmount.toStringAsFixed(1)}', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
      ],
    ]));
  }
}
