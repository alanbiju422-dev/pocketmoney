import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocketmoney/providers/auth_provider.dart';
import 'package:pocketmoney/providers/theme_provider.dart';
import 'package:pocketmoney/providers/transaction_provider.dart';
import 'package:pocketmoney/repositories/local_auth_repository.dart';
import 'package:pocketmoney/repositories/memory_transaction_repository.dart';
import 'package:pocketmoney/screens/auth/auth_gate.dart';
import 'package:pocketmoney/utils/app_theme.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    LocalAuthRepository.resetForTesting();
  });

  testWidgets('Full First-Time User Onboarding Flow UI Test', (WidgetTester tester) async {
    final authRepository = LocalAuthRepository();
    final transactionRepository = MemoryTransactionRepository();

    final authProvider = AuthProvider(repository: authRepository);
    final transactionProvider = TransactionProvider(repository: transactionRepository);
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authProvider),
          ChangeNotifierProvider.value(value: transactionProvider),
          ChangeNotifierProvider.value(value: themeProvider),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AuthGate(),
        ),
      ),
    );

    // Initial pump for auth gate
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // 1. Initial State: Google Sign In Screen
    expect(find.text('SIGN IN TO CONTINUE'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);

    // 2. Tap Continue with Google
    await tester.tap(find.text('Continue with Google'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 3. Display Name Setup Screen
    expect(find.text('What Should We Call You?'), findsOneWidget);
    expect(find.text('Save & Continue'), findsOneWidget);

    // Enter name
    await tester.enterText(find.byType(TextField), 'Alan Biju');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Tap Save & Continue
    await tester.tap(find.text('Save & Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 4. Welcome & Privacy Notice Screen
    expect(find.text('Welcome to Pocket Money!'), findsOneWidget);
    expect(find.text('Your Money, Your Story.'), findsOneWidget);
    expect(find.text('A little about your privacy and data'), findsOneWidget);

    expect(
      find.text('All income and expense transactions must be entered manually by you.'),
      findsOneWidget,
    );
    expect(
      find.text('Pocket Money has no connection to banks, UPI apps or payment services.'),
      findsOneWidget,
    );
    expect(
      find.text('The app cannot automatically access or retrieve your payment history.'),
      findsOneWidget,
    );
    expect(
      find.text('We never ask for bank account details, card details, UPI PINs or banking passwords.'),
      findsOneWidget,
    );
    expect(
      find.text('Your entries are used to calculate your balance and help you track your spending.'),
      findsOneWidget,
    );

    expect(find.text('Your privacy matters.'), findsOneWidget);
    expect(find.text('I Understand & Start'), findsOneWidget);

    // 5. Tap "I Understand & Start"
    await tester.tap(find.text('I Understand & Start'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 6. Home Screen is now active
    expect(find.text('POCKET MONEY'), findsOneWidget);
    expect(find.text('AVAILABLE BALANCE'), findsOneWidget);
    expect(find.text('Add Money'), findsWidgets);
    expect(find.text('Spend Money'), findsOneWidget);
  });
}
