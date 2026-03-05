#!/bin/bash
#
# Configures SSH server on a Debian-based system with root login and custom port.
# Follows Google Shell Style Guide: https://google.github.io/styleguide/shellguide.html
set -o errexit  # Exit on error
set -o nounset  # Exit on unset variables
set -o pipefail # Fail pipeline if any command fails
# Logging framework
# Log format (logback-ish):
# 2026-03-05 14:23:01.123 INFO  [base.sh] (line:42 func:main) message
LOG_LEVEL="${LOG_LEVEL:-DEBUG}"   # DEBUG|INFO|WARN|ERROR  这里可以改默认显示的日志级别
NO_COLOR="${NO_COLOR:-false}"    # true disables color

_log_now() {
    date +'%Y-%m-%d %H:%M:%S.%3N'
}

_log_level_num() {
    case "$1" in
        DEBUG) echo 10 ;;
        INFO)  echo 20 ;;
        WARN)  echo 30 ;;
        ERROR) echo 40 ;;
        *)     echo 20 ;;
    esac
}

_log_should_print() {
    local level="$1"
    local want_num
    local have_num
    want_num="$(_log_level_num "$level")"
    have_num="$(_log_level_num "$LOG_LEVEL")"
    [[ "$want_num" -ge "$have_num" ]]
}

_log_color() {
    local level="$1"
    case "$level" in
        DEBUG) printf '\033[36m' ;; # cyan
        INFO)  printf '\033[32m' ;; # green
        WARN)  printf '\033[33m' ;; # yellow
        ERROR) printf '\033[31m' ;; # red
        *)     printf '\033[0m' ;;
    esac
}

_log_reset() {
    printf '\033[0m'
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

    ts="$(_log_now)"
    if [[ "${FUNCNAME[1]:-}" =~ ^(debug|info|warn|error)$ ]] && [[ -n "${FUNCNAME[2]:-}" ]]; then
        caller_idx=2
        line_idx=1
    fi

    script="$(basename "${BASH_SOURCE[$caller_idx]}")"
    line="${BASH_LINENO[$line_idx]}"
    func="${FUNCNAME[$caller_idx]:-main}"

    # Align levels to 5 chars (DEBUG/INFO/WARN/ERROR)
    level_pad="$(printf '%-5s' "$level")"

    if [[ -t 1 && "$NO_COLOR" != "true" ]]; then
        color="$(_log_color "$level")"
        reset="$(_log_reset)"
    fi

    printf '%s %b%s%b [%s] (line:%s func:%s) %s\n' \
        "$ts" "$color" "$level_pad" "$reset" "$script" "$line" "$func" "$msg"
}

debug() { log "DEBUG" "$1"; }
info()  { log "INFO"  "$1"; }
warn()  { log "WARN"  "$1"; }
error() { log "ERROR" "$1"; }


# Main execution
main() {
    info "打印日志"
    warn "打印日志"
    error "打印日志"
    debug "打印日志"
    info "打印日志"
    warn "打印日志"
    error "打印日志"
    debug "打印日志"
}
main "$@"
