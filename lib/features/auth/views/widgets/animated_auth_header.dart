import 'package:flutter/material.dart';
import 'package:task_scheduler/core/theme/app_theme.dart';

class AnimatedAuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const AnimatedAuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.check_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Themed Badge with decorative confetti dots matching OnboardingView
          SizedBox(
            width: 100,
            height: 94,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Top-left gold dot
                Positioned(
                  top: 10,
                  left: 2,
                  child: _dot(6, AppTheme.accentGold),
                ),
                // Top-right sparkle
                Positioned(
                  top: 4,
                  right: 18,
                  child: Icon(
                    Icons.add_rounded,
                    size: 14,
                    color: AppTheme.accentSparkle,
                  ),
                ),
                // Middle-right navy/slate dot
                Positioned(
                  top: 36,
                  right: 8,
                  child: _dot(7, isDark ? Colors.white38 : const Color(0xFF1E293B)),
                ),
                // Bottom-right lavender dot
                Positioned(
                  bottom: 8,
                  right: 22,
                  child: _dot(6, AppTheme.accentLavender),
                ),
                // Bottom-left grey dot
                Positioned(
                  bottom: 12,
                  left: 6,
                  child: _dot(5, const Color(0xFFD1D5DB)),
                ),

                // Main Rounded Square Badge
                Container(
                  width: 64,
                  height: 64,
                  margin: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.32),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Heading Title matching reference style
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Soft Grey Subtitle matching reference style
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 15.5,
              height: 1.5,
              fontWeight: FontWeight.w400,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
