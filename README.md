# NixOS 配置

这套配置面向 Ryzen 7 9800X3D + RX 9070 XT 台式机，运行 NixOS unstable、CachyOS 内核、Umbriel 和 Noctalia。远程 `~/Downloads/nixos` 是 Intel + NVIDIA 笔记本，硬件文件、显示输出和显卡策略独立维护，不能用本机 AMD 配置覆盖。

## 结构

### 文件结构

| 路径 | 用途 |
| --- | --- |
| `flake.nix` | 输入、缓存、Home Manager、nix-flatpak 和检查项 |
| `configuration.nix` | NixOS 入口、用户、启动和 Nix 设置 |
| `hardware-configuration.nix` | 当前主机生成的磁盘和硬件配置 |
| `home.nix` | maxwell 的 Home Manager 入口 |
| `system/` | 字体、硬件、输入法、服务、监控、游戏和虚拟化 |
| `apps/` | 桌面、终端、开发和 Agent 应用 |
| `editor/` | Helix、Zed、格式化器和语言服务 |
| `notalia/` | Umbriel、Noctalia、Luciole、Greeter 和插件 |

系统服务和硬件放在 NixOS 层，应用配置优先使用 Home Manager 模块，其次使用 `home.packages`。两个 `stateVersion` 只表示数据兼容基线。Home Manager 冲突文件保存为 `*.hm-backup`；应用已有的可变用户配置不会因删除声明字段而自动清理。

注释使用简短英文，注释上方留空行，不写同行注释。

## 软件来源

1. 优先使用 nixpkgs 或上游 flake 的原生包和模块。
2. nixpkgs 没有包但有官方 Flatpak 时使用 nix-flatpak。
3. Homebrew 只用于 Darwin 独立配置。
4. 没有现成包的项目只记录取舍，不自行打包或修改源码。

nix-flatpak 由 Nix 配置安装。当前 Flatpak 应用是 ibisOffice 和 Flectar Mail，运行时来自 Flathub Stable、Beta 或 GNOME Nightly；bundle 版本和 SHA-256 固定，不随 `nix flake update` 自动变化。DOCX、XLSX、PPTX 默认交给 ibisOffice。BetterOffice 目前只有 SDK，没有桌面应用，因此不安装。旧 OnlyOffice 数据不会自动删除，需要时可用 `flatpak uninstall --system org.onlyoffice.desktopeditors` 清理应用，`flatpak uninstall --unused` 清理未使用运行时。

## 系统与桌面

| 范围 | 当前配置 |
| --- | --- |
| Nix | Lix、`flakes`、`nix-command`、`nix-ld`、XDG 基础目录、每周 GC（保留 30 天）和 store 优化 |
| 启动 | `systemd-boot`，最多保留 10 代；CachyOS 最新内核；开机清理临时目录 |
| 文件系统 | Btrfs `compress=zstd:1`、每周 scrub、zram（内存一半，zstd）、`systemd-oomd` |
| 网络 | NetworkManager + iwd、`systemd-resolved`、BBR/FQ、OpenSSH、chrony、PipeWire、portal 和 `wireguard-tools` |
| 桌面服务 | GVFS、GNOME Keyring、fwupd、rtkit、nftables 和 run0；sudo 关闭 |
| 代理 | JustRay 系统与用户服务共用同一包；NetworkManager dispatcher 为 TUN 设置 `172.19.0.2` 和 `~.` DNS 路由域 |
| 输入法 | Fcitx5 + Rime Ice；用户词库保留，部署变化时清理旧编译缓存 |
| 字体 | `system/fonts.nix` 集中管理字体、回退、Fontconfig 渲染和应用字体；关闭默认字体集合，避免重复安装 Noto CJK 与位图 Emoji |
| 健康监控 | Scrutiny + InfluxDB，仅监听 `127.0.0.1`（网页 `8080`、InfluxDB `8086`） |
| 硬件工具 | AMDGPU initrd/OpenCL、`openrgb`、`ddcutil`、`libva-utils`、`mesa-demos`、`nvtopPackages.amd`、`pciutils`、`vulkan-tools`、`vulkan-validation-layers` |
| 虚拟化 | Podman、containerd、`buildkit`、`cloud-hypervisor` 和 `gvisor` |

## Umbriel 与 Noctalia

Umbriel 使用 Wayland 和上游起始配置，只覆盖明确的窗口布局、输出和外观选择。Noctalia 使用壁纸取色、自动主题、玻璃面板、天气、夜灯、壁纸轮换和桌面/锁屏组件。

| 项目 | 设置 |
| --- | --- |
| 快捷键 | `Super+Enter` 启动 Ghostty；`Super` 启动器；`Ctrl+Space` 切换 US 与 Rime |
| 布局 | `scrolling`；默认宽度 `0.7`；预设 `[0.5, 0.7, 0.9]`；窗口间距 `8px`；边框 `0px`；四侧外边距抵消为 `-8` |
| 状态栏 | 顶部、智能隐藏、不占位、接触阴影；控制中心在最右侧 |
| Dock | 右侧、智能隐藏、不占位 |
| 主题与透明度 | 壁纸取色；主题模式自动；纯黑暗色；面板玻璃效果；背景透明度 0.8 |
| 闲置 | 15 分钟锁屏，20 分钟熄屏，25 分钟锁定并挂起 |
| 壁纸 | 启动过渡动画；图片每 15 分钟随机轮换并递归读取目录 |
| 小组件 | 桌面天气、时间、系统监控；锁屏中央时钟 |
| Luciole | 文件/目录选择器；启用图片、视频、文本和 PDF 预览 |

官方插件从 Noctalia 官方 Git 源导入，自动跟随官方源更新。已启用 example、screen_recorder、bongocat、translator、timer、wallhaven、mpvpaper、kaomoji、notes、bitwarden、world_clock、wallpaper_depth、umbriel-companion 和 lyrics。插件安装后仍需按插件要求添加组件、登录或提供模型。

远程 Noctalia 在“锁定并挂起”唤醒后可能丢失锁屏时钟；热加载可恢复，问题已提交 [Noctalia #5444](https://github.com/noctalia-dev/noctalia/issues/5444)。插件安装后仍需按插件要求添加状态栏/桌面组件、登录或提供模型：Translator 使用启动器 /tr，Bitwarden 需要登录，深度壁纸需要模型，Video Wallpaper 支持 MOV、MP4、MKV、WebM 和 GIF。插件 Slideshow 与 Shell 图片轮换相互独立。

## 应用与 GPU

| 应用 | 配置 |
| --- | --- |
| Ghostty / Zed | 日间 GitHub Dark Dimmed，夜间 IR Black；终端字体为 Monaspace Neon Var、Cascadia Code NF、Maple Mono NF/CN、Recursive、Sarasa Mono/Term SC |
| Helix | `base16_terminal`，跟随终端调色板；使用 `wl-clipboard-rs` |
| Anytype | nixpkgs 桌面包；账户和同步在应用内设置 |
| Loupe | nixpkgs 包；常见图片格式默认由 Loupe 打开 |
| `mission-center`、Papers、Tabularis | nixpkgs 桌面包；分别用于系统监控、文档查看和表格编辑 |
| Chrome | 开启实验性硬件编码；GPU 路径需在 `chrome://gpu` 检查 |
| Blender | `rocmSupport = true`；Cycles 设备在应用内选择 HIP |
| Steam | GameMode、Gamescope、MangoHud；`faugus-launcher` 管理 Windows 游戏前缀，`protonup-rs` 管理外部 Proton Runner |
| Epic Games Launcher | 社区 flake 模块；官方 Linux Preview，仅 x86_64-linux |
| ibisOffice / Flectar Mail | 通过 nix-flatpak 声明式安装；文档格式默认交给 ibisOffice |
| Noctalia 插件运行时 | `bitwarden-cli`、`gpu-screen-recorder`、`libinput`、`mpvpaper`、`python3`、`slurp`、`socat`；由插件按需调用 |

本机尚未提供 RX 9070 XT 的 PCI 地址，不能声明所有任务已绑定独显；远程 Greeter/Umbriel 保持 Intel 渲染，应用可使用 NVIDIA offload。mpv 和视频壁纸使用自动硬件解码，实际设备由运行环境选择。Flatpak、容器和应用自带运行时可能有独立设备权限。

## 终端与开发工具

| 类别 | 当前包或模块 |
| --- | --- |
| Shell | Nushell、Bash、Ghostty、Starship、devenv 2.4.0（Nushell 集成） |
| 文件与文本 | `lsr`、`broot`、`mcat`、`ast-grep`、`fd`、`ripgrep`、Yazi；`fd` 和 `ripgrep` 作为 Yazi 搜索依赖保留 |
| 网络与 Nix | `resterm`、`sendme`、`zstd`、`wireguard-tools`、`nix-output-monitor`、`nix-tree`、`mvs` |
| 日常工具 | `tealdeer`、`atuin`、`bottom`、`zoxide`、`ringboard-wayland`、Impression、Ventoy |
| 开发 | `nixd`、`nixfmt`、`oxfmt`、`oxlint`、`ruff`、`ty`、`rust-analyzer`、`tombi`、`rustup`、Bun、`uv`、`gh`、Difftastic、Delta |

已移除 `bat`、`eza`、`xh`、`direnv`、`nix-direnv` 和 `comma`。纯文本搜索可使用系统 `grep`；结构化搜索使用 `ast-grep`。Difftastic 作为 Git difftool 保留。`resterm` 是当前使用的终端 REST 客户端，不能与同名的 reMarkable 投屏工具混淆。Yazi 的 `fd`/`ripgrep` 运行依赖仍保留。

## mpv

mpv 使用 `hwdec = "auto"`、`vo = "gpu-next"`、`gpu-api = "auto"`，关闭内置 OSC，启用 `mpris`、`uosc + thumbfast`。

| 类型 | 当前选择 | 状态 |
| --- | --- | --- |
| 赞助商片段 | `sponsorblock-minimal` | 维护 |
| 片头/回顾/片尾 | `smartskip` | 维护 |
| 静音跳过与加速 | `skipsilence` | 维护 |
| 字幕同步 | `autosubsync-mpv` | 维护 |
| 同步观影 | `syncplay` | 维护 |
| 超分着色器 | `anime4k` | 维护 |
| 播放器界面与缩略图 | `uosc + thumbfast` | 维护 |
| 桌面媒体控制 | `mpris` | 安装，Linux only |
| 片头识别 | `intro-fingerprint`、`TheIntroDB/mpv-script` | 停止维护或无包 |
| 语音转写 | `mpv-sub-fastwhisper` | 无包，不安装 |
| 字幕翻译 | `subtitle-translate-mpv` | 无包，不安装 |
| 字幕下载 | `subfinder` | 无包，不安装 |
| 播放历史 | `mpv-janus` | 无包，不安装 |
| 手势 | `mpv-pointer-event`、`mpv-omniGlass` | 停止维护或无包 |
| 流媒体预加载 | `ytdl-preload` | 无包，不安装 |
| 剪辑 | `mpv_slicing_copy`、`mpv-clip-cutter` | 停止维护或无包 |
| ModernGlass + `thumbz`、`material-osc`、`mpv-prescalers` | — | 无包，不安装 |

语音转写、翻译、下载、历史、手势、流媒体预加载和剪辑脚本没有可用 nixpkgs 包或已停止维护，因此不安装。Anime4K 只提供着色器资源，不会自动改变解码或画质。thumbz 与 uosc 的接口不兼容，不能直接替换 thumbfast；采用 ModernGlass 时需要一并更换播放器界面。

## 网络与端口

| 服务 | 监听或用途 |
| --- | --- |
| Scrutiny | 127.0.0.1:8080 |
| InfluxDB | 127.0.0.1:8086 |
| SSH | 默认端口 22，是否开放由防火墙决定 |
| JustRay | TUN；DNS 172.19.0.2；代理端口由订阅配置决定 |
| WireGuard | 仅安装 CLI 和 NetworkManager 导入支持，未声明连接 |

## Agent 与会话工具

| 工具 | 配置与使用 |
| --- | --- |
| Herdr | `apps/herdr.nix` 接入 Claude Code、Codex、Pi 的 SessionStart 钩子和扩展；在 Herdr 窗格运行 `pi` |
| Pi | 使用 Bun 安装声明在 `settings.packages` 中的 npm 插件；默认提供商为 OpenRouter，模型为 `openrouter/free`，凭据保留用户选择 |
| Claude Code / Codex | 由 Home Manager 启用，主题和凭据保留用户配置；通过 Herdr 钩子同步会话状态 |
| Delta | 上游 `delta-nix` flake 提供 Delta CLI 和桌面入口；与 Git 的 Difftastic difftool 分开使用 |

## 软件取舍

| 项目 | 未采用或撤回原因 | 当前选择 |
| --- | --- | --- |
| LEKTRA | nixpkgs 与已知社区 flake 均无可用包 | Papers |
| OpenGrep | 没有 nixpkgs 包，不自行打包 | ast-grep |
| OmniDiff | 没有 nixpkgs 包，不自行打包 | Difftastic |
| all-smi | 没有 nixpkgs 包，不自行打包 | nvtop |
| Glanvu | 暂无 nixpkgs 包 | Loupe |
| BetterOffice | 目前只有 SDK，没有桌面应用 | 暂不安装 |
| Home Assistant + SMART Sniffer | 可提供健康面板和通知，但需要额外平台与代理 | Scrutiny + InfluxDB（当前选择） |
| FluxDown | nixpkgs 与已知社区包均无可用版本，不自行打包 | 暂不安装 |
| 字体 | 方正可变悠黑的授权和可固定 Nix 来源尚未确认 | 思源黑体 VF → Chiron Hei HK VF；西文使用 Roboto Flex → Google Sans Flex → Inter |
| Hickory DNS | 虽有包，但接入 JustRay TUN/DNS 需要额外适配，完整递归功能仍不作为当前默认 | NetworkManager + systemd-resolved |
| Meta oomd / MetaOOM | 没有可用 Nix 包 | systemd-oomd + zram-generator |
| Cassotis、Rime 万象及独立语法模型 | 没有稳定 nixpkgs 来源；固定快照、模型和校验值需要额外维护 | Fcitx5 + Rime Ice |
| Spacedrive 2.x | nixpkgs 没有所需版本；独立封装的目录浏览和索引兼容性不足 | Luciole；终端保留 Yazi |
| mimalloc 全局替换 | 无法覆盖应用内分配器，混用可能导致崩溃 | 系统 libc 和应用默认分配器 |
| LLVM libc | 不能替换桌面、Steam 及依赖所需的 glibc | glibc |
| 替换 journald | journald 已与系统完整集成 | systemd-journald，并限制容量和保留时间 |
| mdevd | 不能替换桌面和硬件服务依赖的 udev | systemd-udevd |
| 替换 systemd | NixOS、登录会话和系统/用户服务都依赖 systemd | systemd |
| Gas City | nixpkgs 无包；社区版本尚未验证，NixOS 暂不接入 | Darwin 使用 Homebrew，Agent 桌面使用 Herdr |
| Vibex | 无现成 Nix 包，不自行打包 | 暂不安装 |

## 补丁与兼容处理

仓库没有 patches、fetchpatch 或 applyPatches。现有覆盖仅用于参数或依赖：

| 位置 | 用途 |
| --- | --- |
| flake.nix mkShell.override | devShell 使用 mold 链接器 |
| apps/desktop.nix blender.override | 启用 ROCm |
| system/input.nix fcitx5-rime.override | 注入 Rime Ice 数据 |
| system/input.nix defaultCustom | 选择 Rime Ice schema |
| system/fonts.nix | 固定上游字体文件；不是源码补丁 |

nixpkgs 自身可能包含构建适配，例如 Zed 的 GLib 路径、gVisor 的 ldconfig、Delta 的 ELF/RPATH 包装、Herdr 的构建选项和 Helix 依赖修正；这些不属于本仓库的源码补丁。

## 已知限制

- Umbriel Companion 的本机插件源与部分 Shell API 版本可能不一致。
- Noctalia 旧用户状态可能覆盖声明配置；重建不会清理旧 GUI 值。
- JustRay 遇到 tcp: unsupported header type: multi 时改用 sing-box JSON/Clash YAML；首次连接需运行 justray，按 a 导入订阅、m 切换 TUN、回车连接。
- Herdr 的 Kitty 图片协议和 Agent 会话恢复仍需 Linux 实机验证；Pi、Claude Code、Codex 凭据保留用户选择。
- 远程 Ayuz 的上游提示不影响本仓库求值；Steam《艾尔登法环》的中文候选和大屏姓名框仍待定位。
- 应用、Flatpak、容器和视频壁纸的硬件设备选择仍需在实际机器上验证。
- 本机显示器 Philips 32M2N8900X 的 HDR、VRR、EDID 与 3840x2160@240 配置不复制到远程主机。

## 部署与检查

```sh
nixos-rebuild switch --flake .#nixos --elevate run0
nix flake update
nix flake check --all-systems --no-build
nixos-rebuild build --flake .#nixos
nixos-rebuild switch --rollback --no-reexec --elevate run0
```

完整检查会验证 Noctalia 和 Umbriel 配置；普通 Git flake 需要先 git add 新文件，工作树检查可使用 path:.。只有激活阶段需要提权。更换机器时重新运行 nixos-generate-config 并核对磁盘 UUID。

Rime 配置更新后可用 `systemctl --user restart app-org.fcitx.Fcitx5@autostart.service` 重载输入法。
