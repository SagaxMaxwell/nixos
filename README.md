# NixOS 配置

Ryzen 7 9800X3D + Radeon RX 9070 XT；NixOS unstable、CachyOS master/latest、Home Manager、Umbriel + Noctalia。

`configuration.nix` 是入口；`desktop/` 放桌面，`system/` 放系统服务与硬件支持，`home/programs.nix` 放应用。目录均为单层。

## 安装与更新

完成分区、挂载到 `/mnt`，将仓库放到 `/mnt/etc/nixos`：

```sh
sudo nixos-generate-config --root /mnt --show-hardware-config | sudo tee /mnt/etc/nixos/hardware-configuration.nix >/dev/null
sudo nixos-install --flake path:/mnt/etc/nixos#nixos
sudo nixos-enter --root /mnt -c 'passwd maxwell'
```

首次登录前设置密码。后续在仓库内更新：

```sh
nix flake update
nix flake check path:. --show-trace
run0 nixos-rebuild switch --flake path:.#nixos
```

软件版本由 `flake.lock` 固定；`stateVersion` 是数据兼容基线。硬件配置由目标机器生成。内核跟随 `master` 的 `latest`，更新后若尚无二进制缓存会本地编译。

## 桌面

当前引用 `desktop/umbriel.nix`，使用原生 systemd 会话，Nix 字段生成 TOML。切回保留的 niri 时，只需将 `configuration.nix` 中这一行换成 `./desktop/niri.nix`。两者共用 `desktop/common.nix`，登录会话与 Portal 随桌面切换。

Noctalia 平时隐藏；鼠标在屏幕右上角停留 0.5 秒展开悬浮控制中心，点击外部或按 Esc 收起。日期、时间、网络、蓝牙、音量、通知和剪贴板集中在面板里。无常驻状态栏与托盘，应用从启动器打开。Umbriel 完整全屏时会遮住热角，避免游戏误触；可从启动器搜索控制中心。

niri / Umbriel 使用默认颜色与原生动画；窗口和组件形状沿用各自默认。Noctalia 以白色为主，浅蓝（`#629EE8`）点缀按钮和选中状态，使用原生调色板，不添加 CSS 或主题守护进程。保留毛玻璃，支持的应用背景统一为 80% 不透明，文字不做整窗淡化：

| 范围 | 效果与限制 |
| --- | --- |
| Noctalia | 面板、通知、音量／亮度提示为 80%；内层卡片由原生预设固定为 88% |
| Ghostty、Sheprd、Zed | 背景 80%＋模糊；控件、菜单及叠加区域由应用自身绘制 |
| mpv | 视频外空白区域为 80%；视频、字幕保持不透明 |
| 其余应用 | 未提供合适的 Linux 背景透明度接口，保留原状 |

Ghostty 原生跟随系统外观，07:00–22:00 为浅色，其余时间为原有深色；Noctalia 外壳始终浅色。Helix 暂无原生自动浅深主题，保留原配色，终端背景随 Ghostty；Obsidian 主题不变，Zed 保留默认主题和语法配色。Sheprd 在激活时合并外观设置，保留 GUI 的其他设置。

默认横向滚动平铺，列宽 70%，可在 50%／70%／100% 间切换；上下外边距均为 12 个逻辑像素。10 分钟闲置锁屏，11 分钟熄屏。Fcitx 5 提供美式键盘与 Rime-Ice 拼音，Shift 切换中英文。

显示器为飞利浦 32M2N8800P，待绑定输出：`mode = "3840x2160@240"`、`hdr = "on"`（桌面与应用常开）。当前仍使用显示器首选模式和聚焦窗口自动 HDR；安装后运行 `umbriel outputs`，取得接口名或完整 `Config name`，再在 `desktop/umbriel.nix` 绑定输出并移除窗口级 HDR 规则。Umbriel 当前没有输出通配符或自动最高刷新率字段，不能仅凭产品型号匹配。用 `umbriel color` 确认 HDR 实际状态。

niri 与 Umbriel 均关闭 VRR；niri 的 way-displays 保留自动选择首选分辨率下最高刷新率，Umbriel 自行管理输出。显示器菜单需开启 DDC/CI，建议通过 DisplayPort 连接。夜灯按本地时间 22:00–07:00 使用 5500K；夜灯生效时可能阻止直接扫描输出，HDR 色彩与游戏表现需实测。

默认键位保持，仅替换命令：

| 桌面 | 默认键位 | 当前调用 |
| --- | --- | --- |
| Umbriel | `Super+Enter` | Ghostty |
| niri | `Super+T` / `Super+D` / `Super+Alt+L` | Ghostty / Noctalia 启动器 / Noctalia 锁屏 |
| niri | 音量、媒体、亮度键 | Noctalia |

应用快捷键保持默认，已有重叠如下，实际触发取决于输入状态与焦点：

| 快捷键 | 重叠功能 |
| --- | --- |
| `Ctrl+Space` | Fcitx 输入法 / Zed 补全 / Strata 切换选择 |
| `Ctrl+;` | Fcitx 剪贴板 / Zed 行号或上下文菜单 |
| `Ctrl+Shift+U` | Fcitx Unicode / Zed 重做选择 |
| `Ctrl+Alt+P`、`Ctrl+Alt+H/J` | Fcitx 预编辑、拼写提示 / Zed Agent、子词删除或侧栏 |
| `F4`、`Ctrl+反引号`、`Ctrl+Shift+反引号` | Rime 菜单 / Zed 调试与终端；最后一项也用于 Sheprd |
| 仅 niri：`Super+Ctrl+Shift+方向键`、`Ctrl+Alt+Delete` | niri 移动列、退出 / Ghostty 分屏、Zed 子词删除 |

Umbriel 按 `Super` 打开启动器，`Super+O` 打开概览，`Super+R` 切换列宽，`Super+F` 全屏；Strata 与锁屏通过 Noctalia 打开。音量、媒体和亮度沿用上游的 Noctalia 默认绑定。niri 保留的 Orca 默认绑定仍无对应程序。

## 备注

- 剪贴板历史目前使用 Noctalia 内置功能，暂不配置 Ringboard。
- 提权使用 run0，`sudo` 命令由兼容入口转交 run0，常用调用可继续使用；授权仍需密码，不完全兼容 sudo 的所有选项。
- Wi-Fi 使用 NetworkManager + iwd，IP 与 DNS 继续由现有配置管理；当前 NixOS 模块仍将 iwd 后端标为实验性。
- 保留 glibc。mimalloc v3 通过 NixOS 原生字段替换宿主 Nix/glibc 动态程序的分配器，不覆盖所有程序或 Steam 隔离运行时；直接运行的 32 位程序可能出现忽略 64 位预加载库的提示，兼容性需 Linux 实测。
- Linux 下运行 `nix develop` 使用 mold 链接的 C/C++ 开发环境；已有系统软件和项目自带工具链不受此设置覆盖。
- 文件管理：Strata 通过上游 flake 安装，负责打开目录、回收站和显示文件位置；保留 NixOS 预览沙箱显卡驱动补丁。终端保留 Yazi，文件选择器使用 GTK。
- 游戏：Steam、Gamescope、GameMode、MangoHud。GameMode 不会自动作用于所有 Steam 游戏；启动选项使用 `gamemoderun %command%`，性能显示使用 `gamemoderun mangohud %command%`。
- AMD OpenCL 已启用；Blender 内选择 HIP 设备。ReBAR/SAM 需在 UEFI 开启 Above 4G Decoding 和 Re-Size BAR。
- zram-generator 是唯一 swap；使用 systemd-oomd，MetaOOM 目前没有 Nix 包。
- Podman 使用 Netavark；containerd 的 gVisor 需显式选择 `runsc`，CNI 网络尚未配置。BuildKit、Cloud Hypervisor 仅安装工具；WireGuard 通过 NetworkManager 配置，Kea 未启用。
- AI 工作台暂用 Sheprd，Vibex 目前没有 Nix 包；办公使用 ONLYOFFICE。
- 视频使用 mpv，自动选择硬件解码，常见视频格式默认用它打开；Noctalia 通过 MPRIS 控制播放，保留 mpv 默认快捷键。
- sing-box for Desktop 已配置特权后台与授权集成；首次在 GUI 导入订阅并连接，密钥不进入仓库。

`nix flake check` 检查当前桌面和 Noctalia 配置。macOS 使用 `nix flake check path:. --all-systems --no-build --show-trace` 仅做求值；登录、HDR、休眠唤醒和硬件功能需在 Linux 实测。
