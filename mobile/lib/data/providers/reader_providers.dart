import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/storage_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/models.dart';

// 阅读器设置
class ReaderSettings {
  final double fontSize;
  final double lineHeight;
  final ReaderTheme theme;
  final String fontFamily;
  final bool showPageNumber;
  final bool autoTurnPage;
  final int autoTurnInterval;

  ReaderSettings({
    this.fontSize = AppConstants.defaultFontSize,
    this.lineHeight = AppConstants.defaultLineHeight,
    this.theme = ReaderTheme.light,
    this.fontFamily = 'NotoSansSC',
    this.showPageNumber = true,
    this.autoTurnPage = false,
    this.autoTurnInterval = 5,
  });

  ReaderSettings copyWith({
    double? fontSize,
    double? lineHeight,
    ReaderTheme? theme,
    String? fontFamily,
    bool? showPageNumber,
    bool? autoTurnPage,
    int? autoTurnInterval,
  }) {
    return ReaderSettings(
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      theme: theme ?? this.theme,
      fontFamily: fontFamily ?? this.fontFamily,
      showPageNumber: showPageNumber ?? this.showPageNumber,
      autoTurnPage: autoTurnPage ?? this.autoTurnPage,
      autoTurnInterval: autoTurnInterval ?? this.autoTurnInterval,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontSize': fontSize,
      'lineHeight': lineHeight,
      'theme': theme.name,
      'fontFamily': fontFamily,
      'showPageNumber': showPageNumber,
      'autoTurnPage': autoTurnPage,
      'autoTurnInterval': autoTurnInterval,
    };
  }

  factory ReaderSettings.fromJson(Map<String, dynamic> json) {
    return ReaderSettings(
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? AppConstants.defaultFontSize,
      lineHeight: (json['lineHeight'] as num?)?.toDouble() ?? AppConstants.defaultLineHeight,
      theme: ReaderTheme.values.firstWhere(
        (e) => e.name == json['theme'],
        orElse: () => ReaderTheme.light,
      ),
      fontFamily: json['fontFamily'] as String? ?? 'NotoSansSC',
      showPageNumber: json['showPageNumber'] as bool? ?? true,
      autoTurnPage: json['autoTurnPage'] as bool? ?? false,
      autoTurnInterval: json['autoTurnInterval'] as int? ?? 5,
    );
  }
}

enum ReaderTheme {
  light,
  sepia,
  dark,
  night,
}

extension ReaderThemeExtension on ReaderTheme {
  Color get backgroundColor {
    switch (this) {
      case ReaderTheme.light:
        return const Color(0xFFF5F0E6);
      case ReaderTheme.sepia:
        return const Color(0xFFF4ECD8);
      case ReaderTheme.dark:
        return const Color(0xFF1A1A1A);
      case ReaderTheme.night:
        return const Color(0xFF000000);
    }
  }

  Color get textColor {
    switch (this) {
      case ReaderTheme.light:
        return const Color(0xFF333333);
      case ReaderTheme.sepia:
        return const Color(0xFF5D4E37);
      case ReaderTheme.dark:
        return const Color(0xFFCCCCCC);
      case ReaderTheme.night:
        return const Color(0xFF666666);
    }
  }

  String get name {
    switch (this) {
      case ReaderTheme.light:
        return '默认';
      case ReaderTheme.sepia:
        return '护眼';
      case ReaderTheme.dark:
        return '夜间';
      case ReaderTheme.night:
        return '深夜';
    }
  }
}

// 阅读器状态
class ReaderState {
  final Book? book;
  final List<Chapter> chapters;
  final Chapter? currentChapter;
  final ChapterContent? chapterContent;
  final int currentChapterIndex;
  final ReadProgress? progress;
  final bool isLoading;
  final bool isMenuVisible;
  final bool isChapterListVisible;
  final String? error;

  ReaderState({
    this.book,
    this.chapters = const [],
    this.currentChapter,
    this.chapterContent,
    this.currentChapterIndex = 0,
    this.progress,
    this.isLoading = false,
    this.isMenuVisible = false,
    this.isChapterListVisible = false,
    this.error,
  });

  ReaderState copyWith({
    Book? book,
    List<Chapter>? chapters,
    Chapter? currentChapter,
    ChapterContent? chapterContent,
    int? currentChapterIndex,
    ReadProgress? progress,
    bool? isLoading,
    bool? isMenuVisible,
    bool? isChapterListVisible,
    String? error,
  }) {
    return ReaderState(
      book: book ?? this.book,
      chapters: chapters ?? this.chapters,
      currentChapter: currentChapter ?? this.currentChapter,
      chapterContent: chapterContent ?? this.chapterContent,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      progress: progress ?? this.progress,
      isLoading: isLoading ?? this.isLoading,
      isMenuVisible: isMenuVisible ?? this.isMenuVisible,
      isChapterListVisible: isChapterListVisible ?? this.isChapterListVisible,
      error: error,
    );
  }

  bool get hasNextChapter => currentChapterIndex < chapters.length - 1;
  bool get hasPrevChapter => currentChapterIndex > 0;
}

// 阅读器状态管理
class ReaderNotifier extends StateNotifier<ReaderState> {
  final StorageService _storage;
  final String bookId;

  ReaderNotifier(this._storage, this.bookId) : super(ReaderState()) {
    _loadProgress();
  }

  void _loadProgress() {
    final progressData = _storage.getReadProgress(bookId);
    if (progressData != null) {
      state = state.copyWith(progress: ReadProgress.fromJson(progressData));
    }
  }

  void setBook(Book book) {
    state = state.copyWith(book: book);
  }

  void setChapters(List<Chapter> chapters) {
    state = state.copyWith(chapters: chapters);
  }

  Future<void> loadChapter(int index) async {
    if (index < 0 || index >= state.chapters.length) return;

    state = state.copyWith(
      isLoading: true,
      currentChapterIndex: index,
      currentChapter: state.chapters[index],
    );

    try {
      // 实际应该调用API获取章节内容
      // 这里简化处理
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void toggleMenu() {
    state = state.copyWith(isMenuVisible: !state.isMenuVisible);
  }

  void showMenu() {
    state = state.copyWith(isMenuVisible: true);
  }

  void hideMenu() {
    state = state.copyWith(isMenuVisible: false);
  }

  void toggleChapterList() {
    state = state.copyWith(isChapterListVisible: !state.isChapterListVisible);
  }

  void nextChapter() {
    if (state.hasNextChapter) {
      loadChapter(state.currentChapterIndex + 1);
    }
  }

  void prevChapter() {
    if (state.hasPrevChapter) {
      loadChapter(state.currentChapterIndex - 1);
    }
  }

  Future<void> saveProgress(int position) async {
    if (state.currentChapter == null) return;

    final progress = ReadProgress(
      bookId: bookId,
      chapterId: state.currentChapter!.id,
      chapterNumber: state.currentChapter!.number,
      progress: position / 100.0,
      position: position,
      updatedAt: DateTime.now(),
    );

    await _storage.saveReadProgress(bookId, progress.toJson());
    state = state.copyWith(progress: progress);
  }
}

// Provider
final readerSettingsProvider = StateNotifierProvider<ReaderSettingsNotifier, ReaderSettings>((ref) {
  final storage = StorageService.instance;
  return ReaderSettingsNotifier(storage);
});

class ReaderSettingsNotifier extends StateNotifier<ReaderSettings> {
  final StorageService _storage;

  ReaderSettingsNotifier(this._storage) : super(ReaderSettings()) {
    _loadSettings();
  }

  void _loadSettings() {
    final settings = _storage.getReaderSettings();
    state = ReaderSettings.fromJson(settings);
  }

  Future<void> _saveSettings() async {
    await _storage.saveReaderSettings(state.toJson());
  }

  void setFontSize(double size) {
    state = state.copyWith(fontSize: size.clamp(AppConstants.minFontSize, AppConstants.maxFontSize));
    _saveSettings();
  }

  void setLineHeight(double height) {
    state = state.copyWith(lineHeight: height.clamp(AppConstants.minLineHeight, AppConstants.maxLineHeight));
    _saveSettings();
  }

  void setTheme(ReaderTheme theme) {
    state = state.copyWith(theme: theme);
    _saveSettings();
  }

  void setFontFamily(String fontFamily) {
    state = state.copyWith(fontFamily: fontFamily);
    _saveSettings();
  }

  void setShowPageNumber(bool show) {
    state = state.copyWith(showPageNumber: show);
    _saveSettings();
  }

  void setAutoTurnPage(bool auto) {
    state = state.copyWith(autoTurnPage: auto);
    _saveSettings();
  }

  void setAutoTurnInterval(int seconds) {
    state = state.copyWith(autoTurnInterval: seconds);
    _saveSettings();
  }

  void increaseFontSize() {
    setFontSize(state.fontSize + 2);
  }

  void decreaseFontSize() {
    setFontSize(state.fontSize - 2);
  }
}

// 阅读器实例 Provider
final readerProvider = StateNotifierProvider.family<ReaderNotifier, ReaderState, String>((ref, bookId) {
  final storage = StorageService.instance;
  return ReaderNotifier(storage, bookId);
});

// 书签 Provider
final bookmarksProvider = FutureProvider.family<List<Bookmark>, String>((ref, bookId) async {
  final storage = StorageService.instance;
  final data = storage.userBox.get('bookmarks_$bookId');
  if (data != null) {
    return (data as List).map((e) => Bookmark.fromJson(Map<String, dynamic>.from(e))).toList();
  }
  return [];
});

// 笔记 Provider
final notesProvider = FutureProvider.family<List<Note>, String>((ref, bookId) async {
  final storage = StorageService.instance;
  final data = storage.userBox.get('notes_$bookId');
  if (data != null) {
    return (data as List).map((e) => Note.fromJson(Map<String, dynamic>.from(e))).toList();
  }
  return [];
});
