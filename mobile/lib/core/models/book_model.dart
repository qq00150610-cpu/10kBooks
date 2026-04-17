// 书籍模型
class Book {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final String description;
  final String category;
  final int chapterCount;
  final int wordCount;
  final double rating;
  final int viewCount;
  final int collectCount;
  final bool isVipOnly;
  final bool isCompleted;
  final DateTime publishDate;
  final List<String> tags;
  final String language;
  
  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.description,
    required this.category,
    required this.chapterCount,
    required this.wordCount,
    required this.rating,
    required this.viewCount,
    required this.collectCount,
    required this.isVipOnly,
    required this.isCompleted,
    required this.publishDate,
    required this.tags,
    required this.language,
  });
  
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      coverUrl: json['cover_url'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      chapterCount: json['chapter_count'] ?? 0,
      wordCount: json['word_count'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      viewCount: json['view_count'] ?? 0,
      collectCount: json['collect_count'] ?? 0,
      isVipOnly: json['is_vip_only'] ?? false,
      isCompleted: json['is_completed'] ?? false,
      publishDate: json['publish_date'] != null
          ? DateTime.parse(json['publish_date'])
          : DateTime.now(),
      tags: List<String>.from(json['tags'] ?? []),
      language: json['language'] ?? 'zh',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'cover_url': coverUrl,
      'description': description,
      'category': category,
      'chapter_count': chapterCount,
      'word_count': wordCount,
      'rating': rating,
      'view_count': viewCount,
      'collect_count': collectCount,
      'is_vip_only': isVipOnly,
      'is_completed': isCompleted,
      'publish_date': publishDate.toIso8601String(),
      'tags': tags,
      'language': language,
    };
  }
}

// 章节模型
class Chapter {
  final String id;
  final String bookId;
  final int index;
  final String title;
  final int wordCount;
  final bool isVip;
  final DateTime publishDate;
  final String content;
  
  Chapter({
    required this.id,
    required this.bookId,
    required this.index,
    required this.title,
    required this.wordCount,
    required this.isVip,
    required this.publishDate,
    this.content = '',
  });
  
  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] ?? '',
      bookId: json['book_id'] ?? '',
      index: json['index'] ?? 0,
      title: json['title'] ?? '',
      wordCount: json['word_count'] ?? 0,
      isVip: json['is_vip'] ?? false,
      publishDate: json['publish_date'] != null
          ? DateTime.parse(json['publish_date'])
          : DateTime.now(),
      content: json['content'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book_id': bookId,
      'index': index,
      'title': title,
      'word_count': wordCount,
      'is_vip': isVip,
      'publish_date': publishDate.toIso8601String(),
      'content': content,
    };
  }
}

// 阅读进度模型
class ReadingProgress {
  final String id;
  final String bookId;
  final String chapterId;
  final int chapterIndex;
  final double progress;
  final int readPosition;
  final DateTime lastReadTime;
  
  ReadingProgress({
    required this.id,
    required this.bookId,
    required this.chapterId,
    required this.chapterIndex,
    required this.progress,
    required this.readPosition,
    required this.lastReadTime,
  });
  
  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      id: json['id'] ?? '',
      bookId: json['book_id'] ?? '',
      chapterId: json['chapter_id'] ?? '',
      chapterIndex: json['chapter_index'] ?? 0,
      progress: (json['progress'] ?? 0).toDouble(),
      readPosition: json['read_position'] ?? 0,
      lastReadTime: json['last_read_time'] != null
          ? DateTime.parse(json['last_read_time'])
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book_id': bookId,
      'chapter_id': chapterId,
      'chapter_index': chapterIndex,
      'progress': progress,
      'read_position': readPosition,
      'last_read_time': lastReadTime.toIso8601String(),
    };
  }
}

// 书签模型
class Bookmark {
  final String id;
  final String bookId;
  final String chapterId;
  final String chapterTitle;
  final int position;
  final String note;
  final DateTime createTime;
  
  Bookmark({
    required this.id,
    required this.bookId,
    required this.chapterId,
    required this.chapterTitle,
    required this.position,
    this.note = '',
    required this.createTime,
  });
  
  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] ?? '',
      bookId: json['book_id'] ?? '',
      chapterId: json['chapter_id'] ?? '',
      chapterTitle: json['chapter_title'] ?? '',
      position: json['position'] ?? 0,
      note: json['note'] ?? '',
      createTime: json['create_time'] != null
          ? DateTime.parse(json['create_time'])
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book_id': bookId,
      'chapter_id': chapterId,
      'chapter_title': chapterTitle,
      'position': position,
      'note': note,
      'create_time': createTime.toIso8601String(),
    };
  }
}

// 笔记模型
class Note {
  final String id;
  final String bookId;
  final String chapterId;
  final String chapterTitle;
  final String content;
  final String selectedText;
  final DateTime createTime;
  
  Note({
    required this.id,
    required this.bookId,
    required this.chapterId,
    required this.chapterTitle,
    required this.content,
    required this.selectedText,
    required this.createTime,
  });
  
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] ?? '',
      bookId: json['book_id'] ?? '',
      chapterId: json['chapter_id'] ?? '',
      chapterTitle: json['chapter_title'] ?? '',
      content: json['content'] ?? '',
      selectedText: json['selected_text'] ?? '',
      createTime: json['create_time'] != null
          ? DateTime.parse(json['create_time'])
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book_id': bookId,
      'chapter_id': chapterId,
      'chapter_title': chapterTitle,
      'content': content,
      'selected_text': selectedText,
      'create_time': createTime.toIso8601String(),
    };
  }
}
