// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'author.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Author _$AuthorFromJson(Map<String, dynamic> json) => Author(
      id: json['id'] as String,
      penName: json['penName'] as String,
      avatar: json['avatar'] as String,
      bio: json['bio'] as String,
      stats: AuthorStats.fromJson(json['stats'] as Map<String, dynamic>),
      isVerified: json['isVerified'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AuthorToJson(Author instance) => <String, dynamic>{
      'id': instance.id,
      'penName': instance.penName,
      'avatar': instance.avatar,
      'bio': instance.bio,
      'stats': instance.stats.toJson(),
      'isVerified': instance.isVerified,
      'createdAt': instance.createdAt.toIso8601String(),
    };

AuthorStats _$AuthorStatsFromJson(Map<String, dynamic> json) => AuthorStats(
      totalBooks: (json['totalBooks'] as num).toInt(),
      totalWords: (json['totalWords'] as num).toInt(),
      totalChapters: (json['totalChapters'] as num).toInt(),
      totalViews: (json['totalViews'] as num).toInt(),
      totalSubscribers: (json['totalSubscribers'] as num).toInt(),
      totalLikes: (json['totalLikes'] as num).toInt(),
      rating: (json['rating'] as num).toDouble(),
    );

Map<String, dynamic> _$AuthorStatsToJson(AuthorStats instance) =>
    <String, dynamic>{
      'totalBooks': instance.totalBooks,
      'totalWords': instance.totalWords,
      'totalChapters': instance.totalChapters,
      'totalViews': instance.totalViews,
      'totalSubscribers': instance.totalSubscribers,
      'totalLikes': instance.totalLikes,
      'rating': instance.rating,
    };

AuthorEarnings _$AuthorEarningsFromJson(Map<String, dynamic> json) =>
    AuthorEarnings(
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      withdrawable: (json['withdrawable'] as num).toDouble(),
      pending: (json['pending'] as num).toDouble(),
      totalWithdrawed: (json['totalWithdrawed'] as num).toDouble(),
      records: (json['records'] as List<dynamic>)
          .map((e) => EarningsRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary:
          EarningsSummary.fromJson(json['summary'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthorEarningsToJson(AuthorEarnings instance) =>
    <String, dynamic>{
      'totalEarnings': instance.totalEarnings,
      'withdrawable': instance.withdrawable,
      'pending': instance.pending,
      'totalWithdrawed': instance.totalWithdrawed,
      'records': instance.records.map((e) => e.toJson()).toList(),
      'summary': instance.summary.toJson(),
    };

EarningsRecord _$EarningsRecordFromJson(Map<String, dynamic> json) =>
    EarningsRecord(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: $enumDecode(_$EarningsStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$EarningsRecordToJson(EarningsRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'amount': instance.amount,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'status': _$EarningsStatusEnumMap[instance.status]!,
    };

const _$EarningsStatusEnumMap = {
  EarningsStatus.pending: 'pending',
  EarningsStatus.completed: 'completed',
  EarningsStatus.rejected: 'rejected',
};

EarningsSummary _$EarningsSummaryFromJson(Map<String, dynamic> json) =>
    EarningsSummary(
      today: (json['today'] as num).toDouble(),
      thisWeek: (json['thisWeek'] as num).toDouble(),
      thisMonth: (json['thisMonth'] as num).toDouble(),
      thisYear: (json['thisYear'] as num).toDouble(),
    );

Map<String, dynamic> _$EarningsSummaryToJson(EarningsSummary instance) =>
    <String, dynamic>{
      'today': instance.today,
      'thisWeek': instance.thisWeek,
      'thisMonth': instance.thisMonth,
      'thisYear': instance.thisYear,
    };

BookStats _$BookStatsFromJson(Map<String, dynamic> json) => BookStats(
      bookId: json['bookId'] as String,
      bookTitle: json['bookTitle'] as String,
      dailyViews: (json['dailyViews'] as num).toInt(),
      weeklyViews: (json['weeklyViews'] as num).toInt(),
      monthlyViews: (json['monthlyViews'] as num).toInt(),
      totalViews: (json['totalViews'] as num).toInt(),
      dailySubscribers: (json['dailySubscribers'] as num).toInt(),
      weeklySubscribers: (json['weeklySubscribers'] as num).toInt(),
      monthlySubscribers: (json['monthlySubscribers'] as num).toInt(),
      totalSubscribers: (json['totalSubscribers'] as num).toInt(),
      dailyRevenue: (json['dailyRevenue'] as num).toInt(),
      weeklyRevenue: (json['weeklyRevenue'] as num).toInt(),
      monthlyRevenue: (json['monthlyRevenue'] as num).toInt(),
      totalRevenue: (json['totalRevenue'] as num).toInt(),
    );

Map<String, dynamic> _$BookStatsToJson(BookStats instance) =>
    <String, dynamic>{
      'bookId': instance.bookId,
      'bookTitle': instance.bookTitle,
      'dailyViews': instance.dailyViews,
      'weeklyViews': instance.weeklyViews,
      'monthlyViews': instance.monthlyViews,
      'totalViews': instance.totalViews,
      'dailySubscribers': instance.dailySubscribers,
      'weeklySubscribers': instance.weeklySubscribers,
      'monthlySubscribers': instance.monthlySubscribers,
      'totalSubscribers': instance.totalSubscribers,
      'dailyRevenue': instance.dailyRevenue,
      'weeklyRevenue': instance.weeklyRevenue,
      'monthlyRevenue': instance.monthlyRevenue,
      'totalRevenue': instance.totalRevenue,
    };

ChapterStats _$ChapterStatsFromJson(Map<String, dynamic> json) => ChapterStats(
      chapterId: json['chapterId'] as String,
      chapterTitle: json['chapterTitle'] as String,
      chapterNumber: (json['chapterNumber'] as num).toInt(),
      views: (json['views'] as num).toInt(),
      likes: (json['likes'] as num).toInt(),
      subscribers: (json['subscribers'] as num).toInt(),
      revenue: (json['revenue'] as num).toInt(),
    );

Map<String, dynamic> _$ChapterStatsToJson(ChapterStats instance) =>
    <String, dynamic>{
      'chapterId': instance.chapterId,
      'chapterTitle': instance.chapterTitle,
      'chapterNumber': instance.chapterNumber,
      'views': instance.views,
      'likes': instance.likes,
      'subscribers': instance.subscribers,
      'revenue': instance.revenue,
    };

CreateBookRequest _$CreateBookRequestFromJson(Map<String, dynamic> json) =>
    CreateBookRequest(
      title: json['title'] as String,
      description: json['description'] as String,
      categoryId: json['categoryId'] as String,
      tags:
          (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      isVip: json['isVip'] as bool,
    );

Map<String, dynamic> _$CreateBookRequestToJson(CreateBookRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'categoryId': instance.categoryId,
      'tags': instance.tags,
      'isVip': instance.isVip,
    };

CreateChapterRequest _$CreateChapterRequestFromJson(
        Map<String, dynamic> json) =>
    CreateChapterRequest(
      bookId: json['bookId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      isVip: json['isVip'] as bool,
      price: (json['price'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CreateChapterRequestToJson(
        CreateChapterRequest instance) =>
    <String, dynamic>{
      'bookId': instance.bookId,
      'title': instance.title,
      'content': instance.content,
      'isVip': instance.isVip,
      'price': instance.price,
    };
