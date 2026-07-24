import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/onboarding_prefs.dart';
import '../application/auth_providers.dart';

/// Purely branded splash screen and initial routing decision point.
class SplashScreen extends ConsumerStatefulWidget {
  final OnboardingPrefs? onboardingPrefs;
  final Duration initialDelay;

  const SplashScreen({
    super.key,
    this.onboardingPrefs,
    this.initialDelay = const Duration(milliseconds: 1000),
  });

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late final OnboardingPrefs _onboardingPrefs;

  @override
  void initState() {
    super.initState();
    _onboardingPrefs = widget.onboardingPrefs ?? OnboardingPrefs();
    _initAndNavigate();
  }

  Future<void> _initAndNavigate() async {
    await Future.delayed(widget.initialDelay);
    if (!mounted) return;

    await ref.read(authControllerProvider.notifier).checkAuthStatus();
    if (!mounted) return;

    final authState = ref.read(authControllerProvider);
    final hasSeenOnboarding = await _onboardingPrefs.hasSeenOnboarding();

    if (!mounted) return;

    switch (authState) {
      case AuthAuthenticated():
        debugPrint('[SPLASH ROUTER] Routing to /home (AuthAuthenticated)');
        context.go('/home');
        break;
      case AuthUnauthenticated():
      case AuthError():
      default:
        if (!hasSeenOnboarding) {
          debugPrint('[SPLASH ROUTER] Routing to /onboarding (First Launch)');
          context.go('/onboarding');
        } else {
          debugPrint('[SPLASH ROUTER] Routing to /login (Seen Onboarding)');
          context.go('/login');
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGO ASSET PLACEHOLDER: Replace Icon widget with SVG/PNG asset when brand assets are added.
            const Icon(
              Icons.checkroom_rounded,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              'NextLook',
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Discover Your Next Look',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: Colors.white70,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
