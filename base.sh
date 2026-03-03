#!/bin/bash
#
# Configures SSH server on a Debian-based system with root login and custom port.
# Follows Google Shell Style Guide: https://google.github.io/styleguide/shellguide.html
set -o errexit  # Exit on error
set -o nounset  # Exit on unset variables
set -o pipefail # Fail pipeline if any command fails
# Functions
log() {
    local level="$1"
    local msg="$2"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $msg"
}


# Main execution
main() {
    log "INFO" "打印日志"
    log "INFO" "打印日志"
}
main "$@"
