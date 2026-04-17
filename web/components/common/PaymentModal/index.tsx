'use client';

import * as React from 'react';
import { cn } from '@/lib/utils';
import { Button } from '@/components/ui/Button';
import { Modal, ModalFooter } from '@/components/ui/Modal';
import { Input } from '@/components/ui/Input';
import { RECHARGE_PACKAGES } from '@/lib/constants';
import { Coins, CreditCard, Smartphone, QrCode } from 'lucide-react';

interface PaymentModalProps {
  isOpen: boolean;
  onClose: () => void;
  amount: number;
  description?: string;
  onSuccess?: (paymentId: string) => void;
}

const PAYMENT_METHODS = [
  { id: 'wechat', name: '微信支付', icon: QrCode },
  { id: 'alipay', name: '支付宝', icon: Smartphone },
  { id: 'card', name: '银行卡', icon: CreditCard },
];

export function PaymentModal({
  isOpen,
  onClose,
  amount,
  description = '充值',
  onSuccess,
}: PaymentModalProps) {
  const [selectedPackage, setSelectedPackage] = React.useState(RECHARGE_PACKAGES[1]);
  const [selectedMethod, setSelectedMethod] = React.useState('wechat');
  const [isProcessing, setIsProcessing] = React.useState(false);
  const [showQrCode, setShowQrCode] = React.useState(false);

  const handlePayment = async () => {
    setIsProcessing(true);
    // Simulate payment process
    await new Promise((resolve) => setTimeout(resolve, 2000));
    setIsProcessing(false);
    setShowQrCode(false);
    onSuccess?.('payment_' + Date.now());
    onClose();
  };

  return (
    <Modal isOpen={isOpen} onClose={onClose} title="选择充值方式" size="md">
      <div className="space-y-6">
        {/* Selected Package */}
        <div className="rounded-lg bg-primary/10 p-4">
          <p className="text-sm text-muted-foreground">{description}</p>
          <p className="mt-1 text-2xl font-bold text-primary">
            ¥{selectedPackage.amount}
          </p>
          <p className="text-sm text-muted-foreground">
            获得 {selectedPackage.coins + selectedPackage.bonus} 书币
            {selectedPackage.bonus > 0 && (
              <span className="ml-2 text-green-600">+{selectedPackage.bonus}赠送</span>
            )}
          </p>
        </div>

        {/* Packages */}
        <div>
          <h4 className="mb-3 text-sm font-medium">选择套餐</h4>
          <div className="grid grid-cols-3 gap-2">
            {RECHARGE_PACKAGES.map((pkg) => (
              <button
                key={pkg.coins}
                onClick={() => setSelectedPackage(pkg)}
                className={cn(
                  'rounded-lg border p-3 text-center transition-all',
                  selectedPackage.coins === pkg.coins
                    ? 'border-primary bg-primary/5'
                    : 'border-border hover:border-primary/50'
                )}
              >
                <Coins className="mx-auto h-5 w-5 text-amber-500" />
                <p className="mt-1 font-semibold">{pkg.coins}</p>
                <p className="text-xs text-muted-foreground">¥{pkg.amount}</p>
              </button>
            ))}
          </div>
        </div>

        {/* Payment Methods */}
        <div>
          <h4 className="mb-3 text-sm font-medium">支付方式</h4>
          <div className="space-y-2">
            {PAYMENT_METHODS.map((method) => {
              const Icon = method.icon;
              return (
                <button
                  key={method.id}
                  onClick={() => setSelectedMethod(method.id)}
                  className={cn(
                    'flex w-full items-center gap-3 rounded-lg border p-3 transition-all',
                    selectedMethod === method.id
                      ? 'border-primary bg-primary/5'
                      : 'border-border hover:border-primary/50'
                  )}
                >
                  <Icon className="h-5 w-5" />
                  <span className="flex-1 text-left">{method.name}</span>
                  <div
                    className={cn(
                      'h-4 w-4 rounded-full border-2',
                      selectedMethod === method.id
                        ? 'border-primary bg-primary'
                        : 'border-muted-foreground'
                    )}
                  />
                </button>
              );
            })}
          </div>
        </div>

        {/* QR Code Area */}
        {showQrCode && (
          <div className="flex flex-col items-center justify-center rounded-lg bg-white p-6">
            <div className="h-48 w-48 rounded-lg border-2 border-dashed border-gray-300 flex items-center justify-center">
              <p className="text-sm text-gray-500">扫码支付</p>
            </div>
            <p className="mt-4 text-sm text-muted-foreground">
              请使用{PAYMENT_METHODS.find((m) => m.id === selectedMethod)?.name}扫码支付
            </p>
          </div>
        )}
      </div>

      <ModalFooter>
        <Button variant="outline" onClick={onClose}>
          取消
        </Button>
        <Button onClick={handlePayment} isLoading={isProcessing}>
          确认支付 ¥{selectedPackage.amount}
        </Button>
      </ModalFooter>
    </Modal>
  );
}
