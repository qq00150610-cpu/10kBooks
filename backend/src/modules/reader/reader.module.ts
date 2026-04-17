import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ReaderController } from './reader.controller';
import { ReaderService } from './reader.service';
import { ReadingProgress, Bookmark, Note, ReadingHistory, ReadingSession, OfflineCache } from '../../entities/reader.entity';
import { Book, Chapter } from '../../entities/book.entity';

@Module({
  imports: [TypeOrmModule.forFeature([ReadingProgress, Bookmark, Note, ReadingHistory, ReadingSession, OfflineCache, Book, Chapter])],
  controllers: [ReaderController],
  providers: [ReaderService],
  exports: [ReaderService],
})
export class ReaderModule {}
