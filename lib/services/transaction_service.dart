import 'dart:math';
import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';
import '../utils/app_constants.dart';
import '../utils/currency_formatter.dart';

enum DateRangeFilterType {
  daily,
  weekly,
  monthly,
  yearly,
  custom;

  String get displayName {
    switch (this) {
      case DateRangeFilterType.daily:
        return 'Today';
      case DateRangeFilterType.weekly:
        return 'This Week';
      case DateRangeFilterType.monthly:
        return 'This Month';
      case DateRangeFilterType.yearly:
        return 'This Year';
      case DateRangeFilterType.custom:
        return 'Custom';
    }
  }
}

class ReportSummary {
  final int totalIncomePaise;
  final int totalExpensePaise;
  final int netBalanceChangePaise;
  final Map<ExpenseCategory, int> categorySpendingPaise;
  final Map<DateTime, int> dailyExpenseTrendPaise;
  final int totalTransactionCount;

  const ReportSummary({
    required this.totalIncomePaise,
    required this.totalExpensePaise,
    required this.netBalanceChangePaise,
    required this.categorySpendingPaise,
    required this.dailyExpenseTrendPaise,
    required this.totalTransactionCount,
  });

  double get totalIncomeRupees => CurrencyFormatter.paiseToRupees(totalIncomePaise);
  double get totalExpenseRupees => CurrencyFormatter.paiseToRupees(totalExpensePaise);
  double get netBalanceChangeRupees => CurrencyFormatter.paiseToRupees(netBalanceChangePaise);

  /// Get percentage of spending for a given category (0 to 100)
  double getCategoryPercentage(ExpenseCategory category) {
    if (totalExpensePaise == 0) return 0.0;
    final categoryAmount = categorySpendingPaise[category] ?? 0;
    return (categoryAmount / totalExpensePaise) * 100.0;
  }
}

class TransactionValidationException implements Exception {
  final String message;
  const TransactionValidationException(this.message);

  @override
  String toString() => message;
}

/// Core business logic service for Pocket Money Tracker.
/// Operates exclusively through [TransactionRepository] interface.
class TransactionService {
  final TransactionRepository repository;
  final Random _random = Random();

  TransactionService({required this.repository});

  String _generateUniqueId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final salt = _random.nextInt(999999).toString().padLeft(6, '0');
    return 'txn_${now}_$salt';
  }

  /// Add Money (Income)
  /// Requires amount > 0.
  /// Never asks for a category, reason, or description.
  Future<TransactionModel> addIncome({
    required int amountPaise,
    DateTime? dateTime,
  }) async {
    if (amountPaise <= 0) {
      throw const TransactionValidationException('Amount must be greater than zero.');
    }

    final txnDate = dateTime ?? DateTime.now();
    final transaction = TransactionModel(
      id: _generateUniqueId(),
      type: TransactionType.income,
      amountPaise: amountPaise,
      category: null,
      description: null,
      dateTime: txnDate,
      createdAt: DateTime.now(),
    );

    await repository.addTransaction(transaction);
    return transaction;
  }

  /// Spend Money (Expense)
  /// Requires:
  /// - amount > 0
  /// - valid category
  /// - description if category == ExpenseCategory.other
  /// - amount <= available balance
  Future<TransactionModel> addExpense({
    required int amountPaise,
    required ExpenseCategory category,
    String? description,
    DateTime? dateTime,
  }) async {
    if (amountPaise <= 0) {
      throw const TransactionValidationException('Amount must be greater than zero.');
    }

    // Reason validation for Other category
    if (category == ExpenseCategory.other) {
      if (description == null || description.trim().isEmpty) {
        throw const TransactionValidationException(
          'Please provide a reason for "Other" expense.',
        );
      }
    }

    // Check available balance
    final allTransactions = await repository.getAllTransactions();
    final currentBalancePaise = calculateBalancePaise(allTransactions);

    if (amountPaise > currentBalancePaise) {
      final availableFormatted = CurrencyFormatter.formatPaise(currentBalancePaise);
      throw TransactionValidationException(
        'Insufficient balance. Your available balance is $availableFormatted.',
      );
    }

    final txnDate = dateTime ?? DateTime.now();
    final cleanDescription =
        (category == ExpenseCategory.other) ? description?.trim() : description?.trim();

    final transaction = TransactionModel(
      id: _generateUniqueId(),
      type: TransactionType.expense,
      amountPaise: amountPaise,
      category: category,
      description: (cleanDescription != null && cleanDescription.isNotEmpty)
          ? cleanDescription
          : null,
      dateTime: txnDate,
      createdAt: DateTime.now(),
    );

    await repository.addTransaction(transaction);
    return transaction;
  }

  /// Delete a transaction
  Future<void> deleteTransaction(String id) async {
    await repository.deleteTransaction(id);
  }

  /// Clear all transactions
  Future<void> clearAllTransactions() async {
    await repository.clearAllTransactions();
  }

  /// Fetch all transactions
  Future<List<TransactionModel>> getAllTransactions() async {
    return repository.getAllTransactions();
  }

  /// Calculate Available Balance in paise: Total Income - Total Expenses
  int calculateBalancePaise(List<TransactionModel> transactions) {
    int totalIncome = 0;
    int totalExpense = 0;

    for (final txn in transactions) {
      if (txn.type == TransactionType.income) {
        totalIncome += txn.amountPaise;
      } else {
        totalExpense += txn.amountPaise;
      }
    }

    return totalIncome - totalExpense;
  }

  /// Calculate Total Income in paise
  int calculateTotalIncomePaise(List<TransactionModel> transactions) {
    int totalIncome = 0;
    for (final txn in transactions) {
      if (txn.type == TransactionType.income) {
        totalIncome += txn.amountPaise;
      }
    }
    return totalIncome;
  }

  /// Calculate Total Expense in paise
  int calculateTotalExpensePaise(List<TransactionModel> transactions) {
    int totalExpense = 0;
    for (final txn in transactions) {
      if (txn.type == TransactionType.expense) {
        totalExpense += txn.amountPaise;
      }
    }
    return totalExpense;
  }

  /// Filter transactions by search query, type, and category
  List<TransactionModel> filterTransactions({
    required List<TransactionModel> transactions,
    String? searchQuery,
    TransactionType? typeFilter,
    ExpenseCategory? categoryFilter,
  }) {
    return transactions.where((txn) {
      // Type filter
      if (typeFilter != null && txn.type != typeFilter) {
        return false;
      }

      // Category filter
      if (categoryFilter != null) {
        if (txn.type != TransactionType.expense || txn.category != categoryFilter) {
          return false;
        }
      }

      // Search query
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.toLowerCase().trim();
        final title = txn.displayTitle.toLowerCase();
        final subtitle = (txn.displaySubtitle ?? '').toLowerCase();
        final amountStr = txn.amountRupees.toString();

        final matchesTitle = title.contains(query);
        final matchesSubtitle = subtitle.contains(query);
        final matchesAmount = amountStr.contains(query);

        if (!matchesTitle && !matchesSubtitle && !matchesAmount) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Filter transactions by Date Range
  List<TransactionModel> filterByDateRange({
    required List<TransactionModel> transactions,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return transactions.where((txn) {
      return (txn.dateTime.isAfter(startDate) ||
              txn.dateTime.isAtSameMomentAs(startDate)) &&
          (txn.dateTime.isBefore(endDate) ||
              txn.dateTime.isAtSameMomentAs(endDate));
    }).toList();
  }

  /// Generate Analytics and Summaries for a date range
  ReportSummary generateReportSummary({
    required List<TransactionModel> transactions,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final filtered = filterByDateRange(
      transactions: transactions,
      startDate: startDate,
      endDate: endDate,
    );

    int totalIncome = 0;
    int totalExpense = 0;
    final Map<ExpenseCategory, int> categorySpending = {
      ExpenseCategory.travel: 0,
      ExpenseCategory.food: 0,
      ExpenseCategory.college: 0,
      ExpenseCategory.other: 0,
    };

    final Map<DateTime, int> dailyTrend = {};

    for (final txn in filtered) {
      final dayKey = DateTime(txn.dateTime.year, txn.dateTime.month, txn.dateTime.day);

      if (txn.type == TransactionType.income) {
        totalIncome += txn.amountPaise;
      } else {
        totalExpense += txn.amountPaise;
        if (txn.category != null) {
          categorySpending[txn.category!] =
              (categorySpending[txn.category!] ?? 0) + txn.amountPaise;
        }

        dailyTrend[dayKey] = (dailyTrend[dayKey] ?? 0) + txn.amountPaise;
      }
    }

    return ReportSummary(
      totalIncomePaise: totalIncome,
      totalExpensePaise: totalExpense,
      netBalanceChangePaise: totalIncome - totalExpense,
      categorySpendingPaise: categorySpending,
      dailyExpenseTrendPaise: dailyTrend,
      totalTransactionCount: filtered.length,
    );
  }
}
