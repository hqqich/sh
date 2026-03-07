#!/bin/bash

sh_download() {
    local script_path="$HOME/sh/base.sh"

    # 检测国家/IPv6/IPv4
    local country=$(curl -s --max-time 1 ipinfo.io/country || echo "unknown")
    local ipv6_address=$(curl -s --max-time 1 https://v6.ipinfo.io/ip || echo "")
    local ipv4_address=$(curl -s --max-time 1 https://ipinfo.io/ip || echo "")

    if [ "$country" = "CN" ] || [ -n "$ipv6_address" ]; then
        curl -sS -o "$script_path" "https://gh.kejilion.pro/raw.githubusercontent.com/hqqich/sh/main/base.sh"
    else
        curl -sS -o "$script_path" "https://raw.githubusercontent.com/hqqich/sh/main/base.sh"
    fi

    chmod +x "$script_path"
    "$script_path" "$@"
}

sh_download "$@"
