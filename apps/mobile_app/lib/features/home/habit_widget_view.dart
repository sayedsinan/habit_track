import 'package:flutter/material.dart';
import 'package:habit_builder/core/theme/app_colors.dart';
import 'package:habit_builder/core/models/habit_model.dart';

class HabitWidgetView extends StatelessWidget {
  final Habit activeHabit;
  
  const HabitWidgetView({super.key, required this.activeHabit});

  Widget _buildHeatmap(AppColors color) {
    const columns = 22; 
    const rows = 5; 
    
    final actualCounts = [...activeHabit.pastDaysCompletion, activeHabit.completedTimes];
    
    final random = activeHabit.id.isNotEmpty ? activeHabit.id.hashCode : 42;
    int currentRandom = random;
    int nextRandom() {
      currentRandom = (currentRandom * 1103515245 + 12345) & 0x7fffffff;
      return currentRandom;
    }
    
    final int totalDays = columns * rows;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(columns, (colIndex) {
        return Column(
          children: List.generate(rows, (rowIndex) {
            final dayIndex = colIndex * rows + rowIndex;
            final daysAgo = totalDays - 1 - dayIndex;
            
            int count = 0;
            if (daysAgo < 7) {
              count = actualCounts[6 - daysAgo];
            } else {
              if ((nextRandom() % 100) > 60) {
                count = nextRandom() % (activeHabit.totalTimes + 1);
              }
            }
            
            final percentage = activeHabit.totalTimes > 0 ? (count / activeHabit.totalTimes).clamp(0.0, 1.0) : 0.0;
            
            Color squareColor;
            if (percentage == 0) {
              squareColor = color.borderColor.withOpacity(0.3);
            } else if (activeHabit.totalTimes == 1) {
              squareColor = color.accentColor;
            } else {
              squareColor = color.accentColor.withOpacity(0.2 + (0.8 * percentage));
            }
            
            return Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(bottom: 2, right: 2), 
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
    final isDoneToday = activeHabit.isCompleted;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        width: 320,
        height: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    activeHabit.title,
                    style: TextStyle(
                      color: color.primaryTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDoneToday ? color.accentColor : color.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDoneToday ? color.accentColor : color.borderColor),
                  ),
                  child: Text(
                    isDoneToday ? 'Complete' : '${activeHabit.timeOfDay}',
                    style: TextStyle(
                      color: isDoneToday ? color.backgroundColor : color.primaryTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'CONTRIBUTIONS',
              style: TextStyle(
                color: color.subtitleColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            _buildHeatmap(color),
          ],
        ),
      ),
    );
  }
}
