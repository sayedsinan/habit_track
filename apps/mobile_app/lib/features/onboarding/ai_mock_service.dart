import 'dart:convert';
import 'package:habit_builder/core/models/ai_response_model.dart';
import 'package:habit_builder/core/models/habit_model.dart';

class AiMockService {
  Future<AiResponse> generateHabits(String prompt) async {
    // Fake a network delay to show off our loading animations
    await Future.delayed(const Duration(seconds: 3));

    // Return dummy JSON decoded into our models
    final dummyJson = {
      "user_prompt": prompt,
      "suggested_achievements": [
        {
          "id": "achv_1",
          "title": _titleFromPrompt(prompt),
          "habits": [
            {
              "id": "habit_1",
              "title": "Drink 500ml Water",
              "description": "Hydrate immediately after waking up.",
              "time_of_day": "Morning",
              "total_times": 3,
              "completed_times": 0
            },
            {
              "id": "habit_2",
              "title": "15 min Meditation",
              "description": "Clear your mind before starting work.",
              "time_of_day": "Morning",
              "isCompleted": false
            },
            {
              "id": "habit_3",
              "title": "Write 3 Goals",
              "description": "Jot down three high-priority tasks.",
              "time_of_day": "Morning",
              "isCompleted": false
            }
          ]
        }
      ]
    };

    return AiResponse.fromJson(dummyJson);
  }

  String _titleFromPrompt(String prompt) {
    if (prompt.toLowerCase().contains("healthy") || prompt.toLowerCase().contains("health")) {
      return "Health Journey Master";
    }
    if (prompt.toLowerCase().contains("productive") || prompt.toLowerCase().contains("work")) {
      return "Peak Productivity";
    }
    return "Custom AI Blueprint";
  }
}
