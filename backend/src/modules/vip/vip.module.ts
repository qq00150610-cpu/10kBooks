import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { VipController } from './vip.controller';
import { VipService } from './vip.service';
import { VipPackage, VipSubscription, VipPrivilege, VipBenefitLog } from '../../entities/vip.entity';
import { User } from '../../entities/user.entity';
import { BullModule } from '@nestjs/bull';

@Module({
  imports: [TypeOrmModule.forFeature([VipPackage, VipSubscription, VipPrivilege, VipBenefitLog, User]), BullModule.registerQueue({ name: 'vip' })],
  controllers: [VipController],
  providers: [VipService],
  exports: [VipService],
})
export class VipModule {}
