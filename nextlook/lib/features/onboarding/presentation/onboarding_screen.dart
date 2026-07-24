import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _isPressed = false;

  void _onGetStartedTap() {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF070B16), // Deep navy-to-black
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Model Image filling the lower-center/right area
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF070B16), // Solid top for high contrast header
                    Colors.transparent,
                    Colors.transparent,
                    Color(0xFF070B16), // Gradient overlay at bottom for button area
                  ],
                  stops: [0.0, 0.28, 0.72, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstOut,
              child: Image.asset(
                'assets/images/onboarding_model_bg.jpg',
                fit: BoxFit.cover,
                alignment: const Alignment(0.4, 0.2), // Position lower-center/right
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF0D1527),
                    child: const Center(
                      child: Icon(
                        Icons.person_outline,
                        size: 80,
                        color: Colors.white24,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 2. Content overlay with safe area padding
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: topPadding > 0 ? 16 : 32),

                  // Top-left Headline & Subtext
                  const Text(
                    'Your Style, Your Way',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.15,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Discover fashion that fits your personality.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFB0B8C8), // Light grey subtext
                      height: 1.4,
                    ),
                  ),

                  const Spacer(),

                  // Bottom Pill-Shaped "Get Started" Button
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: bottomPadding > 0 ? 12 : 28,
                      ),
                      child: GestureDetector(
                        onTapDown: (_) => setState(() => _isPressed = true),
                        onTapUp: (_) {
                          setState(() => _isPressed = false);
                          _onGetStartedTap();
                        },
                        onTapCancel: () => setState(() => _isPressed = false),
                        child: AnimatedScale(
                          scale: _isPressed ? 0.95 : 1.0,
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.easeOutCubic,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 48,
                            ),
                            decoration: BoxDecoration(
                              color: _isPressed
                                  ? const Color(0xFFD63E45) // Darker coral/pink on press
                                  : const Color(0xFFF2545B), // Vibrant Coral/Pink (#F2545B)
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF2545B).withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
