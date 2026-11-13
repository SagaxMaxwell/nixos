# NixOS 配置

Ryzen 7 9800X3D + RX 9070 XT；NixOS unstable、CachyOS 内核、Umbriel + Noctalia。

入口 `configuration.nix`；`desktop/` 桌面，`system/` 系统（`memory.nix` 管 zram 与 OOM），`home/` 用户应用。

## 管理约定

用户级应用、工具和 dotfiles 一律由 Home Manager（`home-manager.users.maxwell`）管理，优先 `programs.<name>.enable`，其次 `home.packages`。仅以下留在系统层：服务、驱动、内核与硬件；需要系统权限、udev、PAM 的程序；必须在 `/etc` 的配置与登录 shell；非本用户进程用的资源（如登录界面字体）。

Home Manager 仅作为 NixOS 模块随 `nixos-rebuild` 生效，不启用 `programs.home-manager`、不用 `home-manager switch`；冲突文件备份为 `*.hm-backup`。

## 安装

分区挂载到 `/mnt`，在仓库目录执行：

```sh
sudo nixos-generate-config --root /mnt --show-hardware-config > ./hardware-configuration.nix
sudo nixos-install --flake .#nixos
sudo nixos-enter --root /mnt -c 'passwd maxwell'
```

## 日常使用

在仓库目录执行，修改配置后用这一条应用：

```sh
run0 nixos-rebuild switch --flake .#nixos
```

需要升级软件时，先运行 `nix flake update`，再执行上面的命令。内核无缓存时会本地编译。

<details>
<summary>单独检查配置</summary>

NixOS：`nix flake check`。

macOS（只检查求值）：`nix flake check --all-systems --no-build`。

新增文件需先 `git add`，才会被 flake 纳入。

</details>

## 备注

- `Super` 启动器，`Super+Enter` Ghostty，右上角停留 0.5 秒打开控制中心。
- 显示器 4K 240Hz 与常开 HDR 待配置：用 `umbriel outputs` 取输出名，绑定 `mode = "3840x2160@240"`、`hdr = "on"` 并移除窗口级 HDR 规则，用 `umbriel color` 确认。
- 显示器开启 DDC/CI；UEFI 开启 Above 4G Decoding 与 Re-Size BAR。
- sing-box 首次需在 GUI 导入订阅；Obsidian 笔记库在 `~/Documents/notes`。
- Steam 启动选项：`gamemoderun %command%`，需性能叠加用 `gamemoderun mangohud %command%`。
- containerd 未配置 CNI，gVisor 需显式选 `runsc`。
- mimalloc 全局替换有风险：运行时预加载不能覆盖应用内置或直接调用的分配器，混用时可能因分配与释放不匹配导致崩溃。保留系统默认 libc 分配器及各应用默认分配器；有明确性能需求时再针对单个应用测试启用。
- 剪贴板用 Noctalia 内置；Vibex、MetaOOM 无 Nix 包，以 Sheprd、systemd-oomd 代替。
