import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import type { User, ReaderSettings, Bookmark, Note, ReadingProgress } from '@/lib/types';

// Auth Store
interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  setUser: (user: User | null) => void;
  setToken: (token: string | null) => void;
  login: (user: User, token: string) => void;
  logout: () => void;
  updateUser: (updates: Partial<User>) => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      token: null,
      isAuthenticated: false,
      isLoading: false,
      setUser: (user) => set({ user, isAuthenticated: !!user }),
      setToken: (token) => set({ token }),
      login: (user, token) => set({ user, token, isAuthenticated: true }),
      logout: () => set({ user: null, token: null, isAuthenticated: false }),
      updateUser: (updates) =>
        set((state) => ({
          user: state.user ? { ...state.user, ...updates } : null,
        })),
    }),
    {
      name: 'auth-storage',
    }
  )
);

// Reader Store
interface ReaderState {
  settings: ReaderSettings;
  currentBook: { id: string; title: string } | null;
  currentChapter: { id: string; number: number; title: string } | null;
  progress: ReadingProgress | null;
  bookmarks: Bookmark[];
  notes: Note[];
  isToolbarVisible: boolean;
  isSettingsOpen: boolean;
  updateSettings: (settings: Partial<ReaderSettings>) => void;
  setCurrentBook: (book: { id: string; title: string } | null) => void;
  setCurrentChapter: (chapter: { id: string; number: number; title: string } | null) => void;
  setProgress: (progress: ReadingProgress | null) => void;
  addBookmark: (bookmark: Bookmark) => void;
  removeBookmark: (id: string) => void;
  addNote: (note: Note) => void;
  updateNote: (id: string, updates: Partial<Note>) => void;
  deleteNote: (id: string) => void;
  toggleToolbar: () => void;
  toggleSettings: () => void;
}

export const useReaderStore = create<ReaderState>()(
  persist(
    (set) => ({
      settings: {
        theme: 'paper',
        fontSize: 18,
        fontFamily: 'default',
        lineHeight: 1.8,
        pageMode: 'scroll',
        autoSave: true,
        readAloud: false,
        readAloudSpeed: 1,
      },
      currentBook: null,
      currentChapter: null,
      progress: null,
      bookmarks: [],
      notes: [],
      isToolbarVisible: true,
      isSettingsOpen: false,
      updateSettings: (newSettings) =>
        set((state) => ({
          settings: { ...state.settings, ...newSettings },
        })),
      setCurrentBook: (book) => set({ currentBook: book }),
      setCurrentChapter: (chapter) => set({ currentChapter: chapter }),
      setProgress: (progress) => set({ progress }),
      addBookmark: (bookmark) =>
        set((state) => ({ bookmarks: [...state.bookmarks, bookmark] })),
      removeBookmark: (id) =>
        set((state) => ({ bookmarks: state.bookmarks.filter((b) => b.id !== id) })),
      addNote: (note) => set((state) => ({ notes: [...state.notes, note] })),
      updateNote: (id, updates) =>
        set((state) => ({
          notes: state.notes.map((n) => (n.id === id ? { ...n, ...updates } : n)),
        })),
      deleteNote: (id) =>
        set((state) => ({ notes: state.notes.filter((n) => n.id !== id) })),
      toggleToolbar: () => set((state) => ({ isToolbarVisible: !state.isToolbarVisible })),
      toggleSettings: () => set((state) => ({ isSettingsOpen: !state.isSettingsOpen })),
    }),
    {
      name: 'reader-storage',
    }
  )
);

// UI Store
interface UIState {
  isSidebarOpen: boolean;
  isSearchOpen: boolean;
  isThemeMenuOpen: boolean;
  isUserMenuOpen: boolean;
  isLanguageMenuOpen: boolean;
  toggleSidebar: () => void;
  toggleSearch: () => void;
  toggleThemeMenu: () => void;
  toggleUserMenu: () => void;
  toggleLanguageMenu: () => void;
  closeAllMenus: () => void;
}

export const useUIStore = create<UIState>()((set) => ({
  isSidebarOpen: false,
  isSearchOpen: false,
  isThemeMenuOpen: false,
  isUserMenuOpen: false,
  isLanguageMenuOpen: false,
  toggleSidebar: () => set((state) => ({ isSidebarOpen: !state.isSidebarOpen })),
  toggleSearch: () => set((state) => ({ isSearchOpen: !state.isSearchOpen })),
  toggleThemeMenu: () => set((state) => ({ isThemeMenuOpen: !state.isThemeMenuOpen })),
  toggleUserMenu: () => set((state) => ({ isUserMenuOpen: !state.isUserMenuOpen })),
  toggleLanguageMenu: () => set((state) => ({ isLanguageMenuOpen: !state.isLanguageMenuOpen })),
  closeAllMenus: () =>
    set({
      isSidebarOpen: false,
      isSearchOpen: false,
      isThemeMenuOpen: false,
      isUserMenuOpen: false,
      isLanguageMenuOpen: false,
    }),
}));

// Bookshelf Store
interface BookshelfState {
  books: { id: string; addedAt: string }[];
  readingHistory: { bookId: string; chapterId: string; lastReadAt: string }[];
  addBook: (bookId: string) => void;
  removeBook: (bookId: string) => void;
  isBookInShelf: (bookId: string) => boolean;
  updateReadingHistory: (bookId: string, chapterId: string) => void;
  clearHistory: () => void;
}

export const useBookshelfStore = create<BookshelfState>()(
  persist(
    (set, get) => ({
      books: [],
      readingHistory: [],
      addBook: (bookId) =>
        set((state) => {
          if (state.books.some((b) => b.id === bookId)) {
            return state;
          }
          return { books: [...state.books, { id: bookId, addedAt: new Date().toISOString() }] };
        }),
      removeBook: (bookId) =>
        set((state) => ({ books: state.books.filter((b) => b.id !== bookId) })),
      isBookInShelf: (bookId) => get().books.some((b) => b.id === bookId),
      updateReadingHistory: (bookId, chapterId) =>
        set((state) => {
          const filtered = state.readingHistory.filter((h) => h.bookId !== bookId);
          return {
            readingHistory: [
              ...filtered,
              { bookId, chapterId, lastReadAt: new Date().toISOString() },
            ],
          };
        }),
      clearHistory: () => set({ readingHistory: [] }),
    }),
    {
      name: 'bookshelf-storage',
    }
  )
);

// Search Store
interface SearchState {
  recentSearches: string[];
  searchHistory: string[];
  addRecentSearch: (keyword: string) => void;
  clearRecentSearches: () => void;
  addToSearchHistory: (keyword: string) => void;
  clearSearchHistory: () => void;
}

export const useSearchStore = create<SearchState>()(
  persist(
    (set) => ({
      recentSearches: [],
      searchHistory: [],
      addRecentSearch: (keyword) =>
        set((state) => {
          const filtered = state.recentSearches.filter((k) => k !== keyword);
          return { recentSearches: [keyword, ...filtered].slice(0, 10) };
        }),
      clearRecentSearches: () => set({ recentSearches: [] }),
      addToSearchHistory: (keyword) =>
        set((state) => {
          const filtered = state.searchHistory.filter((k) => k !== keyword);
          return { searchHistory: [keyword, ...filtered].slice(0, 50) };
        }),
      clearSearchHistory: () => set({ searchHistory: [] }),
    }),
    {
      name: 'search-storage',
    }
  )
);
