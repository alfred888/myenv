#!/usr/bin/env bash

echo "===== 🚀 启动 HTTP 测试服务器 ====="

# 颜色定义
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

# 使用 80 端口
PORT=80

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ 使用 80 端口需要 root 权限${NC}"
    echo -e "${YELLOW}请使用 sudo 运行此脚本：${NC}"
    echo -e "sudo $0"
    exit 1
fi

# 创建测试页面
create_test_page() {
    cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>测试服务器</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            line-height: 1.6;
        }
        .container {
            background-color: #f5f5f5;
            border-radius: 8px;
            padding: 20px;
            margin-top: 20px;
        }
        .info {
            background-color: #e3f2fd;
            padding: 15px;
            border-radius: 4px;
            margin: 10px 0;
        }
        .success {
            color: #4caf50;
        }
        .warning {
            color: #ff9800;
        }
    </style>
</head>
<body>
    <h1>🚀 HTTP 测试服务器</h1>
    <div class="container">
        <h2>服务器信息</h2>
        <div class="info">
            <p><strong>状态：</strong><span class="success">运行中</span></p>
            <p><strong>时间：</strong><span id="current-time"></span></p>
            <p><strong>客户端 IP：</strong><span id="client-ip">获取中...</span></p>
        </div>
    </div>
    <script>
        // 更新时间
        function updateTime() {
            document.getElementById('current-time').textContent = new Date().toLocaleString();
        }
        updateTime();
        setInterval(updateTime, 1000);

        // 获取客户端 IP
        fetch('https://api.ipify.org?format=json')
            .then(response => response.json())
            .then(data => {
                document.getElementById('client-ip').textContent = data.ip;
            })
            .catch(() => {
                document.getElementById('client-ip').textContent = '无法获取';
            });
    </script>
</body>
</html>
EOF
}

# 检查端口是否被占用
check_port() {
    if command -v lsof >/dev/null 2>&1; then
        lsof -i :$PORT >/dev/null 2>&1
    elif command -v netstat >/dev/null 2>&1; then
        netstat -tuln | grep -q ":$PORT "
    else
        return 0
    fi
    return $?
}

# 启动服务器
start_server() {
    # 检查端口
    if check_port; then
        echo -e "${RED}❌ 端口 $PORT 已被占用${NC}"
        echo -e "${YELLOW}请检查是否有其他 Web 服务器（如 Apache、Nginx）正在运行${NC}"
        exit 1
    fi

    # 创建测试页面
    create_test_page
    echo -e "${GREEN}✅ 测试页面已创建${NC}"

    # 尝试使用 Python 启动服务器
    if command -v python3 >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 使用 Python 启动服务器${NC}"
        echo -e "${YELLOW}📝 访问地址：http://localhost${NC}"
        python3 -m http.server $PORT
    # 如果 Python 不可用，尝试使用 Node.js
    elif command -v node >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 使用 Node.js 启动服务器${NC}"
        echo -e "${YELLOW}📝 访问地址：http://localhost${NC}"
        npx http-server -p $PORT
    else
        echo -e "${RED}❌ 未找到 Python 或 Node.js，无法启动服务器${NC}"
        exit 1
    fi
}

# 启动服务器
start_server