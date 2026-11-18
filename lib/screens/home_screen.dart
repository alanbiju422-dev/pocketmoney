import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/app_theme.dart';
import '../utils/date_helpers.dart';
import '../widgets/balance_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/transaction_detail_sheet.dart';
import '../widgets/transaction_tile.dart';
import 'add_money_screen.dart';
import 'spend_screen.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<int>? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.mainBackground,
      body: SafeArea(
        child: Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            final recentList = provider.recentTransactions;

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // Editorial Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: colors.primarySage,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'POCKET MONEY',
                                      style: TextStyle(
                                        fontFamily: AppFonts.bodyFont,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.6,
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateHelpers.getGreeting(),
                                  style: TextStyle(
                                    fontFamily: AppFonts.headingFont,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            // Settings quick link
                            IconButton(
                              onPressed: () {
                                if (onNavigateTab != null) {
                                  onNavigateTab!(3); // 3 is Settings tab
                                }
                              },
                              icon: const Icon(Icons.tune_rounded),
                              color: colors.textPrimary,
                              tooltip: 'Settings',
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateHelpers.formatEditorialHeader(now),
                          style: TextStyle(
                            fontFamily: AppFonts.bodyFont,
                            fontSize: 13,
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // Available Balance Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: BalanceCard(
                      availableBalance: provider.formattedAvailableBalance,
                      totalAdded: provider.formattedTotalIncome,
                      totalSpent: provider.formattedTotalExpense,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 18)),

                // Quick Actions: Add Money & Spend Money
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: QuickActionButton.addMoney(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => const AddMoneyScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: QuickActionButton.spendMoney(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => const SpendScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Recent Activity Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'RECENT ACTIVITY',
                          style: TextStyle(
                            fontFamily: AppFonts.bodyFont,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.3,
                            color: colors.textSecondary,
                          ),
                        ),
                        if (provider.transactions.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              if (onNavigateTab != null) {
                                onNavigateTab!(1); // 1 is History tab
                              }
                            },
                            child: const Text('View All'),
                          ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                // Recent Transactions List or Empty State
                if (recentList.isEmpty)
                  SliverToBoxAdapter(
                    child: EmptyState.transactions(
                      onAddMoney: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => const AddMoneyScreen(),
                          ),
                        );
                      },
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final txn = recentList[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: TransactionTile(
                              transaction: txn,
                              onTap: () => TransactionDetailSheet.show(context, txn),
                            ),
                          );
                        },
                        childCount: recentList.length,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          },
        ),
      ),
    );
  }
}
