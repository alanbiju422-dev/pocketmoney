import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../utils/app_theme.dart';
import '../utils/date_helpers.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  IconData _getIcon() {
    if (transaction.type == TransactionType.income) {
      return Icons.arrow_downward_rounded;
    }
    return transaction.category?.icon ?? Icons.credit_card_outlined;
  }

  Color _getIconColor(AppColorScheme colors) {
    if (transaction.type == TransactionType.income) {
      return colors.incomeGreen;
    }
    return colors.expenseTerracotta;
  }

  Color _getIconBackgroundColor(AppColorScheme colors) {
    if (transaction.type == TransactionType.income) {
      return colors.incomeGreenBackground;
    }
    return colors.expenseBackground;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isIncome = transaction.type == TransactionType.income;
    final amountPrefix = isIncome ? '+ ' : '- ';
    final amountColor = isIncome ? colors.incomeGreen : colors.expenseTerracotta;
    final iconColor = _getIconColor(colors);
    final iconBg = _getIconBackgroundColor(colors);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.borderBeige, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.2),
                    width: 0.8,
                  ),
                ),
                child: Icon(_getIcon(), size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      transaction.displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppFonts.headingFont,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (transaction.category != null && !isIncome) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: colors.secondaryBackground,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              transaction.category!.displayName,
                              style: TextStyle(
                                fontFamily: AppFonts.bodyFont,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          DateHelpers.formatRelativeOrDate(transaction.dateTime),
                          style: TextStyle(
                            fontFamily: AppFonts.bodyFont,
                            fontSize: 11.5,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$amountPrefix${transaction.formattedAmount}',
                style: TextStyle(
                  fontFamily: AppFonts.headingFont,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: amountColor,
                ),
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  color: colors.textSecondary.withValues(alpha: 0.7),
                  splashRadius: 18,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  tooltip: 'Delete transaction',
                  onPressed: onDelete,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
