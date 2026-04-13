import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { HabitsService } from './habits.service';
import { HabitsController } from './habits.controller';
import { Habit } from './habit.entity';
import { HabitCompletion } from './habit-completion.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Habit, HabitCompletion])],
  controllers: [HabitsController],
  providers: [HabitsService],
})
export class HabitsModule {}
