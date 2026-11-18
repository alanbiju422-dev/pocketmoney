import 'package:intl/intl.dart';

/// Accurate financial currency formatting for Indian Rupees (₹) and paise.
/// Uses integer paise internally to avoid floating-point errors.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _inrFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _inrCompactFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  /// Convert paise (integer) to rupees (double)
  static double paiseToRupees(int paise) {
    return paise / 100.0;
  }

  /// Convert rupees (double or string) to paise (integer)
  static int rupeesToPaise(double rupees) {
    return (rupees * 100).round();
  }

  /// Parse user input string to paise.
  /// Throws FormatException or returns null if invalid.
  static int? parseInputToPaise(String input) {
    final clean = input.replaceAll('₹', '').replaceAll(',', '').trim();
    if (clean.isEmpty) return null;
    final value = double.tryParse(clean);
    if (value == null || value.isNaN || value.isInfinite) return null;
    return rupeesToPaise(value);
  }

  /// Format paise to standard currency string: ₹1,250.00
  static String formatPaise(int paise, {String symbol = '₹'}) {
    final rupees = paiseToRupees(paise);
    if (symbol == '₹') {
      return _inrFormatter.format(rupees);
    }
    final customFormat = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
    );
    return customFormat.format(rupees);
  }

  /// Format paise without decimals if exact, or compact
  static String formatPaiseCompact(int paise, {String symbol = '₹'}) {
    final rupees = paiseToRupees(paise);
    if (paise % 100 == 0) {
      if (symbol == '₹') {
        return _inrCompactFormatter.format(rupees);
      }
      return NumberFormat.currency(symbol: symbol, decimalDigits: 0).format(rupees);
    }
    return formatPaise(paise, symbol: symbol);
  }
}
