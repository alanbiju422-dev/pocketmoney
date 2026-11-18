import 'package:flutter_test/flutter_test.dart';
import 'package:pocketmoney/models/transaction_model.dart';
import 'package:pocketmoney/repositories/memory_transaction_repository.dart';
import 'package:pocketmoney/services/transaction_service.dart';
import 'package:pocketmoney/utils/app_constants.dart';
import 'package:pocketmoney/utils/currency_formatter.dart';

void main() {
  group('Pocket Money Tracker - Business Logic & Unit Tests', () {
    late MemoryTransactionRepository repository;
    late TransactionService service;

    setUp(() {
      repository = MemoryTransactionRepository();
      service = TransactionService(repository: repository);
    });

    test('Initial state: zero balance, zero income, zero expense', () async {
      final transactions = await repository.getAllTransactions();
      expect(transactions.isEmpty, isTrue);
      expect(service.calculateBalancePaise(transactions), equals(0));
      expect(service.calculateTotalIncomePaise(transactions), equals(0));
      expect(service.calculateTotalExpensePaise(transactions), equals(0));
    });

    test('Add Money (Income) adds to balance correctly', () async {
      // Add ₹1,000.00 = 100000 paise
      final txn = await service.addIncome(amountPaise: 100000);

      expect(txn.type, equals(TransactionType.income));
      expect(txn.amountPaise, equals(100000));
      expect(txn.category, isNull);
      expect(txn.description, isNull);

      final all = await repository.getAllTransactions();
      expect(all.length, equals(1));
      expect(service.calculateBalancePaise(all), equals(100000));
      expect(service.calculateTotalIncomePaise(all), equals(100000));
      expect(service.calculateTotalExpensePaise(all), equals(0));
    });

    test('Add Money validates positive amount', () async {
      expect(
        () => service.addIncome(amountPaise: 0),
        throwsA(isA<TransactionValidationException>()),
      );
      expect(
        () => service.addIncome(amountPaise: -500),
        throwsA(isA<TransactionValidationException>()),
      );
    });

    test('Spend Money records expense and deducts from balance', () async {
      // Deposit ₹1,500.00
      await service.addIncome(amountPaise: 150000);

      // Spend ₹450.00 on Food
      final expense = await service.addExpense(
        amountPaise: 45000,
        category: ExpenseCategory.food,
      );

      expect(expense.type, equals(TransactionType.expense));
      expect(expense.amountPaise, equals(45000));
      expect(expense.category, equals(ExpenseCategory.food));

      final all = await repository.getAllTransactions();
      expect(all.length, equals(2));
      expect(service.calculateTotalIncomePaise(all), equals(150000));
      expect(service.calculateTotalExpensePaise(all), equals(45000));
      expect(service.calculateBalancePaise(all), equals(105000)); // ₹1,050.00
    });

    test('Insufficient balance prevention: expense cannot exceed balance', () async {
      // Balance is ₹500.00
      await service.addIncome(amountPaise: 50000);

      // Attempt to spend ₹600.00
      expect(
        () => service.addExpense(
          amountPaise: 60000,
          category: ExpenseCategory.travel,
        ),
        throwsA(
          isA<TransactionValidationException>().having(
            (e) => e.message,
            'message',
            contains('Insufficient balance'),
          ),
        ),
      );

      // Balance remains ₹500.00
      final all = await repository.getAllTransactions();
      expect(service.calculateBalancePaise(all), equals(50000));
    });

    test('Category validation: Other category REQUIRES reason/description', () async {
      await service.addIncome(amountPaise: 100000);

      // Attempt Other without description
      expect(
        () => service.addExpense(
          amountPaise: 10000,
          category: ExpenseCategory.other,
          description: null,
        ),
        throwsA(
          isA<TransactionValidationException>().having(
            (e) => e.message,
            'message',
            contains('reason for "Other"'),
          ),
        ),
      );

      // Attempt Other with empty description
      expect(
        () => service.addExpense(
          amountPaise: 10000,
          category: ExpenseCategory.other,
          description: '   ',
        ),
        throwsA(isA<TransactionValidationException>()),
      );

      // Succeed with valid description
      final valid = await service.addExpense(
        amountPaise: 10000,
        category: ExpenseCategory.other,
        description: 'New notebook for class',
      );
      expect(valid.description, equals('New notebook for class'));
    });

    test('Categories Travel, Food, College do NOT require description', () async {
      await service.addIncome(amountPaise: 100000);

      final travel = await service.addExpense(
        amountPaise: 10000,
        category: ExpenseCategory.travel,
      );
      expect(travel.description, isNull);

      final food = await service.addExpense(
        amountPaise: 15000,
        category: ExpenseCategory.food,
      );
      expect(food.description, isNull);

      final college = await service.addExpense(
        amountPaise: 20000,
        category: ExpenseCategory.college,
      );
      expect(college.description, isNull);
    });

    test('Filtering by type (Income vs Expense)', () async {
      await service.addIncome(amountPaise: 100000);
      await service.addExpense(amountPaise: 20000, category: ExpenseCategory.food);
      await service.addExpense(amountPaise: 30000, category: ExpenseCategory.travel);

      final all = await repository.getAllTransactions();

      final incomeOnly = service.filterTransactions(
        transactions: all,
        typeFilter: TransactionType.income,
      );
      expect(incomeOnly.length, equals(1));
      expect(incomeOnly.first.type, equals(TransactionType.income));

      final expenseOnly = service.filterTransactions(
        transactions: all,
        typeFilter: TransactionType.expense,
      );
      expect(expenseOnly.length, equals(2));
      expect(expenseOnly.every((t) => t.type == TransactionType.expense), isTrue);
    });

    test('Filtering by category (Travel, Food, College, Other)', () async {
      await service.addIncome(amountPaise: 200000);
      await service.addExpense(amountPaise: 20000, category: ExpenseCategory.food);
      await service.addExpense(amountPaise: 30000, category: ExpenseCategory.travel);
      await service.addExpense(amountPaise: 40000, category: ExpenseCategory.college);

      final all = await repository.getAllTransactions();

      final foodItems = service.filterTransactions(
        transactions: all,
        categoryFilter: ExpenseCategory.food,
      );
      expect(foodItems.length, equals(1));
      expect(foodItems.first.category, equals(ExpenseCategory.food));

      final travelItems = service.filterTransactions(
        transactions: all,
        categoryFilter: ExpenseCategory.travel,
      );
      expect(travelItems.length, equals(1));
      expect(travelItems.first.category, equals(ExpenseCategory.travel));
    });

    test('Search query matches category, description, or amount', () async {
      await service.addIncome(amountPaise: 500000);
      await service.addExpense(
        amountPaise: 25000,
        category: ExpenseCategory.other,
        description: 'Textbook for Economics',
      );
      await service.addExpense(
        amountPaise: 12000,
        category: ExpenseCategory.food,
      );

      final all = await repository.getAllTransactions();

      // Search by description keyword
      final matchDesc = service.filterTransactions(
        transactions: all,
        searchQuery: 'Economics',
      );
      expect(matchDesc.length, equals(1));
      expect(matchDesc.first.description, contains('Economics'));

      // Search by category
      final matchCat = service.filterTransactions(
        transactions: all,
        searchQuery: 'Food',
      );
      expect(matchCat.length, equals(1));
      expect(matchCat.first.category, equals(ExpenseCategory.food));

      // Search by amount string
      final matchAmt = service.filterTransactions(
        transactions: all,
        searchQuery: '250',
      );
      expect(matchAmt.length, equals(1));
    });

    test('Reports and Analytics calculation', () async {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      // Add ₹10,000 income
      await service.addIncome(amountPaise: 1000000, dateTime: now);
      // Add expenses
      await service.addExpense(
        amountPaise: 100000, // ₹1,000
        category: ExpenseCategory.food,
        dateTime: now,
      );
      await service.addExpense(
        amountPaise: 200000, // ₹2,000
        category: ExpenseCategory.travel,
        dateTime: now,
      );

      final all = await repository.getAllTransactions();
      final report = service.generateReportSummary(
        transactions: all,
        startDate: start,
        endDate: end,
      );

      expect(report.totalIncomePaise, equals(1000000));
      expect(report.totalExpensePaise, equals(300000));
      expect(report.netBalanceChangePaise, equals(700000));
      expect(report.categorySpendingPaise[ExpenseCategory.food], equals(100000));
      expect(report.categorySpendingPaise[ExpenseCategory.travel], equals(200000));

      // Percentages: Food = 1000/3000 * 100 = 33.33%, Travel = 2000/3000 * 100 = 66.67%
      expect(report.getCategoryPercentage(ExpenseCategory.food), closeTo(33.33, 0.1));
      expect(report.getCategoryPercentage(ExpenseCategory.travel), closeTo(66.67, 0.1));
    });

    test('Currency Formatter precision', () {
      expect(CurrencyFormatter.rupeesToPaise(100.50), equals(10050));
      expect(CurrencyFormatter.paiseToRupees(10050), equals(100.50));
      expect(CurrencyFormatter.parseInputToPaise('₹ 1,500.25'), equals(150025));
      expect(CurrencyFormatter.formatPaise(150025), equals('₹1,500.25'));
    });
  });
}
