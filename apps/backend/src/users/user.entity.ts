import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, OneToMany } from 'typeorm';
import { Habit } from '../habits/habit.entity';

@Entity()
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  email: string;

  @Column()
  passwordHash: string;

  @OneToMany(() => Habit, (habit) => habit.user)
  habits: Habit[];

  @CreateDateColumn()
  createdAt: Date;
}
