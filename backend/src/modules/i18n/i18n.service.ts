import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

// 多语言翻译服务
@Injectable()
export class I18nService {
  private translations: Record<string, Record<string, string>> = {
    'zh-CN': {
      welcome: '欢迎来到万卷书苑',
      book: '书籍',
      chapter: '章节',
      author: '作者',
      reader: '读者',
      search: '搜索',
      login: '登录',
      register: '注册',
      profile: '个人资料',
      settings: '设置',
      language: '语言',
    },
    'en-US': {
      welcome: 'Welcome to 10kBooks',
      book: 'Book',
      chapter: 'Chapter',
      author: 'Author',
      reader: 'Reader',
      search: 'Search',
      login: 'Login',
      register: 'Register',
      profile: 'Profile',
      settings: 'Settings',
      language: 'Language',
    },
    'ja-JP': {
      welcome: '万巻書苑へようこそ',
      book: '書籍',
      chapter: '章',
      author: '著者',
      reader: '読者',
      search: '検索',
      login: 'ログイン',
      register: '登録',
      profile: 'プロフィール',
      settings: '設定',
      language: '言語',
    },
  };

  constructor(private configService: ConfigService) {}

  translate(key: string, lang?: string): string {
    const language = lang || this.configService.get('DEFAULT_LANGUAGE', 'zh-CN');
    return this.translations[language]?.[key] || key;
  }

  translateMultiple(keys: string[], lang?: string): Record<string, string> {
    const language = lang || this.configService.get('DEFAULT_LANGUAGE', 'zh-CN');
    const result: Record<string, string> = {};
    
    for (const key of keys) {
      result[key] = this.translate(key, language);
    }
    
    return result;
  }

  getSupportedLanguages(): { code: string; name: string }[] {
    return [
      { code: 'zh-CN', name: '简体中文' },
      { code: 'zh-TW', name: '繁體中文' },
      { code: 'en-US', name: 'English' },
      { code: 'ja-JP', name: '日本語' },
      { code: 'ko-KR', name: '한국어' },
    ];
  }

  detectLanguage(acceptLanguage?: string): string {
    if (!acceptLanguage) {
      return this.configService.get('DEFAULT_LANGUAGE', 'zh-CN');
    }

    const lang = acceptLanguage.split(',')[0].split('-')[0];
    
    const langMap: Record<string, string> = {
      zh: 'zh-CN',
      en: 'en-US',
      ja: 'ja-JP',
      ko: 'ko-KR',
    };

    return langMap[lang] || this.configService.get('DEFAULT_LANGUAGE', 'zh-CN');
  }
}
