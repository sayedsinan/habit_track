import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habit_builder/core/theme/app_colors.dart';
import 'package:habit_builder/core/data/in_memory_store.dart';
import 'package:habit_builder/core/models/habit_model.dart';
import 'package:habit_builder/features/newHabit/new_habit.dart';
import 'package:habit_builder/features/habitDetails/habit_details_page.dart';

// ─────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────

// Removed old HabitItem since we use the Habit model from core.

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
  final Habit habit;

  const HabitTile({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HabitDetailsPage(habit: habit)),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: color.cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap: () {
                InMemoryStore().toggleHabit(habit.id);
              },
              child: _HabitCheckbox(
                totalTimes: habit.totalTimes,
                completedTimes: habit.completedTimes,
                isCompleted: habit.isCompleted,
              ),
            ),
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
                    habit.description,
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
                  habit.timeOfDay,
                  style: TextStyle(
                    color: color.primaryTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                _DotRow(
                  history: [...habit.pastDaysCompletion.map((c) => c >= habit.totalTimes), habit.isCompleted],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: _HabitCheckbox (private)
// ─────────────────────────────────────────────

class _HabitCheckbox extends StatelessWidget {
  final int totalTimes;
  final int completedTimes;
  final bool isCompleted;

  const _HabitCheckbox({
    required this.totalTimes,
    required this.completedTimes,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();

    // Animate target based on whether we just achieved full completion
    return Container(
          width: 26,
          height: 26,
          child: CustomPaint(
            painter: _SegmentedBorderPainter(
              totalTimes: totalTimes,
              completedTimes: completedTimes,
              isCompleted: isCompleted,
              completedColor: color.accentColor,
              incompleteColor: color.borderColor,
              bgColor: color.backgroundColor,
            ),
            child: Center(
              child: isCompleted
                  ? Icon(Icons.check, color: color.backgroundColor, size: 16)
                  : null,
            ),
          ),
        )
        .animate(target: isCompleted ? 1 : 0)
        .scaleXY(begin: 1.0, end: 1.25, duration: 150.ms, curve: Curves.easeOut)
        .then()
        .scaleXY(
          begin: 1.25,
          end: 1.0,
          duration: 150.ms,
          curve: Curves.bounceOut,
        );
  }
}

class _SegmentedBorderPainter extends CustomPainter {
  final int totalTimes;
  final int completedTimes;
  final bool isCompleted;
  final Color completedColor;
  final Color incompleteColor;
  final Color bgColor;

  _SegmentedBorderPainter({
    required this.totalTimes,
    required this.completedTimes,
    required this.isCompleted,
    required this.completedColor,
    required this.incompleteColor,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final borderRadius =
        size.width * 0.27; // equivalent to circular(7) on size 26
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // If fully completed, fill everything with the accent color
    if (isCompleted) {
      final fillPaint = Paint()
        ..color = completedColor
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rrect, fillPaint);
      return;
    }

    // Otherwise, draw segments around the rounded rect
    // CustomPainter drawing dashed borders on an RRect is complex manually,
    // so we can approximate a segmented circle / RRect with arc segments
    // if totalTimes > 1. For exactly 1 time, draw normal border.

    if (totalTimes <= 1) {
      final borderPaint = Paint()
        ..color = incompleteColor
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(rrect, borderPaint);
      return;
    }

    // For > 1 totalTimes, we will switch to a circular segmentation to make splitting mathematically pure and visually pleasing instead of a segmented RRect.
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 0.75; // - half stroke width

    // Draw background segments
    final strokePaint = Paint()
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double sweepAngle = (2 * math.pi) / totalTimes;
    // adding a small gap between pieces
    double gap = 0.25;
    double drawAngle = sweepAngle - gap;

    for (int i = 0; i < totalTimes; i++) {
      double startAngle = -math.pi / 2 + (i * sweepAngle) + (gap / 2);

      strokePaint.color = i < completedTimes ? completedColor : incompleteColor;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        drawAngle,
        false,
        strokePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SegmentedBorderPainter oldDelegate) {
    return oldDelegate.completedTimes != completedTimes ||
        oldDelegate.totalTimes != totalTimes ||
        oldDelegate.isCompleted != isCompleted;
  }
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: _DotRow (private)
// ─────────────────────────────────────────────

class _DotRow extends StatelessWidget {
  final List<bool> history;

  const _DotRow({required this.history});

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return Row(
      children: List.generate(history.length, (i) {
        final filled = history[i];
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

    return Scaffold(
      backgroundColor: color.backgroundColor,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: InMemoryStore(),
          builder: (context, child) {
            final store = InMemoryStore();
            final habits = store.allHabits;
            final progressPercent = (store.dailyProgress * 100).toInt();

            return Padding(
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
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NewHabitPage(),
                                ),
                              );
                            },
                            child: Icon(
                              Icons.add,
                              color: color.primaryTextColor,
                              size: 26,
                            ),
                          ),
                        ],
                      )
                      .animate()
                      .fade(duration: 400.ms)
                      .slideY(begin: -0.2, end: 0),

                  const SizedBox(height: 20),

                  // ── Stat Cards Row ──
                  Row(
                        children: [
                          StatCard(
                            label: 'COMPLETION',
                            value: '${progressPercent}%',
                          ),
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
                      )
                      .animate()
                      .fade(duration: 400.ms, delay: 100.ms)
                      .slideX(begin: 0.1, end: 0),

                  const SizedBox(height: 24),

                  // ── Section Header ──
                  SectionHeader(
                    title: 'ACTIVE INTENTIONS',
                    trailingText:
                        '${habits.where((h) => h.isCompleted).length} of ${habits.length}',
                  ).animate().fade(duration: 400.ms, delay: 200.ms),

                  const SizedBox(height: 12),

                  // ── Habit Tiles ──
                  ...habits.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: HabitTile(habit: entry.value)
                          .animate()
                          .fade(
                            duration: 400.ms,
                            delay: (300 + entry.key * 100).ms,
                          )
                          .slideY(begin: 0.1, end: 0),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── New Habit Button ──
                  NewHabitButton(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NewHabitPage()),
                      );
                    },
                  ).animate().fade(duration: 400.ms, delay: 600.ms),

                  const SizedBox(height: 20),

                  // ── Architect Tip Card ──
                  if (store.achievements.isNotEmpty)
                    ArchitectTipCard(
                          tip:
                              "AI Goal: **${store.achievements.first.title}**. "
                              "Keep pushing towards your ideal self with these new habits!",
                        )
                        .animate()
                        .fade(duration: 400.ms, delay: 700.ms)
                        .scaleXY(begin: 0.95, end: 1.0),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
