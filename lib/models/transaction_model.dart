import '../utils/app_constants.dart';
import '../utils/currency_formatter.dart';

enum TransactionType {
  income,
  expense;

  String get displayName {
    switch (this) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
    }
  }

  bool get isIncome => this == TransactionType.income;
  bool get isExpense => this == TransactionType.expense;
}

/// Storage-independent transaction model for Pocket Money Tracker.
/// Uses integer paise for exact financial amounts without floating-point errors.
class TransactionModel {
  final String id;
  final TransactionType type;
  final int amountPaise;
  final ExpenseCategory? category;
  final String? description;
  final DateTime dateTime;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.amountPaise,
    this.category,
    this.description,
    required this.dateTime,
    required this.createdAt,
  });

  /// Amount in Rupees as double for display or calculation
  double get amountRupees => CurrencyFormatter.paiseToRupees(amountPaise);

  /// Formatted amount string with currency symbol
  String get formattedAmount => CurrencyFormatter.formatPaise(amountPaise);

  /// Display title for list items
  String get displayTitle {
    if (type == TransactionType.income) {
      return 'Money Added';
    }
    if (category == ExpenseCategory.other) {
      if (description != null && description!.trim().isNotEmpty) {
        return description!.trim();
      }
      return 'Other Expense';
    }
    return category?.displayName ?? 'Expense';
  }

  /// Display subtitle/category tag
  String? get displaySubtitle {
    if (type == TransactionType.income) {
      return 'Added to balance';
    }
    if (category == ExpenseCategory.other) {
      return 'Other';
    }
    if (description != null && description!.trim().isNotEmpty) {
      return description!.trim();
    }
    return category?.displayName;
  }

  TransactionModel copyWith({
    String? id,
    TransactionType? type,
    int? amountPaise,
    ExpenseCategory? category,
    String? description,
    DateTime? dateTime,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amountPaise: amountPaise ?? this.amountPaise,
      category: category ?? this.category,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'amountPaise': amountPaise,
      'category': category?.name,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      type: map['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      amountPaise: (map['amountPaise'] as num).toInt(),
      category: ExpenseCategory.fromString(map['category'] as String?),
      description: map['description'] as String?,
      dateTime: DateTime.parse(map['dateTime'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionModel &&
        other.id == id &&
        other.type == type &&
        other.amountPaise == amountPaise &&
        other.category == category &&
        other.description == description &&
        other.dateTime == dateTime &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      type,
      amountPaise,
      category,
      description,
      dateTime,
      createdAt,
    );
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, type: $type, amountPaise: $amountPaise, category: $category, description: $description, dateTime: $dateTime)';
  }
}
