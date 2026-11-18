import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  factory EmptyState.transactions({VoidCallback? onAddMoney}) {
    return EmptyState(
      icon: Icons.history_edu_outlined,
      title: 'Ledger is Empty',
      message:
          'No activity recorded yet. Add money to your balance or record your first daily expense.',
      actionLabel: onAddMoney != null ? 'Add Money' : null,
      onAction: onAddMoney,
    );
  }

  factory EmptyState.filtered() {
    return const EmptyState(
      icon: Icons.search_off_outlined,
      title: 'No Matching Entries',
      message: 'No transactions found for the selected search query or category filter.',
    );
  }

  factory EmptyState.reports() {
    return const EmptyState(
      icon: Icons.pie_chart_outline_rounded,
      title: 'No Data for Period',
      message: 'There are no income or expense transactions in this date range.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: colors.secondaryBackground,
                shape: BoxShape.circle,
                border: Border.all(color: colors.borderBeige, width: 1.2),
              ),
              child: Icon(icon, size: 30, color: colors.primarySageDark),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.headingFont,
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.bodyFont,
                fontSize: 13.5,
                color: colors.textSecondary,
                height: 1.4,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: Text(actionLabel!),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.textPrimary,
                  side: BorderSide(color: colors.primarySage, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  textStyle: const TextStyle(
                    fontFamily: AppFonts.bodyFont,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
