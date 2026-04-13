import { Entity, Column, PrimaryGeneratedColumn, ManyToOne, CreateDateColumn, Index } from 'typeorm';
import { Habit } from './habit.entity';

@Entity()
@Index(['habit', 'date'], { unique: true })
export class HabitCompletion {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => Habit, { onDelete: 'CASCADE' })
  habit: Habit;

  @Column()
  date: string; // YYYY-MM-DD

  @Column({ default: 0 })
  count: number;

  @CreateDateColumn()
  createdAt: Date;
}
