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
        OS_INFO=$(cat /etc/os-release | grep -w "PRETTY_NAME" | cut -d= -f2 | tr -d '"')
    else
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

# 工具函数：显示脚本来源并执行
run_script() {
    local name=$1
    local github=$2
    local command=$3
    clear
    echo -e "${CYAN}----------------------------------------------------------------${NC}"
    echo -e "${YELLOW}正在运行：${NC}${GREEN}$name${NC}"
    echo -e "${YELLOW}项目地址：${NC}${BLUE}$github${NC}"
    echo -e "${CYAN}----------------------------------------------------------------${NC}"
    echo -e "${YELLOW}准备启动...${NC}"
    sleep 2
    eval "$command"
    echo -e "\n${YELLOW}执行完毕。${NC}"
    read -n 1 -s -r -p "按任意键返回子菜单..."
}

# 1. 安装必备命令
install_essentials() {
    echo -e "${YELLOW}正在安装必备基础命令 (bash, curl, wget, git, sudo, lsof, ca-certificates)...${NC}"
    if [ -f /usr/bin/apt ]; then
        apt update && apt install -y bash curl wget git sudo lsof ca-certificates
    elif [ -f /usr/bin/yum ]; then
        yum makecache && yum install -y bash curl wget git sudo lsof ca-certificates
    elif [ -f /usr/bin/dnf ]; then
        dnf makecache && dnf install -y bash curl wget git sudo lsof ca-certificates
    fi
    echo -e "${GREEN}必备命令安装完成！${NC}"
    sleep 2
}

# “新机体检”子菜单
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
            1) run_script "IP 质量检测" "https://github.com/xykt/IPQuality" "bash <(curl -Ls https://IP.Check.Place) -y" ;;
            2) run_script "网络质量检测" "https://github.com/xykt/NetQuality" "bash <(curl -Ls https://Net.Check.Place) -y" ;;
            3) run_script "硬件质量检测" "https://github.com/xykt/HardwareQuality" "bash <(curl -Ls https://Hardware.Check.Place) -y" ;;
            4) run_script "三网回程路由测试" "https://github.com/zhanghanyun/backtrace" "curl https://raw.githubusercontent.com/zhanghanyun/backtrace/main/install.sh -sSf | sh" ;;
            5) run_script "NodeQuality 检测" "https://github.com/LloydAsp/NodeQuality" "bash <(curl -sL https://run.NodeQuality.com)" ;;
            6) run_script "融合怪测评 - GO版本" "https://github.com/oneclickvirt/ecs" "export noninteractive=true && curl -L https://cdn.spiritlhl.net/https://raw.githubusercontent.com/oneclickvirt/ecs/master/goecs.sh -o goecs.sh && chmod +x goecs.sh && ./goecs.sh install && goecs" ;;
            7) run_script "流媒体解锁检测" "https://github.com/HsukqiLee/MediaUnlockTest" "bash <(curl -Ls unlock.icmp.ing/scripts/test.sh)" ;;
            8) run_script "“更准确”流媒体解锁检测" "https://github.com/1-stream/RegionRestrictionCheck" "bash <(curl -L -s https://raw.githubusercontent.com/1-stream/RegionRestrictionCheck/main/check.sh)" ;;
            0) break ;;
            *) echo -e "${RED}无效输入！${NC}" && sleep 1 ;;
        esac
    done
}

# 主界面头部
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

# 广告脚标
show_footer() {
    echo -e "${CYAN}----------------------------------------------------------------${NC}"
    echo -e "${YELLOW}我的个人博客：${NC}${BLUE}op.style${NC}"
    echo -e "${CYAN}################################################################${NC}"
}

# 主菜单
main_menu() {
    while true; do
        get_system_info
        clear
        show_header
        echo -e "${GREEN}主菜单功能:${NC}"
        echo -e " 1. 安装必备基础命令 (bash/curl/git等)"
        echo -e " 2. 新机体检项目 (IP/网络/硬件/解锁测评)"
        echo -e " 0. 退出脚本"
        echo ""
        show_footer
        read -p "请输入数字选择: " choice

        case $choice in
            1) install_essentials ;;
            2) new_machine_check ;;
            0) echo -e "${GREEN}感谢使用，再见！${NC}" && exit 0 ;;
            *) echo -e "${RED}无效输入！${NC}" && sleep 1 ;;
        esac
    done
}

# 启动
main_menu
