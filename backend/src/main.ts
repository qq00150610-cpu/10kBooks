import { NestFactory } from '@nestjs/core';
import { ValidationPipe, VersioningType } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import { IoAdapter } from '@nestjs/platform-socket.io';
import { AppModule } from './app.module';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import { TransformInterceptor } from './common/interceptors/transform.interceptor';
import { LoggingInterceptor } from './common/interceptors/logging.interceptor';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  const configService = app.get(ConfigService);

  // 全局前缀
  app.setGlobalPrefix('api/v1', {
    exclude: ['health', 'docs'],
  });

  // API版本控制
  app.enableVersioning({
    type: VersioningType.URI,
    defaultVersion: '1',
    prefix: 'v',
  });

  // CORS配置
  app.enableCors({
    origin: true,
    credentials: true,
  });

  // 全局管道 - 参数验证
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  // 全局过滤器 - 异常处理
  app.useGlobalFilters(new HttpExceptionFilter());

  // 全局拦截器 - 响应格式化
  app.useGlobalInterceptors(new TransformInterceptor());

  // 全局拦截器 - 日志
  app.useGlobalInterceptors(new LoggingInterceptor());

  // Swagger文档配置
  const swaggerConfig = new DocumentBuilder()
    .setTitle('万卷书苑 API')
    .setDescription('10kBooks - 多语言在线阅读平台 API 文档')
    .setVersion('1.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        name: 'JWT',
        description: 'Enter JWT token',
        in: 'header',
      },
      'JWT-auth',
    )
    .addApiKey(
      { type: 'apiKey', name: 'X-API-Key', in: 'header' },
      'api-key',
    )
    .addTag('auth', '认证相关接口')
    .addTag('user', '用户相关接口')
    .addTag('author', '作者相关接口')
    .addTag('book', '书籍相关接口')
    .addTag('reader', '阅读器相关接口')
    .addTag('social', '社交相关接口')
    .addTag('payment', '支付相关接口')
    .addTag('vip', 'VIP会员相关接口')
    .addTag('notification', '通知相关接口')
    .addTag('ai', 'AI功能相关接口')
    .addTag('admin', '后台管理接口')
    .build();

  const document = SwaggerModule.createDocument(app, swaggerConfig);
  SwaggerModule.setup('docs', app, document, {
    swaggerOptions: {
      persistAuthorization: true,
    },
    customSiteTitle: '万卷书苑 API 文档',
  });

  const port = configService.get<number>('PORT') || 3000;
  await app.listen(port);

  console.log(`🏠 万卷书苑后端服务已启动: http://localhost:${port}`);
  console.log(`📚 API文档地址: http://localhost:${port}/docs`);
  console.log(`🔧 健康检查: http://localhost:${port}/health`);
}

bootstrap();
