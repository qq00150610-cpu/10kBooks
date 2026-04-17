import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SocialController } from './social.controller';
import { SocialService } from './social.service';
import { Follow, UserDynamic, Comment, Rating, Booklist, BooklistBook, CommentLike, DynamicLike } from '../../entities/social.entity';
import { User } from '../../entities/user.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Follow, UserDynamic, Comment, Rating, Booklist, BooklistBook, CommentLike, DynamicLike, User])],
  controllers: [SocialController],
  providers: [SocialService],
  exports: [SocialService],
})
export class SocialModule {}
