import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class BalanceCard extends StatelessWidget {
  final String availableBalance;
  final String totalAdded;
  final String totalSpent;

  const BalanceCard({
    super.key,
    required this.availableBalance,
    required this.totalAdded,
    required this.totalSpent,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderBeige, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: colors.surfaceElevation,
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AVAILABLE BALANCE',
                style: TextStyle(
                  fontFamily: AppFonts.bodyFont,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4,
                  color: colors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.secondaryBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.borderBeige, width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: colors.primarySage,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Live Ledger',
                      style: TextStyle(
                        fontFamily: AppFonts.bodyFont,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            availableBalance,
            style: TextStyle(
              fontFamily: AppFonts.headingFont,
              fontSize: 34,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: colors.borderBeige, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  context: context,
                  label: 'MONEY ADDED',
                  amount: totalAdded,
                  indicatorColor: colors.incomeGreen,
                  icon: Icons.south_west_rounded,
                  iconBg: colors.incomeGreenBackground,
                ),
              ),
              Container(
                height: 38,
                width: 1,
                color: colors.borderBeige,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetric(
                  context: context,
                  label: 'MONEY SPENT',
                  amount: totalSpent,
                  indicatorColor: colors.expenseTerracotta,
                  icon: Icons.north_east_rounded,
                  iconBg: colors.expenseBackground,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric({
    required BuildContext context,
    required String label,
    required String amount,
    required Color indicatorColor,
    required IconData icon,
    required Color iconBg,
  }) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: indicatorColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppFonts.bodyFont,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  amount,
                  style: TextStyle(
                    fontFamily: AppFonts.headingFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
