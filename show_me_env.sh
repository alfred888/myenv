#!/bin/bash

# 颜色定义
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"

echo -e "\n===== 开发环境检测脚本 =====\n"

check_cmd() {
    local name=$1
    local cmd=$2
    local version_cmd=$3

    if command -v "$cmd" >/dev/null 2>&1; then
        version_output=$($version_cmd 2>&1 | head -n 1)
        echo -e "✅ ${GREEN}${name}:${NC} $version_output"
    else
        echo -e "❌ ${RED}${name}: 未安装${NC}"
    fi
}

# 基本工具检查
check_cmd "Java" "java" "java -version"
check_cmd "Node.js" "node" "node -v"
check_cmd "npm" "npm" "npm -v"
check_cmd "Maven" "mvn" "mvn -v"
check_cmd "Python3" "python3" "python3 --version"
check_cmd "pip3" "pip3" "pip3 --version"

# nvm 检查
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    source "$HOME/.nvm/nvm.sh"
fi
if command -v nvm >/dev/null 2>&1; then
    echo -e "✅ ${GREEN}nvm:${NC} $(nvm --version)"
else
    echo -e "❌ ${RED}nvm: 未安装或未加载${NC}"
fi

# 当前 Shell
echo -e "✅ 当前 Shell: $SHELL"

# Python 虚拟环境激活状态
echo -ne "🔍 Python 虚拟环境: "
if [[ -n "$VIRTUAL_ENV" ]]; then
    echo -e "${GREEN}已激活 (路径: $VIRTUAL_ENV)${NC}"
elif [[ -n "$CONDA_DEFAULT_ENV" ]]; then
    echo -e "${GREEN}Conda 环境已激活 (${CONDA_DEFAULT_ENV})${NC}"
else
    echo -e "${RED}未激活任何 Python 虚拟环境${NC}"
fi

# SDKMAN 检查
if [[ -d "$HOME/.sdkman" && -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    if command -v sdk >/dev/null 2>&1; then
        echo -e "✅ ${GREEN}SDKMAN:${NC} $(sdk version)"
    else
        echo -e "❌ ${RED}SDKMAN: 环境变量存在但 sdk 命令无效${NC}"
    fi
fi