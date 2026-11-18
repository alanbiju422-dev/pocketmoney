import 'dart:async';
import '../models/transaction_model.dart';
import 'transaction_repository.dart';

/// Temporary In-Memory implementation of [TransactionRepository].
///
/// NOTE: Data stored in this repository lives only in RAM for development,
/// UI testing, and verification. All transactions will reset when the application restarts.
/// This implementation allows hot-reloading and UI/logic development while the permanent
/// database decision is finalized.
class MemoryTransactionRepository implements TransactionRepository {
  final List<TransactionModel> _transactions = [];
  final StreamController<List<TransactionModel>> _controller =
      StreamController<List<TransactionModel>>.broadcast();

  MemoryTransactionRepository({List<TransactionModel>? initialTransactions}) {
    if (initialTransactions != null && initialTransactions.isNotEmpty) {
      _transactions.addAll(initialTransactions);
      _sortByDate();
    }
  }

  void _sortByDate() {
    _transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  void _notify() {
    _sortByDate();
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_transactions));
    }
  }

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    _sortByDate();
    return List.unmodifiable(_transactions);
  }

  @override
  Future<TransactionModel?> getTransactionById(String id) async {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    // Avoid duplicate IDs
    _transactions.removeWhere((t) => t.id == transaction.id);
    _transactions.add(transaction);
    _notify();
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    _notify();
  }

  @override
  Future<void> clearAllTransactions() async {
    _transactions.clear();
    _notify();
  }

  @override
  Stream<List<TransactionModel>> watchTransactions() {
    return _controller.stream;
  }

  @override
  void dispose() {
    _controller.close();
  }
}
