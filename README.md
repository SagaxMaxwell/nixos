# NixOS 配置

Ryzen 7 9800X3D + RX 9070 XT；NixOS unstable、CachyOS 内核、Umbriel + Noctalia。

入口 `configuration.nix`；`desktop/` 桌面，`system/` 系统（`memory.nix` 管分配器、zram 与 OOM），`home/` 用户应用。

## 管理约定

用户级应用、工具和 dotfiles 一律由 Home Manager（`home-manager.users.maxwell`）管理，优先 `programs.<name>.enable`，其次 `home.packages`。仅以下留在系统层：服务、驱动、内核与硬件；需要系统权限、udev、PAM 的程序；必须在 `/etc` 的配置与登录 shell；非本用户进程用的资源（如登录界面字体）。

Home Manager 仅作为 NixOS 模块随 `nixos-rebuild` 生效，不启用 `programs.home-manager`、不用 `home-manager switch`；冲突文件备份为 `*.hm-backup`。

## 安装

分区挂载到 `/mnt`，仓库放到 `/mnt/etc/nixos`：

```sh
sudo nixos-generate-config --root /mnt --show-hardware-config | sudo tee /mnt/etc/nixos/hardware-configuration.nix >/dev/null
sudo nixos-install --flake path:/mnt/etc/nixos#nixos
sudo nixos-enter --root /mnt -c 'passwd maxwell'
```

## 构建与更新

```sh
nix flake update                                       # 可选：更新依赖
nix flake check path:. --show-trace
run0 nixos-rebuild switch --flake path:.#nixos
```

macOS 上只能检查求值：`nix flake check path:. --all-systems --no-build`。内核无缓存时会本地编译。

## 备注

- `Super` 启动器，`Super+Enter` Ghostty，右上角停留 0.5 秒打开控制中心。
- 显示器 4K 240Hz 与常开 HDR 待配置：用 `umbriel outputs` 取输出名，绑定 `mode = "3840x2160@240"`、`hdr = "on"` 并移除窗口级 HDR 规则，用 `umbriel color` 确认。
- 显示器开启 DDC/CI；UEFI 开启 Above 4G Decoding 与 Re-Size BAR。
- sing-box 首次需在 GUI 导入订阅；Obsidian 笔记库在 `~/Documents/notes`。
- Steam 启动选项：`gamemoderun %command%`，需性能叠加用 `gamemoderun mangohud %command%`。
- containerd 未配置 CNI，gVisor 需显式选 `runsc`。
- 全局预加载 mimalloc：自带 jemalloc 的程序会在启动时崩溃，需在 `system/memory.nix` 关闭其 jemalloc；排查用 `coredumpctl list`，调用栈出现 `je_*` 即是。
- 剪贴板用 Noctalia 内置；Vibex、MetaOOM 无 Nix 包，以 Sheprd、systemd-oomd 代替。
