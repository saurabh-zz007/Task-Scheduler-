import 'package:flutter/material.dart';
import 'package:task_scheduler/core/theme/app_theme.dart';

enum SocialButtonType {
  google,
  apple,
  facebook,
}

class SocialAuthButton extends StatelessWidget {
  final SocialButtonType type;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isLocked;
  final String? customLabel;

  const SocialAuthButton({
    super.key,
    required this.type,
    required this.onPressed,
    this.isLoading = false,
    this.isLocked = false,
    this.customLabel,
  });

  String get _label {
    if (customLabel != null) return customLabel!;
    switch (type) {
      case SocialButtonType.google:
        return 'Continue with Google';
      case SocialButtonType.apple:
        return 'Continue with Apple';
      case SocialButtonType.facebook:
        return 'Continue with Facebook';
    }
  }

  Widget _buildIcon(BuildContext context) {
    switch (type) {
      case SocialButtonType.google:
        return const _GoogleIcon();
      case SocialButtonType.apple:
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Icon(
          Icons.apple,
          size: 22,
          color: isDark ? Colors.white : Colors.black87,
        );
      case SocialButtonType.facebook:
        return const Icon(
          Icons.facebook,
          size: 22,
          color: Color(0xFF1877F2), // Official Facebook blue
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color bgColor = isDark
        ? AppTheme.darkSurface
        : AppTheme.lightSurface;
    final Color borderColor = isDark
        ? AppTheme.darkBorder
        : AppTheme.lightBorder;
    final Color textColor = isDark
        ? AppTheme.darkTextPrimary
        : AppTheme.lightTextPrimary;

    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: (isLoading || isLocked) ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isLocked ? bgColor.withValues(alpha: 0.6) : bgColor,
          foregroundColor: textColor,
          side: BorderSide(color: borderColor, width: 1.2),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(context),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                _label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor.withValues(alpha: isLocked ? 0.6 : 1.0),
                  letterSpacing: -0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isLocked) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.lock_rounded,
                size: 14,
                color: Color(0xFFF59E0B),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A crisp, lightweight vector drawing of the Google 4-color 'G' icon.
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: _GoogleIconPainter(),
      ),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final paintBlue = Paint()..color = const Color(0xFF4285F4);
    final paintRed = Paint()..color = const Color(0xFFEA4335);
    final paintYellow = Paint()..color = const Color(0xFFFBBC05);
    final paintGreen = Paint()..color = const Color(0xFF34A853);

    final rect = Rect.fromLTWH(0, 0, w, h);

    // Blue horizontal bar and right arc
    final bluePath = Path()
      ..moveTo(w * 0.95, h * 0.5)
      ..arcTo(rect, 0, -0.75, false)
      ..lineTo(w * 0.5, h * 0.5)
      ..lineTo(w * 0.5, h * 0.68)
      ..lineTo(w * 0.85, h * 0.68)
      ..arcTo(rect, 0.45, 0.35, false)
      ..close();
    canvas.drawPath(bluePath, paintBlue);

    // Red top arc
    final redPath = Path()
      ..arcTo(rect, -0.75, -1.8, false)
      ..lineTo(w * 0.5, h * 0.28)
      ..arcTo(
        Rect.fromLTWH(w * 0.22, h * 0.22, w * 0.56, h * 0.56),
        -2.55,
        1.8,
        false,
      )
      ..close();
    canvas.drawPath(redPath, paintRed);

    // Yellow left arc
    final yellowPath = Path()
      ..arcTo(rect, -2.55, -1.4, false)
      ..lineTo(w * 0.28, h * 0.5)
      ..arcTo(
        Rect.fromLTWH(w * 0.22, h * 0.22, w * 0.56, h * 0.56),
        -3.95,
        1.4,
        false,
      )
      ..close();
    canvas.drawPath(yellowPath, paintYellow);

    // Green bottom arc
    final greenPath = Path()
      ..arcTo(rect, -3.95, -1.88, false)
      ..lineTo(w * 0.65, h * 0.68)
      ..arcTo(
        Rect.fromLTWH(w * 0.22, h * 0.22, w * 0.56, h * 0.56),
        -5.83,
        1.88,
        false,
      )
      ..close();
    canvas.drawPath(greenPath, paintGreen);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
