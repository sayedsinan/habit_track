import { Controller, Post, Body, UnauthorizedException, BadRequestException, HttpCode, HttpStatus } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  async register(@Body() body: any) {
    const { email, password, firstName, lastName } = body;
    if (!email || !password) {
      throw new BadRequestException('Email and password required');
    }
    return this.authService.register(email, password, firstName, lastName);
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() body: any) {
    const { email, password } = body;
    const user = await this.authService.validateUser(email, password);
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }
    return this.authService.login(user);
  }
}
