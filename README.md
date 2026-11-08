# NixOS 配置

面向 Ryzen 7 9800X3D + Radeon RX 9070 XT 台式机，使用 NixOS unstable、Home Manager、niri 和 Noctalia。

`configuration.nix` 为入口；`system/` 放系统功能，`home/` 放用户与桌面会话配置，均只有一层目录。`hardware-configuration.nix` 由安装程序生成。

## 安装

完成分区并挂载到 `/mnt`，将仓库放在 `/mnt/etc/nixos`，生成目标机器的硬件配置后安装：

```sh
sudo nixos-generate-config --root /mnt --show-hardware-config \
  | sudo tee /mnt/etc/nixos/hardware-configuration.nix >/dev/null
sudo nixos-install --flake path:/mnt/etc/nixos#nixos
sudo nixos-enter --root /mnt -c 'passwd maxwell'
```

首次登录前必须为 `maxwell` 设置密码。系统升级与检查：

```sh
nix flake update path:.
nix flake check path:. --show-trace
sudo nixos-rebuild switch --flake path:.#nixos
```

内核使用 CachyOS latest。软件版本由 `flake.lock` 固定；`stateVersion` 是数据兼容基线，不代表软件版本。

## 桌面

niri 通过 Home Manager 的 Nix 选项配置，并 include 上游默认 KDL；只覆盖本配置更换的应用绑定。Noctalia 提供自动隐藏的顶栏、启动器、控制中心、通知、锁屏和 Polkit 授权界面。窗口上下间距相同，为 12 个逻辑像素。

Fcitx 5 提供美式键盘和 Rime-Ice 拼音，Shift 切换中英文。NetworkManager、BlueZ、PipeWire/WirePlumber 和 XDG Portal 提供网络、蓝牙、音频及屏幕共享；普通 UVC 摄像头由内核 V4L2 驱动支持。

way-displays 自动选择显示器刷新率并处理 VRR。Noctalia 使用系统本地时间，在 22:00–07:00 开启 5500K 夜间色温。外接显示器亮度通过 DDC/CI 控制，需在显示器菜单中开启 DDC/CI。

## 快捷键

以下仅列跨应用冲突，以及被替换的 niri 默认命令；其他默认快捷键不变。

**冲突**

| 快捷键 | 冲突功能 |
| --- | --- |
| `Ctrl+Space` | Fcitx 切换输入法 / Zed 补全 |
| `Ctrl+;` | Fcitx 剪贴板 / Zed 行号或上下文菜单 |
| `Ctrl+Shift+U` | Fcitx Unicode 输入 / Zed 重做选择 |
| `Ctrl+Alt+P` | Fcitx 预编辑 / Zed Agent 配置 |
| `Ctrl+Alt+H/J` | Fcitx 拼写提示 / Zed 子词删除或工作区侧栏 |
| `F4`、`Ctrl+反引号`、`Ctrl+Shift+反引号` | Rime 菜单 / Zed 调试与终端；最后一项也用于 Sheprd 切换窗口 |
| `Super+Ctrl+Shift+方向键` | niri 跨屏移动列 / Ghostty 调整分屏 |
| `Ctrl+Alt+Delete` | niri 退出 / Zed 删除下个子词 |

**niri 命令替换**

| 默认键位 | 原命令 | 当前命令 |
| --- | --- | --- |
| `Super+T` | Alacritty | Ghostty |
| `Super+D` | Fuzzel | Noctalia 启动器 |
| `Super+Alt+L` | Swaylock | Noctalia 锁屏 |
| 音量键 | `wpctl` | Noctalia 音量控制 |
| 媒体键 | `playerctl` | Noctalia 媒体控制 |
| 亮度键 | `brightnessctl` | Noctalia 亮度控制 |

## 软件与硬件

- 硬件与图形：AMD CPU 微码、CachyOS 最新内核、`amdgpu`、Mesa RADV/RadeonSI；AMD OpenCL 已启用。
- Blender：使用 ROCm/HIP 构建；在 Blender 中选择 HIP 渲染设备。
- 游戏：Steam、Gamescope、GameMode、MangoHud、Wine。GameMode 不会自动作用于所有 Steam 游戏，按需在启动选项填写 `gamemoderun %command%`；MangoHud 可用 `gamemoderun mangohud %command%` 启动。
- 显卡性能：ReBAR/SAM 需在 UEFI 中开启 Above 4G Decoding 和 Re-Size BAR。
- 系统服务：Noctalia Greeter、NetworkManager、Knot Resolver、NixOS 原生 nftables 防火墙、Chrony、BlueZ、PipeWire/WirePlumber、fwupd、OpenSSH、zram-generator（唯一 swap）和 systemd-oomd。MetaOOM 目前没有 Nix 包。
- 容器与虚拟化：Podman 使用 Netavark；containerd 注册可选的 gVisor `runsc` 运行时，CNI 网络尚未配置；安装 BuildKit 和 Cloud Hypervisor。WireGuard 可通过 NetworkManager 配置；Kea DHCP 服务暂未启用。
- 输入与桌面语言：`Asia/Shanghai`、`zh_CN.UTF-8`。
- Shell：Nushell 为默认登录 shell。
- AI：Codex CLI、Herdr；TUI 工作台暂用 Sheprd，Vibex 目前没有 Nix 包。
- 其他应用：Ghostty、Helix、Zed、Obsidian、Chrome、Tabularis、sing-box for Desktop。

sing-box for Desktop 通过社区 `sfd-nix` 模块安装 GUI、配套核心和 root systemd 后台服务，并配置 PolicyKit action/`pkexec` 集成；TUN 操作由后台特权服务执行。GUI 会自动启动，但需在界面导入订阅并手动连接；订阅和密钥不存入仓库。

## 验证

`nix flake check` 会检查 NixOS 求值及 niri、Noctalia 配置。macOS 上可运行 `nix flake check --all-systems --no-build --show-trace` 做求值检查，但不会构建或运行 Linux 程序。硬件、登录、输入法、网络、音频和游戏仍需在目标机器实测。
