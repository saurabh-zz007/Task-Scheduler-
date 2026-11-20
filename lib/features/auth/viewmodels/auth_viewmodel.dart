import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_scheduler/core/constants/app_strings.dart';
import 'package:task_scheduler/core/theme/app_theme.dart';
import 'package:task_scheduler/features/auth/models/user_model.dart';
import 'package:task_scheduler/features/auth/services/auth_service.dart';

class AuthViewModel extends GetxController {
  final AuthService _authService;

  AuthViewModel({AuthService? authService})
    : _authService = authService ?? AuthService();

  // Reactive State Properties
  final RxBool isInitializing = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final RxBool hasSeenOnboarding = false.obs;

  // Form Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Global Keys for Form Validation
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  StreamSubscription<UserModel?>? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    // Initialize current user
    currentUser.value = _authService.currentUser;

    // Listen to Firebase Auth state stream reactively
    _authSubscription = _authService.authStateChanges.listen((user) {
      currentUser.value = user;
    });

    // Startup flash screen delay while app connects to Firebase/Firestore
    Future.delayed(const Duration(milliseconds: 1400), () {
      isInitializing.value = false;
    });
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Toggles password visibility in input fields
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // Complete onboarding flow
  void completeOnboarding() {
    hasSeenOnboarding.value = true;
  }

  // Clear text controllers
  void clearForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    obscurePassword.value = true;
  }

  // Input Field Validators
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.enterName;
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.enterEmail;
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return AppStrings.enterValidEmail;
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.enterPassword;
    }
    if (value.length < 6) {
      return AppStrings.passwordLength;
    }
    return null;
  }

  // Sign in with Email & Password
  Future<bool> signInWithEmail() async {
    if (!loginFormKey.currentState!.validate()) return false;

    try {
      isLoading.value = true;
      final user = await _authService.signInWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (user != null) {
        clearForm();
        showSuccessSnackbar(AppStrings.loginSuccess);
        return true;
      }
      return false;
    } catch (e) {
      showErrorSnackbar(_cleanErrorMessage(e));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Sign up with Name, Email & Password
  Future<bool> signUpWithEmail() async {
    if (!signupFormKey.currentState!.validate()) return false;

    try {
      isLoading.value = true;
      final user = await _authService.signUpWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text,
        displayName: nameController.text.trim(),
      );

      if (user != null) {
        clearForm();
        showSuccessSnackbar(AppStrings.signupSuccess);
        return true;
      }
      return false;
    } catch (e) {
      showErrorSnackbar(_cleanErrorMessage(e));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        showSuccessSnackbar(AppStrings.loginSuccess);
        return true;
      }
      // User cancelled
      return false;
    } catch (e) {
      showErrorSnackbar(_cleanErrorMessage(e));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Sign in with Facebook
  Future<bool> signInWithFacebook() async {
    try {
      isLoading.value = true;
      final user = await _authService.signInWithFacebook();
      if (user != null) {
        showSuccessSnackbar(AppStrings.loginSuccess);
        return true;
      }
      // User cancelled
      return false;
    } catch (e) {
      showErrorSnackbar(_cleanErrorMessage(e));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Sign in with Apple
  Future<bool> signInWithApple() async {
    try {
      isLoading.value = true;
      final user = await _authService.signInWithApple();
      if (user != null) {
        showSuccessSnackbar(AppStrings.loginSuccess);
        return true;
      }
      // User cancelled
      return false;
    } catch (e) {
      showErrorSnackbar(_cleanErrorMessage(e));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _authService.signOut();
      clearForm();
      showSuccessSnackbar(AppStrings.signoutSuccess);
    } catch (e) {
      showErrorSnackbar(_cleanErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  // Snackbar helpers
  void showErrorSnackbar(String message) {
    if (Get.isSnackbarOpen) return;
    Get.snackbar(
      AppStrings.error,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.errorColor.withValues(alpha: 0.95),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: AppTheme.borderRadius,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
      shouldIconPulse: true,
    );
  }

  void showSuccessSnackbar(String message) {
    if (Get.isSnackbarOpen) return;
    Get.snackbar(
      AppStrings.success,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.successColor.withValues(alpha: 0.95),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: AppTheme.borderRadius,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
      shouldIconPulse: false,
    );
  }

  String _cleanErrorMessage(dynamic error) {
    if (error == null) {
      return AppStrings.defaultError;
    }

    // Always log the technical error internally for developer inspection
    developer.log('Auth error caught in AuthViewModel: $error');

    String message = error.toString().trim();
    if (message.startsWith('Exception: ')) {
      message = message.replaceFirst('Exception: ', '').trim();
    }

    final lower = message.toLowerCase();

    // Check for technical signatures (classes, libraries, stack fragments)
    final bool isTechnical = lower.contains('platformexception') ||
        lower.contains('firebaseauth') ||
        lower.contains('firebaseexception') ||
        lower.contains('apiexception') ||
        lower.contains('formatexception') ||
        lower.contains('nullcheckoperator') ||
        lower.contains('nosuchmethoderror') ||
        lower.contains('typeerror') ||
        lower.contains('stacktrace') ||
        lower.contains('httpstatus') ||
        lower.contains('status code') ||
        lower.contains('internal error') ||
        lower.contains('com.google') ||
        lower.contains('io.flutter') ||
        lower.contains('errno');

    if (isTechnical) {
      if (lower.contains('network') ||
          lower.contains('socket') ||
          lower.contains('connection') ||
          lower.contains('timeout') ||
          lower.contains('offline')) {
        return 'Network connection issue. Please check your internet connection and try again.';
      }
      if (lower.contains('password')) {
        return 'Incorrect password. Please verify and try again.';
      }
      if (lower.contains('email') || lower.contains('user-not-found')) {
        return 'Incorrect email or password. Please try again.';
      }
      return 'Authentication could not be completed. Please try again.';
    }

    // Map common raw Firebase error codes if they surfaced
    if (lower.contains('invalid-credential') ||
        lower.contains('invalid_login_credentials') ||
        lower.contains('wrong-password') ||
        lower.contains('user-not-found')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (lower.contains('email-already-in-use')) {
      return 'An account already exists for that email address. Please log in.';
    }
    if (lower.contains('network-request-failed')) {
      return 'Network connection error. Please check your internet connection.';
    }
    if (lower.contains('too-many-requests')) {
      return 'Too many failed attempts. Please wait a moment before trying again.';
    }
    if (lower.contains('weak-password')) {
      return 'The password provided is too weak. Please use at least 6 characters.';
    }
    if (lower.contains('user-disabled')) {
      return 'This account has been disabled. Please contact support.';
    }

    // Ensure we do not display technical symbols or leaked JSON/code
    if (message.contains('{') || message.contains('}') || message.contains('[')) {
      return 'Authentication failed. Please verify your details and try again.';
    }

    // Clean human sentence check
    if (message.isNotEmpty && message.length <= 120) {
      return message;
    }

    return AppStrings.defaultError;
  }
}
