# NixOS 配置

这套配置面向 Ryzen 7 9800X3D + RX 9070 XT 台式机，运行 NixOS unstable、CachyOS 内核、Umbriel 和 Noctalia。远程 `~/Downloads/nixos` 是 Intel + NVIDIA 笔记本，硬件配置、PRIME、Ayuz、Intel 媒体驱动和 NVIDIA 应用 offload 保持独立；远程 `supergfxd` 已禁用，Greeter 与 Umbriel 使用 Intel 渲染路径以避免登录阻塞。同步时不能用本机的 AMD 硬件文件覆盖远程配置。

## 文件与配置边界

| 路径 | 内容 |
| --- | --- |
| `flake.nix` | 输入、Home Manager、nix-flatpak、共享透明度和检查项 |
| `configuration.nix` | NixOS 入口、用户、启动、Nix 设置和模块导入 |
| `hardware-configuration.nix` | 当前主机的磁盘、文件系统、CPU 和硬件生成配置 |
| `home.nix` | `maxwell` 的 Home Manager 入口、应用模块和 XDG 设置 |
| `system/` | 字体、硬件、输入法、服务、监控、游戏和虚拟化 |
| `apps/` | 终端、开发工具、桌面应用、媒体和 Agent 工具 |
| `editor/` | Helix、Zed、格式化器和语言服务 |
| `notalia/` | Umbriel、Noctalia Shell、Luciole、Greeter 和官方插件 |
| `README.md` | 当前选择、限制、维护方式和部署命令 |

`configuration.nix` 管理系统层，`home.nix` 管理用户层；Home Manager 已接入 NixOS，一次 `nixos-rebuild switch` 同时应用两层。系统服务、内核、驱动、udev、PAM 和 `/etc` 留在 NixOS 层，应用配置优先使用 Home Manager 的 `programs.<name>`，其次使用 `home.packages`。注释使用简短英文，注释上方留空行，不写同行注释。

两个 `stateVersion` 是数据兼容基线，不随依赖更新。Home Manager 冲突文件备份为 `*.hm-backup`；Noctalia、Luciole、Zed、Herdr、Tabularis、Claude Code、Codex 和 Pi 仍保留可变用户配置，删除声明字段不会自动清理旧值。

## 软件来源

软件按以下顺序选择，避免重复封装和源码补丁：

1. 优先使用 nixpkgs 或上游 flake 的原生模块和包。
2. nixpkgs 没有包、但有官方 Flatpak 时使用 nix-flatpak。
3. 只有 Darwin 独立配置才使用 Homebrew。
4. 没有现成包的项目只记录在取舍表，不自行打包或打补丁。

`nix-flatpak` 由 nixpkgs/flake 配置安装，Flatpak 运行时和应用不独立手工安装。当前配置保留 Flathub Stable、Beta、GNOME Nightly 和每周更新；ibisOffice 使用官方 0.8.9 x86_64 bundle，固定 URL 和 SHA-256，不随 `nix flake update` 自动升级。DOCX、XLSX、PPTX 默认由 ibisOffice 打开。OnlyOffice 已移除；早期 Flatpak 可用 `flatpak uninstall --system org.onlyoffice.desktopeditors` 删除，但保留应用数据。Flatpak 数据位于 `/var/lib/flatpak`，不随 Nix 代回滚，可用 `flatpak uninstall --unused` 清理运行时。

## 系统

| 范围 | 当前配置 |
| --- | --- |
| Nix | Lix、flakes、nix-command；每周 GC（保留 30 天）和 store 优化；官方、lantian、nix-community 缓存统一在 `flake.nix` 声明 |
| 启动 | systemd-boot，最多保留 10 代；CachyOS 最新内核；临时目录开机清理 |
| 文件系统 | Btrfs `compress=zstd:1`；每周自动 scrub；swap 禁用，zram 使用一半内存和 zstd；systemd-oomd 管理用户 slice |
| 网络 | NetworkManager + iwd；systemd-resolved；BBR + FQ；OpenSSH、chrony、PipeWire 和 portal 已启用 |
| 代理 | JustRay 系统模块和用户服务共用同一包；TUN 接口由 NetworkManager 管理，启动或重新应用时将 DNS 指向 `172.19.0.2`、路由域设为 `~.` 并清理缓存 |
| 输入法 | Fcitx5 + Rime + `rime-ice`；Classic UI 不固定深色，跟随桌面主题；用户词库保留，配置变化时清理旧编译缓存 |
| 字体 | `system/fonts.nix` 集中管理字体、回退顺序、Fontconfig 渲染参数和应用字体；不重复安装 Noto CJK 或位图 Emoji |
| 健康监控 | Scrutiny + InfluxDB，原生 NixOS 模块；网页和数据库仅监听 `127.0.0.1`，默认网页 `8080`、InfluxDB `8086` |
| 硬件工具 | AMDGPU initrd/OpenCL、OpenRGB、DDCutil、VA-API、Mesa、NVTop、PCI 和 Vulkan 工具 |
| 虚拟化 | Podman、containerd、BuildKit、Cloud Hypervisor、gVisor；容器运行时状态彼此独立，CNI 尚未额外声明 |

磁盘监控的备选方案是 Home Assistant + SMART Sniffer；它需要额外平台和代理，当前没有部署。历史 `/var/lib/hass` 和 `/var/lib/smartha-agent` 不会自动删除。

## Umbriel 与 Noctalia 桌面

Umbriel 使用 Wayland、TOML、wlroots 0.20 和 SceneFX，上游包自带 XWayland。布局和窗口外观只覆盖个人选择，其余沿用上游默认，避免复制默认配置。

| 项目 | 设置 |
| --- | --- |
| 快捷键 | `Super+Enter` 启动 Ghostty；`Super` 打开启动器；`Ctrl+Space` 切换 `us` 与 Rime |
| 布局 | `scrolling`；默认宽度 `0.7`；宽度 `[0.5, 0.7, 0.9]`；窗口间距 `8px`；边框 `0px`；四侧 struts `-8`；不足一屏时居中 |
| 状态栏 | 顶部、智能隐藏、不占位、接触阴影；控制中心入口在最右侧 |
| Dock | 右侧、智能隐藏、不占位 |
| 主题 | 壁纸取色；主题和 Shell 主题均为 `auto`；纯黑暗色开启；面板使用 `glass` |
| 天气 | IP 自动定位；代理或 VPN 可能改变结果 |
| 夜灯 | 开启；日间 `6500K`，夜间 `6000K` |
| 闲置 | 15 分钟锁屏，20 分钟熄屏，25 分钟锁屏并挂起 |
| 壁纸 | 启动过渡动画；图片每 15 分钟随机轮换，递归读取子目录 |
| 小组件 | 桌面左上天气、右下时间、左下系统监控；锁屏中央时钟；普通组件背景默认 `0.8`，密码框沿用默认 `0.88` |
| Luciole | 官方包和模块；默认文件/目录选择器；启用图片、视频、文本、PDF 预览及 Glycin、FFmpeg、ffmpegthumbnailer、Poppler |

桌面组件坐标按本机 3840×2160、缩放 1 设置，图形编辑器保存的布局可能覆盖声明。远程 Noctalia 5.5.0 在“锁定并挂起”后唤醒时可能丢失锁屏时钟；热加载可以暂时恢复。已排除配置和权限问题，并提交 [Noctalia #5444](https://github.com/noctalia-dev/noctalia/issues/5444)。

状态栏、Dock、通知和 OSD 的背景不透明度为 `0.8`，Ghostty、Zed、mpv、Luciole 也使用该值；Shell 和窗口模糊使用应用或合成器原生设置，不通过补丁强制统一。Anytype、Chrome 没有确认适用的 Linux 原生透明度字段，因此不添加 CSS 或透明化插件。

官方插件源由 `notalia/plugins.nix` 固定提交和校验值，关闭 Git 源和自动更新，避免在线导出阻塞 Shell。当前加载的插件为：

`example`、`screen_recorder`、`bongocat`、`translator`、`timer`、`wallhaven`、`mpvpaper`、`kaomoji`、`notes`、`bitwarden`、`world_clock`、`wallpaper_depth`、`umbriel-companion`、`lyrics`。

插件安装不代表功能已配置：状态栏按钮需在状态栏设置中添加，Timer 需在桌面组件编辑器中添加，Translator 使用启动器 `/tr`，Bitwarden 需要登录，深度壁纸需要模型。Video Wallpaper 需在视频面板选择显示器并点击视频，支持 MOV、MP4、MKV、WebM、GIF；`socat` 用于同步视频和静态帧。插件提供的 Slideshow 与 Shell 图片轮换相互独立。

## 应用、字体与 GPU

| 应用或范围 | 当前配置 |
| --- | --- |
| Ghostty / Zed | 日间 `GitHub Dark Dimmed`，夜间 `IR Black`；终端字体顺序为 Monaspace Neon Var → Cascadia Code NF → Maple Mono NF → Maple Mono NF CN → Recursive → Sarasa Mono SC → Sarasa Term SC |
| Helix | `base16_terminal`，跟随终端调色板 |
| Anytype | nixpkgs 桌面包；本地数据优先，账户和同步在应用内选择 |
| Chrome | 实验性硬件编码特性；主题由浏览器管理；解码器在 `chrome://media-internals`，GPU 路径在 `chrome://gpu` 核实 |
| Blender | `rocmSupport = true`；Cycles 仍需在应用内选择 HIP 设备 |
| Steam | GameMode、Gamescope、MangoHud、Wine；启动选项可用 `gamemoderun %command%` |
| Epic Games Launcher | 社区 flake 的 NixOS 模块；官方 Linux Preview `.deb`，仅 `x86_64-linux` |

GPU 加速分为驱动安装、硬解开关和设备选择三件事。当前本机尚未提供 RX 9070 XT 的 PCI 地址，因此不能宣称所有桌面和视频任务已绑定独显；远程 Greeter/Umbriel 保持 Intel 渲染，应用保留 NVIDIA offload，mpv 和视频壁纸使用 NVDEC。Screen Recorder 只声明 `video_encoder = "gpu"`，具体编码设备需实测。Flatpak、容器和应用自带运行时可能有独立设备权限。

## mpv

当前 mpv 配置为 `hwdec = "auto"`、`vo = "gpu-next"`、`gpu-api = "auto"`，关闭内置 OSC，启用 MPRIS、`uosc + thumbfast`，并安装以下 nixpkgs 包。视频壁纸使用同一 mpv 配置，但插件传入的参数可能覆盖输出设备。

| 类型 | 包 | 是否安装（当前选择） | 包状态 |
| --- | --- | --- | --- |
| 跳过赞助商片段 | `mpvScripts.sponsorblock-minimal` | 是 | 维护 |
| 片头、回顾、片尾 | `mpvScripts.smartskip` | 是 | 维护 |
| 静音跳过与加速 | `mpvScripts.skipsilence` | 是 | 维护 |
| 字幕同步 | `mpvScripts.autosubsync-mpv` | 是 | 维护 |
| 同步观影 | `pkgs.syncplay` | 是 | 维护 |
| 超分着色器 | `pkgs.anime4k` | 是 | 维护 |
| 播放器界面 | `mpvScripts.uosc` + `mpvScripts.thumbfast` | 是 | 维护 |
| 语音转写、字幕翻译、下载、历史、手势、流媒体预加载、剪辑 | — | 否 | 无包或停止维护 |
| `intro-fingerprint`、`TheIntroDB/mpv-script` | — | 否 | 停止或无包 |
| ModernGlass + `thumbz`、`material-osc`、`mpv-prescalers` | — | 否 | 无包 |

`thumbz` 的消息接口与 `uosc` 不兼容，不能单独替换 `thumbfast`。Anime4K 只提供着色器资源，不会自动改变解码或画质。已安装 nixpkgs 包没有本仓库添加的源码补丁。

## Agent 与开发工具

| 工具 | 配置 |
| --- | --- |
| Pi | nixpkgs + Home Manager；主题跟随系统；模型和凭据保留用户选择 |
| Herdr | `apps/herdr.nix`；terminal 主题、会话恢复、屏幕历史、Kitty 图片协议及 Pi／Claude Code／Codex 集成 |
| Delta | Zed 团队的 `delta-nix` flake，提供 Delta CLI 和桌面入口；不是 `pkgs.delta` Git diff 工具 |
| Git | 启用 `rerere`；Difftastic 作为 difftool |
| 语言工具 | nixd、nixfmt、oxfmt、ruff、ty、rustup、Bun、uv、gh、difftastic |
| 终端 | Nushell、Bash、Starship、bat、eza、fd、ripgrep、tealdeer、atuin、bottom、Yazi、zoxide、direnv；bottom 使用终端调色板 |

Pi、Herdr 在 Ghostty 中继承 `opacity = 0.8` 和模糊；Herdr 退出客户端（`Ctrl+B` 后按 `Q`）时后台进程继续运行。`resume_agents_on_restore = true` 和 `pane_history = true` 已启用，但不能恢复任意进程的内存状态；Linux 实机仍需验证完整会话恢复。

Delta 设置由账号同步并保存到加密缓存，不复制 Zed JSON。当前未找到主题导入、透明/模糊或保存时格式化接口；官方尚未运行语言服务器，完整编辑可使用 `Open in Zed`。更新使用 `nix flake update delta`，不使用应用自更新。

## 网络、端口与外部服务

| 服务 | 监听或用途 |
| --- | --- |
| Scrutiny | `127.0.0.1:8080` |
| InfluxDB | `127.0.0.1:8086` |
| JustRay | TUN 和代理 DNS `172.19.0.2`，端口由订阅和 sing-box 决定 |
| SSH | systemd 服务，默认 22；仅按需开放防火墙 |
| WireGuard | 仅安装工具和 NetworkManager 导入支持，未声明连接参数 |
| Flatpak 应用 | 各应用自带运行时，宿主机端口未额外开放 |

JustRay 报 `tcp: unsupported header type: multi` 时，改用 sing-box JSON/Clash YAML，或尝试在链接末尾加 `?flag=sing-box`。首次连接仍需运行 `justray`，按 `a` 导入订阅、`m` 切换 TUN、`Enter` 连接。

## 补丁、覆盖与维护边界

本仓库没有 `patches`、`fetchpatch` 或 `applyPatches`。以下是参数覆盖或应用配置：

| 位置 | 类型 | 用途 |
| --- | --- | --- |
| `flake.nix` `mkShell.override` | 开发环境参数 | devShell 使用 mold 链接器 |
| `apps/desktop.nix` `blender.override` | 包参数 | 启用 ROCm |
| `system/input.nix` `fcitx5-rime.override` | 包参数 | 注入 `rime-ice` 数据 |
| `system/input.nix` `defaultCustom.patch` | 应用配置 | 选择 Rime Ice schema |
| `system/services.nix` `overrideAttrs` | 依赖校验值修正 | 修复 JustRay 锁定提交的 `vendorHash`，不改源码 |

依赖自身可能含 nixpkgs 维护的构建适配：Zed 的链接和 GLib 路径、gVisor 的 `ldconfig` 路径、smartmontools 的 Darwin 框架、Delta 的 ELF/RPATH 包装和自动更新关闭、Herdr 的 notify-send/libghostty 构建选项、Pi 的 npm workspace 整理，以及 Helix Perl 依赖的 `bsearch` 修正。这些都不是本仓库的源码补丁。

## 软件取舍

| 项目 | 当前选择或原因 |
| --- | --- |
| 中文无衬线字体 | 思源黑体 VF → Chiron Hei HK VF；西文 Roboto Flex → Google Sans Flex → Inter；方正可变悠黑因授权和来源未确定而跳过 |
| 输入法 | Fcitx5 + Rime Ice；Cassotis、万象和独立语法模型没有稳定 nixpkgs 来源，不自行封装 |
| 文件管理 | Luciole；Spacedrive 2.x 版本和索引兼容性不足，终端保留 Yazi |
| 合成器 | Umbriel + Noctalia；不同时维护 niri、Hyprland 和其他个人分支 |
| 剪贴板 | Noctalia 内置功能；不重复安装 Ringboard |
| 内存分配器/ libc | 系统默认 glibc；不做全局 mimalloc 或 LLVM libc 替换 |
| 日志与设备管理 | systemd-journald、systemd-udevd；不替换为其他实现 |
| Gas City | nixpkgs 无包，社区 `llm-agents.nix` 有待验证版本；Darwin 使用 Homebrew，NixOS 暂不接入 |
| Vibex | 无现成 Nix 包，继续跳过；Herdr 为当前 Agent 桌面选择 |

## 已知限制

- Umbriel Companion：本机插件源为 1.4.0（API 54），当前 Shell 只支持 API 53；远程单独保留 1.3.0。
- JustRay：锁定提交 `23dd90f` 的依赖校验值不匹配，两端共用已验证的 `vendorHash` 覆盖；上游修正后应移除。
- 远程 Ayuz：上游仍提示 `system` 应改为 `stdenv.hostPlatform.system`，求值通过，本仓库不加补丁。
- Noctalia：旧 `~/.local/state/noctalia/settings.toml` 可能覆盖声明配置；重建不会清理旧 GUI 值。
- Herdr：Kitty 图片协议和 Agent 恢复仍需 Linux 实机验证；Codex 过去需要手动 `codex resume`。
- Steam《艾尔登法环》：大屏幕姓名框和普通模式中文候选仍待定位。

## 待提供的硬件信息

| 信息 | 用途 |
| --- | --- |
| 本机 RX 9070 XT 的 `lspci -Dnn` PCI 地址及 `/dev/dri/by-path/` | 将桌面、应用渲染、视频硬解和录屏编码绑定到独显 |
| 本机 `umbriel outputs` | 核实 `Philips 32M2N8900X` 的分辨率、240 Hz、VRR、HDR、EDID 和实际生效状态 |

本机已声明 `Philips 32M2N8900X` 的 `3840x2160@240`、全屏 VRR、HDR、EDID、sRGB SDR transfer/gamut；这部分不复制到远程内屏。显示器模式仍需通过 OSD 或实机确认。

## 部署与检查

在仓库目录执行；普通 Git flake 需要先 `git add` 新文件，工作树检查可用 `path:.`。只有激活阶段提权。

| 用途 | 命令 |
| --- | --- |
| 应用 | `nixos-rebuild switch --flake .#nixos --elevate run0` |
| 更新输入 | `nix flake update` |
| 完整检查 | `nix flake check` |
| 仅求值 | `nix flake check --no-build --show-trace` |
| 构建不切换 | `nixos-rebuild build --flake .#nixos` |
| 回滚 | `nixos-rebuild switch --rollback --no-reexec --elevate run0` |
| macOS 检查 | `nix flake check --all-systems --no-build` |
| 含未跟踪文件检查 | `nix flake check path:. --all-systems --no-build` |
| Rime 重新部署 | `systemctl --user restart app-org.fcitx.Fcitx5@autostart.service` |

`--no-build` 不构建检查项，但 IFD 仍可能下载或构建。Umbriel 验证器和 Noctalia 配置生成需要 Linux 完整检查；没有缓存时内核可能本地编译。更换机器时重新运行 `nixos-generate-config` 并核对磁盘 UUID；Btrfs 压缩在 `system/hardware.nix` 独立声明，回滚不会修改仓库。
