import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../models/bet_record.dart';
import '../../../../providers/bet_provider.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../widgets/toast.dart';

class ExportPanel extends StatelessWidget {
  const ExportPanel({super.key});

  String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  String _generateCSV(List<BetRecord> bets) {
    final buf = StringBuffer();
    buf.writeln('\uFEFF序号,彩种,玩法,号码,倍数,金额(元),录入时间');
    for (var i = 0; i < bets.length; i++) {
      final b = bets[i];
      final amount = (b.multiplier * b.baseAmount).toStringAsFixed(1);
      buf.writeln('${i + 1},${_escapeCsvField(b.lotteryType == 1 ? "福彩3D" : "排列三")},${_escapeCsvField(b.playTypeName)},${_escapeCsvField(b.number)},${b.multiplier},$amount,${DateFormat('yyyy-MM-dd HH:mm:ss').format(b.createTime)}');
    }
    final totalAmount = bets.fold<double>(0, (sum, b) => sum + b.multiplier * b.baseAmount);
    buf.writeln(',,,,合计:,${totalAmount.toStringAsFixed(1)}元,');
    return buf.toString();
  }

  String _generateTXT(List<BetRecord> bets) {
    final totalAmount = bets.fold<double>(0, (sum, b) => sum + b.multiplier * b.baseAmount);
    final lines = <String>['=' * 55, '福彩3D/排列三 投注记录导出', '=' * 55, '', '开发者：杰哥网络科技 · QQ 2711793818', '', '导出时间：${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}', '', '总记录数：${bets.length}', '总金额：${totalAmount.toStringAsFixed(1)}元', '', '-' * 55];
    for (var i = 0; i < bets.length; i++) {
      final b = bets[i];
      final lotteryName = b.lotteryType == 1 ? '福彩3D' : '排列三';
      final amount = (b.multiplier * b.baseAmount).toStringAsFixed(1);
      lines.add('${(i + 1).toString().padRight(4)} | ${lotteryName.padRight(6)} | ${b.playTypeName.padRight(8)} | ${b.number.padLeft(6)} | ${b.multiplier.toString().padLeft(4)}x | ${amount.padLeft(6)}元 | ${DateFormat('MM-dd HH:mm').format(b.createTime)}');
    }
    lines.add('-' * 55);
    lines.add('合计：${bets.length}条  ${totalAmount.toStringAsFixed(1)}元');
    return lines.join('\n');
  }

  void _showExportDialog(BuildContext context, List<BetRecord> bets) {
    showModalBottomSheet(context: context, builder: (ctx) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('数据导出', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ListTile(leading: Icon(Icons.table_chart, color: AppColors.primary), title: const Text('导出CSV文件'), subtitle: const Text('Excel兼容格式，含金额列'), onTap: () { Navigator.pop(ctx); final csv = _generateCSV(bets); Share.shareXFiles([XFile.fromData(utf8.encode(csv), name: '投注记录_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.csv')]); }),
        ListTile(leading: Icon(Icons.description, color: AppColors.cyan), title: const Text('导出TXT文本'), subtitle: const Text('纯文本格式，含金额合计'), onTap: () { Navigator.pop(ctx); final txt = _generateTXT(bets); Share.shareXFiles([XFile.fromData(utf8.encode(txt), name: '投注记录_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.txt')]); }),
        ListTile(leading: Icon(Icons.copy, color: AppColors.purple), title: const Text('复制到剪贴板'), subtitle: const Text('复制格式化文本'), onTap: () async { Navigator.pop(ctx); final txt = _generateTXT(bets); await Share.share(txt); }),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final betProvider = Provider.of<BetProvider>(context);
    final lotteryType = Provider.of<SettingsProvider>(context).defaultLotteryType;
    final bets = betProvider.bets.where((b) => b.lotteryType == lotteryType).toList();
    if (bets.isEmpty) return const SizedBox.shrink();
    final totalAmount = bets.fold<double>(0, (sum, b) => sum + b.multiplier * b.baseAmount);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppStyles.radiusSm), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)]),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.upload_file_outlined, color: AppColors.primary, size: 28),
        title: const Text('数据导出', style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('共 ${bets.length} 条记录 / ${totalAmount.toStringAsFixed(1)}元', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showExportDialog(context, bets),
      ),
    );
  }
}
