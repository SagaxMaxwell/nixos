# NixOS 配置

Ryzen 7 9800X3D + RX 9070 XT；NixOS unstable、CachyOS 内核、Umbriel + Noctalia。

`configuration.nix` 是入口：`desktop/` 桌面会话，`system/` 系统模块（`memory.nix` 管 zram 与 OOM），`home/` 用户应用。

## 约定

用户级应用、工具和 dotfiles 由 Home Manager 管理（`home-manager.users.maxwell`），优先 `programs.<name>.enable`，其次 `home.packages`。留在系统层的只有服务、驱动、内核、硬件，以及需要系统权限、udev、`/etc` 或非本用户进程的资源。

外部 flake 只通过上游模块接入，不手写包装：JustRay 用 `programs.justray.enable`（系统）与 `services.justray.enable`（用户），Umbriel 用 `programs.umbriel.settings`，Rime 词库用 `fcitx5-rime.override { rimeDataPkgs }`。桌面配置全部内联在仓库里，不读上游示例文件。

Home Manager 随 `nixos-rebuild` 生效；冲突文件备份为 `*.hm-backup`，只保留最近一份。Noctalia 的 GUI 设置可覆盖 Nix 配置，保存在 `~/.local/state/noctalia/settings.toml`。

## 部署

`hardware-configuration.nix` 已纳入仓库，按目标机器由 `nixos-generate-config` 生成；换机时重新生成并 `git add`。Btrfs 压缩写在 `system/hardware.nix`，不受该文件重新生成影响。

| 用途 | 命令 |
| --- | --- |
| 应用配置 | `nixos-rebuild switch --flake .#nixos --elevate run0` |
| 更新依赖 | `nix flake update` |
| 检查配置 | `nix flake check` |
| 完整构建，不切换 | `nixos-rebuild build --flake .#nixos` |
| 回到上一代 | `nixos-rebuild switch --rollback --no-reexec --elevate run0` |
| 在 macOS 上仅求值 | `nix flake check --all-systems --no-build` |

均在仓库目录执行，仅激活时提权。新增文件要先 `git add` 才参与构建；内核等无缓存时本地编译。回滚不改仓库，无法进入系统时在启动菜单选旧代。

## 桌面

- `Super` 启动器，`Super+Enter` Ghostty；状态栏关闭，右上角停留 0.5 秒开控制中心，`Ctrl+Space` 切换输入法与美式键盘。
- 滚动布局，窗口间距与屏幕四边均为 8px；聚焦窗口在间距内画 4px 边框，圆角 12，开窗为 zoom 动画。仅未聚焦的浮动窗口按应用装饰协商显示 Umbriel 标题栏，聚焦后隐藏；应用自绘标题栏不受影响。
- 字体用 Fontconfig 的 medium hinting 并禁用内嵌位图；高分屏 XWayland 走原生分辨率，重新登录生效，不自缩放界面的旧应用可能偏小。
- Noctalia 用 One，Umbriel 与 Ghostty 经内置模板跟随；白天浅色，18:00–06:00 深色，夜间暖色在边界前后各 30 分钟渐变。壁纸默认用当前 Noctalia 包内图片。Strata（Atelier Cave）、Herdr、Tabularis、Claude Code、Fcitx5 开启深浅联动，Qt 应用接入系统 portal；Mission Center 与 bottom 跟随终端配色。
- 背景透明度由 `flake.nix` 的 `opacity = 0.55` 统一（55% 不透明），与 Noctalia `glass` 外层一致，内部卡片 65%。数值越低越透明。
- Rime 数据更新并应用配置后重启 Fcitx5 重新部署；改输入法列表先退出图形会话，在 TTY 应用，避免旧进程回写。
- 显示器开启 DDC/CI；UEFI 开启 Above 4G Decoding 与 Re-Size BAR。
- Obsidian 笔记库：`~/Documents/notes`。

## 工具与网络

- JustRay 用上游 flake，内嵌 sing-box-lx，以用户后台服务运行，TUN 所需的 `CAP_NET_ADMIN` 由上游的 security wrapper 提供。DNS 在 TUN 内劫持处理，不修改 systemd-resolved，因此无需 polkit 规则。首次按 `a` 导入订阅、`m` 切换 TUN、`Enter` 连接；`o` 设置、`q` 退出。订阅仅导入节点，不继承旧客户端分流；默认局域网直连，其余代理。应用新系统前退出旧代理客户端。
- Chrome 启用硬件加速和平衡档省内存模式；视频硬解取决于显卡、驱动与编码格式，可在 `chrome://media-internals` 查看实际解码器。
- TCP 用 BBR + FQ；Btrfs 挂载统一 `compress=zstd:1`，仅影响后续写入，不转换文件系统或重压缩旧数据。
- SSH 支持 SFTP/SCP 与远程开发：`ssh maxwell@<主机-IP>`。
- Steam 启动选项：`gamemoderun %command%`；需性能叠加时 `gamemoderun mangohud %command%`。

## 软件与组件选择

| 软件／方案 | 取舍 | 当前方案 |
| --- | --- | --- |
| Vibex | 暂未找到可用 Nix 包 | Herdr |
| Meta oomd | 暂未找到可用 Nix 包，不自行打包 | systemd-oomd |
| [Hickory DNS](https://github.com/hickory-dns/hickory-dns/tree/main/bin) | 已有 Nix 包；与代理 TUN/DNS 联动需额外适配；完整递归仍属实验性 | NetworkManager + systemd-resolved |
| Cassotis IME | 当前锁定 nixpkgs 没有包，不自行封装 | Fcitx5 + Rime + 雾凇拼音 |
| Rime 方案 | 万象的语法模型上游发布时覆盖旧文件，nixpkgs 无法打包，需自行下载并校验 | `pkgs.rime-ice`，方案、词库与 Lua 脚本随包提供 |
| Rime 缓存 | Nix store 时间戳固定，Rime 可能复用旧编译结果 | 跟踪词库与配置，变化时清理 `build`，保留用户词库 |
| Ringboard | 已有 Nix 包；Noctalia 已提供剪贴板历史 | Noctalia 内置剪贴板 |
| mimalloc 全局替换 | 预加载无法覆盖所有分配器，混用可能崩溃 | 系统默认分配器 |
| LLVM libc | 不能替换桌面与 Steam 依赖的 glibc | glibc |
| journald / mdevd / systemd | 现有模块与服务依赖其集成 | systemd 全套 |

## 已知问题

- JustRay：URI 订阅报 `tcp: unsupported header type: multi` 时，改用订阅商的 sing-box JSON／Clash YAML，或在链接末尾加 `?flag=sing-box`。
- 《艾尔登法环》：Steam 大屏幕下姓名框无法打开；普通模式可输入英文，中文候选无法提交，原因待定位。
- 显示器：`desktop/umbriel.nix` 的 `outputName` 留空，填入实际输出名后启用 4K 240Hz 与常开 HDR。
- WireGuard：已提供 `wg`、`wg-quick` 和 NetworkManager 导入方式，连接参数待配置。
- containerd：CNI 网络未配置；gVisor 需显式选择 `runsc` runtime。
- 深浅主题：Helix、ONLYOFFICE、Blender、Steam、mpv 不强制切换；Codex 仅在启动时探测。
- Herdr 内 Agent 图片：已开 `terminal.kitty_graphics`；Claude Code／Codex 在 pane 中发图仍受上游终端识别限制。
