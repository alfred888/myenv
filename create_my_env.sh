#!/bin/bash

echo "===== 🧰 开发环境自动安装脚本（macOS） ====="

# 定义颜色
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"

# 检查 Homebrew
if ! command -v brew >/dev/null 2>&1; then
    echo -e "${RED}⚙️ 未检测到 Homebrew，开始安装...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo -e "${GREEN}✅ Homebrew 已安装${NC}"
fi

# 安装 Java JDK（默认安装 Temurin 17）
if ! command -v java >/dev/null 2>&1; then
    echo -e "${RED}📦 安装 Java（JDK 17）...${NC}"
    brew install --cask temurin
else
    echo -e "${GREEN}✅ Java 已安装：$(java -version 2>&1 | head -n 1)${NC}"
fi

# 安装 Python 3 和 pip3
if ! command -v python3 >/dev/null 2>&1; then
    echo -e "${RED}📦 安装 Python 3...${NC}"
    brew install python
else
    echo -e "${GREEN}✅ Python3 已安装：$(python3 --version)${NC}"
fi

# pip3 通常随 Python3 安装
if command -v pip3 >/dev/null 2>&1; then
    echo -e "${GREEN}✅ pip3 已安装：$(pip3 --version)${NC}"
else
    echo -e "${RED}⚠️ pip3 未安装，请检查 Python 安装情况${NC}"
fi

# 安装 Maven
if ! command -v mvn >/dev/null 2>&1; then
    echo -e "${RED}📦 安装 Maven...${NC}"
    brew install maven
else
    echo -e "${GREEN}✅ Maven 已安装：$(mvn -v | head -n 1)${NC}"
fi

# 安装 SDKMAN!
if [ ! -s "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    echo -e "${RED}📦 安装 SDKMAN!...${NC}"
    curl -s "https://get.sdkman.io" | bash
    echo 'source "$HOME/.sdkman/bin/sdkman-init.sh"' >> ~/.zshrc
    source "$HOME/.sdkman/bin/sdkman-init.sh"
else
    echo -e "${GREEN}✅ SDKMAN 已安装${NC}"
fi

# 安装 virtualenv
if ! command -v virtualenv >/dev/null 2>&1; then
    echo -e "${RED}📦 安装 virtualenv...${NC}"
    pip3 install virtualenv
else
    echo -e "${GREEN}✅ virtualenv 已安装：$(virtualenv --version)${NC}"
fi

echo -e "\n${GREEN}🎉 环境安装完毕！建议执行 source ~/.zshrc 以确保环境变量生效${NC}"
