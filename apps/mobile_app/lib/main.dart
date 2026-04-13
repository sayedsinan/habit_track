import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_builder/core/theme/app_colors.dart';
import 'package:habit_builder/features/auth/auth_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
    final AppColors color = AppColors();
    return MaterialApp(
      title: 'Habit Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: color.backgroundColor,
        fontFamily: 'SF Pro Display', // falls back to system sans-serif
        colorScheme: ColorScheme.dark(
          primary: color.accentColor,
          surface: color.cardColor,
          background: color.backgroundColor,
        ),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      home: const AuthPage(),
    );
  }
}
