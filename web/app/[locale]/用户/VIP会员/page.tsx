'use client';

import * as React from 'react';
import Link from 'next/link';
import { Button } from '@/components/ui/Button';
import { Card, CardContent, CardHeader, CardTitle, CardDescription, CardFooter } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { Avatar } from '@/components/ui/Avatar';
import { Crown, Check, Zap, Star, Gift, Clock, Shield, Sparkles } from 'lucide-react';
import { cn } from '@/lib/utils';

const VIP_BENEFITS = [
  { icon: BookOpen, title: '免费阅读', desc: 'VIP专属书籍免费读' },
  { icon: Zap, title: '抢先看', desc: '最新章节提前阅读' },
  { icon: Gift, title: '专属书单', desc: '创建私人收藏夹' },
  { icon: Shield, title: '无广告', desc: '清爽阅读体验' },
  { icon: Star, title: '专属标识', desc: 'VIP专属头像框' },
  { icon: Clock, title: '优先客服', desc: '专属客服通道' },
];

const VIP_PLANS = [
  {
    id: 'monthly',
    name: '月度会员',
    price: 30,
    originalPrice: 50,
    period: '1个月',
    dailyCost: 1,
    features: [
      'VIP书籍免费读',
      '新章节提前看3天',
      '去除广告',
      '专属头像框',
    ],
    popular: false,
  },
  {
    id: 'quarterly',
    name: '季度会员',
    price: 80,
    originalPrice: 150,
    period: '3个月',
    dailyCost: 0.89,
    features: [
      'VIP书籍免费读',
      '新章节提前看7天',
      '去除广告',
      '专属头像框',
      '每月100书币',
    ],
    popular: true,
  },
  {
    id: 'yearly',
    name: '年度会员',
    price: 268,
    originalPrice: 600,
    period: '12个月',
    dailyCost: 0.73,
    features: [
      'VIP书籍免费读',
      '新章节提前看14天',
      '去除广告',
      '专属头像框',
      '每月200书币',
      '专属客服',
    ],
    popular: false,
  },
  {
    id: 'permanent',
    name: '永久会员',
    price: 998,
    originalPrice: null,
    period: '永久有效',
    dailyCost: 0,
    features: [
      'VIP书籍免费读',
      '新章节提前30天',
      '去除广告',
      '专属头像框',
      '每月500书币',
      '专属客服',
      '专属称号',
      '生日礼包',
    ],
    popular: false,
  },
];

export default function VIPPage() {
  const [selectedPlan, setSelectedPlan] = React.useState('quarterly');
  const [isProcessing, setIsProcessing] = React.useState(false);

  const handleSubscribe = async () => {
    setIsProcessing(true);
    // Mock payment process
    await new Promise((resolve) => setTimeout(resolve, 2000));
    setIsProcessing(false);
    alert('支付成功！您已成为VIP会员');
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-amber-50 via-background to-orange-50">
      {/* Hero */}
      <div className="relative overflow-hidden bg-gradient-to-r from-amber-500 via-orange-500 to-amber-500 text-white">
        <div className="absolute inset-0 bg-[url('/images/pattern.png')] opacity-10" />
        <div className="container mx-auto px-4 py-16 relative">
          <div className="text-center max-w-2xl mx-auto">
            <div className="inline-flex items-center gap-2 rounded-full bg-white/20 px-4 py-1.5 mb-6">
              <Crown className="h-5 w-5" />
              <span className="font-medium">VIP会员</span>
            </div>
            <h1 className="text-4xl md:text-5xl font-bold mb-4">
              尊享特权，阅读无界
            </h1>
            <p className="text-lg text-white/80">
              成为VIP会员，享受海量免费书籍、抢先阅读更新、无广告纯净体验
            </p>
          </div>
        </div>
      </div>

      {/* Benefits */}
      <div className="container mx-auto px-4 -mt-8">
        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-6 gap-4">
          {VIP_BENEFITS.map((benefit) => {
            const Icon = benefit.icon;
            return (
              <Card key={benefit.title} className="text-center hover:shadow-lg transition-shadow">
                <CardContent className="p-4">
                  <div className="w-12 h-12 rounded-full bg-amber-100 flex items-center justify-center mx-auto mb-3">
                    <Icon className="h-6 w-6 text-amber-600" />
                  </div>
                  <h3 className="font-semibold text-sm">{benefit.title}</h3>
                  <p className="text-xs text-muted-foreground mt-1">{benefit.desc}</p>
                </CardContent>
              </Card>
            );
          })}
        </div>
      </div>

      {/* Plans */}
      <div className="container mx-auto px-4 py-12">
        <h2 className="text-2xl font-bold text-center mb-8">选择您的会员套餐</h2>
        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
          {VIP_PLANS.map((plan) => (
            <Card
              key={plan.id}
              className={cn(
                'relative overflow-hidden transition-all',
                selectedPlan === plan.id
                  ? 'ring-2 ring-primary shadow-lg scale-[1.02]'
                  : 'hover:shadow-lg',
                plan.popular && 'border-primary'
              )}
              onClick={() => setSelectedPlan(plan.id)}
            >
              {plan.popular && (
                <div className="absolute top-0 right-0 bg-primary text-primary-foreground text-xs font-medium px-3 py-1 rounded-bl-lg">
                  推荐
                </div>
              )}
              <CardHeader className="text-center pb-2">
                <CardTitle className="text-lg">{plan.name}</CardTitle>
                <CardDescription>{plan.period}</CardDescription>
              </CardHeader>
              <CardContent className="text-center">
                <div className="mb-4">
                  <span className="text-4xl font-bold text-primary">¥{plan.price}</span>
                  {plan.originalPrice && (
                    <span className="text-muted-foreground line-through ml-2">
                      ¥{plan.originalPrice}
                    </span>
                  )}
                </div>
                {plan.dailyCost > 0 && (
                  <p className="text-xs text-muted-foreground mb-4">
                    每天仅需 ¥{plan.dailyCost.toFixed(2)}
                  </p>
                )}
                <div className="space-y-2 text-left">
                  {plan.features.map((feature) => (
                    <div key={feature} className="flex items-center gap-2 text-sm">
                      <Check className="h-4 w-4 text-green-500 shrink-0" />
                      <span>{feature}</span>
                    </div>
                  ))}
                </div>
              </CardContent>
              <CardFooter>
                <Button
                  className={cn('w-full', plan.popular ? '' : 'variant')}
                  variant={plan.popular ? 'default' : 'outline'}
                  onClick={() => setSelectedPlan(plan.id)}
                >
                  {selectedPlan === plan.id ? '已选择' : '选择'}
                </Button>
              </CardFooter>
            </Card>
          ))}
        </div>

        {/* Purchase Button */}
        <div className="mt-8 text-center">
          <Button
            size="lg"
            onClick={handleSubscribe}
            isLoading={isProcessing}
            className="bg-gradient-to-r from-amber-500 to-orange-500 hover:from-amber-600 hover:to-orange-600"
          >
            <Crown className="h-5 w-5 mr-2" />
            立即开通 ¥{VIP_PLANS.find((p) => p.id === selectedPlan)?.price}
          </Button>
          <p className="mt-2 text-sm text-muted-foreground">
            开通即表示同意
            <Link href="/terms" className="underline ml-1">VIP会员服务协议</Link>
          </p>
        </div>
      </div>

      {/* FAQ */}
      <div className="container mx-auto px-4 py-12">
        <h2 className="text-2xl font-bold text-center mb-8">常见问题</h2>
        <div className="max-w-2xl mx-auto space-y-4">
          {[
            {
              q: 'VIP会员可以看哪些书？',
              a: 'VIP会员可以免费阅读平台上标注为"VIP"的书籍，非VIP书籍需要单独购买。',
            },
            {
              q: '会员到期后，已购买的章节还能看吗？',
              a: '可以。会员期间购买的章节在会员到期后仍可正常阅读，不会受影响。',
            },
            {
              q: '如何取消自动续费？',
              a: '您可以在"我的-会员中心-自动续费"中关闭自动续费功能。关闭后，会员到期前不会再扣费。',
            },
            {
              q: '支持哪些支付方式？',
              a: '支持微信支付、支付宝、银联卡等主流支付方式。',
            },
          ].map((faq, index) => (
            <Card key={index}>
              <CardContent className="p-4">
                <h3 className="font-semibold mb-2">{faq.q}</h3>
                <p className="text-sm text-muted-foreground">{faq.a}</p>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>

      {/* Bottom CTA */}
      <div className="bg-gradient-to-r from-amber-500 to-orange-500 text-white py-12">
        <div className="container mx-auto px-4 text-center">
          <Sparkles className="h-12 w-12 mx-auto mb-4" />
          <h2 className="text-2xl font-bold mb-4">开启您的VIP阅读之旅</h2>
          <p className="text-white/80 mb-6">
            每天不到1块钱，海量好书免费看
          </p>
          <Button
            size="lg"
            variant="secondary"
            onClick={handleSubscribe}
            isLoading={isProcessing}
            className="bg-white text-orange-600 hover:bg-white/90"
          >
            立即开通VIP
          </Button>
        </div>
      </div>
    </div>
  );
}
