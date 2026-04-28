#!/bin/bash

# set -o errexit # 当脚本中任意命令返回非零退出状态（表示执行失败）时，立即终止脚本运行，避免错误累积导致更严重的问题。
# set -o nounset # 当脚本中使用未赋值/未定义的变量（称为“未绑定变量”，Unbound Variable）时，立即报错并退出，避免因变量拼写错误或遗漏初始化导致的隐性BUG。
# set -o pipefail # 修改管道的退出状态计算规则：默认情况下，管道的退出状态是最后一个命令的状态；开启pipefail后，管道的退出状态是所有命令中第一个非零的状态（即只要有一个命令失败，整个管道视为失败）。
# info() {
#     echo "[INFO] $1"
# }

# Logging framework
# Log format (logback-ish):
# 2026-03-05 14:23:01.123 INFO  [base.sh] (line:42 func:main) message

log() {
    local level="$1"
    local msg="$2"

    local ts
    local script
    local line
    local func
    local level_pad
    local caller_idx=1
    local line_idx=0
    local color=""
    local reset=""

    # Use printf for timestamp if possible (faster), else date
    # printf -v ts '%(%Y-%m-%d %H:%M:%S)T' -1  # No milliseconds
    ts="$(date +'%Y-%m-%d %H:%M:%S.%3N')"

    if [[ "${FUNCNAME[1]:-}" =~ ^(debug|info|warn|error)$ ]] && [[ -n "${FUNCNAME[2]:-}" ]]; then
        caller_idx=2
        line_idx=1
    fi

    script="${BASH_SOURCE[$caller_idx]##*/}"
    line="${BASH_LINENO[$line_idx]}"
    func="${FUNCNAME[$caller_idx]:-main}"

    # Align levels to 5 chars
    printf -v level_pad '%-5s' "$level"

    if [[ -t 1 ]]; then
        case "$level" in
            DEBUG) color=$'\033[36m' ;; # cyan
            INFO)  color=$'\033[32m' ;; # green
            WARN)  color=$'\033[33m' ;; # yellow
            ERROR) color=$'\033[31m' ;; # red
            *)     color=$'\033[0m' ;;
        esac
        reset=$'\033[0m'
    fi

    printf '%s %b%s%b [%s] (line:%s func:%s) %s\n' \
        "$ts" "$color" "$level_pad" "$reset" "$script" "$line" "$func" "$msg"
}

debug() { log "DEBUG" "$1"; }
info()  { log "INFO"  "$1"; }
warn()  { log "WARN"  "$1"; }
error() { log "ERROR" "$1"; }



gl_hui='\e[37m'
gl_hong='\033[31m'
gl_lv='\033[32m'
gl_huang='\033[33m'
gl_lan='\033[34m'
gl_bai='\033[0m'
gl_zi='\033[35m'
gl_kjlan='\033[96m'


break_end() {
	  echo -e "${gl_lv}操作完成${gl_bai}"
	  echo "按任意键继续..."
	  read -n 1 -s -r -p ""
	  echo ""
	  clear
}





#####################################
############ sshd 服务 ###############
#####################################
readonly SSHD_CONFIG="/etc/ssh/sshd_config"

install_ssh_server() {
    info "安装sshd服务"
    apt-get update
    apt-get install -y openssh-server
}

configure_sshd() {
    local ssh_port=""

    while true; do
        read -r -p "请输入 sshd 端口: " ssh_port

        if [[ -z "${ssh_port}" ]]; then
            warn "端口不能为空，请重新输入。"
            continue
        fi

        if [[ ! "${ssh_port}" =~ ^[0-9]+$ ]]; then
            warn "端口必须是数字，请重新输入。"
            continue
        fi

        if (( ssh_port < 1 || ssh_port > 65535 )); then
            warn "端口必须在 1 到 65535 之间，请重新输入。"
            continue
        fi

        break
    done

    info "开启root登录"
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' "${SSHD_CONFIG}"
    info "开启sftp登录"
    sed -i 's/#Subsystem sftp/Subsystem sftp internal-sftp/' "${SSHD_CONFIG}"
    info "设置端口：${ssh_port}"
    sed -i "s/#Port 22/Port ${ssh_port}/" "${SSHD_CONFIG}"
}

set_root_password() {
    local root_password=""
    local confirm_password=""

    while true; do
        read -r -s -p "请输入 root 密码: " root_password
        echo ""

        if [[ -z "${root_password}" ]]; then
            warn "密码不能为空，请重新输入。"
            continue
        fi

        read -r -s -p "请再次输入 root 密码: " confirm_password
        echo ""

        if [[ "${root_password}" != "${confirm_password}" ]]; then
            warn "两次输入的密码不一致，请重新输入。"
            continue
        fi

        break
    done

    echo "root:${root_password}" | chpasswd
    info "设置 root 密码成功。"
}

init_sshd() {
    if dpkg -s openssh-server >/dev/null 2>&1; then
        info "openssh-server 已安装，跳过初始化。"
        return 0
    fi

    install_ssh_server
    configure_sshd
    set_root_password

    info "启动命令： nohup /usr/sbin/sshd -D &"
}

# 1. 生成对称key:   ssh-keygen -t ed25519
# 2. 将 .pub 内容复制到 authorized_keys 文件中，这是公钥
set_private_key_login() {
    info "设置私钥登录"
    # cat id_ed25519.pub >> authorized_keys
    # 修改sshd的配置文件，允许私钥登录
    # 增加配置
    # PubkeyAuthentication yes
    # AuthorizedKeysFile .ssh/authorized_keys
    # 私钥一定要是 600 的， chmod 600 ./key
    #
    #
    # ssh-ed25519                        AAAAC3Nzxxxxxxk3P55LykqrR     root@host
    # 密钥类型（Ed25519，现代、安全、推荐）   Base64 编码的公钥内容           注释（通常是生成密钥时的用户名和主机名）
    #
    #
    # RSA       (全平台通用)           ssh-keygen -t rsa -b 4096
    # Ed25519   (OpenSSH 6.5+)       ssh-keygen -t ed25519
    # ECDSA     (依赖系统随机源)       ssh-keygen -t ecdsa
}
#####################################



#####################################
############ 开启http代理 ############
#####################################
proxyOnClash() {
    export https_proxy=http://172.22.90.3:6789
    export http_proxy=http://172.22.90.3:6789
    export all_proxy=socks5://172.22.90.3:6789
    curl https://ipinfo.io/ip
}
#####################################



#####################################
############ python中的uv ############
#####################################
installUv() {
    # https://uv.oaix.tech/
    # https://uv.doczh.com/getting-started/installation/
    # 下载安装uv
    curl -LsSf https://astral.sh/uv/install.sh | sh
    uv -V
}
#####################################




#####################################
############ 开发者工具 ############
#####################################
installDevTool() {
    info "准备安装：vim git curl wget unzip build-essential zip"
    apt-get install -y vim git lrzsz curl wget unzip build-essential zip
}
#####################################



#####################################
############ 安装 ############
#####################################
#####################################





instruction_interaction_sh() {
	while true; do
		clear
		echo -e "$gl_kjlan"
		echo " +-+-+-+-+-+-+-+-+-+-+-+-+"
		echo " |T|S|I|N|G|L|I|N|K|.|S|H|"
		echo " +-+-+-+-+-+-+-+-+-+-+-+-+"
		echo -e "命令行输入${gl_huang}tss$gl_kjlan可快速启动脚本$gl_bai"
		echo -e "$gl_kjlan------------------------$gl_bai"
		echo -e "${gl_kjlan}1.   ${gl_bai}sshd服务"
		echo -e "${gl_kjlan}2.   ${gl_bai}开启http代理"
		echo -e "${gl_kjlan}3.   ${gl_bai}安装uv"
		echo -e "${gl_kjlan}4.   ${gl_bai}安装dev-tool"
		echo -e "$gl_kjlan------------------------$gl_bai"
		echo -e "${gl_kjlan}00.  $gl_bai脚本更新"
		echo -e "$gl_kjlan------------------------$gl_bai"
		echo -e "${gl_kjlan}0.   $gl_bai退出脚本"
		echo -e "$gl_kjlan------------------------$gl_bai"
		read -e -p "请输入你的选择: " choice

		case $choice in
		1) init_sshd ;;
		2) proxyOnClash ;;
		3) installUv ;;
		4) installDevTool ;;
		02) clear ; send_stats "系统更新" ; linux_update ;;
		03) clear ; send_stats "系统清理" ; linux_clean ;;
		00) kejilion_update ;;
		0) clear ; exit ;;
		*) echo "无效的输入!" ;;
		esac
		break_end
	done
}


main() {


    if [[ "${EUID}" -ne 0 ]]; then
        info "这个脚本必须是root用户执行"
        exit 1
    fi

    info "打印日志"

    if [ "$#" -eq 0 ]; then
    	# 如果没有参数，运行交互式逻辑
    	instruction_interaction_sh
    else
    	# 如果有参数，执行相应函数
    	case $1 in
    		install|add|安装)
    			shift
    			send_stats "安装软件"
    			install "$@"
    			;;
    		remove|del|uninstall|卸载)
    			shift
    			send_stats "卸载软件"
    			remove "$@"
    			;;
    		*)
    			k_info
    			;;
    	esac
    fi

}

debug "打"
info "印"
warn "日"
error "志"

# docker run --rm --network=host -d --runtime=nvidia -v /mnt/aap:/at_in --entrypoint "tail" --name database database:6.1.1 -f /dev/null
# 这确保了脚本仅在被直接执行时运行 main 逻辑，而在被 source 引用时仅加载函数定义，增强了模块化兼容性。
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    sed -i '/^alias tss=/d' ~/.bashrc > /dev/null 2>&1
    sed -i '/^alias tss=/d' ~/.profile > /dev/null 2>&1
    sed -i '/^alias tss=/d' ~/.bash_profile > /dev/null 2>&1
    cp -f ./tsinglink-sh-script.sh ~/tsinglink-sh-script.sh > /dev/null 2>&1
    # tsinglink-sh-script  =>  tss
    cp -f ~/tsinglink-sh-script.sh /usr/local/bin/tss > /dev/null 2>&1
    ln -sf /usr/local/bin/tss /usr/bin/tss > /dev/null 2>&1

    main "$@"
fi
