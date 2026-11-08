# NixOS 配置

Ryzen 7 9800X3D + Radeon RX 9070 XT；NixOS unstable、CachyOS latest、Home Manager、Hyprland + Noctalia。

`configuration.nix` 是入口；`desktop/` 放桌面，`system/` 放系统服务与硬件支持，`home/programs.nix` 放应用。目录均为单层。

## 安装与更新

完成分区、挂载到 `/mnt`，将仓库放到 `/mnt/etc/nixos`：

```sh
sudo nixos-generate-config --root /mnt --show-hardware-config | sudo tee /mnt/etc/nixos/hardware-configuration.nix >/dev/null
sudo nixos-install --flake path:/mnt/etc/nixos#nixos
sudo nixos-enter --root /mnt -c 'passwd maxwell'
```

首次登录前设置密码。后续在仓库内更新：

```sh
nix flake update path:.
nix flake check path:. --show-trace
sudo nixos-rebuild switch --flake path:.#nixos
```

软件版本由 `flake.lock` 固定；`stateVersion` 是数据兼容基线。硬件配置由目标机器生成。

## 桌面

当前引用 `desktop/hyprland.nix`，通过 UWSM 管理会话，Nix 字段生成 Lua。切回保留的 niri 时，只需将 `configuration.nix` 中这一行换成 `./desktop/niri.nix`。两者共用 `desktop/common.nix`，登录会话、Portal 和显示管理分别随桌面切换。

Noctalia 提供自动隐藏的状态栏、启动器、通知、控制中心、锁屏和授权界面。上下外边距均为 12 个逻辑像素；10 分钟闲置锁屏，11 分钟熄屏。Fcitx 5 提供美式键盘与 Rime-Ice 拼音，Shift 切换中英文。

Hyprland 按最高分辨率选择最高刷新率，全屏按需启用 VRR；保留其默认全屏自动 HDR。niri 使用 way-displays。外接显示器需自行开启 DDC/CI。夜灯跟随本地时间，22:00–07:00 为 5500K，切换前后渐变；HDR 与夜灯同时使用的色彩表现需实机检查。

默认键位保持，仅替换命令：

| 桌面 | 默认键位 | 当前调用 |
| --- | --- | --- |
| Hyprland | `Super+Q` / `Super+R` / `Super+E` | Ghostty / Noctalia 启动器 / Ghostty 中运行 Yazi |
| Hyprland | `Super+M` | `uwsm stop` 退出会话 |
| niri | `Super+T` / `Super+D` / `Super+Alt+L` | Ghostty / Noctalia 启动器 / Noctalia 锁屏 |
| 两者 | 音量、媒体、亮度键 | Noctalia |

应用快捷键保持默认，已有重叠如下，实际触发取决于输入状态与焦点：

| 快捷键 | 重叠功能 |
| --- | --- |
| `Ctrl+Space` | Fcitx 输入法 / Zed 补全 |
| `Ctrl+;` | Fcitx 剪贴板 / Zed 行号或上下文菜单 |
| `Ctrl+Shift+U` | Fcitx Unicode / Zed 重做选择 |
| `Ctrl+Alt+P`、`Ctrl+Alt+H/J` | Fcitx 预编辑、拼写提示 / Zed Agent、子词删除或侧栏 |
| `F4`、`Ctrl+反引号`、`Ctrl+Shift+反引号` | Rime 菜单 / Zed 调试与终端；最后一项也用于 Sheprd |
| 仅 niri：`Super+Ctrl+Shift+方向键`、`Ctrl+Alt+Delete` | niri 移动列、退出 / Ghostty 分屏、Zed 子词删除 |

Hyprland 默认没有锁屏键，可通过 Noctalia 锁屏。niri 保留的 Orca 默认绑定仍无对应程序。

## 备注

- 游戏：Steam、Gamescope、GameMode、MangoHud。GameMode 不会自动作用于所有 Steam 游戏；启动选项使用 `gamemoderun %command%`，性能显示使用 `gamemoderun mangohud %command%`。
- AMD OpenCL 已启用；Blender 内选择 HIP 设备。ReBAR/SAM 需在 UEFI 开启 Above 4G Decoding 和 Re-Size BAR。
- zram-generator 是唯一 swap；使用 systemd-oomd，MetaOOM 目前没有 Nix 包。
- Podman 使用 Netavark；containerd 的 gVisor 需显式选择 `runsc`，CNI 网络尚未配置。BuildKit、Cloud Hypervisor 仅安装工具；WireGuard 通过 NetworkManager 配置，Kea 未启用。
- AI 工作台暂用 Sheprd，Vibex 目前没有 Nix 包；办公使用 ONLYOFFICE。
- sing-box for Desktop 已配置特权后台与授权集成；首次在 GUI 导入订阅并连接，密钥不进入仓库。

`nix flake check` 检查当前桌面和 Noctalia 配置。macOS 使用 `nix flake check path:. --all-systems --no-build --show-trace` 仅做求值；登录、HDR、休眠唤醒和硬件功能需在 Linux 实测。
