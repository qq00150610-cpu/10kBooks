// 用户模型
class User {
  final String id;
  final String username;
  final String nickname;
  final String avatarUrl;
  final String email;
  final String phone;
  final int vipLevel;
  final DateTime? vipExpireTime;
  final int coinBalance;
  final int readTime;
  final int bookCount;
  final int followingCount;
  final int followerCount;
  final String bio;
  final bool isAuthor;
  final DateTime registerTime;
  final DateTime lastLoginTime;
  
  User({
    required this.id,
    required this.username,
    required this.nickname,
    required this.avatarUrl,
    required this.email,
    required this.phone,
    required this.vipLevel,
    this.vipExpireTime,
    required this.coinBalance,
    required this.readTime,
    required this.bookCount,
    required this.followingCount,
    required this.followerCount,
    required this.bio,
    required this.isAuthor,
    required this.registerTime,
    required this.lastLoginTime,
  });
  
  bool get isVip => vipLevel > 0;
  
  bool get isVipExpired =>
      vipExpireTime != null && vipExpireTime!.isBefore(DateTime.now());
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      nickname: json['nickname'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      vipLevel: json['vip_level'] ?? 0,
      vipExpireTime: json['vip_expire_time'] != null
          ? DateTime.parse(json['vip_expire_time'])
          : null,
      coinBalance: json['coin_balance'] ?? 0,
      readTime: json['read_time'] ?? 0,
      bookCount: json['book_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      followerCount: json['follower_count'] ?? 0,
      bio: json['bio'] ?? '',
      isAuthor: json['is_author'] ?? false,
      registerTime: json['register_time'] != null
          ? DateTime.parse(json['register_time'])
          : DateTime.now(),
      lastLoginTime: json['last_login_time'] != null
          ? DateTime.parse(json['last_login_time'])
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nickname': nickname,
      'avatar_url': avatarUrl,
      'email': email,
      'phone': phone,
      'vip_level': vipLevel,
      'vip_expire_time': vipExpireTime?.toIso8601String(),
      'coin_balance': coinBalance,
      'read_time': readTime,
      'book_count': bookCount,
      'following_count': followingCount,
      'follower_count': followerCount,
      'bio': bio,
      'is_author': isAuthor,
      'register_time': registerTime.toIso8601String(),
      'last_login_time': lastLoginTime.toIso8601String(),
    };
  }
  
  User copyWith({
    String? id,
    String? username,
    String? nickname,
    String? avatarUrl,
    String? email,
    String? phone,
    int? vipLevel,
    DateTime? vipExpireTime,
    int? coinBalance,
    int? readTime,
    int? bookCount,
    int? followingCount,
    int? followerCount,
    String? bio,
    bool? isAuthor,
    DateTime? registerTime,
    DateTime? lastLoginTime,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      vipLevel: vipLevel ?? this.vipLevel,
      vipExpireTime: vipExpireTime ?? this.vipExpireTime,
      coinBalance: coinBalance ?? this.coinBalance,
      readTime: readTime ?? this.readTime,
      bookCount: bookCount ?? this.bookCount,
      followingCount: followingCount ?? this.followingCount,
      followerCount: followerCount ?? this.followerCount,
      bio: bio ?? this.bio,
      isAuthor: isAuthor ?? this.isAuthor,
      registerTime: registerTime ?? this.registerTime,
      lastLoginTime: lastLoginTime ?? this.lastLoginTime,
    );
  }
}

// 登录响应
class LoginResponse {
  final String token;
  final User user;
  final DateTime expireTime;
  
  LoginResponse({
    required this.token,
    required this.user,
    required this.expireTime,
  });
  
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
      expireTime: json['expire_time'] != null
          ? DateTime.parse(json['expire_time'])
          : DateTime.now().add(const Duration(days: 7)),
    );
  }
}
