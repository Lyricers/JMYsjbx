#!/bin/bash

# ======================================================
# 脚本名称：江某人的万能脚本箱 (v5.0 Comfort Edition)
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
NC='\033[0m'

# 检查 Root 权限
[[ $(id -u) != "0" ]] && echo -e "${RED}❌ 错误: 必须使用 root 权限运行！${NC}" && exit 1

# --- 2. 系统信息采集 ---
get_system_info() {
    if [ -f /etc/os-release ]; then
        OS_RAW=$(cat /etc/os-release | grep -w "ID" | cut -d= -f2 | tr -d '"')
        OS_INFO=$(cat /etc/os-release | grep -w "PRETTY_NAME" | cut -d= -f2 | tr -d '"')
    else
        OS_RAW="unknown"; OS_INFO=$(uname -srm)
    fi
    
    if command -v free >/dev/null 2>&1; then
        MEM_USED=$(free -m | awk '/Mem:/ { print $3 }'); MEM_TOTAL=$(free -m | awk '/Mem:/ { print $2 }')
        MEM_INFO="${MEM_USED}MB / ${MEM_TOTAL}MB"
    else
        MEM_INFO="未知"
    fi

    IPV4=$(curl -s4 --connect-timeout 2 ifconfig.me || echo "N/A")
    IPV6=$(curl -s6 --connect-timeout 2 ifconfig.me || echo "N/A")
    IP_JSON=$(curl -s --connect-timeout 2 http://ip-api.com/json/)
    if [[ $IP_JSON == *"success"* ]]; then
        LOCATION=$(echo $IP_JSON | sed 's/.*"country":"\([^"]*\)".*/\1/')
        ISP=$(echo $IP_JSON | sed 's/.*"isp":"\([^"]*\)".*/\1/')
    else
        LOCATION="未知"; ISP="未知运营商"
    fi
}

# --- 3. 核心工具函数 ---
install_deps() {
    local deps=$@
    if [ "$OS_RAW" = "alpine" ]; then apk add --no-cache $deps
    elif [ -f /usr/bin/apt ]; then apt update -y >/dev/null 2>&1 && apt install -y $deps
    elif [ -f /usr/bin/yum ]; then yum install -y $deps
    elif [ -f /usr/bin/dnf ]; then dnf install -y $deps; fi
}

run_script() {
    local name=$1; local github=$2; local command=$3; local is_alpine=$4
    if [ "$is_alpine" = "true" ] && [ "$OS_RAW" != "alpine" ]; then
        echo -e "${RED}❌ 错误：[ $name ] 仅支持 Alpine 系统！${NC}"; read -n 1 -s -r -p "按任意键返回..."; return
    fi
    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "🚀 ${BOLD}正在启动：${WHITE}$name${NC}"
    echo -e "🔗 ${BOLD}项目地址：${BLUE}$github${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    sleep 1; eval "$command"
    echo -e "\n${GREEN}✅ 执行完毕。${NC}"; read -n 1 -s -r -p "按任意键返回主菜单..."
}

# --- 4. 深度运维逻辑 ---
dns_manager() {
    while true; do
        clear; echo -e "${CYAN}=== DNS 管理器 ===${NC}"; grep "nameserver" /etc/resolv.conf | nl -w2 -s'. '
        echo -e "----------------------------------\n1.添加 2.批量 3.修改 4.移动 5.公共 6.纠错 7.清空 0.返回"
        read -p "操作: " d
        case $d in
            1) read -p "IP: " ip; echo "nameserver $ip" >> /etc/resolv.conf ;;
            2) read -p "IPs: " ips; for i in ${ips//,/ }; do echo "nameserver $i" >> /etc/resolv.conf; done ;;
            3) read -p "行: " l; read -p "新IP: " ni; sed -i "${l}s/nameserver .*/nameserver $ni/" /etc/resolv.conf ;;
            4) read -p "行: " l; read -p "方向(1.上 2.下): " dr; [[ $dr -eq 1 ]] && { sed -i "${l}h;${l}d;$(($l-1))G" /etc/resolv.conf; } || { sed -i "${l}h;${l}d;$(($l+1))G" /etc/resolv.conf; } ;;
            5) echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" >> /etc/resolv.conf ;;
            6) sed -i '/^nameserver/!d' /etc/resolv.conf; sed -i 's/^[ \t]*//;s/[ \t]*$//' /etc/resolv.conf ;;
            7) > /etc/resolv.conf ;;
            0) break ;;
        esac
    done
}

bbr_tuning() {
    clear; echo -e "${CYAN}=== BBR & TPS 管理 ===${NC}\n1.开启BBR 2.关闭BBR 3.TPS调优"; read -p "选择: " b
    if [ "$b" -eq 1 ]; then
        echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
        sysctl -p; echo -e "${GREEN}BBR开启！参考：https://omnitt.com/${NC}"; sleep 3
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

# --- 5. UI 绘制 ---
show_header() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${PURPLE}          🎉 江某人的万能脚本箱 ${YELLOW}| ${GREEN}Toolbox v5.0 ${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "   💻 ${BOLD}系统:${NC} $OS_INFO   🧠 ${BOLD}内存:${NC} $MEM_INFO"
    echo -e "   🌍 ${BOLD}位置:${NC} $LOCATION ($ISP)"
    echo -e "   📡 ${BOLD}网络:${NC} ${BLUE}$IPV4${NC} (IPv4) | ${BLUE}${IPV6:0:15}...${NC} (IPv6)"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# --- 6. 主平铺页面 (双列舒适布局) ---
main_menu() {
    while true; do
        get_system_info; clear; show_header
        
        # 1. 基础
        echo -e "${BOLD}${YELLOW} [1] 基础环境 ${NC}"
        echo -e " 1. 安装必备基础命令 (curl/wget/git/gzip)"
        echo -e "${CYAN} ---------------------------------------------------------- ${NC}"
        
        # 2. 体检
        echo -e "${BOLD}${YELLOW} [2] 新机体检项目 ${NC}"
        echo -e " 2. IP 质量检测           3. 网络质量检测"
        echo -e " 4. 硬件质量检测          5. 三网回程路由"
        echo -e " 6. NodeQuality 检测      7. 融合怪测评 (GO)"
        echo -e " 8. 流媒体解锁检测        9. 流媒体深度检测"
        echo -e "${CYAN} ---------------------------------------------------------- ${NC}"

        # 3. 科学
        echo -e "${BOLD}${YELLOW} [3] 科学上网工具 ${NC}"
        echo -e " 10. 原版 3x-ui           11. Alpine版 3x-ui"
        echo -e " 12. Sing-box-yg 精装     13. yoyo sing-box 一键"
        echo -e " 14. 欢妹 Alpine UI"
        echo -e "${CYAN} ---------------------------------------------------------- ${NC}"

        # 4. 面板
        echo -e "${BOLD}${YELLOW} [4] 可视化管理面板 ${NC}"
        echo -e " 15. 1Panel 官方版        16. 宝塔面板"
        echo -e " 17. aaPanel (国际版)     18. CasaOS 极简"
        echo -e "${CYAN} ---------------------------------------------------------- ${NC}"

        # 5. 运维
        echo -e "${BOLD}${YELLOW} [5] 运维 & 网络 & 综合 ${NC}"
        echo -e " 19. DNS 深度管理         20. BBR & TPS 调优"
        echo -e " 21. Swap 虚拟内存        22. 修改 SSH 端口"
        echo -e " 23. 哪吒 Agent 卸载      24. ${RED}BBR v3 Ultimate${NC}"
        echo -e " 25. Realm 转发管理       26. AkileDNS 解锁"
        echo -e " 27. 科技Lion工具箱"
        echo -e "${CYAN} ---------------------------------------------------------- ${NC}"

        echo -e "   ${GREEN}0.${NC} ❌ 退出脚本"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "   🌐 ${BOLD}我的个人博客：${BLUE}op.style${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

        read -p " 请输入序号执行功能: " choice
        case $choice in
            1) install_deps "bash curl wget git sudo lsof ca-certificates gzip" ;;
            # 体检
            2) run_script "IP质量" "xykt/IPQuality" "bash <(curl -Ls https://IP.Check.Place) -y" "false" ;;
            3) run_script "网络质量" "xykt/NetQuality" "bash <(curl -Ls https://Net.Check.Place) -y" "false" ;;
            4) run_script "硬件质量" "xykt/HardwareQuality" "bash <(curl -Ls https://Hardware.Check.Place) -y" "false" ;;
            5) run_script "三网回程" "zhanghanyun/backtrace" "curl https://raw.githubusercontent.com/zhanghanyun/backtrace/main/install.sh -sSf | sh" "false" ;;
            6) run_script "NodeQuality" "LloydAsp/NodeQuality" "bash <(curl -sL https://run.NodeQuality.com)" "false" ;;
            7) run_script "融合怪测评" "oneclickvirt/ecs" "export noninteractive=true && curl -L https://cdn.spiritlhl.net/https://raw.githubusercontent.com/oneclickvirt/ecs/master/goecs.sh -o goecs.sh && chmod +x goecs.sh && ./goecs.sh install && goecs" "false" ;;
            8) run_script "流媒体解锁" "HsukqiLee/MediaUnlockTest" "bash <(curl -Ls unlock.icmp.ing/scripts/test.sh)" "false" ;;
            9) run_script "流媒体解锁(深)" "1-stream/Check" "bash <(curl -L -s https://raw.githubusercontent.com/1-stream/RegionRestrictionCheck/main/check.sh)" "false" ;;
            # 科学
            10) run_script "原版 3x-ui" "MHSanaei/3x-ui" "bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) v2.6.2" "false" ;;
            11) install_deps "curl bash gzip"; run_script "Alpine-3x-ui" "56idc/3x-ui-alpine" "bash <(curl -Ls https://raw.githubusercontent.com/56idc/3x-ui-alpine/master/install_alpine.sh)" "true" ;;
            12) run_script "Sing-box-yg" "yonggekkk/sing-box-yg" "bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/sing-box-yg/main/sb.sh)" "false" ;;
            13) run_script "yoyo-singbox" "caigouzi121380/singbox-deploy" "bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/caigouzi121380/singbox-deploy/main/install-singbox-yyds.sh)\"" "false" ;;
            14) install_deps "curl bash gzip openssl"; run_script "欢妹Alpine" "StarVM/3x-ui-Apline" "bash <(curl -Ls https://raw.githubusercontent.com/StarVM-OpenSource/3x-ui-Apline/refs/heads/main/install.sh)" "true" ;;
            # 面板
            15) run_script "1Panel" "1panel.cn" "curl -sSL https://resource.fit2cloud.com/1panel/package/quick_start.sh -o quick_start.sh && bash quick_start.sh" "false" ;;
            16) run_script "宝塔" "bt.cn" "curl -sSO https://download.bt.cn/install/install_panel.sh && bash install_panel.sh ed8484bec" "false" ;;
            17) run_script "aaPanel" "aapanel.com" "wget -O install.sh http://www.aapanel.com/script/install_6.0_en.sh && bash install.sh" "false" ;;
            18) run_script "CasaOS" "casaos.io" "curl -fsSL https://get.casaos.io | bash" "false" ;;
            # 工具
            19) dns_manager ;;
            20) bbr_tuning ;;
            21) swap_manager ;;
            22) read -p "新端口: " p; sed -i "s/Port .*/Port $p/" /etc/ssh/sshd_config; systemctl restart sshd; sleep 1 ;;
            23) run_script "哪吒卸载" "everett7623/Nezha-cleaner" "bash <(curl -s https://raw.githubusercontent.com/everett7623/Nezha-cleaner/main/nezha-agent-cleaner.sh)" "false" ;;
            24) 
                install_deps "curl"
                run_script "BBR v3 Ultimate" "Eric86777/vps-tcp-tune" "bash <(curl -fsSL \"https://raw.githubusercontent.com/Eric86777/vps-tcp-tune/main/install-alias.sh?\$(date +%s)\") && bash /root/.vps-tcp-tune/tcp.sh" "false" ;;
            25) run_script "Realm 转发管理" "hiapb/hia-realm" "bash <(curl -fsSL https://raw.githubusercontent.com/hiapb/hia-realm/main/install.sh)" "false" ;;
            26) 
                install_deps "wget"
                echo -e "${YELLOW}提示：运行后请配合 ${BLUE}https://dns.akile.ai/${YELLOW} 使用${NC}"
                run_script "AkileDNS 官方脚本" "akile-network/aktools" "wget -qO- https://raw.githubusercontent.com/akile-network/aktools/refs/heads/main/akdns.sh | bash" "false" ;;
            27) run_script "科技Lion工具箱" "kejilion.pro" "curl -sS -O https://kejilion.pro/kejilion.sh && chmod +x kejilion.sh && ./kejilion.sh" "false" ;;
            0) 
               echo -e "\n${YELLOW}⚠️  提示：${WHITE}如安装了BBR v3，请执行 ${CYAN}source ~/.bashrc${NC}"
               echo -e "${GREEN}👋 感谢使用，江某人再见！${NC}"; exit 0 ;;
            *) sleep 1 ;;
        esac
    done
}

# 启动
main_menu
