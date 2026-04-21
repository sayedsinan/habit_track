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

  @Post('evaluate')
  async evaluate(@Request() req, @Body() body: { prompt: string; durationDays?: number }) {
    return this.goalsService.evaluateGoal(req.user.id, body.prompt, body.durationDays);
  }

  @Post()
  async create(@Request() req, @Body() body: { prompt: string; aiPlan: any; durationDays?: number }) {
    return this.goalsService.createGoal(req.user, body.prompt, body.aiPlan, body.durationDays);
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
