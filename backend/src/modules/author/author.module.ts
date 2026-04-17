import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthorController } from './author.controller';
import { AuthorService } from './author.service';
import { AuthorEarning } from '../../entities/payment.entity';
import { User, AuthorApplication } from '../../entities/user.entity';
import { Book, Chapter } from '../../entities/book.entity';

@Module({
  imports: [TypeOrmModule.forFeature([User, AuthorApplication, Book, Chapter, AuthorEarning])],
  controllers: [AuthorController],
  providers: [AuthorService],
  exports: [AuthorService],
})
export class AuthorModule {}
