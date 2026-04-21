import { Injectable, InternalServerErrorException, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GoogleGenAI } from '@google/genai';

@Injectable()
export class AiService {
  private readonly logger = new Logger(AiService.name);
  private client: GoogleGenAI;

  constructor(private configService: ConfigService) {
    const apiKey = this.configService.get<string>('GEMINI_API_KEY');
    if (!apiKey || apiKey === 'your_gemini_api_key_here') {
      this.logger.warn('GEMINI_API_KEY is not configured correctly in .env');
    }
    this.client = new GoogleGenAI({ apiKey });
  }

  async planGoal(prompt: string, durationDays: number = 90): Promise<any> {
    const systemPrompt = `You are an elite strategic consultant and agentic planner. 
    The user wants to achieve a major goal (e.g., starting a company, learning a complex skill) within ${durationDays} days.
    
    STEP 1: Evaluate feasibility. 
    Options: "not possible", "low", "moderate", "can be done".
    If the goal is absolutely impossible (violates laws of physics or is too extreme for the timeframe), set feasibility to "not possible".
    
    STEP 2: Plan the roadmap.
    Break the ${durationDays} days into 4-8 logical phases/milestones.
    For each milestone, provide specific action items (tasks or recurring habits).
    
    CRITICAL: Distribute the milestones intelligently across the ${durationDays}-day period.
    Milestones should have a "weeks_from_start" field that logically maps to the progression.
    Max weeks_from_start is ${Math.ceil(durationDays / 7)}.
    
    IMPORTANT: You MUST return a JSON object matching this exact structure:
    {
      "feasibility": "low" | "moderate" | "can be done" | "not possible",
      "feasibility_reason": "Executive summary of the feasibility.",
      "strategic_analysis": "3-4 sentences on the high-level strategy required.",
      "key_challenges": ["Challenge 1", "Challenge 2", "Challenge 3"],
      "plan": {
        "title": "Optimized Goal Title",
        "description": "High-level strategy",
        "milestones": [
          {
            "title": "Milestone Title",
            "description": "What this phase achieves",
            "weeks_from_start": 2,
            "action_items": [
              {
                "title": "Action Title",
                "description": "Specific instruction",
                "type": "task" | "habit",
                "frequency": "daily" | "weekly" | null,
                "total_target": 1
              }
            ]
          }
        ]
      }
    }
    
    Rules:
    - Root object MUST have all the above keys.
    - If feasibility is "not possible", strategic_analysis and plan can be simplified or null.
    - Be realistic, elite, and professional.
    - Action items should be actionable.`;

    const models = [
      'gemini-3.1-flash-lite-preview',
      'gemini-3.1-pro-preview',
      'gemini-2.0-flash', 
      'gemini-1.5-flash', 
      'gemini-flash-latest'
    ];
    let lastError: Error = new Error('Unknown AI error');

    for (const modelName of models) {
      try {
        this.logger.log(`Attempting planning with ${modelName}...`);
        const result = await this.client.models.generateContent({
          model: modelName,
          contents: [
            { role: 'user', parts: [{ text: systemPrompt }] },
            { role: 'user', parts: [{ text: prompt }] }
          ],
          config: {
            responseMimeType: 'application/json'
          }
        });

        const responseText = result.text;
        if (!responseText) throw new Error('Empty response');
        
        const parsed = JSON.parse(responseText);
        this.logger.log(`AI Success with ${modelName}. Evaluation: ${parsed.feasibility}`);
        return parsed;

      } catch (error) {
        this.logger.warn(`Failed with ${modelName}: ${error.message}`);
        lastError = error;
        continue;
      }
    }

    this.logger.error(`AI Planning failed for all models: ${lastError.message}`);
    throw new InternalServerErrorException('Failed to generate plan after model exhaustion');
  }

  async generateChat(message: string): Promise<{ response: string }> {
    const systemPrompt = `You are the Mission AI Coach. 
    Help the user with their goals, habits, and strategy. 
    Be concise, encouraging, and highly professional.`;
    
    const models = [
      'gemini-3.1-flash-lite-preview',
      'gemini-3.1-pro-preview',
      'gemini-2.0-flash', 
      'gemini-1.5-flash', 
      'gemini-flash-latest'
    ];
    let lastError: Error = new Error('Unknown AI error');

    for (const modelName of models) {
      try {
        const result = await this.client.models.generateContent({
          model: modelName,
          contents: [
            { role: 'user', parts: [{ text: systemPrompt }] },
            { role: 'user', parts: [{ text: message }] }
          ]
        });

        const text = result.text || 'I am focused on your mission.';
        return { response: text };

      } catch (error) {
        this.logger.warn(`Chat failed with ${modelName}: ${error.message}`);
        lastError = error;
        continue;
      }
    }

    throw new InternalServerErrorException('Failed to generate chat after model exhaustion');
  }

  async generateTaskDetails(title: string, context: string): Promise<{ description: string, steps: string[] }> {
    const systemPrompt = `You are an expert coach and strategist. 
    The user is working on a task: "${title}". 
    The context is: "${context}".
    
    Generate a detailed description (2-3 sentences) and a logical list of 3-5 actionable steps to complete this specific task effectively.
    
    Return a JSON object:
    {
      "description": "Specific, helpful description.",
      "steps": ["Step 1...", "Step 2...", "Step 3..."]
    }`;

    const models = [
      'gemini-3.1-flash-lite-preview',
      'gemini-2.0-flash', 
      'gemini-1.5-flash'
    ];
    let lastError: Error = new Error('Unknown AI error');

    for (const modelName of models) {
      try {
        const result = await this.client.models.generateContent({
          model: modelName,
          contents: [
            { role: 'user', parts: [{ text: systemPrompt }] }
          ],
          config: {
            responseMimeType: 'application/json'
          }
        });

        const responseText = result.text;
        if (!responseText) throw new Error('Empty response');
        
        return JSON.parse(responseText);

      } catch (error) {
        this.logger.warn(`Task details generation failed with ${modelName}: ${error.message}`);
        lastError = error;
        continue;
      }
    }

    throw new InternalServerErrorException('Failed to generate task details');
  }
}
