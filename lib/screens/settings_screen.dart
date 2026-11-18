import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/app_constants.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showCurrencySelector(BuildContext context) {
    final colors = context.colors;
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final currencies = [
      {'symbol': '₹', 'code': 'INR', 'name': 'Indian Rupee (Default)'},
      {'symbol': '\$', 'code': 'USD', 'name': 'US Dollar'},
      {'symbol': '€', 'code': 'EUR', 'name': 'Euro'},
      {'symbol': '£', 'code': 'GBP', 'name': 'British Pound'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'SELECT DISPLAY CURRENCY',
                  style: TextStyle(
                    fontFamily: AppFonts.bodyFont,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                ...currencies.map((curr) {
                  final isSelected = provider.currencySymbol == curr['symbol'];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primarySageLight
                            : colors.secondaryBackground,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        curr['symbol']!,
                        style: TextStyle(
                          fontFamily: AppFonts.headingFont,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? colors.primarySageDark
                              : colors.textPrimary,
                        ),
                      ),
                    ),
                    title: Text(
                      curr['name']!,
                      style: TextStyle(
                        fontFamily: AppFonts.bodyFont,
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: colors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_rounded, color: colors.primarySageDark)
                        : null,
                    onTap: () {
                      provider.setCurrency(curr['symbol']!);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showThemeSelector(BuildContext context) {
    final colors = context.colors;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    final options = [
      {
        'mode': ThemeMode.light,
        'title': 'Light',
        'subtitle': 'Warm ivory & soft cream (Editorial)',
        'icon': Icons.light_mode_outlined,
      },
      {
        'mode': ThemeMode.dark,
        'title': 'Dark',
        'subtitle': 'Charcoal forest & muted sage',
        'icon': Icons.dark_mode_outlined,
      },
      {
        'mode': ThemeMode.system,
        'title': 'System Default',
        'subtitle': 'Follow device appearance',
        'icon': Icons.settings_system_daydream_outlined,
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer<ThemeProvider>(
          builder: (ctx, currentTheme, _) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'SELECT THEME',
                      style: TextStyle(
                        fontFamily: AppFonts.bodyFont,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...options.map((opt) {
                      final mode = opt['mode'] as ThemeMode;
                      final isSelected = currentTheme.themeMode == mode;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.primarySageLight
                                : colors.secondaryBackground,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            opt['icon'] as IconData,
                            size: 18,
                            color: isSelected
                                ? colors.primarySageDark
                                : colors.textPrimary,
                          ),
                        ),
                        title: Text(
                          opt['title'] as String,
                          style: TextStyle(
                            fontFamily: AppFonts.bodyFont,
                            fontSize: 14.5,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: colors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          opt['subtitle'] as String,
                          style: TextStyle(
                            fontFamily: AppFonts.bodyFont,
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_rounded, color: colors.primarySageDark)
                            : null,
                        onTap: () {
                          themeProvider.setThemeMode(mode);
                          Navigator.pop(ctx);
                        },
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditNameDialog(
    BuildContext context,
    AuthProvider auth,
    String currentName,
  ) {
    final colors = context.colors;
    final controller = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: colors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Edit Display Name',
                style: TextStyle(
                  fontFamily: AppFonts.headingFont,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose a display name for your pocket tracker.',
                      style: TextStyle(
                        fontFamily: AppFonts.bodyFont,
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: controller,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 40,
                      decoration: InputDecoration(
                        labelText: 'Display Name',
                        hintText: 'e.g. Alex',
                        fillColor: colors.secondaryBackground,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Display name cannot be empty';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(dialogCtx),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primarySage,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => isSaving = true);
                          try {
                            await auth.saveDisplayName(controller.text.trim());
                            if (dialogCtx.mounted) {
                              Navigator.pop(dialogCtx);
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Display name updated.'),
                                  backgroundColor: colors.primarySageDark,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() => isSaving = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to update name: $e'),
                                  backgroundColor: colors.supportingTerracotta,
                                ),
                              );
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSignOutDialog(BuildContext context, AuthProvider auth) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Sign Out',
          style: TextStyle(
            fontFamily: AppFonts.headingFont,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        content: Text(
          'Do you want to sign out of this Google account on this device?',
          style: TextStyle(
            fontFamily: AppFonts.bodyFont,
            fontSize: 14,
            color: colors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primarySage,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              Provider.of<TransactionProvider>(context, listen: false).clearAllTransactions();
              auth.signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.mainBackground,
      appBar: AppBar(
        title: const Text('Settings & Info'),
      ),
      body: SafeArea(
        child: Consumer<TransactionProvider>(
          builder: (context, provider, _) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Application Info Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border, width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colors.secondaryOliveLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colors.primarySage.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          color: colors.primarySageDark,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppConstants.appName,
                              style: TextStyle(
                                fontFamily: AppFonts.headingFont,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppConstants.appTagline,
                              style: TextStyle(
                                fontFamily: AppFonts.bodyFont,
                                fontSize: 12.5,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.secondaryBackground,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colors.border),
                        ),
                        child: Text(
                          'v1.0.0',
                          style: TextStyle(
                            fontFamily: AppFonts.bodyFont,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Google Account & Identity Section
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    final user = auth.currentUser;
                    if (user == null) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GOOGLE ACCOUNT',
                          style: TextStyle(
                            fontFamily: AppFonts.bodyFont,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.border, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: colors.primarySageLight,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.person_rounded,
                                      color: colors.primarySageDark,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                user.displayName ?? user.googleName ?? 'Pocket User',
                                                style: TextStyle(
                                                  fontFamily: AppFonts.headingFont,
                                                  fontSize: 15.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: colors.textPrimary,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            InkWell(
                                              onTap: () => _showEditNameDialog(
                                                context,
                                                auth,
                                                user.displayName ?? user.googleName ?? '',
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                              child: Padding(
                                                padding: const EdgeInsets.all(3.0),
                                                child: Icon(
                                                  Icons.edit_outlined,
                                                  size: 15,
                                                  color: colors.primarySageDark,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          user.googleName != null && user.googleName!.isNotEmpty
                                              ? user.googleName!
                                              : (user.displayName ?? 'Google Account Profile'),
                                          style: TextStyle(
                                            fontFamily: AppFonts.bodyFont,
                                            fontSize: 12.5,
                                            color: colors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: colors.incomeGreenBackground,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: colors.incomeGreen.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      'Active',
                                      style: TextStyle(
                                        fontFamily: AppFonts.bodyFont,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: colors.incomeGreen,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.verified_user_outlined,
                                    size: 13,
                                    color: colors.primarySageDark,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Privacy Notice Acknowledged',
                                    style: TextStyle(
                                      fontFamily: AppFonts.bodyFont,
                                      fontSize: 11.5,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Divider(color: colors.border, height: 1),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _showEditNameDialog(
                                      context,
                                      auth,
                                      user.displayName ?? user.googleName ?? '',
                                    ),
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      size: 15,
                                      color: colors.primarySageDark,
                                    ),
                                    label: Text(
                                      'Edit Name',
                                      style: TextStyle(
                                        fontFamily: AppFonts.bodyFont,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: colors.primarySageDark,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _showSignOutDialog(context, auth),
                                    icon: Icon(
                                      Icons.logout_rounded,
                                      size: 15,
                                      color: colors.supportingTerracotta,
                                    ),
                                    label: Text(
                                      'Sign Out',
                                      style: TextStyle(
                                        fontFamily: AppFonts.bodyFont,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: colors.supportingTerracotta,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),

                // Development Notice regarding Storage Decoupling
                Text(
                  'DATA PERSISTENCE & STORAGE',
                  style: TextStyle(
                    fontFamily: AppFonts.bodyFont,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.secondaryBackground,
                    borderRadius: BorderRadius.circular(14),
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
                              color: colors.supportingTerracotta,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Active Architecture: In-Memory Repository',
                            style: TextStyle(
                              fontFamily: AppFonts.bodyFont,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'The database technology selection is intentionally decoupled. Data is currently maintained in memory for verification and testing, and will reset upon app restart. The underlying architecture is plug-and-play ready for SQLite, Supabase, Firebase, or PostgreSQL.',
                        style: TextStyle(
                          fontFamily: AppFonts.bodyFont,
                          fontSize: 12.5,
                          color: colors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Preferences Section (Currency and Theme)
                Text(
                  'PREFERENCES',
                  style: TextStyle(
                    fontFamily: AppFonts.bodyFont,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Material(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.border, width: 1),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.currency_rupee_rounded,
                            color: colors.primarySageDark,
                            size: 20,
                          ),
                          title: Text(
                            'Currency',
                            style: TextStyle(
                              fontFamily: AppFonts.bodyFont,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: colors.textPrimary,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${provider.currencySymbol} (INR)',
                                style: TextStyle(
                                  fontFamily: AppFonts.headingFont,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colors.primarySageDark,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: colors.textSecondary,
                              ),
                            ],
                          ),
                          onTap: () => _showCurrencySelector(context),
                        ),
                        Divider(color: colors.border, height: 1),
                        Consumer<ThemeProvider>(
                          builder: (context, themeProvider, _) {
                            return ListTile(
                              leading: Icon(
                                Icons.palette_outlined,
                                color: colors.primarySageDark,
                                size: 20,
                              ),
                              title: Text(
                                'Design Theme',
                                style: TextStyle(
                                  fontFamily: AppFonts.bodyFont,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: colors.textPrimary,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    themeProvider.themeModeName,
                                    style: TextStyle(
                                      fontFamily: AppFonts.bodyFont,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: colors.primarySageDark,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 18,
                                    color: colors.textSecondary,
                                  ),
                                ],
                              ),
                              onTap: () => _showThemeSelector(context),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // Footer
                Center(
                  child: Text(
                    'Pocket Money Tracker • Classic Editorial Edition\nDesigned for timeless clarity & peace of mind',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.bodyFont,
                      fontSize: 11.5,
                      color: colors.textTertiary,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}
