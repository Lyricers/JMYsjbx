#!/bin/bash

# ======================================================
# 脚本名称：江某人的万能脚本箱 (v9.0 Quick Launch Edition)
# 核心作者：Gemini
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

# --- 2. 自动设置全局快捷指令 (核心更新) ---
install_shortcut() {
    local cmd_name="jmy"
    local script_url="https://myno.uk/jmx"
    local bin_path="/usr/local/bin/${cmd_name}"
    
    # 兼容某些没有 /usr/local/bin 的系统 (如部分 Alpine 精简版)
    [ ! -d "/usr/local/bin" ] && bin_path="/usr/bin/${cmd_name}"
    
    if [ ! -f "$bin_path" ]; then
        echo '#!/bin/bash' > "$bin_path"
        echo "bash <(curl -Ls ${script_url})" >> "$bin_path"
        chmod +x "$bin_path"
    fi
}
# 启动时静默安装快捷方式
install_shortcut

# --- 3. 系统信息采集 ---
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

# --- 4. 核心工具函数 ---
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
        echo -e "\n${RED}❌ 错误：[ $name ] 仅支持 Alpine 系统！${NC}"
        read -n 1 -s -r -p "按任意键返回..."
        return
    fi
    
    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "🚀 ${BOLD}即将启动：${WHITE}$name${NC}"
    echo -e "🔗 ${BOLD}项目地址：${BLUE}$github${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    echo -e "为防止误触，请确认启动脚本正确无误后输入${GREEN}任意键${NC}开始执行脚本，否则请输入“${RED}N${NC}”返回脚本列表。"
    read -n 1 -s -r confirm
    if [[ "${confirm}" == "N" || "${confirm}" == "n" ]]; then
        echo -e "\n${YELLOW}已取消执行，正在返回...${NC}"
        sleep 1
        return
    fi
    
    echo -e "\n${GREEN}▶ 开始执行...${NC}\n"
    sleep 1
    eval "$command"
    echo -e "\n${GREEN}✅ 执行完毕。${NC}"
    read -n 1 -s -r -p "按任意键返回主菜单..."
}

# --- 5. 深度运维逻辑 ---
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
            5) clear; echo -e "1. 阿里DNS  2. 腾讯DNS  3. Google  4. Cloudflare  5. Quad9  6. 综合套餐  0. 取消"
               read -p "选择: " pd
               case $pd in
                   1) echo -e "nameserver 223.5.5.5\nnameserver 223.6.6.6\nnameserver 2400:3200::1\nnameserver 2400:3200:baba::1" >> /etc/resolv.conf ;;
                   2) echo -e "nameserver 119.29.29.29\nnameserver 119.28.28.28\nnameserver 2402:4e00::" >> /etc/resolv.conf ;;
                   3) echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4\nnameserver 2001:4860:4860::8888\nnameserver 2001:4860:4860::8844" >> /etc/resolv.conf ;;
                   4) echo -e "nameserver 1.1.1.1\nnameserver 1.0.0.1\nnameserver 2606:4700:4700::1111\nnameserver 2606:4700:4700::1001" >> /etc/resolv.conf ;;
                   5) echo -e "nameserver 9.9.9.9\nnameserver 149.112.112.112\nnameserver 2620:fe::fe\nnameserver 2620:fe::9" >> /etc/resolv.conf ;;
                   6) echo -e "nameserver 223.5.5.5\nnameserver 119.29.29.29\nnameserver 8.8.8.8\nnameserver 1.1.1.1\nnameserver 2400:3200::1\nnameserver 2402:4e00::\nnameserver 2001:4860:4860::8888\nnameserver 2606:4700:4700::1111" >> /etc/resolv.conf ;;
               esac ;;
            6) sed -i '/^nameserver/!d' /etc/resolv.conf; sed -i 's/^[ \t]*//;s/[ \t]*$//' /etc/resolv.conf ;;
            7) > /etc/resolv.conf ;;
            0) break ;;
            *) echo -e "\n${RED}❌ 无效输入！${NC}"; read -n 1 -s -r -p "按任意键继续..." ;;
        esac
    done
}

bbr_tuning() {
    clear; echo -e "${CYAN}=== BBR & TPS 管理 ===${NC}\n1.开启BBR 2.关闭BBR 3.TPS调优 0.返回"; read -p "选择: " b
    case $b in
        1) echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf; echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf; sysctl -p; echo -e "${GREEN}BBR开启！参考：https://omnitt.com/${NC}"; read -n 1 -s -r -p "按任意键继续..." ;;
        2) sed -i '/bbr/d;/fq/d' /etc/sysctl.conf; sysctl -p; read -n 1 -s -r -p "按任意键继续..." ;;
        3) echo "net.ipv4.tcp_fastopen=3" >> /etc/sysctl.conf; sysctl -p; read -n 1 -s -r -p "按任意键继续..." ;;
        0) return ;;
        *) echo -e "\n${RED}❌ 无效输入！${NC}"; read -n 1 -s -r -p "按任意键继续..." ;;
    esac
}

swap_manager() {
    clear; echo -e "${CYAN}=== Swap 管理 ===${NC}\n1.添加 2.删除 0.返回"; read -p "选择: " s
    case $s in
        1) read -p "大小(MB): " sz; dd if=/dev/zero of=/swapfile bs=1M count=$sz; chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile; echo "/swapfile swap swap defaults 0 0" >> /etc/fstab; echo -e "${GREEN}Swap 添加成功！${NC}"; read -n 1 -s -r -p "按任意键继续..." ;;
        2) swapoff /swapfile; rm -f /swapfile; sed -i '/\/swapfile/d' /etc/fstab; read -n 1 -s -r -p "按任意键继续..." ;;
        0) return ;;
        *) echo -e "\n${RED}❌ 无效输入！${NC}"; read -n 1 -s -r -p "按任意键继续..." ;;
    esac
}

oneclickvirt_ecs() {
    while true; do
        clear; show_header
        echo -e "${BOLD}${CYAN}   >>> 👹 融合怪测评 (多节点选择) ${NC}"
        echo -e "${CYAN}   --------------------------------------------------------${NC}"
        echo -e "   ${GREEN}1.${NC} 🌍 国际用户 (无 CDN)       ${GREEN}2.${NC} 🚀 国内外通用 (CDN 加速)"
        echo -e "   ${GREEN}3.${NC} 🇨🇳 国内用户 (CNB 加速)     ${GREEN}4.${NC} 🔗 短链执行 (bash.spiritlhl)"
        echo -e "   ${GREEN}0.${NC} 🔙 返回"
        echo -e "${CYAN}   --------------------------------------------------------${NC}"
        read -p "   请选择 [0-4]: " ecs_c
        case $ecs_c in
            1) run_script "融合怪(无CDN)" "https://github.com/oneclickvirt/ecs" "export noninteractive=true && curl -L https://raw.githubusercontent.com/oneclickvirt/ecs/master/goecs.sh -o goecs.sh && chmod +x goecs.sh && ./goecs.sh install && goecs -l=en" "false"; break ;;
            2) run_script "融合怪(CDN加速)" "https://github.com/oneclickvirt/ecs" "export noninteractive=true && curl -L https://cdn.spiritlhl.net/https://raw.githubusercontent.com/oneclickvirt/ecs/master/goecs.sh -o goecs.sh && chmod +x goecs.sh && ./goecs.sh install && goecs -l=en" "false"; break ;;
            3) run_script "融合怪(CNB加速)" "https://github.com/oneclickvirt/ecs" "export noninteractive=true && export CN=true && curl -L https://cnb.cool/oneclickvirt/ecs/-/git/raw/main/goecs.sh -o goecs.sh && chmod +x goecs.sh && ./goecs.sh install && goecs -l=en" "false"; break ;;
            4) run_script "融合怪(短链)" "https://github.com/oneclickvirt/ecs" "export noninteractive=true && curl -L https://bash.spiritlhl.net/goecs -o goecs.sh && chmod +x goecs.sh && bash goecs.sh install && goecs -l=en" "false"; break ;;
            0) break ;;
            *) echo -e "\n   ${RED}❌ 无效输入！${NC}"; read -n 1 -s -r -p "   按任意键继续..." ;;
        esac
    done
}

dnsmasq_sniproxy_manager() {
    while true; do
        clear; show_header
        echo -e "${BOLD}${CYAN}   >>> 🛡️ Dnsmasq + SNIProxy 流媒体解锁管家 ${NC}"
        echo -e "${CYAN}   --------------------------------------------------------${NC}"
        echo -e "   原理: 将流媒体受限VPS的DNS指向本机，通过SNIProxy反代解锁。"
        echo -e "   ${RED}注意: 本机必须具备解锁相关流媒体(如Netflix)的能力！${NC}"
        echo -e "${CYAN}   --------------------------------------------------------${NC}"
        echo -e "   ${GREEN}1.${NC} 🚀 快速安装 (推荐 - 自动处理端口冲突)"
        echo -e "   ${GREEN}2.${NC} ⚙️  普通安装 (手动交互)"
        echo -e "   ${GREEN}3.${NC} 🗑️  卸载 Dnsmasq + SNI Proxy"
        echo -e "   ${GREEN}4.${NC} 🩺 端口冲突扫描 (排查 80/443/53 是否被占用)"
        echo -e "   ${GREEN}0.${NC} 🔙 返回上一级菜单"
        echo -e "${CYAN}   --------------------------------------------------------${NC}"
        read -p "   请选择操作 [0-4]: " ds_c
        
        case $ds_c in
            1|2)
                echo -e "\n${YELLOW}⚙️  正在进行安装前环境安全检测...${NC}"
                install_deps "lsof net-tools" >/dev/null 2>&1
                
                if lsof -i:80 -t >/dev/null 2>&1 || lsof -i:443 -t >/dev/null 2>&1; then
                    echo -e "\n${RED}⚠️ 严重警告：检测到 80 或 443 端口已被占用！${NC}"
                    echo -e "${WHITE}这通常是因为你的服务器已经安装了建站面板 (如宝塔/1Panel) 或 Web 服务。${NC}"
                    echo -e "${WHITE}SNIProxy 强制安装会导致端口冲突，甚至让你的现有网站崩溃！${NC}"
                    read -p "是否不顾一切强制继续安装？(y/N): " force_install
                    [[ "${force_install,,}" != "y" ]] && { echo -e "${YELLOW}已中止安装，按任意键返回...${NC}"; read -n 1 -s -r; continue; }
                fi
                
                if lsof -i:53 -t >/dev/null 2>&1; then
                    if systemctl is-active --quiet systemd-resolved; then
                        echo -e "\n${YELLOW}🛠️ 检测到 systemd-resolved 正在占用 53 端口，触发自动修复程序...${NC}"
                        sed -i 's/#DNS=/DNS=8.8.8.8 1.1.1.1/' /etc/systemd/resolved.conf
                        sed -i 's/#DNSStubListener=yes/DNSStubListener=no/' /etc/systemd/resolved.conf
                        sed -i 's/DNSStubListener=yes/DNSStubListener=no/' /etc/systemd/resolved.conf
                        ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
                        systemctl restart systemd-resolved.service
                        echo -e "${GREEN}✅ 53 端口冲突已成功解除！${NC}"; sleep 1.5
                    else
                        echo -e "\n${YELLOW}⚠️ 注意：53 端口已被其他未知程序占用，安装可能会报错。${NC}"; sleep 2
                    fi
                fi
                
                if [ "$ds_c" -eq 1 ]; then
                    run_script "SNIProxy 快速安装" "https://github.com/myxuchangbin/dnsmasq_sniproxy_install" "wget --no-check-certificate -O dnsmasq_sniproxy.sh https://raw.githubusercontent.com/myxuchangbin/dnsmasq_sniproxy_install/master/dnsmasq_sniproxy.sh && bash dnsmasq_sniproxy.sh -f" "false"
                else
                    run_script "SNIProxy 普通安装" "https://github.com/myxuchangbin/dnsmasq_sniproxy_install" "wget --no-check-certificate -O dnsmasq_sniproxy.sh https://raw.githubusercontent.com/myxuchangbin/dnsmasq_sniproxy_install/master/dnsmasq_sniproxy.sh && bash dnsmasq_sniproxy.sh -i" "false"
                fi
                ;;
            3) 
                run_script "卸载 SNIProxy" "https://github.com/myxuchangbin/dnsmasq_sniproxy_install" "wget --no-check-certificate -O dnsmasq_sniproxy.sh https://raw.githubusercontent.com/myxuchangbin/dnsmasq_sniproxy_install/master/dnsmasq_sniproxy.sh && bash dnsmasq_sniproxy.sh -u" "false" 
                ;;
            4)
                clear; echo -e "${CYAN}=== 🩺 本机核心端口占用扫描 ===${NC}\n"
                install_deps "lsof" >/dev/null 2>&1
                echo -e "${YELLOW}[80/443 端口状态 - Web & SNIProxy]${NC}"
                lsof -i:80,443 || echo "   ✅ 未被占用，状态良好"
                echo -e "\n${YELLOW}[53 端口状态 - DNS 解析]${NC}"
                lsof -i:53 || echo "   ✅ 未被占用，状态良好"
                echo -e "\n${CYAN}==================================${NC}"
                read -n 1 -s -r -p "按任意键返回..." ;;
            0) break ;;
            *) echo -e "\n${RED}❌ 无效输入！${NC}"; read -n 1 -s -r -p "按任意键继续..." ;;
        esac
    done
}

# --- 6. UI 绘制 ---
show_header() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${PURPLE}          🎉 江某人的万能脚本箱 ${YELLOW}| ${GREEN}Toolbox v9.0 ${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "   💻 ${BOLD}系统:${NC} $OS_INFO   🧠 ${BOLD}内存:${NC} $MEM_INFO"
    echo -e "   🌍 ${BOLD}位置:${NC} $LOCATION ($ISP)"
    echo -e "   📡 ${BOLD}网络:${NC} ${BLUE}$IPV4${NC} (IPv4) | ${BLUE}${IPV6:0:15}...${NC} (IPv6)"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# --- 7. 主平铺页面 ---
main_menu() {
    while true; do
        get_system_info; clear; show_header
        
        echo -e "${BOLD}${YELLOW} [1] 基础环境 ${NC}"
        echo -e " 1. 安装必备基础命令 (curl/wget/git/gzip)"
        echo -e "${CYAN} ---------------------------------------------------------- ${NC}"
        
        echo -e "${BOLD}${YELLOW} [2] 新机体检项目 ${NC}"
        echo -e " 2. IP 质量检测           3. 网络质量检测"
        echo -e " 4. 硬件质量检测          5. 三网回程路由"
        echo -e " 6. NodeQuality 检测      7. 流媒体解锁检测"
        echo -e " 8. 流媒体解锁 (深)"
        echo -e "${CYAN} ---------------------------------------------------------- ${NC}"

        echo -e "${BOLD}${YELLOW} [3] 科学上网工具 ${NC}"
        echo -e " 9. 原版 3x-ui            10. Alpine版 3x-ui"
        echo -e " 11. Sing-box-yg 精装     12. yoyo sing-box 一键"
        echo -e " 13. 欢妹 Alpine UI"
        echo -e "${CYAN} ---------------------------------------------------------- ${NC}"

        echo -e "${BOLD}${YELLOW} [4] 可视化管理面板 ${NC}"
        echo -e " 14. 1Panel 官方版        15. 宝塔面板"
        echo -e " 16. aaPanel (国际版)     17. CasaOS 极简"
        echo -e "${CYAN} ---------------------------------------------------------- ${NC}"

        echo -e "${BOLD}${YELLOW} [5] 运维 & 网络 & 综合 ${NC}"
        echo -e " 18. DNS 深度管理         19. BBR & TPS 调优"
        echo -e " 20. Swap 虚拟内存        21. 修改 SSH 端口"
        echo -e " 22. 哪吒 Agent 卸载      23. ${RED}BBR v3 Ultimate${NC}"
        echo -e " 24. Realm 转发管理       25. AkileDNS 解锁"
        echo -e " 26. 科技Lion工具箱       27. ${PURPLE}Dnsmasq+SNI 解锁${NC}"
        echo -e "${CYAN} ---------------------------------------------------------- ${NC}"

        echo -e "${BOLD}${YELLOW} [6] oneclickvirt 实用脚本合集 ${NC}"
        echo -e " 28. 融合怪测评 (全节点)  29. 三网回程路由 (UT)"
        echo -e " 30. IP安全检测 (SC)      31. 流媒体检测模块 (UT)"
        echo -e "${CYAN} ---------------------------------------------------------- ${NC}"

        echo -e "   ${GREEN}0.${NC} ❌ 退出脚本"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "   🌐 ${BOLD}我的个人博客：${BLUE}op.style${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

        read -p " 请输入序号执行功能: " choice
        case $choice in
            1) install_deps "bash curl wget git sudo lsof ca-certificates gzip" ;;
            
            2) run_script "IP质量检测" "https://github.com/xykt/IPQuality" "bash <(curl -Ls https://IP.Check.Place) -y" "false" ;;
            3) run_script "网络质量检测" "https://github.com/xykt/NetQuality" "bash <(curl -Ls https://Net.Check.Place) -y" "false" ;;
            4) run_script "硬件质量检测" "https://github.com/xykt/HardwareQuality" "bash <(curl -Ls https://Hardware.Check.Place) -y" "false" ;;
            5) run_script "三网回程路由" "https://github.com/zhanghanyun/backtrace" "curl https://raw.githubusercontent.com/zhanghanyun/backtrace/main/install.sh -sSf | sh" "false" ;;
            6) run_script "NodeQuality" "https://github.com/LloydAsp/NodeQuality" "bash <(curl -sL https://run.NodeQuality.com)" "false" ;;
            7) run_script "流媒体解锁检测" "https://github.com/HsukqiLee/MediaUnlockTest" "bash <(curl -Ls unlock.icmp.ing/scripts/test.sh)" "false" ;;
            8) run_script "流媒体解锁(深)" "https://github.com/1-stream/RegionRestrictionCheck" "bash <(curl -L -s https://raw.githubusercontent.com/1-stream/RegionRestrictionCheck/main/check.sh)" "false" ;;
            
            9) run_script "原版 3x-ui" "https://github.com/MHSanaei/3x-ui" "bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) v2.6.2" "false" ;;
            10) install_deps "curl bash gzip"; run_script "Alpine版 3x-ui" "https://github.com/56idc/3x-ui-alpine" "bash <(curl -Ls https://raw.githubusercontent.com/56idc/3x-ui-alpine/master/install_alpine.sh)" "true" ;;
            11) run_script "Sing-box-yg 精装桶" "https://github.com/yonggekkk/sing-box-yg" "bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/sing-box-yg/main/sb.sh)" "false" ;;
            12) run_script "yoyo sing-box 一键" "https://github.com/caigouzi121380/singbox-deploy" "bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/caigouzi121380/singbox-deploy/main/install-singbox-yyds.sh)\"" "false" ;;
            13) install_deps "curl bash gzip openssl"; run_script "欢妹 Alpine UI" "https://github.com/StarVM-OpenSource/3x-ui-Apline" "bash <(curl -Ls https://raw.githubusercontent.com/StarVM-OpenSource/3x-ui-Apline/refs/heads/main/install.sh)" "true" ;;
            
            14) run_script "1Panel 官方版" "https://github.com/1Panel-dev/1Panel" "curl -sSL https://resource.fit2cloud.com/1panel/package/quick_start.sh -o quick_start.sh && bash quick_start.sh" "false" ;;
            15) run_script "宝塔面板" "https://www.bt.cn/" "curl -sSO https://download.bt.cn/install/install_panel.sh && bash install_panel.sh ed8484bec" "false" ;;
            16) run_script "aaPanel" "https://www.aapanel.com/" "wget -O install.sh http://www.aapanel.com/script/install_6.0_en.sh && bash install.sh" "false" ;;
            17) run_script "CasaOS" "https://github.com/IceWhaleTech/CasaOS" "curl -fsSL https://get.casaos.io | bash" "false" ;;
            
            18) dns_manager ;;
            19) bbr_tuning ;;
            20) swap_manager ;;
            21) read -p "新端口: " p; sed -i "s/Port .*/Port $p/" /etc/ssh/sshd_config; systemctl restart sshd; echo -e "${GREEN}修改成功！${NC}"; read -n 1 -s -r -p "按任意键继续..." ;;
            22) run_script "哪吒 Agent 卸载" "https://github.com/everett7623/Nezha-cleaner" "bash <(curl -s https://raw.githubusercontent.com/everett7623/Nezha-cleaner/main/nezha-agent-cleaner.sh)" "false" ;;
            
            23) 
                install_deps "curl"
                clear; echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo -e "🚀 ${BOLD}即将启动：${WHITE}BBR v3 Ultimate${NC}\n🔗 ${BOLD}项目地址：${BLUE}https://github.com/Eric86777/vps-tcp-tune${NC}"
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo -e "为防止误触，请确认启动后输入${GREEN}任意键${NC}开始执行，或输入“${RED}N${NC}”返回。"
                read -n 1 -s -r confirm
                if [[ "${confirm}" == "N" || "${confirm}" == "n" ]]; then
                    echo -e "\n${YELLOW}已取消执行，正在返回...${NC}"; sleep 1
                else
                    echo -e "\n${GREEN}▶ 开始安装并配置别名...${NC}\n"
                    bash <(curl -fsSL "https://raw.githubusercontent.com/Eric86777/vps-tcp-tune/main/install-alias.sh?$(date +%s)")
                    echo -e "\n${GREEN}▶ 尝试自动启动 BBR 面板...${NC}\n"; sleep 1
                    if command -v bbr >/dev/null 2>&1; then bbr; else bash /root/.vps-tcp-tune/tcp.sh; fi
                    
                    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                    echo -e "💡 ${YELLOW}${BOLD}温馨提示：${NC} 下次管理 BBR 时，直接输入 ${BOLD}${CYAN}bbr${NC} 即可！(如报错请先执行 source ~/.bashrc)"
                    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                    read -n 1 -s -r -p "按任意键返回主菜单..."
                fi
                ;;
                
            24) run_script "Realm 转发管理" "https://github.com/hiapb/hia-realm" "bash <(curl -fsSL https://raw.githubusercontent.com/hiapb/hia-realm/main/install.sh)" "false" ;;
            25) 
                install_deps "wget"
                echo -e "${YELLOW}提示：运行后请配合 ${BLUE}https://dns.akile.ai/${YELLOW} 使用${NC}"
                run_script "AkileDNS 官方脚本" "https://github.com/akile-network/aktools" "wget -qO- https://raw.githubusercontent.com/akile-network/aktools/refs/heads/main/akdns.sh | bash" "false" ;;
            26) run_script "科技Lion工具箱" "https://kejilion.pro" "curl -sS -O https://kejilion.pro/kejilion.sh && chmod +x kejilion.sh && ./kejilion.sh" "false" ;;
            
            27) dnsmasq_sniproxy_manager ;;
            
            28) oneclickvirt_ecs ;;
            29) run_script "三网回程路由(UT)" "https://github.com/oneclickvirt/backtrace" "curl https://cdn.spiritlhl.net/https://raw.githubusercontent.com/oneclickvirt/backtrace/main/backtrace_install.sh -sSf | bash && backtrace" "false" ;;
            30) run_script "IP安全检测(SC)" "https://github.com/oneclickvirt/securityCheck" "curl https://cdn.spiritlhl.net/https://raw.githubusercontent.com/oneclickvirt/securityCheck/main/sc_install.sh -sSf | bash" "false" ;;
            31) run_script "流媒体检测模块(UT)" "https://github.com/oneclickvirt/UnlockTests" "curl https://cdn.spiritlhl.net/https://raw.githubusercontent.com/oneclickvirt/UnlockTests/main/ut_install.sh -sSf | bash && ut" "false" ;;
            
            0) 
               echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
               echo -e "💡 ${YELLOW}${BOLD}快捷唤醒提示：${NC}"
               echo -e "以后只需在终端输入 ${BOLD}${GREEN}jmy${NC} 即可随时一键唤出本脚本箱！"
               echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
               echo -e "${GREEN}👋 感谢使用，再见！${NC}"; exit 0 ;;
            *) 
               echo -e "\n${RED}❌ 无效输入 [ $choice ]！请选择列表中存在的数字。${NC}"
               read -n 1 -s -r -p "按任意键继续..."
               ;;
        esac
    done
}

# 启动
main_menu
