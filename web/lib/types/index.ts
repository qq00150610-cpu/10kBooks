// User types
export interface User {
  id: string;
  username: string;
  email: string;
  avatar?: string;
  role: 'user' | 'author' | 'admin';
  vipLevel: 0 | 1 | 2 | 3;
  vipExpireDate?: string;
  gender?: 'male' | 'female' | 'other';
  bio?: string;
  location?: string;
  birthDate?: string;
  createdAt: string;
  stats: {
    followers: number;
    following: number;
    books: number;
    chapters: number;
  };
}

// Book types
export interface Book {
  id: string;
  title: string;
  cover: string;
  author: {
    id: string;
    name: string;
    avatar?: string;
  };
  category: string;
  subCategory?: string;
  tags: string[];
  description: string;
  status: 'ongoing' | 'completed' | 'paused';
  wordCount: number;
  viewCount: number;
  likeCount: number;
  commentCount: number;
  subscribeCount: number;
  rating: number;
  ratingCount: number;
  chapters: Chapter[];
  createdAt: string;
  updatedAt: string;
  isVip: boolean;
  isPaid: boolean;
  price?: number;
  freeChapterCount: number;
}

export interface Chapter {
  id: string;
  bookId: string;
  title: string;
  number: number;
  content?: string;
  wordCount: number;
  viewCount: number;
  likeCount: number;
  isVip: boolean;
  isPaid: boolean;
  price: number;
  status: 'published' | 'draft' | 'pending';
  createdAt: string;
  updatedAt: string;
  publishedAt?: string;
}

// Author types
export interface Author {
  id: string;
  user: User;
  penName: string;
  bio: string;
  avatar: string;
  totalWords: number;
  totalBooks: number;
  totalViews: number;
  totalEarnings: number;
  pendingEarnings: number;
  withdrawalAmount: number;
  rating: number;
  level: number;
  joinedAt: string;
  books: Book[];
}

// Reading types
export interface ReadingProgress {
  id: string;
  userId: string;
  bookId: string;
  chapterId: string;
  position: number;
  percentage: number;
  lastReadAt: string;
}

export interface Bookmark {
  id: string;
  userId: string;
  bookId: string;
  chapterId: string;
  position: number;
  content?: string;
  note?: string;
  createdAt: string;
}

export interface Note {
  id: string;
  userId: string;
  bookId: string;
  chapterId: string;
  content: string;
  selectedText?: string;
  pageNumber?: number;
  createdAt: string;
  updatedAt: string;
}

// Social types
export interface Comment {
  id: string;
  userId: string;
  user: User;
  targetType: 'book' | 'chapter' | 'note' | 'post';
  targetId: string;
  content: string;
  likes: number;
  isLiked: boolean;
  replies?: Comment[];
  parentId?: string;
  createdAt: string;
  updatedAt: string;
}

export interface Post {
  id: string;
  userId: string;
  user: User;
  content: string;
  images?: string[];
  bookId?: string;
  book?: Book;
  likes: number;
  comments: number;
  shares: number;
  isLiked: boolean;
  createdAt: string;
}

export interface BookList {
  id: string;
  userId: string;
  user: User;
  title: string;
  description: string;
  cover?: string;
  isPublic: boolean;
  books: Book[];
  likes: number;
  followers: number;
  createdAt: string;
  updatedAt: string;
}

// Payment types
export interface Order {
  id: string;
  userId: string;
  type: 'vip' | 'book' | 'chapter' | 'recharge';
  amount: number;
  status: 'pending' | 'completed' | 'failed' | 'refunded';
  createdAt: string;
  completedAt?: string;
}

export interface RechargeRecord {
  id: string;
  userId: string;
  amount: number;
  coins: number;
  paymentMethod: string;
  status: 'pending' | 'completed' | 'failed';
  createdAt: string;
}

export interface ConsumptionRecord {
  id: string;
  userId: string;
  type: 'book' | 'chapter' | 'vip';
  targetId: string;
  targetName: string;
  amount: number;
  coins: number;
  createdAt: string;
}

// Reader settings
export interface ReaderSettings {
  theme: 'paper' | 'sepia' | 'night' | 'dark';
  fontSize: number;
  fontFamily: string;
  lineHeight: number;
  pageMode: 'scroll' | 'paginate';
  autoSave: boolean;
  readAloud: boolean;
  readAloudSpeed: number;
}

// Search and filter types
export interface SearchParams {
  keyword?: string;
  category?: string;
  tags?: string[];
  status?: string;
  sortBy?: 'relevance' | 'rating' | 'views' | 'updated' | 'newest';
  sortOrder?: 'asc' | 'desc';
  page: number;
  pageSize: number;
}

export interface SearchResult<T> {
  items: T[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

// API response types
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export interface PaginatedResponse<T> {
  items: T[];
  pagination: {
    total: number;
    page: number;
    pageSize: number;
    totalPages: number;
  };
}
