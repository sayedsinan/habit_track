import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_builder/core/api/api_service.dart';
import 'package:habit_builder/core/theme/app_theme.dart';
import 'package:habit_builder/data/app_data_store.dart';
import 'package:habit_builder/features/auth/auth_page.dart';
import 'package:habit_builder/features/onboarding/onboarding_page.dart';
import 'package:habit_builder/routes/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize persistence and load token
  await ApiService.init();

  if (ApiService.isAuthenticated) {
    await AppDataStore().refreshData();
  }

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1E2229),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const HabitBuilderApp());
}

class HabitBuilderApp extends StatelessWidget {
  const HabitBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    Widget initialScreen;
    if (ApiService.isAuthenticated) {
      final store = AppDataStore();
      if (store.activeGoal != null) {
        initialScreen = const AppShell();
      } else {
        initialScreen = const OnboardingPage();
      }
    } else {
      initialScreen = const AuthPage();
    }

    return MaterialApp(
      title: 'Mission Control',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: initialScreen,
    );
  }
}
