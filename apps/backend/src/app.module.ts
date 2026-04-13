import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { HabitsModule } from './habits/habits.module';
import { AiModule } from './ai/ai.module';
import { User } from './users/user.entity';
import { Habit } from './habits/habit.entity';
import { HabitCompletion } from './habits/habit-completion.entity';

@Module({
  imports: [
    ConfigModule.forRoot({
      envFilePath: '.env.public',
      isGlobal: true,
    }),
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT || '5432', 10) || 5432,
      username: process.env.DB_USER || 'postgres',
      password: process.env.DB_PASSWORD || 'postgres',
      database: process.env.DB_NAME || 'habit_track',
      entities: [User, Habit, HabitCompletion],
      synchronize: true, // Use only in development
    }),
    UsersModule,
    AuthModule,
    HabitsModule,
    AiModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
