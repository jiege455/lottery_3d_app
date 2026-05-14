import 'package:flutter/material.dart';
import '../../../core/constants/play_types.dart';
import '../../../core/theme/app_theme.dart';

class PlayTypeChips extends StatefulWidget {
  final String selectedPlayType;
  final ValueChanged<String> onChanged;

  const PlayTypeChips({super.key, required this.selectedPlayType, required this.onChanged});

  @override
  State<PlayTypeChips> createState() => _PlayTypeChipsState();
}

class _PlayTypeChipsState extends State<PlayTypeChips> {
  final Set<String> _expandedCategories = {};
  bool _showAllCategories = false;

  // 常用玩法
  static const List<String> _quickPlayTypes = [
    'auto',
    'single',
    'group3',
    'group6',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppStyles.radiusSm), boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('选择玩法', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              if (widget.selectedPlayType != 'auto')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: PlayTypes.getByCode(widget.selectedPlayType)?.color.withAlpha(26) ?? AppColors.primary.withAlpha(26),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    PlayTypes.getByCode(widget.selectedPlayType)?.name ?? '自动识别',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: PlayTypes.getByCode(widget.selectedPlayType)?.color ?? AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // 快速选择栏
          _buildQuickSelectBar(),
          const SizedBox(height: 8),
          // 更多分类
          if (_showAllCategories) ...[
            ...PlayTypes.categories.map((cat) => _buildCategorySection(cat)),
          ] else ...[
            // 显示当前选中玩法所在的分类（如果不在快速栏中）
            if (widget.selectedPlayType != 'auto' && !_isQuickPlayType(widget.selectedPlayType))
              _buildSelectedPlayTypeInfo(),
          ],
        ],
      ),
    );
  }

  bool _isQuickPlayType(String code) {
    return _quickPlayTypes.contains(code);
  }

  Widget _buildQuickSelectBar() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // 自动识别
        _buildQuickChip('auto', '自动识别', Icons.auto_awesome, AppColors.primary),
        // 常用玩法
        ..._quickPlayTypes.where((code) => code != 'auto').map((code) {
          final config = PlayTypes.getByCode(code);
          if (config == null) return const SizedBox.shrink();
          return _buildQuickChip(code, config.name, null, config.color);
        }),
        // 更多按钮
        _buildMoreButton(),
      ],
    );
  }

  Widget _buildQuickChip(String code, String label, IconData? icon, Color color) {
    final isSelected = widget.selectedPlayType == code;
    return GestureDetector(
      onTap: () => widget.onChanged(code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: isSelected ? Colors.white : color),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showAllCategories = !_showAllCategories;
          if (_showAllCategories) {
            // 展开时，默认展开基础三码和选中玩法所在分类
            _expandedCategories.clear();
            _expandedCategories.add('基础三码');
            if (widget.selectedPlayType != 'auto') {
              final config = PlayTypes.getByCode(widget.selectedPlayType);
              if (config != null) {
                _expandedCategories.add(config.category);
              }
            }
          } else {
            _expandedCategories.clear();
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _showAllCategories ? AppColors.primary.withAlpha(26) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withAlpha(100), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _showAllCategories ? '收起' : '更多',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              _showAllCategories ? Icons.expand_less : Icons.expand_more,
              size: 16,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedPlayTypeInfo() {
    final config = PlayTypes.getByCode(widget.selectedPlayType);
    if (config == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: config.color.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: config.color.withAlpha(50)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: config.color, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 8),
          Text(
            config.name,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: config.color),
          ),
          const SizedBox(width: 8),
          Text(
            config.ruleText,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String category) {
    final isExpanded = _expandedCategories.contains(category);
    final types = PlayTypes.getByCategory(category);
    final selectedInCategory = types.any((pt) => pt.code == widget.selectedPlayType);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedCategories.remove(category);
              } else {
                _expandedCategories.add(category);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            decoration: BoxDecoration(
              color: selectedInCategory ? AppColors.primary.withAlpha(20) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(isExpanded ? Icons.expand_less : Icons.chevron_right, size: 16, color: selectedInCategory ? AppColors.primary : AppColors.textLight),
                const SizedBox(width: 4),
                Text(category, style: TextStyle(fontSize: 12, color: selectedInCategory ? AppColors.primary : AppColors.textLight, fontWeight: selectedInCategory ? FontWeight.w600 : FontWeight.w500)),
                if (selectedInCategory) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(3)),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Wrap(spacing: 6, runSpacing: 6, children: types.map((pt) => _buildChip(pt)).toList()),
          ),
          const SizedBox(height: 4),
        ],
      ]),
    );
  }

  Widget _buildChip(PlayTypeConfig pt) {
    final isSelected = widget.selectedPlayType == pt.code;
    return GestureDetector(
      onTap: () => widget.onChanged(pt.code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? pt.color : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? pt.color : Colors.transparent, width: 1),
        ),
        child: Text(pt.name, style: TextStyle(color: isSelected ? Colors.white : AppColors.primary, fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500)),
      ),
    );
  }
}
