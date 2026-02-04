#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 获取系统版本
OS_INFO=$(hostnamectl | grep -i "Operating System" | cut -d: -f2 | sed 's/^[ \t]*//')
[ -z "$OS_INFO" ] && OS_INFO=$(cat /etc/os-release | grep -w "PRETTY_NAME" | cut -d= -f2 | tr -d '"')

# 获取 IP 和 地理位置 (使用 ip-api.com，速度快且无需 Key)
IP_JSON=$(curl -s http://ip-api.com/json/)
IPV4=$(curl -s4 ifconfig.me)
IPV6=$(curl -s6 ifconfig.me || echo "未检测到 IPv6")
REGION=$(echo $IP_JSON | sed 's/.*"country":"\([^"]*\)".*/\1/')
CITY=$(echo $IP_JSON | sed 's/.*"city":"\([^"]*\)".*/\1/')
ISP=$(echo $IP_JSON | sed 's/.*"isp":"\([^"]*\)".*/\1/')

# 清屏并显示主页
clear
echo -e "${CYAN}################################################################${NC}"
echo -e "${PURPLE}                江某人的万能脚本箱${NC}"
echo -e "${CYAN}################################################################${NC}"

# 显示服务器基本信息
echo -e "${YELLOW}操作系统:${NC}  $OS_INFO"
echo -e "${YELLOW}IPv4 地址:${NC} $IPV4"
echo -e "${YELLOW}IPv6 地址:${NC} $IPV6"
echo -e "${YELLOW}地理位置:${NC}  $REGION - $CITY ($ISP)"
echo -e "${CYAN}----------------------------------------------------------------${NC}"

# 功能选择菜单
show_menu() {
    echo -e "${GREEN}请选择你要执行的功能:${NC}"
    echo -e " 1. 系统更新与清理"
    echo -e " 2. 安装 Docker & Compose"
    echo -e " 3. 网络环境测试 (回程路由/测速)"
    echo -e " 4. [待添加脚本...]"
    echo -e " 0. 退出脚本"
    echo -e "${CYAN}----------------------------------------------------------------${NC}"
    read -p "请输入数字: " choice
}

# 逻辑循环
while true; do
    show_menu
    case $choice in
        1)
            echo -e "${BLUE}开始运行系统更新...${NC}"
            # 这里放入更新代码
            apt update && apt upgrade -y
            break # 执行完可以选退出或返回
            ;;
        2)
            echo -e "${BLUE}准备安装 Docker...${NC}"
            break
            ;;
        0)
            echo -e "${GREEN}再见，江某人！脚本已退出。${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}输入错误，请重新选择！${NC}"
            sleep 1
            clear
            # 重新显示头部信息
            echo -e "${CYAN}################################################################${NC}"
            echo -e "${PURPLE}                江某人的万能脚本箱${NC}"
            echo -e "${CYAN}################################################################${NC}"
            echo -e "${YELLOW}操作系统:${NC}  $OS_INFO"
            echo -e "${YELLOW}IPv4 地址:${NC} $IPV4"
            echo -e "${YELLOW}IPv6 地址:${NC} $IPV6"
            echo -e "${YELLOW}地理位置:${NC}  $REGION - $CITY ($ISP)"
            echo -e "${CYAN}----------------------------------------------------------------${NC}"
            ;;
    esac
done
