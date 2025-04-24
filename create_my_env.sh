#!/usr/bin/env zsh

echo "===== 🧰 开发环境自动安装脚本（macOS） ====="

# 颜色
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

# 检查 Homebrew
check_brew() {
    # 尝试多个可能的 Homebrew 路径
    for path in "/opt/homebrew/bin/brew" "/usr/local/bin/brew" "/usr/local/Homebrew/bin/brew"; do
        if [ -x "$path" ]; then
            eval "$($path shellenv)"
            return 0
        fi
    done
    return 1
}

if ! check_brew && ! command -v brew >/dev/null 2>&1; then
    echo -e "${RED}⚙️ 未检测到 Homebrew，开始安装...${NC}"
    
    # 检查是否已安装 Xcode Command Line Tools
    if ! xcode-select -p >/dev/null 2>&1; then
        echo -e "${YELLOW}📦 需要安装 Xcode Command Line Tools...${NC}"
        xcode-select --install
        echo -e "${YELLOW}⚠️ 请等待 Xcode Command Line Tools 安装完成，然后重新运行此脚本${NC}"
        exit 1
    fi
    
    # 安装 Homebrew
    echo -e "${YELLOW}📦 正在安装 Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # 检查安装是否成功
    if [ $? -eq 0 ]; then
        # 配置环境变量
        if [ -d "/opt/homebrew" ]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -d "/usr/local/Homebrew" ]; then
            echo 'eval "$(/usr/local/Homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/usr/local/Homebrew/bin/brew shellenv)"
        fi
        
        # 验证安装
        if check_brew || command -v brew >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Homebrew 安装成功！${NC}"
            # 更新 Homebrew
            echo -e "${YELLOW}🔄 正在更新 Homebrew...${NC}"
            brew update
        else
            echo -e "${RED}❌ Homebrew 安装失败，请检查错误信息${NC}"
            exit 1
        fi
    else
        echo -e "${RED}❌ Homebrew 安装失败，请检查错误信息${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Homebrew 已安装${NC}"
    # 更新 Homebrew
    echo -e "${YELLOW}🔄 正在更新 Homebrew...${NC}"
    brew update
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
    echo -e "${GREEN}✅ pip3 已安装：$(pip3 --version | cut -d' ' -f1-2)${NC}"
else
    echo -e "${RED}⚠️ pip3 未安装，请检查 Python 安装情况${NC}"
fi

# 安装 Maven
if ! command -v mvn >/dev/null 2>&1; then
    echo -e "${RED}📦 安装 Maven...${NC}"
    brew install maven
    # 设置 MAVEN_HOME
    if [ -d "/opt/homebrew/opt/maven" ]; then
        echo 'export MAVEN_HOME="/opt/homebrew/opt/maven"' >> ~/.zshrc
        source ~/.zshrc
    fi
else
    echo -e "${GREEN}✅ Maven 已安装：$(mvn -v | head -n 1 | cut -d' ' -f1-3)${NC}"
fi

# 安装 nvm
if [ ! -d "$HOME/.nvm" ]; then
    echo -e "${RED}📦 安装 nvm...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    # 加载 nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    # 安装最新的 LTS 版本 Node.js
    nvm install --lts
else
    echo -e "${GREEN}✅ nvm 已安装${NC}"
    # 确保 nvm 已加载
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

# 检查 Node.js 和 npm
if command -v node >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Node.js 已安装：v$(node --version | sed 's/v//')${NC}"
    echo -e "${GREEN}✅ npm 已安装：v$(npm --version)${NC}"
else
    echo -e "${YELLOW}⚠️ 正在通过 nvm 安装 Node.js...${NC}"
    nvm install --lts
    echo -e "${GREEN}✅ Node.js 已安装：v$(node --version | sed 's/v//')${NC}"
    echo -e "${GREEN}✅ npm 已安装：v$(npm --version)${NC}"
fi

# 安装 SDKMAN
if [ ! -s "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    echo -e "${RED}📦 安装 SDKMAN!...${NC}"
    curl -s "https://get.sdkman.io" | bash
    if ! grep -q "sdkman-init.sh" ~/.zshrc; then
        echo 'source "$HOME/.sdkman/bin/sdkman-init.sh"' >> ~/.zshrc
    fi
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    echo -e "${GREEN}✅ SDKMAN 安装完成${NC}"
else
    echo -e "${GREEN}✅ SDKMAN 已安装${NC}"
    source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# 安装 Java
if ! command -v java >/dev/null 2>&1 || [[ "$(java -version 2>&1)" == *"Unable to locate a Java Runtime"* ]]; then
    echo -e "${YELLOW}📦 正在安装 Java 17 (LTS)...${NC}"
    # 确保 SDKMAN 已加载
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
    
    # 安装 Java 17
    sdk install java 17.0.0-tem
    
    # 设置 JAVA_HOME
    if command -v java >/dev/null 2>&1; then
        JAVA_HOME=$(sdk home java 17.0.0-tem)
        echo "export JAVA_HOME=\"$JAVA_HOME\"" >> ~/.zshrc
        source ~/.zshrc
        echo -e "${GREEN}✅ Java 安装成功：$(java -version 2>&1 | head -n 1)${NC}"
    else
        echo -e "${RED}❌ Java 安装失败${NC}"
    fi
else
    echo -e "${GREEN}✅ Java 已安装：$(java -version 2>&1 | head -n 1)${NC}"
fi

# 检查当前 Shell
echo -e "${GREEN}✅ 当前 Shell: $SHELL${NC}"

# 检查 Python 虚拟环境
if [ -n "$VIRTUAL_ENV" ]; then
    echo -e "${GREEN}✅ Python 虚拟环境: $VIRTUAL_ENV${NC}"
else
    echo -e "${YELLOW}🔍 Python 虚拟环境: 未激活任何 Python 虚拟环境${NC}"
fi

# 总结提示
echo -e "\n${GREEN}🎉 开发环境准备完成！${NC}"
echo -e "👉 请执行以下命令使所有更改生效："
echo -e "   ${GREEN}source ~/.zshrc${NC}"
echo -e "👉 使用 virtualenv 示例："
echo -e "   ${GREEN}python3 -m venv myenv && source myenv/bin/activate${NC}"
