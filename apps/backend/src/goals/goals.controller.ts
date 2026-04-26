import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Request,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { GoalsService } from './goals.service';

@Controller('goals')
@UseGuards(JwtAuthGuard)
export class GoalsController {
  constructor(private readonly goalsService: GoalsService) {}

  @Post('clarify')
  async clarify(@Body() body: { prompt: string }) {
    return this.goalsService.getClarifyingQuestions(body.prompt);
  }

  @Post('evaluate')
  async evaluate(
    @Request() req,
    @Body()
    body: {
      prompt: string;
      durationDays?: number;
      answers?: Record<string, string>;
      previousPlan?: any;
      refinementPrompt?: string;
    },
  ) {
    return this.goalsService.evaluateGoal(
      req.user.id,
      body.prompt,
      body.durationDays,
      body.answers,
      body.previousPlan,
      body.refinementPrompt,
    );
  }

  @Post()
  async create(@Request() req, @Body() body: { prompt: string; aiPlan: any; durationDays?: number; category?: string }) {
    return this.goalsService.createGoal(req.user, body.prompt, body.aiPlan, body.durationDays, body.category);
  }

  @Get()
  async findAll(@Request() req) {
    return this.goalsService.getUserGoals(req.user.id);
  }

  @Patch('action-items/:id')
  async updateActionItem(
    @Param('id') id: string,
    @Body('isCompleted') isCompleted: boolean,
  ) {
    return this.goalsService.updateActionItem(id, isCompleted);
  }

  @Post('action-items/:id/generate-steps')
  async generateSteps(@Param('id') id: string) {
    return this.goalsService.generateAndSaveSteps(id);
  }

  @Patch('steps/:id')
  async toggleStep(
    @Param('id') id: string,
    @Body('isCompleted') isCompleted: boolean,
  ) {
    return this.goalsService.toggleStep(id, isCompleted);
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return this.goalsService.getGoalDetails(id);
  }
}
