import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

class DisplayNameScreen extends StatefulWidget {
  const DisplayNameScreen({super.key});

  @override
  State<DisplayNameScreen> createState() => _DisplayNameScreenState();
}

class _DisplayNameScreenState extends State<DisplayNameScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _error;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _error = 'Please enter your display name.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.saveDisplayName(name);
      // Navigation is automatically handled reactively by AuthGate
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final authProvider = Provider.of<AuthProvider>(context);
    final email = authProvider.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: colors.mainBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon Header
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: colors.secondaryBackground,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.border, width: 1.2),
                    ),
                    child: Icon(
                      Icons.person_outline_rounded,
                      size: 30,
                      color: colors.primarySageDark,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'What Should We Call You?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.headingFont,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Personalize your pocket ledger experience for $email',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.bodyFont,
                    fontSize: 13.5,
                    color: colors.textSecondary,
                  ),
                ),

                const SizedBox(height: 36),

                // Name input card
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _error != null
                          ? colors.supportingTerracotta
                          : colors.border,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow,
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DISPLAY NAME',
                        style: TextStyle(
                          fontFamily: AppFonts.bodyFont,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _nameController,
                        focusNode: _focusNode,
                        textCapitalization: TextCapitalization.words,
                        style: TextStyle(
                          fontFamily: AppFonts.headingFont,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. Alan Biju',
                          prefixIcon: Icon(
                            Icons.badge_outlined,
                            size: 20,
                            color: colors.primarySageDark,
                          ),
                          fillColor: colors.mainBackground,
                        ),
                        onChanged: (_) {
                          if (_error != null) {
                            setState(() {
                              _error = null;
                            });
                          }
                        },
                        onSubmitted: (_) => _submit(),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _error!,
                          style: TextStyle(
                            fontFamily: AppFonts.bodyFont,
                            fontSize: 12.5,
                            color: colors.supportingTerracotta,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primarySage,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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
                            Text(
                              'Save & Continue',
                              style: TextStyle(
                                fontFamily: AppFonts.bodyFont,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
