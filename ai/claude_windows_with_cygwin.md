# 环境与路径约定

- **运行环境**：Windows 11 Pro 笔记本，通过 cygwin 启动 Claude Code。Shell 是 `bash`（不是 PowerShell / cmd），命令一律用 POSIX 语法。
- 工作目录、是否 git 仓库属于**每次会话变动**的信息，以会话环境块为准，不在此记录（写死会过期）。

## 路径写法

`/etc/fstab` 把磁盘直接挂到了根目录：

```
C:/ /c ntfs binary,posix=0,user 0 0
D:/ /d ntfs binary,posix=0,user 0 0
```

- **统一写 POSIX 形式**：`/c/...`、`/d/...`。不要用 `C:\` 反斜杠写法——bash 会把 `\` 当转义符，带引号的 Windows 路径会直接报错。
- 默认挂载点 `/cygdrive/c`、`/cygdrive/d` 依然可用，三种写法指同一处：`D:\cygwin64` = `/d/cygwin64` = `/cygdrive/d/cygwin64`。
- `posix=0`：挂载层不做大小写规范化，写文件时不会自动纠正路径大小写。
- `/c`、`/d` 的 unix 属主/权限显示是 Windows ACL 映射的失真结果（`/c` 显示为 `NT SERVICE+TrustedInstaller`，`/d` 显示为 `SYSTEM`）。实际能不能读/写由 ACL 决定，**不要**据此判断权限。
- 修改 `/etc/fstab` 后要重启所有 cygwin 进程才生效（只被进程树里第一个进程读取）。
