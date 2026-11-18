import '../models/transaction_model.dart';

/// Abstract contract for transaction storage.
///
/// Decouples UI and business logic from specific persistence engines
/// (e.g., In-Memory, SQLite, Supabase, Firebase, PostgreSQL).
abstract class TransactionRepository {
  /// Retrieve all transactions ordered by dateTime descending (newest first).
  Future<List<TransactionModel>> getAllTransactions();

  /// Retrieve a single transaction by ID.
  Future<TransactionModel?> getTransactionById(String id);

  /// Add a new transaction record.
  Future<void> addTransaction(TransactionModel transaction);

  /// Delete a transaction by ID.
  Future<void> deleteTransaction(String id);

  /// Delete all stored transactions.
  Future<void> clearAllTransactions();

  /// Reactive stream for real-time transaction updates.
  Stream<List<TransactionModel>> watchTransactions();

  /// Dispose any resources held by repository.
  void dispose();
}
