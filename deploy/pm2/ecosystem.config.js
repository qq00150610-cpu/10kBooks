# ============================================
# 万卷书苑 / 10kBooks - PM2 配置文件
# 多语言在线阅读平台 API 服务进程管理
# ============================================

module.exports = {
  apps: [
    {
      // ==========================================
      // API 服务
      // ==========================================
      name: '10kbooks-api',
      script: 'dist/main.js',
      cwd: './',
      
      // 实例配置
      instances: 'max',
      exec_mode: 'cluster',
      
      // 自动重启
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      
      // 启动配置
      args: '',
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      },
      
      // 日志配置
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      error_file: './logs/error.log',
      out_file: './logs/out.log',
      log_file: './logs/combined.log',
      time: true,
      
      // 监控
      source_map_support: true,
      
      // 进程键
      instance_var: 'INSTANCE_ID',
      
      // Graceful Shutdown
      kill_timeout: 5000,
      wait_ready: true,
      listen_timeout: 3000,
      
      // 进阶配置
      max_restarts: 10,
      min_uptime: '10s',
      restart_delay: 4000,
      
      // 健康检查
      health_check: {
        path: '/health',
        interval: 15000,
        timeout: 5000,
        retries: 3
      }
    },
    
    {
      // ==========================================
      // Worker 服务 - 定时任务
      // ==========================================
      name: '10kbooks-worker',
      script: 'dist/worker.js',
      cwd: './',
      
      instances: 1,
      exec_mode: 'fork',
      
      autorestart: true,
      watch: false,
      
      env: {
        NODE_ENV: 'production'
      },
      
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      error_file: './logs/worker-error.log',
      out_file: './logs/worker-out.log',
      log_file: './logs/worker-combined.log',
      time: true,
      
      kill_timeout: 5000,
      wait_ready: true,
      listen_timeout: 5000,
      
      max_restarts: 5,
      min_uptime: '30s',
      restart_delay: 5000
    },
    
    {
      // ==========================================
      // WebSocket 服务
      // ==========================================
      name: '10kbooks-websocket',
      script: 'dist/websocket.js',
      cwd: './',
      
      instances: 1,
      exec_mode: 'fork',
      
      autorestart: true,
      watch: false,
      
      env: {
        NODE_ENV: 'production'
      },
      
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      error_file: './logs/ws-error.log',
      out_file: './logs/ws-out.log',
      time: true,
      
      kill_timeout: 10000,
      wait_ready: true,
      listen_timeout: 5000
    }
  ],
  
  // ==========================================
  // 部署配置
  // ==========================================
  deploy: {
    production: {
      user: 'deploy',
      host: ['production.10kbooks.com'],
      ref: 'origin/main',
      repo: 'git@github.com:10kbooks/backend.git',
      path: '/var/www/10kbooks/api',
      'pre-deploy-local': '',
      'post-deploy': 'npm install && npm run build && pm2 restart 10kbooks-api && pm2 restart 10kbooks-worker',
      'pre-setup': ''
    },
    staging: {
      user: 'deploy',
      host: ['staging.10kbooks.com'],
      ref: 'origin/develop',
      repo: 'git@github.com:10kbooks/backend.git',
      path: '/var/www/10kbooks/staging',
      'pre-deploy-local': '',
      'post-deploy': 'npm install && npm run build && pm2 restart 10kbooks-api && pm2 restart 10kbooks-worker',
      'pre-setup': ''
    }
  }
};
