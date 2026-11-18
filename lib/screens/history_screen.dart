import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../utils/app_constants.dart';
import '../utils/app_theme.dart';
import '../widgets/deletion_undo_snackbar.dart';
import '../widgets/empty_state.dart';
import '../widgets/transaction_detail_sheet.dart';
import '../widgets/transaction_tile.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDelete(BuildContext context, TransactionModel transaction) {
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
              Navigator.pop(dialogCtx);
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

    return Scaffold(
      backgroundColor: colors.mainBackground,
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          Consumer<TransactionProvider>(
            builder: (context, provider, _) {
              final hasActiveFilters = provider.searchQuery.isNotEmpty ||
                  provider.typeFilter != null ||
                  provider.categoryFilter != null;

              if (!hasActiveFilters) return const SizedBox.shrink();

              return TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  provider.resetFilters();
                },
                icon: const Icon(Icons.clear_all_rounded, size: 18),
                label: const Text('Reset'),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<TransactionProvider>(
          builder: (context, provider, _) {
            final transactions = provider.filteredTransactions;
            final isSearchingOrFiltering = provider.searchQuery.isNotEmpty ||
                provider.typeFilter != null ||
                provider.categoryFilter != null;

            return Column(
              children: [
                // Search Field & Filter Row
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => provider.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Search by category, note, amount...',
                      prefixIcon: Icon(Icons.search_rounded, color: colors.textSecondary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                provider.setSearchQuery('');
                              },
                            )
                          : null,
                      fillColor: colors.cardBackground,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),

                // Type Filters (All, Income, Expense)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildTypeFilterChip(
                        context: context,
                        label: 'All',
                        isSelected: provider.typeFilter == null,
                        onSelected: () => provider.setTypeFilter(null),
                      ),
                      const SizedBox(width: 8),
                      _buildTypeFilterChip(
                        context: context,
                        label: 'Income',
                        isSelected: provider.typeFilter == TransactionType.income,
                        onSelected: () => provider.setTypeFilter(
                          provider.typeFilter == TransactionType.income
                              ? null
                              : TransactionType.income,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildTypeFilterChip(
                        context: context,
                        label: 'Expense',
                        isSelected: provider.typeFilter == TransactionType.expense,
                        onSelected: () => provider.setTypeFilter(
                          provider.typeFilter == TransactionType.expense
                              ? null
                              : TransactionType.expense,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(width: 1, height: 24, color: colors.borderBeige),
                      const SizedBox(width: 12),

                      // Category Filter Chips
                      ...ExpenseCategory.values.map((cat) {
                        final isSelected = provider.categoryFilter == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(cat.displayName),
                            avatar: Icon(
                              cat.icon,
                              size: 15,
                              color: isSelected
                                  ? colors.primarySageDark
                                  : colors.textSecondary,
                            ),
                            selected: isSelected,
                            onSelected: (_) {
                              provider.setCategoryFilter(isSelected ? null : cat);
                            },
                            backgroundColor: colors.cardBackground,
                            selectedColor: colors.secondaryOliveLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: isSelected
                                    ? colors.primarySage
                                    : colors.borderBeige,
                              ),
                            ),
                            labelStyle: TextStyle(
                              fontFamily: AppFonts.bodyFont,
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? colors.textPrimary : colors.textSecondary,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Transactions List or Empty State
                Expanded(
                  child: transactions.isEmpty
                      ? (isSearchingOrFiltering
                          ? EmptyState.filtered()
                          : EmptyState.transactions())
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          physics: const BouncingScrollPhysics(),
                          itemCount: transactions.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final txn = transactions[index];
                            return TransactionTile(
                              transaction: txn,
                              onTap: () => TransactionDetailSheet.show(context, txn),
                              onDelete: () => _confirmDelete(context, txn),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTypeFilterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    final colors = context.colors;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: colors.cardBackground,
      selectedColor: colors.primarySageLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? colors.primarySageDark : colors.borderBeige,
          width: 1,
        ),
      ),
      labelStyle: TextStyle(
        fontFamily: AppFonts.bodyFont,
        fontSize: 12.5,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? colors.primarySageDark : colors.textPrimary,
      ),
    );
  }
}
