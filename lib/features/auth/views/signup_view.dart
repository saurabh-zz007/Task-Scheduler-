import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_scheduler/core/constants/app_strings.dart';
import 'package:task_scheduler/core/theme/app_theme.dart';
import 'package:task_scheduler/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:task_scheduler/features/auth/views/widgets/blurred_loading_overlay.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthViewModel viewModel = Get.find<AuthViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryPurple = Color(0xFF6366F1);

    return Obx(
      () => Scaffold(
        backgroundColor: isDark ? AppTheme.darkBackground : Colors.white,
        body: BlurredLoadingOverlay(
          isLoading: viewModel.isLoading.value,
          loadingMessage: 'Creating your account...',
          child: SafeArea(
            child: Stack(
              children: [
                // Subtle top-left back button
                Positioned(
                  top: 8,
                  left: 12,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                    onPressed: () {
                      viewModel.clearForm();
                      Get.back();
                    },
                  ),
                ),

                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32.0,
                      vertical: 20.0,
                    ),
                    physics: const ClampingScrollPhysics(),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
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
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Top Confetti Checkmark Badge (Matches Reference)
                            const Center(
                              child: _SignupConfettiBadge(color: primaryPurple),
                            ),
                            const SizedBox(height: 16),

                            // 2. Centered "Let's get started!" Heading
                            Text(
                              "Let's get started!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // 3. Form
                            Form(
                              key: viewModel.signupFormKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // FULL NAME Label
                                  const Padding(
                                    padding: EdgeInsets.only(
                                      left: 4,
                                      bottom: 8,
                                    ),
                                    child: Text(
                                      'FULL NAME',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ),

                                  // Name Input
                                  TextFormField(
                                    controller: viewModel.nameController,
                                    keyboardType: TextInputType.name,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                    validator: viewModel.validateName,
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1F2937),
                                    ),
                                    decoration: _pillInputDecoration(
                                      isDark: isDark,
                                      hintText: 'Laura Smith',
                                    ),
                                  ),
                                  const SizedBox(height: 18),

                                  // EMAIL ADDRESS Label
                                  const Padding(
                                    padding: EdgeInsets.only(
                                      left: 4,
                                      bottom: 8,
                                    ),
                                    child: Text(
                                      'EMAIL ADDRESS',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ),

                                  // Email Input
                                  TextFormField(
                                    controller: viewModel.emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    validator: viewModel.validateEmail,
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1F2937),
                                    ),
                                    decoration: _pillInputDecoration(
                                      isDark: isDark,
                                      hintText: 'laura@gmail.com',
                                    ),
                                  ),
                                  const SizedBox(height: 18),

                                  // PASSWORD Label
                                  const Padding(
                                    padding: EdgeInsets.only(
                                      left: 4,
                                      bottom: 8,
                                    ),
                                    child: Text(
                                      'PASSWORD',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ),

                                  // Password Input
                                  Obx(
                                    () => TextFormField(
                                      controller: viewModel.passwordController,
                                      obscureText:
                                          viewModel.obscurePassword.value,
                                      textInputAction: TextInputAction.done,
                                      validator: viewModel.validatePassword,
                                      onFieldSubmitted: (_) =>
                                          viewModel.signUpWithEmail(),
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1F2937),
                                      ),
                                      decoration: _pillInputDecoration(
                                        isDark: isDark,
                                        hintText: '••••••••',
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            viewModel.obscurePassword.value
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            size: 19,
                                            color: const Color(0xFF9CA3AF),
                                          ),
                                          onPressed: viewModel
                                              .togglePasswordVisibility,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 28),

                                  // Centered Pill "Sign up" Button (Matches Reference)
                                  Center(
                                    child: SizedBox(
                                      width: 190,
                                      height: 60,
                                      child: ElevatedButton(
                                        onPressed: viewModel.isLoading.value
                                            ? null
                                            : () => viewModel.signUpWithEmail(),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryPurple,
                                          foregroundColor: Colors.white,
                                          elevation: 6,
                                          shadowColor: primaryPurple.withValues(
                                            alpha: 0.35,
                                          ),
                                          shape: const StadiumBorder(),
                                        ),
                                        child: const Text(
                                          'Sign up',
                                          style: TextStyle(
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),

                            // 4. "or sign up with" Label
                            const Text(
                              'or sign up with',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // 5. Circular Social Buttons Row (Facebook, Google, Apple)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _CircularSocialButton(
                                  backgroundColor: const Color(0xFF3B5998),
                                  isLocked: true,
                                  lockedTooltip: AppStrings.facebookLocked,
                                  onTap: viewModel.isLoading.value
                                      ? null
                                      : viewModel.signInWithFacebook,
                                  child: const Text(
                                    'f',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 18),
                                _CircularSocialButton(
                                  backgroundColor: const Color(0xFFEA4335),
                                  onTap: viewModel.isLoading.value
                                      ? null
                                      : viewModel.signInWithGoogle,
                                  child: const Text(
                                    'G',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 18),
                                _CircularSocialButton(
                                  backgroundColor: Colors.black,
                                  isLocked: true,
                                  lockedTooltip: AppStrings.appleLocked,
                                  onTap: viewModel.isLoading.value
                                      ? null
                                      : viewModel.signInWithApple,
                                  child: const Icon(
                                    Icons.apple_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),

                            // 6. Bottom "Already an account? Log in"
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Already an account? ',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    viewModel.clearForm();
                                    Get.back();
                                  },
                                  child: const Text(
                                    'Log in',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: primaryPurple,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _pillInputDecoration({
    required bool isDark,
    required String hintText,
    Widget? suffixIcon,
  }) {
    final fillColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFF3F4F6);

    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF9CA3AF),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: fillColor,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
    );
  }
}

class _CircularSocialButton extends StatelessWidget {
  final Color backgroundColor;
  final VoidCallback? onTap;
  final Widget child;
  final bool isLocked;
  final String? lockedTooltip;

  const _CircularSocialButton({
    required this.backgroundColor,
    required this.onTap,
    required this.child,
    this.isLocked = false,
    this.lockedTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Opacity(
          opacity: isLocked ? 0.70 : 1.0,
          child: Material(
            color: backgroundColor,
            shape: const CircleBorder(),
            elevation: isLocked ? 1 : 3,
            shadowColor: backgroundColor.withValues(alpha: 0.35),
            child: InkWell(
              onTap: isLocked
                  ? () {
                      if (lockedTooltip != null) {
                        Get.snackbar(
                          'Option Locked',
                          lockedTooltip!,
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF1F2937).withValues(alpha: 0.95),
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                          duration: const Duration(seconds: 2),
                          icon: const Icon(
                            Icons.lock_rounded,
                            color: Color(0xFFFDE047),
                            size: 20,
                          ),
                        );
                      }
                    }
                  : onTap,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 52,
                height: 52,
                child: Center(child: child),
              ),
            ),
          ),
        ),
        if (isLocked)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(3.5),
              decoration: BoxDecoration(
                color: const Color(0xFF374151),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.lock_rounded,
                size: 10,
                color: Color(0xFFFDE047),
              ),
            ),
          ),
      ],
    );
  }
}

class _SignupConfettiBadge extends StatelessWidget {
  final Color color;

  const _SignupConfettiBadge({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 24,
            left: 16,
            child: _dot(6, const Color(0xFFF59E0B)),
          ),
          const Positioned(
            top: 12,
            right: 28,
            child: Icon(Icons.add_rounded, size: 14, color: Color(0xFFFBBF24)),
          ),
          Positioned(
            top: 48,
            right: 12,
            child: _dot(8, const Color(0xFF1E293B)),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: _dot(7, const Color(0xFFA5B4FC)),
          ),
          Positioned(
            bottom: 28,
            left: 24,
            child: _dot(5, const Color(0xFFD1D5DB)),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.28),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 40,
            ),
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
