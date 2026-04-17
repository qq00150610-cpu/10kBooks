import 'package:json_annotation/json_annotation.dart';
import 'book.dart';

part 'author.g.dart';

@JsonSerializable()
class Author {
  final String id;
  final String penName;
  final String avatar;
  final String bio;
  final AuthorStats stats;
  final bool isVerified;
  final DateTime createdAt;

  Author({
    required this.id,
    required this.penName,
    required this.avatar,
    required this.bio,
    required this.stats,
    required this.isVerified,
    required this.createdAt,
  });

  factory Author.fromJson(Map<String, dynamic> json) => _$AuthorFromJson(json);
  Map<String, dynamic> toJson() => _$AuthorToJson(this);
}

@JsonSerializable()
class AuthorStats {
  final int totalBooks;
  final int totalWords;
  final int totalChapters;
  final int totalViews;
  final int totalSubscribers;
  final int totalLikes;
  final double rating;

  AuthorStats({
    required this.totalBooks,
    required this.totalWords,
    required this.totalChapters,
    required this.totalViews,
    required this.totalSubscribers,
    required this.totalLikes,
    required this.rating,
  });

  factory AuthorStats.fromJson(Map<String, dynamic> json) => _$AuthorStatsFromJson(json);
  Map<String, dynamic> toJson() => _$AuthorStatsToJson(this);

  String get totalWordsFormatted {
    if (totalWords >= 10000) {
      return '${(totalWords / 10000).toStringAsFixed(1)}万';
    }
    return totalWords.toString();
  }
}

@JsonSerializable()
class AuthorEarnings {
  final double totalEarnings;
  final double withdrawable;
  final double pending;
  final double totalWithdrawed;
  final List<EarningsRecord> records;
  final EarningsSummary summary;

  AuthorEarnings({
    required this.totalEarnings,
    required this.withdrawable,
    required this.pending,
    required this.totalWithdrawed,
    required this.records,
    required this.summary,
  });

  factory AuthorEarnings.fromJson(Map<String, dynamic> json) => _$AuthorEarningsFromJson(json);
  Map<String, dynamic> toJson() => _$AuthorEarningsToJson(this);
}

@JsonSerializable()
class EarningsRecord {
  final String id;
  final String type;
  final double amount;
  final String description;
  final DateTime createdAt;
  final EarningsStatus status;

  EarningsRecord({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
    required this.status,
  });

  factory EarningsRecord.fromJson(Map<String, dynamic> json) => _$EarningsRecordFromJson(json);
  Map<String, dynamic> toJson() => _$EarningsRecordToJson(this);
}

@JsonEnum()
enum EarningsStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('completed')
  completed,
  @JsonValue('rejected')
  rejected,
}

@JsonSerializable()
class EarningsSummary {
  final double today;
  final double thisWeek;
  final double thisMonth;
  final double thisYear;

  EarningsSummary({
    required this.today,
    required this.thisWeek,
    required this.thisMonth,
    required this.thisYear,
  });

  factory EarningsSummary.fromJson(Map<String, dynamic> json) => _$EarningsSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$EarningsSummaryToJson(this);
}

@JsonSerializable()
class BookStats {
  final String bookId;
  final String bookTitle;
  final int dailyViews;
  final int weeklyViews;
  final int monthlyViews;
  final int totalViews;
  final int dailySubscribers;
  final int weeklySubscribers;
  final int monthlySubscribers;
  final int totalSubscribers;
  final int dailyRevenue;
  final int weeklyRevenue;
  final int monthlyRevenue;
  final int totalRevenue;

  BookStats({
    required this.bookId,
    required this.bookTitle,
    required this.dailyViews,
    required this.weeklyViews,
    required this.monthlyViews,
    required this.totalViews,
    required this.dailySubscribers,
    required this.weeklySubscribers,
    required this.monthlySubscribers,
    required this.totalSubscribers,
    required this.dailyRevenue,
    required this.weeklyRevenue,
    required this.monthlyRevenue,
    required this.totalRevenue,
  });

  factory BookStats.fromJson(Map<String, dynamic> json) => _$BookStatsFromJson(json);
  Map<String, dynamic> toJson() => _$BookStatsToJson(this);
}

@JsonSerializable()
class ChapterStats {
  final String chapterId;
  final String chapterTitle;
  final int chapterNumber;
  final int views;
  final int likes;
  final int subscribers;
  final int revenue;

  ChapterStats({
    required this.chapterId,
    required this.chapterTitle,
    required this.chapterNumber,
    required this.views,
    required this.likes,
    required this.subscribers,
    required this.revenue,
  });

  factory ChapterStats.fromJson(Map<String, dynamic> json) => _$ChapterStatsFromJson(json);
  Map<String, dynamic> toJson() => _$ChapterStatsToJson(this);
}

@JsonSerializable()
class CreateBookRequest {
  final String title;
  final String description;
  final String categoryId;
  final List<String> tags;
  final bool isVip;

  CreateBookRequest({
    required this.title,
    required this.description,
    required this.categoryId,
    required this.tags,
    required this.isVip,
  });

  factory CreateBookRequest.fromJson(Map<String, dynamic> json) => _$CreateBookRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateBookRequestToJson(this);
}

@JsonSerializable()
class CreateChapterRequest {
  final String bookId;
  final String title;
  final String content;
  final bool isVip;
  final int? price;

  CreateChapterRequest({
    required this.bookId,
    required this.title,
    required this.content,
    required this.isVip,
    this.price,
  });

  factory CreateChapterRequest.fromJson(Map<String, dynamic> json) => _$CreateChapterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateChapterRequestToJson(this);
}
