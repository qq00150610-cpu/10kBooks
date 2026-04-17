// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Book _$BookFromJson(Map<String, dynamic> json) => Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      cover: json['cover'] as String,
      description: json['description'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      wordCount: (json['wordCount'] as num).toInt(),
      chapterCount: (json['chapterCount'] as num).toInt(),
      status: $enumDecode(_$BookStatusEnumMap, json['status']),
      isVip: json['isVip'] as bool,
      rating: (json['rating'] as num).toDouble(),
      viewCount: (json['viewCount'] as num).toInt(),
      subscribeCount: (json['subscribeCount'] as num).toInt(),
      commentCount: (json['commentCount'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      lastChapterId: json['lastChapterId'] as String?,
      lastChapterTitle: json['lastChapterTitle'] as String?,
      lastChapterAt: json['lastChapterAt'] == null
          ? null
          : DateTime.parse(json['lastChapterAt'] as String),
    );

Map<String, dynamic> _$BookToJson(Book instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'author': instance.author,
      'cover': instance.cover,
      'description': instance.description,
      'tags': instance.tags,
      'wordCount': instance.wordCount,
      'chapterCount': instance.chapterCount,
      'status': _$BookStatusEnumMap[instance.status]!,
      'isVip': instance.isVip,
      'rating': instance.rating,
      'viewCount': instance.viewCount,
      'subscribeCount': instance.subscribeCount,
      'commentCount': instance.commentCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'lastChapterId': instance.lastChapterId,
      'lastChapterTitle': instance.lastChapterTitle,
      'lastChapterAt': instance.lastChapterAt?.toIso8601String(),
    };

const _$BookStatusEnumMap = {
  BookStatus.ongoing: 'ongoing',
  BookStatus.completed: 'completed',
  BookStatus.suspended: 'suspended',
};

Chapter _$ChapterFromJson(Map<String, dynamic> json) => Chapter(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      number: (json['number'] as num).toInt(),
      title: json['title'] as String,
      wordCount: (json['wordCount'] as num).toInt(),
      isVip: json['isVip'] as bool,
      isLock: json['isLock'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ChapterToJson(Chapter instance) => <String, dynamic>{
      'id': instance.id,
      'bookId': instance.bookId,
      'number': instance.number,
      'title': instance.title,
      'wordCount': instance.wordCount,
      'isVip': instance.isVip,
      'isLock': instance.isLock,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

ChapterContent _$ChapterContentFromJson(Map<String, dynamic> json) =>
    ChapterContent(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      chapterId: json['chapterId'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ChapterContentToJson(ChapterContent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookId': instance.bookId,
      'chapterId': instance.chapterId,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
    };

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      bookCount: (json['bookCount'] as num).toInt(),
      sort: (json['sort'] as num).toInt(),
    );

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'bookCount': instance.bookCount,
      'sort': instance.sort,
    };

Banner _$BannerFromJson(Map<String, dynamic> json) => Banner(
      id: json['id'] as String,
      title: json['title'] as String,
      image: json['image'] as String,
      link: json['link'] as String?,
      bookId: json['bookId'] as String?,
      sort: (json['sort'] as num).toInt(),
      type: $enumDecode(_$BannerTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$BannerToJson(Banner instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'image': instance.image,
      'link': instance.link,
      'bookId': instance.bookId,
      'sort': instance.sort,
      'type': _$BannerTypeEnumMap[instance.type]!,
    };

const _$BannerTypeEnumMap = {
  BannerType.book: 'book',
  BannerType.activity: 'activity',
  BannerType.external: 'external',
};

ReadProgress _$ReadProgressFromJson(Map<String, dynamic> json) => ReadProgress(
      bookId: json['bookId'] as String,
      chapterId: json['chapterId'] as String,
      chapterNumber: (json['chapterNumber'] as num).toInt(),
      progress: (json['progress'] as num).toDouble(),
      position: (json['position'] as num).toInt(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ReadProgressToJson(ReadProgress instance) =>
    <String, dynamic>{
      'bookId': instance.bookId,
      'chapterId': instance.chapterId,
      'chapterNumber': instance.chapterNumber,
      'progress': instance.progress,
      'position': instance.position,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

Bookmark _$BookmarkFromJson(Map<String, dynamic> json) => Bookmark(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      chapterId: json['chapterId'] as String,
      position: (json['position'] as num).toInt(),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$BookmarkToJson(Bookmark instance) => <String, dynamic>{
      'id': instance.id,
      'bookId': instance.bookId,
      'chapterId': instance.chapterId,
      'position': instance.position,
      'note': instance.note,
      'createdAt': instance.createdAt.toIso8601String(),
    };

Note _$NoteFromJson(Map<String, dynamic> json) => Note(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      chapterId: json['chapterId'] as String,
      content: json['content'] as String,
      reply: json['reply'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$NoteToJson(Note instance) => <String, dynamic>{
      'id': instance.id,
      'bookId': instance.bookId,
      'chapterId': instance.chapterId,
      'content': instance.content,
      'reply': instance.reply,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
