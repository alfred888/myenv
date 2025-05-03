#!/usr/bin/env bash

echo "===== 开发环境检测脚本 ====="
echo ""

# 颜色
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

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