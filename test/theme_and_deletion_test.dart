import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocketmoney/providers/auth_provider.dart';
import 'package:pocketmoney/providers/theme_provider.dart';
import 'package:pocketmoney/providers/transaction_provider.dart';
import 'package:pocketmoney/repositories/local_auth_repository.dart';
import 'package:pocketmoney/repositories/memory_transaction_repository.dart';
import 'package:pocketmoney/screens/history_screen.dart';
import 'package:pocketmoney/screens/settings_screen.dart';
import 'package:pocketmoney/utils/app_constants.dart';
import 'package:pocketmoney/utils/app_theme.dart';
import 'package:pocketmoney/widgets/transaction_tile.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Dark Mode & Theme Switching Tests', () {
    test('Light theme palette matches exact approved values', () {
      final light = AppColors.light;
      expect(light.mainBackground, const Color(0xFFF8F6F0));
      expect(light.secondaryBackground, const Color(0xFFF1EEE5));
      expect(light.cardBackground, const Color(0xFFFFFFFF));
      expect(light.primarySage, const Color(0xFF91A58B));
      expect(light.secondaryOlive, const Color(0xFFB2B99A));
      expect(light.supportingTerracotta, const Color(0xFFC58F78));
      expect(light.border, const Color(0xFFE6E1D6));
      expect(light.textPrimary, const Color(0xFF514E46));
      expect(light.textSecondary, const Color(0xFF918D83));
      expect(light.isDark, isFalse);
    });

    test('Dark theme palette matches exact required hex codes', () {
      final dark = AppColors.dark;
      expect(dark.mainBackground, const Color(0xFF171916));
      expect(dark.cardBackground, const Color(0xFF232721));
      expect(dark.secondaryBackground, const Color(0xFF2C322B));
      expect(dark.textPrimary, const Color(0xFFF2F0E8));
      expect(dark.textSecondary, const Color(0xFFAAAFA4));
      expect(dark.primarySage, const Color(0xFF91A58B));
      expect(dark.supportingTerracotta, const Color(0xFFD49A83));
      expect(dark.expenseTerracotta, const Color(0xFFD49A83));
      expect(dark.border, const Color(0xFF383F36));
      expect(dark.isDark, isTrue);
    });

    test('ThemeProvider switches modes and names correctly', () async {
      final provider = ThemeProvider();
      expect(provider.themeMode, ThemeMode.system);
      expect(provider.themeModeName, 'System Default');

      await provider.setThemeMode(ThemeMode.light);
      expect(provider.themeMode, ThemeMode.light);
      expect(provider.themeModeName, 'Light');

      await provider.setThemeMode(ThemeMode.dark);
      expect(provider.themeMode, ThemeMode.dark);
      expect(provider.themeModeName, 'Dark');

      await provider.setThemeMode(ThemeMode.system);
      expect(provider.themeMode, ThemeMode.system);
      expect(provider.themeModeName, 'System Default');
    });
  });

  group('Individual Transaction Deletion Tests', () {
    late MemoryTransactionRepository repository;
    late TransactionProvider provider;

    setUp(() {
      repository = MemoryTransactionRepository();
      provider = TransactionProvider(repository: repository);
    });

    test('Deleting individual transaction recalculates balance and removes item', () async {
      await provider.addIncome(50000); // ₹500
      await provider.addExpense(
        amountPaise: 12000, // ₹120
        category: ExpenseCategory.food,
        description: 'Lunch',
      );
      await provider.addExpense(
        amountPaise: 8000, // ₹80
        category: ExpenseCategory.travel,
        description: 'Metro',
      );

      expect(provider.totalIncomePaise, 50000);
      expect(provider.totalExpensePaise, 20000);
      expect(provider.availableBalancePaise, 30000);
      expect(provider.transactions.length, 3);

      // Find the lunch transaction
      final lunchTx = provider.transactions.firstWhere((tx) => tx.description == 'Lunch');

      // Delete lunch
      await provider.deleteTransaction(lunchTx.id);

      // Verify balance recalculations
      expect(provider.transactions.length, 2);
      expect(provider.totalIncomePaise, 50000);
      expect(provider.totalExpensePaise, 8000);
      expect(provider.availableBalancePaise, 42000); // 500 - 80 = 420
    });

    testWidgets('History screen shows individual delete button and triggers confirmation',
        (WidgetTester tester) async {
      await provider.addIncome(50000); // Need positive balance to spend
      await provider.addExpense(
        amountPaise: 25000,
        category: ExpenseCategory.other,
        description: 'College Books',
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: provider),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const HistoryScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify transaction tile is present
      expect(find.byType(TransactionTile), findsNWidgets(2)); // Income + Expense
      expect(find.text('College Books'), findsOneWidget);

      // Verify individual delete icon button is present
      expect(find.byIcon(Icons.delete_outline_rounded), findsNWidgets(2));

      // Tap the delete icon for College Books
      final collegeDeleteBtn = find.descendant(
        of: find.widgetWithText(TransactionTile, 'College Books'),
        matching: find.byIcon(Icons.delete_outline_rounded),
      );
      await tester.tap(collegeDeleteBtn);
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.text('Are you sure you want to delete this transaction?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Tap Delete in dialog
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify transaction is deleted and only income remains
      expect(provider.transactions.length, 1);
      expect(find.text('College Books'), findsNothing);
    });
  });

  group('Settings Screen Verification Tests', () {
    testWidgets('Settings screen has Theme preference and NO Clear Ledger History',
        (WidgetTester tester) async {
      LocalAuthRepository.resetForTesting();
      final authRepo = LocalAuthRepository();
      final authProvider = AuthProvider(repository: authRepo);
      final txProvider = TransactionProvider(repository: MemoryTransactionRepository());
      final themeProvider = ThemeProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(value: txProvider),
            ChangeNotifierProvider.value(value: themeProvider),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SettingsScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify Design Theme is present in Preferences
      expect(find.text('Design Theme'), findsOneWidget);

      // Verify Clear Ledger History is completely gone
      expect(find.text('Clear Ledger History'), findsNothing);
      expect(find.text('DATA ACTIONS'), findsNothing);
      expect(find.text('Reset All'), findsNothing);

      // Tap Design Theme to verify bottom sheet
      await tester.tap(find.text('Design Theme'));
      await tester.pumpAndSettle();

      // Verify bottom sheet options
      expect(find.text('SELECT THEME'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      // Both tile trailing and sheet item have 'System Default'
      expect(find.text('System Default'), findsNWidgets(2));

      // Tap Dark
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(themeProvider.themeMode, ThemeMode.dark);
    });
  });
}
