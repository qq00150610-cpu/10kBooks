import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { BookController } from './book.controller';
import { BookService } from './book.service';
import { Book, Chapter, BookCategory, BookTag, BookCollection } from '../../entities/book.entity';
import { User } from '../../entities/user.entity';
import { Rating } from '../../entities/social.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Book, Chapter, BookCategory, BookTag, BookCollection, User, Rating])],
  controllers: [BookController],
  providers: [BookService],
  exports: [BookService],
})
export class BookModule {}
