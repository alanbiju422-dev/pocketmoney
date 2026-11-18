import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/transaction_model.dart';
import '../utils/app_constants.dart';
import 'transaction_repository.dart';

/// Supabase-backed transaction storage. The owner is always taken from the
/// active Supabase Auth session; callers cannot choose a user ID.
class SupabaseTransactionRepository implements TransactionRepository {
  static const String _table = 'transactions';

  final SupabaseClient _client;
  final StreamController<List<TransactionModel>> _controller =
      StreamController<List<TransactionModel>>.broadcast();

  StreamSubscription<AuthState>? _authSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _transactionSubscription;
  String? _activeUserId;
  bool _disposed = false;

  SupabaseTransactionRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client {
    _activeUserId = _client.auth.currentUser?.id;
    _listenForUserTransactions(_activeUserId);
    _authSubscription = _client.auth.onAuthStateChange.listen((state) {
      _handleAuthChange(state.session?.user.id);
    });
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Sign in to access transactions.');
    }
    return userId;
  }

  void _handleAuthChange(String? userId) {
    if (_disposed || userId == _activeUserId) return;
    _activeUserId = userId;
    _controller.add(const []);
    _listenForUserTransactions(userId);
  }

  void _listenForUserTransactions(String? userId) {
    _transactionSubscription?.cancel();
    _transactionSubscription = null;
    if (userId == null || _disposed) return;

    _transactionSubscription = _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('date_time', ascending: false)
        .listen(
          (rows) {
            if (_disposed || userId != _activeUserId) return;
            try {
              _controller.add(rows.map(_fromRow).toList(growable: false));
            } catch (error, stackTrace) {
              _controller.addError(error, stackTrace);
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!_disposed && userId == _activeUserId) {
              _controller.addError(error, stackTrace);
            }
          },
        );
  }

  TransactionModel _fromRow(Map<String, dynamic> row) {
    final type = row['type'] as String;
    final categoryName = row['category'] as String?;
    final category = ExpenseCategory.fromString(categoryName);
    if (type == 'expense' && category == null) {
      throw FormatException('Unknown transaction category: $categoryName');
    }

    return TransactionModel(
      id: row['id'] as String,
      type: type == 'income' ? TransactionType.income : TransactionType.expense,
      amountPaise: (row['amount_paise'] as num).toInt(),
      category: category,
      description: row['description'] as String?,
      dateTime: DateTime.parse(row['date_time'] as String),
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  Map<String, dynamic> _toRow(TransactionModel transaction, String userId) => {
        'id': transaction.id,
        'user_id': userId,
        'type': transaction.type.name,
        'amount_paise': transaction.amountPaise,
        'category': transaction.category?.name,
        'description': transaction.description,
        'date_time': transaction.dateTime.toIso8601String(),
        'created_at': transaction.createdAt.toIso8601String(),
      };

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', _requireUserId())
        .order('date_time', ascending: false);
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<TransactionModel?> getTransactionById(String id) async {
    final row = await _client
        .from(_table)
        .select()
        .eq('id', id)
        .eq('user_id', _requireUserId())
        .maybeSingle();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    await _client.from(_table).insert(_toRow(transaction, _requireUserId()));
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _client
        .from(_table)
        .delete()
        .eq('id', id)
        .eq('user_id', _requireUserId());
  }

  @override
  Future<void> clearAllTransactions() async {
    await _client
        .from(_table)
        .delete()
        .eq('user_id', _requireUserId());
  }

  @override
  Stream<List<TransactionModel>> watchTransactions() => _controller.stream;

  @override
  void dispose() {
    _disposed = true;
    _authSubscription?.cancel();
    _transactionSubscription?.cancel();
    _controller.close();
  }
}
