import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_builder/core/theme/app_colors.dart';
import 'package:habit_builder/features/newHabit/new_habit.dart';

// ─────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────

class HabitItem {
  final String title;
  final String subtitle;
  final String streak;
  final bool isCompleted;
  final int dotCount;

  const HabitItem({
    required this.title,
    required this.subtitle,
    required this.streak,
    this.isCompleted = false,
    this.dotCount = 3,
  });
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: StatCard
// ─────────────────────────────────────────────

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color.subtitleColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color.primaryTextColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 6), trailing!],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: HabitTile
// ─────────────────────────────────────────────

class HabitTile extends StatelessWidget {
  final HabitItem habit;

  const HabitTile({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: color.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Checkbox
          _HabitCheckbox(isCompleted: habit.isCompleted),
          const SizedBox(width: 14),
          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: TextStyle(
                    color: habit.isCompleted
                        ? color.subtitleColor
                        : color.primaryTextColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    decoration: habit.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: color.subtitleColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  habit.subtitle,
                  style: TextStyle(color: color.subtitleColor, fontSize: 12),
                ),
              ],
            ),
          ),
          // Streak + dots
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                habit.streak,
                style: TextStyle(
                  color: color.primaryTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              _DotRow(count: habit.dotCount, isCompleted: habit.isCompleted),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: _HabitCheckbox (private)
// ─────────────────────────────────────────────

class _HabitCheckbox extends StatelessWidget {
  final bool isCompleted;

  const _HabitCheckbox({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: isCompleted ? color.accentColor : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        border: isCompleted
            ? null
            : Border.all(color: color.borderColor, width: 1.5),
      ),
      child: isCompleted
          ? Icon(Icons.check, color: color.backgroundColor, size: 16)
          : null,
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: _DotRow (private)
// ─────────────────────────────────────────────

class _DotRow extends StatelessWidget {
  final int count;
  final bool isCompleted;

  const _DotRow({required this.count, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return Row(
      children: List.generate(count, (i) {
        final filled = isCompleted ? i < count : i < 1;
        return Container(
          margin: const EdgeInsets.only(left: 3),
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? color.accentColor : color.dotInactiveColor,
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: SectionHeader
// ─────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final String? trailingText;

  const SectionHeader({super.key, required this.title, this.trailingText});

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color.subtitleColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.3,
          ),
        ),
        if (trailingText != null)
          Text(
            trailingText!,
            style: TextStyle(color: color.subtitleColor, fontSize: 12),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: NewHabitButton
// ─────────────────────────────────────────────

class NewHabitButton extends StatelessWidget {
  final VoidCallback? onTap;

  const NewHabitButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: color.cardColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: color.primaryTextColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'New Habit',
              style: TextStyle(
                color: color.primaryTextColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: ArchitectTipCard
// ─────────────────────────────────────────────

class ArchitectTipCard extends StatelessWidget {
  final String tip;

  const ArchitectTipCard({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon area
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.tipIconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.psychology_outlined,
              color: color.subtitleColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Architect Tip',
                  style: TextStyle(
                    color: color.primaryTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: color.subtitleColor,
                      fontSize: 12.5,
                      height: 1.5,
                    ),
                    children: _buildTipSpans(tip, color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Compass icon
          Icon(Icons.architecture, color: color.subtitleColor, size: 28),
        ],
      ),
    );
  }

  List<TextSpan> _buildTipSpans(String text, AppColors color) {
    // Bold text between ** markers
    final List<TextSpan> spans = [];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int last = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > last) {
        spans.add(TextSpan(text: text.substring(last, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: TextStyle(
            color: color.primaryTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
      last = match.end;
    }
    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last)));
    }
    return spans;
  }
}

// ─────────────────────────────────────────────
// MAIN PAGE: HomePage
// ─────────────────────────────────────────────

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();

    final List<HabitItem> habits = const [
      HabitItem(
        title: 'Deep Work',
        subtitle: '90-minute focused session',
        streak: '14 days',
        isCompleted: false,
        dotCount: 3,
      ),
      HabitItem(
        title: 'Evening Reflection',
        subtitle: 'Reviewing daily wins',
        streak: '8 days',
        isCompleted: true,
        dotCount: 4,
      ),
      HabitItem(
        title: 'Digital Detox',
        subtitle: 'No screens after 9:00 PM',
        streak: '21 days',
        isCompleted: false,
        dotCount: 2,
      ),
    ];

    return Scaffold(
      backgroundColor: color.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [
              const SizedBox(height: 16),

              // ── App Bar Row ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color.cardColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_outline,
                          color: color.primaryTextColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Today',
                        style: TextStyle(
                          color: color.primaryTextColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.add, color: color.primaryTextColor, size: 26),
                ],
              ),

              const SizedBox(height: 20),

              // ── Stat Cards Row ──
              Row(
                children: [
                  StatCard(label: 'COMPLETION', value: '68%'),
                  const SizedBox(width: 12),
                  StatCard(
                    label: 'DAILY STREAK',
                    value: '14',
                    trailing: Icon(
                      Icons.bedtime,
                      color: color.accentColor,
                      size: 20,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Section Header ──
              SectionHeader(title: 'ACTIVE INTENTIONS', trailingText: '3 of 5'),

              const SizedBox(height: 12),

              // ── Habit Tiles ──
              ...habits.map(
                (habit) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: HabitTile(habit: habit),
                ),
              ),

              const SizedBox(height: 8),

              // ── New Habit Button ──
              NewHabitButton(
                onTap: () {
                  Get.to(NewHabitPage());
                },
              ),

              const SizedBox(height: 20),

              // ── Architect Tip Card ──
              ArchitectTipCard(
                tip:
                    "You're most consistent with **Deep Work** when started before 10:00 AM. "
                    'Consider scheduling a "Do Not Disturb" block on your calendar for tomorrow.',
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
