import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/bet_record.dart';
import '../../../providers/bet_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/toast.dart';

class BetHistoryList extends StatefulWidget {
  const BetHistoryList({super.key});

  @override
  State<BetHistoryList> createState() => _BetHistoryListState();
}

class _BetHistoryListState extends State<BetHistoryList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _pageSize = 20;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BetRecord> _getFilteredBets() {
    final bets = Provider.of<BetProvider>(context).bets;
    if (_searchQuery.isEmpty) return bets;
    final query = _searchQuery.toLowerCase();
    return bets.where((b) =>
      b.number.toLowerCase().contains(query) ||
      b.playTypeName.toLowerCase().contains(query) ||
      b.playType.toLowerCase().contains(query)
    ).toList();
  }

  void _deleteBet(int id) async {
    await Provider.of<BetProvider>(context, listen: false).deleteBet(id);
    ToastUtil.success(context, '已删除');
  }

  void _confirmDelete(BetRecord bet) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('确认删除'),
      content: Text('确定要删除「${bet.number}」(${bet.playTypeName})这条记录吗？'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
          onPressed: () { Navigator.pop(ctx); if (bet.id != null) _deleteBet(bet.id!); },
          child: const Text('删除', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final filteredBets = _getFilteredBets();
    final displayBets = filteredBets.take(_pageSize).toList();
    final totalAmount = filteredBets.fold<double>(0, (sum, b) => sum + b.multiplier * b.baseAmount);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppStyles.radiusSm), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('投注记录', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Row(children: [
            Text('共${filteredBets.length}条', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Text('${totalAmount.toStringAsFixed(1)}元', style: TextStyle(fontSize: 11, color: AppColors.danger, fontWeight: FontWeight.w600))),
          ]),
        ]),
        const SizedBox(height: 10),
        TextField(controller: _searchController, onChanged: (v) => setState(() => _searchQuery = v), decoration: InputDecoration(hintText: '搜索号码/玩法...', prefixIcon: Icon(Icons.search, size: 18, color: AppColors.textLight), isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14))),
        const SizedBox(height: 12),
        if (displayBets.isEmpty)
          EmptyState(message: '暂无投注记录', icon: Icons.receipt_long_outlined)
        else
          ...displayBets.map((bet) => Dismissible(key: ValueKey(bet.id ?? '${bet.number}_${bet.playType}'), direction: DismissDirection.endToStart, background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(AppStyles.radiusXs)), child: const Icon(Icons.delete, color: Colors.white)), confirmDismiss: (_) async { _confirmDelete(bet); return false; }, child: _buildItem(bet))),
        if (_pageSize < filteredBets.length) Center(child: Padding(padding: const EdgeInsets.only(top: 8), child: TextButton.icon(onPressed: () => setState(() => _pageSize += 20), icon: const Icon(Icons.expand_more, size: 16), label: Text('加载更多 (${filteredBets.length - _pageSize})')))),
      ]),
    );
  }

  Widget _buildItem(BetRecord bet) {
    Color playColor = AppColors.primary;
    try {
      final cat = _getCategoryByPlayType(bet.playType);
      playColor = AppColors.playTypeColors[cat] ?? AppColors.primary;
    } catch (_) {}

    final amount = bet.multiplier * bet.baseAmount;

    return Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppStyles.radiusXs), border: Border.all(color: AppColors.border.withOpacity(0.5))), child: Row(children: [
      Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(bet.number, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        const SizedBox(height: 2),
        Text(DateFormat('MM-dd HH:mm').format(bet.createTime), style: TextStyle(fontSize: 10, color: AppColors.textLight)),
      ])),
      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), decoration: BoxDecoration(color: playColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text(bet.playTypeName, style: TextStyle(fontSize: 11, color: playColor, fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis)),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('${bet.multiplier}x', style: TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w600)),
        Text('${amount.toStringAsFixed(1)}元', style: TextStyle(fontSize: 11, color: AppColors.danger, fontWeight: FontWeight.w500)),
      ]),
      const SizedBox(width: 4),
      IconButton(icon: Icon(Icons.delete_outline, size: 18, color: AppColors.textLight), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => _confirmDelete(bet)),
    ]));
  }

  String _getCategoryByPlayType(String playType) {
    if (['single', 'group3', 'group6'].contains(playType)) return 'basic';
    if (['dan', 'pos1', 'pos2'].contains(playType)) return 'position';
    if (playType.startsWith('shuangfei')) return 'shuangfei';
    if (playType.startsWith('g3_') || playType == 'g3_all') return 'g3';
    if (playType.startsWith('g6_') || playType == 'g6_all') return 'g6';
    if (playType.startsWith('fs_') || playType == 'fs_all') return 'fs';
    if (playType.startsWith('span')) return 'span';
    return 'other';
  }
}
