
--                                MONITORS
-- ██████████████████████████████████████████████████████████████████████████
-- Make sure to customize monitors! This is just my setup which I've left in so you get an idea.
-- Run `hyprctl monitors all` to see all your available monitors!

hl.monitor({ output = "DP-2", mode = "1920x1080@144.00", position = "0x250",  scale = 1 })
hl.monitor({ output = "DP-4", mode = "2560x1440@164.84", position = "1920x0", scale = 1 })


--                             DEFAULT PROGRAMS
-- ██████████████████████████████████████████████████████████████████████████
-- These are the default programs I use, do change them if you have other preferences.
local terminal    = "kitty"
local fileManager = "nemo"


-- This command calls the quickshell IPC to open the app launcher for the currently focused monitor.
-- I know it's a bit messy — I might make this cleaner eventually with built-in quickshell functionality.
local menu = "quickshell ipc call appLauncher_$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name') toggleAppLauncher"

-- Same focused-monitor dance as above: raises the sidebar and bottom bar to the
-- front, or sends them back behind the windows again.
local toggleBars = "m=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name'); quickshell ipc call sidebar_$m toggle; quickshell ipc call bottombar_$m toggle"


--                               AUTOSTART
-- ██████████████████████████████████████████████████████████████████████████

-- Hyprpaper for wallpaper, network manager applet, polkit, and also set the
-- cursor theme.
hl.on("hyprland.start", function()
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("qs")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("hyprctl setcursor Hackneyed-24px 24") -- Set cursor theme here
end)


--                          ENVIRONMENT VARIABLES
-- ██████████████████████████████████████████████████████████████████████████
hl.env("XCURSOR_SIZE",    "24")
hl.env("HYPRCURSOR_SIZE", "24")


--                                 INPUT
-- ██████████████████████████████████████████████████████████████████████████
-- Read https://wiki.hypr.land/Configuring/Variables/#input if confused!

hl.config({
    input = {
        -- Switch keyboard language layout with: alt + shift
        kb_layout  = "us,se",
        kb_options = "grp:alt_shift_toggle",

        kb_rules   = "",
        kb_variant = "",
        kb_model   = "",

        follow_mouse = 1,

        -- Range is -1.0 to 1.0 | 0 means no modification to sensitivity.
        sensitivity = 0,

        touchpad = {
            natural_scroll = false,
        },
    },

    -- This fixes a few bugs for me.
    cursor = {
        no_hardware_cursors = true,
    },
})


--                              DESIGN & STYLE
-- ██████████████████████████████████████████████████████████████████████████

-- Animations
hl.config({
    animations = {
        enabled = true,
    },
})

hl.curve("smooth", { type = "bezier", points = { {0.22, 1}, {0.36, 1} } })

hl.animation({ leaf = "workspaces", enabled = true, speed = 8, bezier = "smooth", style = "slide" })
hl.animation({ leaf = "windows",    enabled = true, speed = 3, bezier = "smooth" })
hl.animation({ leaf = "fade",       enabled = true, speed = 3, bezier = "smooth" })

-- window gaps, borders, and layout
hl.config({
    general = {
        -- Inner and outer gaps between windows.
        gaps_in  = 4,
        gaps_out = 8,

        -- I prefer a thin border.
        border_size = 1,

        -- Border colors.
        col = {
            active_border   = "rgb(1c1c1c)",
            inactive_border = "rgb(1c1c1c)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps.
        -- I prefer disabling this.
        resize_on_border = false,

        layout = "dwindle",

        -- Read https://wiki.hypr.land/Configuring/Tearing/ before turning this on!
        allow_tearing = false,
    },
})

-- shadow, blur, rounding, opacity.
hl.config({
    decoration = {
        -- 9px rounding, same as taskbar; change if wanted.
        -- Make them slightly squircle-ish with rounding power.
        rounding       = 9,
        rounding_power = 4,

        -- Transparency unchanged since we have the colored border.
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        -- Window shadow.
        shadow = {
            enabled      = true,
            range        = 12,
            render_power = 6,
            sharp        = false,
            color        = "rgba(0,0,0,0.19)",
            offset       = {0, 0},
            scale        = 1,
        },

        -- Transparent window blur.
        blur = {
            enabled           = true,
            size              = 3,
            passes            = 2,
            noise             = 0.023,
            contrast          = 0.9,
            new_optimizations = true,
        },
    },
})

-- Dwindle layout
hl.config({
    dwindle = {
        preserve_split = true,
    },
})
-- Master layout
hl.config({
    master = {
        new_status = "master",
    },
})

-- We have our own wallpapers, so disable Hyprland's defaults.
hl.config({
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
})


--                               KEYBINDS
-- ██████████████████████████████████████████████████████████████████████████
-- My personally preferred keybinds — change as needed!

local mainMod = "SUPER" -- Windows / Super key is the main modifier.

-- mod + Enter       -> start terminal
hl.bind(mainMod .. " + Return",        hl.dsp.exec_cmd(terminal))
-- mod + Q           -> kill focused application
hl.bind(mainMod .. " + Q",             hl.dsp.window.close())
-- mod + SHIFT + S   -> screenshot a region (requires hyprshot)
hl.bind(mainMod .. " + SHIFT + S",     hl.dsp.exec_cmd("hyprshot --mode region --output-folder /tmp"))
-- mod + E           -> open file manager
hl.bind(mainMod .. " + E",             hl.dsp.exec_cmd(fileManager))
-- mod + SHIFT + SPACE -> toggle focused window floating / tiled
hl.bind(mainMod .. " + SHIFT + SPACE", hl.dsp.window.float({ action = "toggle" }))
-- mod + F           -> toggle fullscreen
hl.bind(mainMod .. " + F",             hl.dsp.window.fullscreen())
-- mod + D           -> open application launcher
hl.bind(mainMod .. " + D",             hl.dsp.exec_cmd(menu))
-- mod + B           -> bring the sidebar & bottom bar to the front / send them back
hl.bind(mainMod .. " + B",             hl.dsp.exec_cmd(toggleBars))

-- Switch workspaces with mainMod + [0-9]
-- Move focused window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10  -- workspace 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Move / resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),    { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 10%+"),                         { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"),                         { locked = true, repeating = true })


--                              LAYER RULES
-- ██████████████████████████████████████████████████████████████████████████

-- Blur windows according to the linux antiquity theme
hl.layer_rule({ match = { namespace = "diinki_celestialantiquity:bars" },    blur = true, ignore_alpha = 0.19 })
hl.layer_rule({ match = { namespace = "diinki_celestialantiquity:no_blur" }, blur = true, ignore_alpha = 0.19 })
