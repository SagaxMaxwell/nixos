# NixOS 配置

Ryzen 7 9800X3D + Radeon RX 9070 XT；NixOS unstable、CachyOS master/latest、Umbriel + Noctalia。

入口为 `configuration.nix`；`desktop/umbriel.nix` 配置桌面，`system/` 配置系统，`home/programs.nix` 配置应用。

## 安装

分区并挂载到 `/mnt`，将仓库放到 `/mnt/etc/nixos`，生成本机硬件配置：

```sh
sudo nixos-generate-config --root /mnt --show-hardware-config | sudo tee /mnt/etc/nixos/hardware-configuration.nix >/dev/null
sudo nixos-install --flake path:/mnt/etc/nixos#nixos
sudo nixos-enter --root /mnt -c 'passwd maxwell'
```

## 检查、构建与更新

在 Linux 的仓库目录中执行：

```sh
nix flake check path:. --show-trace
nixos-rebuild build --flake path:.#nixos
run0 nixos-rebuild switch --flake path:.#nixos
```

更新依赖用 `nix flake update`，再执行上述检查与构建。版本由 `flake.lock` 固定；内核无缓存时会本地编译。

仅检查求值（也可在 macOS 执行），不代替 Linux 完整构建与硬件验证：

```sh
nix flake check path:. --all-systems --no-build --show-trace
```

## 使用备注

- `Super` 打开启动器，`Super+Enter` 打开 Ghostty；右上角停留 0.5 秒打开 Noctalia 控制中心。
- 显示器 32M2N8800P 的 **4K 240Hz、常开 HDR 待配置**，当前使用首选模式与自动 HDR，VRR 关闭。安装后用 `umbriel outputs` 取得输出名称，在桌面配置中绑定 `mode = "3840x2160@240"`、`hdr = "on"`，移除窗口级 HDR 规则；用 `umbriel color` 确认。
- 显示器菜单开启 DDC/CI；ReBAR/SAM 在 UEFI 开启 Above 4G Decoding 与 Re-Size BAR。
- sing-box 首次在 GUI 导入订阅并连接。
- Obsidian 笔记库为 `~/Documents/notes`。
- GameMode 不会自动作用于 Steam 游戏，启动选项用 `gamemoderun %command%`；叠加性能显示用 `gamemoderun mangohud %command%`。
- containerd 的 CNI 网络尚未配置，gVisor 需显式选择 `runsc`。
- 剪贴板使用 Noctalia 内置功能，暂不用 Ringboard；Vibex、MetaOOM 目前没有 Nix 包，分别使用 Sheprd、systemd-oomd。
