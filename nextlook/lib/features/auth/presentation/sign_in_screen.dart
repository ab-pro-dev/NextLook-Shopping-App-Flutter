import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../application/auth_providers.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final authNotifier = ref.read(authControllerProvider.notifier);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next is AuthAuthenticated) {
        context.go('/home');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 20),

              // BRANDING HEADER
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_rounded,
                      color: AppColors.primary,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'NextLook',
                    style: GoogleFonts.poppins(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Discover Your Next Look',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),

              // SIGN IN ACTIONS & ERROR AREA
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // INLINE ERROR BROWSER
                  if (authState is AuthError) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              authState.message,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // GOOGLE SIGN-IN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      key: const Key('google_sign_in_button'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: authState is AuthLoading
                          ? null
                          : () => authNotifier.signInWithGoogle(),
                      child: authState is AuthLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildGoogleLogo(),
                                const SizedBox(width: 12),
                                Text(
                                  'Continue with Google',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1F1F1F),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'By continuing, you agree to NextLook\'s Terms of Service\nand Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[500],
                      height: 1.4,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  /// Official Google 'G' Logo icon rendering
  Widget _buildGoogleLogo() {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

/// Custom Painter drawing the official 4-color Google 'G' logo icon
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double center = size.width / 2;
    final double radius = size.width / 2;

    final Paint red = Paint()..color = const Color(0xFFEA4335);
    final Paint blue = Paint()..color = const Color(0xFF4285F4);
    final Paint green = Paint()..color = const Color(0xFF34A853);
    final Paint yellow = Paint()..color = const Color(0xFFFBBC05);

    // Blue arc & bar
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center, center), radius: radius),
      -0.5,
      2.1,
      true,
      blue,
    );

    // Green arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center, center), radius: radius),
      1.6,
      1.1,
      true,
      green,
    );

    // Yellow arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center, center), radius: radius),
      2.7,
      1.1,
      true,
      yellow,
    );

    // Red arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center, center), radius: radius),
      3.8,
      1.8,
      true,
      red,
    );

    // Inner cutout
    final Paint white = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center, center), radius * 0.55, white);

    // Center bar
    final Rect barRect = Rect.fromLTRB(center, center - radius * 0.22, center + radius, center + radius * 0.22);
    canvas.drawRect(barRect, blue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
