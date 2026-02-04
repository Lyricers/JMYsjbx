#!/bin/bash

# ======================================================
# 脚本名称：江某人的万能脚本箱 (Pro UI Edition)
# 核心作者：Gemini (for 江某人)
# 博客地址：op.style
# ======================================================

# --- 1. 颜色与样式定义 ---
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[35m'
CYAN='\033[36m'
WHITE='\033[37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# 检查 Root 权限
[[ $(id -u) != "0" ]] && echo -e "${RED}❌ 错误: 必须使用 root 权限运行此脚本！${NC}" && exit 1

# --- 2. 系统信息采集 ---
get_system_info() {
    # 系统内核
    if [ -f /etc/os-release ]; then
        OS_RAW=$(cat /etc/os-release | grep -w "ID" | cut -d= -f2 | tr -d '"')
        OS_INFO=$(cat /etc/os-release | grep -w "PRETTY_NAME" | cut -d= -f2 | tr -d '"')
    else
        OS_RAW="unknown"; OS_INFO=$(uname -srm)
    fi
    
    # 内存使用率
    if command -v free >/dev/null 2>&1; then
        MEM_USED=$(free -m | awk '/Mem:/ { print $3 }')
        MEM_TOTAL=$(free -m | awk '/Mem:/ { print $2 }')
        MEM_INFO="${MEM_USED}MB / ${MEM_TOTAL}MB"
    else
        MEM_INFO="未知"
    fi

    # 网络信息 (带超时防止卡顿)
    IPV4=$(curl -s4 --connect-timeout 3 ifconfig.me || echo "N/A")
    IPV6=$(curl -s6 --connect-timeout 3 ifconfig.me || echo "N/A")
    
    # 地理位置
    IP_JSON=$(curl -s --connect-timeout 3 http://ip-api.com/json/)
    if [[ $IP_JSON == *"success"* ]]; then
        COUNTRY=$(echo $IP_JSON | sed 's/.*"country":"\([^"]*\)".*/\1/')
        CITY=$(echo $IP_JSON | sed 's/.*"city":"\([^"]*\)".*/\1/')
        ISP=$(echo $IP_JSON | sed 's/.*"isp":"\([^"]*\)".*/\1/')
        LOCATION="$COUNTRY - $CITY"
    else
        LOCATION="未知位置"
        ISP="未知运营商"
    fi
}

# --- 3. 基础工具函数 ---
install_deps() {
    local deps=$@
    echo -e "${YELLOW}⚙️  正在检查并安装依赖: ${CYAN}$deps${NC}"
    if [ "$OS_RAW" = "alpine" ]; then
        apk add --no-cache $deps
    elif [ -f /usr/bin/apt ]; then
        apt update -y >/dev/null 2>&1 && apt install -y $deps
    elif [ -f /usr/bin/yum ]; then
        yum install -y $deps
    elif [ -f /usr/bin/dnf ]; then
        dnf install -y $deps
    fi
}

run_script() {
    local name=$1; local github=$2; local command=$3; local is_alpine=$4
    if [ "$is_alpine" = "true" ] && [ "$OS_RAW" != "alpine" ]; then
        echo -e "${RED}❌ 错误：脚本 [ $name ] 仅支持 Alpine 系统！${NC}"
        read -n 1 -s -r -p "按任意键返回..."
        return
    fi
    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "🚀 ${BOLD}正在启动：${WHITE}$name${NC}"
    echo -e "🔗 ${BOLD}开源地址：${BLUE}$github${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    sleep 1; eval "$command"
    echo -e "\n${GREEN}✅ 执行完毕。${NC}"; read -n 1 -s -r -p "按任意键返回主菜单..."
}

# --- 4. 核心功能菜单 ---

# 4.1 新机体检
new_machine_check() {
    while true; do
        clear; show_header
        echo -e "${BOLD}${CYAN}   >>> 📊 新机体检项目 ${NC}"
        echo -e "${CYAN}   --------------------------------------------------------${NC}"
        echo -e "   ${GREEN}1.${NC} 🌍 IP 质量检测 (xykt/IPQuality)"
        echo -e "   ${GREEN}2.${NC} 🚀 网络质量检测 (xykt/NetQuality)"
        echo -e "   ${GREEN}3.${NC} 💻 硬件质量检测 (xykt/HardwareQuality)"
        echo -e "   ${GREEN}4.${NC} 📡 三网回程路由测试 (Backtrace)"
        echo -e "   ${GREEN}5.${NC} ⚡ NodeQuality 节点检测"
        echo -e "   ${GREEN}6.${NC} 👹 融合怪测评 - GO版本 (Spiritlhl)"
        echo -e "   ${GREEN}7.${NC} 🎬 流媒体解锁检测 (HsukqiLee)"
        echo -e "   ${GREEN}8.${NC} 🎥 “更准确”流媒体解锁检测 (1-stream)"
        echo -e "   ${GREEN}0.${NC} 🔙 返回主菜单"
        echo ""
        read -p "   请选择操作 [0-8]: " c
        case $c in
            1) run_script "IP 质量检测" "xykt/IPQuality" "bash <(curl -Ls https://IP.Check.Place) -y" "false" ;;
            2) run_script "网络质量检测" "xykt/NetQuality" "bash <(curl -Ls https://Net.Check.Place) -y" "false" ;;
            3) run_script "硬件质量检测" "xykt/HardwareQuality" "bash <(curl -Ls https://Hardware.Check.Place) -y" "false" ;;
            4) run_script "三网回程测试" "zhanghanyun/backtrace" "curl https://raw.githubusercontent.com/zhanghanyun/backtrace/main/install.sh -sSf | sh" "false" ;;
            5) run_script "NodeQuality" "LloydAsp/NodeQuality" "bash <(curl -sL https://run.NodeQuality.com)" "false" ;;
            6) run_script "融合怪测评-GO" "oneclickvirt/ecs" "export noninteractive=true && curl -L https://cdn.spiritlhl.net/https://raw.githubusercontent.com/oneclickvirt/ecs/master/goecs.sh -o goecs.sh && chmod +x goecs.sh && ./goecs.sh install && goecs" "false" ;;
            7) run_script "流媒体解锁" "HsukqiLee/MediaUnlockTest" "bash <(curl -Ls unlock.icmp.ing/scripts/test.sh)" "false" ;;
            8) run_script "流媒体解锁(深)" "1-stream/Check" "bash <(curl -L -s https://raw.githubusercontent.com/1-stream/RegionRestrictionCheck/main/check.sh)" "false" ;;
            0) break ;;
        esac
    done
}

# 4.2 科学上网
science_tools() {
    while true; do
        clear; show_header
        echo -e "${BOLD}${CYAN}   >>> 🪜 科学上网工具 ${NC}"
        echo -e "${CYAN}   --------------------------------------------------------${NC}"
        echo -e "   ${GREEN}1.${NC} 📦 原版 3x-ui (v2.6.2)"
        echo -e "   ${GREEN}2.${NC} ❄️ 适配 Alpine 版旧 3x-ui ${RED}(仅限Alpine)${NC}"
        echo -e "   ${GREEN}3.${NC} 📦 Sing-box-yg 精装桶 ${RED}(争议脚本/慎用)${NC}"
        echo -e "   ${GREEN}4.${NC} 🚀 yoyo sing-box 一键部署"
        echo -e "   ${GREEN}5.${NC} ❄️ 欢妹 3X-UI-Alpine ${RED}(仅限Alpine)${NC}"
        echo -e "   ${GREEN}0.${NC} 🔙 返回主菜单"
        echo ""
        read -p "   请选择操作 [0-5]: " c
        case $c in
            1) run_script "原版 3x-ui" "MHSanaei/3x-ui" "bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) v2.6.2" "false" ;;
            2) install_deps "curl bash gzip"; run_script "Alpine-3x-ui" "56idc/3x-ui-alpine" "bash <(curl -Ls https://raw.githubusercontent.com/56idc/3x-ui-alpine/master/install_alpine.sh)" "true" ;;
            3) run_script "Sing-box-yg" "yonggekkk/sing-box-yg" "bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/sing-box-yg/main/sb.sh)" "false" ;;
            4) run_script "yoyo-singbox" "caigouzi121380/singbox-deploy" "bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/caigouzi121380/singbox-deploy/main/install-singbox-yyds.sh)\"" "false" ;;
            5) install_deps "curl bash gzip openssl"; run_script "欢妹Alpine" "StarVM/3x-ui-Apline" "bash <(curl -Ls https://raw.githubusercontent.com/StarVM-OpenSource/3x-ui-Apline/refs/heads/main/install.sh)" "true" ;;
            0) break ;;
        esac
    done
}

# 4.3 可视化面板
panel_tools() {
    while true; do
        clear; show_header
        echo -e "${BOLD}${CYAN}   >>> 🖥️  可视化管理面板 ${NC}"
        echo -e "${CYAN}   --------------------------------------------------------${NC}"
        echo -e "   ${GREEN}1.${NC} 🐳 1Panel 官方版 (推荐：现代化 Docker 管理)"
        echo -e "   ${GREEN}2.${NC} 🏰 宝塔面板 (国内流行版本)"
        echo -e "   ${GREEN}3.${NC} 🌐 aaPanel (宝塔国际版：无需手机号)"
        echo -e "   ${GREEN}4.${NC} 🏠 CasaOS (超高颜值极简家庭云)"
        echo -e "   ${GREEN}0.${NC} 🔙 返回主菜单"
        echo ""
        read -p "   请选择操作 [0-4]: " c
        case $c in
            1) run_script "1Panel" "1panel.cn" "curl -sSL https://resource.fit2cloud.com/1panel/package/quick_start.sh -o quick_start.sh && bash quick_start.sh" "false" ;;
            2) run_script "宝塔面板" "bt.cn" "if [ -f /usr/bin/curl ];then curl -sSO https://download.bt.cn/install/install_panel.sh;else wget -O install_panel.sh https://download.bt.cn/install/install_panel.sh;fi && bash install_panel.sh ed8484bec" "false" ;;
            3) run_script "aaPanel" "aapanel.com" "wget -O install.sh http://www.aapanel.com/script/install_6.0_en.sh && bash install.sh" "false" ;;
            4) run_script "CasaOS" "casaos.io" "curl -fsSL https://get.casaos.io | bash" "false" ;;
            0) break ;;
        esac
    done
}

# 4.4 实用工具 (已添加哪吒卸载)
utility_tools() {
    while true; do
        clear; show_header
        echo -e "${BOLD}${CYAN}   >>> 🛠️  实用运维工具箱 ${NC}"
        echo -e "${CYAN}   --------------------------------------------------------${NC}"
        echo -e "   ${GREEN}1.${NC} 🌐 DNS 深度管理 (添加/排序/纠错)"
        echo -e "   ${GREEN}2.${NC} 🚀 BBR & TPS 调优 (开启/关闭/进阶)"
        echo -e "   ${GREEN}3.${NC} 🧠 Swap 虚拟内存管理 (添加/删除)"
        echo -e "   ${GREEN}4.${NC} 🛡️ 修改 SSH 端口 (防爆破)"
        echo -e "   ${GREEN}5.${NC} 🗑️ 哪吒探针 Agent 卸载工具 (Nezha-cleaner)"
        echo -e "   ${GREEN}0.${NC} 🔙 返回主菜单"
        echo ""
        read -p "   请选择操作 [0-5]: " c
        case $c in
            1) dns_manager ;;
            2) bbr_tuning ;;
            3) swap_manager ;;
            4) read -p "输入新端口: " port; sed -i "s/#Port 22/Port $port/g;s/Port .*/Port $port/g" /etc/ssh/sshd_config; systemctl restart sshd; echo -e "${GREEN}端口已改为 $port，请放行防火墙！${NC}"; sleep 2 ;;
            5) run_script "哪吒探针卸载" "everett7623/Nezha-cleaner" "bash <(curl -s https://raw.githubusercontent.com/everett7623/Nezha-cleaner/main/nezha-agent-cleaner.sh)" "false" ;;
            0) break ;;
        esac
    done
}

# --- 5. 深度逻辑函数 ---

dns_manager() {
    while true; do
        clear; echo -e "${CYAN}=== DNS 管理器 (当前配置) ===${NC}"; grep "nameserver" /etc/resolv.conf | nl -w2 -s'. '
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
    clear; echo -e "${CYAN}=== BBR 管理 ===${NC}\n1.开启BBR 2.关闭BBR 3.TPS调优"; read -p "选择: " b
    if [ "$b" -eq 1 ]; then
        echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
        sysctl -p; echo -e "${GREEN}BBR开启！进阶参考：https://omnitt.com/${NC}"; sleep 3
    elif [ "$b" -eq 2 ]; then
        sed -i '/bbr/d;/fq/d' /etc/sysctl.conf; sysctl -p
    fi
}

swap_manager() {
    clear; echo -e "${CYAN}=== Swap 管理 ===${NC}\n1.添加 2.删除"; read -p "选择: " s
    if [ "$s" -eq 1 ]; then
        read -p "大小(MB): " sz; dd if=/dev/zero of=/swapfile bs=1M count=$sz
        chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile
        echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
    elif [ "$s" -eq 2 ]; then
        swapoff /swapfile; rm -f /swapfile; sed -i '/\/swapfile/d' /etc/fstab
    fi
}

# --- 6. 统一 UI 界面 ---

show_header() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${PURPLE}          🎉 江某人的万能脚本箱 ${YELLOW}| ${GREEN}J's Toolbox v2.0 ${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "   💻 ${BOLD}系统信息:${NC} $OS_INFO"
    echo -e "   🧠 ${BOLD}内存占用:${NC} $MEM_INFO"
    echo -e "   🌍 ${BOLD}地理位置:${NC} $LOCATION ($ISP)"
    echo -e "   📡 ${BOLD}网络地址:${NC} ${BLUE}$IPV4${NC} (IPv4)"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

show_footer() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "   🌐 ${BOLD}我的个人博客：${BLUE}op.style${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

main_menu() {
    while true; do
        get_system_info
        clear
        show_header
        echo -e "   ${BOLD}请选择功能模块：${NC}"
        echo -e "${CYAN}   --------------------------------------------------------${NC}"
        echo -e "   ${GREEN}1.${NC} 🔧 安装必备基础命令 (curl/wget/git/gzip)"
        echo -e "   ${GREEN}2.${NC} 📊 新机体检项目 (IP/网络/硬件/流媒体)"
        echo -e "   ${GREEN}3.${NC} 🪜 科学上网工具 (3x-ui/Sing-box/Alpine适配)"
        echo -e "   ${GREEN}4.${NC} 🖥️  可视化面板安装 (1Panel/宝塔/CasaOS)"
        echo -e "   ${GREEN}5.${NC} 🛠️  实用运维工具 (DNS/BBR/Swap/哪吒卸载)"
        echo -e "${CYAN}   --------------------------------------------------------${NC}"
        echo -e "   ${GREEN}0.${NC} ❌ 退出脚本"
        echo ""
        show_footer
        read -p "   请输入数字 [0-5]: " choice
        case $choice in
            1) install_deps "bash curl wget git sudo lsof ca-certificates gzip" ;;
            2) new_machine_check ;;
            3) science_tools ;;
            4) panel_tools ;;
            5) utility_tools ;;
            0) echo -e "\n${GREEN}👋 感谢使用，再见，江某人！${NC}"; exit 0 ;;
            *) sleep 1 ;;
        esac
    done
}

# 启动脚本
main_menu
