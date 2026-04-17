import { Test, TestingModule } from '@nestjs/testing';
import { BookController } from './book.controller';
import { BookService } from './book.service';

describe('BookController', () => {
  let controller: BookController;
  let bookService: BookService;

  const mockBookService = {
    searchBooks: jest.fn(),
    getBookDetail: jest.fn(),
    getBookChapters: jest.fn(),
    getChapterContent: jest.fn(),
    collectBook: jest.fn(),
    uncollectBook: jest.fn(),
    getHotBooks: jest.fn(),
    getNewBooks: jest.fn(),
    getRecommendedBooks: jest.fn(),
    getCategories: jest.fn(),
    getTags: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [BookController],
      providers: [{ provide: BookService, useValue: mockBookService }],
    }).compile();

    controller = module.get<BookController>(BookController);
    bookService = module.get<BookService>(BookService);
  });

  afterEach(() => jest.clearAllMocks());

  describe('searchBooks', () => {
    it('should return search results', async () => {
      const searchDto = { keyword: 'test', page: 1, pageSize: 20 };
      const expectedResult = {
        list: [{ id: 'uuid', title: 'Test Book' }],
        pagination: { page: 1, pageSize: 20, total: 1, totalPages: 1 },
      };

      mockBookService.searchBooks.mockResolvedValue(expectedResult);

      const result = await controller.searchBooks(searchDto);

      expect(bookService.searchBooks).toHaveBeenCalledWith(searchDto);
      expect(result).toEqual(expectedResult);
    });
  });

  describe('getHotBooks', () => {
    it('should return hot books', async () => {
      const expectedResult = [{ id: 'uuid', title: 'Hot Book', totalViews: 1000 }];
      mockBookService.getHotBooks.mockResolvedValue(expectedResult);

      const result = await controller.getHotBooks(10);

      expect(bookService.getHotBooks).toHaveBeenCalledWith(10);
      expect(result).toEqual(expectedResult);
    });
  });

  describe('getBookDetail', () => {
    it('should return book details', async () => {
      const expectedResult = {
        id: 'uuid',
        title: 'Test Book',
        description: 'Description',
        author: { id: 'author-uuid', penName: 'Author Name' },
      };

      mockBookService.getBookDetail.mockResolvedValue(expectedResult);

      const result = await controller.getBookDetail('uuid', 'user-uuid');

      expect(bookService.getBookDetail).toHaveBeenCalledWith('uuid', 'user-uuid');
      expect(result).toEqual(expectedResult);
    });
  });

  describe('collectBook', () => {
    it('should collect a book', async () => {
      mockBookService.collectBook.mockResolvedValue({ message: '收藏成功' });

      const result = await controller.collectBook('book-uuid', 'user-uuid', 'Note');

      expect(bookService.collectBook).toHaveBeenCalledWith('user-uuid', 'book-uuid', 'Note');
      expect(result).toEqual({ message: '收藏成功' });
    });
  });
});
