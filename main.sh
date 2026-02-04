#!/bin/bash

# ======================================================
# 脚本名称：江某人的万能脚本箱
# 博客地址：op.style
# 适用系统：Debian / Ubuntu / CentOS / Alpine
# ======================================================

# 1. 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 检查是否为 Root
if [ $(id -u) != "0" ]; then
    echo -e "${RED}错误: 必须使用 root 权限运行此脚本。${NC}"
    exit 1
fi

# 2. 环境信息获取
get_system_info() {
    # 系统内核识别
    if [ -f /etc/os-release ]; then
        OS_RAW=$(cat /etc/os-release | grep -w "ID" | cut -d= -f2 | tr -d '"')
        OS_INFO=$(cat /etc/os-release | grep -w "PRETTY_NAME" | cut -d= -f2 | tr -d '"')
    else
        OS_RAW="unknown"
        OS_INFO=$(uname -srm)
    fi

    # IP 信息获取
    IPV4=$(curl -s4 --connect-timeout 5 ifconfig.me || echo "未检测到 IPv4")
    IPV6=$(curl -s6 --connect-timeout 5 ifconfig.me || echo "未检测到 IPv6")

    # 地理位置
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

# 3. 依赖安装工具
install_deps() {
    local deps=$@
    echo -e "${YELLOW}正在安装依赖: ${BLUE}$deps${NC}"
    if [ "$OS_RAW" = "alpine" ]; then
        apk add --no-cache $deps
    elif [ -f /usr/bin/apt ]; then
        apt update && apt install -y $deps
    elif [ -f /usr/bin/yum ]; then
        yum install -y $deps
    elif [ -f /usr/bin/dnf ]; then
        dnf install -y $deps
    fi
}

# 4. 通用运行模版
run_script() {
    local name=$1
    local github=$2
    local command=$3
    local is_alpine_only=$4

    # Alpine 限制检测
    if [ "$is_alpine_only" = "true" ] && [ "$OS_RAW" != "alpine" ]; then
        echo -e "${RED}❌ 错误：脚本 [ $name ] 仅支持 Alpine 系统！${NC}"
        echo -e "${YELLOW}当前系统检测为：$OS_INFO${NC}"
        read -n 1 -s -r -p "按任意键返回..."
        return
    fi

    clear
    echo -e "${CYAN}----------------------------------------------------------------${NC}"
    echo -e "${YELLOW}正在启动：${NC}${GREEN}$name${NC}"
    echo -e "${YELLOW}开源地址：${NC}${BLUE}$github${NC}"
    echo -e "${CYAN}----------------------------------------------------------------${NC}"
    sleep 1
    eval "$command"
    echo -e "\n${YELLOW}执行完毕。${NC}"
    read -n 1 -s -r -p "按任意键返回主菜单..."
}

# 5. 各分类菜单
# --- 5.1 基础命令 ---
install_essentials() {
    install_deps "bash curl wget git sudo lsof ca-certificates gzip"
    echo -e "${GREEN}必备基础命令已就绪。${NC}"
    sleep 2
}

# --- 5.2 新机体检 ---
new_machine_check() {
    while true; do
        clear
        show_header
        echo -e "${BLUE}>>> [ 新机体检项目 ]${NC}"
        echo -e " 1. IP 质量检测 (xykt/IPQuality)"
        echo -e " 2. 网络质量检测 (xykt/NetQuality)"
        echo -e " 3. 硬件质量检测 (xykt/HardwareQuality)"
        echo -e " 4. 三网回程路由测试 (zhanghanyun/backtrace)"
        echo -e " 5. NodeQuality 检测脚本 (LloydAsp/NodeQuality)"
        echo -e " 6. 融合怪测评 - GO版本 (oneclickvirt/ecs)"
        echo -e " 7. 流媒体解锁检测 (HsukqiLee/MediaUnlockTest)"
        echo -e " 8. “更准确”流媒体解锁检测 (1-stream/Check)"
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

# --- 5.3 科学上网 ---
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
            4) run_script "yoyo sing-box一键" "https://github.com/caigouzi121380/singbox-deploy" "bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/caigouzi121380/singbox-deploy/main/install-singbox-yyds.sh)\"" "false" ;;
            5) 
               install_deps "curl bash gzip openssl"
               run_script "欢妹 3X-UI-Alpine" "https://github.com/StarVM-OpenSource/3x-ui-Apline" "bash <(curl -Ls https://raw.githubusercontent.com/StarVM-OpenSource/3x-ui-Apline/refs/heads/main/install.sh)" "true" 
               ;;
            0) break ;;
        esac
    done
}

# --- 5.4 管理面板 ---
panel_tools() {
    while true; do
        clear
        show_header
        echo -e "${BLUE}>>> [ 可视化管理面板 ]${NC}"
        echo -e " 1. 1Panel 官方版 (现代化 Docker 管理)"
        echo -e " 2. 宝塔面板 (国内流行)"
        echo -e " 3. aaPanel (宝塔国际版 - 无需手机号)"
        echo -e " 4. CasaOS (极简家庭云系统)"
        echo -e " 0. 返回主菜单"
        echo -e "${CYAN}----------------------------------------------------------------${NC}"
        read -p "请输入数字选择: " sub_choice
        case $sub_choice in
            1) run_script "1Panel" "https://1panel.cn" "curl -sSL https://resource.fit2cloud.com/1panel/package/quick_start.sh -o quick_start.sh && bash quick_start.sh" "false" ;;
            2) run_script "宝塔面板" "https://bt.cn" "if [ -f /usr/bin/curl ];then curl -sSO https://download.bt.cn/install/install_panel.sh;else wget -O install_panel.sh https://download.bt.cn/install/install_panel.sh;fi && bash install_panel.sh ed8484bec" "false" ;;
            3) run_script "aaPanel" "https://aapanel.com" "wget -O install.sh http://www.aapanel.com/script/install_6.0_en.sh && bash install.sh" "false" ;;
            4) run_script "CasaOS" "https://casaos.io" "curl -fsSL https://get.casaos.io | bash" "false" ;;
            0) break ;;
        esac
    done
}

# 6. UI 组件
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

# 7. 主逻辑
main_menu() {
    while true; do
        get_system_info
        clear
        show_header
        echo -e "${GREEN}主菜单功能:${NC}"
        echo -e " 1. 安装必备基础命令 (bash/curl/git等)"
        echo -e " 2. 新机体检项目 (IP/网络/硬件/测评)"
        echo -e " 3. 科学上网工具 (3x-ui/Sing-box等)"
        echo -e " 4. 可视化面板安装 (1Panel/宝塔等)"
        echo -e " 0. 退出脚本"
        echo ""
        show_footer
        read -p "请输入数字选择: " choice
        case $choice in
            1) install_essentials ;;
            2) new_machine_check ;;
            3) science_tools ;;
            4) panel_tools ;;
            0) echo -e "${GREEN}脚本退出。再见，江某人！${NC}" && exit 0 ;;
            *) echo -e "${RED}输入错误！${NC}" && sleep 1 ;;
        esac
    done
}

# 启动脚本
main_menu
