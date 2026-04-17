// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
      id: json['id'] as String,
      author: User.fromJson(json['author'] as Map<String, dynamic>),
      content: json['content'] as String,
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      book: json['book'] == null
          ? null
          : Book.fromJson(json['book'] as Map<String, dynamic>),
      likeCount: (json['likeCount'] as num).toInt(),
      commentCount: (json['commentCount'] as num).toInt(),
      shareCount: (json['shareCount'] as num).toInt(),
      isLiked: json['isLiked'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'id': instance.id,
      'author': instance.author.toJson(),
      'content': instance.content,
      'images': instance.images,
      'book': instance.book?.toJson(),
      'likeCount': instance.likeCount,
      'commentCount': instance.commentCount,
      'shareCount': instance.shareCount,
      'isLiked': instance.isLiked,
      'createdAt': instance.createdAt.toIso8601String(),
    };

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      id: json['id'] as String,
      author: User.fromJson(json['author'] as Map<String, dynamic>),
      content: json['content'] as String,
      likeCount: (json['likeCount'] as num).toInt(),
      isLiked: json['isLiked'] as bool,
      replyTo: json['replyTo'] == null
          ? null
          : Comment.fromJson(json['replyTo'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'id': instance.id,
      'author': instance.author.toJson(),
      'content': instance.content,
      'likeCount': instance.likeCount,
      'isLiked': instance.isLiked,
      'replyTo': instance.replyTo?.toJson(),
      'createdAt': instance.createdAt.toIso8601String(),
      'replies': instance.replies.map((e) => e.toJson()).toList(),
    };

Circle _$CircleFromJson(Map<String, dynamic> json) => Circle(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      description: json['description'] as String,
      memberCount: (json['memberCount'] as num).toInt(),
      postCount: (json['postCount'] as num).toInt(),
      isJoined: json['isJoined'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$CircleToJson(Circle instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'description': instance.description,
      'memberCount': instance.memberCount,
      'postCount': instance.postCount,
      'isJoined': instance.isJoined,
      'createdAt': instance.createdAt.toIso8601String(),
    };

FollowRelation _$FollowRelationFromJson(Map<String, dynamic> json) =>
    FollowRelation(
      id: json['id'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$FollowRelationToJson(FollowRelation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user.toJson(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
