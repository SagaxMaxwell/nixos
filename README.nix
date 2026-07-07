# date updated: 2026-07-03
#
# NixOS 配置目录
#
# 目录结构
# .
# ├── flake.nix
# ├── flake.lock
# ├── configuration.nix
# ├── hardware-configuration.nix
# ├── home.nix
# └── modules
#     ├── asus.nix
#     ├── desktop.nix
#     ├── gaming.nix
#     ├── input.nix
#     ├── mihomo.nix
#     └── nvidia.nix
#
# 顶层文件
# flake.nix
# - 仓库入口，固定 nixpkgs 和 Home Manager。
# - 定义 nixosConfigurations.${hostname}。
# - username 默认是 maxwellsagax；如果系统用户名不同，在 flake.nix 修改。
# - hostname 同时影响 nixosConfigurations 名称和 rebuild/install 命令中的 .#nixos。
# - specialArgs 传递 hostname、username、inputs 给系统模块。
# - home-manager.extraSpecialArgs 传递 Home Manager 需要的参数。
#
# configuration.nix
# - 主机入口，由 flake.nix 载入。
# - 导入 hardware-configuration.nix 和 modules/ 下的拆分模块。
# - 放基础系统项：Nix、GC、boot、SSH、ZRAM、nix-ld、系统级 shell。
# - boot.loader.systemd-boot.configurationLimit 控制 systemd-boot 菜单保留的历史启动项数量。
# - nix.gc 自动删除超过 30 天的旧 generation/store 引用。
# - 不启用写入时自动优化；定时 nix.optimise 已覆盖日常 store 去重需求。
#
# hardware-configuration.nix
# - 由 nixos-generate-config 自动生成。
# - 放在 flake.nix 同级目录。
# - 不手写，不放模板。
#
# home.nix
# - Home Manager 用户配置。
# - 优先使用 Home Manager module 管理工具。
# - 没有合适 module 的工具保留在 home.packages。
#
# 系统模块
# modules/desktop.nix
# - 图形栈、32 位图形支持、PipeWire、Flatpak、XDG portal、dconf。
# - Flatpak 需要同步启用 XDG portal，并指定 gtk portal backend。
# - PipeWire 不额外写 audio 和 WirePlumber；当前默认值会随 pulse/alsa 和 PipeWire 推导。
#
# modules/gaming.nix
# - Steam、GameMode、Gamescope、ProtonPlus、图形和游戏诊断工具。
# - Steam 使用 NixOS programs.steam module，不放在 home.nix。
# - programs.steam 会自动启用 hardware.steam-hardware，用于 Steam Controller、
#   部分手柄、HTC Vive 等硬件 udev 支持。
# - mesa-demos、vulkan-tools：基础 OpenGL/Vulkan 验证。
# - vulkan-validation-layers：Vulkan 调试层。
# - libva-utils、vdpauinfo：视频加速查询。
# - clinfo：OpenCL 查询。
#
# modules/input.nix
# - Fcitx5 中文输入法和 Wayland 前端。
# - 使用 i18n.inputMethod.enable 加 i18n.inputMethod.type。
# - 不手写 GTK_IM_MODULE、QT_IM_MODULE、XMODIFIERS；
#   NixOS 模块会按 Wayland/X11 场景生成环境变量。
#
# modules/mihomo.nix
# - Mihomo systemd service。
# - configFile 指向 /var/lib/mihomo/config.yaml，避免把订阅、节点密钥等敏感配置写进仓库。
# - tunMode 开启 systemd 所需的 TUN 能力；Mihomo 配置文件里仍需要手动启用 tun。
# - processesInfo 开启进程规则所需能力，供 process-name 等规则使用。
#
# modules/nvidia.nix
# - NVIDIA 驱动和显卡电源管理。
# - open 驱动适合 Turing 及更新架构，如 RTX 系列和 GTX 16 系列。
# - GTX 10 系列或更旧显卡需要把 open 改成 false，并选择对应 legacy 分支。
# - PRIME Offload 需要 GPU Bus ID，确认硬件后再单独添加。
# - nixpkgs.config.allowUnfree 目前放在这里；如果以后移除 NVIDIA 模块但保留 VS Code、
#   Obsidian 等 unfree 包，需要把 allowUnfree 移到更通用的位置。
#
# modules/asus.nix
# - ASUS ROG 控制中心、supergfxd、电源模式、thermald。
# - ROG 控制中心会自动启用 asusd 服务，不再重复手写 asusd 服务开关。
# - 不启用 tlp 或 auto-cpufreq，避免和 power-profiles-daemon 冲突。
# - thermald 主要适用于 Intel CPU。
#
# Home Manager 程序
# module 管理：
# - MangoHud、bat、eza、fd、fzf、jq、ripgrep、tealdeer、VS Code、Codex、Bun、Yazi。
# - Zoxide、Starship、Obsidian、uv、Nushell、WezTerm。
#
# home.packages 保留：
# - duf、ncdu、rsync、unzip、which、wl-clipboard、xh、zip、7zip、poppler-utils。
#
# 配置流程
# 1. 先按 flake.nix 建好目录结构。
# 2. 用安装器生成 hardware-configuration.nix，再放到 flake.nix 同级目录。
# 3. 在 configuration.nix 中导入硬件配置和拆分模块。
# 4. 导入 modules/desktop.nix、modules/gaming.nix、modules/input.nix 和 modules/mihomo.nix。
# 5. 如果硬件匹配，再导入 modules/nvidia.nix 和 modules/asus.nix。
# 6. 把 Mihomo 配置放到 /var/lib/mihomo/config.yaml。
# 7. 使用 Home Manager 管理用户环境。
#
# 常用命令
# nixos-generate-config --root /mnt
# nixos-install --flake .#nixos
# nix flake check
# sudo nixos-rebuild switch --flake .#nixos
# sudo nix-collect-garbage -d
# nix flake update
# home-manager switch
#
# 历史版本和启动项
# - 当前配置设置 boot.loader.systemd-boot.configurationLimit = 10，只保留最近 10 个启动项。
# - nix.gc.automatic 每周运行，当前策略删除超过 30 天的旧 generation。
# - sudo nix-collect-garbage -d 会手动删除所有旧 generation，只保留当前 generation。
# - 删除旧 generation 后再 rebuild，systemd-boot 菜单会随 bootloader entries 更新。
#
# 验证命令
# fcitx5-configtool
# glxinfo -B
# vulkaninfo --summary
# vainfo
# vdpauinfo
# clinfo

{}
