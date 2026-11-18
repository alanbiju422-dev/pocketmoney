import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../services/transaction_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_helpers.dart';
import '../widgets/empty_state.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedChartTab = 0; // 0: Income vs Expense, 1: Category Breakdown, 2: Spending Trend

  Future<void> _selectCustomDateRange(BuildContext context) async {
    final colors = context.colors;
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final initialDateRange = DateTimeRange(
      start: provider.reportStartDate,
      end: provider.reportEndDate,
    );

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colors.primarySage,
              onPrimary: Colors.white,
              surface: colors.cardBackground,
              onSurface: colors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      provider.setReportFilterType(
        DateRangeFilterType.custom,
        customStart: picked.start,
        customEnd: picked.end,
      );
    }
  }

  Color _getCategoryColor(ExpenseCategory category, AppColorScheme colors) {
    switch (category) {
      case ExpenseCategory.travel:
        return colors.primarySage;
      case ExpenseCategory.food:
        return colors.secondaryOlive;
      case ExpenseCategory.college:
        return colors.primarySageDark;
      case ExpenseCategory.other:
        return colors.supportingTerracotta;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.mainBackground,
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
      ),
      body: SafeArea(
        child: Consumer<TransactionProvider>(
          builder: (context, provider, _) {
            final summary = provider.reportSummary;
            final hasData = summary.totalTransactionCount > 0;

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // Date Range Filter Tabs
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: DateRangeFilterType.values.map((filter) {
                              final isSelected = provider.reportFilterType == filter;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(filter.displayName),
                                  selected: isSelected,
                                  onSelected: (_) {
                                    if (filter == DateRangeFilterType.custom) {
                                      _selectCustomDateRange(context);
                                    } else {
                                      provider.setReportFilterType(filter);
                                    }
                                  },
                                  backgroundColor: colors.cardBackground,
                                  selectedColor: colors.primarySageLight,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                      color: isSelected
                                          ? colors.primarySageDark
                                          : colors.border,
                                    ),
                                  ),
                                  labelStyle: TextStyle(
                                    fontFamily: AppFonts.bodyFont,
                                    fontSize: 12.5,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected
                                        ? colors.primarySageDark
                                        : colors.textPrimary,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Current range label
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: colors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              provider.reportDateRangeLabel,
                              style: TextStyle(
                                fontFamily: AppFonts.bodyFont,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Top Summary Cards (Income, Expense, Net Change)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            colors: colors,
                            title: 'TOTAL INCOME',
                            amount: CurrencyFormatter.formatPaise(summary.totalIncomePaise),
                            color: colors.incomeGreen,
                            bgColor: colors.incomeGreenBackground,
                            icon: Icons.south_west_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMetricCard(
                            colors: colors,
                            title: 'TOTAL EXPENSE',
                            amount: CurrencyFormatter.formatPaise(summary.totalExpensePaise),
                            color: colors.expenseTerracotta,
                            bgColor: colors.expenseBackground,
                            icon: Icons.north_east_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMetricCard(
                            colors: colors,
                            title: 'NET SAVING',
                            amount: CurrencyFormatter.formatPaise(summary.netBalanceChangePaise),
                            color: summary.netBalanceChangePaise >= 0
                                ? colors.incomeGreen
                                : colors.expenseTerracotta,
                            bgColor: colors.secondaryBackground,
                            icon: Icons.balance_outlined,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                if (!hasData)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: EmptyState.reports(),
                    ),
                  )
                else ...[
                  // Chart Selector Segment
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colors.secondaryBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.border, width: 1),
                        ),
                        child: Row(
                          children: [
                            _buildSegmentTab(colors, 'Income vs Expense', 0),
                            _buildSegmentTab(colors, 'Categories', 1),
                            _buildSegmentTab(colors, 'Trends', 2),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Visual Chart Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colors.cardBackground,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: colors.border, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: colors.shadow,
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _buildActiveChart(summary, colors),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Category Breakdown Table / Progress bars
                  if (summary.totalExpensePaise > 0) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'SPENDING BY CATEGORY',
                          style: TextStyle(
                            fontFamily: AppFonts.bodyFont,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.3,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final category = ExpenseCategory.values[index];
                            final amount = summary.categorySpendingPaise[category] ?? 0;
                            final percentage = summary.getCategoryPercentage(category);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: colors.cardBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: colors.border, width: 0.9),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: _getCategoryColor(category, colors).withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          category.icon,
                                          size: 16,
                                          color: _getCategoryColor(category, colors),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          category.displayName,
                                          style: TextStyle(
                                            fontFamily: AppFonts.headingFont,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: colors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            CurrencyFormatter.formatPaise(amount),
                                            style: TextStyle(
                                              fontFamily: AppFonts.headingFont,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: colors.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            '${percentage.toStringAsFixed(1)}%',
                                            style: TextStyle(
                                              fontFamily: AppFonts.bodyFont,
                                              fontSize: 11,
                                              color: colors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: percentage / 100.0,
                                      backgroundColor: colors.secondaryBackground,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _getCategoryColor(category, colors),
                                      ),
                                      minHeight: 5,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          childCount: ExpenseCategory.values.length,
                        ),
                      ),
                    ),
                  ],

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required AppColorScheme colors,
    required String title,
    required String amount,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 12, color: color),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.bodyFont,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: TextStyle(
                fontFamily: AppFonts.headingFont,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentTab(AppColorScheme colors, String title, int index) {
    final isSelected = _selectedChartTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedChartTab = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colors.cardBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: isSelected
                ? Border.all(color: colors.border, width: 1)
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colors.shadow,
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppFonts.bodyFont,
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? colors.textPrimary : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveChart(ReportSummary summary, AppColorScheme colors) {
    switch (_selectedChartTab) {
      case 0:
        return _buildIncomeExpenseComparison(summary, colors);
      case 1:
        return _buildCategoryDonutChart(summary, colors);
      case 2:
        return _buildSpendingTrendChart(summary, colors);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildIncomeExpenseComparison(ReportSummary summary, AppColorScheme colors) {
    final incomeRupees = summary.totalIncomeRupees;
    final expenseRupees = summary.totalExpenseRupees;
    final maxY = (incomeRupees > expenseRupees ? incomeRupees : expenseRupees) * 1.25;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Income vs Expense Ratio',
          style: TextStyle(
            fontFamily: AppFonts.headingFont,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Comparison of money added versus money spent in this period.',
          style: TextStyle(
            fontFamily: AppFonts.bodyFont,
            fontSize: 12,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              maxY: maxY <= 0 ? 100 : maxY,
              alignment: BarChartAlignment.spaceAround,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => colors.textPrimary,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final isInc = rodIndex == 0;
                    return BarTooltipItem(
                      '${isInc ? "Income" : "Expense"}\n₹${rod.toY.toStringAsFixed(0)}',
                      TextStyle(
                        color: colors.cardBackground,
                        fontFamily: AppFonts.bodyFont,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (val, meta) {
                      if (val.toInt() == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Comparison',
                            style: TextStyle(
                              fontFamily: AppFonts.bodyFont,
                              fontSize: 12,
                              color: colors.textSecondary,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barsSpace: 16,
                  barRods: [
                    BarChartRodData(
                      toY: incomeRupees,
                      color: colors.incomeGreen,
                      width: 32,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    BarChartRodData(
                      toY: expenseRupees,
                      color: colors.expenseTerracotta,
                      width: 32,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(colors, 'Money Added', colors.incomeGreen),
            const SizedBox(width: 20),
            _buildLegendItem(colors, 'Money Spent', colors.expenseTerracotta),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryDonutChart(ReportSummary summary, AppColorScheme colors) {
    if (summary.totalExpensePaise == 0) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'No expenses recorded in this period.',
            style: TextStyle(
              fontFamily: AppFonts.bodyFont,
              color: colors.textSecondary,
            ),
          ),
        ),
      );
    }

    final sections = ExpenseCategory.values.map((cat) {
      final percentage = summary.getCategoryPercentage(cat);
      if (percentage <= 0) {
        return PieChartSectionData(value: 0, showTitle: false);
      }
      return PieChartSectionData(
        color: _getCategoryColor(cat, colors),
        value: percentage,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 46,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          fontFamily: AppFonts.bodyFont,
        ),
      );
    }).where((s) => s.value > 0).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expense Breakdown',
          style: TextStyle(
            fontFamily: AppFonts.headingFont,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Proportional spending across expense categories.',
          style: TextStyle(
            fontFamily: AppFonts.bodyFont,
            fontSize: 12,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: ExpenseCategory.values.map((cat) {
            final amt = summary.categorySpendingPaise[cat] ?? 0;
            if (amt == 0) return const SizedBox.shrink();
            return _buildLegendItem(colors, cat.displayName, _getCategoryColor(cat, colors));
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSpendingTrendChart(ReportSummary summary, AppColorScheme colors) {
    final trendMap = summary.dailyExpenseTrendPaise;

    if (trendMap.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'No expense trend data available for this range.',
            style: TextStyle(
              fontFamily: AppFonts.bodyFont,
              color: colors.textSecondary,
            ),
          ),
        ),
      );
    }

    final sortedDates = trendMap.keys.toList()..sort();
    final spots = <FlSpot>[];

    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final paise = trendMap[date] ?? 0;
      spots.add(FlSpot(i.toDouble(), CurrencyFormatter.paiseToRupees(paise)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Expense Trend',
          style: TextStyle(
            fontFamily: AppFonts.headingFont,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Trajectory of daily expenditure over time.',
          style: TextStyle(
            fontFamily: AppFonts.bodyFont,
            fontSize: 12,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (val, meta) {
                      final idx = val.toInt();
                      if (idx >= 0 && idx < sortedDates.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateHelpers.formatShortMonthDay(sortedDates[idx]),
                            style: TextStyle(
                              fontFamily: AppFonts.bodyFont,
                              fontSize: 10,
                              color: colors.textSecondary,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: colors.supportingTerracotta,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: colors.supportingTerracotta.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(AppColorScheme colors, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.bodyFont,
            fontSize: 12,
            color: colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
