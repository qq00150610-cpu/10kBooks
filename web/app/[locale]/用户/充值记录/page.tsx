'use client';

import * as React from 'react';
import Link from 'next/link';
import { Button } from '@/components/ui/Button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Avatar } from '@/components/ui/Avatar';
import { Badge } from '@/components/ui/Badge';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/Tabs';
import { Pagination } from '@/components/ui/Pagination';
import { useAuthStore } from '@/lib/store';
import {
  Wallet,
  CreditCard,
  History,
  ArrowUpRight,
  ArrowDownRight,
  Gift,
  Coins,
  ChevronRight,
} from 'lucide-react';
import { formatNumber, formatDate, formatCurrency, cn } from '@/lib/utils';

const RECHARGE_PACKAGES = [
  { coins: 100, amount: 10, bonus: 0 },
  { coins: 500, amount: 50, bonus: 20 },
  { coins: 1000, amount: 100, bonus: 50 },
  { coins: 2000, amount: 200, bonus: 120 },
  { coins: 5000, amount: 500, bonus: 350 },
  { coins: 10000, amount: 1000, bonus: 800 },
];

const MOCK_RECHARGES = [
  { id: '1', amount: 100, coins: 150, method: '微信支付', status: 'completed', createdAt: '2024-01-21T10:30:00Z' },
  { id: '2', amount: 50, coins: 70, method: '支付宝', status: 'completed', createdAt: '2024-01-18T15:20:00Z' },
  { id: '3', amount: 200, coins: 320, method: '微信支付', status: 'completed', createdAt: '2024-01-15T09:00:00Z' },
];

const MOCK_CONSUMPTIONS = [
  { id: '1', type: 'book', targetName: '仙武帝尊 第51章', coins: 10, createdAt: '2024-01-21T08:00:00Z' },
  { id: '2', type: 'chapter', targetName: '都市逍遥医神 第120章', coins: 10, createdAt: '2024-01-20T20:00:00Z' },
  { id: '3', type: 'vip', targetName: '月度VIP会员', coins: 3000, createdAt: '2024-01-15T12:00:00Z' },
  { id: '4', type: 'book', targetName: '庆余年 全本', coins: 500, createdAt: '2024-01-10T14:00:00Z' },
];

export default function RechargePage() {
  const { user, isAuthenticated } = useAuthStore();
  const [selectedPackage, setSelectedPackage] = React.useState(RECHARGE_PACKAGES[2]);
  const [currentPage, setCurrentPage] = React.useState(1);

  if (!isAuthenticated) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <Wallet className="h-16 w-16 mx-auto text-muted-foreground mb-4" />
          <p className="text-muted-foreground mb-4">请先登录</p>
          <Button asChild>
            <Link href="/login">去登录</Link>
          </Button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-muted/30">
      <div className="container mx-auto px-4 py-8">
        <h1 className="text-2xl font-bold mb-6">我的钱包</h1>

        <div className="grid lg:grid-cols-3 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-2 space-y-6">
            {/* Balance Card */}
            <Card className="bg-gradient-to-r from-primary to-secondary text-white border-0">
              <CardContent className="p-6">
                <div className="flex items-center justify-between mb-4">
                  <div>
                    <p className="text-white/70 text-sm">我的余额</p>
                    <p className="text-4xl font-bold mt-1">2,580 书币</p>
                  </div>
                  <Button variant="secondary" className="bg-white/20 hover:bg-white/30 text-white border-0">
                    <Coins className="h-5 w-5 mr-2" />
                    充值
                  </Button>
                </div>
                <div className="flex gap-6">
                  <div>
                    <p className="text-white/70 text-sm">累计充值</p>
                    <p className="text-xl font-semibold">¥350</p>
                  </div>
                  <div>
                    <p className="text-white/70 text-sm">累计消费</p>
                    <p className="text-xl font-semibold">¥180</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Recharge Packages */}
            <Card>
              <CardHeader>
                <CardTitle>选择充值金额</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-3 gap-4">
                  {RECHARGE_PACKAGES.map((pkg) => (
                    <button
                      key={pkg.coins}
                      onClick={() => setSelectedPackage(pkg)}
                      className={cn(
                        'rounded-xl border-2 p-4 text-center transition-all',
                        selectedPackage.coins === pkg.coins
                          ? 'border-primary bg-primary/5'
                          : 'border-border hover:border-primary/50'
                      )}
                    >
                      <div className="flex items-center justify-center gap-1 mb-2">
                        <Coins className="h-5 w-5 text-amber-500" />
                        <span className="text-xl font-bold">{pkg.coins}</span>
                      </div>
                      <p className="text-sm text-muted-foreground">¥{pkg.amount}</p>
                      {pkg.bonus > 0 && (
                        <Badge variant="success" className="mt-2">
                          +{pkg.bonus}赠送
                        </Badge>
                      )}
                    </button>
                  ))}
                </div>

                {/* Selected Summary */}
                <div className="mt-6 p-4 bg-muted/50 rounded-lg">
                  <div className="flex items-center justify-between mb-4">
                    <span>充值金额</span>
                    <span className="text-xl font-bold">¥{selectedPackage.amount}</span>
                  </div>
                  <div className="flex items-center justify-between mb-4">
                    <span>获得书币</span>
                    <span className="text-xl font-bold text-amber-600">
                      {selectedPackage.coins + selectedPackage.bonus}
                    </span>
                  </div>
                  <Button className="w-full" size="lg">
                    立即充值 ¥{selectedPackage.amount}
                  </Button>
                </div>

                {/* Payment Methods */}
                <div className="mt-6">
                  <p className="text-sm font-medium mb-3">支付方式</p>
                  <div className="flex gap-4">
                    {[
                      { id: 'wechat', name: '微信支付' },
                      { id: 'alipay', name: '支付宝' },
                      { id: 'card', name: '银行卡' },
                    ].map((method) => (
                      <button
                        key={method.id}
                        className={cn(
                          'flex-1 rounded-lg border p-3 text-center transition-all',
                          'hover:border-primary/50'
                        )}
                      >
                        <p className="text-sm font-medium">{method.name}</p>
                      </button>
                    ))}
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Transaction Records */}
            <Tabs defaultValue="recharge">
              <TabsList>
                <TabsTrigger value="recharge">充值记录</TabsTrigger>
                <TabsTrigger value="consumption">消费记录</TabsTrigger>
              </TabsList>

              <TabsContent value="recharge" className="mt-4">
                <Card>
                  <CardContent className="p-0">
                    <div className="divide-y">
                      {MOCK_RECHARGES.map((record) => (
                        <div
                          key={record.id}
                          className="flex items-center justify-between p-4"
                        >
                          <div className="flex items-center gap-3">
                            <div className="w-10 h-10 rounded-full bg-green-100 flex items-center justify-center">
                              <ArrowDownRight className="h-5 w-5 text-green-600" />
                            </div>
                            <div>
                              <p className="font-medium">充值 {record.coins} 书币</p>
                              <p className="text-sm text-muted-foreground">
                                {record.method} · {formatDate(record.createdAt)}
                              </p>
                            </div>
                          </div>
                          <div className="text-right">
                            <p className="font-medium text-green-600">+{record.coins}</p>
                            <p className="text-sm text-muted-foreground">
                              ¥{record.amount}
                            </p>
                          </div>
                        </div>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              </TabsContent>

              <TabsContent value="consumption" className="mt-4">
                <Card>
                  <CardContent className="p-0">
                    <div className="divide-y">
                      {MOCK_CONSUMPTIONS.map((record) => (
                        <div
                          key={record.id}
                          className="flex items-center justify-between p-4"
                        >
                          <div className="flex items-center gap-3">
                            <div className="w-10 h-10 rounded-full bg-red-100 flex items-center justify-center">
                              <ArrowUpRight className="h-5 w-5 text-red-600" />
                            </div>
                            <div>
                              <p className="font-medium">
                                {record.type === 'vip' ? 'VIP会员' : '购买'} {record.targetName}
                              </p>
                              <p className="text-sm text-muted-foreground">
                                {formatDate(record.createdAt)}
                              </p>
                            </div>
                          </div>
                          <div className="text-right">
                            <p className="font-medium text-red-600">-{record.coins}</p>
                          </div>
                        </div>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              </TabsContent>
            </Tabs>
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Quick Actions */}
            <Card>
              <CardHeader>
                <CardTitle className="text-base">快捷操作</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-2">
                  {[
                    { icon: Gift, label: '赠送书籍', href: '/gift' },
                    { icon: CreditCard, label: '提现', href: '/withdrawal' },
                    { icon: History, label: '交易明细', href: '/transactions' },
                  ].map((item) => {
                    const Icon = item.icon;
                    return (
                      <Link
                        key={item.href}
                        href={item.href}
                        className="flex items-center justify-between p-3 rounded-lg hover:bg-accent transition-colors"
                      >
                        <span className="flex items-center gap-3">
                          <Icon className="h-5 w-5 text-muted-foreground" />
                          <span>{item.label}</span>
                        </span>
                        <ChevronRight className="h-4 w-4 text-muted-foreground" />
                      </Link>
                    );
                  })}
                </div>
              </CardContent>
            </Card>

            {/* VIP Card */}
            <Card className="bg-gradient-to-br from-amber-500 to-orange-500 text-white border-0">
              <CardContent className="p-6">
                <div className="flex items-center gap-3 mb-4">
                  <Gift className="h-8 w-8" />
                  <div>
                    <p className="font-semibold">升级VIP会员</p>
                    <p className="text-sm text-white/70">享受更多特权</p>
                  </div>
                </div>
                <Button
                  variant="secondary"
                  className="w-full bg-white/20 hover:bg-white/30 text-white border-0"
                  asChild
                >
                  <Link href="/vip">立即开通</Link>
                </Button>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </div>
  );
}
