'use client';

import * as React from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter } from '@/components/ui/Card';
import { Tabs, TabsList, TabsTrigger } from '@/components/ui/Tabs';
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
  CheckCircle,
} from 'lucide-react';

export default function RegisterPage() {
  const router = useRouter();
  const { login } = useAuthStore();

  const [isLoading, setIsLoading] = React.useState(false);
  const [showPassword, setShowPassword] = React.useState(false);
  const [step, setStep] = React.useState(1);
  const [agreed, setAgreed] = React.useState(false);
  const [formData, setFormData] = React.useState({
    username: '',
    email: '',
    phone: '',
    password: '',
    confirmPassword: '',
    code: '',
  });
  const [errors, setErrors] = React.useState<Record<string, string>>({});
  const [successMessage, setSuccessMessage] = React.useState('');

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
    setErrors((prev) => ({ ...prev, [name]: '' }));
  };

  const validateStep1 = () => {
    const newErrors: Record<string, string> = {};

    if (!formData.username) {
      newErrors.username = '请输入用户名';
    } else if (formData.username.length < 3) {
      newErrors.username = '用户名至少3个字符';
    }

    if (!formData.email) {
      newErrors.email = '请输入邮箱';
    } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
      newErrors.email = '请输入有效的邮箱';
    }

    if (!agreed) {
      newErrors.agreed = '请同意服务条款和隐私政策';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const validateStep2 = () => {
    const newErrors: Record<string, string> = {};

    if (!formData.password) {
      newErrors.password = '请输入密码';
    } else if (formData.password.length < 6) {
      newErrors.password = '密码至少6个字符';
    }

    if (formData.password !== formData.confirmPassword) {
      newErrors.confirmPassword = '两次密码输入不一致';
    }

    if (!formData.code) {
      newErrors.code = '请输入验证码';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSendCode = async () => {
    if (!formData.email || !/\S+@\S+\.\S+/.test(formData.email)) {
      setErrors((prev) => ({ ...prev, email: '请输入有效的邮箱' }));
      return;
    }
    await new Promise((resolve) => setTimeout(resolve, 1000));
    alert('验证码已发送到您的邮箱');
  };

  const handleNextStep = () => {
    if (validateStep1()) {
      setStep(2);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!validateStep2()) return;

    setIsLoading(true);
    try {
      await new Promise((resolve) => setTimeout(resolve, 1500));
      
      login(
        {
          id: '1',
          username: formData.username,
          email: formData.email,
          avatar: 'https://picsum.photos/seed/user/100/100',
          role: 'user',
          vipLevel: 0,
          createdAt: new Date().toISOString(),
          stats: { followers: 0, following: 0, books: 0, chapters: 0 },
        },
        'mock-token'
      );

      setSuccessMessage('注册成功！正在跳转...');
      setTimeout(() => {
        router.push('/');
      }, 1500);
    } catch (error) {
      console.error('Registration failed:', error);
    } finally {
      setIsLoading(false);
    }
  };

  if (successMessage) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary/10 via-background to-secondary/10 py-12 px-4">
        <Card className="max-w-md w-full text-center">
          <CardContent className="pt-12 pb-8">
            <div className="mx-auto w-20 h-20 rounded-full bg-green-100 flex items-center justify-center mb-6">
              <CheckCircle className="h-10 w-10 text-green-500" />
            </div>
            <h2 className="text-2xl font-bold mb-2">注册成功</h2>
            <p className="text-muted-foreground">{successMessage}</p>
          </CardContent>
        </Card>
      </div>
    );
  }

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
          <p className="mt-2 text-muted-foreground">创建账号开始阅读之旅</p>
        </div>

        <Card className="shadow-xl">
          <CardHeader className="space-y-1">
            <CardTitle className="text-2xl text-center">注册账号</CardTitle>
            <CardDescription className="text-center">
              步骤 {step} / 2：{step === 1 ? '填写基本信息' : '设置密码'}
            </CardDescription>
          </CardHeader>
          <CardContent>
            {/* Progress */}
            <div className="mb-6">
              <div className="h-2 bg-muted rounded-full overflow-hidden">
                <div
                  className="h-full bg-primary transition-all duration-300"
                  style={{ width: `${step * 50}%` }}
                />
              </div>
            </div>

            <form onSubmit={step === 1 ? (e) => { e.preventDefault(); handleNextStep(); } : handleSubmit} className="space-y-4">
              {step === 1 && (
                <>
                  <div className="space-y-2">
                    <label className="text-sm font-medium">用户名</label>
                    <Input
                      type="text"
                      name="username"
                      placeholder="请输入用户名"
                      value={formData.username}
                      onChange={handleInputChange}
                      error={errors.username}
                      leftIcon={<User className="h-5 w-5" />}
                    />
                    <p className="text-xs text-muted-foreground">3-20个字符，可包含字母、数字、下划线</p>
                  </div>
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
                  <div className="flex items-start gap-2">
                    <input
                      type="checkbox"
                      id="agreement"
                      checked={agreed}
                      onChange={(e) => setAgreed(e.target.checked)}
                      className="mt-1 rounded border-muted"
                    />
                    <label htmlFor="agreement" className="text-sm text-muted-foreground">
                      我已阅读并同意{' '}
                      <Link href="/terms" className="text-primary hover:underline">
                        服务条款
                      </Link>{' '}
                      和{' '}
                      <Link href="/privacy" className="text-primary hover:underline">
                        隐私政策
                      </Link>
                    </label>
                  </div>
                  {errors.agreed && (
                    <p className="text-sm text-destructive">{errors.agreed}</p>
                  )}
                  <Button type="submit" className="w-full" size="lg">
                    下一步
                  </Button>
                </>
              )}

              {step === 2 && (
                <>
                  <div className="p-4 bg-muted/50 rounded-lg">
                    <p className="text-sm">
                      <span className="font-medium">用户名：</span>{formData.username}
                    </p>
                    <p className="text-sm">
                      <span className="font-medium">邮箱：</span>{formData.email}
                    </p>
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
                    <p className="text-xs text-muted-foreground">至少6个字符，建议包含字母和数字</p>
                  </div>
                  <div className="space-y-2">
                    <label className="text-sm font-medium">确认密码</label>
                    <Input
                      type={showPassword ? 'text' : 'password'}
                      name="confirmPassword"
                      placeholder="请再次输入密码"
                      value={formData.confirmPassword}
                      onChange={handleInputChange}
                      error={errors.confirmPassword}
                      leftIcon={<Lock className="h-5 w-5" />}
                    />
                  </div>
                  <div className="space-y-2">
                    <label className="text-sm font-medium">邮箱验证码</label>
                    <div className="flex gap-2">
                      <Input
                        type="text"
                        name="code"
                        placeholder="请输入验证码"
                        value={formData.code}
                        onChange={handleInputChange}
                        error={errors.code}
                        leftIcon={<Send className="h-5 w-5" />}
                      />
                      <Button type="button" variant="outline" onClick={handleSendCode}>
                        获取验证码
                      </Button>
                    </div>
                  </div>
                  <div className="flex gap-3">
                    <Button
                      type="button"
                      variant="outline"
                      className="flex-1"
                      onClick={() => setStep(1)}
                    >
                      上一步
                    </Button>
                    <Button type="submit" className="flex-1" isLoading={isLoading}>
                      完成注册
                    </Button>
                  </div>
                </>
              )}
            </form>
          </CardContent>
          <CardFooter className="flex flex-col space-y-2">
            <p className="text-sm text-muted-foreground text-center">
              已有账号？{' '}
              <Link href="/login" className="text-primary hover:underline">
                立即登录
              </Link>
            </p>
          </CardFooter>
        </Card>
      </div>
    </div>
  );
}
