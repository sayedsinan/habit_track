import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class AiService {
  constructor(private configService: ConfigService) {}

  async generateChatResponse(message: string): Promise<any> {
    const apiKey = this.configService.get<string>('GEMINI_API_KEY');
    if (!apiKey || apiKey === 'your_gemini_api_key_here') {
       throw new InternalServerErrorException('Gemini API Key is missing or invalid.');
    }

    const systemPrompt = `You are a professional habit architect. Generate a habit plan in JSON format.
    Response MUST be valid JSON matching this structure:
    {
      "user_prompt": "the user's message",
      "suggested_achievements": [
        {
          "id": "unique_string",
          "title": "Achievement Title",
          "habits": [
            {
              "title": "Habit Name",
              "description": "Short description",
              "time_of_day": "Morning/Afternoon/Evening",
              "total_times": 1
            }
          ]
        }
      ]
    }`;

    try {
      const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${apiKey}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [
            { role: 'user', parts: [{ text: systemPrompt }] },
            { role: 'user', parts: [{ text: message }] }
          ]
        })
      });
      
      const data = await response.json();
      let text = data?.candidates?.[0]?.content?.parts?.[0]?.text || '{}';
      
      // Clean up markdown markers if present
      text = text.replace(/```json/g, '').replace(/```/g, '').trim();
      
      return JSON.parse(text);
    } catch (error) {
      console.error(error);
      throw new InternalServerErrorException('Failed to generate habits');
    }
  }
}
