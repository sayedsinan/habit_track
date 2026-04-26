import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Brackets } from 'typeorm';
import { Friend } from './friend.entity';
import { UsersService } from '../users/users.service';

@Injectable()
export class FriendsService {
  constructor(
    @InjectRepository(Friend)
    private friendRepository: Repository<Friend>,
    private usersService: UsersService,
  ) {}

  async sendRequest(requesterId: string, recipientEmail: string) {
    if (!recipientEmail) throw new BadRequestException('Email is required');
    
    const recipient = await this.usersService.findByEmail(recipientEmail);
    if (!recipient) throw new NotFoundException('User not found');
    
    if (recipient.id === requesterId) {
      throw new BadRequestException('You cannot send a request to yourself');
    }

    const existing = await this.friendRepository.findOne({
      where: [
        { requester: { id: requesterId }, recipient: { id: recipient.id } },
        { requester: { id: recipient.id }, recipient: { id: requesterId } }
      ]
    });

    if (existing) {
      throw new BadRequestException('Friend request already exists or you are already friends');
    }

    const requester = await this.usersService.findById(requesterId);
    
    const friend = this.friendRepository.create({
      requester,
      recipient,
      status: 'pending',
    });

    return this.friendRepository.save(friend);
  }

  async acceptRequest(userId: string, requestId: string) {
    const request = await this.friendRepository.findOne({
      where: { id: requestId, recipient: { id: userId }, status: 'pending' },
    });

    if (!request) throw new NotFoundException('Request not found or not pending');

    request.status = 'accepted';
    return this.friendRepository.save(request);
  }

  async rejectRequest(userId: string, requestId: string) {
    const request = await this.friendRepository.findOne({
      where: { id: requestId, recipient: { id: userId }, status: 'pending' },
    });

    if (!request) throw new NotFoundException('Request not found or not pending');

    request.status = 'rejected';
    return this.friendRepository.save(request);
  }

  async getFriends(userId: string) {
    // Get all accepted friendships where user is either requester or recipient
    const friendships = await this.friendRepository.find({
      where: [
        { requester: { id: userId }, status: 'accepted' },
        { recipient: { id: userId }, status: 'accepted' }
      ],
      relations: ['requester', 'recipient']
    });

    return friendships.map(f => {
      const friend = f.requester.id === userId ? f.recipient : f.requester;
      return {
        id: friend.id,
        email: friend.email,
        firstName: friend.firstName,
        lastName: friend.lastName,
        friendshipId: f.id
      };
    });
  }

  async getPendingRequests(userId: string) {
    const requests = await this.friendRepository.find({
      where: { recipient: { id: userId }, status: 'pending' },
      relations: ['requester']
    });

    return requests.map(r => ({
      id: r.id,
      requesterId: r.requester.id,
      requesterEmail: r.requester.email,
      requesterFirstName: r.requester.firstName,
      requesterLastName: r.requester.lastName,
      createdAt: r.createdAt
    }));
  }

  async getLeaderboard(userId: string) {
    const friends = await this.getFriends(userId);
    const friendIds = friends.map(f => f.id);
    const userIds = [userId, ...friendIds];

    // Need to get goals for these users to compute score.
    // We can use query builder or fetch user goals.
    // For simplicity, let's fetch users with their goals and completed action items
    
    // We will do this via UsersService or directly using query builder if we inject Goal repository
    // But since we are in FriendsService, we can query users directly if we had a method or via raw queries.
    // Let's use a simpler approach: get users and their completed goals/tasks
    const users = await this.usersService['usersRepository'].find({
      where: userIds.map(id => ({ id })),
      relations: ['goals', 'goals.milestones', 'goals.milestones.actionItems']
    });

    const leaderboard = users.map(u => {
      let score = 0;
      let completedGoals = 0;
      const activeMissions: any[] = [];

      u.goals?.forEach(g => {
        if (g.status === 'completed') completedGoals++;

        let totalItems = 0;
        let completedItems = 0;

        g.milestones?.forEach(m => {
          m.actionItems?.forEach(a => {
            totalItems++;
            if (a.isCompleted) {
              score += 10;
              completedItems++;
            }
            if (a.type === 'habit') score += (a.completedCount * 2);
          });
        });

        if (g.status !== 'completed' && g.status !== 'archived') {
          activeMissions.push({
            id: g.id,
            title: g.title,
            progress: totalItems > 0 ? (completedItems / totalItems) : 0,
            durationDays: g.durationDays,
          });
        }
      });

      return {
        id: u.id,
        email: u.email,
        firstName: u.firstName,
        lastName: u.lastName,
        score,
        completedGoals,
        activeMissions,
      };
    });

    leaderboard.sort((a, b) => b.score - a.score);
    return leaderboard;
  }
}
