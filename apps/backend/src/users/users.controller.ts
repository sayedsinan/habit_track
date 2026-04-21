import { Body, Controller, Get, Patch, Request, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { UsersService } from './users.service';

@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  async getProfile(@Request() req) {
    const user = await this.usersService.findById(req.user.id);
    const { passwordHash, ...result } = user;
    return result;
  }

  @Patch('me')
  async updateProfile(@Request() req, @Body() body: any) {
    const user = await this.usersService.update(req.user.id, body);
    const { passwordHash, ...result } = user;
    return result;
  }
}
