import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../utils/app_theme.dart';

/// Floating toast/snackbar notification with an animated 5-second countdown
/// and a prominent, easy-to-tap "Undo" action.
class DeletionUndoBanner extends StatefulWidget {
  final TransactionModel transaction;
  final VoidCallback onUndo;
  final Duration duration;

  const DeletionUndoBanner({
    super.key,
    required this.transaction,
    required this.onUndo,
    this.duration = const Duration(seconds: 5),
  });

  @override
  State<DeletionUndoBanner> createState() => _DeletionUndoBannerState();
}

class _DeletionUndoBannerState extends State<DeletionUndoBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _secondsRemaining = 5;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.duration.inSeconds;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _controller.addListener(() {
      final rem = (widget.duration.inSeconds * (1.0 - _controller.value)).ceil();
      if (rem != _secondsRemaining && mounted) {
        setState(() {
          _secondsRemaining = rem.clamp(0, widget.duration.inSeconds);
        });
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.isDark ? const Color(0xFF232721) : const Color(0xFF2C322B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.isDark ? colors.borderBeige : Colors.black12,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                // Trash icon badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0x26C58F78),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: Color(0xFFE5A189),
                  ),
                ),
                const SizedBox(width: 12),

                // Notification text & countdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Transaction deleted',
                        style: TextStyle(
                          fontFamily: AppFonts.headingFont,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF2F0E8),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _secondsRemaining > 0
                            ? 'Undo expires in ${_secondsRemaining}s'
                            : 'Removing permanently...',
                        style: const TextStyle(
                          fontFamily: AppFonts.bodyFont,
                          fontSize: 11.5,
                          color: Color(0xFFAAAFA4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Large, easy-to-tap Undo button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onUndo,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF91A58B),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.undo_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Undo',
                            style: TextStyle(
                              fontFamily: AppFonts.bodyFont,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Visual 5-second countdown progress bar
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return LinearProgressIndicator(
                value: (1.0 - _controller.value).clamp(0.0, 1.0),
                minHeight: 2.5,
                backgroundColor: const Color(0x22FFFFFF),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF91A58B)),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Helper function to display the 5-second undo snackbar consistently
void showDeletionUndoSnackBar({
  required BuildContext context,
  required TransactionModel transaction,
  required VoidCallback onUndo,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      duration: const Duration(milliseconds: 5000),
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: EdgeInsets.zero,
      content: DeletionUndoBanner(
        transaction: transaction,
        onUndo: () {
          messenger.hideCurrentSnackBar();
          onUndo();
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Transaction restored.'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    ),
  );
}
