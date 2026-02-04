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
    # 操作系统版本
    if [ -f /etc/os-release ]; then
        OS_INFO=$(cat /etc/os-release | grep -w "PRETTY_NAME" | cut -d= -f2 | tr -d '"')
    else
        OS_INFO=$(uname -srm)
    fi

    # 公网 IP 获取 (容错处理)
    IPV4=$(curl -s4 --connect-timeout 5 ifconfig.me || echo "未检测到 IPv4")
    IPV6=$(curl -s6 --connect-timeout 5 ifconfig.me || echo "未检测到 IPv6")

    # 地理位置与运营商
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

# 1. 安装必备命令
install_essentials() {
    echo -e "${YELLOW}正在安装必备基础命令 (bash, curl, wget, git, sudo, lsof)...${NC}"
    
    if [ -f /usr/bin/apt ]; then
        apt update && apt install -y bash curl wget git sudo lsof ca-certificates
    elif [ -f /usr/bin/yum ]; then
        yum makecache && yum install -y bash curl wget git sudo lsof ca-certificates
    elif [ -f /usr/bin/dnf ]; then
        dnf makecache && dnf install -y bash curl wget git sudo lsof ca-certificates
    else
        echo -e "${RED}未能识别包管理器，请手动安装必备组件。${NC}"
    fi
    
    echo -e "${GREEN}必备命令安装完成！${NC}"
    sleep 2
}

# 2. IP 质量检测
check_ip_quality() {
    clear
    echo -e "${CYAN}----------------------------------------------------------------${NC}"
    echo -e "${YELLOW}脚本名称：${NC}IP 质量检测 (IPQuality)"
    echo -e "${YELLOW}项目开源地址：${NC}${BLUE}https://github.com/xykt/IPQuality${NC}"
    echo -e "${CYAN}----------------------------------------------------------------${NC}"
    echo -e "${GREEN}正在启动检测脚本，请稍候...${NC}"
    sleep 2
    bash <(curl -Ls https://IP.Check.Place) -y
}

# 主界面显示
show_header() {
    clear
    echo -e "${CYAN}################################################################${NC}"
    echo -e "${PURPLE}                江某人的万能脚本箱${NC}"
    echo -e "${CYAN}################################################################${NC}"
    echo -e "${YELLOW}操作系统:${NC}  $OS_INFO"
    echo -e "${YELLOW}IPv4 地址:${NC} $IPV4"
    echo -e "${YELLOW}IPv6 地址:${NC} $IPV6"
    echo -e "${YELLOW}地理位置:${NC}  $LOCATION"
    echo -e "${CYAN}----------------------------------------------------------------${NC}"
}

# 菜单选择
main_menu() {
    while true; do
        get_system_info
        show_header
        echo -e "${GREEN}请选择功能:${NC}"
        echo -e " 1. 安装必备基础命令 (bash/curl/git等)"
        echo -e " 2. IP 质量检测 (查看流媒体解锁/黑名单等)"
        echo -e " 0. 退出脚本"
        echo -e "${CYAN}----------------------------------------------------------------${NC}"
        read -p "请输入数字选择: " choice

        case $choice in
            1)
                install_essentials
                ;;
            2)
                check_ip_quality
                echo -e "\n${YELLOW}检测完成。${NC}"
                read -n 1 -s -r -p "按任意键返回主菜单..."
                ;;
            0)
                echo -e "${GREEN}感谢使用，再见！${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}无效输入，请重新选择！${NC}"
                sleep 1
                ;;
        esac
    done
}

# 启动脚本
main_menu
