#!/usr/bin/env bash

echo "===== 开发环境检测脚本 ====="
echo ""

# 颜色
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

# 检测是否为树莓派
is_raspberry_pi() {
    if [ -f /proc/device-tree/model ]; then
        grep -q "Raspberry Pi" /proc/device-tree/model
        return $?
    fi
    return 1
}

# 获取树莓派信息
get_raspberry_pi_info() {
    if is_raspberry_pi; then
        echo -e "\n${GREEN}=== 树莓派信息 ===${NC}"
        # 获取树莓派型号
        if [ -f /proc/device-tree/model ]; then
            echo -e "${GREEN}✅ 型号: $(cat /proc/device-tree/model)${NC}"
        fi
        
        # 获取 CPU 温度
        if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
            temp=$(cat /sys/class/thermal/thermal_zone0/temp)
            temp_c=$(echo "scale=1; $temp/1000" | bc)
            echo -e "${GREEN}✅ CPU 温度: ${temp_c}°C${NC}"
        fi
        
        # 获取内存信息
        if command -v free >/dev/null 2>&1; then
            total_mem=$(free -h | grep Mem | awk '{print $2}')
            used_mem=$(free -h | grep Mem | awk '{print $3}')
            echo -e "${GREEN}✅ 内存: ${used_mem}/${total_mem}${NC}"
        fi
        
        # 获取存储信息
        if command -v df >/dev/null 2>&1; then
            echo -e "${GREEN}✅ 存储空间:${NC}"
            df -h / | grep -v "Filesystem" | awk '{print "  - 总空间: " $2 "\n  - 已用: " $3 "\n  - 可用: " $4}'
        fi
    fi
}

# 静默加载环境变量
{
    # 禁用 Oh My Zsh 的自动更新提示
    DISABLE_AUTO_UPDATE="true"

    # 加载常见 shell 配置
    [ -f ~/.zshrc ] && source ~/.zshrc >/dev/null 2>&1
    [ -f ~/.zprofile ] && source ~/.zprofile >/dev/null 2>&1
    [ -f ~/.bashrc ] && source ~/.bashrc >/dev/null 2>&1

    # 检查 Homebrew 路径（macOS/Ubuntu）
    if [ -f "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)" >/dev/null 2>&1
    elif [ -f "/usr/local/bin/brew" ]; then
        eval "$(/usr/local/bin/brew shellenv)" >/dev/null 2>&1
    elif [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" >/dev/null 2>&1
    fi

    # 加载 nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" >/dev/null 2>&1

    # 加载 SDKMAN
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh" >/dev/null 2>&1
} >/dev/null 2>&1

# 显示系统信息
echo -e "${GREEN}=== 系统信息 ===${NC}"
# 操作系统信息
if is_raspberry_pi; then
    echo -e "${GREEN}✅ 设备: 树莓派${NC}"
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo -e "${GREEN}✅ 操作系统: $PRETTY_NAME${NC}"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "${GREEN}✅ 操作系统: macOS $(sw_vers -productVersion)${NC}"
elif [[ -f "/etc/lsb-release" ]]; then
    . /etc/lsb-release
    echo -e "${GREEN}✅ 操作系统: $DISTRIB_DESCRIPTION${NC}"
else
    echo -e "${GREEN}✅ 操作系统: $(uname -s)${NC}"
fi

# 主机名
echo -e "${GREEN}✅ 主机名: $(hostname)${NC}"

# 显示树莓派特定信息
get_raspberry_pi_info

# 显示网络信息
echo -e "\n${GREEN}=== 网络信息 ===${NC}"
# 显示本机 IP 地址
echo -e "${GREEN}✅ 本机 IP 地址:${NC}"
if is_raspberry_pi; then
    # 树莓派特定网络接口
    for interface in eth0 wlan0; do
        if ip addr show $interface >/dev/null 2>&1; then
            ip=$(ip addr show $interface | grep "inet " | awk '{print $2}')
            if [ ! -z "$ip" ]; then
                echo -e "  - $interface: $ip"
            fi
        fi
    done
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    for interface in $(networksetup -listallhardwareports | grep "Device:" | awk '{print $2}'); do
        ip=$(ipconfig getifaddr $interface 2>/dev/null)
        if [ ! -z "$ip" ]; then
            echo -e "  - $interface: $ip"
        fi
    done
else
    # Linux
    ip addr show | grep "inet " | grep -v "127.0.0.1" | awk '{print "  - " $2}'
fi

# 检查 SSH 服务状态
echo -e "\n${GREEN}=== SSH 服务 ===${NC}"
if command -v systemctl >/dev/null 2>&1; then
    if systemctl is-active ssh >/dev/null 2>&1; then
        echo -e "${GREEN}✅ SSH 服务: 运行中${NC}"
    else
        echo -e "${RED}❌ SSH 服务: 未运行${NC}"
    fi
elif command -v service >/dev/null 2>&1; then
    if service ssh status >/dev/null 2>&1; then
        echo -e "${GREEN}✅ SSH 服务: 运行中${NC}"
    else
        echo -e "${RED}❌ SSH 服务: 未运行${NC}"
    fi
else
    if ps aux | grep -v grep | grep -q "sshd"; then
        echo -e "${GREEN}✅ SSH 服务: 运行中${NC}"
    else
        echo -e "${RED}❌ SSH 服务: 未运行${NC}"
    fi
fi

# 检查 SSH 端口
if command -v lsof >/dev/null 2>&1; then
    if lsof -i :22 >/dev/null 2>&1; then
        echo -e "${GREEN}✅ SSH 端口 (22): 已监听${NC}"
    else
        echo -e "${RED}❌ SSH 端口 (22): 未监听${NC}"
    fi
elif command -v netstat >/dev/null 2>&1; then
    if netstat -tuln | grep -q ":22 "; then
        echo -e "${GREEN}✅ SSH 端口 (22): 已监听${NC}"
    else
        echo -e "${RED}❌ SSH 端口 (22): 未监听${NC}"
    fi
fi

# 检查 HTTP 服务状态
echo -e "\n${GREEN}=== HTTP 服务 ===${NC}"
check_http_service() {
    local service=$1
    local name=$2
    if command -v systemctl >/dev/null 2>&1; then
        if systemctl is-active $service >/dev/null 2>&1; then
            echo -e "${GREEN}✅ $name 服务: 运行中${NC}"
            return 0
        fi
    elif command -v service >/dev/null 2>&1; then
        if service $service status >/dev/null 2>&1; then
            echo -e "${GREEN}✅ $name 服务: 运行中${NC}"
            return 0
        fi
    else
        if ps aux | grep -v grep | grep -q "$service"; then
            echo -e "${GREEN}✅ $name 服务: 运行中${NC}"
            return 0
        fi
    fi
    return 1
}

# 检查 Apache 和 Nginx
check_http_service "apache2" "Apache"
check_http_service "httpd" "Apache"
check_http_service "nginx" "Nginx"

# 检查 HTTP 端口
if command -v lsof >/dev/null 2>&1; then
    if lsof -i :80 >/dev/null 2>&1; then
        echo -e "${GREEN}✅ HTTP 端口 (80): 已监听${NC}"
    else
        echo -e "${RED}❌ HTTP 端口 (80): 未监听${NC}"
    fi
    if lsof -i :443 >/dev/null 2>&1; then
        echo -e "${GREEN}✅ HTTPS 端口 (443): 已监听${NC}"
    else
        echo -e "${RED}❌ HTTPS 端口 (443): 未监听${NC}"
    fi
elif command -v netstat >/dev/null 2>&1; then
    if netstat -tuln | grep -q ":80 "; then
        echo -e "${GREEN}✅ HTTP 端口 (80): 已监听${NC}"
    else
        echo -e "${RED}❌ HTTP 端口 (80): 未监听${NC}"
    fi
    if netstat -tuln | grep -q ":443 "; then
        echo -e "${GREEN}✅ HTTPS 端口 (443): 已监听${NC}"
    else
        echo -e "${RED}❌ HTTPS 端口 (443): 未监听${NC}"
    fi
fi

# 原有的环境检查
echo -e "\n${GREEN}=== 开发环境 ===${NC}"

# 检查 Java
if command -v java >/dev/null 2>&1; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | sed 's/"//g')
    if [[ "$JAVA_VERSION" == *"Unable to locate a Java Runtime"* ]]; then
        echo -e "${RED}❌ Java: 未正确安装或环境变量未设置${NC}"
    else
        echo -e "${GREEN}✅ Java: $JAVA_VERSION${NC}"
    fi
else
    echo -e "${RED}❌ Java: 未安装${NC}"
fi

# 检查 Node.js
if command -v node >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Node.js: $(node --version)${NC}"
else
    echo -e "${RED}❌ Node.js: 未安装${NC}"
fi

# 检查 npm
if command -v npm >/dev/null 2>&1; then
    echo -e "${GREEN}✅ npm: $(npm --version)${NC}"
else
    echo -e "${RED}❌ npm: 未安装${NC}"
fi

# 检查 Maven
if command -v mvn >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Maven: $(mvn -v 2>/dev/null | head -n 1 | cut -d' ' -f1-3)${NC}"
else
    echo -e "${RED}❌ Maven: 未安装${NC}"
fi

# 检查 Python3
if command -v python3 >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Python3: $(python3 --version)${NC}"
else
    echo -e "${RED}❌ Python3: 未安装${NC}"
fi

# 检查 pip3
if command -v pip3 >/dev/null 2>&1; then
    echo -e "${GREEN}✅ pip3: $(pip3 --version)${NC}"
else
    echo -e "${RED}❌ pip3: 未安装${NC}"
fi

# 检查 nvm
if command -v nvm >/dev/null 2>&1; then
    echo -e "${GREEN}✅ nvm: $(nvm --version)${NC}"
else
    echo -e "${RED}❌ nvm: 未安装${NC}"
fi

# 检查当前 Shell
echo -e "${GREEN}✅ 当前 Shell: $SHELL${NC}"

# 检查 Python 虚拟环境
if [ -n "$VIRTUAL_ENV" ]; then
    echo -e "${GREEN}✅ Python 虚拟环境: $VIRTUAL_ENV${NC}"
else
    echo -e "${YELLOW}🔍 Python 虚拟环境: 未激活任何 Python 虚拟环境${NC}"
fi

# 检查 SDKMAN
if command -v sdk >/dev/null 2>&1; then
    SDK_VERSION=$(sdk version 2>/dev/null)
    if [ -n "$SDK_VERSION" ]; then
        echo -e "${GREEN}✅ SDKMAN: $SDK_VERSION${NC}"
    else
        echo -e "${RED}❌ SDKMAN: 已安装但未正确加载${NC}"
    fi
else
    echo -e "${RED}❌ SDKMAN: 未安装${NC}"
fi

echo ""
echo "提示："
echo "1. 如果某些工具显示未安装但你已经安装，请运行: source ~/.zshrc 或 source ~/.bashrc"
echo "2. 对于 Java 问题，请运行: sdk list java 查看可用版本，然后使用 sdk install java <版本> 安装"
echo "3. 对于 Node.js，请运行: nvm install --lts 安装最新 LTS 版本"
echo "4. 如果遇到权限问题，请运行: chmod +x show_me_env.sh"
if is_raspberry_pi; then
    echo "5. 树莓派特定提示："
    echo "   - 使用 'vcgencmd measure_temp' 查看更详细的温度信息"
    echo "   - 使用 'vcgencmd get_mem arm' 查看 GPU 内存分配"
    echo "   - 使用 'raspi-config' 进行系统配置"
fi