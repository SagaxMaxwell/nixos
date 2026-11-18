# NixOS 配置

Ryzen 7 9800X3D + RX 9070 XT；NixOS unstable、CachyOS 内核、Umbriel + Noctalia。

本仓库对应 AMD 台式机。远程 `~/Downloads/nixos` 是 Intel + NVIDIA 笔记本，保留自己的硬件配置、NVIDIA PRIME、Ayuz、supergfxd 和 Intel 媒体驱动，不能用本仓库的硬件文件覆盖。

## 结构

| 文件 | 职责 |
| --- | --- |
| `flake.nix` | 依赖、Home Manager、nix-flatpak、透明度和检查项 |
| `configuration.nix` | 系统入口、用户、启动、Nix 和系统级策略 |
| `hardware-configuration.nix` | 当前主机的磁盘、文件系统、CPU 和基础硬件 |
| `home.nix` | Shell、命令行工具、开发工具和用户应用 |
| `helix.nix` / `zed.nix` | 编辑器、格式化器和语言服务 |
| `system/hardware.nix` | AMD 显卡、Btrfs 压缩、zram、OOM 和硬件工具 |
| `system/services.nix` | Flatpak、portal、网络、音频、JustRay、SSH 和权限服务 |
| `system/gaming.nix` | Steam、GameMode、Gamescope、MangoHud 和 Wine |
| `system/virtualisation.nix` | Podman、containerd、gVisor 和虚拟化工具 |
| `umbriel/default.nix` | Umbriel、登录、portal、字体和 Strata |
| `umbriel/compositor.nix` | 布局、窗口规则、快捷键和显示器 |
| `umbriel/noctalia.nix` | 外壳、主题、夜间模式和空闲动作 |
| `umbriel/input.nix` | Fcitx5、Rime 和词库缓存更新 |

## 配置约定

小型应用配置放在 `home.nix`，独立的编辑器和桌面配置使用单独模块。用户应用和 dotfiles 优先使用 Home Manager 的 `programs.<name>`，其次使用 `home.packages`；内核、驱动、系统服务、udev、PAM 和 `/etc` 资源留在 NixOS 层。编辑器语言服务使用 Nix store 路径，同一 derivation 不重复安装。

优先使用上游模块：JustRay 同时声明系统模块和用户服务，Umbriel 使用上游 Home Manager 模块，Rime 使用 `fcitx5-rime.override { rimeDataPkgs; }`，不自行下载词库。快捷键只声明覆盖和新增项。Home Manager 随系统配置生效，冲突文件备份为 `*.hm-backup`；两个 `stateVersion` 是数据兼容基线，不随依赖更新。

Noctalia 的 GUI 设置保存在 `~/.local/state/noctalia/settings.toml`，Zed、Strata、Herdr、Tabularis 和 Claude Code 保留可变配置，Nix 声明优先。删除声明字段后，旧值可能需要手动清理。

软件来源保持单一：系统服务、驱动、CLI、编辑器、Steam、Ghostty、Chrome、Obsidian 和 Strata 来自 nixpkgs 或 Home Manager；OnlyOffice 使用 nix-flatpak，因为它是独立桌面应用且上游发布较快。nix-flatpak 固定到 v0.8.0，由 Nix 声明 Flathub Stable、Flathub Beta、GNOME Nightly、OnlyOffice 和每周更新；Beta 与 Nightly 只提供仓库，不默认安装测试版应用。Flatpak 数据位于 `/var/lib/flatpak`，不进入 Nix store；删除声明不会回滚旧数据，需要时执行 `flatpak uninstall --unused`。Homebrew 只用于独立的 Darwin 配置，NixOS 不依赖 Homebrew。

## 补丁与参数覆盖

本仓库没有源码补丁、`patches` 列表、`fetchpatch` 或 `applyPatches`。以下是功能参数或应用配置，不是源码补丁：

| 位置 | 类型 | 用途 |
| --- | --- | --- |
| `flake.nix` 的 `mkShell.override` | 开发环境参数 | devShell 使用 mold 链接器 |
| `home.nix` 的 `blender.override` | 包参数 | 打开 ROCm 支持以使用 AMD GPU |
| `umbriel/input.nix` 的 `fcitx5-rime.override` | 包参数 | 注入 nixpkgs 的 `rime-ice` 数据 |
| `umbriel/input.nix` 的 `defaultCustom.patch` | 应用配置 | 选择 Rime Ice schema |

## 部署与检查

在仓库目录执行。普通 Git flake 需要先 `git add` 新文件；`path:.` 可直接检查工作目录。仅在激活阶段提权。

| 用途 | 命令 |
| --- | --- |
| 应用配置 | `nixos-rebuild switch --flake .#nixos --elevate run0` |
| 更新依赖 | `nix flake update` |
| 完整检查 | `nix flake check` |
| 仅求值检查 | `nix flake check --no-build --show-trace` |
| 构建但不切换 | `nixos-rebuild build --flake .#nixos` |
| 回到上一代 | `nixos-rebuild switch --rollback --no-reexec --elevate run0` |
| macOS 上检查求值 | `nix flake check --all-systems --no-build` |
| 含未跟踪文件的求值 | `nix flake check path:. --all-systems --no-build` |

`--no-build` 只验证求值；Umbriel 配置验证器和 Noctalia 配置生成需要 Linux 上的完整检查。内核等没有缓存时需要本地编译。

`hardware-configuration.nix` 的磁盘 UUID 保留现有值，CPU 按 AMD 主机配置。换机时用 `nixos-generate-config` 重新生成并核对；Btrfs 压缩独立放在 `system/hardware.nix`，不受重新生成影响。回滚不修改仓库；无法启动时在启动菜单选择旧代。

Nix 使用 Lix，默认只保留仍被 GC 根关联的输出；每周清理超过 30 天的旧代并优化 store。缓存为官方缓存、lantian 和 nix-community，官方缓存排在最前，签名密钥均已配置。

## 桌面

- `Super` 打开启动器，`Super+Enter` 打开 Ghostty；状态栏关闭，鼠标停在右上角 0.5 秒打开控制中心，`Ctrl+Space` 切换美式键盘与 Rime。
- Ghostty 和 Chrome 通过 Home Manager 的 `xdg.autostart` 在图形登录后启动，适用于 Umbriel 及其他支持 XDG 自启动的桌面；Chrome 保留 Home Manager 声明的启动参数。
- Umbriel 使用原生 Wayland、TOML、wlroots 0.20 和 SceneFX；合成器本身不是 Vulkan 渲染，安装 Vulkan 工具不会改变这一点。
- 滚动布局间距 8px，聚焦边框 4px，圆角 12；未聚焦的浮动窗口协商显示标题栏，应用自绘标题栏不受影响。
- Noctalia 使用 One 配色和 `mode = "auto"`，18:00–06:00 深色，夜间色温 5500K；Umbriel 与 Ghostty 通过内置模板跟随，Helix 使用 onedark，Zed 使用自己的主题，其余应用不强制跟随。
- `opacity = 0.55` 为统一透明度，自动计算的 `alpha` 供 Zed 和 mpv 使用。
- 空闲 10 分钟锁屏、15 分钟关闭屏幕、20 分钟挂起；显示器需开启 DDC/CI，UEFI 需开启 Above 4G Decoding 与 Re-Size BAR。
- Obsidian 笔记库为 `~/Documents/notes`，社区插件和主题由 Nix 管理。

Rime 词库或配置更新后会清理编译缓存但保留用户词库，需重启 Fcitx5 重新部署：

```sh
systemctl --user restart app-org.fcitx.Fcitx5@autostart.service
```

修改输入法列表时先退出图形会话，在 TTY 应用，避免旧进程回写。

## 网络、工具与游戏

- JustRay 使用上游内嵌 sing-box-lx 与权限包装，`justrayd` 用户服务已启用登录自启动，不依赖 Ghostty 或 TUI；关闭终端不影响后台连接。后台启动时会尝试恢复保存的活动连接；首次连接仍需在终端运行 `justray`，按 `a` 导入订阅、`m` 切换 TUN、`Enter` 连接。订阅只导入节点，不继承其他客户端的分流规则；应用前退出旧代理客户端。
- Chrome 启用硬件加速与平衡档省内存模式，实际视频解码器可在 `chrome://media-internals` 查看。
- NetworkManager 使用 iwd，DNS 使用 systemd-resolved，TCP 使用 BBR + FQ。
- Btrfs 使用 `compress=zstd:1`，磁盘 swap 禁用，zram 使用一半内存和 zstd，配合 systemd-oomd。
- SSH：`ssh maxwell@<主机-IP>`，支持 SFTP、SCP 和远程开发；WireGuard 提供工具与 NetworkManager 导入方式，连接参数待配置。
- Blender 使用启用 ROCm 的 nixpkgs 构建，Cycles 的 HIP 设备需在应用内选择；Strata 和 Blender 不添加自定义 ThinLTO 参数，Strata 的全量 LTO 与 `codegen-units = 1` 由上游决定。
- Steam 启动选项为 `gamemoderun %command%`；性能叠加使用 `gamemoderun mangohud %command%`。
- containerd 未配置 CNI，gVisor 需要显式选择 `runsc` runtime。

## 软件取舍

以下结论来自当前锁定依赖和配置，更新依赖后可以重新评估。

| 方案 | 未采用或撤回原因 | 当前选择 |
| --- | --- | --- |
| Vibex | 当时没有可用的 nixpkgs 包，不自行打包 | Herdr；早期 Sheprd 已移除 |
| Meta oomd / MetaOOM | 没有可用的 Nix 包 | systemd-oomd + zram-generator |
| Hickory DNS | 虽有包，但接入代理 TUN/DNS 需要额外适配，完整递归当时仍属实验性 | NetworkManager + systemd-resolved，代理 DNS 由 JustRay TUN 处理 |
| Cassotis IME | 锁定的 nixpkgs 没有包，不自行封装 | Fcitx5 + Rime + 雾凇拼音 |
| Rime 万象及独立语法模型 | 固定快照、下载和校验需要额外维护，模型不随 nixpkgs 提供 | `pkgs.rime-ice` |
| Spacedrive 2.x | nixpkgs 没有所需版本；独立二进制封装的目录浏览和索引兼容性不足 | Strata；终端保留 Yazi |
| 原版 niri、Hyprland、Scroll | 需要维护不同语法和个人分支，长期跟进成本高 | Umbriel + Noctalia |
| Ringboard | 与 Noctalia 的剪贴板历史重复 | Noctalia 内置功能 |
| mimalloc 全局替换 | 不能覆盖应用内分配器，和其他分配器混用可能导致崩溃 | 系统 libc 和应用默认分配器 |
| LLVM libc | 不能单独替换桌面、Steam 及其依赖所需的 glibc | glibc |
| 替换 journald | journald 已有完整系统集成 | systemd-journald，限制容量和保留时间 |
| mdevd | 不能替换桌面、硬件和服务依赖的 udev | systemd-udevd |
| 替换 systemd | NixOS、登录会话和系统/用户服务都依赖 systemd | systemd |

Rime 的 Nix store 时间戳可能复用旧编译缓存；当前通过词库和配置指纹变化清理 `build`，保留用户词库，再重启 Fcitx5 部署。

## 已知限制

- 显示器：`umbriel/compositor.nix` 的 `outputName` 留空，4K 240Hz/HDR 输出块未生效。先用 `umbriel outputs` 确认输出名和支持模式；HDR 是否可用取决于显示器 EDID。
- JustRay：订阅报 `tcp: unsupported header type: multi` 时，改用 sing-box JSON / Clash YAML，或尝试在链接末尾加 `?flag=sing-box`。
- 主题：Helix、OnlyOffice、Blender、Steam、mpv 不强制切换；Codex 仅在启动时探测。
- Herdr 已启用 Kitty 图片协议，但 Agent 在 pane 内发图仍受上游终端识别限制；Codex 重启后需要手动 `codex resume`，Claude Code 不受影响。
- 《艾尔登法环》：Steam 大屏幕下姓名框无法打开，普通模式中文候选无法提交，原因待定位。
