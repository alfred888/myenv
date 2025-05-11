#!/usr/bin/env bash

echo "===== 🍓 树莓派环境检测脚本 ====="
echo ""

# 颜色
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

# 检查是否为树莓派
check_raspberry_pi() {
    if [ ! -f /proc/device-tree/model ]; then
        echo -e "${RED}❌ 此脚本仅适用于树莓派设备${NC}"
        exit 1
    fi
    if ! grep -q "Raspberry Pi" /proc/device-tree/model; then
        echo -e "${RED}❌ 此脚本仅适用于树莓派设备${NC}"
        exit 1
    fi
}

# 获取树莓派基本信息
get_raspberry_pi_info() {
    echo -e "${GREEN}=== 树莓派基本信息 ===${NC}"
    
    # 获取树莓派型号
    if [ -f /proc/device-tree/model ]; then
        echo -e "${GREEN}✅ 型号: $(cat /proc/device-tree/model)${NC}"
    fi
    
    # 获取序列号
    if [ -f /proc/device-tree/serial-number ]; then
        echo -e "${GREEN}✅ 序列号: $(cat /proc/device-tree/serial-number)${NC}"
    fi
    
    # 获取操作系统信息
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo -e "${GREEN}✅ 操作系统: $PRETTY_NAME${NC}"
    fi
    
    # 获取内核版本
    echo -e "${GREEN}✅ 内核版本: $(uname -r)${NC}"
    
    # 获取主机名
    echo -e "${GREEN}✅ 主机名: $(hostname)${NC}"
}

# 获取硬件信息
get_hardware_info() {
    echo -e "\n${GREEN}=== 硬件信息 ===${NC}"
    
    # CPU 信息
    echo -e "${GREEN}✅ CPU 信息:${NC}"
    echo -e "  - 型号: $(grep "Model name" /proc/cpuinfo | head -n1 | cut -d':' -f2 | sed 's/^[ \t]*//')"
    echo -e "  - 核心数: $(grep -c "processor" /proc/cpuinfo)"
    
    # CPU 温度
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        temp=$(cat /sys/class/thermal/thermal_zone0/temp)
        temp_c=$(echo "scale=1; $temp/1000" | bc)
        echo -e "  - 温度: ${temp_c}°C"
    fi
    
    # 内存信息
    if command -v free >/dev/null 2>&1; then
        total_mem=$(free -h | grep Mem | awk '{print $2}')
        used_mem=$(free -h | grep Mem | awk '{print $3}')
        free_mem=$(free -h | grep Mem | awk '{print $4}')
        echo -e "${GREEN}✅ 内存信息:${NC}"
        echo -e "  - 总内存: $total_mem"
        echo -e "  - 已用: $used_mem"
        echo -e "  - 可用: $free_mem"
    fi
    
    # 存储信息
    if command -v df >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 存储信息:${NC}"
        df -h / | grep -v "Filesystem" | awk '{print "  - 总空间: " $2 "\n  - 已用: " $3 "\n  - 可用: " $4 "\n  - 使用率: " $5}'
    fi
    
    # GPU 信息
    if command -v vcgencmd >/dev/null 2>&1; then
        echo -e "${GREEN}✅ GPU 信息:${NC}"
        echo -e "  - 内存分配: $(vcgencmd get_mem arm | cut -d'=' -f2)"
        echo -e "  - 当前频率: $(vcgencmd measure_clock arm | cut -d'=' -f2) Hz"
    fi
}

# 获取网络信息
get_network_info() {
    echo -e "\n${GREEN}=== 网络信息 ===${NC}"
    
    # 网络接口信息
    echo -e "${GREEN}✅ 网络接口:${NC}"
    for interface in eth0 wlan0; do
        if ip addr show $interface >/dev/null 2>&1; then
            ip=$(ip addr show $interface | grep "inet " | awk '{print $2}')
            if [ ! -z "$ip" ]; then
                echo -e "  - $interface: $ip"
            fi
        fi
    done
    
    # 检查 SSH 服务
    echo -e "\n${GREEN}✅ SSH 服务:${NC}"
    if systemctl is-active ssh >/dev/null 2>&1; then
        echo -e "  - 状态: 运行中"
        echo -e "  - 端口: 22"
    else
        echo -e "  - 状态: 未运行"
    fi
    
    # 检查 HTTP 服务
    echo -e "\n${GREEN}✅ HTTP 服务:${NC}"
    if systemctl is-active apache2 >/dev/null 2>&1; then
        echo -e "  - Apache2: 运行中"
    else
        echo -e "  - Apache2: 未运行"
    fi
    if systemctl is-active nginx >/dev/null 2>&1; then
        echo -e "  - Nginx: 运行中"
    else
        echo -e "  - Nginx: 未运行"
    fi
}

# 获取开发环境信息
get_dev_env_info() {
    echo -e "\n${GREEN}=== 开发环境 ===${NC}"
    
    # Python
    if command -v python3 >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Python3: $(python3 --version)${NC}"
    else
        echo -e "${RED}❌ Python3: 未安装${NC}"
    fi
    
    # pip
    if command -v pip3 >/dev/null 2>&1; then
        echo -e "${GREEN}✅ pip3: $(pip3 --version)${NC}"
    else
        echo -e "${RED}❌ pip3: 未安装${NC}"
    fi
    
    # Node.js
    if command -v node >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Node.js: $(node --version)${NC}"
    else
        echo -e "${RED}❌ Node.js: 未安装${NC}"
    fi
    
    # npm
    if command -v npm >/dev/null 2>&1; then
        echo -e "${GREEN}✅ npm: $(npm --version)${NC}"
    else
        echo -e "${RED}❌ npm: 未安装${NC}"
    fi
    
    # Git
    if command -v git >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Git: $(git --version)${NC}"
    else
        echo -e "${RED}❌ Git: 未安装${NC}"
    fi
}

# 获取系统状态
get_system_status() {
    echo -e "\n${GREEN}=== 系统状态 ===${NC}"
    
    # 运行时间
    if command -v uptime >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 运行时间: $(uptime -p)${NC}"
    fi
    
    # 负载
    if [ -f /proc/loadavg ]; then
        load=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
        echo -e "${GREEN}✅ 系统负载: $load${NC}"
    fi
    
    # 磁盘使用情况
    if command -v df >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 磁盘使用情况:${NC}"
        df -h | grep -v "tmpfs" | grep -v "udev" | awk '{print "  - " $1 ": " $5 " 已用 (" $3 "/" $2 ")"}'
    fi
}

# 主函数
main() {
    # 检查是否为树莓派
    check_raspberry_pi
    
    # 获取各项信息
    get_raspberry_pi_info
    get_hardware_info
    get_network_info
    get_dev_env_info
    get_system_status
    
    # 显示提示信息
    echo -e "\n${YELLOW}=== 提示信息 ===${NC}"
    echo "1. 使用 'vcgencmd measure_temp' 查看详细温度信息"
    echo "2. 使用 'vcgencmd get_mem arm' 查看 GPU 内存分配"
    echo "3. 使用 'raspi-config' 进行系统配置"
    echo "4. 使用 'sudo apt update && sudo apt upgrade' 更新系统"
    echo "5. 使用 'sudo rpi-update' 更新固件（谨慎使用）"
}

# 运行主函数
main