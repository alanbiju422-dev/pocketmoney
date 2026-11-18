import 'package:flutter/material.dart';

/// Available spending categories as per requirements:
/// 1. Travel
/// 2. Food
/// 3. College
/// 4. Other
enum ExpenseCategory {
  travel,
  food,
  college,
  other;

  String get displayName {
    switch (this) {
      case ExpenseCategory.travel:
        return 'Travel';
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.college:
        return 'College';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.travel:
        return Icons.directions_transit_outlined;
      case ExpenseCategory.food:
        return Icons.restaurant_outlined;
      case ExpenseCategory.college:
        return Icons.school_outlined;
      case ExpenseCategory.other:
        return Icons.grid_view_outlined;
    }
  }

  static ExpenseCategory? fromString(String? value) {
    if (value == null) return null;
    final lower = value.toLowerCase().trim();
    for (final category in ExpenseCategory.values) {
      if (category.name == lower || category.displayName.toLowerCase() == lower) {
        return category;
      }
    }
    return null;
  }
}

class AppConstants {
  AppConstants._();

  static const String appName = 'Pocket Money';
  static const String appTagline = 'Classic Editorial Personal Ledger';
  static const String appVersion = '1.0.0 (Build 1)';
  static const String defaultCurrencySymbol = '₹';
  static const String defaultCurrencyCode = 'INR';

  static const String inMemoryStorageNotice =
      'Development Stage Active: Transactions are held in-memory and will reset when the application restarts. The repository architecture is decoupled and ready for persistent database integration.';
}
