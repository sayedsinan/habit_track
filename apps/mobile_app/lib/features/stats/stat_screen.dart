import 'package:flutter/material.dart';
import 'package:habit_builder/core/theme/app_colors.dart';

// ─────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────

class HabitDetailData {
  final String habitName;
  final int currentStreak;
  final String streakInsight;
  final double consistencyPercent;
  final String consistencyLabel;
  final int totalSessions;
  final String sessionsLabel;
  final String chartTitle;
  final String chartChangeText;
  final List<BarChartEntry> chartData;
  final String aiInsight;

  const HabitDetailData({
    required this.habitName,
    required this.currentStreak,
    required this.streakInsight,
    required this.consistencyPercent,
    required this.consistencyLabel,
    required this.totalSessions,
    required this.sessionsLabel,
    required this.chartTitle,
    required this.chartChangeText,
    required this.chartData,
    required this.aiInsight,
  });
}

class BarChartEntry {
  final String label;
  final double value; // 0.0 to 1.0 normalized

  const BarChartEntry({required this.label, required this.value});
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: DetailAppBar
// ─────────────────────────────────────────────

class DetailAppBar extends StatelessWidget {
  final String habitName;
  final VoidCallback? onSettingsTap;

  const DetailAppBar({
    super.key,
    required this.habitName,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_outline,
                color: color.primaryTextColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              habitName,
              style: TextStyle(
                color: color.primaryTextColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GestureDetector(
            onTap: onSettingsTap,
            child: Icon(Icons.settings_outlined,
                color: color.subtitleColor, size: 20),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: StreakHeroCard
// ─────────────────────────────────────────────

class StreakHeroCard extends StatelessWidget {
  final int streakDays;
  final String insight;

  const StreakHeroCard({
    super.key,
    required this.streakDays,
    required this.insight,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
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
          // Medal icon
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color.borderColor, width: 2),
                ),
                child: Icon(Icons.workspace_premium_outlined,
                    color: color.subtitleColor, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$streakDays',
                  style: TextStyle(
                    color: color.primaryTextColor,
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
                TextSpan(
                  text: ' days',
                  style: TextStyle(
                    color: color.primaryTextColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: StatMiniCard
// ─────────────────────────────────────────────

class StatMiniCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sublabel;

  const StatMiniCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
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
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: color.primaryTextColor,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sublabel,
              style: TextStyle(
                color: color.subtitleColor,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: WeekBarChart
// ─────────────────────────────────────────────

class WeekBarChart extends StatelessWidget {
  final String title;
  final String subtitle;
  final String changeText;
  final List<BarChartEntry> data;

  const WeekBarChart({
    super.key,
    required this.title,
    required this.subtitle,
    required this.changeText,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
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
                    style: TextStyle(
                      color: color.subtitleColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Text(
                changeText,
                style: TextStyle(
                  // color: color.,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Bars
          SizedBox(
            height: 72,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((entry) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: entry.value.clamp(0.08, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: entry.value > 0.6
                                    ? color.accentColor
                                    : color.borderColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          entry.label,
                          style: TextStyle(
                            color: color.subtitleColor,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: AiInsightCard
// ─────────────────────────────────────────────

class AiInsightCard extends StatelessWidget {
  final String insight;

  const AiInsightCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: color.subtitleColor, size: 16),
              const SizedBox(width: 8),
              Text(
                'AI INSIGHT',
                style: TextStyle(
                  color: color.subtitleColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"$insight"',
            style: TextStyle(
              color: color.primaryTextColor,
              fontSize: 13.5,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: PrimaryActionButton
// ─────────────────────────────────────────────

class PrimaryActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isOutlined;

  const PrimaryActionButton({
    super.key,
    required this.label,
    this.onTap,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: isOutlined ? Colors.transparent : color.primaryTextColor,
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isOutlined ? color.primaryTextColor : color.backgroundColor,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: BottomNavBar
// ─────────────────────────────────────────────

class HabitBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onTap;

  const HabitBottomNavBar({
    super.key,
    this.selectedIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    final items = [
      (Icons.today_outlined, 'Today'),
      (Icons.bar_chart_outlined, 'Stats'),
      (Icons.add_circle_outline, 'Add'),
      (Icons.auto_awesome_outlined, 'AI'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.cardColor,
        border: Border(top: BorderSide(color: color.borderColor, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final isSelected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onTap?.call(i),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  items[i].$1,
                  color: isSelected
                      ? color.primaryTextColor
                      : color.subtitleColor,
                  size: 22,
                ),
                const SizedBox(height: 3),
                Text(
                  items[i].$2,
                  style: TextStyle(
                    color: isSelected
                        ? color.primaryTextColor
                        : color.subtitleColor,
                    fontSize: 10,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MAIN PAGE: HabitDetailPage
// ─────────────────────────────────────────────

class StatScreen extends StatefulWidget {
  const StatScreen({super.key});

  @override
  State<StatScreen> createState() => _StatScreenState();
}

class _StatScreenState extends State<StatScreen> {
  int _navIndex = 0;

  final HabitDetailData _data = const HabitDetailData(
    habitName: 'Deep Work',
    currentStreak: 24,
    streakInsight:
        "You're in the top 5% of users maintaining\na deep work habit this month.",
    consistencyPercent: 92,
    consistencyLabel: 'Completion rate this month',
    totalSessions: 148,
    sessionsLabel: 'Total focus hours logged',
    chartTitle: 'Last 7 Days',
    chartChangeText: '+12%',
    chartData: [
      BarChartEntry(label: 'Mon', value: 0.55),
      BarChartEntry(label: 'Tue', value: 0.40),
      BarChartEntry(label: 'Wed', value: 0.70),
      BarChartEntry(label: 'Thu', value: 0.85),
      BarChartEntry(label: 'Fri', value: 0.65),
      BarChartEntry(label: 'Sat', value: 0.30),
      BarChartEntry(label: 'Sun', value: 0.90),
    ],
    aiInsight:
        'Your focus peaks between 9:00 AM and 11:30 AM. You are 40% more '
        'likely to complete this habit if started before noon. Consider moving '
        'your \'Deep Work\' block earlier on Tuesdays to maintain your streak.',
  );

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();

    return Scaffold(
      backgroundColor: color.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Scrollable Content ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  children: [
                    const SizedBox(height: 14),

                    // App Bar
                    DetailAppBar(habitName: _data.habitName),

                    const SizedBox(height: 14),

                    // Streak Hero
                    StreakHeroCard(
                      streakDays: _data.currentStreak,
                      insight: _data.streakInsight,
                    ),

                    const SizedBox(height: 12),

                    // Stats Row
                    Row(
                      children: [
                        StatMiniCard(
                          icon: Icons.calendar_month_outlined,
                          label: 'Consistency',
                          value: '${_data.consistencyPercent.toInt()}%',
                          sublabel: _data.consistencyLabel,
                        ),
                        const SizedBox(width: 12),
                        StatMiniCard(
                          icon: Icons.timer_outlined,
                          label: 'Sessions',
                          value: '${_data.totalSessions}',
                          sublabel: _data.sessionsLabel,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Bar Chart
                    WeekBarChart(
                      title: _data.chartTitle,
                      subtitle: 'Focus duration (minutes)',
                      changeText: _data.chartChangeText,
                      data: _data.chartData,
                    ),

                    const SizedBox(height: 12),

                    // AI Insight
                    AiInsightCard(insight: _data.aiInsight),

                    const SizedBox(height: 20),

                    // Complete for Today
                    PrimaryActionButton(
                      label: 'Complete for Today',
                      onTap: () {},
                    ),

                    const SizedBox(height: 12),

                    // Edit Habit (text button)
                    GestureDetector(
                      onTap: () {},
                      child: Center(
                        child: Text(
                          'Edit Habit',
                          style: TextStyle(
                            color: color.primaryTextColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Bottom Nav ──
           
          ],
        ),
      ),
    );
  }
}