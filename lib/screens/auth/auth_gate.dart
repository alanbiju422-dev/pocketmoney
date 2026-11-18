import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../main_navigation_screen.dart';
import 'display_name_screen.dart';
import 'google_sign_in_screen.dart';
import 'welcome_privacy_notice_screen.dart';

/// Central Auth & Onboarding Gate for Pocket Money.
///
/// Reactively handles the complete user flow:
/// 1. Unauthenticated -> [GoogleSignInScreen]
/// 2. Signed In & First-Time (missing display name) -> [DisplayNameScreen]
/// 3. Display name set & First-Time (notice unacknowledged) -> [WelcomePrivacyNoticeScreen]
/// 4. Onboarded & Returning users -> [MainNavigationScreen]
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoading && auth.currentUser == null) {
          return Scaffold(
            backgroundColor: colors.mainBackground,
            body: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: colors.primarySage,
              ),
            ),
          );
        }

        if (!auth.isAuthenticated) {
          return const GoogleSignInScreen();
        }

        if (auth.needsDisplayName) {
          return const DisplayNameScreen();
        }

        if (auth.needsWelcomeNotice) {
          return const WelcomePrivacyNoticeScreen();
        }

        return const MainNavigationScreen();
      },
    );
  }
}
