#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Logging framework
# Log format (logback-ish):
# 2026-03-05 14:23:01.123 INFO  [base.sh] (line:42 func:main) message
LOG_LEVEL="${LOG_LEVEL:-DEBUG}"   # DEBUG|INFO|WARN|ERROR
NO_COLOR="${NO_COLOR:-false}"    # true disables color

# Map levels to numbers for comparison
declare -A _LOG_LEVEL_MAP=( [DEBUG]=10 [INFO]=20 [WARN]=30 [ERROR]=40 )

_log_should_print() {
    local level="${1:-INFO}"
    local level_val="${_LOG_LEVEL_MAP[$level]:-20}"
    local current_val="${_LOG_LEVEL_MAP[$LOG_LEVEL]:-10}"
    (( level_val >= current_val ))
}

log() {
    local level="$1"
    local msg="$2"

    if ! _log_should_print "$level"; then
        return 0
    fi

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

    if [[ -t 1 && "$NO_COLOR" != "true" ]]; then
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
install_ssh_server() {
    log "安装sshd服务..."
    apt-get update
    apt-get install -y openssh-server
}

configure_sshd() {
    log "配置sshd服务..."
    # Enable root login with password
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' "${SSHD_CONFIG}"
    # Configure SFTP subsystem
    sed -i 's/#Subsystem sftp/Subsystem sftp internal-sftp/' "${SSHD_CONFIG}"
    # Change SSH port
    sed -i "s/#Port 22/Port ${SSH_PORT}/" "${SSHD_CONFIG}"
    log "SSHD 配置完成. 端口为: ${SSH_PORT}"
}

set_root_password() {
    log "Setting root password..."
    echo "root:${ROOT_PASSWORD}" | chpasswd
    log "WARN" "Root password set to default value. Change this immediately!"
}
#####################################






instruction_interaction_sh() {
	while true; do
		clear
		echo -e "$gl_kjlan"
		echo " +-+-+-+-+-+-+-+-+-+-+-+-+"
		echo " |T|S|I|N|G|L|I|N|K|.|S|H|"
		echo " +-+-+-+-+-+-+-+-+-+-+-+-+"
		echo -e "命令行输入${gl_huang}k$gl_kjlan可快速启动脚本$gl_bai"
		echo -e "$gl_kjlan------------------------$gl_bai"
		echo -e "${gl_kjlan}1.   ${gl_bai}sshd服务"
		echo -e "${gl_kjlan}2.   ${gl_bai}系统更新"
		echo -e "$gl_kjlan------------------------$gl_bai"
		echo -e "${gl_kjlan}00.  $gl_bai脚本更新"
		echo -e "$gl_kjlan------------------------$gl_bai"
		echo -e "${gl_kjlan}0.   $gl_bai退出脚本"
		echo -e "$gl_kjlan------------------------$gl_bai"
		read -e -p "请输入你的选择: " choice

		case $choice in
		1) linux_info ;;
		2) clear ; send_stats "系统更新" ; linux_update ;;
		3) clear ; send_stats "系统清理" ; linux_clean ;;
		4) linux_tools ;;
		5) linux_bbr ;;
		6) linux_docker ;;
		7) clear ; send_stats "warp管理" ; install wget
			wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh ; bash menu.sh [option] [lisence/url/token]
		;;
		8) linux_test ;;
		9) linux_Oracle ;;
		10) linux_ldnmp ;;
		11) linux_panel ;;
		12) linux_work ;;
		13) linux_Settings ;;
		14) linux_cluster ;;
		15) kejilion_Affiliates ;;
		16) games_server_tools ;;
		00) kejilion_update ;;
		0) clear ; exit ;;
		*) echo "无效的输入!" ;;
		esac
		break_end
	done
}


# Main execution
main() {
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

# 这确保了脚本仅在被直接执行时运行 main 逻辑，而在被 source 引用时仅加载函数定义，增强了模块化兼容性。
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
