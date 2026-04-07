import 'package:flutter/material.dart';
import '../../../core/utils/batch_parser.dart';
import '../../../core/theme/app_theme.dart';

class PreviewList extends StatelessWidget {
  final List<ParsedItem> items;
  const PreviewList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final displayItems = items.length > BatchParser.previewMax ? items.sublist(0, BatchParser.previewMax) : items;
    final hiddenCount = items.length - displayItems.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppStyles.radiusSm),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('预览列表 (${items.length}条)', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              if (hiddenCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('还有$hiddenCount条未显示', style: TextStyle(fontSize: 11, color: AppColors.warning)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ...displayItems.asMap().entries.map((entry) => _buildItem(context, entry.key + 1, entry.value)),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, ParsedItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 28, child: Text('$index', style: TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.w500))),
          Expanded(child: Text(item.number, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'monospace'))),
          if (item.multiplier != 1.0)
            Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text('×${item.multiplier}', style: TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w600)),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(item.playTypeName, style: TextStyle(fontSize: 11, color: item.color, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
