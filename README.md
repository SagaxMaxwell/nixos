# NixOS 配置

这是 NixOS + Home Manager + Lix 的桌面配置，面向 `x86_64-linux` 主机。系统模块集中在 `modules/`，硬件自动生成文件单独保存。

## 文件

- `flake.nix`：声明依赖、NixOS 主机 `nixos` 和 Home Manager 入口。
- `flake.lock`：锁定 flake 依赖版本。
- `configuration.nix`：系统总配置，负责导入硬件与功能模块。
- `hardware-configuration.nix`：由 `nixos-generate-config` 生成的硬件、文件系统和启动配置；不要手工改动。
- `home.nix`：用户级软件包、桌面工具、Shell 和开发环境。
- `clash-verge.yaml`：mihomo 使用的代理配置文件。
- `README.md`：构建方式和文件说明。
- `LICENSE`、`.gitignore`：许可证和 Git 忽略规则。

## modules/

- `asus.nix`：ROG 控制中心、OpenRGB、电源策略、风扇与温控。
- `desktop.nix`：X11、GDM、GNOME、PipeWire、Flatpak 和桌面门户。
- `fonts.nix`：中文、英文字体和 Nerd Font。
- `gaming.nix`：Steam、Gamescope、GameMode、Jovian 和游戏工具。
- `graphics.nix`：Intel/NVIDIA 图形栈、媒体驱动和诊断工具。
- `input.nix`：Fcitx5 与中文输入法。
- `mihomo.nix`：mihomo 服务、DNS 和 TUN 模式。
- `nvidia.nix`：NVIDIA 驱动与电源管理。

## 构建

```zsh
sudo nixos-rebuild switch --flake .#nixos
```

Lix 由 `configuration.nix` 中的 `nix.package = pkgs.lix` 声明，切换系统时会自动使用。

需要更新依赖时运行 `nix flake update`。
