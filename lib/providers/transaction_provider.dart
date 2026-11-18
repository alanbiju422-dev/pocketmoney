import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';
import '../services/transaction_service.dart';
import '../utils/app_constants.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_helpers.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository repository;
  late final TransactionService _service;
  StreamSubscription<List<TransactionModel>>? _subscription;

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currencySymbol = AppConstants.defaultCurrencySymbol;

  // Pending deletions map keyed by transaction ID for safe 5-second countdown & undo
  final Map<String, TransactionModel> _pendingDeletions = {};
  final Map<String, Timer> _pendingTimers = {};

  // History Screen Filters
  String _searchQuery = '';
  TransactionType? _typeFilter;
  ExpenseCategory? _categoryFilter;

  // Reports Screen Filters
  DateRangeFilterType _reportFilterType = DateRangeFilterType.monthly;
  DateTime _reportStartDate = DateHelpers.startOfMonth(DateTime.now());
  DateTime _reportEndDate = DateHelpers.endOfMonth(DateTime.now());

  TransactionProvider({required this.repository}) {
    _service = TransactionService(repository: repository);
    _init();
  }

  void _init() {
    _subscription = repository.watchTransactions().listen((updatedList) {
      _transactions = updatedList;
      notifyListeners();
    });
    loadTransactions();
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currencySymbol => _currencySymbol;

  List<TransactionModel> get transactions =>
      _transactions.where((t) => !_pendingDeletions.containsKey(t.id)).toList();

  /// Top 5 recent transactions for the Home Dashboard
  List<TransactionModel> get recentTransactions => transactions.take(5).toList();

  /// Filtered transactions for the History Screen
  List<TransactionModel> get filteredTransactions {
    return _service.filterTransactions(
      transactions: transactions,
      searchQuery: _searchQuery,
      typeFilter: _typeFilter,
      categoryFilter: _categoryFilter,
    );
  }

  // Balance & Financial Calculations
  int get availableBalancePaise => _service.calculateBalancePaise(transactions);
  double get availableBalanceRupees =>
      CurrencyFormatter.paiseToRupees(availableBalancePaise);
  String get formattedAvailableBalance =>
      CurrencyFormatter.formatPaise(availableBalancePaise, symbol: _currencySymbol);

  int get totalIncomePaise => _service.calculateTotalIncomePaise(transactions);
  double get totalIncomeRupees =>
      CurrencyFormatter.paiseToRupees(totalIncomePaise);
  String get formattedTotalIncome =>
      CurrencyFormatter.formatPaise(totalIncomePaise, symbol: _currencySymbol);

  int get totalExpensePaise => _service.calculateTotalExpensePaise(transactions);
  double get totalExpenseRupees =>
      CurrencyFormatter.paiseToRupees(totalExpensePaise);
  String get formattedTotalExpense =>
      CurrencyFormatter.formatPaise(totalExpensePaise, symbol: _currencySymbol);

  // Filters State
  String get searchQuery => _searchQuery;
  TransactionType? get typeFilter => _typeFilter;
  ExpenseCategory? get categoryFilter => _categoryFilter;

  DateRangeFilterType get reportFilterType => _reportFilterType;
  DateTime get reportStartDate => _reportStartDate;
  DateTime get reportEndDate => _reportEndDate;

  /// Computed Report summary based on active report range filter
  ReportSummary get reportSummary {
    return _service.generateReportSummary(
      transactions: transactions,
      startDate: _reportStartDate,
      endDate: _reportEndDate,
    );
  }

  String get reportDateRangeLabel {
    switch (_reportFilterType) {
      case DateRangeFilterType.daily:
        return 'Today (${DateHelpers.formatShortDate(_reportStartDate)})';
      case DateRangeFilterType.weekly:
        return '${DateHelpers.formatShortMonthDay(_reportStartDate)} - ${DateHelpers.formatShortDate(_reportEndDate)}';
      case DateRangeFilterType.monthly:
        return '${DateHelpers.formatShortMonthDay(_reportStartDate)} - ${DateHelpers.formatShortDate(_reportEndDate)}';
      case DateRangeFilterType.yearly:
        return '${_reportStartDate.year}';
      case DateRangeFilterType.custom:
        return '${DateHelpers.formatShortMonthDay(_reportStartDate)} - ${DateHelpers.formatShortDate(_reportEndDate)}';
    }
  }

  // Actions
  Future<void> loadTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transactions = await repository.getAllTransactions();
    } catch (e) {
      _errorMessage = 'Failed to load transactions: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add Money (Income)
  Future<void> addIncome(int amountPaise, {DateTime? dateTime}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.addIncome(amountPaise: amountPaise, dateTime: dateTime);
      _transactions = await repository.getAllTransactions();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Spend Money (Expense)
  Future<void> addExpense({
    required int amountPaise,
    required ExpenseCategory category,
    String? description,
    DateTime? dateTime,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.addExpense(
        amountPaise: amountPaise,
        category: category,
        description: description,
        dateTime: dateTime,
      );
      _transactions = await repository.getAllTransactions();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Stages a transaction for deletion with a 5-second countdown & undo window.
  /// Does not send deletion request to the backend until the 5-second countdown finishes.
  void stagePendingDeletion(
    TransactionModel transaction, {
    void Function(Object error)? onError,
    void Function()? onPermanentlyDeleted,
  }) {
    final id = transaction.id;

    // If a deletion was already pending for this ID, cancel previous timer
    _pendingTimers[id]?.cancel();

    _pendingDeletions[id] = transaction;
    notifyListeners();

    _pendingTimers[id] = Timer(const Duration(seconds: 5), () async {
      _pendingTimers.remove(id);
      try {
        await _service.deleteTransaction(id);
        _transactions = await repository.getAllTransactions();
        _pendingDeletions.remove(id);
        notifyListeners();
        onPermanentlyDeleted?.call();
      } catch (e) {
        // Backend deletion failed - restore transaction in UI and notify
        _pendingDeletions.remove(id);
        _errorMessage = 'Failed to delete transaction: $e';
        notifyListeners();
        onError?.call(e);
      }
    });
  }

  /// Cancels a pending deletion within the 5-second window.
  /// Keeps the transaction unchanged and never sends a delete request to the backend.
  bool cancelPendingDeletion(String id) {
    final timer = _pendingTimers.remove(id);
    timer?.cancel();
    final removed = _pendingDeletions.remove(id);
    if (removed != null || timer != null) {
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Checks if a transaction is currently pending deletion
  bool isPendingDeletion(String id) => _pendingDeletions.containsKey(id);

  /// Delete transaction immediately (permanent)
  Future<void> deleteTransaction(String id) async {
    _pendingTimers.remove(id)?.cancel();
    _pendingDeletions.remove(id);
    try {
      await _service.deleteTransaction(id);
      _transactions = await repository.getAllTransactions();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Clear all transactions
  Future<void> clearAllTransactions() async {
    try {
      await _service.clearAllTransactions();
      _transactions = await repository.getAllTransactions();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Filter setters
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setTypeFilter(TransactionType? type) {
    _typeFilter = type;
    notifyListeners();
  }

  void setCategoryFilter(ExpenseCategory? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _typeFilter = null;
    _categoryFilter = null;
    notifyListeners();
  }

  void setReportFilterType(
    DateRangeFilterType type, {
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    _reportFilterType = type;
    final now = DateTime.now();

    switch (type) {
      case DateRangeFilterType.daily:
        _reportStartDate = DateHelpers.startOfDay(now);
        _reportEndDate = DateHelpers.endOfDay(now);
        break;
      case DateRangeFilterType.weekly:
        _reportStartDate = DateHelpers.startOfWeek(now);
        _reportEndDate = DateHelpers.endOfWeek(now);
        break;
      case DateRangeFilterType.monthly:
        _reportStartDate = DateHelpers.startOfMonth(now);
        _reportEndDate = DateHelpers.endOfMonth(now);
        break;
      case DateRangeFilterType.yearly:
        _reportStartDate = DateHelpers.startOfYear(now);
        _reportEndDate = DateHelpers.endOfYear(now);
        break;
      case DateRangeFilterType.custom:
        if (customStart != null && customEnd != null) {
          _reportStartDate = DateHelpers.startOfDay(customStart);
          _reportEndDate = DateHelpers.endOfDay(customEnd);
        }
        break;
    }
    notifyListeners();
  }

  void setCurrency(String symbol) {
    _currencySymbol = symbol;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    for (final timer in _pendingTimers.values) {
      timer.cancel();
    }
    _pendingTimers.clear();
    _pendingDeletions.clear();
    repository.dispose();
    super.dispose();
  }
}
