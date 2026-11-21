# NixOS 配置

Ryzen 7 9800X3D + RX 9070 XT；NixOS unstable、CachyOS 内核、Umbriel + Noctalia。

本仓库对应 AMD 台式机。远程 `~/Downloads/nixos` 是 Intel + NVIDIA 笔记本，保留硬件配置、PRIME、Ayuz 和 Intel 媒体驱动；supergfxd 保持禁用。此前黑屏排查中，远程 Greeter 与 Umbriel 改为 Intel 渲染路径，应用保留 NVIDIA offload 配置；NVIDIA 初始化阻塞的根因仍未解决，同步时须保留实际远程设置，不能用 AMD 硬件文件覆盖。

## 结构

| 文件 | 职责 |
| --- | --- |
| `flake.nix` | 依赖、Home Manager、nix-flatpak、透明度和检查项 |
| `configuration.nix` | NixOS 系统入口、用户账号、启动、Nix 和系统模块导入 |
| `hardware-configuration.nix` | 当前主机的磁盘、文件系统、CPU 和基础硬件 |
| `home.nix` | `maxwell` 的 Home Manager 入口、应用模块导入和基础 XDG 设置 |
| `apps/terminal.nix` | Ghostty、Shell 和终端工具 |
| `apps/development.nix` | Git、开发工具、Pi、Delta 与 Herdr 模块接入 |
| `apps/herdr.nix` | Herdr 外观、会话恢复及 Pi／Claude Code／Codex 官方集成 |
| `apps/desktop.nix` | 浏览器、播放器、Anytype 和其他桌面应用 |
| `editor/helix.nix` / `editor/zed.nix` | 编辑器、格式化器和语言服务 |
| `system/hardware.nix` | AMD 显卡、Btrfs 压缩、zram、OOM 和硬件工具 |
| `system/fonts.nix` | 字体安装、渲染与应用字体设置 |
| `system/services.nix` | Flatpak、portal、网络、音频、JustRay、SSH 和权限服务 |
| `system/monitoring.nix` | Scrutiny 磁盘健康监测与本机数据库 |
| `system/gaming.nix` | Steam、Epic Games Launcher、GameMode、Gamescope、MangoHud 和 Wine |
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

优先使用上游模块：JustRay 分别提供系统集成和用户服务，Umbriel 和 Luciole 使用上游 NixOS/Home Manager 模块，Rime 使用 nixpkgs 的词库包。Umbriel 基于锁定版本的 `examples/config.toml`，覆盖 Ghostty 快捷键、滚动布局、窗口边框、拖动不透明度、XWayland 原生分辨率和应用自启动；其余随上游更新，不维护默认值副本。Home Manager 冲突文件备份为 `*.hm-backup`；两个 `stateVersion` 是数据兼容基线，不随依赖更新。

Noctalia 的 GUI 设置保存在 `~/.local/state/noctalia/settings.toml`，可以覆盖声明配置；移除 Nix 设置不会自动清除已有 GUI 设置。Luciole、Zed、Herdr、Tabularis、Claude Code、Codex 和 Pi 也保留可变配置，具体合并方式由各自模块决定，删除声明字段后旧值可能仍保留。

软件优先使用 nixpkgs，由 NixOS 或 Home Manager 配置；Luciole 使用其官方 flake 模块，JustRay 等使用 `flake.nix` 锁定的上游输入。ibisOffice 替代 OnlyOffice，通过 nix-flatpak v0.8.0 的原生 `bundle` 字段安装官方 0.8.9 x86_64 Flatpak，固定下载地址和 SHA-256，无本地补丁；DOCX、XLSX、PPTX 默认由它打开。保留 Flathub Stable、Flathub Beta、GNOME Nightly 和每周更新；ibisOffice 尚未上架 Flathub，升级需修改 `system/services.nix` 中的版本地址和校验值，不随 `nix flake update` 或每周 Flatpak 更新自动升级。Flatpak 数据位于 `/var/lib/flatpak`，不随 Nix 代回滚；可用 `flatpak uninstall --unused` 清理未使用的运行时。Homebrew 仅用于独立的 Darwin 配置。

历史：nixpkgs 的 OnlyOffice 包原生解决了跳过 NixOS 字体链接的问题；现已从安装列表移除。应用配置后，若仍有早期手动安装的 Flatpak 版，可用 `flatpak uninstall --system org.onlyoffice.desktopeditors` 移除；保留应用数据，不加 `--delete-data`。

## 补丁与参数覆盖

本仓库没有源码补丁、`patches` 列表、`fetchpatch` 或 `applyPatches`。以下是功能参数或应用配置，不是源码补丁：

| 位置 | 类型 | 用途 |
| --- | --- | --- |
| `flake.nix` 的 `mkShell.override` | 开发环境参数 | devShell 使用 mold 链接器 |
| `apps/desktop.nix` 的 `blender.override` | 包参数 | 打开 ROCm 支持以使用 AMD GPU |
| `system/input.nix` 的 `fcitx5-rime.override` | 包参数 | 注入 nixpkgs 的 `rime-ice` 数据 |
| `system/input.nix` 的 `defaultCustom.patch` | 应用配置 | 选择 Rime Ice schema |
| `system/services.nix` 的 `overrideAttrs` | 依赖校验值修正 | 修正 JustRay 锁定提交的 `vendorHash`，系统与用户服务共用同一包；不修改源码 |

依赖包仍可能包含 nixpkgs 维护的构建适配。以下是已确认的例子，不代表整个传递依赖闭包：

| 依赖 | 适配内容 |
| --- | --- |
| Zed | 移除上游链接参数覆盖，调整 WebRTC 动态链接、GLib 头文件路径和许可证生成工具版本 |
| gVisor | 将 `/sbin/ldconfig` 替换为 Nix store 中的路径 |
| smartmontools | nixpkgs 的补丁调整 Darwin 链接框架，不改变 Linux 分支；本仓库无额外补丁 |
| Delta 官方 flake | 修正发布二进制的 ELF 加载器／RPATH，使用 Nix 的 libxkbcommon 并包装运行环境、禁用应用自更新；上游 Linux 打包适配，本仓库无额外补丁 |
| Herdr（Linux） | nixpkgs 固定 notify-send 路径，并调整内嵌 libghostty 的 compiler-rt／ubsan 构建选项 |
| Pi | nixpkgs 从同版本 npm 发布补充模型目录并整理 workspace 依赖；上游离线构建与安装处理 |
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

`--no-build` 不构建检查项，但求值中的 IFD 仍可能触发下载或构建。Umbriel 配置验证器和 Noctalia 配置生成需要 Linux 上的完整检查；内核等没有缓存时需要本地编译。

`hardware-configuration.nix` 的磁盘 UUID 保留现有值，CPU 按 AMD 主机配置。换机时用 `nixos-generate-config` 重新生成并核对；Btrfs 压缩独立放在 `system/hardware.nix`，不受重新生成影响。回滚不修改仓库；无法启动时在启动菜单选择旧代。

Nix 使用 Lix，每周清理超过 30 天的旧代和未引用的 store 路径，并优化 store。缓存包含官方、lantian、nix-community；额外地址和公钥统一在 `flake.nix` 声明，供 flake 调用与 `configuration.nix` 中的 Nix 服务共用。

## 桌面

| 功能 | 配置 |
| --- | --- |
| 快捷键 | `Super+Enter` 启动 Ghostty，其余沿用上游默认；`Super` 打开启动器，`Ctrl+Space` 切换美式键盘与 Rime |
| 自启动 | Ghostty、Chrome 使用 Umbriel `general.autostart`，引用 Home Manager 程序路径并保留 Chrome 参数；更改后重新登录 |
| 平铺 | `scrolling`，默认列宽 `0.7`，档位 `[0.5, 0.7, 0.9]`；横纵间距 `8px`、边框 `0px`，四侧 struts 均为 `-8`，抵消外侧间距；不足一屏时居中，仍尊重面板占位 |
| 状态栏 | 顶部智能隐藏、不占位，开启接触阴影，控制中心入口最右；空工作区或概览中显示，有窗口时按需隐藏，触及边缘可显示；`auto_hide_delay_ms` 是普通自动隐藏模式的隐藏延迟 |
| Dock | 右侧智能隐藏、不占位，显示延迟沿用上游默认值 |
| Shell 与登录 | Shell 随壁纸取色（`theme.source = "wallpaper"`），主题模式与 Shell 主题模式均为 `auto`；热角沿用默认值，夜灯启用，日间 `6500K`、夜间 `6000K`；Greeter 默认 Umbriel 会话 |
| 闲置动作 | 启用闲置 15 分钟锁屏、20 分钟熄屏、25 分钟锁屏并睡眠（Suspend）；时间从闲置开始计算，不累加，合盖策略独立 |
| 小组件 | 锁屏中央时钟、下方密码框；桌面左上天气、右下时钟、左下系统监控（CPU 与内存使用率）。普通组件背景默认 `0.8`；本机组件不指定屏幕，自动选择可用屏幕，密码框由 Shell 自动生成（默认 `0.88`）。布局在 `notalia/shell.nix`，坐标仍按 3840×2160、缩放 1 设置，不会自动适配所有分辨率；图形编辑器保存的布局可覆盖声明配置 |
| 锁屏组件待排查 | 远程 Noctalia 5.5.0 锁定并挂起后，唤醒时钟可能消失；未发现相关配置或权限异常，热加载可暂时恢复但不稳定。已提交 [Noctalia #5444](https://github.com/noctalia-dev/noctalia/issues/5444)，尚未修复 |
| 天气 | `location.auto_locate = true`，按 IP 定位；代理或 VPN 可能改变定位结果 |
| 图片壁纸轮换 | 每 15 分钟随机切换，包含子目录；使用 Shell 原生 `wallpaper.automation`，视频壁纸轮播由插件单独管理 |
| 文件管理 | Luciole 使用官方 Nix 包，作为默认目录和文件选择器；启用图片、视频、文本、PDF 预览，运行时包含 Glycin、FFmpeg、ffmpegthumbnailer 与 Poppler |
| 应用主题 | Ghostty、Zed 对齐 `~/darwin` 设置，使用 Nix 包；日夜主题 GitHub Dark Dimmed / IR Black，Zed 自动安装主题扩展；Helix 使用 `base16_terminal` |
| 应用字体 | Ghostty、Zed 内置终端使用 Monaspace Neon Var → Cascadia Code NF → Maple Mono NF → Maple Mono NF CN → Recursive → Sarasa Mono SC → Sarasa Term SC；界面与编辑区采用应用默认 |
| Anytype | 使用 nixpkgs 的 `anytype` 桌面包；本地优先，账户与同步方式在应用内选择；既有 `~/Documents/notes` 笔记保留，不自动迁移 |

Umbriel 使用 Wayland、TOML、wlroots 0.20 和 SceneFX，上游包自带 XWayland 供 Steam、Wine 等使用，无需额外安装。保留 XWayland 原生分辨率设置，其余未覆盖的焦点、窗口规则和外观沿用上游配置。合成器不是 Vulkan 渲染，安装 Vulkan 工具不会改变这一点。ibisOffice、Blender、Steam、mpv 不强制切换主题，Codex 仅在启动时探测。DDC 亮度控制需显示器开启 DDC/CI，UEFI 需开启 Above 4G Decoding 与 Re-Size BAR。

`opacity = 0.8` 统一 Ghostty、Zed、mpv、Luciole，以及 Shell 状态栏、Dock、通知、OSD 的背景不透明度；`alpha` 自动转为十六进制。Shell 面板采用 `glass`，具体层次透明度由上游控制，不再使用此前的 `soft`。mpv 视频、Luciole 菜单和对话框保持原样；Zed 内层保留零 alpha，避免叠色。Umbriel 拖动不透明度也为 `0.8`。

模糊使用 Umbriel 上游窗口及图层规则和强度，Ghostty、Zed 与 Shell 状态栏、Dock 启用原生模糊；不额外叠加整窗透明度。模糊强度不等于不透明度，Greeter 壁纸模糊不作数值同步。Anytype、Chrome 未确认有适用的 Linux 原生背景数值设置，跳过该数值设置；不添加自定义 CSS snippet、不安装窗口透明化插件、不打补丁。

14 个官方插件由 `notalia/plugins.nix` 固定源码版本和校验值，Home Manager 安装运行依赖，Shell 从原生 `path` 源 `nix-official` 加载。关闭 Shell Git 源与自动更新，避免在线导出阻塞界面；更新插件需单独更新该文件，不随 `nix flake update` 自动变化，也不修改插件源码。Companion 的 API 限制见下表。

Settings → Plugins 管理插件；状态栏按钮需在状态栏设置添加，Timer 在桌面组件编辑器添加，Translator 使用启动器 `/tr` 前缀。Bitwarden 需登录、深度壁纸需安装模型；安装不代表这些条件已满足。

Video Wallpaper 选择目录后，还需在视频面板选择显示器并点击视频；可用 `noctalia msg panel-toggle noctalia/mpvpaper:picker` 打开。支持 MOV、MP4、MKV、WebM、GIF 混放；Slideshow 按间隔轮播，设置持久保存，当前版本没有对应 Nix 间隔字段。`socat` 用于跟踪当前视频和同步静态帧；Shell 的图片轮换不控制视频轮播。

Rime 通过配置与词库指纹检测变化并清理编译缓存，避免 Nix store 时间戳导致旧缓存复用；用户词库保留。更新后重启 Fcitx5 重新部署：

```sh
systemctl --user restart app-org.fcitx.Fcitx5@autostart.service
```

修改输入法列表时先退出图形会话，在 TTY 应用，避免旧进程回写。

## 网络、工具与游戏

- JustRay 使用上游内嵌 sing-box-lx 与权限包装，`justrayd` 用户服务已启用登录自启动，不依赖 Ghostty 或 TUI；关闭终端不影响后台连接。后台启动时会尝试恢复保存的活动连接；首次连接仍需在终端运行 `justray`，按 `a` 导入订阅、`m` 切换 TUN、`Enter` 连接。订阅只导入节点，不继承其他客户端的分流规则；应用前退出旧代理客户端。
- Chrome 声明实验性硬件编码特性；内存节省模式由浏览器设置管理，实际视频解码器可在 `chrome://media-internals` 查看。
- NetworkManager 使用 iwd，DNS 使用 systemd-resolved，TCP 使用 BBR + FQ。
- JustRay 接口启动或重新应用时，NetworkManager 钩子将 DNS 指向 TUN 的 `172.19.0.2`，设置路由域 `~.` 并清理缓存；接口移除后自动恢复普通网络 DNS。
- Btrfs 使用 `compress=zstd:1`，每周自动 scrub 校验，同一设备的子卷不重复校验；磁盘 swap 禁用，zram 使用一半内存和 zstd，配合 systemd-oomd。
- 磁盘健康监测方案：**Home Assistant + SMART Sniffer**、**Scrutiny（当前选择）**。`system/monitoring.nix` 使用 Scrutiny 原生 NixOS 模块，自动启用 smartd、每日采集器和 InfluxDB，无自定义下载包或本地补丁；版本随 nixpkgs 锁定输入更新。应用配置后访问 <http://127.0.0.1:8080> 查看 SMART/NVMe 健康数据与历史趋势，网页和数据库均仅监听本机；首次采集可运行 `sudo systemctl start scrutiny-collector.service`。邮件或推送告警尚未配置。
- 备选 Home Assistant + SMART Sniffer 提供健康面板和 Home Assistant 内通知，需部署平台及代理；此前固定 1.0.0，每 5 分钟采集，首次读取后跳过待机磁盘，集成通过 Nix 安装而无需 HACS。现已移除该方案的声明，原网页 `8123`、代理 `9099` 和账号接入步骤不再适用；若曾启用，`/var/lib/hass` 与 `/var/lib/smartha-agent` 的历史数据不自动删除。
- Zed 启用类型与参数内联提示（`inlay_hints.enabled`），具体支持取决于语言服务器。
- mpv 界面与缩略图组合：`thumbfast + material-osc`、[ModernGlass + thumbz](https://github.com/akFace/mpv.config/tree/c4f8bd5c27833ab3061320ba947df75f166f988c/src/modern_glass)、`uosc + thumbfast`。当前选择 **uosc + thumbfast**，使用 nixpkgs 包，关闭自带控制条，保留 MPRIS 桌面媒体控制。ModernGlass + thumbz 支持实时缩略图、故事板预渲染和缓存；进度条缓存用于当前文件，菜单封面另有持久缓存。thumbz 与 uosc 的消息接口不同，不能直接替换 thumbfast，采用时需一并更换界面。
- Git 启用 `rerere`，记录并复用相同冲突的解决方式，复用后仍需检查并手动暂存。
- SSH：`ssh maxwell@<主机-IP>`，支持 SFTP、SCP 和远程开发；WireGuard 提供工具与 NetworkManager 导入方式，连接参数待配置。
- Blender 使用启用 ROCm 的 nixpkgs 构建，Cycles 的 HIP 设备需在应用内选择。
- Steam 启动选项为 `gamemoderun %command%`；性能叠加使用 `gamemoderun mangohud %command%`。
- Epic Games Launcher 使用社区 `epic-games-launcher-flake` 的 NixOS 模块，封装 Epic 官方 Linux Preview `.deb`；专有软件，限 `x86_64-linux`，更新锁定输入以获取上游新构建。Windows 游戏由启动器下载并配置 GE-Proton。
- Podman 与 containerd 是独立运行时，不共享容器状态；BuildKit、Cloud Hypervisor 仅安装工具。containerd 尚未声明 CNI 网络配置，gVisor 需显式选择 `runsc` runtime。

## Agent 工具

| 工具 | 安装与配置 |
| --- | --- |
| Pi | nixpkgs + Home Manager 原生模块，`system` 主题跟随终端；运行 `pi` 后通过 `/login` 登录并选择模型 |
| Herdr | `apps/herdr.nix` 使用 `terminal` 主题，保留会话恢复、屏幕历史及 Kitty 图片协议；直接链接安装包内 Pi／Claude Code／Codex 官方扩展或钩子 |
| Delta（Zed 团队） | [官方 `delta-nix` flake](https://github.com/zed-industries/delta-nix)，与主系统共用 nixpkgs，提供 `delta` CLI 和桌面入口；专有应用，不是 Git diff 工具 `pkgs.delta` |
| Gas City | 当前锁定的 nixpkgs 无包；已找到社区 `numtide/llm-agents.nix` 的 1.5.1 包，尚未接入或验证；Darwin 使用 Homebrew |
| Vibex | 暂无现成 Nix 包，继续跳过，见软件取舍 |

Pi／Herdr 在 Ghostty 中沿用 `opacity = 0.8` 和模糊配置；它们没有独立的窗口不透明度字段，Linux 实际模糊效果取决于合成器。Pi 设置可变，Nix 只固定主题，模型与凭据保留用户选择。无需再手工安装 Herdr 集成。

Herdr 退出客户端（`Ctrl+B` 后按 `Q`）时后台进程继续运行；服务器重启后恢复布局及上报了有效引用的 Agent 对话。`resume_agents_on_restore = true` 和 `pane_history = true` 已启用；对话恢复优先于屏幕历史重放，不能恢复任意进程的内存状态。原有 Codex 手动恢复记录保留为历史问题，本次补齐 SessionStart 钩子，实际恢复仍需在 Linux 激活后验证。

Delta 的设置由账号同步并保存到加密缓存，不复制 Zed 的 JSON 字段。主题目标参考 Zed 的 `GitHub Dark Dimmed`／`IR Black`，但尚未找到对应主题导入、透明／模糊或 Herdr 集成接口，暂不设置。它会按需下载语法高亮扩展，但官方明确尚不运行语言服务器；诊断、补全和跳转不可照搬，也未找到保存时格式化接口。完整编辑可使用 `Open in Zed`。参见 [Delta 设置](https://delta.dev/docs/configuration/settings)、[语言支持](https://delta.dev/docs/agents/language-support)。

更新 Delta 使用 `nix flake update delta` 后重建；不使用应用自更新。配置同步只复制声明文件，不执行远程构建或 `switch`。2026-11-19 已核对 Pi 1.5.2、Herdr 0.9.5、Delta 0.28.3 及生成的用户路径；2026-11-21 再次在 macOS 上检查全部 Nix 文件格式、Flake 与系统 derivation 求值及模块断言。Linux 构建、桌面效果和会话恢复仍待目标机器验证。

## 软件取舍

以下保留此前的选型理由，包可用性属于当时的检查结果，可随依赖更新重新评估。当前选择覆盖大量字体、14 个插件、两款编辑器、两种容器运行时，以及 Scrutiny 和 InfluxDB；并非最小安装，完整健康面板及数据库的资源开销也高于独立磁盘采集器。未使用功能的取舍应单独决定。

| 方案 | 未采用或撤回原因 | 当前选择 |
| --- | --- | --- |
| 方正可变悠黑 | 尚未取得适用授权及可用于 Nix 的字体文件，暂不声明安装 | 中文无衬线回退顺序为思源黑体 VF → Chiron Hei HK VF；西文为 Roboto Flex → Google Sans Flex → Inter |
| Vibex | 2026-11-19 复核仍无现成 Nix 包，不自行打包 | Herdr；早期 Sheprd 已移除 |
| Gas City | nixpkgs 无包；社区 [llm-agents.nix](https://github.com/numtide/llm-agents.nix/blob/main/packages/gascity/package.nix) 已提供 1.5.1，待验证；tmux 后端存在 Nix 包装器进程识别报告 [#7551](https://github.com/gastownhall/gascity/issues/7551)，不能据此推断 Herdr 后端同样受影响 | Darwin 已通过 Homebrew 声明；NixOS 尚未接入社区包 |
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
| JustRay 构建 | 锁定提交 `23dd90f` 的依赖校验值不匹配；两端共用已验证的 `vendorHash` 修正，更新到上游修正版后可移除 |
| 远程 Ayuz | 上游依赖求值仍提示 `system` 应改为 `stdenv.hostPlatform.system`；系统求值通过，本仓库不加补丁，待上游更新 |
| GUI 覆盖 | Noctalia 的旧 `settings.toml` 可以关闭状态栏或覆盖插件配置；重建不会自动清除，先备份再处理冲突字段 |

- JustRay：订阅报 `tcp: unsupported header type: multi` 时，改用 sing-box JSON / Clash YAML，或尝试在链接末尾加 `?flag=sing-box`。
- Herdr 已启用 Kitty 图片协议，但 Agent 在 pane 内发图仍受上游终端识别限制；此前 Codex 重启后需要手动 `codex resume`，本次已补齐原生恢复钩子，待 Linux 实机复验；Claude Code 此前不受影响。
- 《艾尔登法环》：Steam 大屏幕下姓名框无法打开，普通模式中文候选无法提交，原因待定位。

## 待提供的硬件信息

以下信息需在 AMD 的 NixOS 主机上获取。

| 项目 | 待提供的信息 | 后续调整 |
| --- | --- | --- |
| RX 9070 XT | `lspci -Dnn` 中的显卡 PCI 地址，以及 `ls -l /dev/dri/by-path/` 输出 | 指定独显用于桌面、应用渲染、视频硬解与录屏编码；目前尚未指定具体设备 |
| 显示器 | `umbriel outputs` 输出，核实匹配名称、分辨率和刷新率，以及 EDID/HDR 支持 | 已对 `Philips 32M2N8900X` 声明 `3840x2160@240`、全屏 VRR、HDR、EDID 色彩配置及 sRGB SDR 传递函数和色域；仍需实机确认生效，不同步到远程内屏 |

## 显卡使用范围

目标是支持 GPU 加速的功能优先使用独显。驱动安装、启用硬解与选择具体显卡是三件事；本机仍待提供 PCI 地址，不能把 `hwdec=auto` 或 `video_encoder=gpu` 当成已选中 RX 9070 XT。

| 范围 | 当前配置与限制 |
| --- | --- |
| Umbriel、Greeter、Shell、Ghostty、Zed、游戏 | 本机待指定 AMD 独显；远程 Greeter 与 Umbriel 使用 Intel 渲染路径以恢复登录，应用保留 NVIDIA offload 配置，实际 GPU 及稳定性仍需验证 |
| mpv、视频壁纸 | 本机自动选择硬解，待绑定 AMD 独显；远程已指定 NVDEC |
| Screen Recorder | 显式使用 `video_encoder = "gpu"`；插件没有具体 GPU 选择字段，实际编码设备需录制时验证 |
| Chrome、Anytype 等 Chromium/Electron 应用 | GPU 渲染不等于视频硬解；Chrome 已声明硬件编码特性，解码路径与设备需通过 `chrome://gpu`、`chrome://media-internals` 核实；NVIDIA VA-API 不保证适用于 Chromium |
| Blender | 本机包启用 ROCm，Cycles 仍需在应用内选择 HIP 与 RX 9070 XT；远程需选择可用的 CUDA/OptiX 与 NVIDIA 设备，不能仅靠图形渲染环境变量指定计算设备 |
| Luciole 缩略图、插件缩略图与 FFmpeg | 当前相关调用没有统一的硬解设备字段；安装 FFmpeg 不会让所有调用自动使用 GPU，不修改上游代码来强制替换 |
| Flatpak、容器和应用自带运行时 | 设备权限、驱动和加速选项由各自运行环境决定，宿主机变量不能保证全部覆盖 |
