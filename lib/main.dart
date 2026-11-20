import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:task_scheduler/core/constants/app_strings.dart';
import 'package:task_scheduler/core/services/network_service.dart';
import 'package:task_scheduler/core/theme/app_theme.dart';
import 'package:task_scheduler/features/auth/services/auth_service.dart';
import 'package:task_scheduler/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:task_scheduler/features/auth/views/auth_wrapper.dart';
import 'package:task_scheduler/features/tasks/services/task_service.dart';
import 'package:task_scheduler/features/tasks/viewmodels/task_viewmodel.dart';
import 'package:task_scheduler/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables safely
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    developer.log(
      'Notice: .env file not loaded or not found ($e). Using defaults.',
    );
  }

  // Initialize Firebase with cross-platform configuration
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    developer.log('Firebase initialization error: $e');
  }

  // Register Global Services & ViewModels (Strict MVVM DI via GetX)
  Get.put<NetworkService>(NetworkService(), permanent: true);
  final authService = Get.put<AuthService>(AuthService(), permanent: true);
  final authViewModel = Get.put<AuthViewModel>(
    AuthViewModel(authService: authService),
    permanent: true,
  );
  final taskService = Get.put<TaskService>(TaskService(), permanent: true);
  Get.put<TaskViewModel>(
    TaskViewModel(taskService: taskService, authViewModel: authViewModel),
    permanent: true,
  );

  runApp(const TaskSchedulerApp());
}

class TaskSchedulerApp extends StatelessWidget {
  const TaskSchedulerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthWrapper(),
    );
  }
}
