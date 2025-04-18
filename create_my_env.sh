#!/bin/bash

echo "===== 🧰 开发环境自动安装脚本（macOS） ====="

# 颜色
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

# 安装 Java（JDK 17）
if ! command -v java >/dev/null 2>&1; then
    echo -e "${RED}📦 安装 Java（JDK 17）...${NC}"
    brew install --cask temurin
else
    echo -e "${GREEN}✅ Java 已安装：$(java -version 2>&1 | head -n 1)${NC}"
fi

# 安装 Python 3
if ! command -v python3 >/dev/null 2>&1; then
    echo -e "${RED}📦 安装 Python 3...${NC}"
    brew install python
else
    echo -e "${GREEN}✅ Python3 已安装：$(python3 --version)${NC}"
fi

# 检查 pip3
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

# 安装 SDKMAN
if [ ! -s "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    echo -e "${RED}📦 安装 SDKMAN!...${NC}"
    curl -s "https://get.sdkman.io" | bash
    if ! grep -q "sdkman-init.sh" ~/.zshrc; then
        echo 'source "$HOME/.sdkman/bin/sdkman-init.sh"' >> ~/.zshrc
    fi
    echo -e "${GREEN}✅ SDKMAN 安装完成，请执行：${NC} ${RED}source ~/.zshrc${NC} 或重新打开终端"
else
    echo -e "${GREEN}✅ SDKMAN 已安装${NC}"
fi
 

# 总结提示
echo -e "\n${GREEN}🎉 开发环境准备完成！${NC}"
echo -e "👉 如果你刚刚安装了 SDKMAN，请执行：${RED}source ~/.zshrc${NC}"
echo -e "👉 使用 virtualenv 示例："
echo -e "   ${GREEN}python3 -m venv myenv && source myenv/bin/activate${NC}"
