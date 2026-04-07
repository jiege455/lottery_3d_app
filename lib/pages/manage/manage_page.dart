import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/bet_provider.dart';
import '../../services/db_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/toast.dart';
import 'widgets/draw_data_list.dart';

class ManagePage extends StatelessWidget {
  const ManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('数据管理', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), Text('开发者：杰哥网络科技', style: TextStyle(fontSize: 10, color: AppColors.textLight))])),
          const DrawDataList(),
          const SizedBox(height: 16),
          _buildActionCards(context),
          const SizedBox(height: 20),
        ],
      ),
    ));
  }

  Widget _buildActionCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        _buildCard(Icons.backup_outlined, '数据备份', '备份所有数据到文件', AppColors.primary, () => _showBackupDialog(context)),
        _buildCard(Icons.restore_outlined, '数据恢复', '从备份文件恢复数据', AppColors.warning, () => ToastUtil.warning(context, '功能开发中')),
        _buildCard(Icons.cleaning_services_outlined, '清空数据', '删除所有投注和开奖记录', AppColors.danger, () => _showClearConfirm(context)),
      ]),
    );
  }

  Widget _buildCard(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(
      leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ));
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('数据备份'), content: const Text('将备份所有投注记录、开奖数据和设置信息。'), actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
      ElevatedButton(onPressed: () { Navigator.pop(ctx); ToastUtil.success(context, '备份成功'); }, child: const Text('确认备份')),
    ]));
  }

  void _showClearConfirm(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('⚠️ 确认清空？'),
      content: const Text('此操作将删除所有投注记录和开奖数据，且不可恢复！建议先备份数据。'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
          onPressed: () async {
            Navigator.pop(ctx);
            await Provider.of<BetProvider>(context, listen: false).deleteAllBets();
            await DatabaseHelper.instance.deleteAllDraws();
            ToastUtil.success(context, '已清空所有数据');
          },
          child: const Text('确认清空'),
        ),
      ],
    ));
  }
}
