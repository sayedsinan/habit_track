import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habit_builder/core/data/in_memory_store.dart';
import 'package:habit_builder/core/theme/app_colors.dart';
import 'package:habit_builder/features/onboarding/ai_mock_service.dart';
import 'package:habit_builder/routes/app_shell.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final TextEditingController _promptController = TextEditingController();
  final AiMockService _aiService = AiMockService();
  bool _isLoading = false;

  void _generateHabits() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.mediumImpact();

    final response = await _aiService.generateHabits(prompt);
    InMemoryStore().loadAiResponse(response);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AppShell(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                "What do you want to achieve?",
                style: TextStyle(
                  color: color.primaryTextColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ).animate().fade(duration: 600.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 16),
              Text(
                "Our AI will generate a custom plan tailored to your goals.",
                style: TextStyle(
                  color: color.subtitleColor,
                  fontSize: 16,
                ),
              )
                  .animate()
                  .fade(duration: 600.ms, delay: 200.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 48),
              TextField(
                controller: _promptController,
                style: TextStyle(color: color.primaryTextColor, fontSize: 18),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "e.g., I want to build a healthy morning routine...",
                  hintStyle: TextStyle(color: color.subtitleColor.withOpacity(0.5)),
                  filled: true,
                  fillColor: color.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(20),
                ),
              )
                  .animate()
                  .fade(duration: 600.ms, delay: 400.ms)
                  .slideY(begin: 0.2, end: 0),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _generateHabits,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color.accentColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Generate Plan",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              )
                  .animate()
                  .fade(duration: 600.ms, delay: 600.ms)
                  .scaleXY(begin: 0.9, end: 1.0),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
