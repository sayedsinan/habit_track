import 'package:flutter/material.dart';
import 'package:habit_builder/core/theme/app_colors.dart';
import 'package:habit_builder/core/data/in_memory_store.dart';

class StatScreen extends StatefulWidget {
  const StatScreen({super.key});

  @override
  State<StatScreen> createState() => _StatScreenState();
}

class _StatScreenState extends State<StatScreen> {
  @override
  void initState() {
    super.initState();
    InMemoryStore().addListener(_update);
  }

  @override
  void dispose() {
    InMemoryStore().removeListener(_update);
    super.dispose();
  }

  void _update() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    final store = InMemoryStore();
    final habits = store.allHabits;

    final double completionRate = habits.isEmpty
        ? 0
        : (habits.where((h) => h.isCompleted).length / habits.length) * 100;
    final int totalSessions = habits.fold(
      0,
      (sum, h) => sum + h.completedTimes,
    );

    return Scaffold(
      backgroundColor: color.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              const SizedBox(height: 14),
              _DetailAppBar(title: 'Overall Stats'),
              const SizedBox(height: 14),
              _StreakHeroCard(
                streakDays: 0, // TODO: Implement real streak
                insight: habits.isEmpty
                    ? "Add your first habit to start tracking!"
                    : "You're consistently tracking ${habits.length} habits.",
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatMiniCard(
                    icon: Icons.calendar_month_outlined,
                    label: 'Consistency',
                    value: '${completionRate.toInt()}%',
                    sublabel: 'Completion rate today',
                  ),
                  const SizedBox(width: 12),
                  _StatMiniCard(
                    icon: Icons.check_circle_outline,
                    label: 'Sessions',
                    value: '$totalSessions',
                    sublabel: 'Total completions logged',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _WeekBarChart(
                title: 'Activity Level',
                subtitle: 'Total completions per day',
                data: List.generate(7, (index) {
                  int totalForDay = 0;
                  for (var h in habits) {
                    final hist = [...h.pastDaysCompletion, h.completedTimes];
                    totalForDay += hist[index];
                  }
                  double normalized = habits.isEmpty
                      ? 0
                      : totalForDay / (habits.length * 5); // arbitrary max
                  return _BarChartEntry(
                    label: [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun',
                    ][index],
                    value: normalized.clamp(0.0, 1.0),
                  );
                }),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailAppBar extends StatelessWidget {
  final String title;
  const _DetailAppBar({required this.title});
  @override
  Widget build(BuildContext context) {
    final color = AppColors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: color.primaryTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StreakHeroCard extends StatelessWidget {
  final int streakDays;
  final String insight;
  const _StreakHeroCard({required this.streakDays, required this.insight});
  @override
  Widget build(BuildContext context) {
    final color = AppColors();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: color.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'CURRENT STREAK',
            style: TextStyle(
              color: color.subtitleColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$streakDays days',
            style: TextStyle(
              color: color.primaryTextColor,
              fontSize: 40,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            insight,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color.subtitleColor,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatMiniCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sublabel;
  const _StatMiniCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sublabel,
  });
  @override
  Widget build(BuildContext context) {
    final color = AppColors();
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color.subtitleColor, size: 18),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color.primaryTextColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color.primaryTextColor,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              sublabel,
              style: TextStyle(color: color.subtitleColor, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarChartEntry {
  final String label;
  final double value;
  const _BarChartEntry({required this.label, required this.value});
}

class _WeekBarChart extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<_BarChartEntry> data;
  const _WeekBarChart({
    required this.title,
    required this.subtitle,
    required this.data,
  });
  @override
  Widget build(BuildContext context) {
    final color = AppColors();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color.primaryTextColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(color: color.subtitleColor, fontSize: 11),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 80,
            child: Row(
              children: data
                  .map(
                    (e) => Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: FractionallySizedBox(
                              heightFactor: e.value.clamp(0.1, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: e.value > 0.5
                                      ? color.accentColor
                                      : color.borderColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            e.label,
                            style: TextStyle(
                              color: color.subtitleColor,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
