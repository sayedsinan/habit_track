import {
  Column,
  Entity,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { ActionItem } from './action-item.entity';
import { Goal } from './goal.entity';

@Entity()
export class Milestone {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  title: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'timestamp', nullable: true })
  targetDate: Date;

  @Column()
  order: number;

  @Column({ default: false })
  isCompleted: boolean;

  @ManyToOne(() => Goal, (goal) => goal.milestones, { onDelete: 'CASCADE' })
  goal: Goal;

  @OneToMany(() => ActionItem, (actionItem) => actionItem.milestone, {
    cascade: true,
  })
  actionItems: ActionItem[];
}
