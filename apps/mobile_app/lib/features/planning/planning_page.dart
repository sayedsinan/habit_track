import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_builder/core/api/api_service.dart';
import 'package:habit_builder/core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PlanningPage extends StatefulWidget {
  const PlanningPage({super.key});

  @override
  State<PlanningPage> createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage> {
  final _promptController = TextEditingController();
  bool _isEvaluating = false;
  Map<String, dynamic>? _aiResult;
  String? _error;

  Future<void> _evaluate() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _isEvaluating = true;
      _error = null;
      _aiResult = null;
    });
    HapticFeedback.mediumImpact();

    try {
      final result = await ApiService.evaluateGoal(prompt);
      setState(() {
        _aiResult = result;
      });
    } catch (e) {
      setState(() {
        _error = "Something went wrong. High traffic maybe?";
      });
    } finally {
      setState(() => _isEvaluating = false);
    }
  }

  Future<void> _startPlan() async {
    if (_aiResult == null) return;

    setState(() => _isEvaluating = true);
    try {
      await ApiService.createGoal(_promptController.text.trim(), _aiResult!);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _error = "Failed to finalize plan");
    } finally {
      setState(() => _isEvaluating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_aiResult == null) ...[
                    _buildInputState(context),
                  ] else ...[
                    _buildFeasibilityView(context),
                  ],
                  if (_error != null) _buildError(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _aiResult == null ? 'New Mission' : 'Strategic Analysis',
            style: theme.textTheme.titleLarge,
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(LucideIcons.x, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildInputState(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What do you want to achieve in the next 90 days?",
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _promptController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText:
                "e.g., Build a successful habit tracking app using Flutter and AI...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isEvaluating ? null : _evaluate,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isEvaluating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text("Analyze with AI"),
          ),
        ),
      ],
    );
  }

  Widget _buildFeasibilityView(BuildContext context) {
    final theme = Theme.of(context);
    final result = _aiResult!;
    final feasibility = result['feasibility'] ?? 'moderate';
    final reason = result['feasibility_reason'] ?? "";
    final analysis = result['strategic_analysis'] ?? "";
    final challenges = List<String>.from(result['key_challenges'] ?? []);
    final isPossible = feasibility != 'not possible';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatusBadge(context, feasibility),
        const SizedBox(height: 12),
        Text(reason, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
        const SizedBox(height: 32),
        if (analysis.isNotEmpty) ...[
          _buildSectionTitle(context, "Strategic Approach"),
          const SizedBox(height: 12),
          Text(
            analysis,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 32),
        ],
        if (challenges.isNotEmpty) ...[
          _buildSectionTitle(context, "Key Challenges"),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: challenges.map((c) => _buildChip(context, c)).toList(),
          ),
          const SizedBox(height: 32),
        ],
        if (isPossible)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isEvaluating ? null : _startPlan,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: _isEvaluating
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Initialize Roadmap"),
            ),
          )
        else
          TextButton(
            onPressed: () => setState(() => _aiResult = null),
            child: const Text("Try another mission prompt"),
          ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, String feasibility) {
    final theme = Theme.of(context);
    Color color;
    switch (feasibility) {
      case 'can be done':
        color = Colors.green;
        break;
      case 'moderate':
        color = Colors.orange;
        break;
      default:
        color = theme.colorScheme.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        feasibility.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String text) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Text(text, style: theme.textTheme.bodySmall),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        _error!,
        style: const TextStyle(color: Colors.redAccent, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }
}
