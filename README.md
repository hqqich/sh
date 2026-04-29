# script

fork自：[kejilion/sh](https://github.com/kejilion/sh)

从`科技lion`学习脚本开发

### 工具

| 工具                                                                                         | 下载地址 | 安装方式   |
| -------------------------------------------------------------------------------------------- | -------- | ---------- |
| [x-cmd](https://cn.x-cmd.com/)                                                               |          |            |
| [chsrc](https://chsrc.run/)                                                                  |          |            |
| [timg](https://github.com/hzeller/timg/releases/download/v1.6.3/timg-v1.6.3-x86_64.AppImage) |          |            |
| [yazi](https://github.com/sxyazi/yazi)                                                       |          |            |
| [glow](https://github.com/charmbracelet/glow)                                                |          | 可执行文件 |
| [jq](https://github.com/jqlang/jq)                                                           |          | 可执行文件 |
| [fish](https://fishshell.com/)                                                               |          | apt安装    |
| [btop]()                                                                                         |          |            |
| [ctop]()                                                                                         |          |            |
| [dufs]()                                                                                         |          |            |
| [somo](https://github.com/theopfr/somo)                                                     |          |   deb安装         |
| [asciinema](https://docs.asciinema.org/getting-started/)                               |          |            |
| []()                                                                                         |          |            |


### 工具

| 工具                                                                                         | 下载地址 | 安装方式   |
| -------------------------------------------------------------------------------------------- | -------- | ---------- |
| [lsd](https://github.com/lsd-rs/lsd)                                                               |          |            |



### 使用

```shell
bash <(curl -sL https://raw.githubusercontent.com/hqqich/sh/main/base.sh)
bash <(curl -sL https://cdn.jsdelivr.net/gh/hqqich/sh@main/base.sh)
bash <(curl -sL http://172.22.90.1:5244/sh/base.sh)
bash <(curl -sL http://172.22.90.1:8080/base.sh)
```

```shell
python3 -m http.server 8080
# bash <(curl -sL http://172.22.90.1:8080/base.sh)


# 这个需要安装   https://pypi.org/project/uploadserver/
python3 -m pip install --user uploadserver
python3 -m uploadserver 8080
# 指定token
python3 -m uploadserver -t helloworld
# 上传文件
curl -v  http://127.0.0.1:8000/upload -F "files=@/tmp/test.txt;filename=test.txt"
```

### 提交辅助脚本

记录了本次实际使用的提交流程，适合在当前这种可能处于 detached HEAD 的仓库里直接复用。

```shell
./git_commit_push_main.sh "docs: update README"
./git_commit_push_main.sh "feat: update scripts" README.md base.sh
```
