import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String nickname;
  final String avatar;
  final String? bio;
  final String? email;
  final String? phone;
  final VipInfo? vipInfo;
  final UserStats stats;
  final DateTime createdAt;

  User({
    required this.id,
    required this.nickname,
    required this.avatar,
    this.bio,
    this.email,
    this.phone,
    this.vipInfo,
    required this.stats,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  bool get isVip => vipInfo?.isActive ?? false;
}

@JsonSerializable()
class VipInfo {
  final String id;
  final bool isActive;
  final DateTime? expireAt;
  final VipLevel level;
  final int balance;
  final int totalRecharge;

  VipInfo({
    required this.id,
    required this.isActive,
    this.expireAt,
    required this.level,
    required this.balance,
    required this.totalRecharge,
  });

  factory VipInfo.fromJson(Map<String, dynamic> json) => _$VipInfoFromJson(json);
  Map<String, dynamic> toJson() => _$VipInfoToJson(this);

  String get levelName {
    switch (level) {
      case VipLevel.none:
        return '普通会员';
      case VipLevel.monthly:
        return '月度VIP';
      case VipLevel.quarterly:
        return '季度VIP';
      case VipLevel.annual:
        return '年度VIP';
      case VipLevel.perpetual:
        return '终身VIP';
    }
  }

  int get remainingDays {
    if (expireAt == null) return 0;
    return expireAt!.difference(DateTime.now()).inDays;
  }
}

@JsonEnum()
enum VipLevel {
  @JsonValue('none')
  none,
  @JsonValue('monthly')
  monthly,
  @JsonValue('quarterly')
  quarterly,
  @JsonValue('annual')
  annual,
  @JsonValue('perpetual')
  perpetual,
}

@JsonSerializable()
class UserStats {
  final int bookCount;
  final int followCount;
  final int followerCount;
  final int postCount;
  final int commentCount;
  final int likeCount;

  UserStats({
    required this.bookCount,
    required this.followCount,
    required this.followerCount,
    required this.postCount,
    required this.commentCount,
    required this.likeCount,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) => _$UserStatsFromJson(json);
  Map<String, dynamic> toJson() => _$UserStatsToJson(this);
}

@JsonSerializable()
class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) => _$AuthTokensFromJson(json);
  Map<String, dynamic> toJson() => _$AuthTokensToJson(this);
}

@JsonSerializable()
class LoginRequest {
  final String account;
  final String password;

  LoginRequest({
    required this.account,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class RegisterRequest {
  final String nickname;
  final String email;
  final String password;
  final String? inviteCode;

  RegisterRequest({
    required this.nickname,
    required this.email,
    required this.password,
    this.inviteCode,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class VipProduct {
  final String id;
  final String name;
  final VipLevel level;
  final int originalPrice;
  final int price;
  final int coinAmount;
  final int validityDays;
  final List<String> benefits;
  final bool isPopular;

  VipProduct({
    required this.id,
    required this.name,
    required this.level,
    required this.originalPrice,
    required this.price,
    required this.coinAmount,
    required this.validityDays,
    required this.benefits,
    this.isPopular = false,
  });

  factory VipProduct.fromJson(Map<String, dynamic> json) => _$VipProductFromJson(json);
  Map<String, dynamic> toJson() => _$VipProductToJson(this);

  String get validityText {
    switch (level) {
      case VipLevel.monthly:
        return '1个月';
      case VipLevel.quarterly:
        return '3个月';
      case VipLevel.annual:
        return '12个月';
      case VipLevel.perpetual:
        return '永久';
      default:
        return '$validityDays天';
    }
  }

  int get discount {
    if (originalPrice == 0) return 100;
    return ((price / originalPrice) * 10).round();
  }
}
