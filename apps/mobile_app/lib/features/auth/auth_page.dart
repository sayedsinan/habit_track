import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habit_builder/core/theme/app_colors.dart';
import 'package:habit_builder/core/api/api_service.dart';
import 'package:habit_builder/core/data/in_memory_store.dart';
import 'package:habit_builder/features/onboarding/onboarding_page.dart';
import 'package:habit_builder/routes/app_shell.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    if (email.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      if (_isLogin) {
        await ApiService.login(email, password);
        await InMemoryStore().fetchHabits();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AppShell()),
          );
        }
      } else {
        await ApiService.register(email, password);
        await InMemoryStore().fetchHabits();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OnboardingPage()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors();

    return Scaffold(
      backgroundColor: color.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Habit Track',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color.accentColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fade(duration: 600.ms).slideY(begin: -0.2),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                style: TextStyle(color: color.primaryTextColor),
                decoration: InputDecoration(
                  hintText: "Email",
                  hintStyle: TextStyle(color: color.subtitleColor.withOpacity(0.5)),
                  filled: true,
                  fillColor: color.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ).animate().fade(duration: 400.ms, delay: 200.ms),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: color.primaryTextColor),
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: TextStyle(color: color.subtitleColor.withOpacity(0.5)),
                  filled: true,
                  fillColor: color.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ).animate().fade(duration: 400.ms, delay: 300.ms),
              const SizedBox(height: 32),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color.accentColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                          _isLogin ? 'Sign In' : 'Sign Up',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ).animate().fade().scaleXY(),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin ? "Don't have an account? Sign up" : "Already have an account? Sign in",
                  style: TextStyle(color: color.subtitleColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
