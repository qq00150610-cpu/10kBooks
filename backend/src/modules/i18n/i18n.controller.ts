import { Controller, Get, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { I18nService } from './i18n.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentLanguage } from '../../common/decorators/param.decorators';
import { Public } from '../../common/decorators/auth.decorators';
import { ApiGroup } from '../../common/decorators/api.decorators';

@ApiTags('多语言')
@ApiGroup('i18n')
@Controller({ path: 'i18n', version: '1' })
export class I18nController {
  constructor(private readonly i18nService: I18nService) {}

  @Get('languages')
  @Public()
  @ApiOperation({ summary: '获取支持的语言列表' })
  async getSupportedLanguages() {
    return this.i18nService.getSupportedLanguages();
  }

  @Get('translate/:key')
  @Public()
  @ApiOperation({ summary: '翻译单个词条' })
  async translate(
    @Param('key') key: string,
    @Query('lang') lang?: string,
  ) {
    return { key, translation: this.i18nService.translate(key, lang) };
  }

  @Get('translate')
  @Public()
  @ApiOperation({ summary: '批量翻译' })
  async translateMultiple(
    @Query('keys') keys: string,
    @Query('lang') lang?: string,
  ) {
    const keyArray = keys.split(',');
    return this.i18nService.translateMultiple(keyArray, lang);
  }

  @Get('detect')
  @Public()
  @ApiOperation({ summary: '检测语言' })
  async detectLanguage(@Query('accept-language') acceptLanguage?: string) {
    const lang = this.i18nService.detectLanguage(acceptLanguage);
    return { detectedLanguage: lang };
  }
}
