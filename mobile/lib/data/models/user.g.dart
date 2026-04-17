// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      avatar: json['avatar'] as String,
      bio: json['bio'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      vipInfo: json['vipInfo'] == null
          ? null
          : VipInfo.fromJson(json['vipInfo'] as Map<String, dynamic>),
      stats: UserStats.fromJson(json['stats'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'nickname': instance.nickname,
      'avatar': instance.avatar,
      'bio': instance.bio,
      'email': instance.email,
      'phone': instance.phone,
      'vipInfo': instance.vipInfo?.toJson(),
      'stats': instance.stats.toJson(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

VipInfo _$VipInfoFromJson(Map<String, dynamic> json) => VipInfo(
      id: json['id'] as String,
      isActive: json['isActive'] as bool,
      expireAt: json['expireAt'] == null
          ? null
          : DateTime.parse(json['expireAt'] as String),
      level: $enumDecode(_$VipLevelEnumMap, json['level']),
      balance: (json['balance'] as num).toInt(),
      totalRecharge: (json['totalRecharge'] as num).toInt(),
    );

Map<String, dynamic> _$VipInfoToJson(VipInfo instance) => <String, dynamic>{
      'id': instance.id,
      'isActive': instance.isActive,
      'expireAt': instance.expireAt?.toIso8601String(),
      'level': _$VipLevelEnumMap[instance.level]!,
      'balance': instance.balance,
      'totalRecharge': instance.totalRecharge,
    };

const _$VipLevelEnumMap = {
  VipLevel.none: 'none',
  VipLevel.monthly: 'monthly',
  VipLevel.quarterly: 'quarterly',
  VipLevel.annual: 'annual',
  VipLevel.perpetual: 'perpetual',
};

UserStats _$UserStatsFromJson(Map<String, dynamic> json) => UserStats(
      bookCount: (json['bookCount'] as num).toInt(),
      followCount: (json['followCount'] as num).toInt(),
      followerCount: (json['followerCount'] as num).toInt(),
      postCount: (json['postCount'] as num).toInt(),
      commentCount: (json['commentCount'] as num).toInt(),
      likeCount: (json['likeCount'] as num).toInt(),
    );

Map<String, dynamic> _$UserStatsToJson(UserStats instance) => <String, dynamic>{
      'bookCount': instance.bookCount,
      'followCount': instance.followCount,
      'followerCount': instance.followerCount,
      'postCount': instance.postCount,
      'commentCount': instance.commentCount,
      'likeCount': instance.likeCount,
    };

AuthTokens _$AuthTokensFromJson(Map<String, dynamic> json) => AuthTokens(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresIn: (json['expiresIn'] as num).toInt(),
    );

Map<String, dynamic> _$AuthTokensToJson(AuthTokens instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'expiresIn': instance.expiresIn,
    };

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
      account: json['account'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'account': instance.account,
      'password': instance.password,
    };

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      nickname: json['nickname'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      inviteCode: json['inviteCode'] as String?,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'nickname': instance.nickname,
      'email': instance.email,
      'password': instance.password,
      'inviteCode': instance.inviteCode,
    };

VipProduct _$VipProductFromJson(Map<String, dynamic> json) => VipProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      level: $enumDecode(_$VipLevelEnumMap, json['level']),
      originalPrice: (json['originalPrice'] as num).toInt(),
      price: (json['price'] as num).toInt(),
      coinAmount: (json['coinAmount'] as num).toInt(),
      validityDays: (json['validityDays'] as num).toInt(),
      benefits:
          (json['benefits'] as List<dynamic>).map((e) => e as String).toList(),
      isPopular: json['isPopular'] as bool? ?? false,
    );

Map<String, dynamic> _$VipProductToJson(VipProduct instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'level': _$VipLevelEnumMap[instance.level]!,
      'originalPrice': instance.originalPrice,
      'price': instance.price,
      'coinAmount': instance.coinAmount,
      'validityDays': instance.validityDays,
      'benefits': instance.benefits,
      'isPopular': instance.isPopular,
    };
