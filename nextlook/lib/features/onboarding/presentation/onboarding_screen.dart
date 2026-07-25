import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Phase flag: false = Splash Welcome View (Get Started), true = 3-Screen Onboarding Flow
  bool _showOnboardingFlow = false;

  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isGetStartedPressed = false;
  bool _isActionButtonPressed = false;

  final List<String> _onboardingImages = const [
    'assets/images/screen_1.png',
    'assets/images/screen_2.png',
    'assets/images/screen_3.png',
  ];

  void _onGetStartedTap() {
    setState(() {
      _showOnboardingFlow = true;
    });
  }

  void _onSkipTap() {
    context.go('/home');
  }

  void _onNextTap() {
    if (_currentPage < _onboardingImages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: !_showOnboardingFlow
          ? _buildSplashWelcomeView(context, bottomPadding)
          : _buildOnboardingFlowView(context, topPadding, bottomPadding),
    );
  }

  /// 1. Initial Splash Welcome View (NextLook artwork + Get Started button)
  Widget _buildSplashWelcomeView(BuildContext context, double bottomPadding) {
    return Scaffold(
      key: const ValueKey('SplashWelcomeView'),
      backgroundColor: const Color(0xFF070B16), // Deep navy/black
      body: Stack(
        fit: StackFit.expand,
        children: [
          // NextLook Splash Artwork (Hanger Logo + NextLook title + Subline + Model)
          Positioned.fill(
            child: Image.asset(
              'assets/images/nextlook_splash_bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF070B16),
                  child: const Center(
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: 80,
                      color: Colors.white24,
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Gradient overlay for button contrast
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 180,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xCC070B16),
                    Color(0xFF070B16),
                  ],
                ),
              ),
            ),
          ),

          // Coral/Pink "Get Started" Pill Button
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 32,
                  right: 32,
                  bottom: bottomPadding > 0 ? 16 : 32,
                ),
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _isGetStartedPressed = true),
                  onTapUp: (_) {
                    setState(() => _isGetStartedPressed = false);
                    _onGetStartedTap();
                  },
                  onTapCancel: () => setState(() => _isGetStartedPressed = false),
                  child: AnimatedScale(
                    scale: _isGetStartedPressed ? 0.95 : 1.0,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeOutCubic,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: _isGetStartedPressed
                            ? const Color(0xFFD63E45)
                            : const Color(0xFFF2545B), // Coral/pink (#F2545B)
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF2545B).withValues(alpha: 0.45),
                            blurRadius: 24,
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
                          letterSpacing: 0.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. 3-Screen Onboarding Flow View (screen_1.png, screen_2.png, screen_3.png)
  Widget _buildOnboardingFlowView(BuildContext context, double topPadding, double bottomPadding) {
    final isLastPage = _currentPage == _onboardingImages.length - 1;

    return Scaffold(
      key: const ValueKey('OnboardingFlowView'),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // PageView for screen_1.png, screen_2.png, screen_3.png
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _onboardingImages.length,
            itemBuilder: (context, index) {
              return Container(
                color: Colors.white,
                child: Column(
                  children: [
                    SizedBox(height: topPadding + 48), // Space for top-right Skip button
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Image.asset(
                          _onboardingImages[index],
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Screen ${index + 1}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF333333),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 120), // Bottom space for dots & action button
                  ],
                ),
              );
            },
          ),

          // Top-Right "Skip" Button (dark text on white background)
          Positioned(
            top: topPadding + 8,
            right: 16,
            child: SafeArea(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _onSkipTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Text(
                      'Skip',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom Controls (3 Pagination Dots + Dark Pill Next/Finish Button)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: bottomPadding > 0 ? bottomPadding + 12 : 28,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pagination Dots (3 dots total)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingImages.length,
                      (index) {
                        final isActive = _currentPage == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: isActive ? 24 : 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFF2545B) // Active brand Coral/Pink (#F2545B)
                                : const Color(0xFFE0E0E0), // Inactive light grey
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Dark Pill Action Button ("Next" for Screens 1 & 2, "Finish" for Screen 3)
                  GestureDetector(
                    onTapDown: (_) => setState(() => _isActionButtonPressed = true),
                    onTapUp: (_) {
                      setState(() => _isActionButtonPressed = false);
                      _onNextTap();
                    },
                    onTapCancel: () => setState(() => _isActionButtonPressed = false),
                    child: AnimatedScale(
                      scale: _isActionButtonPressed ? 0.96 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeOutCubic,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _isActionButtonPressed
                              ? const Color(0xFF141420)
                              : const Color(0xFF1E1E2E), // Dark Navy/Black (#1E1E2E)
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E1E2E).withValues(alpha: 0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Text(
                          isLastPage ? 'Finish' : 'Next',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.center,
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
