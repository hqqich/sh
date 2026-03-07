#!/bin/bash

log_info() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERROR] $1" >&2
}

calculate_sum() {
    local a=$1
    local b=$2
    echo $((a + b))
}
