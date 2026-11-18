import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_theme.dart';

class GoogleSignInScreen extends StatefulWidget {
  const GoogleSignInScreen({super.key});

  @override
  State<GoogleSignInScreen> createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<GoogleSignInScreen> {
  void _signIn(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: colors.mainBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Editorial Emblem / Badge
                Center(
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: colors.cardBackground,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.border, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: colors.shadow,
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 34,
                      color: colors.primarySageDark,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // App Title & Tagline
                Text(
                  AppConstants.appName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.headingFont,
                    fontSize: 28,
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
                    fontFamily: AppFonts.bodyFont,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: colors.textSecondary,
                  ),
                ),

                const SizedBox(height: 48),

                // Sign-In Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.border, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow,
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'SIGN IN TO CONTINUE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppFonts.bodyFont,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Continue with Google Button
                      ElevatedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () => _signIn(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.cardBackground,
                          foregroundColor: colors.textPrimary,
                          elevation: 0,
                          side: BorderSide(color: colors.border, width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: authProvider.isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.primarySage,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildGoogleGLogo(),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Continue with Google',
                                    style: TextStyle(
                                      fontFamily: AppFonts.bodyFont,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),

                if (authProvider.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.expenseBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: colors.supportingTerracotta.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      authProvider.errorMessage!,
                      style: TextStyle(
                        fontFamily: AppFonts.bodyFont,
                        fontSize: 12.5,
                        color: colors.supportingTerracotta,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 36),

                // Trust indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 16,
                      color: colors.primarySageDark,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'No banking credentials required • Private & Offline',
                      style: TextStyle(
                        fontFamily: AppFonts.bodyFont,
                        fontSize: 12,
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleGLogo() {
    // Tasteful minimalist multi-color Google G icon representation
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            fontFamily: AppFonts.headingFont,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.blue.shade700,
          ),
        ),
      ),
    );
  }
}
