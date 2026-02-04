#!/bin/bash

# ======================================================
# 脚本名称：江某人的万能脚本箱 (Full Version)
# 核心作者：Gemini (for 江某人)
# 博客地址：op.style
# ======================================================

# 1. 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 检查 Root
[[ $(id -u) != "0" ]] && echo -e "${RED}错误: 请使用 root 权限运行！${NC}" && exit 1

# 2. 环境抓取
get_system_info() {
    if [ -f /etc/os-release ]; then
        OS_RAW=$(cat /etc/os-release | grep -w "ID" | cut -d= -f2 | tr -d '"')
        OS_INFO=$(cat /etc/os-release | grep -w "PRETTY_NAME" | cut -d= -f2 | tr -d '"')
    else
        OS_RAW="unknown"; OS_INFO=$(uname -srm)
    fi
    IPV4=$(curl -s4 --connect-timeout 5 ifconfig.me || echo "未检测到 IPv4")
    IPV6=$(curl -s6 --connect-timeout 5 ifconfig.me || echo "未检测到 IPv6")
    IP_JSON=$(curl -s --connect-timeout 5 http://ip-api.com/json/)
    if [[ $IP_JSON == *"success"* ]]; then
        REGION=$(echo $IP_JSON | sed 's/.*"country":"\([^"]*\)".*/\1/')
        ISP=$(echo $IP_JSON | sed 's/.*"isp":"\([^"]*\)".*/\1/')
        LOCATION="$REGION ($ISP)"
    else
        LOCATION="获取失败"
    fi
}

# 3. 核心工具函数
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

run_script() {
    local name=$1; local github=$2; local command=$3; local is_alpine=$4
    if [ "$is_alpine" = "true" ] && [ "$OS_RAW" != "alpine" ]; then
        echo -e "${RED}❌ 该脚本仅支持 Alpine 系统！当前：$OS_INFO${NC}"; read -n 1 -s -r; return
    fi
    clear
    echo -e "${CYAN}----------------------------------------------------------------${NC}"
    echo -e "${YELLOW}启动：${NC}${GREEN}$name${NC}\n${YELLOW}项目：${NC}${BLUE}$github${NC}"
    echo -e "${CYAN}----------------------------------------------------------------${NC}"
    sleep 1; eval "$command"
    echo -e "\n${YELLOW}执行完毕。${NC}"; read -n 1 -s -r -p "按任意键返回..."
}

# --- 4. 功能分类菜单 ---

# 4.1 新机体检
new_machine_check() {
    while true; do
        clear; show_header
        echo -e "${BLUE}>>> [ 新机体检项目 ]${NC}"
        echo -e " 1. IP 质量检测 (xykt/IPQuality)"
        echo -e " 2. 网络质量检测 (xykt/NetQuality)"
        echo -e " 3. 硬件质量检测 (xykt/HardwareQuality)"
        echo -e " 4. 三网回程路由测试 (zhanghanyun/backtrace)"
        echo -e " 5. NodeQuality 检测脚本"
        echo -e " 6. 融合怪测评 - GO版本"
        echo -e " 7. 流媒体解锁检测 (HsukqiLee)"
        echo -e " 8. “更准确”流媒体解锁检测 (1-stream)"
        echo -e " 0. 返回主菜单"
        echo -e "${CYAN}----------------------------------------------------------------${NC}"
        read -p "选择: " c
        case $c in
            1) run_script "IP质量" "xykt/IPQuality" "bash <(curl -Ls https://IP.Check.Place) -y" "false" ;;
            2) run_script "网络质量" "xykt/NetQuality" "bash <(curl -Ls https://Net.Check.Place) -y" "false" ;;
            3) run_script "硬件质量" "xykt/HardwareQuality" "bash <(curl -Ls https://Hardware.Check.Place) -y" "false" ;;
            4) run_script "三网回程" "zhanghanyun/backtrace" "curl https://raw.githubusercontent.com/zhanghanyun/backtrace/main/install.sh -sSf | sh" "false" ;;
            5) run_script "NodeQuality" "LloydAsp/NodeQuality" "bash <(curl -sL https://run.NodeQuality.com)" "false" ;;
            6) run_script "融合怪-GO" "oneclickvirt/ecs" "export noninteractive=true && curl -L https://cdn.spiritlhl.net/https://raw.githubusercontent.com/oneclickvirt/ecs/master/goecs.sh -o goecs.sh && chmod +x goecs.sh && ./goecs.sh install && goecs" "false" ;;
            7) run_script "流媒体解锁" "HsukqiLee/MediaUnlockTest" "bash <(curl -Ls unlock.icmp.ing/scripts/test.sh)" "false" ;;
            8) run_script "流媒体深度" "1-stream/Check" "bash <(curl -L -s https://raw.githubusercontent.com/1-stream/RegionRestrictionCheck/main/check.sh)" "false" ;;
            0) break ;;
        esac
    done
}

# 4.2 科学上网
science_tools() {
    while true; do
        clear; show_header
        echo -e "${BLUE}>>> [ 科学上网工具 ]${NC}"
        echo -e " 1. 原版 3x-ui (v2.6.2)"
        echo -e " 2. 适配 Alpine 版旧 3x-ui ${RED}(仅限Alpine)${NC}"
        echo -e " 3. Sing-box-yg 精装桶 ${RED}(慎用)${NC}"
        echo -e " 4. yoyo sing-box 一键部署"
        echo -e " 5. 欢妹 3X-UI-Alpine ${RED}(仅限Alpine)${NC}"
        echo -e " 0. 返回主菜单"
        echo -e "${CYAN}----------------------------------------------------------------${NC}"
        read -p "选择: " c
        case $c in
            1) run_script "3x-ui" "MHSanaei/3x-ui" "bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) v2.6.2" "false" ;;
            2) install_deps "curl bash gzip"; run_script "Alpine-3x-ui" "56idc/3x-ui-alpine" "bash <(curl -Ls https://raw.githubusercontent.com/56idc/3x-ui-alpine/master/install_alpine.sh)" "true" ;;
            3) run_script "Sing-box-yg" "yonggekkk/sing-box-yg" "bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/sing-box-yg/main/sb.sh)" "false" ;;
            4) run_script "yoyo-singbox" "caigouzi121380/singbox-deploy" "bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/caigouzi121380/singbox-deploy/main/install-singbox-yyds.sh)\"" "false" ;;
            5) install_deps "curl bash gzip openssl"; run_script "欢妹Alpine" "StarVM/3x-ui-Apline" "bash <(curl -Ls https://raw.githubusercontent.com/StarVM-OpenSource/3x-ui-Apline/refs/heads/main/install.sh)" "true" ;;
            0) break ;;
        esac
    done
}

# 4.3 可视化面板 (江某人，都在这里！)
panel_tools() {
    while true; do
        clear; show_header
        echo -e "${BLUE}>>> [ 可视化管理面板 ]${NC}"
        echo -e " 1. 1Panel 官方版 (推荐：Docker 容器化管理)"
        echo -e " 2. 宝塔面板 (国内流行版本)"
        echo -e " 3. aaPanel (宝塔国际版：无需手机号)"
        echo -e " 4. CasaOS (超高颜值极简系统)"
        echo -e " 0. 返回主菜单"
        echo -e "${CYAN}----------------------------------------------------------------${NC}"
        read -p "选择: " c
        case $c in
            1) run_script "1Panel" "1panel.cn" "curl -sSL https://resource.fit2cloud.com/1panel/package/quick_start.sh -o quick_start.sh && bash quick_start.sh" "false" ;;
            2) run_script "宝塔面板" "bt.cn" "if [ -f /usr/bin/curl ];then curl -sSO https://download.bt.cn/install/install_panel.sh;else wget -O install_panel.sh https://download.bt.cn/install/install_panel.sh;fi && bash install_panel.sh ed8484bec" "false" ;;
            3) run_script "aaPanel" "aapanel.com" "wget -O install.sh http://www.aapanel.com/script/install_6.0_en.sh && bash install.sh" "false" ;;
            4) run_script "CasaOS" "casaos.io" "curl -fsSL https://get.casaos.io | bash" "false" ;;
            0) break ;;
        esac
    done
}

# 4.4 实用工具
utility_tools() {
    while true; do
        clear; show_header
        echo -e "${BLUE}>>> [ 实用运维工具箱 ]${NC}"
        echo -e " 1. DNS 深度管理 (查看/添加/排序/纠错)"
        echo -e " 2. BBR & TPS 调优 (开启/关闭/进阶优化)"
        echo -e " 3. Swap 虚拟内存管理 (添加/删除)"
        echo -e " 4. 修改 SSH 端口 (加固服务器)"
        echo -e " 0. 返回主菜单"
        echo -e "${CYAN}----------------------------------------------------------------${NC}"
        read -p "选择: " c
        case $c in
            1) dns_manager ;;
            2) bbr_tuning ;;
            3) swap_manager ;;
            4) read -p "输入新端口: " port; sed -i "s/#Port 22/Port $port/g;s/Port .*/Port $port/g" /etc/ssh/sshd_config; systemctl restart sshd; echo -e "${GREEN}端口已改为 $port，请放行防火墙！${NC}"; sleep 2 ;;
            0) break ;;
        esac
    done
}

# --- 5. 深度逻辑函数 ---

dns_manager() {
    while true; do
        clear; echo -e "${BLUE}>>> DNS 管理器${NC}\n${CYAN}当前配置:${NC}"; grep "nameserver" /etc/resolv.conf | nl -w2 -s'. '
        echo -e "----------------------------------\n1.添加单条 2.批量添加 3.修改行 4.移动行 5.公共DNS 6.纠错 7.清空 0.返回"
        read -p "操作: " d
        case $d in
            1) read -p "IP: " ip; echo "nameserver $ip" >> /etc/resolv.conf ;;
            2) read -p "IPs(逗号隔开): " ips; for i in ${ips//,/ }; do echo "nameserver $i" >> /etc/resolv.conf; done ;;
            3) read -p "行号: " l; read -p "新IP: " ni; sed -i "${l}s/nameserver .*/nameserver $ni/" /etc/resolv.conf ;;
            4) read -p "行号: " l; read -p "方向(1.上 2.下): " dr; [[ $dr -eq 1 ]] && { sed -i "${l}h;${l}d;$(($l-1))G" /etc/resolv.conf; } || { sed -i "${l}h;${l}d;$(($l+1))G" /etc/resolv.conf; } ;;
            5) echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" >> /etc/resolv.conf ;;
            6) sed -i '/^nameserver/!d' /etc/resolv.conf; sed -i 's/^[ \t]*//;s/[ \t]*$//' /etc/resolv.conf ;;
            7) > /etc/resolv.conf ;;
            0) break ;;
        esac
    done
}

bbr_tuning() {
    clear; echo -e "1.开启BBR 2.关闭BBR 3.TPS调优"; read -p "选择: " b
    if [ "$b" -eq 1 ]; then
        echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
        sysctl -p; echo -e "${GREEN}BBR开启！进阶参考：https://omnitt.com/${NC}"; sleep 3
    elif [ "$b" -eq 2 ]; then
        sed -i '/bbr/d;/fq/d' /etc/sysctl.conf; sysctl -p
    fi
}

swap_manager() {
    clear; echo -e "1.添加 2.删除"; read -p "选择: " s
    if [ "$s" -eq 1 ]; then
        read -p "大小(MB): " sz; dd if=/dev/zero of=/swapfile bs=1M count=$sz
        chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile
        echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
    elif [ "$s" -eq 2 ]; then
        swapoff /swapfile; rm -f /swapfile; sed -i '/\/swapfile/d' /etc/fstab
    fi
}

# --- 6. 统一 UI ---

show_header() {
    echo -e "${CYAN}################################################################${NC}"
    echo -e "${PURPLE}                江某人的万能脚本箱${NC}"
    echo -e "${CYAN}################################################################${NC}"
    echo -e "${YELLOW}系统:${NC} $OS_INFO  ${YELLOW}位置:${NC} $LOCATION"
    echo -e "${YELLOW}IPv4:${NC} $IPV4  ${YELLOW}IPv6:${NC} $IPV6"
    echo -e "${CYAN}----------------------------------------------------------------${NC}"
}

show_footer() {
    echo -e "${CYAN}----------------------------------------------------------------${NC}"
    echo -e "${YELLOW}我的个人博客：${NC}${BLUE}op.style${NC}"
    echo -e "${CYAN}################################################################${NC}"
}

main_menu() {
    while true; do
        get_system_info; clear; show_header
        echo -e "${GREEN}主菜单功能:${NC}"
        echo -e " 1. 安装必备基础命令 (bash/curl/git等)"
        echo -e " 2. 新机体检项目 (IP/网络/硬件/测评)"
        echo -e " 3. 科学上网工具 (3x-ui/Sing-box等)"
        echo -e " 4. 可视化面板安装 (1Panel/宝塔等)"
        echo -e " 5. 实用运维工具 (DNS/BBR/Swap/SSH)"
        echo -e " 0. 退出脚本"
        echo ""; show_footer
        read -p "输入数字: " choice
        case $choice in
            1) install_deps "bash curl wget git sudo lsof ca-certificates gzip unzip" ;;
            2) new_machine_check ;;
            3) science_tools ;;
            4) panel_tools ;;
            5) utility_tools ;;
            0) echo -e "${GREEN}感谢使用，江某人再见！${NC}"; exit 0 ;;
            *) sleep 1 ;;
        esac
    done
}

# 启动
main_menu
