# 

fork自：[kejilion/sh](https://github.com/kejilion/sh)

从`科技lion`学习脚本开发


### 好用的工具

- [x-cmd](https://cn.x-cmd.com/)
- [chsrc](https://chsrc.run/)

### 使用

```shell

bash <(curl -sL https://raw.githubusercontent.com/hqqich/sh/main/base.sh)
bash <(curl -sL http://172.22.90.1:5244/sh/base.sh)

```

### 提交辅助脚本

记录了本次实际使用的提交流程，适合在当前这种可能处于 detached HEAD 的仓库里直接复用。

```shell
./git_commit_push_main.sh "docs: update README"
./git_commit_push_main.sh "feat: update scripts" README.md base.sh
```
