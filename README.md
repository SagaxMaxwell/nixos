# NixOS 配置

Ryzen 7 9800X3D + RX 9070 XT；NixOS unstable、CachyOS 内核、Umbriel + Noctalia。

入口 `configuration.nix`；`desktop/` 桌面，`system/` 系统（`memory.nix` 管 zram 与 OOM），`home/` 用户应用。

## 管理约定

用户级应用、工具和 dotfiles 一律由 Home Manager（`home-manager.users.maxwell`）管理，优先 `programs.<name>.enable`，其次 `home.packages`。仅以下留在系统层：服务、驱动、内核与硬件；需要系统权限、udev、PAM 的程序；必须在 `/etc` 的配置与登录 shell；非本用户进程用的资源（如登录界面字体）。

Home Manager 随 `nixos-rebuild` 生效；冲突文件备份为 `*.hm-backup`，只保留最近一份。

Noctalia 的 GUI 设置可覆盖 Nix 配置，保存在 `~/.local/state/noctalia/settings.toml`。Zed、Strata、Herdr、Tabularis、Claude Code 保留可变配置；删除 Nix 字段后，用户文件中的旧值需手动清理。

## 首次接管

先正常安装 NixOS，再在本仓库目录执行，无需手动挂载。`hardware-configuration.nix` 由 NixOS 工具按目标机器自动生成，仓库不附带；首次构建前须生成并纳入 flake。核对 `system/hardware.nix` 中的 CPU、显卡设置；已有正确硬件配置则跳过前两步。首次接管命令临时启用 flakes，使用原系统的 sudo。

| 步骤 | 命令 |
| --- | --- |
| 生成硬件配置 | `sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix` |
| 将硬件配置纳入 flake | `git add hardware-configuration.nix` |
| 首次应用配置 | `nix --extra-experimental-features 'nix-command flakes' run .#nixosConfigurations.nixos.config.system.build.nixos-rebuild -- switch --flake .#nixos --elevate sudo` |

## 常用命令

均在仓库目录执行；普通用户运行，仅激活时提权。更新依赖后需再次应用配置。新增文件不必提交即可构建；内核等软件无缓存时会本地编译。

| 用途 | 命令 |
| --- | --- |
| 应用配置 | `nixos-rebuild switch --flake .#nixos --elevate run0` |
| 更新依赖 | `nix flake update` |
| 将新增配置文件纳入 flake | `git add 文件路径` |
| 检查配置与仓库校验项 | `nix flake check` |
| 查看构建计划，不编译 | `nixos-rebuild dry-build --flake .#nixos` |
| 完整构建，不切换系统 | `nixos-rebuild build --flake .#nixos` |
| 回到上一代系统 | `nixos-rebuild switch --rollback --no-reexec --elevate run0` |
| 在 macOS 上仅检查求值（需目标机硬件配置） | `nix flake check --all-systems --no-build` |

回滚不修改仓库文件；无法进入系统时，在启动菜单选择旧代。

## 使用说明

- 系统字体使用 Fontconfig 的 medium hinting 并禁用内嵌位图；应用可能采用自己的渲染策略。高分屏 XWayland 使用原生分辨率，重新登录生效；不自行缩放界面的旧应用可能显示较小。
- `Super` 启动器，`Super+Enter` Ghostty，右上角停留 0.5 秒打开控制中心。
- `Ctrl+Space` 切换美式键盘与万象拼音；`Super+Space` 保留 Umbriel 默认功能。Rime 数据更新并应用配置后，重启 Fcitx5 重新部署；修改输入法列表时先退出图形会话，在 TTY 应用配置，避免旧进程回写。
- Noctalia 使用 One Dark Warmer，Umbriel 与 Ghostty 通过内置模板跟随；白天为配套浅色，18:00–06:00 为深色。夜间暖色沿用同一时间表，在边界前后各 30 分钟渐变。
- Strata（Atelier Cave）、Herdr、Tabularis、Claude Code、Fcitx5 启用深浅联动；Qt 应用接入系统 portal。Ghostty、Zed、Obsidian、Chrome、Yazi、bat 沿用已有联动。
- Mission Center 默认跟随系统主题；bottom 使用终端前景色与 ANSI 调色板，随 Ghostty 昼夜配色变化。
- 原生背景透明度由 `flake.nix` 的 `opacity = 0.55` 统一，表示 55% 不透明，与 Noctalia `glass` 外层一致（内部卡片 65%）。不强制整窗透明；数值越低越透明。
- 显示器开启 DDC/CI；UEFI 开启 Above 4G Decoding 与 Re-Size BAR。
- JustRay 使用上游 flake，内嵌 sing-box-lx；`justray`（或 `jray`）打开 TUI，字体、背景和 ANSI 配色跟随 Ghostty。后台登录启动，关闭 TUI 保持连接，重启后恢复活动节点与模式；自启动由 Nix 管理。
- 首次按 `a` 导入订阅、`m` 切换 TUN、`Enter` 连接；`o` 设置、`q` 退出界面。`justray down` 断开，`justray status` 查看状态。订阅仅导入节点，不继承旧客户端分流；默认局域网直连，其余代理。应用新系统前退出旧代理客户端。
- JustRay 配置、订阅和连接状态保存在 `~/.config/justray/`；Nix 合并阿里 DoH、允许 QUIC，订阅不写入仓库。保留 NetworkManager + systemd-resolved，授予 maxwell 用户切换隧道 DNS 的权限；不开放局域网代理端口。
- Chrome 启用硬件加速和平衡档省内存模式；视频硬解取决于显卡、驱动与编码格式，可在 `chrome://media-internals` 查看实际解码器。
- TCP 使用 BBR + FQ；显式启用 Btrfs 支持，所有声明为 Btrfs 的挂载统一使用 `compress=zstd:1`。仅影响后续写入，不转换文件系统或自动重压缩旧文件。
- SSH 支持 SFTP/SCP 和远程开发：`ssh maxwell@<主机-IP>`。
- Obsidian 笔记库：`~/Documents/notes`。
- Steam 启动选项：`gamemoderun %command%`；需性能叠加时用 `gamemoderun mangohud %command%`。

## 软件与组件选择

| 软件／方案 | 取舍 | 当前方案 |
| --- | --- | --- |
| Vibex | 暂未找到可用 Nix 包 | Herdr |
| Meta oomd | 暂未找到可用 Nix 包，不自行打包 | systemd-oomd |
| [Hickory DNS](https://github.com/hickory-dns/hickory-dns/tree/main/bin) | 已有 Nix 包；与代理 TUN/DNS 联动需额外适配；Rust 异步架构，完整递归仍属实验性，性能未实测 | NetworkManager + systemd-resolved |
| Cassotis IME | 当前锁定 nixpkgs 没有包，不自行封装 | Fcitx5 + Rime + 万象 |
| 万象语法模型 | 上游 LTS 可覆盖，nixpkgs 未包含模型 | [快照 20261112153433](https://github.com/OrdChaos/RIME-LMDG.snapshot/releases/tag/20261112153433) + 固定 SHA-256 校验，经 `rimeDataPkgs` 合并；约 389.6 MiB，哈希与官方 LTS 一致，更新时同步修改 `system/input.nix` 的版本与哈希 |
| Rime 缓存兼容 | Nix store 时间戳固定，Rime 可能复用旧编译结果 | 跟踪词库、模型和配置；变化时清理 `build` 缓存，保留用户词库，重启 Fcitx5 后部署 |
| Ringboard | 已有 Nix 包；Noctalia 已提供剪贴板历史 | Noctalia 内置剪贴板 |
| mimalloc 全局替换 | 预加载无法覆盖所有分配器，混用可能导致崩溃 | 系统及应用默认分配器，按需单独测试 |
| LLVM libc | 不能直接替换当前桌面与 Steam 依赖的 glibc | glibc |
| journald | 足够现代，保留 | systemd-journald |
| mdevd | 不能直接替换本配置依赖的 udev 集成 | systemd-udevd |
| systemd | 当前 NixOS 模块与服务依赖它，不能直接替换 | systemd |

## 已知问题与待配置

- JustRay：若 URI 订阅报 `tcp: unsupported header type: multi`，改用订阅商的 sing-box JSON／Clash YAML；当前订阅支持在链接末尾加 `?flag=sing-box`，无需源码补丁。
- 《艾尔登法环》：Steam 大屏幕下姓名框无法打开，允许 Umbriel 输入控制后仍无效；普通模式可输入英文，中文候选无法提交，原因待定位。
- 显示器：等待实际输出名称；填入 `desktop/umbriel.nix` 的 `outputName` 后启用 4K 240Hz、常开 HDR，留空不生效。
- WireGuard：已提供 `wg`、`wg-quick` 和 NetworkManager 导入方式，连接参数待配置。
- containerd：CNI 网络尚未配置；gVisor 需显式选择 `runsc`。
- 深浅主题：Helix、ONLYOFFICE Linux、Blender、Steam、mpv 暂不强制切换；Codex 仅在启动时探测。
- Herdr 内 Agent 图片：已开启 `terminal.kitty_graphics = true`；Claude Code／Codex 在 Herdr pane 中的图片发送仍受上游终端识别限制，等待修复。
