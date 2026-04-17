import type { Metadata, Viewport } from 'next';
import { NextIntlClientProvider } from 'next-intl';
import { getMessages } from 'next-intl/server';
import { Inter, Noto_Serif_SC, JetBrains_Mono } from 'next/font/google';
import { Header } from '@/components/layout/Header';
import { Footer } from '@/components/layout/Footer';
import { ToastProvider } from '@/components/ui/Toast';
import '@/styles/globals.css';

const inter = Inter({
  subsets: ['latin'],
  variable: '--font-sans',
});

const notoSerifSC = Noto_Serif_SC({
  subsets: ['latin'],
  weight: ['400', '700'],
  variable: '--font-serif',
});

const jetbrainsMono = JetBrains_Mono({
  subsets: ['latin'],
  variable: '--font-mono',
});

export const metadata: Metadata = {
  title: {
    default: '万卷书苑 - 10kBooks',
    template: '%s | 万卷书苑',
  },
  description: '最好的在线阅读平台，提供海量优质网络小说、文学作品，为读者打造沉浸式阅读体验。',
  keywords: ['小说', '阅读', '文学', '网络小说', '电子书', '读书'],
  authors: [{ name: '万卷书苑' }],
  creator: '万卷书苑',
  metadataBase: new URL('https://10kbooks.com'),
  openGraph: {
    type: 'website',
    locale: 'zh_CN',
    siteName: '万卷书苑',
    title: '万卷书苑 - 10kBooks',
    description: '最好的在线阅读平台',
  },
  twitter: {
    card: 'summary_large_image',
    title: '万卷书苑 - 10kBooks',
    description: '最好的在线阅读平台',
  },
  robots: {
    index: true,
    follow: true,
  },
  manifest: '/manifest.json',
  appleWebApp: {
    capable: true,
    statusBarStyle: 'default',
    title: '万卷书苑',
  },
};

export const viewport: Viewport = {
  themeColor: [
    { media: '(prefers-color-scheme: light)', color: '#0ea5e9' },
    { media: '(prefers-color-scheme: dark)', color: '#1a1a2e' },
  ],
  width: 'device-width',
  initialScale: 1,
  maximumScale: 1,
};

interface LocaleLayoutProps {
  children: React.ReactNode;
  params: { locale: string };
}

export default async function LocaleLayout({
  children,
  params: { locale },
}: LocaleLayoutProps) {
  const messages = await getMessages();

  return (
    <html
      lang={locale}
      className={`${inter.variable} ${notoSerifSC.variable} ${jetbrainsMono.variable}`}
      suppressHydrationWarning
    >
      <body className="min-h-screen bg-background antialiased">
        <NextIntlClientProvider messages={messages}>
          <ToastProvider>
            <div className="flex min-h-screen flex-col">
              <Header locale={locale} />
              <main className="flex-1">{children}</main>
              <Footer />
            </div>
          </ToastProvider>
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
