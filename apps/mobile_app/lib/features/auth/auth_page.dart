import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habit_builder/core/theme/app_colors.dart';
import 'package:habit_builder/core/api/api_service.dart';
import 'package:habit_builder/data/app_data_store.dart';
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
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (email.isEmpty || password.isEmpty) return;
    if (!_isLogin && (firstName.isEmpty || lastName.isEmpty)) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      if (_isLogin) {
        await ApiService.login(email, password);
        await AppDataStore().refreshData();
        if (mounted) {
          final store = AppDataStore();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => store.activeGoal != null
                  ? const AppShell()
                  : const OnboardingPage(),
            ),
          );
        }
      } else {
        await ApiService.register(
          email,
          password,
          firstName: firstName,
          lastName: lastName,
        );
        await AppDataStore().refreshData();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OnboardingPage()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background decorative elements
          Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 1.seconds)
              .scale(begin: const Offset(0.5, 0.5)),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 28.0,
                vertical: 40.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  // Logo / Brand
                  Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            color: theme.colorScheme.primary,
                            size: 48,
                          ),
                        ),
                      )
                      .animate()
                      .fade(duration: 600.ms)
                      .scale(curve: Curves.elasticOut),

                  const SizedBox(height: 24),
                  Text(
                    'Habit Architect',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.2),

                  Text(
                    _isLogin
                        ? 'Welcome back, designer.'
                        : 'Build your future today.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ).animate().fade(delay: 400.ms).slideY(begin: 0.2),

                  const SizedBox(height: 60),

                  // Input Fields
                  if (!_isLogin) ...[
                    _buildInputField(
                      controller: _firstNameController,
                      hint: "First name",
                      icon: Icons.person_outline_rounded,
                    ).animate().fade(delay: 500.ms).slideX(begin: 0.1),
                    const SizedBox(height: 20),
                    _buildInputField(
                      controller: _lastNameController,
                      hint: "Last name",
                      icon: Icons.person_outline_rounded,
                    ).animate().fade(delay: 550.ms).slideX(begin: 0.1),
                    const SizedBox(height: 20),
                  ],

                  _buildInputField(
                    controller: _emailController,
                    hint: "Email address",
                    icon: Icons.email_outlined,
                  ).animate().fade(delay: 600.ms).slideX(begin: 0.1),

                  const SizedBox(height: 20),

                  _buildInputField(
                    controller: _passwordController,
                    hint: "Password",
                    icon: Icons.lock_outline_rounded,
                    obscure: true,
                  ).animate().fade(delay: 700.ms).slideX(begin: 0.1),

                  const SizedBox(height: 40),

                  // Action Button
                  GestureDetector(
                    onTap: _isLoading ? null : _submit,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isLogin ? 'Sign In' : 'Get Started',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ).animate().fade(delay: 900.ms).scaleY(begin: 0.8),

                  const SizedBox(height: 24),

                  // Toggle Login/Signup
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() => _isLogin = !_isLogin);
                    },
                    child: RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: _isLogin
                                ? "New here? "
                                : "Already a member? ",
                          ),
                          TextSpan(
                            text: _isLogin ? "Create account" : "Sign in",
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fade(delay: 1100.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          icon: Icon(
            icon,
            size: 20,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          hintText: hint,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
