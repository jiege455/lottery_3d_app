import 'package:flutter/material.dart';
import '../../../core/constants/play_types.dart';
import '../../../core/theme/app_theme.dart';

class PlayTypeChips extends StatelessWidget {
  final String selectedPlayType;
  final ValueChanged<String> onChanged;

  const PlayTypeChips({super.key, required this.selectedPlayType, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppStyles.radiusSm), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('选择玩法', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 10),
          ...PlayTypes.categories.map((cat) => _buildCategorySection(cat)),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String category) {
    final types = PlayTypes.getByCategory(category);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(category, style: TextStyle(fontSize: 11, color: AppColors.textLight, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Wrap(spacing: 6, runSpacing: 6, children: types.map((pt) => _buildChip(pt)).toList()),
      ]),
    );
  }

  Widget _buildChip(PlayTypeConfig pt) {
    final isSelected = selectedPlayType == pt.code;
    return GestureDetector(
      onTap: () => onChanged(pt.code),
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
