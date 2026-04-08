import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/play_types.dart';
import '../../../providers/settings_provider.dart';

class OddsSelector extends StatelessWidget {
  final String selectedPlayType;
  final ValueChanged<String> onChanged;
  
  const OddsSelector({
    super.key,
    required this.selectedPlayType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    
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
              const Text('赔率选择', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text('开发者：杰哥网络科技', style: TextStyle(fontSize: 9, color: AppColors.textLight)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: PlayTypes.all.map((playType) {
              final isSelected = selectedPlayType == playType.code;
              final amount = settings.getPlayTypeAmount(playType.code);
              return ChoiceChip(
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      playType.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : playType.color,
                      ),
                    ),
                    Text(
                      '${amount.toStringAsFixed(1)}元',
                      style: TextStyle(
                        fontSize: 9,
                        color: isSelected ? Colors.white.withOpacity(0.9) : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                selected: isSelected,
                selectedColor: playType.color,
                backgroundColor: playType.color.withOpacity(0.05),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                onSelected: (selected) {
                  if (selected) onChanged(playType.code);
                },
              ),
            }).toList(),
          ),
        ],
      ),
    );
  }
}
