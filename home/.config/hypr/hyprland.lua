local terminal = "kitty"
local file_manager = "kitty yazi"
local menu = "kitty --class=\"launcher\" -e /usr/bin/fish ~/.config/hypr/scripts/app-launcher.fish"
local browser = "firefox"
local main_mod = "SUPER"

local colors = {
    background = "rgb(1F1F28)",
    foreground = "rgb(DCD7BA)",
    color0 = "rgb(090618)",
    color1 = "rgb(C34043)",
    color2 = "rgb(76946A)",
    color3 = "rgb(C0A36E)",
    color4 = "rgb(7E9CD8)",
    color5 = "rgb(957FB8)",
    color6 = "rgb(6A9589)",
    color7 = "rgb(C8C093)",
    color8 = "rgb(727169)",
    color9 = "rgb(E82424)",
    color10 = "rgb(98BB6C)",
    color11 = "rgb(E6C384)",
    color12 = "rgb(7FB4CA)",
    color13 = "rgb(938AA9)",
    color14 = "rgb(7AA89F)",
    color15 = "rgb(DCD7BA)",
}

local wal = io.open(os.getenv("HOME") .. "/.cache/wal/colors-hyprland.conf", "r")
if wal then
    for line in wal:lines() do
        local name, value = line:match("^%$(%S+)%s*=%s*(%S+)")
        if name and value then
            colors[name] = value
        end
    end
    wal:close()
end

local function with_alpha(color, alpha)
    local hex = color:match("rgb%((%x+)%)")
    if hex then
        return "rgba(" .. hex .. alpha .. ")"
    end
    return color
end

local function blend_colors(c1, c2, ratio, alpha)
    local h1 = c1:match("rgb%((%x+)%)")
    local h2 = c2:match("rgb%((%x+)%)")
    if not h1 or not h2 then
        return with_alpha(c1, alpha or "ff")
    end
    local r1, g1, b1 = tonumber(h1:sub(1, 2), 16), tonumber(h1:sub(3, 4), 16), tonumber(h1:sub(5, 6), 16)
    local r2, g2, b2 = tonumber(h2:sub(1, 2), 16), tonumber(h2:sub(3, 4), 16), tonumber(h2:sub(5, 6), 16)
    local r = math.floor(r1 * (1 - ratio) + r2 * ratio + 0.5)
    local g = math.floor(g1 * (1 - ratio) + g2 * ratio + 0.5)
    local b = math.floor(b1 * (1 - ratio) + b2 * ratio + 0.5)
    return string.format("rgba(%02x%02x%02x%s)", r, g, b, alpha or "ff")
end

hl.monitor({
    output = "desc:Samsung Electric Company Odyssey G95NC HNTX800635",
    -- The G9 advertises 4K as its EDID-preferred mode even when its native
    -- Dual UHD mode is available, so keep native single-source operation explicit.
    mode = "7680x2160@240",
    position = "0x0",
    scale = "1",
    bitdepth = 10,
    vrr = 0,
})

hl.config({
    render = {
        cm_enabled = true,
        non_shader_cm = 2,
    },
    debug = {
        disable_logs = false,
    },
    input = {
        kb_layout = "us,se",
        kb_variant = "",
        kb_model = "",
        kb_options = "grp:win_space_toggle",
        kb_rules = "",
        follow_mouse = 1,
        accel_profile = "flat",
        repeat_rate = 25,
        repeat_delay = 400,
        sensitivity = 0,
        touchpad = {
            natural_scroll = false,
        },
    },
    general = {
        gaps_in = 2,
        gaps_out = 2,
        border_size = 1,
        col = {
            active_border = { colors = { colors.color11, colors.color14, colors.color13 }, angle = 45 },
            inactive_border = colors.color1,
        },
        layout = "master",
        allow_tearing = false,
    },
    dwindle = {
        preserve_split = true,
        smart_split = false,
        force_split = 2,
    },
    master = {
        new_status = "inherit",
        orientation = "center",
        center_master_fallback = "right",
        mfact = 0.40,
    },
    decoration = {
        rounding = 10,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        dim_inactive = false,
        blur = {
            enabled = false,
            size = 8,
            passes = 1,
        },
        shadow = {
            enabled = false,
            offset = { 0, 0 },
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
            color_inactive = 0x50000000,
        },
    },
    animations = {
        enabled = false,
    },
    group = {
        col = {
            border_active = { colors = { colors.color11, colors.color14 }, angle = 45 },
            border_inactive = colors.color1,
        },
        groupbar = {
            font_family = "FiraCode Nerd Font Mono",
            font_size = 13,
            font_weight_active = "bold",
            font_weight_inactive = "normal",
            render_titles = true,
            stacked = false,
            height = 24,
            indicator_height = 0,
            gradients = true,
            gradient_rounding = 12,
            gradient_round_only_edges = false,
            gaps_in = 6,
            gaps_out = 4,
            text_padding = 10,
            col = {
                active = blend_colors(colors.background, colors.color4, 0.25, "e6"),
                inactive = with_alpha(colors.background, "cc"),
            },
            text_color = colors.foreground,
            text_color_inactive = colors.color8,
        },
    },
    misc = {
        force_default_wallpaper = 0,
        vrr = 3,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        initial_workspace_tracking = 0,
    },
})

hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm app -- sh -c 'out=$(xrandr --listmonitors 2>/dev/null | awk \"NR==2 {print \\$4}\"); [ -n \"$out\" ] && xrandr --output \"$out\" --primary'")
    hl.exec_cmd("uwsm app -- /usr/lib/hyprpolkitagent/hyprpolkitagent")
    hl.exec_cmd("uwsm app -- swaync")
    hl.exec_cmd("uwsm app -- wl-paste --type text --watch cliphist store")
    hl.exec_cmd("uwsm app -- wl-paste --type image --watch cliphist store")
    hl.exec_cmd("uwsm app -- steam -silent")
    hl.exec_cmd("uwsm app -- ~/.config/hypr/scripts/auto-theme.sh")
end)

local function exec(cmd)
    return hl.dsp.exec_cmd(cmd)
end

hl.bind(main_mod .. " + Q", exec("uwsm app -- " .. terminal))
hl.bind(main_mod .. " + W", exec("uwsm app -- " .. browser))
hl.bind(main_mod .. " + C", hl.dsp.window.close())
hl.bind(main_mod .. " + M", exec("uwsm stop"))
hl.bind(main_mod .. " + E", exec("uwsm app -- " .. file_manager))
hl.bind(main_mod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(main_mod .. " + R", exec("uwsm app -- " .. menu))
hl.bind("ALT + SPACE", exec("uwsm app -- " .. menu))
hl.bind(main_mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(main_mod .. " + P", hl.dsp.window.pseudo())
hl.bind(main_mod .. " + U", hl.dsp.layout("togglesplit"))
hl.bind(main_mod .. " + V", exec("uwsm app -- ~/.config/hypr/scripts/smart-paste.sh"))
hl.bind(main_mod .. " + ALT + T", hl.dsp.group.toggle())
hl.bind(main_mod .. " + ALT + G", exec("uwsm app -- ~/.config/hypr/scripts/toggle-group-titles.sh"))
hl.bind(main_mod .. " + T", exec("uwsm app -- streamlink-twitch-gui"))
hl.bind(main_mod .. " + ALT + S", exec("uwsm app -- steam"))
hl.bind(main_mod .. " + ALT + P", exec("~/.config/hypr/scripts/pip-mode-toggle.sh"))

hl.bind(main_mod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(main_mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(main_mod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(main_mod .. " + down", hl.dsp.focus({ direction = "down" }))

for i = 1, 4 do
    hl.bind(main_mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(main_mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

for i = 1, 10 do
    local key = i % 10
    hl.bind(main_mod .. " + ALT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end

hl.bind("ALT + up", hl.dsp.group.next())
hl.bind("ALT + down", hl.dsp.group.prev())

hl.bind("XF86AudioRaiseVolume", exec("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", exec("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", exec("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioNext", exec("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", exec("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", exec("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", exec("playerctl previous"), { locked = true })

hl.bind("CTRL + ALT + SHIFT + 1", exec("~/.config/hypr/scripts/scratchpad.sh"))

hl.bind(main_mod .. " + SHIFT + Q", exec("uwsm stop"))
hl.bind(main_mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(main_mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(main_mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(main_mod .. " + H", hl.dsp.window.swap({ direction = "left" }))
hl.bind(main_mod .. " + L", hl.dsp.window.swap({ direction = "right" }))
hl.bind(main_mod .. " + K", hl.dsp.window.swap({ direction = "up" }))
hl.bind(main_mod .. " + J", hl.dsp.window.swap({ direction = "down" }))

hl.bind(main_mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(main_mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(main_mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(main_mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))

hl.bind(main_mod .. " + CTRL + H", hl.dsp.window.resize({ x = -40, y = 0, relative = true }), { repeating = true })
hl.bind(main_mod .. " + CTRL + L", hl.dsp.window.resize({ x = 40, y = 0, relative = true }), { repeating = true })
hl.bind(main_mod .. " + CTRL + K", hl.dsp.window.resize({ x = 0, y = -40, relative = true }), { repeating = true })
hl.bind(main_mod .. " + CTRL + J", hl.dsp.window.resize({ x = 0, y = 40, relative = true }), { repeating = true })

hl.bind("CTRL + ALT + 1", exec("~/.config/hypr/scripts/g9-snap.sh 15"))
hl.bind("CTRL + ALT + 2", exec("~/.config/hypr/scripts/g9-snap.sh 35"))
hl.bind("CTRL + ALT + 3", exec("~/.config/hypr/scripts/g9-snap.sh 50"))
hl.bind("CTRL + ALT + 4", exec("~/.config/hypr/scripts/g9-snap.sh 65"))
hl.bind("CTRL + ALT + 5", exec("~/.config/hypr/scripts/g9-snap.sh 85"))
hl.bind("CTRL + ALT + H", exec("~/.config/hypr/scripts/g9-snap.sh 15"))
hl.bind("CTRL + ALT + L", exec("~/.config/hypr/scripts/g9-snap.sh 35"))
hl.bind("CTRL + ALT + SPACE", exec("~/.config/hypr/scripts/g9-layout.sh proportional"))
hl.bind("CTRL + ALT + SHIFT + SPACE", exec("~/.config/hypr/scripts/g9-layout.sh equal"))
hl.bind("CTRL + ALT + G", exec("~/.config/hypr/scripts/game-stream-layout.sh"))

hl.bind("SHIFT + PRINT", exec("uwsm app -- hyprshot -m window"))
hl.bind("PRINT", exec("uwsm app -- hyprshot -m output"))
hl.bind(main_mod .. " + PRINT", exec("uwsm app -- hyprshot -m region"))
hl.bind(main_mod .. " + N", exec("swaync-client -t -sw"))
hl.bind(main_mod .. " + ALT + R", function()
    hl.config({
        master = {
            mfact = 0.40,
            orientation = "center",
        },
    })
end)

hl.window_rule({
    name = "GlobalMaximizeSuppression",
    suppress_event = "maximize",
    match = { class = ".*" },
})

hl.window_rule({
    name = "StreamlinkTwitchGUI",
    group = "set",
    match = { class = "streamlink-twitch-gui" },
})

hl.window_rule({
    name = "TuiLauncher",
    float = true,
    center = true,
    size = "(monitor_w*0.15) (monitor_h*0.4)",
    match = { class = "^(launcher)$" },
})

hl.window_rule({
    name = "MPVPlayer",
    border_size = 0,
    rounding = 0,
    no_initial_focus = true,
    opaque = true,
    group = "set",
    match = { class = "mpv" },
})

hl.window_rule({
    name = "Spotify",
    group = "set",
    match = { class = "spotify" },
})

hl.window_rule({
    name = "PictureInPicture",
    group = "set",
    opaque = true,
    match = { title = "Picture-in-Picture" },
})

hl.window_rule({
    name = "SteamTinkerLaunch",
    float = true,
    match = { title = "^(SteamTinkerLaunch)" },
})

hl.window_rule({
    name = "OrcaSlicerSplash",
    stay_focused = true,
    match = { class = "^(OrcaSlicer)$", title = "^()$" },
})

hl.window_rule({
    name = "JavaFocusFix",
    no_initial_focus = true,
    match = { class = "^(java)$" },
})

hl.window_rule({
    name = "BlenderFileBrowserFix",
    float = true,
    size = "900 600",
    center = true,
    persistent_size = true,
    match = { class = "^blender$", title = "^Blender File View:$" },
})

hl.window_rule({
    name = "ScratchpadCommon",
    float = true,
    workspace = "special:scratchpad",
    match = { class = "^(scratchpad-(left|right))$" },
})

hl.window_rule({
    name = "ScratchpadLeft",
    size = "(monitor_w*0.3) (monitor_h*0.7)",
    move = "((monitor_w*0.2)) ((monitor_h*0.15))",
    match = { class = "^(scratchpad-left)$" },
})

hl.window_rule({
    name = "ScratchpadRight",
    size = "(monitor_w*0.3) (monitor_h*0.7)",
    move = "((monitor_w*0.5)) ((monitor_h*0.15))",
    match = { class = "^(scratchpad-right)$" },
})
