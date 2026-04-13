import 'package:habit_builder/core/models/habit_model.dart';

class AiAchievement {
  final String id;
  final String title;
  final List<Habit> habits;

  AiAchievement({
    required this.id,
    required this.title,
    required this.habits,
  });

  factory AiAchievement.fromJson(Map<String, dynamic> json) {
    return AiAchievement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      habits: (json['habits'] as List<dynamic>?)
              ?.map((h) => Habit.fromJson(h as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class AiResponse {
  final String userPrompt;
  final List<AiAchievement> suggestedAchievements;

  AiResponse({
    required this.userPrompt,
    required this.suggestedAchievements,
  });

  factory AiResponse.fromJson(Map<String, dynamic> json) {
    return AiResponse(
      userPrompt: json['user_prompt'] ?? '',
      suggestedAchievements: (json['suggested_achievements'] as List<dynamic>?)
              ?.map((a) => AiAchievement.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
