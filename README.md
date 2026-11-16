# NixOS 配置

Ryzen 7 9800X3D + RX 9070 XT；NixOS unstable、CachyOS 内核、Umbriel + Noctalia。

## 结构

只保留 `system/` 和 `umbriel/` 两个一级目录。

| 文件 | 职责 |
| --- | --- |
| `flake.nix` | 依赖、Home Manager 集成、共享透明度与桌面检查 |
| `configuration.nix` | 系统入口、用户、启动、Nix 与 Chrome 策略 |
| `hardware-configuration.nix` | 磁盘、文件系统、CPU 与基础硬件信息 |
| `home.nix` | Shell、命令行工具、Herdr 与用户应用 |
| `helix.nix` / `zed.nix` | 编辑器、格式化与语言服务 |
| `system/hardware.nix` | AMD 显卡、Btrfs 压缩、zram、OOM 与硬件工具 |
| `system/services.nix` | 网络、音频、JustRay、SSH 与权限服务 |
| `system/gaming.nix` | Steam、GameMode、Gamescope、MangoHud 与 Wine |
| `system/virtualisation.nix` | Podman、containerd、gVisor 与虚拟化工具 |
| `umbriel/default.nix` | 桌面入口、登录、portal、字体与 Strata |
| `umbriel/compositor.nix` | 布局、窗口规则、快捷键与显示器 |
| `umbriel/noctalia.nix` | 桌面外壳、主题、夜间模式与空闲动作 |
| `umbriel/input.nix` | Fcitx5、Rime 与词库缓存更新 |

## 约定

小型应用配置放在 `home.nix`；较大且独立的编辑器与桌面配置单独维护。系统模块可以同时声明相关的 Home Manager 设置，让同一功能的服务与用户配置保持在一起。

用户应用和 dotfiles 优先使用 Home Manager 的 `programs.<name>`，其次使用 `home.packages`。内核、驱动、系统服务及需要权限、udev、`/etc` 的资源留在 NixOS 层。编辑器语言服务使用 Nix store 绝对路径；需要终端直接调用的工具也在 `home.nix` 提供，同一 derivation 不会重复安装。

优先使用上游模块。JustRay 使用系统模块与用户服务，Umbriel 使用上游 Home Manager 模块，Rime 使用 `fcitx5-rime.override { rimeDataPkgs; }`，不自行封装词库下载。快捷键只声明覆盖或新增项。

Home Manager 随系统配置生效；冲突文件备份为 `*.hm-backup`，仅保留最近一份。Noctalia 的 GUI 设置可覆盖 Nix 配置，保存在 `~/.local/state/noctalia/settings.toml`。两个 `stateVersion` 保持安装时版本，不随依赖更新调整。

## 部署与检查

| 用途 | 命令 |
| --- | --- |
| 应用配置 | `nixos-rebuild switch --flake .#nixos --elevate run0` |
| 更新依赖 | `nix flake update` |
| 完整检查 | `nix flake check` |
| 构建但不切换 | `nixos-rebuild build --flake .#nixos` |
| 回到上一代 | `nixos-rebuild switch --rollback --no-reexec --elevate run0` |
| macOS 上仅求值 | `nix flake check --all-systems --no-build` |
| 含未跟踪文件的求值 | `nix flake check path:. --all-systems --no-build` |

在仓库目录执行，仅激活时提权。普通 Git flake 需要先 `git add` 新文件；`path:.` 可直接检查工作目录。`--no-build` 只验证求值，Umbriel 配置验证器和 Noctalia 配置生成需要在 Linux 上运行完整检查。内核等没有缓存时需要本地编译。

`hardware-configuration.nix` 的磁盘 UUID 保留现有值，CPU 已按 AMD 主机统一。换机时用 `nixos-generate-config` 重新生成并核对。Btrfs 压缩独立放在 `system/hardware.nix`，不受重新生成影响。回滚不修改仓库；无法启动时在启动菜单选择旧代。

## 桌面

- `Super` 打开启动器，`Super+Enter` 打开 Ghostty；状态栏关闭，右上角停留 0.5 秒打开控制中心，`Ctrl+Space` 切换输入法与美式键盘。
- 滚动布局，间距 8px、聚焦边框 4px、圆角 12；仅未聚焦的浮动窗口协商显示标题栏，应用自绘标题栏不受影响。
- Noctalia 使用 One，Umbriel 与 Ghostty 通过内置模板跟随；18:00–06:00 深色，夜间色温 5500K。Strata、Herdr、Tabularis、Claude Code 跟随系统主题，Fcitx5 使用深色候选框，Qt 通过 portal 接入。
- `flake.nix` 的 `opacity = 0.55` 统一透明度，表示 55% 不透明；自动计算的十六进制 `alpha` 供 Zed 与 mpv 使用。
- 空闲 10 分钟锁屏、15 分钟关闭屏幕、20 分钟挂起。
- 显示器需开启 DDC/CI；UEFI 开启 Above 4G Decoding 与 Re-Size BAR。
- Obsidian 笔记库为 `~/Documents/notes`，社区插件与主题由 Nix 管理。

Rime 词库或配置更新后会清理编译缓存，保留用户词库；需重启 Fcitx5 重新部署：

```sh
systemctl --user restart app-org.fcitx.Fcitx5@autostart.service
```

修改输入法列表时先退出图形会话，在 TTY 应用，避免旧进程回写。

## 网络与工具

- JustRay 使用上游内嵌 sing-box-lx 与权限包装，以用户服务运行。首次按 `a` 导入订阅、`m` 切换 TUN、`Enter` 连接；订阅只导入节点，不继承其他客户端的分流规则。应用前退出旧代理客户端。
- Chrome 启用硬件加速与平衡档省内存模式；实际视频解码器可在 `chrome://media-internals` 查看。
- NetworkManager 使用 iwd，DNS 使用 systemd-resolved；TCP 使用 BBR + FQ。
- Btrfs 使用 `compress=zstd:1`，仅影响后续写入；磁盘 swap 被禁用，zram 使用一半内存和 zstd 压缩，配合 systemd-oomd。
- SSH：`ssh maxwell@<主机-IP>`，支持 SFTP/SCP 与远程开发。
- Steam 启动选项：`gamemoderun %command%`；性能叠加使用 `gamemoderun mangohud %command%`。

## 软件与组件取舍

这里记录希望采用但尚未启用，以及试用后撤回的方案和替代选择。缺包与兼容性结论来自本仓库当时锁定的依赖和配置，不代表上游永久不支持；更新依赖后可重新评估。后续精简 README 时保留本章及各项理由。

| 希望采用／评估过的方案 | 未采用或撤回的原因 | 当前选择 |
| --- | --- | --- |
| Vibex | 当时未找到可用的 nixpkgs 包，不自行打包 | Herdr；早期曾使用 Sheprd，现已移除 |
| Meta oomd（历史记录亦称 MetaOOM） | 当时未找到可用的 Nix 包，不自行打包 | systemd-oomd，配合 zram-generator |
| [Hickory DNS](https://github.com/hickory-dns/hickory-dns/tree/main/bin) | 有 Nix 包，但接入代理 TUN/DNS 链路需要额外适配；历史评估时完整递归仍属实验性，未实测性能优势 | NetworkManager + systemd-resolved，代理 DNS 由 JustRay 的 TUN 处理 |
| Cassotis IME | 当时锁定的 nixpkgs 没有包，不自行封装 | Fcitx5 + Rime + 雾凇拼音 |
| Rime 万象及独立语法模型 | 曾使用固定快照与 SHA-256 安装模型；上游 LTS 发布资源可能覆盖旧文件，模型未随 nixpkgs 方案包提供，需要额外维护下载、快照与校验 | `pkgs.rime-ice`，方案、词库与 Lua 脚本随包提供，不再单独下载万象模型 |
| Ringboard | 有 Nix 包，但与 Noctalia 已有的剪贴板历史功能重复 | Noctalia 内置剪贴板 |
| mimalloc 全局替换 | 曾通过全局预加载试用；无法覆盖应用内置或直接调用的分配器，与 jemalloc 等混用存在分配、释放不匹配及启动崩溃风险，后已撤回 | 系统 libc 与各应用默认分配器；有明确性能需求时再针对单个应用测试 |
| LLVM libc | 无法直接全局替换当前桌面、Steam 及其依赖所需的 glibc；更换 libc 需要处理整个依赖栈的兼容性 | glibc |
| 替换 journald | 原有评估认为 journald 已满足现代日志需求，保留现成集成 | systemd-journald，限制日志容量与保留时间 |
| mdevd | 不能直接替换当前配置中桌面、硬件和服务依赖的 udev 集成 | systemd-udevd |
| 替换 systemd | 当前 NixOS 模块、登录会话与系统／用户服务依赖 systemd，无法作为单个组件直接替换 | systemd |

Rime 的 Nix store 时间戳可能导致旧编译缓存被复用；这属于已采用方案的兼容处理，现通过词库与配置指纹变化清理 `build`，保留用户词库，随后重启 Fcitx5 部署，详见桌面章节。

## 已知限制

- 显示器：`umbriel/compositor.nix` 中 `outputName` 留空，填入真实输出名后启用 4K 240Hz 与 HDR。
- JustRay：订阅报 `tcp: unsupported header type: multi` 时，改用订阅商的 sing-box JSON / Clash YAML，或尝试在链接末尾加 `?flag=sing-box`。
- WireGuard：提供工具与 NetworkManager 导入方式，连接参数待配置。
- containerd：CNI 网络未配置；gVisor 需要显式选择 `runsc` runtime。
- 主题：Helix、ONLYOFFICE、Blender、Steam、mpv 不强制切换；Codex 仅在启动时探测。
- Herdr：已启用 Kitty 图片协议，Agent 在 pane 内发图仍受上游终端识别限制。
- 《艾尔登法环》：Steam 大屏幕下姓名框无法打开，普通模式中文候选无法提交，原因待定位。
