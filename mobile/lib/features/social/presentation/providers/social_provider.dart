import 'package:flutter_riverpod/flutter_riverpod.dart';

// 动态模型
class Post {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final List<String> images;
  final String? bookId;
  final String? bookTitle;
  final String? bookAuthor;
  final String? bookCover;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool isLiked;
  final bool isVip;
  final DateTime createTime;
  
  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    this.images = const [],
    this.bookId,
    this.bookTitle,
    this.bookAuthor,
    this.bookCover,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.isLiked,
    required this.isVip,
    required this.createTime,
  });
  
  Post copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? content,
    List<String>? images,
    String? bookId,
    String? bookTitle,
    String? bookAuthor,
    String? bookCover,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    bool? isLiked,
    bool? isVip,
    DateTime? createTime,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      images: images ?? this.images,
      bookId: bookId ?? this.bookId,
      bookTitle: bookTitle ?? this.bookTitle,
      bookAuthor: bookAuthor ?? this.bookAuthor,
      bookCover: bookCover ?? this.bookCover,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      isLiked: isLiked ?? this.isLiked,
      isVip: isVip ?? this.isVip,
      createTime: createTime ?? this.createTime,
    );
  }
}

// 社交状态
class SocialState {
  final bool isLoading;
  final String? error;
  final List<Post> recommendedPosts;
  final List<Post> followingPosts;
  final List<Post> hotPosts;
  final List<UserProfile> suggestedUsers;
  
  SocialState({
    this.isLoading = false,
    this.error,
    this.recommendedPosts = const [],
    this.followingPosts = const [],
    this.hotPosts = const [],
    this.suggestedUsers = const [],
  });
  
  SocialState copyWith({
    bool? isLoading,
    String? error,
    List<Post>? recommendedPosts,
    List<Post>? followingPosts,
    List<Post>? hotPosts,
    List<UserProfile>? suggestedUsers,
  }) {
    return SocialState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      recommendedPosts: recommendedPosts ?? this.recommendedPosts,
      followingPosts: followingPosts ?? this.followingPosts,
      hotPosts: hotPosts ?? this.hotPosts,
      suggestedUsers: suggestedUsers ?? this.suggestedUsers,
    );
  }
}

// 用户资料
class UserProfile {
  final String id;
  final String nickname;
  final String avatarUrl;
  final String bio;
  final int followers;
  final int following;
  final int posts;
  final bool isFollowing;
  final bool isVip;
  
  UserProfile({
    required this.id,
    required this.nickname,
    required this.avatarUrl,
    required this.bio,
    required this.followers,
    required this.following,
    required this.posts,
    required this.isFollowing,
    required this.isVip,
  });
}

// 社交 Provider
final socialProvider = StateNotifierProvider<SocialNotifier, SocialState>((ref) {
  return SocialNotifier();
});

class SocialNotifier extends StateNotifier<SocialState> {
  SocialNotifier() : super(SocialState()) {
    _init();
  }
  
  Future<void> _init() async {
    await loadPosts();
  }
  
  Future<void> loadPosts() async {
    if (state.isLoading) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final recommendedPosts = _generateMockPosts(10, 'recommended');
      final followingPosts = _generateMockPosts(5, 'following');
      final hotPosts = _generateMockPosts(8, 'hot');
      final suggestedUsers = _generateMockUsers(6);
      
      state = state.copyWith(
        isLoading: false,
        recommendedPosts: recommendedPosts,
        followingPosts: followingPosts,
        hotPosts: hotPosts,
        suggestedUsers: suggestedUsers,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  void toggleLike(String postId) {
    final toggleInList = (List<Post> posts) {
      return posts.map((post) {
        if (post.id == postId) {
          return post.copyWith(
            isLiked: !post.isLiked,
            likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
          );
        }
        return post;
      }).toList();
    };
    
    state = state.copyWith(
      recommendedPosts: toggleInList(state.recommendedPosts),
      followingPosts: toggleInList(state.followingPosts),
      hotPosts: toggleInList(state.hotPosts),
    );
  }
  
  void createPost(String content) {
    final newPost = Post(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user',
      userName: '当前用户',
      userAvatar: 'https://picsum.photos/seed/currentuser/200/200',
      content: content,
      images: [],
      likeCount: 0,
      commentCount: 0,
      shareCount: 0,
      isLiked: false,
      isVip: false,
      createTime: DateTime.now(),
    );
    
    state = state.copyWith(
      recommendedPosts: [newPost, ...state.recommendedPosts],
      followingPosts: [newPost, ...state.followingPosts],
    );
  }
  
  void followUser(String userId) {
    final updateUser = (List<UserProfile> users) {
      return users.map((user) {
        if (user.id == userId) {
          return UserProfile(
            id: user.id,
            nickname: user.nickname,
            avatarUrl: user.avatarUrl,
            bio: user.bio,
            followers: user.isFollowing ? user.followers - 1 : user.followers + 1,
            following: user.following,
            posts: user.posts,
            isFollowing: !user.isFollowing,
            isVip: user.isVip,
          );
        }
        return user;
      }).toList();
    };
    
    state = state.copyWith(
      suggestedUsers: updateUser(state.suggestedUsers),
    );
  }
  
  List<Post> _generateMockPosts(int count, String type) {
    final contents = [
      '今天看完了《逆天改命》，太精彩了！主角的经历让人热血沸腾，推荐给大家！',
      '有没有人喜欢看玄幻小说的？我最近在追《仙武帝尊》，作者文笔太好了！',
      '分享一本好书：《都市全能高手》，都市爽文中的经典之作！',
      '阅读真的能让人放松心情，今天读了一整天的书，感觉收获满满。',
      '求推荐好看的言情小说，最近书荒了！',
      '这本书真的太好看了，我一口气看完了整本！',
      '阅读是一种修行，每天坚持读书，让自己变得更好。',
      '刚更新的章节太精彩了，作者加油！',
      '这本书的剧情太虐心了，看得我眼泪都快掉下来了。',
      '周末最适合宅在家里看书了，推荐几本我最近在看的书。',
    ];
    
    return List.generate(count, (index) {
      return Post(
        id: 'post_${type}_$index',
        userId: 'user_$index',
        userName: ['书虫一号', '阅读达人', '小说迷', '文学青年', '书评家'][index % 5],
        userAvatar: 'https://picsum.photos/seed/user_$index/200/200',
        content: contents[index % contents.length],
        images: index % 3 == 0
            ? ['https://picsum.photos/seed/post$index_1/400/400']
            : index % 3 == 1
                ? [
                    'https://picsum.photos/seed/post$index_1/400/400',
                    'https://picsum.photos/seed/post$index_2/400/400',
                    'https://picsum.photos/seed/post$index_3/400/400',
                  ]
                : [],
        bookId: index % 2 == 0 ? 'book_$index' : null,
        bookTitle: index % 2 == 0
            ? ['逆天改命', '都市全能高手', '仙武帝尊', '三体'][index % 4]
            : null,
        bookAuthor: index % 2 == 0
            ? ['天蚕土豆', '鱼人二代', '我吃西红柿', '刘慈欣'][index % 4]
            : null,
        bookCover: index % 2 == 0
            ? 'https://picsum.photos/seed/bookcover_$index/200/300'
            : null,
        likeCount: 100 + index * 10,
        commentCount: 20 + index * 5,
        shareCount: 10 + index * 2,
        isLiked: index % 4 == 0,
        isVip: index % 3 == 0,
        createTime: DateTime.now().subtract(Duration(hours: index * 3)),
      );
    });
  }
  
  List<UserProfile> _generateMockUsers(int count) {
    return List.generate(count, (index) {
      return UserProfile(
        id: 'user_profile_$index',
        nickname: ['阅读爱好者', '小说达人', '书评专家', '文学发烧友', '阅读达人', '书虫'][index],
        avatarUrl: 'https://picsum.photos/seed/profile_$index/200/200',
        bio: '热爱阅读，享受生活',
        followers: 1000 + index * 100,
        following: 100 + index * 10,
        posts: 50 + index * 5,
        isFollowing: index % 2 == 0,
        isVip: index % 3 == 0,
      );
    });
  }
}
