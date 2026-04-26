import {
  Injectable,
  NotFoundException,
  Logger,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AiService } from '../ai/ai.service';
import { User } from '../users/user.entity';
import { ActionItem } from './action-item.entity';
import { Goal } from './goal.entity';
import { Milestone } from './milestone.entity';
import { TaskStep } from './task-step.entity';

@Injectable()
export class GoalsService {
  private readonly logger = new Logger(GoalsService.name);
  constructor(
    @InjectRepository(Goal)
    private goalRepository: Repository<Goal>,
    @InjectRepository(Milestone)
    private milestoneRepository: Repository<Milestone>,
    @InjectRepository(ActionItem)
    private actionItemRepository: Repository<ActionItem>,
    @InjectRepository(TaskStep)
    private taskStepRepository: Repository<TaskStep>,
    private aiService: AiService,
  ) {}

  async getClarifyingQuestions(prompt: string) {
    this.logger.log(`Generating clarifying questions for prompt: ${prompt}`);
    return this.aiService.generateClarifyingQuestions(prompt);
  }

  async evaluateGoal(
    userId: string,
    prompt: string,
    durationDays: number = 90,
    answers?: Record<string, string>,
    previousPlan?: any,
    refinementPrompt?: string,
  ) {
    this.logger.log(
      `Evaluating goal for user ${userId} (${durationDays} days): ${prompt.substring(0, 50)}...`,
    );
    const aiResponse = await this.aiService.planGoal(prompt, durationDays, answers, previousPlan, refinementPrompt);

    if (aiResponse.feasibility === 'not possible') {
      return {
        feasibility: aiResponse.feasibility,
        reason: aiResponse.feasibility_reason,
        probability_ratio: aiResponse.probability_ratio || 0,
        plan: null,
      };
    }

    return aiResponse;
  }

  async createGoal(
    user: User,
    prompt: string,
    aiPlan: any,
    durationDays: number = 90,
    category: string = 'other',
  ) {
    if (!aiPlan || !aiPlan.plan) {
      this.logger.error(
        `Invalid Plan Data received: ${JSON.stringify(aiPlan)}`,
      );
      throw new BadRequestException(
        'The AI was unable to generate a valid roadmap for this mission.',
      );
    }

    this.logger.log(
      `Creating goal for user ${user.id}: ${aiPlan.plan.title} (${durationDays} days)`,
    );
    const goal = this.goalRepository.create({
      user,
      title: aiPlan.plan.title,
      description: aiPlan.plan.description,
      prompt,
      category,
      feasibility: aiPlan.feasibility || 'moderate',
      durationDays: durationDays,
      startDate: new Date(),
      targetDate: new Date(Date.now() + durationDays * 24 * 60 * 60 * 1000),
      status: 'active',
    });

    const savedGoal = await this.goalRepository.save(goal);
    this.logger.log(
      `Goal saved (ID: ${savedGoal.id}). Architecting ${aiPlan.plan.milestones.length} milestones...`,
    );

    for (const m of aiPlan.plan.milestones) {
      const milestone = this.milestoneRepository.create({
        goal: savedGoal,
        title: m.title,
        description: m.description,
        order: m.weeks_from_start,
        targetDate: new Date(
          Date.now() + m.weeks_from_start * 7 * 24 * 60 * 60 * 1000,
        ),
      });

      const savedMilestone = await this.milestoneRepository.save(milestone);
      this.logger.log(
        `Milestone Phase ${savedMilestone.order} created. Syncing action items...`,
      );

      for (const a of m.action_items) {
        const actionItem = this.actionItemRepository.create({
          milestone: savedMilestone,
          title: a.title,
          description: a.description,
          type: a.type,
          frequency: a.frequency,
          totalTarget: a.total_target,
        });
        await this.actionItemRepository.save(actionItem);
      }
    }

    return this.getGoalDetails(savedGoal.id);
  }

  async getGoalDetails(goalId: string) {
    return this.goalRepository.findOne({
      where: { id: goalId },
      relations: [
        'milestones',
        'milestones.actionItems',
        'milestones.actionItems.steps',
      ],
      order: {
        milestones: {
          order: 'ASC',
        },
      },
    });
  }

  async getUserGoals(userId: string) {
    return this.goalRepository.find({
      where: { user: { id: userId } },
      order: { createdAt: 'DESC' },
    });
  }

  async updateActionItem(actionItemId: string, isCompleted: boolean) {
    const actionItem = await this.actionItemRepository.findOneBy({
      id: actionItemId,
    });
    if (!actionItem) {
      this.logger.warn(`Action item not found: ${actionItemId}`);
      throw new NotFoundException('Action item not found');
    }

    this.logger.log(
      `Updating action item ${actionItemId}: isCompleted=${isCompleted}`,
    );
    actionItem.isCompleted = isCompleted;
    if (isCompleted && actionItem.type === 'habit') {
      actionItem.completedCount += 1;
    }
    return this.actionItemRepository.save(actionItem);
  }

  async generateAndSaveSteps(actionItemId: string) {
    const actionItem = await this.actionItemRepository.findOne({
      where: { id: actionItemId },
      relations: ['milestone', 'milestone.goal', 'steps'],
    });

    if (!actionItem) throw new NotFoundException('Action item not found');

    // If steps already exist and have content, don't regenerate (optional, but requested to reuse)
    if (actionItem.steps && actionItem.steps.length > 0) {
      return actionItem;
    }

    const context = `Goal: ${actionItem.milestone.goal.title}. Milestone: ${actionItem.milestone.title}. Task Type: ${actionItem.type}. Frequency: ${actionItem.frequency}`;
    const aiDetails = await this.aiService.generateTaskDetails(
      actionItem.title,
      context,
    );

    // Update description if it was empty
    if (!actionItem.description || actionItem.description === '') {
      actionItem.description = aiDetails.description;
      await this.actionItemRepository.save(actionItem);
    }

    // Save steps
    const steps = aiDetails.steps.map((text, index) => {
      const step = new TaskStep();
      step.text = text;
      step.order = index;
      step.actionItem = actionItem;
      return step;
    });

    await this.taskStepRepository.save(steps);

    return this.actionItemRepository.findOne({
      where: { id: actionItemId },
      relations: ['steps'],
    });
  }

  async toggleStep(stepId: string, isCompleted: boolean) {
    const step = await this.taskStepRepository.findOne({
      where: { id: stepId },
    });
    if (!step) throw new NotFoundException('Step not found');

    step.isCompleted = isCompleted;
    step.completedAt = isCompleted ? new Date() : undefined;
    return this.taskStepRepository.save(step);
  }
}
