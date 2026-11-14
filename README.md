# NixOS 配置

Ryzen 7 9800X3D + RX 9070 XT；NixOS unstable、CachyOS 内核、Umbriel + Noctalia。

入口 `configuration.nix`；`desktop/` 桌面，`system/` 系统（`memory.nix` 管 zram 与 OOM），`home/` 用户应用。

## 管理约定

用户级应用、工具和 dotfiles 一律由 Home Manager（`home-manager.users.maxwell`）管理，优先 `programs.<name>.enable`，其次 `home.packages`。仅以下留在系统层：服务、驱动、内核与硬件；需要系统权限、udev、PAM 的程序；必须在 `/etc` 的配置与登录 shell；非本用户进程用的资源（如登录界面字体）。

Home Manager 随 `nixos-rebuild` 生效；冲突文件备份为 `*.hm-backup`，只保留最近一份。

Noctalia 的 GUI 设置可覆盖 Nix 配置，保存在 `~/.local/state/noctalia/settings.toml`。Zed、Sheprd 保留可变配置；删除 Nix 字段后，用户文件中的旧值需手动清理。

## 首次接管

先正常安装 NixOS，再在本仓库目录执行，无需手动挂载。仅更换机器或首次接管时生成硬件配置；已有正确配置则跳过。

```sh
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
git add hardware-configuration.nix
```

核对 `system/hardware.nix` 中的 CPU、显卡设置。尚未应用本配置时，用仓库指定的 rebuild 工具首次接管；命令临时启用 flakes，使用原系统的 sudo：

```sh
nix --extra-experimental-features 'nix-command flakes' run .#nixosConfigurations.nixos.config.system.build.nixos-rebuild -- switch --flake .#nixos --elevate sudo
```

## 常用命令

均在仓库目录执行。应用配置（普通用户运行，仅激活时提权）：

```sh
nixos-rebuild switch --flake .#nixos --elevate run0
```

升级软件：先运行 `nix flake update`，再应用配置。新增配置文件先 `git add 文件路径`；不必提交。内核等软件无缓存时会本地编译。

<details>
<summary>检查、构建与回滚（按需执行）</summary>

| 用途 | 命令 |
| --- | --- |
| 检查配置与仓库校验项 | `nix flake check` |
| 查看构建计划，不编译 | `nixos-rebuild dry-build --flake .#nixos` |
| 完整构建，不切换系统 | `nixos-rebuild build --flake .#nixos` |
| 回到上一代系统 | `nixos-rebuild switch --rollback --no-reexec --elevate run0` |
| 在 macOS 上仅检查求值 | `nix flake check --all-systems --no-build` |

回滚不修改仓库文件；无法进入系统时，在启动菜单选择旧代。

</details>

## 备注

- `Super` 启动器，`Super+Enter` Ghostty，右上角停留 0.5 秒打开控制中心。
- 主题与夜间暖色按本地时间 18:00–06:00 切换；应用需支持跟随系统主题。暖色在边界前后各 30 分钟渐变。
- `Ctrl+Space` 切换美式键盘与雾凇拼音；`Super+Space` 保留 Umbriel 默认功能。输入法列表由 Home Manager 写入；修改列表时先退出图形会话，在 TTY 应用配置，避免旧进程回写。
- 等待支持 HDR、240Hz、4K 显示器的设备名称；填入 `desktop/umbriel.nix` 的 `outputName` 后启用 4K 240Hz、常开 HDR，留空不生效。
- 显示器开启 DDC/CI；UEFI 开启 Above 4G Decoding 与 Re-Size BAR。
- sing-box 首次需在 GUI 导入订阅；NetworkManager + systemd-resolved 随 TUN 启停切换 DNS，防火墙放行 `tun0`。
- SSH 支持 SFTP/SCP 和远程开发：`ssh maxwell@<主机-IP>`。WireGuard 已提供 `wg`、`wg-quick`，也可用 NetworkManager 导入连接；连接参数待配置。
- [Hickory DNS](https://github.com/hickory-dns/hickory-dns/tree/main/bin)：注重性能的现代 Rust 异步架构，可作 DNS 替换候选；完整递归仍属实验性，与当前 sing-box TUN/DNS 链路配合需额外适配，暂未启用，未实测性能优势。
- Obsidian 笔记库在 `~/Documents/notes`。
- Steam 启动选项：`gamemoderun %command%`，需性能叠加用 `gamemoderun mangohud %command%`。
- containerd 未配置 CNI，gVisor 需显式选 `runsc`。
- mimalloc 全局替换有风险：运行时预加载不能覆盖应用内置或直接调用的分配器，混用时可能因分配与释放不匹配导致崩溃。保留系统默认 libc 分配器及各应用默认分配器；有明确性能需求时再针对单个应用测试启用。
- 剪贴板用 Noctalia 内置；Vibex、MetaOOM 无 Nix 包，以 Sheprd、systemd-oomd 代替。
