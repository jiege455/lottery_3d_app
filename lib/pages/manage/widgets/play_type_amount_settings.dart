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
  final Map<String, TextEditingController> _amountControllers = {};
  final Map<String, TextEditingController> _payoutControllers = {};
  final TextEditingController _customCodeController = TextEditingController();
  final TextEditingController _customNameController = TextEditingController();
  final TextEditingController _customCategoryController = TextEditingController();
  final TextEditingController _customAmountController = TextEditingController();
  final TextEditingController _customPayoutController = TextEditingController();
  final TextEditingController _customColorController = TextEditingController(text: '#4F46E5');

  @override
  void initState() {
    super.initState();
    for (final pt in PlayTypes.all) {
      _amountControllers[pt.code] = TextEditingController();
      _payoutControllers[pt.code] = TextEditingController();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAmounts());
  }

  void _loadAmounts() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    for (final pt in PlayTypes.all) {
      final amount = settings.getPlayTypeAmount(pt.code);
      final payoutRate = settings.getPlayTypePayoutRate(pt.code);
      _amountControllers[pt.code]!.text = amount.toStringAsFixed(1);
      _payoutControllers[pt.code]!.text = payoutRate.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    for (final controller in _amountControllers.values) controller.dispose();
    for (final controller in _payoutControllers.values) controller.dispose();
    for (final controller in [_customCodeController, _customNameController, _customCategoryController, _customAmountController, _customPayoutController, _customColorController]) controller.dispose();
    super.dispose();
  }

  void _showAddCustomPlayTypeDialog() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('添加自定义玩法'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: _customCodeController, decoration: const InputDecoration(labelText: '玩法代码', hintText: '如：custom1'), helperText: '英文或数字，不能与现有玩法重复'),
          TextField(controller: _customNameController, decoration: const InputDecoration(labelText: '玩法名称', hintText: '如：自定义玩法')),
          TextField(controller: _customCategoryController, decoration: const InputDecoration(labelText: '所属分类', hintText: '如：自定义')),
          TextField(controller: _customAmountController, decoration: const InputDecoration(labelText: '投注金额', hintText: '2.0'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          TextField(controller: _customPayoutController, decoration: const InputDecoration(labelText: '赔付倍率', hintText: '0 表示使用默认'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          TextField(controller: _customColorController, decoration: const InputDecoration(labelText: '颜色代码', hintText: '#4F46E5')),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        ElevatedButton(
          onPressed: () {
            if (_customCodeController.text.isEmpty || _customNameController.text.isEmpty) {
              ToastUtil.warning(context, '请填写必填项');
              return;
            }
            final amount = double.tryParse(_customAmountController.text) ?? 2.0;
            final payoutRate = double.tryParse(_customPayoutController.text) ?? 0.0;
            Provider.of<SettingsProvider>(context, listen: false).addCustomPlayType(
              _customCodeController.text, _customNameController.text, _customCategoryController.text, amount, payoutRate, _customColorController.text);
            Navigator.pop(ctx);
            ToastUtil.success(context, '添加成功');
            _customCodeController.clear();
            _customNameController.clear();
            _customCategoryController.clear();
            _customAmountController.clear();
            _customPayoutController.clear();
          },
          child: const Text('添加'),
        ),
      ],
    ));
  }

  Future<void> _saveAmount(String playType) async {
    final amount = double.tryParse(_amountControllers[playType]!.text);
    final payoutRate = double.tryParse(_payoutControllers[playType]!.text) ?? 0.0;
    if (amount == null || amount <= 0) {
      ToastUtil.warning(context, '请输入有效金额');
      return;
    }
    await Provider.of<SettingsProvider>(context, listen: false).updatePlayTypeAmount(playType, amount, payoutRate);
  }

  Future<void> _resetAll() async {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('确认重置？'),
      content: const Text('将把所有玩法金额恢复为默认值。'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        ElevatedButton(onPressed: () async {
          Navigator.pop(ctx);
          await Provider.of<SettingsProvider>(context, listen: false).resetPlayTypeAmounts();
          _loadAmounts();
          ToastUtil.success(context, '已恢复默认值');
        }, child: const Text('确认重置')),
      ],
    ));
  }

  void _confirmDeleteCustom(String code, SettingsProvider settings) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('确认删除'),
      content: const Text('确定要删除这个自定义玩法吗？'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
          onPressed: () {
            Navigator.pop(ctx);
            settings.deleteCustomPlayType(code);
            ToastUtil.success(context, '已删除');
          },
          child: const Text('删除', style: TextStyle(color: Colors.white)),
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
          TextButton.icon(onPressed: _showAddCustomPlayTypeDialog, icon: const Icon(Icons.add, size: 18), label: const Text('添加玩法')),
          const SizedBox(width: 8),
          TextButton.icon(onPressed: _resetAll, icon: const Icon(Icons.restore, size: 18), label: const Text('恢复默认')),
        ],
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...PlayTypes.categories.map((category) {
                final playTypesInCategory = PlayTypes.getByCategory(category);
                if (playTypesInCategory.isEmpty) return const SizedBox.shrink();
                return _buildCategorySection(category, playTypesInCategory, settings);
              }),
              if (settings.customPlayTypes.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildCustomPlayTypesSection(settings),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategorySection(String category, List<PlayTypeConfig> playTypes, SettingsProvider settings) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: playTypes.first.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(category, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: playTypes.first.color)),
          ),
        ]),
      ),
      Card(
        margin: EdgeInsets.zero,
        child: Column(children: playTypes.asMap().entries.map((entry) {
          final pt = entry.value;
          final isLast = entry.key == playTypes.length - 1;
          final currentAmount = settings.getPlayTypeAmount(pt.code);
          final defaultAmount = pt.baseAmount;
          final isCustom = settings.playTypeAmounts.containsKey(pt.code);
          return _buildPlayTypeItem(pt.code, pt.name, defaultAmount, currentAmount, isCustom, settings, isLast);
        }).toList()),
      ),
      const SizedBox(height: 8),
    ]);
  }

  Widget _buildCustomPlayTypesSection(SettingsProvider settings) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text('自定义玩法 (${settings.customPlayTypes.length})', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success)),
          ),
        ]),
      ),
      Card(
        margin: EdgeInsets.zero,
        child: Column(children: settings.customPlayTypes.asMap().entries.map((entry) {
          final custom = entry.value;
          final isLast = entry.key == settings.customPlayTypes.length - 1;
          final code = custom['code'] as String;
          final name = custom['name'] as String;
          final amount = (custom['amount'] as num?)?.toDouble() ?? 2.0;
          return _buildPlayTypeItem(code, name, amount, settings.getPlayTypeAmount(code), settings.playTypeAmounts.containsKey(code), settings, isLast, isCustom: true, customData: custom);
        }).toList()),
      ),
    ]);
  }

  Widget _buildPlayTypeItem(String code, String name, double defaultAmount, double currentAmount, bool isCustomAmount, SettingsProvider settings, bool isLast, {bool isCustom = false, Map<String, dynamic>? customData}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: AppColors.border.withOpacity(0.3)))),
      child: Row(children: [
        Expanded(
          flex: 2,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
              if (isCustom) ...[
                const SizedBox(width: 6),
                Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: Text('自定义', style: TextStyle(fontSize: 9, color: AppColors.success))),
              ],
            ]),
            Text('默认：${defaultAmount.toStringAsFixed(1)}元', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
          ]),
        ),
        if (isCustom && customData != null) ...[
          IconButton(icon: Icon(Icons.delete_outline, color: AppColors.danger, size: 18), onPressed: () => _confirmDeleteCustom(code, settings), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
          const SizedBox(width: 4),
        ],
        Column(children: [
          SizedBox(
            width: 70,
            child: TextField(
              controller: _amountControllers[code],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6), labelText: '金额', labelStyle: TextStyle(fontSize: 10), suffixText: '元', suffixStyle: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _saveAmount(code),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 70,
            child: TextField(
              controller: _payoutControllers[code],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6), labelText: '赔付', labelStyle: TextStyle(fontSize: 10), suffixText: '倍', suffixStyle: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _saveAmount(code),
            ),
          ),
        ]),
        const SizedBox(width: 8),
        IconButton(icon: Icon(Icons.save, color: AppColors.primary, size: 20), onPressed: () => _saveAmount(code), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 36, minHeight: 36)),
      ]),
    );
  }
}
