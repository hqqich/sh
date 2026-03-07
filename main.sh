#!/bin/bash

# 引入工具函数
source ./utils.sh

# 使用引入的函数
log_info "程序开始执行"

result=$(calculate_sum 10 20)
log_info "计算结果: $result"

log_error "这是一个错误示例"
