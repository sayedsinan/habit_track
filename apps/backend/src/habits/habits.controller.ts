import { Controller, Get, Post, Body, Param, Put, Delete, UseGuards, Request } from '@nestjs/common';
import { HabitsService } from './habits.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Habit } from './habit.entity';

@UseGuards(JwtAuthGuard)
@Controller('habits')
export class HabitsController {
  constructor(private readonly habitsService: HabitsService) {}

  @Get()
  findAll(@Request() req) {
    return this.habitsService.findAll(req.user.id);
  }

  @Get(':id')
  findOne(@Param('id') id: string, @Request() req) {
    return this.habitsService.findOne(id, req.user.id);
  }

  @Post()
  create(@Body() habitData: Partial<Habit>, @Request() req) {
    return this.habitsService.create(habitData, req.user.id);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() updateData: Partial<Habit>, @Request() req) {
    return this.habitsService.update(id, updateData, req.user.id);
  }

  @Post(':id/toggle')
  toggle(@Param('id') id: string, @Body('date') date: string, @Request() req) {
    const targetDate = date || new Date().toISOString().split('T')[0];
    return this.habitsService.toggleCompletion(id, req.user.id, targetDate);
  }

  @Delete(':id')
  remove(@Param('id') id: string, @Request() req) {
    return this.habitsService.remove(id, req.user.id);
  }
}
