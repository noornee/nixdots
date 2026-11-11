{ ... }:
{
  imports = [
    ./scripts.nix # shell scripts for the keybinds
  ];

  wayland.windowManager.hyprland.extraConfig = /* lua */ ''
    ---------------------
    ---- KEYBINDINGS ----
    ---------------------
    local mainMod = "SUPER"
    local function bind(keys, dsp, opts) hl.bind(mainMod .. " + " .. keys, dsp, opts) end

    -- https://wiki.hypr.land/Configuring/Variables/#binds
    hl.config({
      binds = {
        workspace_back_and_forth = true,
        allow_workspace_cycles   = true,
      },
    })

    bind("BackSpace", hl.dsp.window.close())
    bind("ALT + Q",   hl.dsp.exit())

    -- toggle floating and center the window in one press
    bind("V", function()
      hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
      hl.dispatch(hl.dsp.window.center())
    end)

    bind("F", hl.dsp.window.fullscreen())                       -- fullscreen
    bind("M", hl.dsp.window.fullscreen({ mode = "maximized" })) -- monocle
    bind("P", hl.dsp.window.pin())
    bind("grave", hl.dsp.layout("togglesplit"))

    bind("Space",   hl.dsp.exec_cmd("bemenu-run"))
    bind("N",       hl.dsp.exec_cmd("swaync-client -t -sw")) -- toggle notification panel
    bind("ALT + N", hl.dsp.exec_cmd("swaync-client -d -sw")) -- toggle dnd
    bind("Return",  hl.dsp.exec_cmd("kitty"))
    bind("W",       hl.dsp.exec_cmd("neorg-note"))

    -- https://wiki.hypr.land/Configuring/Uncommon-tips--tricks/#minimize-windows-using-special-workspaces
    bind("D", hl.dsp.exec_cmd("minimize_window"))

    bind("TAB", hl.dsp.focus({ workspace = "previous" }))

    -- special workspace (scratchpad)
    bind("ALT + S", hl.dsp.window.move({ workspace = "special" }))
    bind("S",       hl.dsp.workspace.toggle_special())

    -- zoom
    bind("equal", hl.dsp.exec_cmd([[hyprctl keyword cursor:zoom_factor "$(hyprctl getoption cursor:zoom_factor | grep float | awk '{print $2 + 0.5}')"]]))
    bind("minus", hl.dsp.exec_cmd([[hyprctl keyword cursor:zoom_factor "$(hyprctl getoption cursor:zoom_factor | grep float | awk '{print $2 - 0.5}')"]]))

    -- focus / swap / resize with vim keys
    local dirs = { h = "left", l = "right", k = "up", j = "down" }
    local resize = { h = { -10, 0 }, l = { 10, 0 }, k = { 0, -10 }, j = { 0, 10 } }
    for key, dir in pairs(dirs) do
      bind(key,              hl.dsp.focus({ direction = dir }))
      bind("SHIFT + " .. key, hl.dsp.window.swap({ direction = dir }))
      bind("ALT + SHIFT + " .. key,
        hl.dsp.window.resize({ x = resize[key][1], y = resize[key][2], relative = true }),
        { repeating = true })
    end

    -- workspaces 1-10 (key 0 = workspace 10)
    for i = 1, 10 do
      local key = i % 10
      bind(key,              hl.dsp.focus({ workspace = i }))
      bind("SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
    end

    -- scroll through existing workspaces
    bind("mouse_down", hl.dsp.focus({ workspace = "e+1" }))
    bind("mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

    -- tab groups
    bind("g",         hl.dsp.group.toggle())
    bind("SHIFT + G", hl.dsp.group.lock())
    bind("CTRL + n",  hl.dsp.group.next())
    bind("CTRL + p",  hl.dsp.group.prev())
    for key, dir in pairs(dirs) do
      bind("CTRL + " .. key, hl.dsp.window.move({ into_group = dir }))
    end
    bind("CTRL + r", hl.dsp.window.move({ out_of_group = true }))

    -- mouse move / resize
    bind("mouse:272", hl.dsp.window.drag(),   { mouse = true })
    bind("mouse:273", hl.dsp.window.resize(), { mouse = true })
    bind("ALT_L",     hl.dsp.window.resize(), { mouse = true })
    bind("Escape",    hl.dsp.window.drag(),   { mouse = true })

    -- media / brightness (repeat when held, work on lock screen)
    local media = { repeating = true, locked = true }
    hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("pactl set-sink-mute 0 toggle"), { locked = true })
    hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("volume up"),       media)
    hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("volume down"),     media)
    hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightness up"),   media)
    hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightness down"), media)

    -- touchpad: 3-finger horizontal swipe switches workspaces
    hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

    -- screenshot
    hl.bind("Print", hl.dsp.exec_cmd("grimshot"))
  '';
}
