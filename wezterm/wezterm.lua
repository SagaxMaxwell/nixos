local wezterm = require("wezterm")

-- Build configuration
local config = wezterm.config_builder()

-- Use a fixed color scheme
config.color_scheme = "OneHalfDark"

-- Prefer GPU rendering for better performance (macOS)
config.front_end = "WebGpu"

-- Work around GNOME Wayland window dragging issues by using XWayland.
config.enable_wayland = false

-- Disable tab bar for slightly lower overhead
config.enable_tab_bar = false

-- Return configuration
return config
