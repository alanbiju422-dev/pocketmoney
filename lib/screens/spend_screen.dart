import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/app_constants.dart';
import '../utils/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../widgets/category_selector.dart';

class SpendScreen extends StatefulWidget {
  const SpendScreen({super.key});

  @override
  State<SpendScreen> createState() => _SpendScreenState();
}

class _SpendScreenState extends State<SpendScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  ExpenseCategory? _selectedCategory;
  String? _errorMessage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _amountFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _amountFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final rawText = _amountController.text.trim();

    if (rawText.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an expense amount.';
      });
      return;
    }

    final paise = CurrencyFormatter.parseInputToPaise(rawText);

    if (paise == null || paise <= 0) {
      setState(() {
        _errorMessage = 'Please enter a valid amount greater than ₹0.';
      });
      return;
    }

    if (_selectedCategory == null) {
      setState(() {
        _errorMessage = 'Please select a spending category.';
      });
      return;
    }

    if (_selectedCategory == ExpenseCategory.other) {
      final desc = _descriptionController.text.trim();
      if (desc.isEmpty) {
        setState(() {
          _errorMessage = 'Please specify the reason for "Other" expense.';
        });
        _descriptionFocusNode.requestFocus();
        return;
      }
    }

    final provider = Provider.of<TransactionProvider>(context, listen: false);

    // Validate balance prevention
    if (paise > provider.availableBalancePaise) {
      final currentFormatted = provider.formattedAvailableBalance;
      setState(() {
        _errorMessage =
            'Insufficient balance. You cannot spend more than your available balance of $currentFormatted.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await provider.addExpense(
        amountPaise: paise,
        category: _selectedCategory!,
        description: _descriptionController.text.trim(),
      );

      if (mounted) {
        final colors = context.colors;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Recorded expense of ${CurrencyFormatter.formatPaise(paise)} (${_selectedCategory!.displayName}).',
                ),
              ],
            ),
            backgroundColor: colors.textPrimary,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.mainBackground,
      appBar: AppBar(
        title: const Text('Spend Money'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Available Balance Indicator Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.borderBeige, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AVAILABLE FUNDS',
                      style: TextStyle(
                        fontFamily: AppFonts.bodyFont,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                        color: colors.textSecondary,
                      ),
                    ),
                    Text(
                      provider.formattedAvailableBalance,
                      style: TextStyle(
                        fontFamily: AppFonts.headingFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Prominent Amount Entry Field
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _errorMessage != null
                        ? colors.supportingTerracotta
                        : colors.borderBeige,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.surfaceElevation,
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'EXPENSE AMOUNT',
                      style: TextStyle(
                        fontFamily: AppFonts.bodyFont,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.4,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '₹',
                          style: TextStyle(
                            fontFamily: AppFonts.headingFont,
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                            color: colors.expenseTerracotta,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IntrinsicWidth(
                          child: TextField(
                            controller: _amountController,
                            focusNode: _amountFocusNode,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppFonts.headingFont,
                              fontSize: 38,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                            decoration: const InputDecoration(
                              hintText: '0',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            onChanged: (_) {
                              if (_errorMessage != null) {
                                setState(() {
                                  _errorMessage = null;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Category Selector
              CategorySelector(
                selectedCategory: _selectedCategory,
                onCategorySelected: (cat) {
                  setState(() {
                    _selectedCategory = cat;
                    _errorMessage = null;
                  });
                  if (cat == ExpenseCategory.other) {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      _descriptionFocusNode.requestFocus();
                    });
                  }
                },
              ),

              // Reason / Description Field (REQUIRED ONLY for Other category)
              if (_selectedCategory == ExpenseCategory.other) ...[
                const SizedBox(height: 20),
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 250),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'REASON / DESCRIPTION',
                            style: TextStyle(
                              fontFamily: AppFonts.bodyFont,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '*',
                            style: TextStyle(
                              color: colors.supportingTerracotta,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descriptionController,
                        focusNode: _descriptionFocusNode,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'e.g. Stationery, movie tickets, gifts...',
                          prefixIcon: Icon(
                            Icons.edit_note_rounded,
                            color: colors.textSecondary,
                            size: 20,
                          ),
                          fillColor: colors.cardBackground,
                        ),
                        onChanged: (_) {
                          if (_errorMessage != null) {
                            setState(() {
                              _errorMessage = null;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],

              // Error display
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.expenseBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: colors.supportingTerracotta.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 18,
                        color: colors.supportingTerracotta,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontFamily: AppFonts.bodyFont,
                            fontSize: 12.5,
                            color: colors.supportingTerracotta,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 36),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primarySage,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Record Expense',
                            style: TextStyle(
                              fontFamily: AppFonts.bodyFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
