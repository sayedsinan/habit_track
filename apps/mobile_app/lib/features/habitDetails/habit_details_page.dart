import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habit_builder/core/theme/app_colors.dart';
import 'package:habit_builder/core/models/habit_model.dart';
import 'package:habit_builder/core/data/in_memory_store.dart';

class HabitDetailsPage extends StatefulWidget {
  final Habit habit;

  const HabitDetailsPage({super.key, required this.habit});

  @override
  State<HabitDetailsPage> createState() => _HabitDetailsPageState();
}

class _HabitDetailsPageState extends State<HabitDetailsPage> {
  void _listenableUpdate() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    InMemoryStore().addListener(_listenableUpdate);
  }

  @override
  void dispose() {
    InMemoryStore().removeListener(_listenableUpdate);
    super.dispose();
  }

  Widget _buildHeatmap(
    BuildContext context,
    Habit activeHabit,
    AppColors color,
  ) {
    const columns = 22; // Increased to add more data
    const rows = 5; // Reduced number of rows per column

    // Create fake extended history.
    // The last 7 days are actual data.
    final actualCounts = [
      ...activeHabit.pastDaysCompletion,
      activeHabit.completedTimes,
    ];

    // We'll generate past days deterministically based on habit id so it doesn't flicker
    final random = activeHabit.id.isNotEmpty ? activeHabit.id.hashCode : 42;
    // creating a simple LCG random for deterministic values
    int currentRandom = random;
    int nextRandom() {
      currentRandom = (currentRandom * 1103515245 + 12345) & 0x7fffffff;
      return currentRandom;
    }

    final int totalDays = columns * rows;

    return Row(
      mainAxisAlignment:
          MainAxisAlignment.start, // Removed horizontally stretched spacing
      children: List.generate(columns, (colIndex) {
        return Column(
          children: List.generate(rows, (rowIndex) {
            final dayIndex = colIndex * rows + rowIndex;
            final daysAgo = totalDays - 1 - dayIndex;

            int count = 0;
            if (daysAgo < 7) {
              count = actualCounts[6 - daysAgo];
            } else {
              // 30% chance to have some completions
              if ((nextRandom() % 100) > 60) {
                count = nextRandom() % (activeHabit.totalTimes + 1);
              }
            }

            final percentage = activeHabit.totalTimes > 0
                ? (count / activeHabit.totalTimes).clamp(0.0, 1.0)
                : 0.0;

            Color squareColor;
            if (percentage == 0) {
              squareColor = color.borderColor.withOpacity(0.3);
            } else if (activeHabit.totalTimes == 1) {
              squareColor = color.accentColor;
            } else {
              // Different opacities based on how complete it is
              squareColor = color.accentColor.withOpacity(
                0.2 + (0.8 * percentage),
              );
            }

            return Container(
              width: 15,
              height: 15,
              margin: const EdgeInsets.only(
                bottom: 4,
                right: 4,
              ), // Only 1px right margin to visually separate technically, but if they want 0 we can do 0.
              decoration: BoxDecoration(
                color: squareColor,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors();
    // Re-fetch the habit just in case the instances differ from store
    final activeHabit = InMemoryStore().allHabits.firstWhere(
      (h) => h.id == widget.habit.id,
      orElse: () => widget.habit,
    );

    final isDoneToday = activeHabit.isCompleted;

    return Scaffold(
      backgroundColor: color.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.cardColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: color.borderColor, width: 1),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: color.primaryTextColor,
                        size: 20,
                      ),
                    ),
                  ),
                  Text(
                    'Details',
                    style: TextStyle(
                      color: color.primaryTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 40), // Spacer for centering
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 10),

                  // TAGS
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.cardColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          activeHabit.timeOfDay.toUpperCase(),
                          style: TextStyle(
                            color: color.subtitleColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${activeHabit.totalTimes}x DAILY',
                          style: TextStyle(
                            color: color.accentColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fade(duration: 400.ms).slideX(begin: -0.1),

                  const SizedBox(height: 16),

                  // TITLE
                  Text(
                    activeHabit.title,
                    style: TextStyle(
                      color: color.primaryTextColor,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ).animate().fade(duration: 400.ms, delay: 100.ms),

                  const SizedBox(height: 8),

                  // DESC
                  Text(
                    activeHabit.description,
                    style: TextStyle(
                      color: color.subtitleColor,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ).animate().fade(duration: 400.ms, delay: 200.ms),

                  const SizedBox(height: 32),

                  // ACTION BUTTON (CURRENT DAY)
                  GestureDetector(
                        onTap: () {
                          InMemoryStore().toggleHabit(activeHabit.id);
                        },
                        child: Container(
                          width: double.infinity,
                          height: 64,
                          decoration: BoxDecoration(
                            color: isDoneToday
                                ? color.accentColor
                                : color.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDoneToday
                                  ? color.accentColor
                                  : color.borderColor,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isDoneToday
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: isDoneToday
                                    ? color.backgroundColor
                                    : color.subtitleColor,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                isDoneToday
                                    ? 'Completed for Today'
                                    : 'Mark ${activeHabit.completedTimes}/${activeHabit.totalTimes} Complete',
                                style: TextStyle(
                                  color: isDoneToday
                                      ? color.backgroundColor
                                      : color.primaryTextColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .animate(target: isDoneToday ? 1 : 0)
                      .scaleXY(begin: 1.0, end: 1.03, duration: 150.ms)
                      .then()
                      .scaleXY(begin: 1.03, end: 1.0, duration: 150.ms),

                  const SizedBox(height: 40),

                  // ANALYTICS ROW
                  Row(
                        children: [
                          Expanded(
                            child: _StatBox(
                              title: 'STREAK',
                              value: '14 Days',
                              icon: Icons.local_fire_department,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatBox(
                              title: 'COMPLETION',
                              value: '87%',
                              icon: Icons.trending_up,
                              color: color,
                            ),
                          ),
                        ],
                      )
                      .animate()
                      .fade(duration: 400.ms, delay: 300.ms)
                      .slideY(begin: 0.1),

                  const SizedBox(height: 32),

                  // WEEKLY GRAPH
                  Text(
                    'PAST ACTIVITY',
                    style: TextStyle(
                      color: color.subtitleColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ).animate().fade(duration: 400.ms, delay: 400.ms),

                  const SizedBox(height: 16),

                  Container(
                        height: 180,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: color.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: color.borderColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(7, (index) {
                            final historyCounts = [
                              ...activeHabit.pastDaysCompletion,
                              activeHabit.completedTimes,
                            ];
                            final count = historyCounts[index];
                            final percentage = activeHabit.totalTimes > 0
                                ? (count / activeHabit.totalTimes).clamp(
                                    0.0,
                                    1.0,
                                  )
                                : 0.0;
                            final isDayDone = percentage >= 1.0;

                            final heightFactor = percentage == 0
                                ? 0.05
                                : percentage;

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeOutBack,
                                  width: 28,
                                  height: 100 * heightFactor,
                                  decoration: BoxDecoration(
                                    color: percentage > 0
                                        ? color.accentColor.withOpacity(
                                            isDayDone ? 1.0 : percentage,
                                          )
                                        : color.borderColor.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  [
                                    'Mon',
                                    'Tue',
                                    'Wed',
                                    'Thu',
                                    'Fri',
                                    'Sat',
                                    'Sun',
                                  ][index],
                                  style: TextStyle(
                                    color: isDayDone
                                        ? color.primaryTextColor
                                        : color.subtitleColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      )
                      .animate()
                      .fade(duration: 400.ms, delay: 500.ms)
                      .slideY(begin: 0.1),

                  const SizedBox(height: 40),

                  // HEATMAP GRAPH
                  Text(
                    'CONTRIBUTIONS',
                    style: TextStyle(
                      color: color.subtitleColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ).animate().fade(duration: 400.ms, delay: 500.ms),

                  const SizedBox(height: 16),

                  Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: color.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: color.borderColor),
                        ),
                        child: _buildHeatmap(context, activeHabit, color),
                      )
                      .animate()
                      .fade(duration: 400.ms, delay: 600.ms)
                      .slideY(begin: 0.1),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final AppColors color;

  const _StatBox({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color.subtitleColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              Icon(icon, color: color.accentColor, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color.primaryTextColor,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
