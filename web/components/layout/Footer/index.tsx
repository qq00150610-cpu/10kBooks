import Link from 'next/link';
import { BookMarked, Github, Mail, Globe } from 'lucide-react';

const FOOTER_LINKS = {
  product: [
    { label: '关于我们', href: '/about' },
    { label: '作者入驻', href: '/author/join' },
    { label: '联系方式', href: '/contact' },
    { label: '帮助中心', href: '/help' },
  ],
  legal: [
    { label: '用户协议', href: '/terms' },
    { label: '隐私政策', href: '/privacy' },
    { label: '版权声明', href: '/copyright' },
    { label: '商务合作', href: '/business' },
  ],
  social: [
    { label: '官方微博', href: 'https://weibo.com/10kbooks' },
    { label: '官方微信', href: '/wechat' },
    { label: '读者QQ群', href: '/qqgroup' },
  ],
};

export function Footer() {
  return (
    <footer className="border-t bg-muted/50">
      <div className="container mx-auto px-4 py-12">
        <div className="grid grid-cols-1 gap-8 md:grid-cols-4">
          {/* Brand */}
          <div className="space-y-4">
            <Link href="/" className="flex items-center gap-2">
              <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-primary to-secondary text-white">
                <BookMarked className="h-6 w-6" />
              </div>
              <span className="text-xl font-bold gradient-text">万卷书苑</span>
            </Link>
            <p className="text-sm text-muted-foreground">
              打造最好的在线阅读平台，为读者提供优质的文学作品，为作者提供展示才华的舞台。
            </p>
            <div className="flex gap-4">
              <a
                href="#"
                className="rounded-full p-2 hover:bg-accent transition-colors"
                aria-label="Github"
              >
                <Github className="h-5 w-5" />
              </a>
              <a
                href="#"
                className="rounded-full p-2 hover:bg-accent transition-colors"
                aria-label="Mail"
              >
                <Mail className="h-5 w-5" />
              </a>
              <a
                href="#"
                className="rounded-full p-2 hover:bg-accent transition-colors"
                aria-label="Website"
              >
                <Globe className="h-5 w-5" />
              </a>
            </div>
          </div>

          {/* Product Links */}
          <div>
            <h4 className="font-semibold mb-4">产品</h4>
            <ul className="space-y-2">
              {FOOTER_LINKS.product.map((link) => (
                <li key={link.href}>
                  <Link
                    href={link.href}
                    className="text-sm text-muted-foreground hover:text-foreground transition-colors"
                  >
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Legal Links */}
          <div>
            <h4 className="font-semibold mb-4">法律</h4>
            <ul className="space-y-2">
              {FOOTER_LINKS.legal.map((link) => (
                <li key={link.href}>
                  <Link
                    href={link.href}
                    className="text-sm text-muted-foreground hover:text-foreground transition-colors"
                  >
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Social Links */}
          <div>
            <h4 className="font-semibold mb-4">关注我们</h4>
            <ul className="space-y-2">
              {FOOTER_LINKS.social.map((link) => (
                <li key={link.href}>
                  <a
                    href={link.href}
                    className="text-sm text-muted-foreground hover:text-foreground transition-colors"
                    target={link.href.startsWith('http') ? '_blank' : undefined}
                    rel={link.href.startsWith('http') ? 'noopener noreferrer' : undefined}
                  >
                    {link.label}
                  </a>
                </li>
              ))}
            </ul>
          </div>
        </div>

        <div className="mt-12 pt-8 border-t text-center">
          <p className="text-sm text-muted-foreground">
            © {new Date().getFullYear()} 万卷书苑 10kBooks. All rights reserved.
          </p>
        </div>
      </div>
    </footer>
  );
}
