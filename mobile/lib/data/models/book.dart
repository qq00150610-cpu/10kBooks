import 'package:json_annotation/json_annotation.dart';

part 'book.g.dart';

@JsonSerializable()
class Book {
  final String id;
  final String title;
  final String author;
  final String cover;
  final String description;
  final List<String> tags;
  final int wordCount;
  final int chapterCount;
  final BookStatus status;
  final bool isVip;
  final double rating;
  final int viewCount;
  final int subscribeCount;
  final int commentCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? categoryId;
  final String? categoryName;
  final String? lastChapterId;
  final String? lastChapterTitle;
  final DateTime? lastChapterAt;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.cover,
    required this.description,
    required this.tags,
    required this.wordCount,
    required this.chapterCount,
    required this.status,
    required this.isVip,
    required this.rating,
    required this.viewCount,
    required this.subscribeCount,
    required this.commentCount,
    required this.createdAt,
    required this.updatedAt,
    this.categoryId,
    this.categoryName,
    this.lastChapterId,
    this.lastChapterTitle,
    this.lastChapterAt,
  });

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);
  Map<String, dynamic> toJson() => _$BookToJson(this);

  String get wordCountFormatted {
    if (wordCount >= 10000) {
      return '${(wordCount / 10000).toStringAsFixed(1)}万字';
    }
    return '${wordCount}字';
  }

  String get statusText {
    switch (status) {
      case BookStatus.ongoing:
        return '连载中';
      case BookStatus.completed:
        return '已完结';
      case BookStatus.suspended:
        return '暂停更新';
    }
  }
}

@JsonEnum()
enum BookStatus {
  @JsonValue('ongoing')
  ongoing,
  @JsonValue('completed')
  completed,
  @JsonValue('suspended')
  suspended,
}

@JsonSerializable()
class Chapter {
  final String id;
  final String bookId;
  final int number;
  final String title;
  final int wordCount;
  final bool isVip;
  final bool isLock;
  final DateTime createdAt;
  final DateTime updatedAt;

  Chapter({
    required this.id,
    required this.bookId,
    required this.number,
    required this.title,
    required this.wordCount,
    required this.isVip,
    required this.isLock,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) => _$ChapterFromJson(json);
  Map<String, dynamic> toJson() => _$ChapterToJson(this);
}

@JsonSerializable()
class ChapterContent {
  final String id;
  final String bookId;
  final String chapterId;
  final String content;
  final DateTime createdAt;

  ChapterContent({
    required this.id,
    required this.bookId,
    required this.chapterId,
    required this.content,
    required this.createdAt,
  });

  factory ChapterContent.fromJson(Map<String, dynamic> json) => _$ChapterContentFromJson(json);
  Map<String, dynamic> toJson() => _$ChapterContentToJson(this);
}

@JsonSerializable()
class Category {
  final String id;
  final String name;
  final String icon;
  final int bookCount;
  final int sort;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.bookCount,
    required this.sort,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class Banner {
  final String id;
  final String title;
  final String image;
  final String? link;
  final String? bookId;
  final int sort;
  final BannerType type;

  Banner({
    required this.id,
    required this.title,
    required this.image,
    this.link,
    this.bookId,
    required this.sort,
    required this.type,
  });

  factory Banner.fromJson(Map<String, dynamic> json) => _$BannerFromJson(json);
  Map<String, dynamic> toJson() => _$BannerToJson(this);
}

@JsonEnum()
enum BannerType {
  @JsonValue('book')
  book,
  @JsonValue('activity')
  activity,
  @JsonValue('external')
  external,
}

@JsonSerializable()
class ReadProgress {
  final String bookId;
  final String chapterId;
  final int chapterNumber;
  final double progress;
  final int position;
  final DateTime updatedAt;

  ReadProgress({
    required this.bookId,
    required this.chapterId,
    required this.chapterNumber,
    required this.progress,
    required this.position,
    required this.updatedAt,
  });

  factory ReadProgress.fromJson(Map<String, dynamic> json) => _$ReadProgressFromJson(json);
  Map<String, dynamic> toJson() => _$ReadProgressToJson(this);
}

@JsonSerializable()
class Bookmark {
  final String id;
  final String bookId;
  final String chapterId;
  final int position;
  final String? note;
  final DateTime createdAt;

  Bookmark({
    required this.id,
    required this.bookId,
    required this.chapterId,
    required this.position,
    this.note,
    required this.createdAt,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) => _$BookmarkFromJson(json);
  Map<String, dynamic> toJson() => _$BookmarkToJson(this);
}

@JsonSerializable()
class Note {
  final String id;
  final String bookId;
  final String chapterId;
  final String content;
  final String? reply;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Note({
    required this.id,
    required this.bookId,
    required this.chapterId,
    required this.content,
    this.reply,
    required this.createdAt,
    this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
  Map<String, dynamic> toJson() => _$NoteToJson(this);
}
