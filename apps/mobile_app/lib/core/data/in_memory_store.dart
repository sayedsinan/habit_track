import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:habit_builder/core/models/ai_response_model.dart';
import 'package:habit_builder/core/models/habit_model.dart';
import 'package:home_widget/home_widget.dart';
import 'package:habit_builder/features/home/habit_widget_view.dart';

class InMemoryStore extends ChangeNotifier {
  // Singleton pattern
  static final InMemoryStore _instance = InMemoryStore._internal();
  factory InMemoryStore() => _instance;
  InMemoryStore._internal();

  // State
  List<AiAchievement> achievements = [];

  List<Habit> get allHabits {
    return achievements.expand((a) => a.habits).toList();
  }

  void loadAiResponse(AiResponse response) {
    achievements = response.suggestedAchievements;
    _updateNativeWidget();
    notifyListeners();
  }

  void toggleHabit(String id) {
    for (var achievement in achievements) {
      for (var habit in achievement.habits) {
        if (habit.id == id) {
          if (habit.completedTimes < habit.totalTimes) {
            habit.completedTimes++;
          } else {
            habit.completedTimes = 0;
          }
          _updateNativeWidget();
          notifyListeners();
          return;
        }
      }
    }
  }

  void addHabit(Habit habit) {
    if (achievements.isEmpty) {
      achievements.add(AiAchievement(id: 'custom_1', title: 'My Goals', habits: []));
    }
    achievements.first.habits.add(habit);
    _updateNativeWidget();
    notifyListeners();
  }

  // Calculate overall progress based on total tasks completed vs total tasks
  double get dailyProgress {
    final habits = allHabits;
    if (habits.isEmpty) return 0.0;
    final completed = habits.where((h) => h.isCompleted).length;
    return completed / habits.length;
  }

  void _updateNativeWidget() async {
    // We send simple strings or primitive types to the native OS Home Screen Widgets
    final int percent = (dailyProgress * 100).toInt();
    HomeWidget.saveWidgetData<int>('progressPercent', percent);
    
    // We can also send the next habit title as a string
    final pending = allHabits.where((h) => !h.isCompleted).toList();
    if (pending.isNotEmpty) {
      HomeWidget.saveWidgetData<String>('nextHabit', pending.first.title);
    } else {
      HomeWidget.saveWidgetData<String>('nextHabit', "All done!");
    }

    final activeHabit = pending.isNotEmpty ? pending.first : (allHabits.isNotEmpty ? allHabits.first : null);
    if (activeHabit != null) {
      try {
        await HomeWidget.renderFlutterWidget(
          HabitWidgetView(activeHabit: activeHabit),
          logicalSize: const Size(320, 160),
          key: 'widgetImage',
        );
      } catch (e) {
        debugPrint("Failed to render widget image: $e");
      }
    }
    
    // Trigger OS Update for Dashboard Widget
    HomeWidget.updateWidget(
      iOSName: 'HabitWidget', 
      androidName: 'HabitWidgetProvider',
    );

    // Trigger OS Update for Minimal Widget
    HomeWidget.updateWidget(
      iOSName: 'HabitWidget', 
      androidName: 'MinimalWidgetProvider',
    );
  }
}
