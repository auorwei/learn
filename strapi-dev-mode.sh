#!/bin/bash

# Strapi 开发模式切换脚本

case "${1:-help}" in
  "start"|"dev")
    echo "🔧 启动 Strapi 开发模式..."
    
    # 备份数据库
    echo "📦 备份数据库..."
    docker exec strapi-postgres pg_dump -U strapi_prod strapi_prod > "backup_$(date +%Y%m%d_%H%M%S).sql"
    
    # 停止生产环境
    echo "⏹️ 停止生产环境..."
    docker compose -f docker-compose.prod.yml down
    
    # 启动开发模式
    echo "🚀 启动开发模式..."
    echo "访问: http://your-domain.com:1337/admin"
    echo "按 Ctrl+C 退出开发模式"
    
    docker compose -f docker-compose.prod.yml run --rm \
      -e NODE_ENV=development \
      -p 1337:1337 \
      strapi npm run develop
    
    # 用户退出后自动恢复生产模式
    echo "🔄 恢复生产模式..."
    docker compose -f docker-compose.prod.yml up -d
    echo "✅ 已恢复生产模式"
    ;;
    
  "prod"|"production")
    echo "🚀 恢复生产模式..."
    docker compose -f docker-compose.prod.yml up -d
    echo "✅ 生产模式已启动"
    ;;
    
  "status")
    echo "📊 当前状态:"
    docker compose -f docker-compose.prod.yml ps
    ;;
    
  "help"|*)
    echo "Strapi 模式切换工具"
    echo "用法: $0 [命令]"
    echo ""
    echo "命令:"
    echo "  start, dev     - 启动开发模式（可编辑内容类型）"
    echo "  prod          - 恢复生产模式"
    echo "  status        - 查看当前状态"
    echo "  help          - 显示此帮助"
    echo ""
    echo "示例:"
    echo "  $0 dev        # 进入开发模式"
    echo "  $0 prod       # 恢复生产模式"
    ;;
esac
