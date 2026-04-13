import { Entity, Column, PrimaryGeneratedColumn, ManyToOne, CreateDateColumn, OneToMany } from 'typeorm';
import { User } from '../users/user.entity';
import { HabitCompletion } from './habit-completion.entity';

@Entity()
export class Habit {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  title: string;

  @Column()
  description: string;

  @Column({ default: 'Morning' })
  timeOfDay: string;

  @Column({ default: 1 })
  totalTimes: number;

  @OneToMany(() => HabitCompletion, (completion) => completion.habit)
  completions: HabitCompletion[];

  @ManyToOne(() => User, (user) => user.habits)
  user: User;

  @CreateDateColumn()
  createdAt: Date;
}
