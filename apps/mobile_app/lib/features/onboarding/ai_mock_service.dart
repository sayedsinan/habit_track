import 'package:habit_builder/core/models/ai_response_model.dart';
import 'package:habit_builder/core/api/api_service.dart';

class AiService {
  Future<AiResponse> generateHabits(String prompt) async {
    try {
      final json = await ApiService.generateHabits(prompt);
      return AiResponse.fromJson(json);
    } catch (e) {
      throw Exception('Failed to generate habits with AI: $e');
    }
  }
}
