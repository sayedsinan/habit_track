import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:habit_builder/data/app_data_store.dart';
import 'package:habit_builder/core/theme/app_colors.dart';
import 'package:habit_builder/core/api/api_service.dart';
import 'package:habit_builder/routes/app_shell.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final TextEditingController _promptController = TextEditingController();
  int _selectedDuration = 90;
  bool _isLoading = false;

  void _generateMission() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.mediumImpact();

    try {
      final evaluation = await ApiService.evaluateGoal(
        prompt,
        durationDays: _selectedDuration,
      );
      
      if (evaluation['feasibility'] == 'not possible') {
         throw Exception("This mission seems impossible. Try something more realistic!");
      }

      await ApiService.createGoal(
        prompt,
        evaluation,
        durationDays: _selectedDuration,
      );
      
      await AppDataStore().refreshData();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const AppShell(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(LucideIcons.rocket, color: theme.colorScheme.primary, size: 28),
              ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),
              
              const SizedBox(height: 32),
              
              Text(
                "Define your\nvision.",
                style: theme.textTheme.displayLarge?.copyWith(fontSize: 40),
              ).animate().fade().slideY(begin: 0.1),
              
              const SizedBox(height: 16),
              
              Text(
                "Describe what you want to achieve, and our Architect AI will construct a tailored roadmap for your success.",
                style: theme.textTheme.bodyMedium,
              ).animate().fade(delay: 200.ms).slideY(begin: 0.1),

              const SizedBox(height: 48),

              Container(
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: _promptController,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "e.g., I want to master high-performance engineering and build a portfolio of AI agents...",
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ).animate().fade(delay: 400.ms).slideX(begin: 0.05),

              const SizedBox(height: 40),

              _buildSectionTitle(context, "MISSION TIMELINE"),

              const SizedBox(height: 16),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [30, 90, 180, 365].map((days) {
                    final isSelected = _selectedDuration == days;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedDuration = days);
                        },
                        child: AnimatedContainer(
                          duration: 200.ms,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? theme.colorScheme.primary : theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? theme.colorScheme.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                          ),
                          child: Text(
                            "$days Days",
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ).animate().fade(delay: 600.ms).slideX(begin: 0.1),

              const SizedBox(height: 80),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _generateMission,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text("Initialize Mission"),
                          SizedBox(width: 8),
                          Icon(LucideIcons.arrowRight, size: 20),
                        ],
                      ),
              ).animate().fade(delay: 800.ms).scaleY(begin: 0.8),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
      ),
    );
  }
}
