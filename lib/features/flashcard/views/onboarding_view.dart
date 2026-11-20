import 'dart:math' as math;
import 'package:flutter/material.dart';

class OnboardingSlideData {
  final String title;
  final String subtitle;
  final IconData badgeIcon;
  final Color accentColor;

  const OnboardingSlideData({
    required this.title,
    required this.subtitle,
    required this.badgeIcon,
    this.accentColor = const Color(0xFF6366F1), // Vibrant indigo-purple
  });
}

class OnboardingView extends StatefulWidget {
  final VoidCallback? onCompleted;

  const OnboardingView({super.key, this.onCompleted});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  late final AnimationController _floatController;

  // 3 Onboarding Flash Cards matching the reference style
  final List<OnboardingSlideData> _slides = const [
    OnboardingSlideData(
      title: 'Get things done.',
      subtitle: 'Just a click away from\nplanning your tasks.',
      badgeIcon: Icons.check_rounded,
      accentColor: Color(0xFF6366F1),
    ),
    OnboardingSlideData(
      title: 'Stay on schedule.',
      subtitle: 'Organize priorities and set\nsmart reminders effortlessly.',
      badgeIcon: Icons.calendar_today_rounded,
      accentColor: Color(0xFF6366F1),
    ),
    OnboardingSlideData(
      title: 'Track your progress.',
      subtitle: 'Build daily momentum and\nachieve every milestone.',
      badgeIcon: Icons.bolt_rounded,
      accentColor: Color(0xFF6366F1),
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Gentle continuous breathing/floating animation for the badge & confetti
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    } else {
      if (widget.onCompleted != null) {
        widget.onCompleted!();
      } else {
        // Placeholder feedback while testing standalone
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Onboarding complete! Ready to connect to Login.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _slides[_currentIndex].accentColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Swipeable Flash Cards (PageView)
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return _OnboardingCardContent(
                data: _slides[index],
                pageController: _pageController,
                index: index,
                floatAnimation: _floatController,
              );
            },
          ),

          // 2. Smooth Animated Page Indicator Dots (Left-aligned like reference)
          Positioned(
            left: 36,
            bottom: 195,
            child: Row(
              children: List.generate(_slides.length, (index) {
                final isActive = _currentIndex == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.only(right: 8),
                  height: 7,
                  width: isActive ? 18 : 7,
                  decoration: BoxDecoration(
                    color: isActive
                        ? primaryColor
                        : const Color(0xFFD1D5DB), // Soft grey inactive dot
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
          ),

          // 3. Optional Skip Button at top-right
          if (_currentIndex < _slides.length - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 24,
              child: TextButton(
                onPressed: () {
                  if (widget.onCompleted != null) {
                    widget.onCompleted!();
                  } else {
                    _pageController.animateToPage(
                      _slides.length - 1,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                    );
                  }
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          // 4. Bottom-Right Quarter-Circle Action Button (Exact Reference Shape)
          Positioned(
            right: -42,
            bottom: -42,
            child: GestureDetector(
              onTap: _handleNext,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 195,
                height: 195,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.32),
                      blurRadius: 24,
                      offset: const Offset(-4, -4),
                    ),
                  ],
                ),
                child: Align(
                  alignment: const Alignment(-0.28, -0.28),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: anim,
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: Icon(
                      _currentIndex == _slides.length - 1
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                      key: ValueKey(_currentIndex == _slides.length - 1),
                      color: Colors.white,
                      size: 32,
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
}

class _OnboardingCardContent extends StatelessWidget {
  final OnboardingSlideData data;
  final PageController pageController;
  final int index;
  final Animation<double> floatAnimation;

  const _OnboardingCardContent({
    required this.data,
    required this.pageController,
    required this.index,
    required this.floatAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([pageController, floatAnimation]),
      builder: (context, child) {
        // Calculate page offset for smooth parallax & scale transitions
        double pageOffset = 0.0;
        if (pageController.hasClients &&
            pageController.position.haveDimensions) {
          pageOffset = (pageController.page ?? 0.0) - index;
        }

        final clampedOffset = pageOffset.clamp(-1.0, 1.0);
        final scale = 1.0 - (clampedOffset.abs() * 0.14);
        final opacity = (1.0 - (clampedOffset.abs() * 0.65)).clamp(0.0, 1.0);
        final floatY = math.sin(floatAnimation.value * math.pi) * 6.0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 3),

              // Centered Icon Badge + Decorative Confetti
              Center(
                child: Transform.translate(
                  offset: Offset(clampedOffset * -35, -floatY),
                  child: Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: _ConfettiBadge(
                        icon: data.badgeIcon,
                        color: data.accentColor,
                        floatProgress: floatAnimation.value,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Left-aligned Bold Heading
              Transform.translate(
                offset: Offset(clampedOffset * 25, 0),
                child: Opacity(
                  opacity: opacity,
                  child: Text(
                    data.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Left-aligned Soft Grey Subtitle
              Transform.translate(
                offset: Offset(clampedOffset * 45, 0),
                child: Opacity(
                  opacity: opacity,
                  child: Text(
                    data.subtitle,
                    style: const TextStyle(
                      fontSize: 15.5,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 4),
            ],
          ),
        );
      },
    );
  }
}

class _ConfettiBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double floatProgress;

  const _ConfettiBadge({
    required this.icon,
    required this.color,
    required this.floatProgress,
  });

  @override
  Widget build(BuildContext context) {
    final pulse = (floatProgress - 0.5) * 6;

    return SizedBox(
      width: 190,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Top-left gold dot
          Positioned(
            top: 42 + pulse,
            left: 22,
            child: _dot(7, const Color(0xFFF59E0B)),
          ),
          // Top-right small sparkle
          Positioned(
            top: 24 - pulse,
            right: 36,
            child: Icon(
              Icons.add_rounded,
              size: 16,
              color: const Color(0xFFFBBF24),
            ),
          ),
          // Middle-right dark navy dot
          Positioned(
            top: 72 + pulse,
            right: 18,
            child: _dot(9, const Color(0xFF1E293B)),
          ),
          // Bottom-right lavender dot
          Positioned(
            bottom: 36 - pulse,
            right: 26,
            child: _dot(8, const Color(0xFFA5B4FC)),
          ),
          // Bottom-left tiny grey dot
          Positioned(
            bottom: 46 + pulse,
            left: 34,
            child: _dot(5, const Color(0xFFD1D5DB)),
          ),

          // Main Rounded Square Badge
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.30),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 54),
          ),
        ],
      ),
    );
  }

  Widget _dot(double size, Color dotColor) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
    );
  }
}
