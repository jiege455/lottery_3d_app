import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/play_types.dart';
import '../../../providers/settings_provider.dart';
import '../../../services/check_service.dart';

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
          const Text('赔率选择', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: PlayTypes.all.map((playType) {
              final isSelected = selectedPlayType == playType.code;
              final amount = settings.getPlayTypeAmount(playType.code);
              final odds = CheckService.oddsMap[playType.code] ?? 0.0;
              final winAmount = amount * odds;
              return GestureDetector(
                onTap: () => onChanged(playType.code),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? playType.color : playType.color.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? playType.color : AppColors.border.withOpacity(0.3),
                      width: isSelected ? 1.5 : 0.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        playType.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : playType.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '1赔${odds.toStringAsFixed(odds == odds.roundToDouble() ? 0 : 1)}',
                        style: TextStyle(
                          fontSize: 9,
                          color: isSelected ? Colors.white.withOpacity(0.85) : AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '中${winAmount.toStringAsFixed(winAmount == winAmount.roundToDouble() ? 0 : 1)}',
                        style: TextStyle(
                          fontSize: 9,
                          color: isSelected ? Colors.white.withOpacity(0.85) : AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
