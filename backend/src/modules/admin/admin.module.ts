import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';
import { User, AuthorApplication } from '../../entities/user.entity';
import { Book, Chapter, BookCategory } from '../../entities/book.entity';
import { Order, Withdrawal } from '../../entities/payment.entity';
import { ReviewTask, Report } from '../../entities/review.entity';
import { VipSubscription } from '../../entities/vip.entity';

@Module({
  imports: [TypeOrmModule.forFeature([User, AuthorApplication, Book, Chapter, BookCategory, Order, Withdrawal, ReviewTask, Report, VipSubscription])],
  controllers: [AdminController],
  providers: [AdminService],
  exports: [AdminService],
})
export class AdminModule {}
