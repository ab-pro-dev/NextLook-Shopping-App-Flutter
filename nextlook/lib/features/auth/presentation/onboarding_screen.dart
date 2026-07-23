import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/onboarding_prefs.dart';

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}

/// Onboarding screen featuring 3 swipeable pages, dot indicators, and navigation controls.
class OnboardingScreen extends StatefulWidget {
  final OnboardingPrefs? onboardingPrefs;

  const OnboardingScreen({
    super.key,
    this.onboardingPrefs,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  late final OnboardingPrefs _onboardingPrefs;
  int _currentPage = 0;

  static const List<OnboardingItem> _pages = [
    OnboardingItem(
      title: 'Discover Your Style',
      description:
          'Explore thousands of trending fashion items curated just for you',
      icon: Icons.style_rounded,
      accentColor: Color(0xFF6C63FF),
    ),
    OnboardingItem(
      title: 'Easy & Secure Shopping',
      description:
          'Multiple payment options and fast, reliable delivery to your door',
      icon: Icons.shopping_bag_rounded,
      accentColor: Color(0xFF6C63FF),
    ),
    OnboardingItem(
      title: 'Track Every Order',
      description:
          'Follow your order from checkout to doorstep in real time',
      icon: Icons.local_shipping_rounded,
      accentColor: Color(0xFF6C63FF),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _onboardingPrefs = widget.onboardingPrefs ?? OnboardingPrefs();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await _onboardingPrefs.markOnboardingSeen();
    if (mounted) {
      context.go('/login');
    }
  }

  void _onNextPressed() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF6C63FF);
    const backgroundColor = Color(0xFFF5F6FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48),
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      key: const Key('onboarding_skip_button'),
                      onPressed: _completeOnboarding,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 48),
                ],
              ),
            ),

            // Swipeable PageView
            Expanded(
              child: PageView.builder(
                key: const Key('onboarding_pageview'),
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final item = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ILLUSTRATION PLACEHOLDER: Replace this container with SVG/Image asset when final brand illustration assets are provided.
                        Container(
                          height: MediaQuery.of(context).size.height * 0.35,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: item.accentColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: item.accentColor.withValues(alpha: 0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                item.icon,
                                size: 80,
                                color: item.accentColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E1E2D),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item.description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page Dot Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? primaryPurple
                        : const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Bottom Navigation Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  key: const Key('onboarding_next_button'),
                  onPressed: _onNextPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPurple,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
