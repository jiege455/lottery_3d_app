import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/play_types.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/settings_provider.dart';
import '../../../widgets/toast.dart';

class PlayTypeAmountSettingsPage extends StatefulWidget {
  const PlayTypeAmountSettingsPage({super.key});

  @override
  State<PlayTypeAmountSettingsPage> createState() => _PlayTypeAmountSettingsPageState();
}

class _PlayTypeAmountSettingsPageState extends State<PlayTypeAmountSettingsPage> {
  final Map<String, TextEditingController> _controllers = {};
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    for (final pt in PlayTypes.all) {
      _controllers[pt.code] = TextEditingController();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAmounts();
    });
  }

  void _loadAmounts() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    for (final pt in PlayTypes.all) {
      final amount = settings.getPlayTypeAmount(pt.code);
      _controllers[pt.code]!.text = amount.toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveAmount(String playType) async {
    final amount = double.tryParse(_controllers[playType]!.text);
    if (amount == null || amount <= 0) {
      ToastUtil.warning(context, '请输入有效金额');
      return;
    }
    await Provider.of<SettingsProvider>(context, listen: false).updatePlayTypeAmount(playType, amount);
  }

  Future<void> _resetAll() async {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('确认重置？'),
      content: const Text('将把所有玩法金额恢复为默认值。'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(ctx);
            await Provider.of<SettingsProvider>(context, listen: false).resetPlayTypeAmounts();
            _loadAmounts();
            _hasChanges = false;
            ToastUtil.success(context, '已恢复默认值');
          },
          child: const Text('确认重置'),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('玩法金额设置'),
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _resetAll,
            icon: const Icon(Icons.restore, size: 18),
            label: const Text('恢复默认'),
          ),
        ],
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: PlayTypes.categories.length,
            itemBuilder: (context, index) {
              final category = PlayTypes.categories[index];
              final playTypesInCategory = PlayTypes.getByCategory(category);
              if (playTypesInCategory.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: playTypesInCategory.first.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(category, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: playTypesInCategory.first.color)),
                        ),
                      ],
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: playTypesInCategory.asMap().entries.map((entry) {
                        final pt = entry.value;
                        final isLast = entry.key == playTypesInCategory.length - 1;
                        final currentAmount = settings.getPlayTypeAmount(pt.code);
                        final defaultAmount = pt.baseAmount;
                        final isCustom = settings.playTypeAmounts.containsKey(pt.code);

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: isLast ? null : Border(bottom: BorderSide(color: AppColors.border.withOpacity(0.3))),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(pt.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                    Text('默认: ${defaultAmount.toStringAsFixed(1)}元', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                                  ],
                                ),
                              ),
                              if (isCustom)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('已修改', style: TextStyle(fontSize: 10, color: AppColors.success)),
                                ),
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  controller: _controllers[pt.code],
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 15),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    suffixText: '元',
                                    suffixStyle: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                  onChanged: (_) {
                                    setState(() => _hasChanges = true);
                                  },
                                  onSubmitted: (_) => _saveAmount(pt.code),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(Icons.save, color: AppColors.primary, size: 20),
                                onPressed: () => _saveAmount(pt.code),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          );
        },
      ),
    );
  }
}