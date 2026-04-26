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

  async planGoal(prompt: string, durationDays: number = 90, answers?: Record<string, string>, previousPlan?: any, refinementPrompt?: string): Promise<any> {
    if (this.configService.get<string>('MOCK_AI') === 'true') {
      this.logger.log('MOCK_AI is enabled, returning simulated planGoal response');
      return {
        feasibility: 'can be done',
        feasibility_reason: 'This is a simulated AI response indicating feasibility.',
        strategic_analysis: 'Simulated strategic analysis. Break down the goal into manageable chunks.',
        probability_ratio: 85,
        key_challenges: ['Time management', 'Consistency', 'Focus'],
        graph_data: [
          { label: 'Time Requirement', value: 80 },
          { label: 'Skill Needed', value: 50 },
          { label: 'Consistency', value: 90 },
          { label: 'Energy Cost', value: 70 }
        ],
        plan: {
          title: 'Epic Goal Journey',
          description: 'Simulated high-level strategy for achieving the goal.',
          milestones: [
            {
              title: 'Level 1: The Beginning',
              description: 'Establish a strong foundation.',
              weeks_from_start: 1,
              action_items: [
                {
                  title: 'Quest: Daily Consistency',
                  description: 'Complete your daily tasks.',
                  type: 'habit',
                  frequency: 'daily',
                  total_target: 7,
                },
              ],
            },
          ],
        },
      };
    }

    let userContext = `The user wants to achieve a major goal (e.g., starting a company, learning a complex skill) within ${durationDays} days.\nInitial Prompt: ${prompt}`;
    
    if (answers && Object.keys(answers).length > 0) {
      userContext += `\n\nUser provided the following additional context:\n`;
      for (const [q, a] of Object.entries(answers)) {
        userContext += `- Q: ${q}\n  A: ${a}\n`;
      }
    }

    if (previousPlan && refinementPrompt) {
      userContext += `\n\nThe user wants to REFINE their previous plan. 
      Previous Plan Title: ${previousPlan.plan?.title}
      Refinement Request: ${refinementPrompt}
      Please adjust the milestones and feasibility based on this new request.`;
    }

    const systemPrompt = `You are an elite strategic consultant and agentic planner. 
    ${userContext}
    
    STEP 1: Evaluate feasibility. 
    Options: "not possible", "low", "moderate", "can be done".
    If the goal is absolutely impossible (violates laws of physics or is too extreme for the timeframe), set feasibility to "not possible".
    
    STEP 2: Plan the roadmap.
    Break the ${durationDays} days into 4-8 logical phases/milestones.
    For each milestone, provide specific action items (tasks or recurring habits).
    
    CRITICAL: Distribute the milestones intelligently across the ${durationDays}-day period.
    Milestones should have a "weeks_from_start" field that logically maps to the progression.
    Max weeks_from_start is ${Math.ceil(durationDays / 7)}.
    
    GAMIFICATION REQUIREMENT:
    Write the roadmap in an engaging, game-like narrative. Treat the user as a player embarking on a grand quest. Each phase is a "Level" or "Boss Fight", and action items are "Quests" or "Missions" that yield XP. The tone should be motivating, epic, and highly engaging.
    
    IMPORTANT: You MUST return a JSON object matching this exact structure:
    {
      "feasibility": "low" | "moderate" | "can be done" | "not possible",
      "feasibility_reason": "Executive summary of the feasibility.",
      "strategic_analysis": "3-4 sentences on the high-level strategy required.",
      "probability_ratio": 75,
      "key_challenges": ["Challenge 1", "Challenge 2", "Challenge 3"],
      "graph_data": [
        {"label": "Time Requirement", "value": 80},
        {"label": "Skill Needed", "value": 60},
        {"label": "Consistency", "value": 90},
        {"label": "Financial Cost", "value": 30}
      ],
      "plan": {
        "title": "Optimized Goal Title (Epic sounding)",
        "description": "High-level strategy",
        "milestones": [
          {
            "title": "Milestone Title (e.g., Level 1: The Awakening)",
            "description": "What this phase achieves",
            "weeks_from_start": 2,
            "action_items": [
              {
                "title": "Action Title (e.g., Quest: Daily Grinding)",
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
    - Be realistic, elite, professional, yet gamified and epic.
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

  async generateClarifyingQuestions(prompt: string): Promise<{ questions: string[] }> {
    if (this.configService.get<string>('MOCK_AI') === 'true') {
      this.logger.log('MOCK_AI is enabled, returning simulated generateClarifyingQuestions response');
      return { 
        questions: [
          "How much time can you dedicate daily?",
          "What is your current skill level regarding this?",
          "What are your biggest potential roadblocks?"
        ] 
      };
    }

    const systemPrompt = `You are an elite strategic coach. The user wants to start a mission: "${prompt}".
    Generate 3 clarifying questions to better understand their situation, constraints, or specific goals.
    
    IMPORTANT: You MUST return a JSON object matching this exact structure:
    {
      "questions": ["Question 1", "Question 2", "Question 3"]
    }`;

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
        this.logger.warn(`Failed with ${modelName}: ${error.message}`);
        lastError = error;
        continue;
      }
    }

    throw new InternalServerErrorException('Failed to generate questions');
  }

  async generateChat(message: string): Promise<{ response: string }> {
    if (this.configService.get<string>('MOCK_AI') === 'true') {
      this.logger.log('MOCK_AI is enabled, returning simulated generateChat response');
      return { response: "This is a simulated response. Keep up the good work!" };
    }

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
    if (this.configService.get<string>('MOCK_AI') === 'true') {
      this.logger.log('MOCK_AI is enabled, returning simulated generateTaskDetails response');
      return {
        description: "Simulated detailed description for the task.",
        steps: ["Simulated Step 1", "Simulated Step 2", "Simulated Step 3"]
      };
    }

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
