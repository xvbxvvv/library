--[[
================================================================================
    monolithhh.lua — Liquid Glass Edition
================================================================================
    Bibliothèque UI complète pour Roblox executors.

    Features :
        - Window (drag / resize / UIScale responsive)
        - Tabs + Sub-tabs imbriqués
        - Sections (left / right)
        - Composants : Toggle, Slider, Dropdown, Label, Colorpicker,
                       Textbox, Keybind, Button, List
        - Watermark (FPS + Ping + draggable)
        - Keybind HUD (panneau flottant)
        - Mobile FAB (bouton flottant tactile)
        - Quick settings (gear dans le header)
        - Avatar + username + badge dans le header
        - Notifications avancées (fade + progress bar)
        - Save / Load config (JSON)
        - 14 thèmes prédéfinis
        - Glassify : reflets + shadow + gradient + stroke

    Modes :
        - v1 : 650x400
        - v2 : 720x560

    Utilisation :
        local library, notifications = loadstring(...)()
        local window = library:window({ name = "menu", mode = "v2" })
        window.toggle_menu(true)
================================================================================
]]

-- ============================================================================
-- SERVICES
-- ============================================================================
local uis              = game:GetService("UserInputService")
local players          = game:GetService("Players")
local ws               = game:GetService("Workspace")
local rs               = game:GetService("ReplicatedStorage")
local http_service     = game:GetService("HttpService")
local gui_service      = game:GetService("GuiService")
local coregui          = game:GetService("CoreGui")
local tween_service    = game:GetService("TweenService")
local run_service      = game:GetService("RunService")
local stats            = game:GetService("Stats")
local teleport_service = game:GetService("TeleportService")
local lighting         = game:GetService("Lighting")
local sound_service    = game:GetService("SoundService")
local debris           = game:GetService("Debris")

-- ============================================================================
-- GLOBAL REFS
-- ============================================================================
local camera     = ws.CurrentCamera
local lp         = players.LocalPlayer
local mouse      = lp:GetMouse()
local gui_offset = gui_service:GetGuiInset().Y

-- ============================================================================
-- SHORTCUTS
-- ============================================================================
local vec2       = Vector2.new
local vec3       = Vector3.new
local dim2       = UDim2.new
local dim        = UDim.new
local rect       = Rect.new
local cfr        = CFrame.new
local dim_offset = UDim2.fromOffset

local rgb        = Color3.fromRGB
local color      = Color3.new
local hex        = Color3.fromHex
local hsv        = Color3.fromHSV
local rgbseq     = ColorSequence.new
local rgbkey     = ColorSequenceKeypoint.new
local numseq     = NumberSequence.new
local numkey     = NumberSequenceKeypoint.new

local floor      = math.floor
local ceil       = math.ceil
local min        = math.min
local max        = math.max
local abs        = math.abs
local clamp      = math.clamp
local rad        = math.rad
local sin        = math.sin
local cos        = math.cos
local random     = math.random
local noise      = math.noise

local insert     = table.insert
local find       = table.find
local remove     = table.remove
local concat     = table.concat
local sort       = table.sort

-- ============================================================================
-- THEME
-- ============================================================================
local glass_theme = {
    -- Couleurs de surfaces
    background   = rgb(18, 18, 24),
    surface      = rgb(34, 34, 44),
    surface_light= rgb(46, 46, 58),
    surface_dark = rgb(14, 14, 18),

    -- Accent
    accent       = rgb(130, 170, 255),
    accent_dim   = rgb(90, 130, 210),
    accent_glow  = rgb(180, 210, 255),

    -- Texte
    text         = rgb(240, 240, 250),
    text_dim     = rgb(172, 174, 190),
    text_muted   = rgb(112, 114, 130),

    -- Glass
    glass_top    = rgb(255, 255, 255),
    glass_bot    = rgb(0, 0, 0),
    glass_border = rgb(255, 255, 255),
    glass_inner  = rgb(255, 255, 255),

    -- Radii
    corner_radius       = 12,
    corner_radius_small = 9,
    corner_radius_tiny  = 7,

    -- Animations
    tween_speed = 0.28,
    tween_style = Enum.EasingStyle.Quint,
}

-- Thèmes prédéfinis (variantes de palette accent)
local THEME_PRESETS = {
    ["Default Blue"]   = rgb(130, 170, 255),
    ["Matcha Pink"]    = rgb(255, 60, 140),
    ["Matcha Green"]   = rgb(75, 235, 135),
    ["Mint Emerald"]   = rgb(0, 245, 175),
    ["Electric Cyan"]  = rgb(0, 215, 255),
    ["Sakura Blossom"] = rgb(255, 165, 200),
    ["Crimson Blood"]  = rgb(255, 55, 75),
    ["Cyberpunk"]      = rgb(175, 90, 255),
    ["Midnight Purple"]= rgb(145, 95, 240),
    ["Sunset Amber"]   = rgb(255, 135, 45),
    ["Pure Gold"]      = rgb(255, 205, 50),
    ["Nord Arctic"]    = rgb(135, 215, 255),
    ["Obsidian Mono"]  = rgb(226, 232, 240),
    ["Tokyo Night"]    = rgb(122, 162, 247),
    ["Dracula"]        = rgb(255, 121, 198),
}

-- ============================================================================
-- LIBRARY STATE
-- ============================================================================
getgenv().library = {
    directory    = "monolithhh",
    folders      = { "/fonts", "/configs" },
    flags        = {},
    config_flags = {},
    connections  = {},
    notifications = { notifs = {} },
    current      = nil,
    theme        = glass_theme,
    keybinds     = {},
    elements     = {},
}

-- ============================================================================
-- KEY MAP
-- ============================================================================
local keys = {
    [Enum.KeyCode.LeftShift]        = "LS",
    [Enum.KeyCode.RightShift]       = "RS",
    [Enum.KeyCode.LeftControl]      = "LC",
    [Enum.KeyCode.RightControl]     = "RC",
    [Enum.KeyCode.Insert]           = "INS",
    [Enum.KeyCode.Backspace]        = "BS",
    [Enum.KeyCode.Return]           = "Ent",
    [Enum.KeyCode.LeftAlt]          = "LA",
    [Enum.KeyCode.RightAlt]         = "RA",
    [Enum.KeyCode.CapsLock]         = "CAPS",
    [Enum.KeyCode.One]              = "1",
    [Enum.KeyCode.Two]              = "2",
    [Enum.KeyCode.Three]            = "3",
    [Enum.KeyCode.Four]             = "4",
    [Enum.KeyCode.Five]             = "5",
    [Enum.KeyCode.Six]              = "6",
    [Enum.KeyCode.Seven]            = "7",
    [Enum.KeyCode.Eight]            = "8",
    [Enum.KeyCode.Nine]             = "9",
    [Enum.KeyCode.Zero]             = "0",
    [Enum.KeyCode.Minus]            = "-",
    [Enum.KeyCode.Equals]           = "=",
    [Enum.KeyCode.LeftBracket]      = "[",
    [Enum.KeyCode.RightBracket]     = "]",
    [Enum.KeyCode.Semicolon]        = ";",
    [Enum.KeyCode.Quote]            = "'",
    [Enum.KeyCode.BackSlash]        = "\\",
    [Enum.KeyCode.Comma]            = ",",
    [Enum.KeyCode.Period]           = ".",
    [Enum.KeyCode.Slash]            = "/",
    [Enum.KeyCode.Asterisk]         = "*",
    [Enum.KeyCode.Plus]             = "+",
    [Enum.KeyCode.Backquote]        = "`",
    [Enum.KeyCode.Escape]           = "ESC",
    [Enum.KeyCode.Space]            = "SPC",
    [Enum.KeyCode.Tab]              = "TAB",
    [Enum.UserInputType.MouseButton1] = "MB1",
    [Enum.UserInputType.MouseButton2] = "MB2",
    [Enum.UserInputType.MouseButton3] = "MB3",
}

library.__index = library

-- Création des dossiers
pcall(function()
    for _, path in next, library.folders do
        if not isfolder(library.directory .. path) then
            makefolder(library.directory .. path)
        end
    end
end)

local flags        = library.flags
local config_flags = library.config_flags
local notifications = library.notifications

-- ============================================================================
-- FONT LOADING (avec fallback)
-- ============================================================================
local font_ok = pcall(function()
    local fp = library.directory .. "/fonts/main.ttf"
    local ep = library.directory .. "/fonts/main_encoded.ttf"

    if not isfile(fp) then
        writefile(fp, game:HttpGet("https://github.com/f1nobe7650/Nebula/raw/refs/heads/main/Minecraftia-Regular.ttf"))
    end

    local mf = {
        name = "Minecraftia",
        faces = {
            {
                name = "Regular",
                weight = 400,
                style = "normal",
                assetId = getcustomasset(fp),
            },
        },
    }

    if not isfile(ep) then
        writefile(ep, http_service:JSONEncode(mf))
    end

    library.font = Font.new(getcustomasset(ep), Enum.FontWeight.Regular)
end)

if not font_ok or not library.font then
    library.font = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular)
    warn("[monolithhh] custom font failed, using SourceSansPro fallback")
end

-- ============================================================================
-- CORE HELPERS
-- ============================================================================
function library:tween(obj, props, style, time)
    local t = tween_service:Create(
        obj,
        TweenInfo.new(time or glass_theme.tween_speed, style or glass_theme.tween_style, Enum.EasingDirection.InOut),
        props
    )
    t:Play()
    return t
end

function library:get_transparency(obj)
    if obj:IsA("Frame") then
        return { "BackgroundTransparency" }
    elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
        return { "TextTransparency", "BackgroundTransparency" }
    elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
        return { "BackgroundTransparency", "ImageTransparency" }
    elseif obj:IsA("ScrollingFrame") then
        return { "BackgroundTransparency", "ScrollBarImageTransparency" }
    elseif obj:IsA("TextBox") then
        return { "TextTransparency", "BackgroundTransparency" }
    elseif obj:IsA("UIStroke") then
        return { "Transparency" }
    end
    return nil
end

function library:fade(obj, prop, vis)
    if not (obj and prop) then return end
    local old = obj[prop]
    obj[prop] = vis and 1 or old
    local t = library:tween(obj, { [prop] = vis and old or 1 })
    library:connection(t.Completed, function()
        if not vis then
            task.wait()
            obj[prop] = old
        end
    end)
    return t
end

function library:create(cls, opts)
    local i = Instance.new(cls)
    for k, v in pairs(opts or {}) do
        i[k] = v
    end
    return i
end

function library:connection(sig, cb)
    local c = sig:Connect(cb)
    insert(library.connections, c)
    return c
end

function library:mouse_in_frame(u)
    local y = u.AbsolutePosition.Y <= mouse.Y and mouse.Y <= u.AbsolutePosition.Y + u.AbsoluteSize.Y
    local x = u.AbsolutePosition.X <= mouse.X and mouse.X <= u.AbsolutePosition.X + u.AbsoluteSize.X
    return y and x
end

function library:round(n, f)
    local m = 1 / (f or 1)
    return floor(n * m + 0.5) / m
end

function library:convert_enum(e)
    local parts = {}
    for p in string.gmatch(e, "[%w_]+") do
        insert(parts, p)
    end
    local t = Enum
    for i = 2, #parts do
        t = t[parts[i]]
    end
    return t
end

function library:close_current_element(cfg)
    local path = library.current
    if path and path ~= cfg and path.set_visible then
        path.set_visible(false)
        path.open = false
    end
end

function library:set_accent(c)
    glass_theme.accent = c
    glass_theme.accent_dim = color(
        math.max(0, c.R - 0.15),
        math.max(0, c.G - 0.15),
        math.max(0, c.B - 0.15)
    )
end

-- ============================================================================
-- GLASSIFY — applique reflets + shadow + gradient + stroke sur une frame
-- ============================================================================
function library:glassify(frame, radius, intensity)
    radius = radius or glass_theme.corner_radius
    intensity = intensity or 1

    frame.BorderSizePixel = 0

    -- Coins arrondis
    local ex = frame:FindFirstChildOfClass("UICorner")
    if ex then
        ex.CornerRadius = dim(0, radius)
    else
        library:create("UICorner", { Parent = frame, CornerRadius = dim(0, radius) })
    end

    -- Bord clair (stroke)
    if not frame:FindFirstChild("GlassStroke") then
        library:create("UIStroke", {
            Parent = frame,
            Name = "GlassStroke",
            Color = glass_theme.glass_border,
            Thickness = 1,
            Transparency = 0.78,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        })
    end

    -- Gradient du fond (clair haut, sombre bas)
    local g = frame:FindFirstChild("GlassGrad")
    if not g then
        g = library:create("UIGradient", { Parent = frame, Name = "GlassGrad", Rotation = 90 })
    end

    g.Color = rgbseq {
        rgbkey(0,    glass_theme.surface_light),
        rgbkey(0.5,  glass_theme.surface),
        rgbkey(1,    glass_theme.surface_dark),
    }
    g.Transparency = numseq {
        numkey(0,   0.10 * intensity),
        numkey(0.5, 0.22 * intensity),
        numkey(1,   0.42 * intensity),
    }

    -- Highlight top (fine ligne blanche)
    if not frame:FindFirstChild("GlassHighlight") then
        local h = library:create("Frame", {
            Parent = frame,
            Name = "GlassHighlight",
            BackgroundColor3 = glass_theme.glass_top,
            BackgroundTransparency = 0.80,
            BorderSizePixel = 0,
            Size = dim2(1, -2, 0, 1),
            Position = dim2(0, 1, 0, 0),
            ZIndex = frame.ZIndex + 1,
        })
        library:create("UICorner", { Parent = h, CornerRadius = dim(0, 2) })
    end

    -- Shadow bottom (fine ligne noire)
    if not frame:FindFirstChild("GlassShadow") then
        local s = library:create("Frame", {
            Parent = frame,
            Name = "GlassShadow",
            BackgroundColor3 = glass_theme.glass_bot,
            BackgroundTransparency = 0.6,
            BorderSizePixel = 0,
            Size = dim2(1, -2, 0, 1),
            Position = dim2(0, 1, 1, -1),
            ZIndex = frame.ZIndex + 1,
        })
        library:create("UICorner", { Parent = s, CornerRadius = dim(0, 2) })
    end
end

-- ============================================================================
-- DRAGGIFY — rendre une frame déplaçable
-- ============================================================================
function library:draggify(frame, handle)
    handle = handle or frame
    local dragging, start, start_pos = false, nil, frame.Position

    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            start = i.Position
            start_pos = frame.Position
        end
    end)

    handle.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    library:connection(uis.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local vx, vy = camera.ViewportSize.X, camera.ViewportSize.Y
            frame.Position = dim2(
                0, clamp(start_pos.X.Offset + (i.Position.X - start.X), 0, vx - frame.Size.X.Offset),
                0, clamp(start_pos.Y.Offset + (i.Position.Y - start.Y), 0, vy - frame.Size.Y.Offset)
            )
            library:close_current_element(nil)
        end
    end)
end

-- ============================================================================
-- RESIZIFY — poignée de resize en bas-droite
-- ============================================================================
function library:resizify(frame)
    local grip = library:create("TextButton", {
        Parent = frame,
        Name = "ResizeGrip",
        Position = dim2(1, -12, 1, -12),
        Size = dim2(0, 12, 0, 12),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 100,
    })

    local rz, start_size, start, og = false, nil, nil, frame.Size

    grip.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            rz = true
            start = i.Position
            start_size = frame.Size
        end
    end)

    grip.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            rz = false
        end
    end)

    library:connection(uis.InputChanged, function(i)
        if rz and i.UserInputType == Enum.UserInputType.MouseMovement then
            frame.Size = dim2(
                start_size.X.Scale,
                clamp(start_size.X.Offset + (i.Position.X - start.X), og.X.Offset, camera.ViewportSize.X),
                start_size.Y.Scale,
                clamp(start_size.Y.Offset + (i.Position.Y - start.Y), og.Y.Offset, camera.ViewportSize.Y)
            )
        end
    end)
end

-- ============================================================================
-- WATERMARK — FPS + Ping + draggable
-- ============================================================================
function library:create_watermark(parent_screen, config)
    config = config or {}
    local name = config.name or "monolithhh"
    local logo = config.logo or "rbxassetid://128155293790451"

    local wm = library:create("Frame", {
        Parent = parent_screen,
        Name = "Watermark",
        Size = dim2(0, 260, 0, 22),
        Position = dim2(0, 16, 0, 16),
        BackgroundColor3 = glass_theme.surface_dark,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        ZIndex = 999,
    })
    library:glassify(wm, 6, 1.2)

    library:create("ImageLabel", {
        Parent = wm,
        Image = logo,
        BackgroundTransparency = 1,
        Position = dim2(0, 5, 0.5, -8),
        Size = dim2(0, 16, 0, 16),
    })

    library:create("TextLabel", {
        Parent = wm,
        Name = "Title",
        FontFace = library.font,
        TextColor3 = glass_theme.text,
        Text = string.upper(name),
        BackgroundTransparency = 1,
        Position = dim2(0, 26, 0, 0),
        Size = dim2(0, 90, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 10,
    })

    library:create("TextLabel", {
        Parent = wm,
        Text = "|",
        FontFace = library.font,
        TextColor3 = glass_theme.text_muted,
        BackgroundTransparency = 1,
        Position = dim2(0, 116, 0, 0),
        Size = dim2(0, 8, 1, 0),
        TextSize = 10,
    })

    local fps_lbl = library:create("TextLabel", {
        Parent = wm,
        Name = "FPS",
        FontFace = library.font,
        TextColor3 = glass_theme.text,
        Text = "0 FPS",
        BackgroundTransparency = 1,
        Position = dim2(0, 128, 0, 0),
        Size = dim2(0, 50, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 10,
    })

    library:create("TextLabel", {
        Parent = wm,
        Text = "|",
        FontFace = library.font,
        TextColor3 = glass_theme.text_muted,
        BackgroundTransparency = 1,
        Position = dim2(0, 180, 0, 0),
        Size = dim2(0, 8, 1, 0),
        TextSize = 10,
    })

    local ping_lbl = library:create("TextLabel", {
        Parent = wm,
        Name = "Ping",
        FontFace = library.font,
        TextColor3 = glass_theme.text,
        Text = "0ms",
        BackgroundTransparency = 1,
        Position = dim2(0, 192, 0, 0),
        Size = dim2(0, 40, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 10,
    })

    library:draggify(wm)

    task.spawn(function()
        local frame_count, last_time, fps = 0, tick(), 60
        library:connection(run_service.RenderStepped, function()
            frame_count = frame_count + 1
            local now = tick()
            if now - last_time >= 1 then
                fps = floor(frame_count / (now - last_time))
                frame_count, last_time = 0, now
            end
        end)
        while wm.Parent do
            local ping = 0
            pcall(function()
                ping = floor(stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            fps_lbl.Text = fps .. " FPS"
            ping_lbl.Text = ping .. "ms"
            task.wait(0.5)
        end
    end)

    return wm
end

-- ============================================================================
-- KEYBIND HUD — panneau flottant listant les binds actifs
-- ============================================================================
function library:create_keybind_hud(parent_screen)
    local hud = library:create("Frame", {
        Parent = parent_screen,
        Name = "KeybindHUD",
        Size = dim2(0, 180, 0, 0),
        Position = dim2(0, 20, 0, 60),
        BackgroundColor3 = glass_theme.surface_dark,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Visible = false,
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    library:glassify(hud, glass_theme.corner_radius_small, 1.2)

    local header = library:create("Frame", {
        Parent = hud,
        Name = "Header",
        Size = dim2(1, 0, 0, 24),
        BackgroundTransparency = 1,
    })

    local dot = library:create("Frame", {
        Parent = header,
        Size = dim2(0, 6, 0, 6),
        Position = dim2(0, 10, 0.5, -3),
        BackgroundColor3 = glass_theme.accent,
        BorderSizePixel = 0,
    })
    library:create("UICorner", { Parent = dot, CornerRadius = dim(1, 0) })

    library:create("TextLabel", {
        Parent = header,
        Text = "KEYBINDS",
        FontFace = library.font,
        TextColor3 = glass_theme.text,
        BackgroundTransparency = 1,
        Position = dim2(0, 22, 0, 0),
        Size = dim2(1, -30, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 10,
    })

    local list = library:create("Frame", {
        Parent = hud,
        Name = "List",
        Size = dim2(1, -16, 0, 0),
        Position = dim2(0, 8, 0, 26),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    library:create("UIListLayout", {
        Parent = list,
        Padding = dim(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    library:draggify(hud, header)

    function library:refresh_keybind_hud()
        for _, c in ipairs(list:GetChildren()) do
            if c:IsA("Frame") then
                c:Destroy()
            end
        end

        for flag_name, kb in pairs(library.keybinds) do
            if kb.key then
                local row = library:create("Frame", {
                    Parent = list,
                    Size = dim2(1, 0, 0, 14),
                    BackgroundTransparency = 1,
                })

                local key_txt = keys[kb.key] or (typeof(kb.key) == "EnumItem" and kb.key.Name) or "?"

                library:create("TextLabel", {
                    Parent = row,
                    FontFace = library.font,
                    TextColor3 = glass_theme.accent,
                    Text = "[ " .. key_txt .. " ]",
                    BackgroundTransparency = 1,
                    Size = dim2(0.4, 0, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextSize = 10,
                })

                library:create("TextLabel", {
                    Parent = row,
                    FontFace = library.font,
                    TextColor3 = glass_theme.text_dim,
                    Text = kb.name or flag_name,
                    BackgroundTransparency = 1,
                    Position = dim2(0.4, 0, 0, 0),
                    Size = dim2(0.6, 0, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextSize = 10,
                })
            end
        end
    end

    return hud
end

-- ============================================================================
-- MOBILE FAB — bouton rond flottant draggable
-- ============================================================================
function library:create_mobile_fab(parent_screen, on_click)
    local fab = library:create("TextButton", {
        Parent = parent_screen,
        Name = "MobileFAB",
        Size = dim2(0, 44, 0, 44),
        Position = dim2(1, -60, 0.5, -22),
        BackgroundColor3 = glass_theme.surface_dark,
        BackgroundTransparency = 0.1,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 9999,
        Visible = uis.TouchEnabled,
    })
    library:glassify(fab, 22, 1.3)

    library:create("TextLabel", {
        Parent = fab,
        Text = "M",
        FontFace = library.font,
        TextColor3 = glass_theme.accent,
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 1, 0),
        TextSize = 20,
    })

    local dragging, start, start_pos = false, nil, fab.Position

    fab.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            start = i.Position
            start_pos = fab.Position
        end
    end)

    uis.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            fab.Position = dim2(
                0, start_pos.X.Offset + (i.Position.X - start.X),
                0, start_pos.Y.Offset + (i.Position.Y - start.Y)
            )
        end
    end)

    uis.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            if dragging and (i.Position - start).Magnitude < 5 then
                on_click()
            end
            dragging = false
        end
    end)

    return fab
end

-- ============================================================================
-- NOTIFICATIONS
-- ============================================================================
local notif = library.notifications

function notif:refresh()
    local y = 20
    for _, v in pairs(notif.notifs) do
        if v and v.Parent then
            tween_service:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
                Position = dim_offset(20, y),
            }):Play()
            y = y + v.AbsoluteSize.Y + 8
        end
    end
end

function notif:create(options)
    options = options or {}
    local title    = options.name or options.title or "Notification"
    local content  = options.content or ""
    local c        = options.color or glass_theme.accent
    local duration = options.duration or 4

    if not library.items then return end

    local card = library:create("TextButton", {
        Parent = library.items,
        Name = "Notification",
        Size = dim2(0, 260, 0, 0),
        BackgroundColor3 = glass_theme.surface_dark,
        BackgroundTransparency = 0.15,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })
    library:glassify(card, glass_theme.corner_radius_small, 1.2)

    library:create("Frame", {
        Parent = card,
        Name = "AccentBar",
        Size = dim2(0, 3, 1, -8),
        Position = dim2(0, 4, 0, 4),
        BackgroundColor3 = c,
        BorderSizePixel = 0,
    })

    library:create("TextLabel", {
        Parent = card,
        Name = "Title",
        FontFace = library.font,
        TextColor3 = glass_theme.text,
        Text = title,
        BackgroundTransparency = 1,
        Position = dim2(0, 14, 0, 6),
        Size = dim2(1, -20, 0, 14),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 10,
    })

    if content ~= "" then
        library:create("TextLabel", {
            Parent = card,
            Name = "Content",
            FontFace = library.font,
            TextColor3 = glass_theme.text_dim,
            Text = content,
            BackgroundTransparency = 1,
            TextWrapped = true,
            Position = dim2(0, 14, 0, 22),
            Size = dim2(1, -20, 0, 28),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextSize = 10,
        })
    end

    local prog = library:create("Frame", {
        Parent = card,
        Name = "Progress",
        Size = dim2(1, 0, 0, 2),
        Position = dim2(0, 0, 1, -2),
        BackgroundColor3 = c,
        BorderSizePixel = 0,
    })

    local target_h = (content ~= "") and 60 or 30
    tween_service:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Size = dim2(0, 260, 0, target_h),
    }):Play()
    tween_service:Create(prog, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = dim2(0, 0, 0, 2),
    }):Play()

    local i = #notif.notifs + 1
    notif.notifs[i] = card
    notif:refresh()

    task.delay(duration, function()
        notif.notifs[i] = nil
        if card and card.Parent then
            local t = tween_service:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                Size = dim2(0, 260, 0, 0),
                BackgroundTransparency = 1,
            })
            t:Play()
            t.Completed:Connect(function()
                card:Destroy()
                notif:refresh()
            end)
        end
    end)
end

-- ============================================================================
-- WINDOW
-- ============================================================================
local SIZE_MODES = {
    v1 = { width = 650, height = 400 },
    v2 = { width = 720, height = 560 },
}

function library:window(properties)
    properties = properties or {}
    local mode = properties.mode or properties.Mode or "v1"
    local size_cfg = SIZE_MODES[mode] or SIZE_MODES.v1
    local user_name = (lp and lp.DisplayName) or "User"
    local handle = "@" .. ((lp and lp.Name) or "user")

    local cfg = {
        name = properties.name or properties.Name or "monolithhh",
        size = properties.size or properties.Size or dim2(0, size_cfg.width, 0, size_cfg.height),
        logo = properties.logo or properties.Logo or "rbxassetid://128155293790451",
        badge = properties.badge or properties.Badge or "",
        mode = mode,
        selected_tab = nil,
        items = {},
        tweening = false,
    }

    -- ScreenGui principal
    library.items = library:create("ScreenGui", {
        Parent = coregui,
        Name = "\0",
        Enabled = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })

    library.other = library:create("ScreenGui", {
        Parent = coregui,
        Name = "\0",
        Enabled = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })

    local items = cfg.items

    -- ========================================================================
    -- WINDOW FRAME
    -- ========================================================================
    items.window = library:create("Frame", {
        Parent = library.items,
        Name = "MainWindow",
        Visible = false,
        Position = dim2(0.5, -cfg.size.X.Offset / 2, 0.5, -cfg.size.Y.Offset / 2),
        Size = cfg.size,
        BackgroundColor3 = glass_theme.surface,
        BorderSizePixel = 0,
    })
    library:glassify(items.window, glass_theme.corner_radius, 1.4)

    -- UIScale pour responsive
    items.uiscale = library:create("UIScale", { Parent = items.window, Scale = 1 })

    local function auto_fit()
        local vp = camera.ViewportSize
        local sx = (vp.X - 20) / cfg.size.X.Offset
        local sy = (vp.Y - 20) / cfg.size.Y.Offset
        items.uiscale.Scale = clamp(math.min(sx, sy, 1), 0.5, 1)
        items.window.Position = dim2(0.5, -cfg.size.X.Offset / 2, 0.5, -cfg.size.Y.Offset / 2)
    end
    auto_fit()
    camera:GetPropertyChangedSignal("ViewportSize"):Connect(auto_fit)

    -- ========================================================================
    -- HEADER / TOP BAR
    -- ========================================================================
    items.top_frame = library:create("Frame", {
        Parent = items.window,
        Name = "TopBar",
        Size = dim2(1, 0, 0, 45),
        Position = dim2(0, 0, 0, 0),
        BackgroundColor3 = glass_theme.surface_light,
        BorderSizePixel = 0,
    })
    library:glassify(items.top_frame, glass_theme.corner_radius, 0.9)

    items.logo = library:create("ImageLabel", {
        Parent = items.top_frame,
        Name = "Logo",
        Image = cfg.logo,
        BackgroundTransparency = 1,
        Position = dim2(0, 12, 0, 7),
        Size = dim2(0, 32, 0, 32),
    })

    items.ui_title = library:create("TextLabel", {
        Parent = items.top_frame,
        Name = "Title",
        FontFace = library.font,
        TextColor3 = glass_theme.text,
        Text = cfg.name,
        BackgroundTransparency = 1,
        Position = dim2(0, 52, 0, 0),
        Size = dim2(0, 150, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 22,
    })

    -- Badge optionnel
    if cfg.badge ~= "" then
        local bg = library:create("Frame", {
            Parent = items.top_frame,
            Name = "Badge",
            Size = dim2(0, 40, 0, 14),
            Position = dim2(0, 52 + 90, 0.5, -7),
            BackgroundColor3 = glass_theme.accent,
            BackgroundTransparency = 0.85,
            BorderSizePixel = 0,
        })
        library:create("UICorner", { Parent = bg, CornerRadius = dim(0, 4) })

        library:create("TextLabel", {
            Parent = bg,
            Text = cfg.badge,
            FontFace = library.font,
            TextColor3 = glass_theme.accent,
            BackgroundTransparency = 1,
            Size = dim2(1, 0, 1, 0),
            TextSize = 9,
        })
    end

    -- User profile area (right)
    items.user_frame = library:create("Frame", {
        Parent = items.top_frame,
        Name = "UserArea",
        Size = dim2(0, 200, 1, 0),
        Position = dim2(1, -215, 0, 0),
        BackgroundTransparency = 1,
    })

    items.avatar = library:create("ImageLabel", {
        Parent = items.user_frame,
        Name = "Avatar",
        Size = dim2(0, 26, 0, 26),
        Position = dim2(1, -30, 0.5, -13),
        BackgroundColor3 = glass_theme.surface_dark,
        BackgroundTransparency = 0.1,
        Image = "rbxassetid://0",
        BorderSizePixel = 0,
    })
    library:create("UICorner", { Parent = items.avatar, CornerRadius = dim(1, 0) })
    library:create("UIStroke", {
        Parent = items.avatar,
        Color = glass_theme.accent,
        Transparency = 0.4,
        Thickness = 1,
    })

    items.display = library:create("TextLabel", {
        Parent = items.user_frame,
        Name = "DisplayName",
        FontFace = library.font,
        TextColor3 = glass_theme.text,
        Text = user_name,
        BackgroundTransparency = 1,
        Position = dim2(1, -180, 0, 4),
        Size = dim2(0, 145, 0, 13),
        TextXAlignment = Enum.TextXAlignment.Right,
        TextSize = 10,
    })

    items.handle = library:create("TextLabel", {
        Parent = items.user_frame,
        Name = "Username",
        FontFace = library.font,
        TextColor3 = glass_theme.text_dim,
        Text = handle,
        BackgroundTransparency = 1,
        Position = dim2(1, -180, 0, 18),
        Size = dim2(0, 145, 0, 11),
        TextXAlignment = Enum.TextXAlignment.Right,
        TextSize = 9,
    })

    -- Charger avatar async
    task.spawn(function()
        pcall(function()
            if lp and lp.UserId and lp.UserId > 0 then
                local content = players:GetUserThumbnailAsync(
                    lp.UserId,
                    Enum.ThumbnailType.HeadShot,
                    Enum.ThumbnailSize.Size48x48
                )
                if content then
                    items.avatar.Image = content
                end
            end
        end)
    end)

    -- Gear button
    items.gear = library:create("TextButton", {
        Parent = items.top_frame,
        Name = "GearBtn",
        Size = dim2(0, 22, 0, 22),
        Position = dim2(1, -60, 0.5, -11),
        BackgroundColor3 = glass_theme.surface,
        BackgroundTransparency = 0.3,
        Text = "⚙",
        Font = Enum.Font.GothamBold,
        TextColor3 = glass_theme.text_dim,
        TextSize = 13,
        AutoButtonColor = false,
        BorderSizePixel = 0,
    })
    library:glassify(items.gear, 5, 0.7)

    -- ========================================================================
    -- SIDEBAR / TABS
    -- ========================================================================
    items.inline = library:create("Frame", {
        Parent = items.window,
        Name = "Sidebar",
        Position = dim2(0, 0, 0, 44),
        Size = dim2(0, 63, 1, -44),
        BackgroundColor3 = glass_theme.background,
        BorderSizePixel = 0,
    })
    library:glassify(items.inline, glass_theme.corner_radius, 0.7)

    items.tab_button_holder = library:create("Frame", {
        Parent = items.inline,
        Name = "TabHolder",
        Position = dim2(0, 1, 0, 1),
        Size = dim2(1, -2, 1, -2),
        BackgroundColor3 = glass_theme.background,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
    })
    library:create("UICorner", {
        Parent = items.tab_button_holder,
        CornerRadius = dim(0, glass_theme.corner_radius),
    })
    library:create("UIPadding", {
        Parent = items.tab_button_holder,
        PaddingTop = dim(0, 37),
    })
    library:create("UIListLayout", {
        Parent = items.tab_button_holder,
        Padding = dim(0, 24),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    -- ========================================================================
    -- PAGE HOLDER
    -- ========================================================================
    items.page_holder = library:create("Frame", {
        Parent = items.window,
        Name = "PageHolder",
        Position = dim2(0, 63, 0, 45),
        Size = dim2(1, -63, 1, -45),
        BackgroundColor3 = glass_theme.surface_dark,
        BorderSizePixel = 0,
    })
    library:glassify(items.page_holder, glass_theme.corner_radius, 0.8)

    library:draggify(items.window)
    library:resizify(items.window)

    -- ========================================================================
    -- QUICK SETTINGS POPUP
    -- ========================================================================
    local popup = library:create("Frame", {
        Parent = items.window,
        Name = "QuickSettings",
        Size = dim2(0, 200, 0, 0),
        Position = dim2(1, -210, 0, 48),
        BackgroundColor3 = glass_theme.surface_dark,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 500,
    })
    library:glassify(popup, glass_theme.corner_radius_small, 1.3)

    local qp = library:create("Frame", {
        Parent = popup,
        Size = dim2(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 501,
    })
    library:create("UIListLayout", {
        Parent = qp,
        Padding = dim(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    library:create("UIPadding", {
        Parent = qp,
        PaddingTop = dim(0, 8),
        PaddingBottom = dim(0, 8),
        PaddingLeft = dim(0, 10),
        PaddingRight = dim(0, 10),
    })

    library:create("TextLabel", {
        Parent = qp,
        Text = "QUICK HUD SETTINGS",
        FontFace = library.font,
        TextColor3 = glass_theme.text_muted,
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 0, 14),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 9,
        ZIndex = 502,
    })

    local function quick_row(label, default, cb)
        local row = library:create("Frame", {
            Parent = qp,
            Size = dim2(1, 0, 0, 20),
            BackgroundTransparency = 1,
            ZIndex = 502,
        })

        library:create("TextLabel", {
            Parent = row,
            Text = label,
            FontFace = library.font,
            TextColor3 = glass_theme.text,
            BackgroundTransparency = 1,
            Size = dim2(1, -40, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 10,
            ZIndex = 502,
        })

        local sw = library:create("TextButton", {
            Parent = row,
            Size = dim2(0, 32, 0, 16),
            Position = dim2(1, -32, 0.5, -8),
            BackgroundColor3 = default and glass_theme.accent or glass_theme.surface_dark,
            Text = "",
            AutoButtonColor = false,
            BorderSizePixel = 0,
            ZIndex = 502,
        })
        library:create("UICorner", { Parent = sw, CornerRadius = dim(1, 0) })

        local dot = library:create("Frame", {
            Parent = sw,
            Size = dim2(0, 12, 0, 12),
            Position = default and dim2(1, -14, 0.5, -6) or dim2(0, 2, 0.5, -6),
            BackgroundColor3 = color(1, 1, 1),
            BorderSizePixel = 0,
            ZIndex = 503,
        })
        library:create("UICorner", { Parent = dot, CornerRadius = dim(1, 0) })

        local state = default
        sw.MouseButton1Click:Connect(function()
            state = not state
            library:tween(sw, { BackgroundColor3 = state and glass_theme.accent or glass_theme.surface_dark }, nil, 0.15)
            library:tween(dot, { Position = state and dim2(1, -14, 0.5, -6) or dim2(0, 2, 0.5, -6) }, nil, 0.15)
            cb(state)
        end)
    end

    -- Création des HUD
    items.watermark    = library:create_watermark(library.items, { name = cfg.name, logo = cfg.logo })
    items.keybind_hud  = library:create_keybind_hud(library.items)
    items.mobile_fab   = library:create_mobile_fab(library.items, function()
        cfg.toggle_menu(not items.window.Visible)
    end)

    quick_row("Watermark HUD", true, function(state) items.watermark.Visible = state end)
    quick_row("Keybinds HUD", false, function(state) items.keybind_hud.Visible = state end)
    if uis.TouchEnabled then
        quick_row("Mobile Button", true, function(state) items.mobile_fab.Visible = state end)
    end

    -- Toggle du popup
    local popup_open = false
    items.gear.MouseButton1Click:Connect(function()
        popup_open = not popup_open
        if popup_open then
            popup.Visible = true
            tween_service:Create(popup, TweenInfo.new(0.22, Enum.EasingStyle.Quart), {
                Size = dim2(0, 200, 0, 20 + 26 * #qp:GetChildren()),
            }):Play()
            library:tween(items.gear, { TextColor3 = glass_theme.accent }, nil, 0.15)
        else
            local t = tween_service:Create(popup, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {
                Size = dim2(0, 200, 0, 0),
            })
            t:Play()
            t.Completed:Connect(function()
                if not popup_open then popup.Visible = false end
            end)
            library:tween(items.gear, { TextColor3 = glass_theme.text_dim }, nil, 0.15)
        end
    end)

    -- ========================================================================
    -- TOGGLE MENU (fade in/out)
    -- ========================================================================
    function cfg.toggle_menu(bool)
        if cfg.tweening then return end
        cfg.tweening = true

        if bool then
            items.window.Visible = true
        end

        local children = items.window:GetDescendants()
        insert(children, items.window)

        local last
        for _, obj in ipairs(children) do
            local idx = library:get_transparency(obj)
            if idx then
                if type(idx) == "table" then
                    for _, p in ipairs(idx) do
                        last = library:fade(obj, p, bool)
                    end
                else
                    last = library:fade(obj, idx, bool)
                end
            end
        end

        if last then
            library:connection(last.Completed, function()
                cfg.tweening = false
                items.window.Visible = bool
            end)
        else
            cfg.tweening = false
            items.window.Visible = bool
        end
    end

    return setmetatable(cfg, library)
end

-- ============================================================================
-- TAB (avec SubTab imbriqué)
-- ============================================================================
function library:Tab(properties)
    properties = properties or {}
    local cfg = {
        name = properties.name or properties.Name or "Tab",
        icon = properties.icon or properties.Icon or "http://www.roblox.com/asset/?id=6034767608",
        items = {},
        subtabs = {},
        active_subtab = nil,
    }

    local items = cfg.items

    -- Bouton sidebar
    items.tab_button = library:create("TextButton", {
        Parent = self.items.tab_button_holder,
        BackgroundTransparency = 1,
        Text = "",
        Size = dim2(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BorderSizePixel = 0,
    })

    items.image = library:create("ImageLabel", {
        ImageColor3 = glass_theme.text_dim,
        Parent = items.tab_button,
        Size = dim2(0, 32, 0, 32),
        AnchorPoint = vec2(0.5, 0),
        Image = cfg.icon,
        BackgroundTransparency = 1,
        Position = dim2(0.5, 0, 0, 0),
    })

    -- Page du tab
    items.tab = library:create("Frame", {
        Parent = library.items,
        BackgroundTransparency = 1,
        Visible = false,
        Size = dim2(1, 0, 1, 0),
        BorderSizePixel = 0,
    })

    -- Barre de sub-tabs
    items.subtab_bar = library:create("Frame", {
        Parent = items.tab,
        Name = "SubTabBar",
        Size = dim2(1, -24, 0, 26),
        Position = dim2(0, 12, 0, 10),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
    })
    library:create("UIListLayout", {
        Parent = items.subtab_bar,
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = dim(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    })

    -- Séparateur sous la barre
    items.subtab_sep = library:create("Frame", {
        Parent = items.tab,
        Name = "SubTabSep",
        Size = dim2(1, -24, 0, 1),
        Position = dim2(0, 12, 0, 42),
        BackgroundColor3 = glass_theme.glass_border,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        Visible = false,
    })

    -- Holder pour les sub-tabs
    items.subtab_holder = library:create("Frame", {
        Parent = items.tab,
        Name = "SubTabHolder",
        Size = dim2(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    })

    -- ========================================================================
    -- SUB-TAB FACTORY
    -- ========================================================================
    function cfg:SubTab(name)
        local st = {
            name = name,
            items = {},
            parent_tab = cfg,
        }

        local st_frame = library:create("Frame", {
            Parent = items.subtab_holder,
            Name = "Sub_" .. name,
            Size = dim2(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = false,
        })

        library:create("UIListLayout", {
            Parent = st_frame,
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = dim(0, 16),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalFlex = Enum.UIFlexAlignment.Fill,
        })

        library:create("UIPadding", {
            Parent = st_frame,
            PaddingTop = dim(0, 50),
            PaddingBottom = dim(0, 16),
            PaddingLeft = dim(0, 16),
            PaddingRight = dim(0, 16),
        })

        local left = library:create("Frame", {
            Parent = st_frame,
            Name = "Left",
            BackgroundTransparency = 1,
            Size = dim2(0, 100, 0, 100),
        })

        local right = library:create("Frame", {
            Parent = st_frame,
            Name = "Right",
            BackgroundTransparency = 1,
            Size = dim2(0, 100, 0, 100),
        })

        st.items.left = left
        st.items.right = right
        st.items.frame = st_frame
        st.frame = st_frame

        setmetatable(st, library)

        -- Bouton de subtab dans la barre
        local btn = library:create("TextButton", {
            Parent = items.subtab_bar,
            Name = "Btn_" .. name,
            Size = dim2(0, 0, 0, 20),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = glass_theme.surface,
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0,
            Text = name,
            TextColor3 = glass_theme.text_dim,
            Font = library.font,
            TextSize = 12,
            AutoButtonColor = false,
        })
        library:create("UICorner", { Parent = btn, CornerRadius = dim(0, 6) })
        library:create("UIPadding", {
            Parent = btn,
            PaddingLeft = dim(0, 10),
            PaddingRight = dim(0, 10),
        })
        st.button = btn

        insert(cfg.subtabs, st)

        btn.MouseButton1Click:Connect(function()
            cfg:SetActiveSubTab(name)
        end)

        if #cfg.subtabs == 1 then
            cfg:SetActiveSubTab(name)
        end
        if #cfg.subtabs > 1 then
            items.subtab_bar.Visible = true
            items.subtab_sep.Visible = true
        end

        return st
    end

    function cfg:SetActiveSubTab(name)
        cfg.active_subtab = name
        for _, st in ipairs(cfg.subtabs) do
            local active = (st.name == name)
            st.frame.Visible = active
            if st.button then
                library:tween(st.button, {
                    BackgroundTransparency = active and 0 or 0.5,
                    TextColor3 = active and glass_theme.text or glass_theme.text_dim,
                }, nil, 0.15)
            end
            if active then
                items.left = st.items.left
                items.right = st.items.right
            end
        end
    end

    -- Sub-tab par défaut
    cfg:SubTab("Main")

    function cfg.open_tab()
        local sel = self.selected_tab
        if sel then
            sel[1].ImageColor3 = glass_theme.text_dim
            sel[2].Parent = library.items
            sel[2].Visible = false
        end
        items.image.ImageColor3 = glass_theme.text
        items.tab.Parent = self.items.page_holder
        items.tab.Visible = true
        self.selected_tab = { items.image, items.tab }
        library:close_current_element(nil)
    end

    items.tab_button.MouseButton1Down:Connect(function()
        cfg.open_tab()
    end)

    if not self.selected_tab then
        cfg.open_tab(true)
    end

    return setmetatable(cfg, library)
end

-- ============================================================================
-- SECTION
-- ============================================================================
function library:Section(properties)
    properties = properties or {}
    local cfg = {
        name = properties.name or properties.Name or "section",
        side = properties.side or properties.Side or "left",
        default = properties.default or properties.Default or false,
        size = properties.size or properties.Size or 0.5,
        items = {},
    }

    local parent = self.items[cfg.side]
    if not parent then
        parent = self.items.left or self.items.right
    end

    local items = cfg.items

    items.section_outline = library:create("Frame", {
        Parent = parent,
        Name = "Section",
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 1, 0),
        BorderSizePixel = 0,
    })

    items.section_shadow = library:create("Frame", {
        Parent = items.section_outline,
        Name = "Glass",
        Position = dim2(0, 1, 0, 1),
        Size = dim2(1, -2, 1, -2),
        BackgroundColor3 = glass_theme.surface,
        BorderSizePixel = 0,
    })
    library:glassify(items.section_shadow, glass_theme.corner_radius, 1.0)

    items.scrolling = library:create("ScrollingFrame", {
        Parent = items.section_shadow,
        Name = "Scroll",
        ScrollBarImageColor3 = glass_theme.accent,
        Active = true,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2,
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 1, 0),
        CanvasSize = dim2(0, 0, 0, 0),
        BorderSizePixel = 0,
    })

    items.elements = library:create("Frame", {
        Parent = items.scrolling,
        Name = "Elements",
        BackgroundTransparency = 1,
        Position = dim2(0, 12, 0, 12),
        Size = dim2(1, -24, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BorderSizePixel = 0,
    })
    library:create("UIListLayout", {
        Parent = items.elements,
        Padding = dim(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    items.text = library:create("TextLabel", {
        FontFace = library.font,
        TextColor3 = glass_theme.text_dim,
        Text = cfg.name,
        Parent = items.section_outline,
        BackgroundTransparency = 1,
        Position = dim2(0, 8, 0, -15),
        AutomaticSize = Enum.AutomaticSize.XY,
        TextSize = 10,
        BorderSizePixel = 0,
    })

    items.line = library:create("Frame", {
        Parent = items.text,
        Position = dim2(0, 0, 1, 2),
        Size = dim2(0, 0, 0, 1),
        BackgroundColor3 = glass_theme.accent,
        BorderSizePixel = 0,
    })

    items.section_outline.MouseEnter:Connect(function()
        library:tween(items.line, { Size = dim2(1, 0, 0, 1) }, nil, 0.15)
        library:tween(items.text, { TextColor3 = glass_theme.text }, nil, 0.15)
    end)

    items.section_outline.MouseLeave:Connect(function()
        library:tween(items.line, { Size = dim2(0, 0, 0, 1) }, nil, 0.15)
        library:tween(items.text, { TextColor3 = glass_theme.text_dim }, nil, 0.15)
    end)

    return setmetatable(cfg, library)
end

-- ============================================================================
-- TOGGLE
-- ============================================================================
function library:Toggle(options)
    options = options or {}
    local cfg = {
        enabled = options.enabled or options.Enabled or false,
        name = options.name or options.Name or "Toggle",
        flag = options.flag or options.Flag or "flag_" .. tostring(math.random(1, 99999)),
        default = options.default or options.Default or false,
        callback = options.callback or options.Callback or function() end,
        items = {},
    }

    local items = cfg.items

    items.object = library:create("TextButton", {
        Parent = self.items.elements,
        Text = "",
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 0, 16),
        BorderSizePixel = 0,
    })
    library:create("UIListLayout", {
        Parent = items.object,
        Padding = dim(0, 6),
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    })

    items.toggle_outline = library:create("Frame", {
        Parent = items.object,
        Size = dim2(0, 14, 0, 14),
        BackgroundColor3 = glass_theme.surface_dark,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
    })
    library:glassify(items.toggle_outline, 4, 0.6)

    items.text = library:create("TextLabel", {
        FontFace = library.font,
        TextColor3 = glass_theme.text_dim,
        Text = cfg.name,
        Parent = items.object,
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
        TextSize = 10,
        BorderSizePixel = 0,
    })

    function cfg.set(bool)
        library:tween(items.text, { TextColor3 = bool and glass_theme.text or glass_theme.text_dim }, nil, 0.15)
        library:tween(items.toggle_outline, {
            BackgroundColor3 = bool and glass_theme.accent or glass_theme.surface_dark,
            BackgroundTransparency = bool and 0.05 or 0.4,
        }, nil, 0.15)
        cfg.callback(bool)
        flags[cfg.flag] = bool
    end

    items.object.MouseButton1Click:Connect(function()
        cfg.enabled = not cfg.enabled
        cfg.set(cfg.enabled)
    end)

    cfg.set(cfg.default)
    config_flags[cfg.flag] = cfg.set
    return setmetatable(cfg, library)
end

-- ============================================================================
-- SLIDER
-- ============================================================================
function library:Slider(options)
    options = options or {}
    local cfg = {
        name = options.name or options.Name or "",
        suffix = options.suffix or options.Suffix or "",
        flag = options.flag or options.Flag or "flag_" .. tostring(math.random(1, 99999)),
        callback = options.callback or options.Callback or function() end,
        min = options.min or options.Min or 0,
        max = options.max or options.Max or 100,
        intervals = options.interval or options.Interval or 1,
        default = options.default or options.Default or 10,
        value = options.default or options.Default or 10,
        dragging = false,
        items = {},
    }

    local items = cfg.items

    items.object = library:create("Frame", {
        Parent = self.items.elements,
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 0, 24),
        AutomaticSize = Enum.AutomaticSize.Y,
        BorderSizePixel = 0,
    })
    library:create("UIListLayout", {
        Parent = items.object,
        Padding = dim(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    items.header = library:create("Frame", {
        Parent = items.object,
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 0, 12),
        BorderSizePixel = 0,
    })

    items.name = library:create("TextLabel", {
        Parent = items.header,
        FontFace = library.font,
        TextColor3 = glass_theme.text_dim,
        Text = cfg.name,
        BackgroundTransparency = 1,
        Size = dim2(0.7, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 10,
        BorderSizePixel = 0,
    })

    items.value = library:create("TextLabel", {
        Parent = items.header,
        FontFace = library.font,
        TextColor3 = glass_theme.text,
        Text = "",
        BackgroundTransparency = 1,
        Position = dim2(0.7, 0, 0, 0),
        Size = dim2(0.3, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
        TextSize = 10,
        BorderSizePixel = 0,
    })

    items.track = library:create("TextButton", {
        Parent = items.object,
        BackgroundColor3 = glass_theme.surface_dark,
        BackgroundTransparency = 0.4,
        Size = dim2(1, 0, 0, 5),
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
    })
    library:create("UICorner", { Parent = items.track, CornerRadius = dim(1, 0) })

    items.fill = library:create("Frame", {
        Parent = items.track,
        BackgroundColor3 = glass_theme.accent,
        Size = dim2(0, 0, 1, 0),
        BorderSizePixel = 0,
    })
    library:create("UICorner", { Parent = items.fill, CornerRadius = dim(1, 0) })

    function cfg.set(value)
        cfg.value = clamp(library:round(value, cfg.intervals), cfg.min, cfg.max)
        local pct = (cfg.value - cfg.min) / (cfg.max - cfg.min)
        library:tween(items.fill, { Size = dim2(pct, 0, 1, 0) }, nil, 0.12)
        items.value.Text = tostring(cfg.value) .. cfg.suffix
        flags[cfg.flag] = cfg.value
        cfg.callback(flags[cfg.flag])
    end

    items.track.MouseButton1Down:Connect(function()
        cfg.dragging = true
    end)

    library:connection(uis.InputChanged, function(i)
        if cfg.dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local pct = (i.Position.X - items.track.AbsolutePosition.X) / items.track.AbsoluteSize.X
            cfg.set((cfg.max - cfg.min) * pct + cfg.min)
        end
    end)

    library:connection(uis.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            cfg.dragging = false
        end
    end)

    cfg.set(cfg.default)
    config_flags[cfg.flag] = cfg.set
    return setmetatable(cfg, library)
end

-- ============================================================================
-- DROPDOWN
-- ============================================================================
function library:Dropdown(options)
    options = options or {}
    local cfg = {
        name = options.name or options.Name or nil,
        flag = options.flag or options.Flag or "flag_" .. tostring(math.random(1, 99999)),
        options = options.items or options.Items or { "1", "2", "3" },
        callback = options.callback or options.Callback or function() end,
        multi = options.multi or options.Multi or false,
        open = false,
        option_instances = {},
        multi_items = {},
        items = {},
    }

    cfg.default = options.default or cfg.options[1] or "None"
    flags[cfg.flag] = cfg.default

    local items = cfg.items

    items.object = library:create("Frame", {
        Parent = self.items.elements,
        BackgroundTransparency = 1,
        Size = dim2(0, 0, 0, 16),
        AutomaticSize = Enum.AutomaticSize.XY,
        BorderSizePixel = 0,
    })
    library:create("UIListLayout", {
        Parent = items.object,
        Padding = dim(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    if cfg.name then
        library:create("TextLabel", {
            Parent = items.object,
            FontFace = library.font,
            TextColor3 = glass_theme.text_dim,
            Text = cfg.name,
            BackgroundTransparency = 1,
            Size = dim2(1, 0, 0, 12),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 10,
            BorderSizePixel = 0,
            LayoutOrder = 0,
        })
    end

    items.dropdown_outline = library:create("TextButton", {
        Parent = items.object,
        Text = "",
        AutoButtonColor = false,
        Size = dim2(0, 0, 0, 18),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = glass_theme.surface_dark,
        BorderSizePixel = 0,
        LayoutOrder = 1,
    })
    library:glassify(items.dropdown_outline, glass_theme.corner_radius_tiny, 0.9)

    items.inner_text = library:create("TextLabel", {
        Parent = items.dropdown_outline,
        FontFace = library.font,
        TextColor3 = glass_theme.text,
        Text = tostring(cfg.default),
        BackgroundTransparency = 1,
        Position = dim2(0, 10, 0, 0),
        Size = dim2(1, -30, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextSize = 10,
        BorderSizePixel = 0,
    })

    items.arrow = library:create("ImageLabel", {
        Parent = items.dropdown_outline,
        ImageColor3 = glass_theme.text_dim,
        AnchorPoint = vec2(1, 0.5),
        Image = "rbxassetid://76667213487638",
        BackgroundTransparency = 1,
        Position = dim2(1, -8, 0.5, 0),
        Size = dim2(0, 8, 0, 5),
        BorderSizePixel = 0,
    })

    items.holder = library:create("Frame", {
        Parent = library.items,
        Size = dim2(0, 114, 0, 0),
        Visible = false,
        Position = dim2(0, 0, 0, 0),
        BackgroundColor3 = glass_theme.surface_dark,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    library:glassify(items.holder, glass_theme.corner_radius_tiny, 1.0)

    items.list = library:create("Frame", {
        Parent = items.holder,
        Size = dim2(1, -2, 0, -2),
        Position = dim2(0, 1, 0, 1),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        BorderSizePixel = 0,
    })
    library:create("UIListLayout", {
        Parent = items.list,
        Padding = dim(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    library:create("UIPadding", {
        Parent = items.list,
        PaddingBottom = dim(0, 6),
        PaddingTop = dim(0, 6),
        PaddingLeft = dim(0, 6),
        PaddingRight = dim(0, 6),
    })

    function cfg.render_option(text)
        local btn = library:create("TextButton", {
            Parent = items.list,
            FontFace = library.font,
            TextColor3 = glass_theme.text_dim,
            Text = text,
            Size = dim2(1, 0, 0, 16),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            AutomaticSize = Enum.AutomaticSize.XY,
            TextSize = 10,
            BorderSizePixel = 0,
        })
        library:create("UIPadding", {
            Parent = btn,
            PaddingLeft = dim(0, 6),
            PaddingRight = dim(0, 6),
        })
        return btn
    end

    function cfg.set_visible(bool)
        items.holder.Visible = bool
        items.arrow.Rotation = bool and 180 or 0
        items.holder.Size = dim2(0, items.dropdown_outline.AbsoluteSize.X, 0, 0)
        items.holder.Position = dim2(
            0, items.dropdown_outline.AbsolutePosition.X,
            0, items.dropdown_outline.AbsolutePosition.Y + items.dropdown_outline.AbsoluteSize.Y + 2
        )
        library.current = cfg
    end

    function cfg.set(value)
        local selected = {}
        local isTable = type(value) == "table"
        for _, opt in ipairs(cfg.option_instances) do
            if opt.Text == value or (isTable and find(value, opt.Text)) then
                insert(selected, opt.Text)
                cfg.multi_items = selected
                opt.TextColor3 = glass_theme.text
            else
                opt.TextColor3 = glass_theme.text_dim
            end
        end
        items.inner_text.Text = isTable and concat(selected, ", ") or (selected[1] or "")
        flags[cfg.flag] = isTable and selected or selected[1]
        cfg.callback(flags[cfg.flag])
    end

    function cfg.refresh_options(list)
        for _, o in ipairs(cfg.option_instances) do
            o:Destroy()
        end
        cfg.option_instances = {}
        for _, opt in ipairs(list) do
            local b = cfg.render_option(opt)
            insert(cfg.option_instances, b)
            b.MouseButton1Down:Connect(function()
                if cfg.multi then
                    local i = find(cfg.multi_items, b.Text)
                    if i then
                        remove(cfg.multi_items, i)
                    else
                        insert(cfg.multi_items, b.Text)
                    end
                    cfg.set(cfg.multi_items)
                else
                    cfg.set_visible(false)
                    cfg.open = false
                    cfg.set(b.Text)
                end
            end)
        end
    end

    items.dropdown_outline.MouseButton1Click:Connect(function()
        cfg.open = not cfg.open
        cfg.set_visible(cfg.open)
    end)

    library:connection(uis.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            if not (library:mouse_in_frame(items.holder) or library:mouse_in_frame(items.object)) then
                cfg.open = false
                cfg.set_visible(false)
            end
        end
    end)

    cfg.refresh_options(cfg.options)
    cfg.set(cfg.default)
    config_flags[cfg.flag] = cfg.set
    return setmetatable(cfg, library)
end

-- ============================================================================
-- LABEL
-- ============================================================================
function library:Label(options)
    options = options or {}
    local cfg = {
        name = options.Name or options.name or "",
        items = {},
    }

    local items = cfg.items

    items.object = library:create("TextLabel", {
        Parent = self.items.elements or self.items.object or self.items.header,
        Text = cfg.name,
        FontFace = library.font,
        TextColor3 = glass_theme.text_dim,
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 0, 12),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 10,
        BorderSizePixel = 0,
    })

    function cfg.set(text)
        items.object.Text = text
    end

    return setmetatable(cfg, library)
end

-- ============================================================================
-- COLORPICKER
-- ============================================================================
function library:Colorpicker(options)
    options = options or {}
    local cfg = {
        name = options.name or options.Name or "",
        flag = options.flag or options.Flag or "flag_" .. tostring(math.random(1, 99999)),
        color = options.color or options.Color or color(1, 1, 1),
        alpha = (options.alpha and 1 - options.alpha) or 0,
        callback = options.callback or options.Callback or function() end,
        items = {},
    }

    local h, s, v = cfg.color:ToHSV()
    local a = cfg.alpha

    flags[cfg.flag] = { Color = cfg.color, Transparency = cfg.alpha }

    local items = cfg.items

    items.row = library:create("Frame", {
        Parent = self.items.elements,
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 0, 16),
        BorderSizePixel = 0,
    })

    items.swatch = library:create("TextButton", {
        Parent = items.row,
        BackgroundColor3 = cfg.color,
        BackgroundTransparency = 0.1,
        Size = dim2(0, 16, 0, 16),
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
    })
    library:create("UICorner", { Parent = items.swatch, CornerRadius = dim(0, 4) })
    library:create("UIStroke", {
        Parent = items.swatch,
        Color = glass_theme.glass_border,
        Transparency = 0.7,
        Thickness = 1,
    })

    library:create("TextLabel", {
        Parent = items.row,
        FontFace = library.font,
        TextColor3 = glass_theme.text_dim,
        Text = cfg.name,
        BackgroundTransparency = 1,
        Position = dim2(0, 22, 0, 0),
        Size = dim2(1, -22, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 10,
        BorderSizePixel = 0,
    })

    items.panel = library:create("Frame", {
        Parent = library.items,
        Visible = false,
        Size = dim2(0, 180, 0, 180),
        BackgroundColor3 = glass_theme.surface_dark,
        BorderSizePixel = 0,
        ZIndex = 100,
    })
    library:glassify(items.panel, glass_theme.corner_radius_small, 1.2)

    items.sv = library:create("TextButton", {
        Parent = items.panel,
        Size = dim2(1, -22, 1, -40),
        Position = dim2(0, 10, 0, 10),
        BackgroundColor3 = Color3.fromHSV(h, 1, 1),
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
    })
    library:create("UICorner", { Parent = items.sv, CornerRadius = dim(0, 6) })
    library:create("UIGradient", {
        Parent = items.sv,
        Rotation = 270,
        Transparency = numseq { numkey(0, 0), numkey(1, 1) },
    })

    items.sv_cur = library:create("Frame", {
        Parent = items.sv,
        Size = dim2(0, 8, 0, 8),
        AnchorPoint = vec2(0.5, 0.5),
        BackgroundColor3 = color(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 5,
    })
    library:create("UICorner", { Parent = items.sv_cur, CornerRadius = dim(1, 0) })

    items.hue = library:create("TextButton", {
        Parent = items.panel,
        Size = dim2(0, 8, 1, -40),
        Position = dim2(1, -18, 0, 10),
        BackgroundColor3 = color(1, 1, 1),
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
    })
    library:create("UICorner", { Parent = items.hue, CornerRadius = dim(0, 4) })
    library:create("UIGradient", {
        Parent = items.hue,
        Rotation = 270,
        Color = rgbseq {
            rgbkey(0,    rgb(255, 0, 0)),
            rgbkey(0.17, rgb(255, 255, 0)),
            rgbkey(0.33, rgb(0, 255, 0)),
            rgbkey(0.5,  rgb(0, 255, 255)),
            rgbkey(0.67, rgb(0, 0, 255)),
            rgbkey(0.83, rgb(255, 0, 255)),
            rgbkey(1,    rgb(255, 0, 0)),
        },
    })

    items.hue_cur = library:create("Frame", {
        Parent = items.hue,
        Size = dim2(1, 2, 0, 3),
        Position = dim2(0, -1, 0, -1),
        BackgroundColor3 = color(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 5,
    })

    items.alpha = library:create("TextButton", {
        Parent = items.panel,
        Size = dim2(1, -22, 0, 8),
        Position = dim2(0, 10, 1, -20),
        BackgroundColor3 = color(1, 1, 1),
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
    })
    library:create("UICorner", { Parent = items.alpha, CornerRadius = dim(0, 4) })
    library:create("UIGradient", {
        Parent = items.alpha,
        Color = rgbseq { rgbkey(0, color(0, 0, 0)), rgbkey(1, color(1, 1, 1)) },
    })

    items.alpha_cur = library:create("Frame", {
        Parent = items.alpha,
        Size = dim2(0, 3, 1, 2),
        Position = dim2(0, -1, 0, -1),
        BackgroundColor3 = color(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 5,
    })

    local ds, dh, da = false, false, false

    function cfg.set_visible(bool)
        items.panel.Visible = bool
        items.panel.Position = dim2(
            0, items.swatch.AbsolutePosition.X - 90,
            0, items.swatch.AbsolutePosition.Y + 22
        )
        library.current = cfg
    end

    function cfg.set(col, alpha)
        if col then h, s, v = col:ToHSV() end
        if alpha then a = alpha end
        local Color = Color3.fromHSV(h, s, v)
        items.hue_cur.Position = dim2(0, -1, 1 - h, -1)
        items.alpha_cur.Position = dim2(1 - a, -1, 0, -1)
        items.sv_cur.Position = dim2(s, 0, 1 - v, 0)
        items.sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        items.swatch.BackgroundColor3 = Color
        flags[cfg.flag] = { Color = Color, Transparency = a }
        cfg.callback(Color, a)
    end

    function cfg.update_color()
        local offset = vec2(mouse.X, mouse.Y - gui_offset)
        if ds then
            s = clamp((offset.X - items.sv.AbsolutePosition.X) / items.sv.AbsoluteSize.X, 0, 1)
            v = 1 - clamp((offset.Y - items.sv.AbsolutePosition.Y) / items.sv.AbsoluteSize.Y, 0, 1)
        elseif dh then
            h = 1 - clamp((offset.Y - items.hue.AbsolutePosition.Y) / items.hue.AbsoluteSize.Y, 0, 1)
        elseif da then
            a = 1 - clamp((offset.X - items.alpha.AbsolutePosition.X) / items.alpha.AbsoluteSize.X, 0, 1)
        end
        cfg.set(nil, nil)
    end

    library:connection(uis.InputChanged, function(i)
        if (ds or dh or da) and i.UserInputType == Enum.UserInputType.MouseMovement then
            cfg.update_color()
        end
    end)

    library:connection(uis.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            ds, dh, da = false, false, false
        end
    end)

    items.swatch.MouseButton1Click:Connect(function()
        cfg.set_visible(not items.panel.Visible)
    end)
    items.sv.MouseButton1Down:Connect(function() ds = true; cfg.update_color() end)
    items.hue.MouseButton1Down:Connect(function() dh = true; cfg.update_color() end)
    items.alpha.MouseButton1Down:Connect(function() da = true; cfg.update_color() end)

    cfg.set(cfg.color, cfg.alpha)
    config_flags[cfg.flag] = cfg.set
    return setmetatable(cfg, library)
end

-- ============================================================================
-- TEXTBOX
-- ============================================================================
function library:Textbox(options)
    options = options or {}
    local cfg = {
        name = options.name or options.Name or "",
        placeholder = options.placeholder or options.PlaceHolder or "type...",
        default = options.default or options.Default or "",
        flag = options.flag or "flag_" .. tostring(math.random(1, 99999)),
        callback = options.callback or options.Callback or function() end,
        items = {},
    }

    flags[cfg.flag] = cfg.default
    local items = cfg.items

    items.object = library:create("Frame", {
        Parent = self.items.elements,
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 0, 36),
        BorderSizePixel = 0,
    })
    library:create("UIListLayout", {
        Parent = items.object,
        Padding = dim(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    if cfg.name ~= "" then
        library:create("TextLabel", {
            Parent = items.object,
            FontFace = library.font,
            TextColor3 = glass_theme.text_dim,
            Text = cfg.name,
            BackgroundTransparency = 1,
            Size = dim2(1, 0, 0, 12),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 10,
            BorderSizePixel = 0,
        })
    end

    items.box = library:create("TextBox", {
        Parent = items.object,
        FontFace = library.font,
        PlaceholderText = cfg.placeholder,
        PlaceholderColor3 = glass_theme.text_muted,
        TextSize = 10,
        Size = dim2(1, 0, 0, 20),
        TextColor3 = glass_theme.text,
        Text = "",
        BackgroundColor3 = glass_theme.surface_dark,
        BackgroundTransparency = 0.3,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        BorderSizePixel = 0,
    })
    library:glassify(items.box, glass_theme.corner_radius_tiny, 0.9)
    library:create("UIPadding", {
        Parent = items.box,
        PaddingLeft = dim(0, 8),
        PaddingRight = dim(0, 8),
    })

    function cfg.set(text)
        if type(text) == "boolean" then return end
        flags[cfg.flag] = text
        items.box.Text = text
        cfg.callback(text)
    end

    items.box:GetPropertyChangedSignal("Text"):Connect(function()
        cfg.set(items.box.Text)
    end)

    if cfg.default ~= "" then
        cfg.set(cfg.default)
    end

    config_flags[cfg.flag] = cfg.set
    return setmetatable(cfg, library)
end

-- ============================================================================
-- KEYBIND
-- ============================================================================
function library:Keybind(options)
    options = options or {}
    local cfg = {
        flag = options.flag or "flag_" .. tostring(math.random(1, 99999)),
        callback = options.callback or options.Callback or function() end,
        name = options.name or options.Name or nil,
        key = options.key or options.Key or nil,
        mode = options.mode or options.Mode or "Toggle",
        active = options.default or options.Default or false,
        items = {},
    }

    flags[cfg.flag] = { mode = cfg.mode, key = cfg.key, active = cfg.active }
    local items = cfg.items

    items.object = library:create("Frame", {
        Parent = self.items.elements,
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 0, 16),
        BorderSizePixel = 0,
    })

    if cfg.name then
        library:create("TextLabel", {
            Parent = items.object,
            FontFace = library.font,
            TextColor3 = glass_theme.text_dim,
            Text = cfg.name,
            BackgroundTransparency = 1,
            Size = dim2(1, -80, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 10,
            BorderSizePixel = 0,
        })
    end

    items.btn = library:create("TextButton", {
        Parent = items.object,
        FontFace = library.font,
        TextColor3 = glass_theme.text,
        Text = cfg.key and (keys[cfg.key] or tostring(cfg.key):gsub("Enum.", "")) or "NONE",
        BackgroundColor3 = glass_theme.surface_dark,
        BackgroundTransparency = 0.3,
        Size = dim2(0, 70, 1, 0),
        Position = dim2(1, -70, 0, 0),
        TextSize = 10,
        AutoButtonColor = false,
        BorderSizePixel = 0,
    })
    library:glassify(items.btn, glass_theme.corner_radius_tiny, 0.7)

    function cfg.set(input)
        if type(input) == "boolean" then
            cfg.active = input
        elseif typeof(input) == "EnumItem" then
            cfg.key = input
            items.btn.Text = keys[input] or input.Name
        elseif type(input) == "table" then
            if input.key then cfg.key = input.key end
            if input.mode then cfg.mode = input.mode end
            if input.active ~= nil then cfg.active = input.active end
            items.btn.Text = cfg.key and (keys[cfg.key] or (typeof(cfg.key) == "EnumItem" and cfg.key.Name) or "NONE") or "NONE"
        end
        cfg.callback(cfg.active)
        flags[cfg.flag] = { mode = cfg.mode, key = cfg.key, active = cfg.active }
        library.keybinds[cfg.flag] = { key = cfg.key, mode = cfg.mode, name = cfg.name or cfg.flag }
        if library.refresh_keybind_hud then
            library:refresh_keybind_hud()
        end
    end

    items.btn.MouseButton1Down:Connect(function()
        items.btn.Text = "..."
        local conn
        conn = uis.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Keyboard then
                cfg.set(i.KeyCode)
                conn:Disconnect()
            end
        end)
    end)

    library:connection(uis.InputBegan, function(i, gp)
        if gp then return end
        local k = i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode or i.UserInputType
        if k == cfg.key then
            if cfg.mode == "Toggle" then
                cfg.active = not cfg.active
                cfg.set(cfg.active)
            elseif cfg.mode == "Hold" then
                cfg.set(true)
            end
        end
    end)

    library:connection(uis.InputEnded, function(i)
        local k = i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode or i.UserInputType
        if k == cfg.key and cfg.mode == "Hold" then
            cfg.set(false)
        end
    end)

    cfg.set({ key = cfg.key, mode = cfg.mode, active = cfg.active })
    config_flags[cfg.flag] = cfg.set
    return setmetatable(cfg, library)
end

-- ============================================================================
-- BUTTON
-- ============================================================================
function library:Button(options)
    options = options or {}
    local cfg = {
        name = options.name or options.Name or "Button",
        callback = options.callback or options.Callback or function() end,
        items = {},
    }

    local btn = library:create("TextButton", {
        Parent = self.items.elements,
        Name = "Button",
        FontFace = library.font,
        TextColor3 = glass_theme.text,
        Text = cfg.name,
        BackgroundColor3 = glass_theme.surface_dark,
        BackgroundTransparency = 0.3,
        Size = dim2(1, 0, 0, 22),
        TextSize = 10,
        AutoButtonColor = false,
        BorderSizePixel = 0,
    })
    library:glassify(btn, glass_theme.corner_radius_tiny, 0.9)

    btn.MouseEnter:Connect(function()
        library:tween(btn, { BackgroundTransparency = 0.05, TextColor3 = glass_theme.accent }, nil, 0.12)
    end)
    btn.MouseLeave:Connect(function()
        library:tween(btn, { BackgroundTransparency = 0.3, TextColor3 = glass_theme.text }, nil, 0.12)
    end)
    btn.MouseButton1Click:Connect(function()
        cfg.callback()
    end)

    return setmetatable(cfg, library)
end

-- ============================================================================
-- LIST
-- ============================================================================
function library:list(options)
    options = options or {}
    local cfg = {
        options = options.options or options.Options or { "1", "2", "3" },
        flag = options.flag or "flag_" .. tostring(math.random(1, 99999)),
        callback = options.callback or function() end,
        data = {},
        current = nil,
        items = {},
    }

    local items = cfg.items

    items.wrap = library:create("Frame", {
        Parent = self.items.elements,
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BorderSizePixel = 0,
    })
    library:create("UIListLayout", {
        Parent = items.wrap,
        Padding = dim(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    function cfg.refresh_options(list)
        for _, b in ipairs(cfg.data) do
            b:Destroy()
        end
        cfg.data = {}
        for _, opt in ipairs(list) do
            local btn = library:create("TextButton", {
                Parent = items.wrap,
                FontFace = library.font,
                TextColor3 = glass_theme.text_dim,
                Text = "",
                Size = dim2(1, 0, 0, 20),
                BackgroundColor3 = glass_theme.surface_dark,
                BackgroundTransparency = 0.4,
                AutoButtonColor = false,
                BorderSizePixel = 0,
            })
            library:glassify(btn, glass_theme.corner_radius_tiny, 0.7)

            library:create("TextLabel", {
                Parent = btn,
                Text = opt,
                FontFace = library.font,
                TextColor3 = glass_theme.text_dim,
                BackgroundTransparency = 1,
                Size = dim2(1, 0, 1, 0),
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Center,
            })
            insert(cfg.data, btn)

            btn.MouseButton1Click:Connect(function()
                if cfg.current and cfg.current ~= btn then
                    library:tween(cfg.current, { BackgroundTransparency = 0.4 }, nil, 0.15)
                end
                flags[cfg.flag] = opt
                cfg.callback(opt)
                library:tween(btn, {
                    BackgroundTransparency = 0.05,
                    BackgroundColor3 = glass_theme.accent,
                }, nil, 0.15)
                cfg.current = btn
            end)
        end
    end

    cfg.refresh_options(cfg.options)
    return setmetatable(cfg, library)
end

-- ============================================================================
-- INIT CONFIG TAB
-- ============================================================================
function library:init_config(window)
    local textbox
    local main = window:Tab({ name = "Configs", icon = "rbxassetid://72506063321241" })
    local section = main:Section({ name = "Settings", side = "left" })

    config_holder = section:Dropdown({
        name = "Configs",
        options = { "Default" },
        callback = function(opt)
            if textbox then textbox.set(opt) end
        end,
        flag = "config_name_list",
    })

    textbox = section:Textbox({ name = "Config name:", flag = "config_name_text" })

    section:Button({
        name = "Save",
        callback = function()
            local n = flags["config_name_text"]
            if n and n ~= "" then
                writefile(library.directory .. "/configs/" .. n .. ".cfg", library:get_config())
                library:update_config_list()
            end
        end,
    })

    section:Button({
        name = "Load",
        callback = function()
            local n = flags["config_name_text"]
            if n and isfile(library.directory .. "/configs/" .. n .. ".cfg") then
                library:load_config(readfile(library.directory .. "/configs/" .. n .. ".cfg"))
            end
        end,
    })

    section:Button({
        name = "Delete",
        callback = function()
            local n = flags["config_name_text"]
            if n and isfile(library.directory .. "/configs/" .. n .. ".cfg") then
                delfile(library.directory .. "/configs/" .. n .. ".cfg")
                library:update_config_list()
            end
        end,
    })

    section:Label({ name = "UI Bind" }):Keybind({
        callback = function(v)
            window.toggle_menu(v)
        end,
    })
end

function library:update_config_list()
    if not config_holder then return end
    local list = {}
    local ok, files = pcall(function()
        return listfiles(library.directory .. "/configs")
    end)
    if ok and files then
        for _, f in ipairs(files) do
            local n = f:match("([^/\\]+)%.cfg$")
            if n then insert(list, n) end
        end
    end
    config_holder.refresh_options(list)
end

function library:get_config()
    local out = {}
    for k, v in pairs(flags) do
        if type(v) == "table" and v.key then
            out[k] = { active = v.active, mode = v.mode, key = tostring(v.key) }
        elseif type(v) == "table" and v.Transparency and v.Color then
            out[k] = { Transparency = v.Transparency, Color = v.Color:ToHex() }
        else
            out[k] = v
        end
    end
    return http_service:JSONEncode(out)
end

function library:load_config(json)
    local ok, cfg = pcall(function()
        return http_service:JSONDecode(json)
    end)
    if not ok or type(cfg) ~= "table" then return end
    for k, v in pairs(cfg) do
        if k ~= "config_name_list" then
            local fn = config_flags[k]
            if fn then
                pcall(function()
                    if type(v) == "table" and v.Transparency and v.Color then
                        fn(hex(v.Color), v.Transparency)
                    else
                        fn(v)
                    end
                end)
            end
        end
    end
end

-- ============================================================================
-- UNLOAD
-- ============================================================================
function library:unload_menu()
    if library.items then library.items:Destroy() end
    if library.other then library.other:Destroy() end
    for _, c in ipairs(library.connections) do
        pcall(function() c:Disconnect() end)
    end
    library.connections = {}
end

-- ============================================================================
-- DONE
-- ============================================================================
print("[monolithhh] loaded — Liquid Glass COMPLET")
return library, notifications
