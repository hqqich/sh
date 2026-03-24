#!/bin/bash

sh_download() {
    local script_path="$HOME/tsinglink-sh-script.sh"
    local lan_url="http://172.22.90.1:5244/sh/base.sh"

    # LAN 可达时优先使用
    if curl -sS --head --max-time 1 "$lan_url" >/dev/null 2>&1; then
        echo "内部下载"
        curl -sS -o "$script_path" "$lan_url"
    else
        echo "外部下载"
        # 检测国家/IPv6/IPv4
        local country=$(curl -s --max-time 1 ipinfo.io/country || echo "unknown")
        local ipv6_address=$(curl -s --max-time 1 https://v6.ipinfo.io/ip || echo "")
        local ipv4_address=$(curl -s --max-time 1 https://ipinfo.io/ip || echo "")

        if [ "$country" = "CN" ] || [ -n "$ipv6_address" ]; then
            curl -sS -o "$script_path" "https://gh.kejilion.pro/raw.githubusercontent.com/hqqich/sh/main/base.sh"
        else
            curl -sS -o "$script_path" "https://raw.githubusercontent.com/hqqich/sh/main/base.sh"
        fi
    fi

    chmod +x "$script_path"
    "$script_path" "$@"
}

sh_download "$@"
