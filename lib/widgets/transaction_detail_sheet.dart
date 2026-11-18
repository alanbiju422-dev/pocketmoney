import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../utils/app_theme.dart';
import '../utils/date_helpers.dart';
import 'deletion_undo_snackbar.dart';

class TransactionDetailSheet extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailSheet({super.key, required this.transaction});

  static void show(BuildContext context, TransactionModel transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => TransactionDetailSheet(transaction: transaction),
    );
  }

  void _confirmDelete(BuildContext context) {
    final colors = context.colors;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Are you sure you want to delete this transaction?',
          style: TextStyle(
            fontFamily: AppFonts.headingFont,
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: colors.textPrimary,
          ),
        ),
        content: Text(
          'You will have 5 seconds to undo this action before it is permanently removed.',
          style: TextStyle(
            fontFamily: AppFonts.bodyFont,
            fontSize: 13.5,
            color: colors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.supportingTerracotta,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogCtx); // close dialog
              Navigator.pop(context); // close bottom sheet
              final provider = Provider.of<TransactionProvider>(context, listen: false);
              provider.stagePendingDeletion(
                transaction,
                onError: (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete transaction: $error'),
                        backgroundColor: colors.supportingTerracotta,
                      ),
                    );
                  }
                },
              );
              showDeletionUndoSnackBar(
                context: context,
                transaction: transaction,
                onUndo: () => provider.cancelPendingDeletion(transaction.id),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isIncome = transaction.type == TransactionType.income;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.borderBeige,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TRANSACTION DETAILS',
                  style: TextStyle(
                    fontFamily: AppFonts.bodyFont,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: colors.textSecondary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                  color: colors.textSecondary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Amount display card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: isIncome
                    ? colors.incomeGreenBackground
                    : colors.expenseBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isIncome
                      ? colors.incomeGreen.withValues(alpha: 0.2)
                      : colors.expenseTerracotta.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    isIncome ? 'MONEY ADDED' : 'EXPENSE INCURRED',
                    style: TextStyle(
                      fontFamily: AppFonts.bodyFont,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                      color: isIncome ? colors.incomeGreen : colors.expenseTerracotta,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${isIncome ? '+' : '-'} ${transaction.formattedAmount}',
                    style: TextStyle(
                      fontFamily: AppFonts.headingFont,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: isIncome ? colors.incomeGreen : colors.expenseTerracotta,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Detail items
            _buildDetailRow(context, 'Date & Time', DateHelpers.formatDateTime(transaction.dateTime)),
            Divider(color: colors.borderBeige, height: 16),
            if (!isIncome && transaction.category != null) ...[
              _buildDetailRow(context, 'Category', transaction.category!.displayName),
              Divider(color: colors.borderBeige, height: 16),
            ],
            if (transaction.description != null && transaction.description!.isNotEmpty) ...[
              _buildDetailRow(context, 'Description', transaction.description!),
              Divider(color: colors.borderBeige, height: 16),
            ],
            _buildDetailRow(context, 'Reference ID', transaction.id),
            const SizedBox(height: 24),

            // Delete action button
            OutlinedButton.icon(
              onPressed: () => _confirmDelete(context),
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('Delete Transaction'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.supportingTerracotta,
                side: BorderSide(color: colors.supportingTerracotta, width: 1),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.bodyFont,
              fontSize: 13,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontFamily: AppFonts.bodyFont,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
