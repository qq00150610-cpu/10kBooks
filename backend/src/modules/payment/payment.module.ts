import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PaymentController } from './payment.controller';
import { PaymentService } from './payment.service';
import { Order, UserBalance, Withdrawal, AuthorEarning, Coupon, UserCoupon } from '../../entities/payment.entity';
import { User } from '../../entities/user.entity';
import { Book, Chapter } from '../../entities/book.entity';
import { BullModule } from '@nestjs/bull';

@Module({
  imports: [
    TypeOrmModule.forFeature([Order, UserBalance, Withdrawal, AuthorEarning, Coupon, UserCoupon, User, Book, Chapter]),
    BullModule.registerQueue({ name: 'payment' }),
  ],
  controllers: [PaymentController],
  providers: [PaymentService],
  exports: [PaymentService],
})
export class PaymentModule {}
