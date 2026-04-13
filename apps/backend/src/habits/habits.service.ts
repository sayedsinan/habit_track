import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { Habit } from './habit.entity';
import { HabitCompletion } from './habit-completion.entity';

@Injectable()
export class HabitsService {
  constructor(
    @InjectRepository(Habit)
    private habitsRepository: Repository<Habit>,
    @InjectRepository(HabitCompletion)
    private completionRepository: Repository<HabitCompletion>,
  ) {}

  private mapToJSON(habit: Habit, todayCompletion?: HabitCompletion, pastDays: number[] = []) {
    return {
      id: habit.id,
      title: habit.title,
      description: habit.description,
      total_times: habit.totalTimes,
      time_of_day: habit.timeOfDay,
      completed_times: todayCompletion ? todayCompletion.count : 0,
      past_days: pastDays,
    };
  }

  async findAll(userId: string): Promise<any[]> {
    const habits = await this.habitsRepository.find({
      where: { user: { id: userId } },
      relations: ['completions'],
    });

    const today = new Date().toISOString().split('T')[0];

    return habits.map((habit) => {
      const completions = habit.completions || [];
      const todayCompletion = completions.find((c) => c.date === today);

      const pastDays: number[] = [];
      for (let i = 6; i >= 1; i--) {
        const d = new Date();
        d.setDate(d.getDate() - i);
        const dateStr = d.toISOString().split('T')[0];
        const comp = completions.find((c) => c.date === dateStr);
        pastDays.push(comp ? comp.count : 0);
      }

      return this.mapToJSON(habit, todayCompletion, pastDays);
    });
  }

  async findOne(id: string, userId: string): Promise<any> {
    const habit = await this.habitsRepository.findOne({
      where: { id, user: { id: userId } },
      relations: ['completions'],
    });
    if (!habit) throw new NotFoundException('Habit not found');

    const today = new Date().toISOString().split('T')[0];
    const todayCompletion = habit.completions?.find((c) => c.date === today);

    return this.mapToJSON(habit, todayCompletion);
  }

  async toggleCompletion(
    habitId: string,
    userId: string,
    date: string,
  ): Promise<any> {
    const rawHabit = await this.habitsRepository.findOne({
      where: { id: habitId, user: { id: userId } },
    });
    if (!rawHabit) throw new NotFoundException('Habit not found');

    let completion = await this.completionRepository.findOne({
      where: { habit: { id: habitId }, date },
    });

    if (completion) {
      if (completion.count < rawHabit.totalTimes) {
        completion.count++;
      } else {
        completion.count = 0;
      }
      await this.completionRepository.save(completion);
    } else {
      completion = this.completionRepository.create({
        habit: { id: habitId },
        date,
        count: 1,
      });
      await this.completionRepository.save(completion);
    }
    return this.findOne(habitId, userId);
  }

  async create(habitData: Partial<Habit>, userId: string): Promise<any> {
    const habit = this.habitsRepository.create({
      ...habitData,
      user: { id: userId },
    });
    const saved = await this.habitsRepository.save(habit);
    return this.mapToJSON(saved);
  }

  async update(
    id: string,
    updateData: Partial<Habit>,
    userId: string,
  ): Promise<any> {
    const habit = await this.habitsRepository.findOne({
      where: { id, user: { id: userId } },
    });
    if (!habit) throw new NotFoundException('Habit not found');
    Object.assign(habit, updateData);
    const saved = await this.habitsRepository.save(habit);
    return this.findOne(id, userId);
  }

  async remove(id: string, userId: string): Promise<void> {
    const habit = await this.habitsRepository.findOne({
      where: { id, user: { id: userId } },
    });
    if (!habit) throw new NotFoundException('Habit not found');
    await this.habitsRepository.remove(habit);
  }
}
