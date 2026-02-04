#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 获取系统基本信息
get_system_info() {
    if [ -f /etc/os-release ]; then
        OS_RAW=$(cat /etc/os-release | grep -w "ID" | cut -d= -f2 | tr -d '"')
        OS_INFO=$(cat /etc/os-release | grep -w "PRETTY_NAME" | cut -d= -f2 | tr -d '"')
    else
        OS_RAW="unknown"
        OS_INFO=$(uname -srm)
    fi
    IPV4=$(curl -s4 --connect-timeout 5 ifconfig.me || echo "未检测到 IPv4")
    IPV6=$(curl -s6 --connect-timeout 5 ifconfig.me || echo "未检测到 IPv6")
    IP_JSON=$(curl -s --connect-timeout 5 http://ip-api.com/json/)
    if [[ $IP_JSON == *"success"* ]]; then
        REGION=$(echo $IP_JSON | sed 's/.*"country":"\([^"]*\)".*/\1/')
        CITY=$(echo $IP_JSON | sed 's/.*"city":"\([^"]*\)".*/\1/')
        ISP=$(echo $IP_JSON | sed 's/.*"isp":"\([^"]*\)".*/\1/')
        LOCATION="$REGION - $CITY ($ISP)"
    else
        LOCATION="位置获取失败"
    fi
}

# 自动安装依赖函数 (针对不同系统)
install_deps() {
    local deps=$@
    echo -e "${YELLOW}正在检查依赖环境: ${BLUE}$deps${NC}"
    if [ "$OS_RAW" = "alpine" ]; then
        apk add --no-cache $deps
    elif [ -f /usr/bin/apt ]; then
        apt update && apt install -y $deps
    elif [ -f /usr/bin/yum ]; then
        yum install -y $deps
    fi
}

# 工具函数：通用运行逻辑
run_script() {
    local name=$1
    local github=$2
    local command=$3
    local is_alpine_only=$4

    # Alpine 限制检测
    if [ "$is_alpine_only" = "true" ] && [ "$OS_RAW" != "alpine" ]; then
        echo -e "${RED}错误：该脚本仅支持 Alpine 系统，当前系统为 $OS_INFO，已拦截。${NC}"
        read -n 1 -s -r -p "按任意键返回..."
        return
    fi

    clear
    echo -e "${CYAN}----------------------------------------------------------------${NC}"
    echo -e "${YELLOW}正在运行：${NC}${GREEN}$name${NC}"
    echo -e "${YELLOW}项目地址：${NC}${BLUE}$github${NC}"
    echo -e "${CYAN}----------------------------------------------------------------${NC}"
    echo -e "${YELLOW}环境检查与启动中...${NC}"
    sleep 2
    eval "$command"
    echo -e "\n${YELLOW}执行完毕。${NC}"
    read -n 1 -s -r -p "按任意键返回..."
}

# --- 功能菜单 ---

# 1. 基础命令
install_essentials() {
    install_deps "bash curl wget git sudo lsof ca-certificates"
    echo -e "${GREEN}必备命令安装完成！${NC}"
    sleep 2
}

# 2. 新机体检
new_machine_check() {
    while true; do
        clear
        show_header
        echo -e "${BLUE}>>> [ 新机体检 ]${NC}"
        echo -e " 1. IP 质量检测 (xykt/IPQuality)"
        echo -e " 2. 网络质量检测 (xykt/NetQuality)"
        echo -e " 3. 硬件质量检测 (xykt/HardwareQuality)"
        echo -e " 4. 三网回程路由测试 (zhanghanyun/backtrace)"
        echo -e " 5. NodeQuality 检测脚本 (LloydAsp/NodeQuality)"
        echo -e " 6. 融合怪测评 - GO版本 (oneclickvirt/ecs)"
        echo -e " 7. 流媒体解锁检测 (HsukqiLee/MediaUnlockTest)"
        echo -e " 8. “更准确”流媒体解锁检测 (1-stream/RegionCheck)"
        echo -e " 0. 返回主菜单"
        echo -e "${CYAN}----------------------------------------------------------------${NC}"
        read -p "请输入数字选择: " sub_choice
        case $sub_choice in
            1) run_script "IP 质量检测" "https://github.com/xykt/IPQuality" "bash <(curl -Ls https://IP.Check.Place) -y" "false" ;;
            2) run_script "网络质量检测" "https://github.com/xykt/NetQuality" "bash <(curl -Ls https://Net.Check.Place) -y" "false" ;;
            3) run_script "硬件质量检测" "https://github.com/xykt/HardwareQuality" "bash <(curl -Ls https://Hardware.Check.Place) -y" "false" ;;
            4) run_script "三网回程路由测试" "https://github.com/zhanghanyun/backtrace" "curl https://raw.githubusercontent.com/zhanghanyun/backtrace/main/install.sh -sSf | sh" "false" ;;
            5) run_script "NodeQuality 检测" "https://github.com/LloydAsp/NodeQuality" "bash <(curl -sL https://run.NodeQuality.com)" "false" ;;
            6) run_script "融合怪测评 - GO版本" "https://github.com/oneclickvirt/ecs" "export noninteractive=true && curl -L https://cdn.spiritlhl.net/https://raw.githubusercontent.com/oneclickvirt/ecs/master/goecs.sh -o goecs.sh && chmod +x goecs.sh && ./goecs.sh install && goecs" "false" ;;
            7) run_script "流媒体解锁检测" "https://github.com/HsukqiLee/MediaUnlockTest" "bash <(curl -Ls unlock.icmp.ing/scripts/test.sh)" "false" ;;
            8) run_script "“更准确”流媒体解锁检测" "https://github.com/1-stream/RegionRestrictionCheck" "bash <(curl -L -s https://raw.githubusercontent.com/1-stream/RegionRestrictionCheck/main/check.sh)" "false" ;;
            0) break ;;
        esac
    done
}

# 3. 科学上网
science_tools() {
    while true; do
        clear
        show_header
        echo -e "${BLUE}>>> [ 科学上网相关 ]${NC}"
        echo -e " 1. 原版 3x-ui (v2.6.2)"
        echo -e " 2. 适配 Alpine 版旧 3x-ui ${RED}(仅限Alpine)${NC}"
        echo -e " 3. Sing-box-yg 精装桶 ${RED}(有争议/慎用)${NC}"
        echo -e " 4. yoyo sing-box 一键部署 (SS/HY2/TUIC/VLESS)"
        echo -e " 5. 欢妹 3X-UI-Alpine ${RED}(仅限Alpine)${NC}"
        echo -e " 0. 返回主菜单"
        echo -e "${CYAN}----------------------------------------------------------------${NC}"
        read -p "请输入数字选择: " sub_choice
        case $sub_choice in
            1) run_script "原版 3x-ui(2.6.2)" "https://github.com/MHSanaei/3x-ui" "bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) v2.6.2" "false" ;;
            2) 
               install_deps "curl bash gzip"
               run_script "适配Alpine旧版3x-ui" "https://github.com/56idc/3x-ui-alpine" "bash <(curl -Ls https://raw.githubusercontent.com/56idc/3x-ui-alpine/master/install_alpine.sh)" "true" 
               ;;
            3) run_script "Sing-box-yg精装桶" "https://github.com/yonggekkk/sing-box-yg" "bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/sing-box-yg/main/sb.sh)" "false" ;;
            4) run_script "yoyo sing-box一键脚本" "https://github.com/caigouzi121380/singbox-deploy" "bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/caigouzi121380/singbox-deploy/main/install-singbox-yyds.sh)\"" "false" ;;
            5) 
               install_deps "curl bash gzip openssl"
               run_script "欢妹 3X-UI-Alpine" "https://github.com/StarVM-OpenSource/3x-ui-Apline" "bash <(curl -Ls https://raw.githubusercontent.com/StarVM-OpenSource/3x-ui-Apline/refs/heads/main/install.sh)" "true" 
               ;;
            0) break ;;
        esac
    done
}

# --- 基础 UI 架构 ---

show_header() {
    echo -e "${CYAN}################################################################${NC}"
    echo -e "${PURPLE}                江某人的万能脚本箱${NC}"
    echo -e "${CYAN}################################################################${NC}"
    echo -e "${YELLOW}操作系统:${NC}  $OS_INFO"
    echo -e "${YELLOW}IPv4 地址:${NC} $IPV4"
    echo -e "${YELLOW}IPv6 地址:${NC} $IPV6"
    echo -e "${YELLOW}地理位置:${NC}  $LOCATION"
    echo -e "${CYAN}----------------------------------------------------------------${NC}"
}

show_footer() {
    echo -e "${CYAN}----------------------------------------------------------------${NC}"
    echo -e "${YELLOW}我的个人博客：${NC}${BLUE}op.style${NC}"
    echo -e "${CYAN}################################################################${NC}"
}

main_menu() {
    while true; do
        get_system_info
        clear
        show_header
        echo -e "${GREEN}主菜单功能:${NC}"
        echo -e " 1. 安装必备基础命令 (bash/curl/git等)"
        echo -e " 2. 新机体检项目 (IP/网络/硬件/解锁测评)"
        echo -e " 3. 科学上网工具 (3x-ui/Sing-box等)"
        echo -e " 0. 退出脚本"
        echo ""
        show_footer
        read -p "请输入数字选择: " choice
        case $choice in
            1) install_essentials ;;
            2) new_machine_check ;;
            3) science_tools ;;
            0) echo -e "${GREEN}感谢使用，再见！${NC}" && exit 0 ;;
            *) echo -e "${RED}无效输入！${NC}" && sleep 1 ;;
        esac
    done
}

main_menu
