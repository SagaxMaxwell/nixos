# NixOS 配置

Ryzen 7 9800X3D + RX 9070 XT；NixOS unstable、CachyOS 内核、Umbriel + Noctalia。

本仓库对应 AMD 台式机。远程 `~/Downloads/nixos` 是 Intel + NVIDIA 笔记本，保留自己的硬件配置、NVIDIA PRIME、Ayuz、supergfxd 和 Intel 媒体驱动，不能用本仓库的硬件文件覆盖。

## 结构

| 文件 | 职责 |
| --- | --- |
| `flake.nix` | 依赖、Home Manager、nix-flatpak、透明度和检查项 |
| `configuration.nix` | NixOS 系统入口、用户账号、启动、Nix 和系统模块导入 |
| `hardware-configuration.nix` | 当前主机的磁盘、文件系统、CPU 和基础硬件 |
| `home.nix` | `maxwell` 的 Home Manager 入口、应用模块导入和基础 XDG 设置 |
| `apps/terminal.nix` | Ghostty、Shell 和终端工具 |
| `apps/development.nix` | Git、开发工具和 AI 工具 |
| `apps/desktop.nix` | 浏览器、播放器、Obsidian 和其他桌面应用 |
| `editor/helix.nix` / `editor/zed.nix` | 编辑器、格式化器和语言服务 |
| `system/hardware.nix` | AMD 显卡、Btrfs 压缩、zram、OOM 和硬件工具 |
| `system/fonts.nix` | 字体安装、渲染与应用字体设置 |
| `system/services.nix` | Flatpak、portal、网络、音频、JustRay、SSH 和权限服务 |
| `system/gaming.nix` | Steam、GameMode、Gamescope、MangoHud 和 Wine |
| `system/virtualisation.nix` | Podman、containerd、gVisor 和虚拟化工具 |
| `notalia/default.nix` | 团队模块入口及共用桌面集成 |
| `notalia/umbriel.nix` | Umbriel 滚动布局、窗口外观、XWayland 和应用自启动 |
| `notalia/shell.nix` | Noctalia Shell 服务、背景透明度与模糊 |
| `notalia/luciole.nix` | Luciole、预览、文件选择门户和目录关联 |
| `notalia/greeter.nix` | 登录界面和默认会话 |
| `notalia/plugins.nix` | 官方插件及其运行依赖 |
| `system/input.nix` | Fcitx5、Rime 和词库缓存更新 |

## 配置约定

`configuration.nix` 导入硬件、`system/` 和 `notalia/`，管理整台机器；`home.nix` 导入 `apps/` 和 `editor/`，管理 `maxwell` 的用户环境。Home Manager 已接入 NixOS，一次 `nixos-rebuild switch` 同时应用两层配置。

`notalia/` 每个组件一个文件，用户部分通过 `home-manager.users.maxwell` 声明。应用和 dotfiles 优先使用 Home Manager 的 `programs.<name>`，其次使用 `home.packages`；内核、驱动、系统服务、udev、PAM 和 `/etc` 留在 NixOS 层。编辑器语言服务使用 Nix store 路径；多处引用同一包不会重复下载或存储。注释使用简短英文，前留空行，不写同行注释。

优先使用上游模块：JustRay 分别提供系统集成和用户服务，Umbriel 和 Luciole 使用上游 NixOS/Home Manager 模块，Rime 使用 nixpkgs 的词库包。Umbriel 以锁定版本的上游 `examples/config.toml` 为基础，仅覆盖滚动布局、窗口边框、拖动不透明度、XWayland 原生分辨率和应用自启动；其余设置随上游更新，不维护本地默认值副本。Home Manager 冲突文件备份为 `*.hm-backup`；两个 `stateVersion` 是数据兼容基线，不随依赖更新。

Noctalia 的 GUI 设置保存在 `~/.local/state/noctalia/settings.toml`，可以覆盖声明配置；移除 Nix 设置不会自动清除已有 GUI 设置。Luciole、Zed、Herdr、Tabularis 和 Claude Code 也保留可变配置，具体合并方式由各自模块决定，删除声明字段后旧值可能仍保留。

软件优先使用 nixpkgs，由 NixOS 或 Home Manager 配置；Luciole 使用其官方 flake 模块，JustRay 等使用 `flake.nix` 锁定的上游输入。OnlyOffice 使用 nix-flatpak v0.8.0，声明 Flathub Stable、Flathub Beta、GNOME Nightly，默认从 Stable 安装，每周更新；Beta 与 Nightly 不默认安装应用。Flatpak 数据位于 `/var/lib/flatpak`，不随 Nix 代回滚；可用 `flatpak uninstall --unused` 清理未使用的运行时。Homebrew 仅用于独立的 Darwin 配置。

## 补丁与参数覆盖

本仓库没有源码补丁、`patches` 列表、`fetchpatch` 或 `applyPatches`。以下是功能参数或应用配置，不是源码补丁：

| 位置 | 类型 | 用途 |
| --- | --- | --- |
| `flake.nix` 的 `mkShell.override` | 开发环境参数 | devShell 使用 mold 链接器 |
| `apps/desktop.nix` 的 `blender.override` | 包参数 | 打开 ROCm 支持以使用 AMD GPU |
| `system/input.nix` 的 `fcitx5-rime.override` | 包参数 | 注入 nixpkgs 的 `rime-ice` 数据 |
| `system/input.nix` 的 `defaultCustom.patch` | 应用配置 | 选择 Rime Ice schema |

依赖包仍可能包含 nixpkgs 维护的构建适配。以下是已确认的例子，不代表整个传递依赖闭包：

| 依赖 | 适配内容 |
| --- | --- |
| Zed | 移除上游链接参数覆盖，调整 WebRTC 动态链接、GLib 头文件路径和许可证生成工具版本 |
| gVisor | 将 `/sbin/ldconfig` 替换为 Nix store 中的路径 |
| Helix 的 Perl 语法依赖 | 移除与 glibc 冲突的 `bsearch` 实现及引用 |

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

Nix 使用 Lix，每周清理超过 30 天的旧代和未引用的 store 路径，并优化 store。缓存包含官方、lantian、nix-community；额外地址和公钥统一在 `flake.nix` 声明，供 flake 调用与 `configuration.nix` 中的 Nix 服务共用。

## 桌面

| 功能 | 配置 |
| --- | --- |
| 快捷键 | 上游默认：`Super` 启动器、`Super+Enter` Kitty；`Ctrl+Space` 切换美式键盘与 Rime |
| 自启动 | Ghostty、Chrome 使用 Umbriel `general.autostart`，引用 Home Manager 程序路径并保留 Chrome 参数；更改后重新登录 |
| 平铺 | `scrolling`，默认列宽 `0.7`，档位 `[0.5, 0.7, 0.9]`；横纵间距 `8px`、边框 `0px`，四侧 struts 均为 `-8`，抵消外侧间距；不足一屏时居中，仍尊重面板占位 |
| 状态栏 | 顶部自动隐藏、不占位，控制中心入口最右；当前版本触及边缘即显示，`auto_hide_delay_ms` 仅控制隐藏延迟 |
| Dock | 右侧自动隐藏、不占位，悬停 `500ms` 后出现 |
| Shell 与登录 | 配色、热角、夜灯、闲置行为沿用默认值；Greeter 默认 Umbriel 会话 |
| 天气 | `location.auto_locate = true`，按 IP 定位；代理或 VPN 可能改变定位结果 |
| 文件管理 | Luciole 使用官方 Nix 包，作为默认目录和文件选择器；启用图片、视频、文本、PDF 预览，运行时包含 Glycin、FFmpeg、ffmpegthumbnailer 与 Poppler |
| 应用主题 | Ghostty、Zed 对齐 `~/darwin` 设置，使用 Nix 包；日夜主题 Tokyo Night Storm / IR Black，Zed 自动安装主题扩展；Helix 使用 `base16_terminal` |
| 应用字体 | Ghostty、Zed 界面及编辑区采用应用默认；Zed 内置终端 Cascadia Code NF → Maple Mono NF → Maple Mono NF CN |
| Obsidian | 笔记库 `~/Documents/notes`，社区插件与主题由 Nix 管理 |

Umbriel 使用 Wayland、TOML、wlroots 0.20 和 SceneFX，上游包自带 XWayland 供 Steam、Wine 等使用，无需额外安装。保留 XWayland 原生分辨率设置，其余未覆盖的焦点、窗口规则和外观沿用上游配置。合成器不是 Vulkan 渲染，安装 Vulkan 工具不会改变这一点。OnlyOffice、Blender、Steam、mpv 不强制切换主题，Codex 仅在启动时探测。DDC 亮度控制需显示器开启 DDC/CI，UEFI 需开启 Above 4G Decoding 与 Re-Size BAR。

`opacity = 0.8` 统一 Ghostty、Kitty、Zed、mpv、Luciole，以及 Shell 状态栏、Dock、通知、OSD 的背景不透明度；`alpha` 自动转为十六进制。Shell 面板采用 `soft`（外层 `0.8`，内卡片由上游调整）。mpv 视频、Luciole 菜单和对话框保持原样；Zed 内层保留零 alpha，避免叠色。Umbriel 拖动不透明度也为 `0.8`。

模糊使用 Umbriel 上游窗口及图层规则和强度，Ghostty、Zed 与 Shell 状态栏、Dock 启用原生模糊；不额外叠加整窗透明度。模糊强度不等于不透明度，Greeter 壁纸模糊不作数值同步。Obsidian、Chrome 未确认有适用的 Linux 原生背景数值设置，跳过；不注入 CSS、不安装透明化插件、不打补丁。

14 个官方插件由 `notalia/plugins.nix` 固定源码版本和校验值，Home Manager 安装运行依赖，Shell 从原生 `path` 源 `nix-official` 加载。关闭 Shell Git 源与自动更新，避免在线导出阻塞界面；更新插件需单独更新该文件，不随 `nix flake update` 自动变化，也不修改插件源码。Companion 的 API 限制见下表。

Settings → Plugins 管理插件；状态栏按钮需在状态栏设置添加，Timer 在桌面组件编辑器添加，Translator 使用启动器 `/tr` 前缀。Bitwarden 需登录、深度壁纸需安装模型；安装不代表这些条件已满足。

Rime 通过配置与词库指纹检测变化并清理编译缓存，避免 Nix store 时间戳导致旧缓存复用；用户词库保留。更新后重启 Fcitx5 重新部署：

```sh
systemctl --user restart app-org.fcitx.Fcitx5@autostart.service
```

修改输入法列表时先退出图形会话，在 TTY 应用，避免旧进程回写。

## 网络、工具与游戏

- JustRay 使用上游内嵌 sing-box-lx 与权限包装，`justrayd` 用户服务已启用登录自启动，不依赖 Ghostty 或 TUI；关闭终端不影响后台连接。后台启动时会尝试恢复保存的活动连接；首次连接仍需在终端运行 `justray`，按 `a` 导入订阅、`m` 切换 TUN、`Enter` 连接。订阅只导入节点，不继承其他客户端的分流规则；应用前退出旧代理客户端。
- Chrome 声明实验性硬件编码特性；内存节省模式由浏览器设置管理，实际视频解码器可在 `chrome://media-internals` 查看。
- NetworkManager 使用 iwd，DNS 使用 systemd-resolved，TCP 使用 BBR + FQ。
- Btrfs 使用 `compress=zstd:1`，磁盘 swap 禁用，zram 使用一半内存和 zstd，配合 systemd-oomd。
- SSH：`ssh maxwell@<主机-IP>`，支持 SFTP、SCP 和远程开发；WireGuard 提供工具与 NetworkManager 导入方式，连接参数待配置。
- Blender 使用启用 ROCm 的 nixpkgs 构建，Cycles 的 HIP 设备需在应用内选择。
- Steam 启动选项为 `gamemoderun %command%`；性能叠加使用 `gamemoderun mangohud %command%`。
- Podman 与 containerd 是独立运行时，不共享容器状态；BuildKit、Cloud Hypervisor 仅安装工具。containerd 尚未声明 CNI 网络配置，gVisor 需显式选择 `runsc` runtime。

## 软件取舍

以下保留此前的选型理由，包可用性属于当时的检查结果，可随依赖更新重新评估。当前选择覆盖大量字体、14 个插件、两款编辑器及两种容器运行时；配置可精简，但并非最小安装，未使用功能的取舍应单独决定。

| 方案 | 未采用或撤回原因 | 当前选择 |
| --- | --- | --- |
| Vibex | 当时没有可用的 nixpkgs 包，不自行打包 | Herdr；早期 Sheprd 已移除 |
| Meta oomd / MetaOOM | 没有可用的 Nix 包 | systemd-oomd + zram-generator |
| Hickory DNS | 虽有包，但接入代理 TUN/DNS 需要额外适配，完整递归当时仍属实验性 | NetworkManager + systemd-resolved，代理 DNS 由 JustRay TUN 处理 |
| Cassotis IME | 锁定的 nixpkgs 没有包，不自行封装 | Fcitx5 + Rime + 雾凇拼音 |
| Rime 万象及独立语法模型 | 固定快照、下载和校验需要额外维护，模型不随 nixpkgs 提供 | `pkgs.rime-ice` |
| Spacedrive 2.x | nixpkgs 没有所需版本；独立二进制封装的目录浏览和索引兼容性不足 | Luciole；终端保留 Yazi |
| 原版 niri、Hyprland、Scroll | 需要维护不同语法和个人分支，长期跟进成本高 | Umbriel + Noctalia |
| Ringboard | 与 Noctalia 的剪贴板历史重复 | Noctalia 内置功能 |
| mimalloc 全局替换 | 不能覆盖应用内分配器，和其他分配器混用可能导致崩溃 | 系统 libc 和应用默认分配器 |
| LLVM libc | 不能单独替换桌面、Steam 及其依赖所需的 glibc | glibc |
| 替换 journald | journald 已有完整系统集成 | systemd-journald，限制容量和保留时间 |
| mdevd | 不能替换桌面、硬件和服务依赖的 udev | systemd-udevd |
| 替换 systemd | NixOS、登录会话和系统/用户服务都依赖 systemd | systemd |

## 已知限制

| 项目 | 当前限制 |
| --- | --- |
| Umbriel Companion | 本机随插件源使用 1.4.0（API 54），当前 Shell 仅支持到 API 53，升级前无法加载；按用户选择不固定旧版。远程单独保留 1.3.0，同步时保留差异 |
| JustRay 构建 | 当前锁定提交 `23dd90f` 曾确认存在 `vendorHash` 与依赖不匹配；本机未添加校验值覆盖，需采用上游修正版本后再确认构建 |
| GUI 覆盖 | Noctalia 的旧 `settings.toml` 可以关闭状态栏或覆盖插件配置；重建不会自动清除，先备份再处理冲突字段 |

- 显示器：没有强制指定输出模式或 HDR。后续配置前用 `umbriel outputs` 确认输出名和支持模式；HDR 是否可用取决于显示器 EDID。
- JustRay：订阅报 `tcp: unsupported header type: multi` 时，改用 sing-box JSON / Clash YAML，或尝试在链接末尾加 `?flag=sing-box`。
- Herdr 已启用 Kitty 图片协议，但 Agent 在 pane 内发图仍受上游终端识别限制；Codex 重启后需要手动 `codex resume`，Claude Code 不受影响。
- 《艾尔登法环》：Steam 大屏幕下姓名框无法打开，普通模式中文候选无法提交，原因待定位。
