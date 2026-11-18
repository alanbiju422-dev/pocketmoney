import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

class WelcomePrivacyNoticeScreen extends StatefulWidget {
  const WelcomePrivacyNoticeScreen({super.key});

  @override
  State<WelcomePrivacyNoticeScreen> createState() =>
      _WelcomePrivacyNoticeScreenState();
}

class _WelcomePrivacyNoticeScreenState
    extends State<WelcomePrivacyNoticeScreen> {
  bool _isSaving = false;
  String? _errorMessage;

  Future<void> _acknowledgeAndProceed() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Persist completion against the authenticated user's unique account ID
      await authProvider.completeWelcomeNotice();
      // AuthGate will reactively route to MainNavigationScreen
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'Could not save preference: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PopScope(
      // Do not allow accidental dismissal without acknowledging the notice
      canPop: false,
      child: Scaffold(
        backgroundColor: colors.mainBackground,
        body: SafeArea(
          child: Column(
            children: [
              // Scrollable editorial content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Tasteful Privacy Shield Badge
                      Center(
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: colors.primarySageLight,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.primarySageDark.withValues(alpha: 0.3),
                              width: 1.2,
                            ),
                          ),
                          child: Icon(
                            Icons.shield_outlined,
                            size: 32,
                            color: colors.primarySageDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title & Subtitle
                      Text(
                        'Welcome to Pocket Money!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppFonts.headingFont,
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your Money, Your Story.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppFonts.headingFont,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: colors.primarySageDark,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Section Heading & Main Content Card
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: colors.cardBackground,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: colors.border, width: 1.1),
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
                              'A little about your privacy and data',
                              style: TextStyle(
                                fontFamily: AppFonts.headingFont,
                                fontSize: 16.5,
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Pocket Money helps you manually record and calculate your income and expenses.',
                              style: TextStyle(
                                fontFamily: AppFonts.bodyFont,
                                fontSize: 13.5,
                                color: colors.textPrimary,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Bullet points
                            _buildBulletItem(
                              colors,
                              'All income and expense transactions must be entered manually by you.',
                            ),
                            _buildBulletItem(
                              colors,
                              'Pocket Money has no connection to banks, UPI apps or payment services.',
                            ),
                            _buildBulletItem(
                              colors,
                              'The app cannot automatically access or retrieve your payment history.',
                            ),
                            _buildBulletItem(
                              colors,
                              'We never ask for bank account details, card details, UPI PINs or banking passwords.',
                            ),
                            _buildBulletItem(
                              colors,
                              'Your entries are used to calculate your balance and help you track your spending.',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Privacy Section Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: colors.secondaryBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colors.border, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: colors.primarySageDark,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Your privacy matters.',
                                  style: TextStyle(
                                    fontFamily: AppFonts.headingFont,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your Google account is used only to identify your account and sign you in to Pocket Money. Your financial entries are manually provided by you and are used to calculate your income, expenses and balance.',
                              style: TextStyle(
                                fontFamily: AppFonts.bodyFont,
                                fontSize: 13,
                                color: colors.textSecondary,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
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
              ),

              // Fixed Bottom Button Container
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  border: Border(
                    top: BorderSide(color: colors.border, width: 1),
                  ),
                ),
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _acknowledgeAndProceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primarySage,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
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
                              'I Understand & Start',
                              style: TextStyle(
                                fontFamily: AppFonts.bodyFont,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletItem(AppColorScheme colors, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 10),
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: colors.primarySageDark,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: AppFonts.bodyFont,
                fontSize: 13,
                color: colors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
