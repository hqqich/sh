#!/bin/bash

# ==========================================
# Easy-Forward: Socat 端口转发管理工具 (修正版)
# ==========================================

# 颜色定义 (使用 $'' 方式确保 Bash 正确解析转义符)
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
PLAIN=$'\033[0m'

# 路径定义
SERVICE_PATH="/etc/systemd/system"
BIN_PATH="/usr/local/bin/easy-forward"

# 检查 Root 权限
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}错误：必须以 root 权限运行此脚本${PLAIN}"
    exit 1
fi

# 检查并安装 socat
check_dependency() {
    if ! command -v socat &> /dev/null; then
        echo -e "${YELLOW}正在安装 socat...${PLAIN}"
        if [ -f /etc/redhat-release ]; then
            yum install -y socat
        else
            apt-get update && apt-get install -y socat
        fi
    fi
}

# 1. 列表功能 (已修正颜色显示问题)
list_forwards() {
    echo -e "\n${GREEN}=== 当前转发列表 ===${PLAIN}"
    local count=0
    # 遍历所有 socat- 开头的服务文件
    for file in $SERVICE_PATH/socat-*.service; do
        if [ -f "$file" ]; then
            count=$((count+1))
            # 提取文件名中的任务名
            filename=$(basename "$file")
            name=${filename#socat-}
            name=${name%.service}
            
            # 提取具体的转发配置
            exec_line=$(grep "ExecStart" "$file")
            # 解析本地端口
            local_port=$(echo "$exec_line" | grep -oP 'TCP4-LISTEN:\K\d+')
            # 解析目标地址
            target=$(echo "$exec_line" | awk -F'TCP4:' '{print $2}')
            
            # 检查运行状态
            if systemctl is-active --quiet "socat-$name"; then
                status_text="${GREEN}运行中${PLAIN}"
            else
                status_text="${RED}已停止${PLAIN}"
            fi

            # 注意：这里将状态的格式化符由 %s 改为了 %b，以便正确解析颜色代码
            printf "任务: ${YELLOW}%-15s${PLAIN} 端口: ${GREEN}%-6s${PLAIN} -> 目标: ${YELLOW}%-20s${PLAIN} 状态: %b\n" "$name" "$local_port" "$target" "$status_text"
        fi
    done

    if [ "$count" -eq 0 ]; then
        echo "暂无转发任务。"
    fi
    echo "========================"
}

# 2. 添加转发
add_forward() {
    local name=$1
    local port=$2
    local remote_ip=$3
    local remote_port=$4

    if [ -z "$name" ]; then
        read -p "请输入任务名称 (例如 web): " name
        read -p "请输入本地监听端口 (例如 30003): " port
        read -p "请输入目标 IP: " remote_ip
        read -p "请输入目标端口: " remote_port
    fi

    if [[ -z "$name" || -z "$port" || -z "$remote_ip" || -z "$remote_port" ]]; then
        echo -e "${RED}错误：参数不完整${PLAIN}"
        return
    fi

    SERVICE_NAME="socat-$name"
    FILE_NAME="$SERVICE_PATH/$SERVICE_NAME.service"

    cat <<EOF > "$FILE_NAME"
[Unit]
Description=Socat Forwarding Service - $name
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/socat TCP4-LISTEN:$port,reuseaddr,fork TCP4:$remote_ip:$remote_port
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable "$SERVICE_NAME" --now > /dev/null 2>&1
    
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo -e "${GREEN}✅ 转发 [$name] 添加成功并已启动！${PLAIN}"
        echo -e "   本地 $port -> $remote_ip:$remote_port (开机自启)"
    else
        echo -e "${RED}❌ 启动失败，请检查参数或端口占用情况。${PLAIN}"
    fi
}

# 3. 删除转发
del_forward() {
    local name=$1
    
    if [ -z "$name" ]; then
        list_forwards
        read -p "请输入要删除的任务名称: " name
    fi

    if [ -z "$name" ]; then echo -e "${RED}取消操作${PLAIN}"; return; fi

    SERVICE_NAME="socat-$name"
    if [ ! -f "$SERVICE_PATH/$SERVICE_NAME.service" ]; then
        echo -e "${RED}错误：找不到名为 $name 的转发任务${PLAIN}"
        return
    fi

    systemctl stop "$SERVICE_NAME"
    systemctl disable "$SERVICE_NAME" > /dev/null 2>&1
    rm -f "$SERVICE_PATH/$SERVICE_NAME.service"
    systemctl daemon-reload
    
    echo -e "${GREEN}🗑️  转发任务 [$name] 已删除${PLAIN}"
}

# 4. 安装到全局
install_to_global() {
    cp "$0" "$BIN_PATH"
    chmod +x "$BIN_PATH"
    echo -e "${GREEN}✅ 已安装到 $BIN_PATH${PLAIN}"
    echo -e "现在你可以在任意目录下直接输入 ${YELLOW}easy-forward${PLAIN} 来使用工具了。"
}

# 显示菜单
show_menu() {
    clear
    echo -e "Easy-Forward 端口转发管理"
    echo "-------------------------"
    echo -e "${GREEN}1.${PLAIN} 转发列表"
    echo -e "${GREEN}2.${PLAIN} 添加转发"
    echo -e "${GREEN}3.${PLAIN} 删除转发"
    echo "-------------------------"
    echo -e "${YELLOW}4. 安装到全局${PLAIN}"
    echo -e "0. 退出"
    echo ""
    read -p "请选择 [0-4]: " choice
    
    case "$choice" in
        1) list_forwards ;;
        2) add_forward ;;
        3) del_forward ;;
        4) install_to_global ;;
        0) exit 0 ;;
        *) echo -e "${RED}无效选项${PLAIN}" ;;
    esac
}

# 主逻辑
check_dependency
if [ $# -gt 0 ]; then
    ACTION=$1
    case "$ACTION" in
        add) add_forward "$2" "$3" "$4" "$5" ;;
        del) del_forward "$2" ;;
        list) list_forwards ;;
        install) install_to_global ;;
        *) echo "用法: easy-forward {add|del|list|install}" ;;
    esac
else
    while true; do
        show_menu
        echo ""
        read -p "按回车键继续..."
    done
fi