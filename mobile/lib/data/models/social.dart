import 'package:json_annotation/json_annotation.dart';
import 'book.dart';
import 'user.dart';

part 'social.g.dart';

@JsonSerializable()
class Post {
  final String id;
  final User author;
  final String content;
  final List<String> images;
  final Book? book;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool isLiked;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.author,
    required this.content,
    required this.images,
    this.book,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.isLiked,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()}年前';
    } else if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()}月前';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}天前';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}小时前';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}

@JsonSerializable()
class Comment {
  final String id;
  final User author;
  final String content;
  final int likeCount;
  final bool isLiked;
  final Comment? replyTo;
  final DateTime createdAt;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.author,
    required this.content,
    required this.likeCount,
    required this.isLiked,
    this.replyTo,
    required this.createdAt,
    this.replies = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()}年前';
    } else if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()}月前';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}天前';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}小时前';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}

@JsonSerializable()
class Circle {
  final String id;
  final String name;
  final String icon;
  final String description;
  final int memberCount;
  final int postCount;
  final bool isJoined;
  final DateTime createdAt;

  Circle({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.memberCount,
    required this.postCount,
    required this.isJoined,
    required this.createdAt,
  });

  factory Circle.fromJson(Map<String, dynamic> json) => _$CircleFromJson(json);
  Map<String, dynamic> toJson() => _$CircleToJson(this);
}

@JsonSerializable()
class FollowRelation {
  final String id;
  final User user;
  final DateTime createdAt;

  FollowRelation({
    required this.id,
    required this.user,
    required this.createdAt,
  });

  factory FollowRelation.fromJson(Map<String, dynamic> json) => _$FollowRelationFromJson(json);
  Map<String, dynamic> toJson() => _$FollowRelationToJson(this);
}
