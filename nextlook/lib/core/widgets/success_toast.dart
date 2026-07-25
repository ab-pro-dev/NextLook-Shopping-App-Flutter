import 'dart:async';
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
    final overlayState = Overlay.maybeOf(context);
    if (overlayState == null) return;

    late OverlayEntry overlayEntry;

    void removeEntry() {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    }

    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        title: title,
        subtitle: subtitle,
        actionLabel: actionLabel,
        onActionTap: onActionTap != null
            ? () {
                removeEntry();
                onActionTap();
              }
            : null,
        isError: isError,
        duration: duration,
        onDismissed: removeEntry,
      ),
    );

    overlayState.insert(overlayEntry);
  }
}

class _ToastWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final bool isError;
  final Duration duration;
  final VoidCallback onDismissed;

  const _ToastWidget({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onActionTap,
    required this.isError,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _timer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -0.8),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    // Auto-dismiss timer
    _timer = Timer(widget.duration, () {
      if (mounted && !_isDismissing) {
        _dismissAnimated();
      }
    });
  }

  void _dismissAnimated() async {
    if (_isDismissing) return;
    _timer?.cancel();
    if (mounted) {
      setState(() {
        _isDismissing = true;
      });
    }

    await _controller.reverse();
    widget.onDismissed();
  }

  void _handleActionTap() {
    _timer?.cancel();
    widget.onActionTap?.call();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const successGreen = Color(0xFF22C55E);
    const errorRed = Color(0xFFEF4444);
    const darkNavy = Color(0xFF1E1E2D);
    const primaryPurple = Color(0xFF6C63FF);

    final badgeColor = widget.isError ? errorRed : successGreen;
    final badgeIcon = widget.isError ? Icons.priority_high_rounded : Icons.check_rounded;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _offsetAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: widget.isError ? errorRed.withValues(alpha: 0.2) : Colors.grey[200]!,
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

                  // Middle Text Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: darkNavy,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
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

                  // Action Link (e.g. "View Cart")
                  if (widget.actionLabel != null && widget.onActionTap != null) ...[
                    const SizedBox(width: 10),
                    GestureDetector(
                      key: const Key('toast_action_button'),
                      onTap: _handleActionTap,
                      child: Text(
                        widget.actionLabel!,
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
          ),
        ),
      ),
    );
  }
}
