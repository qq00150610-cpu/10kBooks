import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy, VerifyCallback } from 'passport-google-oauth20';
import { ConfigService } from '@nestjs/config';
import { AuthService } from '../auth.service';

@Injectable()
export class GoogleStrategy extends PassportStrategy(Strategy, 'google') {
  constructor(
    private configService: ConfigService,
    private authService: AuthService,
  ) {
    super({
      clientID: configService.get('GOOGLE_CLIENT_ID'),
      clientSecret: configService.get('GOOGLE_CLIENT_SECRET'),
      callbackURL: '/api/v1/auth/social/google/callback',
      scope: ['email', 'profile'],
    });
  }

  async validate(
    accessToken: string,
    refreshToken: string,
    profile: any,
    done: VerifyCallback,
  ) {
    try {
      const { id, displayName, emails, photos } = profile;
      const email = emails?.[0]?.value;
      const avatar = photos?.[0]?.value;

      if (!email) {
        return done(new UnauthorizedException('无法获取邮箱信息'), null);
      }

      const result = await this.authService.validateSocialLogin('google', {
        id,
        email,
        name: displayName,
        avatar,
      });

      return done(null, result.user);
    } catch (error) {
      return done(error, null);
    }
  }
}
