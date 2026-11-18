import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class QuickActionButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final bool isIncome;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.label,
    required this.subtitle,
    required this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    this.isIncome = true,
    required this.onTap,
  });

  factory QuickActionButton.addMoney({required VoidCallback onTap}) {
    return QuickActionButton(
      label: 'Add Money',
      subtitle: 'Deposit funds',
      icon: Icons.add_rounded,
      isIncome: true,
      onTap: onTap,
    );
  }

  factory QuickActionButton.spendMoney({required VoidCallback onTap}) {
    return QuickActionButton(
      label: 'Spend Money',
      subtitle: 'Record expense',
      icon: Icons.arrow_outward_rounded,
      isIncome: false,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final resolvedIconColor = iconColor ?? (isIncome ? colors.incomeGreen : colors.expenseTerracotta);
    final resolvedBgColor = iconBackgroundColor ?? (isIncome ? colors.incomeGreenBackground : colors.expenseBackground);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.borderBeige, width: 1.1),
            boxShadow: [
              BoxShadow(
                color: colors.surfaceElevation,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: resolvedBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: resolvedIconColor.withValues(alpha: 0.2),
                    width: 0.8,
                  ),
                ),
                child: Icon(icon, color: resolvedIconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: AppFonts.headingFont,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: AppFonts.bodyFont,
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colors.borderBeige,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
