import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../utils/app_theme.dart';

class CategorySelector extends StatelessWidget {
  final ExpenseCategory? selectedCategory;
  final ValueChanged<ExpenseCategory> onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SELECT CATEGORY',
              style: TextStyle(
                fontFamily: AppFonts.bodyFont,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: colors.textSecondary,
              ),
            ),
            if (selectedCategory != null)
              Text(
                selectedCategory!.displayName,
                style: TextStyle(
                  fontFamily: AppFonts.headingFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.primarySageDark,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: ExpenseCategory.values.map((category) {
            final isSelected = selectedCategory == category;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _buildCategoryCard(context, category, isSelected),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, ExpenseCategory category, bool isSelected) {
    final colors = context.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onCategorySelected(category),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? colors.secondaryOliveLight : colors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? colors.primarySage : colors.borderBeige,
              width: isSelected ? 1.8 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colors.primarySage.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: colors.surfaceElevation,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primarySage.withValues(alpha: 0.2)
                      : colors.secondaryBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category.icon,
                  size: 20,
                  color: isSelected ? colors.primarySageDark : colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.bodyFont,
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? colors.textPrimary : colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
