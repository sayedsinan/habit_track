import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  CreateDateColumn,
} from 'typeorm';
import { ActionItem } from './action-item.entity';

@Entity()
export class TaskStep {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  text: string;

  @Column({ default: false })
  isCompleted: boolean;

  @Column({ nullable: true })
  completedAt?: Date;

  @Column({ default: 0 })
  order: number;

  @ManyToOne(() => ActionItem, (actionItem) => actionItem.steps, {
    onDelete: 'CASCADE',
    nullable: true,
  })
  actionItem: ActionItem;

  @CreateDateColumn()
  createdAt: Date;
}
