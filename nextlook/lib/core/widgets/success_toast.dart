import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppToast {
  static void show(
    BuildContext context, {
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onActionTap,
    bool isError = false,
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    const successGreen = Color(0xFF22C55E);
    const errorRed = Color(0xFFEF4444);
    const darkNavy = Color(0xFF1E1E2D);
    const primaryPurple = Color(0xFF6C63FF);

    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();

    final badgeColor = isError ? errorRed : successGreen;
    final badgeIcon = isError ? Icons.priority_high_rounded : Icons.check_rounded;

    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final topOffset = mediaQuery.padding.top + 12;
    final bottomMargin = screenHeight > 300 ? (screenHeight - topOffset - 80) : 20.0;

    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: bottomMargin > 0 ? bottomMargin : 20,
      ),
      padding: EdgeInsets.zero,
      duration: duration,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: isError ? errorRed.withValues(alpha: 0.2) : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Circular Badge Icon
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                badgeIcon,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),

            // Text Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: darkNavy,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            // Action Link ("View Cart")
            if (actionLabel != null && onActionTap != null) ...[
              const SizedBox(width: 10),
              GestureDetector(
                key: const Key('toast_action_button'),
                onTap: () {
                  messenger.hideCurrentSnackBar();
                  onActionTap();
                },
                child: Text(
                  actionLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: primaryPurple,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    messenger.showSnackBar(snackBar);
  }
}
