import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_scheduler/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:task_scheduler/features/auth/views/login_view.dart';
import 'package:task_scheduler/features/flashcard/views/onboarding_view.dart';
import 'package:task_scheduler/features/splash/views/splash_view.dart';
import 'package:task_scheduler/features/tasks/views/home_view.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthViewModel authViewModel = Get.find<AuthViewModel>();

    return Obx(() {
      // 0. Startup Splash Screen while connecting to Firebase/Firestore
      if (authViewModel.isInitializing.value) {
        return const SplashView();
      }

      final user = authViewModel.currentUser.value;
      final hasSeenOnboarding = authViewModel.hasSeenOnboarding.value;

      // 1. If user is authenticated, route directly to Home
      if (user != null) {
        return const HomeView();
      }

      // 2. If onboarding has not been completed, show Flashcard Onboarding first
      if (!hasSeenOnboarding) {
        return OnboardingView(
          onCompleted: () => authViewModel.completeOnboarding(),
        );
      }

      // 3. Otherwise show Login screen
      return const LoginView();
    });
  }
}
