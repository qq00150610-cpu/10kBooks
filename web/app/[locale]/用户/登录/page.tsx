'use client';

import * as React from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter } from '@/components/ui/Card';
import { Tabs, TabsList, TabsTrigger } from '@/components/ui/Tabs';
import { Avatar } from '@/components/ui/Avatar';
import { useAuthStore } from '@/lib/store';
import {
  Mail,
  Lock,
  User,
  Phone,
  Eye,
  EyeOff,
  Send,
  Chrome,
  Github,
  BookMarked,
} from 'lucide-react';
import { cn } from '@/lib/utils';

type LoginType = 'email' | 'phone' | 'code';

export default function LoginPage() {
  const router = useRouter();
  const { login } = useAuthStore();

  const [loginType, setLoginType] = React.useState<LoginType>('email');
  const [isLoading, setIsLoading] = React.useState(false);
  const [showPassword, setShowPassword] = React.useState(false);
  const [formData, setFormData] = React.useState({
    email: '',
    phone: '',
    password: '',
    code: '',
    username: '',
    confirmPassword: '',
  });
  const [errors, setErrors] = React.useState<Record<string, string>>({});

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
    setErrors((prev) => ({ ...prev, [name]: '' }));
  };

  const validateForm = () => {
    const newErrors: Record<string, string> = {};

    if (loginType === 'email') {
      if (!formData.email) {
        newErrors.email = '请输入邮箱地址';
      } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
        newErrors.email = '请输入有效的邮箱地址';
      }
      if (!formData.password) {
        newErrors.password = '请输入密码';
      }
    } else if (loginType === 'phone') {
      if (!formData.phone) {
        newErrors.phone = '请输入手机号';
      } else if (!/^1[3-9]\d{9}$/.test(formData.phone)) {
        newErrors.phone = '请输入有效的手机号';
      }
      if (!formData.password) {
        newErrors.password = '请输入密码';
      }
    } else if (loginType === 'code') {
      if (!formData.phone) {
        newErrors.phone = '请输入手机号';
      } else if (!/^1[3-9]\d{9}$/.test(formData.phone)) {
        newErrors.phone = '请输入有效的手机号';
      }
      if (!formData.code) {
        newErrors.code = '请输入验证码';
      }
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!validateForm()) return;

    setIsLoading(true);
    try {
      // Mock login
      await new Promise((resolve) => setTimeout(resolve, 1500));
      
      login(
        {
          id: '1',
          username: formData.email.split('@')[0] || 'user',
          email: formData.email || 'user@example.com',
          avatar: 'https://picsum.photos/seed/user/100/100',
          role: 'user',
          vipLevel: 0,
          createdAt: new Date().toISOString(),
          stats: { followers: 0, following: 0, books: 0, chapters: 0 },
        },
        'mock-token'
      );

      router.push('/');
    } catch (error) {
      console.error('Login failed:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleSendCode = async () => {
    if (!formData.phone || !/^1[3-9]\d{9}$/.test(formData.phone)) {
      setErrors((prev) => ({ ...prev, phone: '请输入有效的手机号' }));
      return;
    }
    // Mock send code
    await new Promise((resolve) => setTimeout(resolve, 1000));
    alert('验证码已发送');
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary/10 via-background to-secondary/10 py-12 px-4">
      <div className="w-full max-w-md">
        {/* Logo */}
        <div className="text-center mb-8">
          <Link href="/" className="inline-flex items-center gap-2">
            <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-gradient-to-br from-primary to-secondary text-white shadow-lg">
              <BookMarked className="h-8 w-8" />
            </div>
            <span className="text-2xl font-bold gradient-text">万卷书苑</span>
          </Link>
          <p className="mt-2 text-muted-foreground">登录开启你的阅读之旅</p>
        </div>

        <Card className="shadow-xl">
          <CardHeader className="space-y-1">
            <CardTitle className="text-2xl text-center">欢迎回来</CardTitle>
            <CardDescription className="text-center">
              选择登录方式开始探索
            </CardDescription>
          </CardHeader>
          <CardContent>
            {/* Login Type Tabs */}
            <Tabs defaultValue="email" onValueChange={(v) => setLoginType(v as LoginType)}>
              <TabsList className="grid w-full grid-cols-3">
                <TabsTrigger value="email">邮箱</TabsTrigger>
                <TabsTrigger value="phone">手机</TabsTrigger>
                <TabsTrigger value="code">验证码</TabsTrigger>
              </TabsList>
            </Tabs>

            <form onSubmit={handleSubmit} className="mt-6 space-y-4">
              {/* Email Login */}
              {loginType === 'email' && (
                <>
                  <div className="space-y-2">
                    <label className="text-sm font-medium">邮箱</label>
                    <Input
                      type="email"
                      name="email"
                      placeholder="请输入邮箱"
                      value={formData.email}
                      onChange={handleInputChange}
                      error={errors.email}
                      leftIcon={<Mail className="h-5 w-5" />}
                    />
                  </div>
                  <div className="space-y-2">
                    <label className="text-sm font-medium">密码</label>
                    <Input
                      type={showPassword ? 'text' : 'password'}
                      name="password"
                      placeholder="请输入密码"
                      value={formData.password}
                      onChange={handleInputChange}
                      error={errors.password}
                      leftIcon={<Lock className="h-5 w-5" />}
                      rightIcon={
                        <button
                          type="button"
                          onClick={() => setShowPassword(!showPassword)}
                          className="text-muted-foreground hover:text-foreground"
                        >
                          {showPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
                        </button>
                      }
                    />
                  </div>
                </>
              )}

              {/* Phone Login */}
              {loginType === 'phone' && (
                <>
                  <div className="space-y-2">
                    <label className="text-sm font-medium">手机号</label>
                    <Input
                      type="tel"
                      name="phone"
                      placeholder="请输入手机号"
                      value={formData.phone}
                      onChange={handleInputChange}
                      error={errors.phone}
                      leftIcon={<Phone className="h-5 w-5" />}
                    />
                  </div>
                  <div className="space-y-2">
                    <label className="text-sm font-medium">密码</label>
                    <Input
                      type={showPassword ? 'text' : 'password'}
                      name="password"
                      placeholder="请输入密码"
                      value={formData.password}
                      onChange={handleInputChange}
                      error={errors.password}
                      leftIcon={<Lock className="h-5 w-5" />}
                      rightIcon={
                        <button
                          type="button"
                          onClick={() => setShowPassword(!showPassword)}
                          className="text-muted-foreground hover:text-foreground"
                        >
                          {showPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
                        </button>
                      }
                    />
                  </div>
                </>
              )}

              {/* Code Login */}
              {loginType === 'code' && (
                <>
                  <div className="space-y-2">
                    <label className="text-sm font-medium">手机号</label>
                    <Input
                      type="tel"
                      name="phone"
                      placeholder="请输入手机号"
                      value={formData.phone}
                      onChange={handleInputChange}
                      error={errors.phone}
                      leftIcon={<Phone className="h-5 w-5" />}
                    />
                  </div>
                  <div className="space-y-2">
                    <label className="text-sm font-medium">验证码</label>
                    <div className="flex gap-2">
                      <Input
                        type="text"
                        name="code"
                        placeholder="请输入验证码"
                        value={formData.code}
                        onChange={handleInputChange}
                        error={errors.code}
                        leftIcon={<Lock className="h-5 w-5" />}
                      />
                      <Button type="button" variant="outline" onClick={handleSendCode}>
                        获取验证码
                      </Button>
                    </div>
                  </div>
                </>
              )}

              <div className="flex items-center justify-between text-sm">
                <label className="flex items-center gap-2">
                  <input type="checkbox" className="rounded border-muted" />
                  <span className="text-muted-foreground">记住我</span>
                </label>
                <Link href="/forgot-password" className="text-primary hover:underline">
                  忘记密码？
                </Link>
              </div>

              <Button type="submit" className="w-full" size="lg" isLoading={isLoading}>
                登录
              </Button>
            </form>

            {/* Divider */}
            <div className="relative my-6">
              <div className="absolute inset-0 flex items-center">
                <div className="w-full border-t" />
              </div>
              <div className="relative flex justify-center text-xs uppercase">
                <span className="bg-background px-2 text-muted-foreground">
                  其他登录方式
                </span>
              </div>
            </div>

            {/* Social Login */}
            <div className="grid grid-cols-2 gap-4">
              <Button variant="outline" disabled>
                <Chrome className="h-5 w-5 mr-2" />
                谷歌
              </Button>
              <Button variant="outline" disabled>
                <Github className="h-5 w-5 mr-2" />
                GitHub
              </Button>
            </div>
          </CardContent>
          <CardFooter className="flex flex-col space-y-2">
            <p className="text-sm text-muted-foreground text-center">
              还没有账号？{' '}
              <Link href="/register" className="text-primary hover:underline">
                立即注册
              </Link>
            </p>
          </CardFooter>
        </Card>

        <p className="mt-4 text-xs text-muted-foreground text-center">
          登录即表示同意{' '}
          <Link href="/terms" className="underline">
            服务条款
          </Link>{' '}
          和{' '}
          <Link href="/privacy" className="underline">
            隐私政策
          </Link>
        </p>
      </div>
    </div>
  );
}
