#!/bin/bash

# ======================================================
# 脚本名称：江某人的万能脚本箱
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
    [ "$OS_RAW" = "alpine" ] && apk add --no-cache $deps || {
        [ -f /usr/bin/apt ] && apt update && apt install -y $deps
        [ -f /usr/bin/yum ] && yum install -y $deps
    }
}

run_script() {
    local name=$1; local github=$2; local command=$3; local is_alpine=$4
    if [ "$is_alpine" = "true" ] && [ "$OS_RAW" != "alpine" ]; then
        echo -e "${RED}❌ 该脚本仅支持 Alpine 系统！${NC}"; read -n 1 -s -r; return
    fi
    clear
    echo -e "${CYAN}----------------------------------------------------------------${NC}"
    echo -e "${YELLOW}启动：${NC}${GREEN}$name${NC}\n${YELLOW}项目：${NC}${BLUE}$github${NC}"
    echo -e "${CYAN}----------------------------------------------------------------${NC}"
    sleep 1; eval "$command"
    echo -e "\n${YELLOW}执行完毕。${NC}"; read -n 1 -s -r -p "按任意键返回..."
}

# --- 4. 实用工具集 ---

# DNS 管理器 (江某人定制)
dns_manager() {
    while true; do
        clear
        echo -e "${BLUE}>>> [ DNS 深度管理器 ]${NC}"
        echo -e "${CYAN}当前配置内容 (/etc/resolv.conf):${NC}"
        grep "nameserver" /etc/resolv.conf | nl -w2 -s'. '
        echo -e "${CYAN}----------------------------------------------------------------${NC}"
        echo -e " 1. 添加单个 DNS (例如 8.8.8.8)"
        echo -e " 2. 批量添加 DNS (空格或逗号分隔)"
        echo -e " 3. 修改特定行 DNS"
        echo -e " 4. 移动行位置 (向上/向下)"
        echo -e " 5. 一键添加公共 DNS (Google/Cloudflare/Ali)"
        echo -e " 6. 自动纠错并清理拼写错误"
        echo -e " 7. 一键清空所有配置"
        echo -e " 0. 返回主菜单"
        echo -e "${CYAN}----------------------------------------------------------------${NC}"
        read -p "选择操作: " dns_choice
        case $dns_choice in
            1) read -p "输入 IP: " ip; echo "nameserver $ip" >> /etc/resolv.conf ;;
            2) read -p "输入多个 IP (逗号或空格隔开): " ips
               for i in ${ips//,/ }; do echo "nameserver $i" >> /etc/resolv.conf; done ;;
            3) read -p "修改哪一行? " line_num; read -p "新 IP: " new_ip
               sed -i "${line_num}s/nameserver .*/nameserver $new_ip/" /etc/resolv.conf ;;
            4) read -p "操作行号: " l; read -p "方向(1.向上 2.向下): " d
               [[ $d -eq 1 ]] && { sed -i "${l}h;${l}d;$(($l-1))G" /etc/resolv.conf; } || { sed -i "${l}h;${l}d;$(($l+1))G" /etc/resolv.conf; } ;;
            5) echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1\nnameserver 223.5.5.5" >> /etc/resolv.conf ;;
            6) sed -i '/^nameserver/!d' /etc/resolv.conf; sed -i 's/^[ \t]*//;s/[ \t]*$//' /etc/resolv.conf ;;
            7) > /etc/resolv.conf ;;
            0) break ;;
        esac
    done
}

# BBR & TPS 调优
bbr_tuning() {
    clear
    echo -e "${BLUE}>>> [ BBR & 网络 TPS 调优 ]${NC}"
    echo -e " 1. 开启 BBR (标准内核支持)"
    echo -e " 2. 关闭 BBR"
    echo -e " 3. 系统 TPS 网络参数深度优化"
    echo -e " 0. 返回"
    read -p "选择: " b_choice
    case $b_choice in
        1)
            echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
            echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
            sysctl -p
            echo -e "${GREEN}BBR 已开启！${NC}"
            echo -e "${YELLOW}更多暴力 BBR 指令请参考：${BLUE}https://omnitt.com/${NC}"
            sleep 3 ;;
        2)
            sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
            sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
            sysctl -p ;;
        3)
            echo "net.ipv4.tcp_fastopen=3" >> /etc/sysctl.conf
            echo "net.ipv4.tcp_slow_start_after_idle=0" >> /etc/sysctl.conf
            sysctl -p
            echo -e "${GREEN}网络 TPS 已调优！${NC}" ;;
    esac
}

# 额外福利：Swap 管理
swap_manager() {
    clear
    echo -e "${BLUE}>>> [ Swap 虚拟内存管理 ]${NC}"
    echo -e " 1. 添加 Swap"
    echo -e " 2. 删除 Swap"
    read -p "选择: " s_choice
    case $s_choice in
        1)
            read -p "请输入 Swap 大小 (MB, 建议为物理内存 2 倍): " size
            dd if=/dev/zero of=/swapfile bs=1M count=$size
            chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile
            echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
            echo -e "${GREEN}Swap 设置成功！${NC}" ;;
        2)
            swapoff /swapfile && rm -f /swapfile
            sed -i '/\/swapfile swap/d' /etc/fstab
            echo -e "${YELLOW}Swap 已卸载。${NC}" ;;
    esac
    sleep 2
}

# --- 5. 菜单结构 ---

new_machine_check() {
    while true; do
        clear; show_header
        echo -e "${BLUE}>>> [ 新机体检项目 ]${NC}"
        echo -e " 1. IP 质量检测 (xykt/IPQuality)\n 2. 网络质量检测 (xykt/NetQuality)\n 3. 硬件质量检测 (xykt/HardwareQuality)\n 4. 三网回程路由测试 (zhanghanyun/backtrace)\n 5. NodeQuality 检测脚本\n 6. 融合怪测评 - GO版本\n 7. 流媒体解锁检测\n 8. “更准确”流媒体解锁检测\n 0. 返回"
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

science_tools() {
    while true; do
        clear; show_header
        echo -e "${BLUE}>>> [ 科学上网工具 ]${NC}"
        echo -e " 1. 原版 3x-ui (2.6.2)\n 2. Alpine版 3x-ui (仅限Alpine)\n 3. Sing-box-yg 精装桶 (慎用)\n 4. yoyo sing-box 一键\n 5. 欢妹 3X-UI-Alpine (仅限Alpine)\n 0. 返回"
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

utility_tools() {
    while true; do
        clear; show_header
        echo -e "${BLUE}>>> [ 实用工具箱 ]${NC}"
        echo -e " 1. DNS 深度管理\n 2. BBR & TPS 调优\n 3. Swap 虚拟内存管理\n 4. 修改 SSH 端口 (防扫爆破)\n 0. 返回"
        read -p "选择: " c
        case $c in
            1) dns_manager ;;
            2) bbr_tuning ;;
            3) swap_manager ;;
            4) read -p "输入新端口: " port; sed -i "s/#Port 22/Port $port/g;s/Port .*/Port $port/g" /etc/ssh/sshd_config; systemctl restart sshd; echo -e "${GREEN}端口已改为 $port，请确保防火墙已放行！${NC}"; sleep 3 ;;
            0) break ;;
        esac
    done
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
        echo -e " 1. 安装必备基础命令\n 2. 新机体检项目\n 3. 科学上网工具\n 4. 可视化面板安装\n 5. 实用运维工具 (DNS/BBR/Swap)\n 0. 退出脚本"
        echo ""; show_footer
        read -p "输入数字: " choice
        case $choice in
            1) install_deps "bash curl wget git sudo lsof ca-certificates gzip" ;;
            2) new_machine_check ;;
            3) science_tools ;;
            4) run_script "1Panel" "1panel.cn" "curl -sSL https://resource.fit2cloud.com/1panel/package/quick_start.sh -o quick_start.sh && bash quick_start.sh" "false" ;;
            5) utility_tools ;;
            0) exit 0 ;;
            *) sleep 1 ;;
        esac
    done
}

main_menu
