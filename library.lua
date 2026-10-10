-- REASON: Discontinued nobody wanted to buy it either...
-- Rewritten: Gamesense CS2 style + icon sidebar + compact sub-tab badges + rounded + mobile
-- FULL VERSION: toutes les fonctions restaurées

-- ===== SERVICES =====
local uis = game:GetService("UserInputService")
local players = game:GetService("Players")
local ws = game:GetService("Workspace")
local rs = game:GetService("ReplicatedStorage")
local http_service = game:GetService("HttpService")
local gui_service = game:GetService("GuiService")
local lighting = game:GetService("Lighting")
local run = game:GetService("RunService")
local stats = game:GetService("Stats")
local coregui = game:GetService("CoreGui")
local debris = game:GetService("Debris")
local tween_service = game:GetService("TweenService")
local sound_service = game:GetService("SoundService")

-- ===== SHORTCUTS =====
local vec2 = Vector2.new
local vec3 = Vector3.new
local dim2 = UDim2.new
local dim = UDim.new
local rect = Rect.new
local cfr = CFrame.new
local empty_cfr = cfr()
local angle = CFrame.Angles
local dim_offset = UDim2.fromOffset

local color = Color3.new
local rgb = Color3.fromRGB
local hex = Color3.fromHex
local hsv = Color3.fromHSV
local rgbseq = ColorSequence.new
local rgbkey = ColorSequenceKeypoint.new
local numseq = NumberSequence.new
local numkey = NumberSequenceKeypoint.new

local camera = ws.CurrentCamera
local lp = players.LocalPlayer
local mouse = lp:GetMouse()
local gui_offset = gui_service:GetGuiInset().Y

local max = math.max
local floor = math.floor
local min = math.min
local abs = math.abs
local noise = math.noise
local rad = math.rad
local random = math.random
local pow = math.pow
local sin = math.sin
local pi = math.pi
local tan = math.tan
local atan2 = math.atan2
local clamp = math.clamp

local insert = table.insert
local find = table.find
local remove = table.remove
local concat = table.concat

-- ===== MOBILE =====
local is_mobile = uis.TouchEnabled and not uis.MouseEnabled
local is_tablet = uis.TouchEnabled and uis.MouseEnabled and not uis.KeyboardEnabled

local function get_ui_scale()
    local vp = camera.ViewportSize
    if is_mobile then return clamp(min(vp.X / 420, vp.Y / 320), 0.65, 1) end
    if is_tablet then return clamp(min(vp.X / 420, vp.Y / 320), 0.8, 1) end
    return 1
end
local UI_SCALE = get_ui_scale()

-- ===== INIT =====
getgenv().library = {
    directory = "vaderhaxx",
    folders = { "/fonts", "/configs" },
    flags = {},
    config_flags = {},
    connections = {},
    notifications = {},
    colorpicker_open = false,
    gui,
    is_mobile = is_mobile,
    scale = UI_SCALE,
}

-- ===== THEME =====
local themes = {
    preset = {
        accent      = rgb(0, 200, 160),
        accent_alt  = rgb(220, 70, 70),
        text        = rgb(225, 225, 225),
        text_dim    = rgb(130, 130, 130),
        text_outline= rgb(0, 0, 0),
        a = rgb(10, 10, 10),
        b = rgb(22, 22, 22),
        c = rgb(28, 28, 28),
        d = rgb(15, 15, 15),
        e = rgb(35, 35, 35),
        f = rgb(55, 55, 55),
        g = rgb(45, 45, 45),
        header = rgb(18, 18, 18),
        border = rgb(55, 55, 55),
    },
    utility = {
        accent = {BackgroundColor3 = {}, Color = {}, ScrollBarImageColor3 = {}, TextColor3 = {}, ImageColor3 = {}},
        text = {TextColor3 = {}, BackgroundColor3 = {}},
        text_outline = {Color = {}},
        a = {BackgroundColor3 = {}, Color = {}},
        b = {BackgroundColor3 = {}, Color = {}},
        c = {BackgroundColor3 = {}, Color = {}},
        d = {BackgroundColor3 = {}, Color = {}},
        e = {BackgroundColor3 = {}, Color = {}},
        f = {BackgroundColor3 = {}, Color = {}},
        g = {BackgroundColor3 = {}, Color = {}},
        header = {BackgroundColor3 = {}, Color = {}},
        border = {BackgroundColor3 = {}, Color = {}},
    }
}

-- ===== KEYS (complet) =====
local keys = {
    [Enum.KeyCode.LeftShift] = "LS", [Enum.KeyCode.RightShift] = "RS",
    [Enum.KeyCode.LeftControl] = "LC", [Enum.KeyCode.RightControl] = "RC",
    [Enum.KeyCode.Insert] = "INS", [Enum.KeyCode.Backspace] = "BS",
    [Enum.KeyCode.Return] = "ENT", [Enum.KeyCode.LeftAlt] = "LA",
    [Enum.KeyCode.RightAlt] = "RA", [Enum.KeyCode.CapsLock] = "CAPS",
    [Enum.KeyCode.One] = "1", [Enum.KeyCode.Two] = "2", [Enum.KeyCode.Three] = "3",
    [Enum.KeyCode.Four] = "4", [Enum.KeyCode.Five] = "5", [Enum.KeyCode.Six] = "6",
    [Enum.KeyCode.Seven] = "7", [Enum.KeyCode.Eight] = "8", [Enum.KeyCode.Nine] = "9",
    [Enum.KeyCode.Zero] = "0",
    [Enum.KeyCode.KeypadOne] = "Num1", [Enum.KeyCode.KeypadTwo] = "Num2",
    [Enum.KeyCode.KeypadThree] = "Num3", [Enum.KeyCode.KeypadFour] = "Num4",
    [Enum.KeyCode.KeypadFive] = "Num5", [Enum.KeyCode.KeypadSix] = "Num6",
    [Enum.KeyCode.KeypadSeven] = "Num7", [Enum.KeyCode.KeypadEight] = "Num8",
    [Enum.KeyCode.KeypadNine] = "Num9", [Enum.KeyCode.KeypadZero] = "Num0",
    [Enum.KeyCode.Minus] = "-", [Enum.KeyCode.Equals] = "=",
    [Enum.KeyCode.Tilde] = "~", [Enum.KeyCode.LeftBracket] = "[",
    [Enum.KeyCode.RightBracket] = "]", [Enum.KeyCode.RightParenthesis] = ")",
    [Enum.KeyCode.LeftParenthesis] = "(", [Enum.KeyCode.Semicolon] = ",",
    [Enum.KeyCode.Quote] = "'", [Enum.KeyCode.BackSlash] = "\\",
    [Enum.KeyCode.Comma] = ",", [Enum.KeyCode.Period] = ".",
    [Enum.KeyCode.Slash] = "/", [Enum.KeyCode.Asterisk] = "*",
    [Enum.KeyCode.Plus] = "+", [Enum.KeyCode.Backquote] = "`",
    [Enum.UserInputType.MouseButton1] = "MB1",
    [Enum.UserInputType.MouseButton2] = "MB2",
    [Enum.UserInputType.MouseButton3] = "MB3",
    [Enum.UserInputType.Touch] = "TCH",
    [Enum.KeyCode.Escape] = "ESC",
    [Enum.KeyCode.Space] = "SPC",
}

library.__index = library

for _, path in next, library.folders do
    pcall(makefolder, library.directory .. path)
end

local flags = library.flags
local config_flags = library.config_flags

-- ===== FONT =====
if not isfile(library.directory .. "/fonts/main.ttf") then
    pcall(function()
        writefile(library.directory .. "/fonts/main.ttf",
            game:HttpGet("https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/ProggyClean.ttf"))
    end)
end

local proggy = {
    name = "ProggyClean",
    faces = {{
        name = "Regular", weight = 400, style = "normal",
        assetId = getcustomasset(library.directory .. "/fonts/main.ttf")
    }}
}
if not isfile(library.directory .. "/fonts/main_encoded.ttf") then
    writefile(library.directory .. "/fonts/main_encoded.ttf", http_service:JSONEncode(proggy))
end
library.font = Font.new(getcustomasset(library.directory .. "/fonts/main_encoded.ttf"), Enum.FontWeight.Regular)

-- ===== ROUNDED HELPER =====
local function apply_corner(instance, radius)
    if instance:FindFirstChildOfClass("UICorner") then return end
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 4)
    c.Parent = instance
    return c
end
library.apply_corner = apply_corner

-- =========================================================
-- LIBRARY FUNCTIONS
-- =========================================================
function library:tween(obj, props)
    return tween_service:Create(obj,
        TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

function library:close_current_element(cfg)
    local path = library.current_element_open
    if path then
        path.set_visible(false)
        path.open = false
    end
end

library.lerp = function(start, finish, t)
    t = t or 1 / 8
    return start * (1 - t) + finish * t
end

function library:mouse_in_frame(uiobject)
    local p = uis:GetMouseLocation()
    return uiobject.AbsolutePosition.Y <= p.Y and p.Y <= uiobject.AbsolutePosition.Y + uiobject.AbsoluteSize.Y
       and uiobject.AbsolutePosition.X <= p.X and p.X <= uiobject.AbsolutePosition.X + uiobject.AbsoluteSize.X
end

function library:draggify(frame)
    local dragging, start, start_pos = false, nil, nil
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; start = input.Position; start_pos = frame.Position
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    library:connection(uis.InputChanged, function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            frame.Position = dim2(0,
                clamp(start_pos.X.Offset + (input.Position.X - start.X), 0, camera.ViewportSize.X - frame.AbsoluteSize.X),
                0,
                clamp(start_pos.Y.Offset + (input.Position.Y - start.Y), 0, camera.ViewportSize.Y - frame.AbsoluteSize.Y))
        end
    end)
end

function library:resizify(frame)
    local h = Instance.new("TextButton")
    h.BackgroundTransparency = 1; h.Text = ""
    h.Size = dim2(0, is_mobile and 22 or 14, 0, is_mobile and 22 or 14)
    h.Position = dim2(1, -h.Size.X.Offset, 1, -h.Size.Y.Offset)
    h.Parent = frame

    local resizing, start, og = false, nil, nil
    h.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            resizing = true; start = i.Position; og = frame.Size
        end
    end)
    h.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            resizing = false
        end
    end)
    library:connection(uis.InputChanged, function(i)
        if resizing and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            frame.Size = dim2(0,
                clamp(og.X.Offset + (i.Position.X - start.X), 320, camera.ViewportSize.X),
                0,
                clamp(og.Y.Offset + (i.Position.Y - start.Y), 240, camera.ViewportSize.Y))
        end
    end)
end

function library:convert(str)
    local v = {}
    for x in string.gmatch(str, "[^,]+") do insert(v, tonumber(x)) end
    if #v == 4 then return unpack(v) end
end

function library:convert_enum(enum)
    local parts = {}
    for p in string.gmatch(enum, "[%w_]+") do insert(parts, p) end
    local t = Enum
    for i = 2, #parts do t = t[parts[i]] end
    return t
end

local config_holder
function library:update_config_list()
    if not config_holder then return end
    local list = {}
    for _, file in next, listfiles(library.directory .. "/configs") do
        local name = file:gsub(library.directory .. "/configs\\", ""):gsub(".cfg", ""):gsub(library.directory .. "\\configs\\", "")
        list[#list + 1] = name
    end
    config_holder.refresh_options(list)
end

function library:get_config()
    local Config = {}
    for _, v in flags do
        if type(v) == "table" and v.key then
            Config[_] = {active = v.active, mode = v.mode, key = tostring(v.key)}
        elseif type(v) == "table" and v["Transparency"] and v["Color"] then
            Config[_] = {Transparency = v["Transparency"], Color = v["Color"]:ToHex()}
        else
            Config[_] = v
        end
    end
    return http_service:JSONEncode(Config)
end

function library:load_config(config_json)
    local config = http_service:JSONDecode(config_json)
    for _, v in next, config do
        local function_set = library.config_flags[_]
        if _ == "config_name_list" then continue end
        if function_set then
            if type(v) == "table" and v["Transparency"] and v["Color"] then
                function_set(hex(v["Color"]), v["Transparency"])
            else
                function_set(v)
            end
        end
    end
end

function library:round(n, f)
    local m = 1 / (f or 1)
    return floor(n * m + 0.5) / m
end

function library:apply_theme(inst, theme, prop)
    if themes.utility[theme] and themes.utility[theme][prop] then
        insert(themes.utility[theme][prop], inst)
    end
end

function library:update_theme(theme, c)
    if not themes.utility[theme] then return end
    for _, property in themes.utility[theme] do
        for m, object in property do
            if object[m] == themes.preset[theme] then
                object[m] = c
            end
        end
    end
    themes.preset[theme] = c
end

function library:connection(sig, cb)
    local c = sig:Connect(cb)
    insert(library.connections, c)
    return c
end

function library:apply_stroke(parent)
    -- conservé vide pour compat avec l'API originale
end

function library:create(class, props)
    local ins = Instance.new(class)
    for k, v in next, props do ins[k] = v end
    if ins:IsA("GuiObject") and not ins:FindFirstChildOfClass("UICorner") then
        apply_corner(ins, 4)
    end
    if class == "TextLabel" or class == "TextButton" or class == "TextBox" then
        library:apply_theme(ins, "text", "TextColor3")
        library:apply_stroke(ins)
    end
    return ins
end

function library:unload_menu()
    if library.gui then library.gui:Destroy() end
    for _, c in next, library.connections do pcall(function() c:Disconnect() end) end
    library = nil
end

-- =========================================================
-- WATERMARK
-- =========================================================
function library:watermark(options)
    local cfg = { name = options.name or "gamesense" }

    local outline = library:create("Frame", {
        Parent = library.gui,
        Size = dim2(0, 0, 0, 18),
        Position = dim2(0, 50, 0, 50),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = themes.preset.a,
    })
    apply_corner(outline, 4)
    library:apply_theme(outline, "a", "BackgroundColor3")
    library:draggify(outline)

    local inline = library:create("Frame", {
        Parent = outline,
        Position = dim2(0, 1, 0, 1),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = themes.preset.header,
    })
    apply_corner(inline, 3)
    library:apply_theme(inline, "header", "BackgroundColor3")

    library:create("TextLabel", {
        Parent = inline,
        BackgroundTransparency = 1,
        FontFace = library.font,
        Text = "◈ ",
        TextColor3 = themes.preset.accent,
        TextSize = 12,
        AutomaticSize = Enum.AutomaticSize.XY,
        Position = dim2(0, 6, 0, -2),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
    })
    library:apply_theme(inline, "accent", "BackgroundColor3")

    local title = library:create("TextLabel", {
        Parent = inline,
        BackgroundTransparency = 1,
        FontFace = library.font,
        Text = cfg.name,
        TextColor3 = themes.preset.text,
        TextSize = 12,
        AutomaticSize = Enum.AutomaticSize.XY,
        Position = dim2(0, 26, 0, -2),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
    })

    library:create("UIPadding", {
        PaddingTop = dim(0, 5), PaddingBottom = dim(0, 4),
        PaddingLeft = dim(0, 4), PaddingRight = dim(0, 10),
        Parent = inline,
    })

    function cfg.update_text(text)
        title.Text = cfg.name
    end

    return setmetatable(cfg, library)
end

-- =========================================================
-- WINDOW
-- =========================================================
function library:window(props)
    local cfg = {
        name = props.name or "gamesense",
        size = props.size or dim2(0, 400, 0, 320),
        selected_tab,
        tabs = {},
    }

    if is_mobile then
        local vp = camera.ViewportSize
        cfg.size = dim2(0, clamp(vp.X * 0.85, 320, 420), 0, clamp(vp.Y * 0.7, 260, 380))
    end

    library.gui = library:create("ScreenGui", {
        Parent = coregui, Name = "\0", Enabled = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true,
    })

    local us = Instance.new("UIScale")
    us.Scale = UI_SCALE; us.Parent = library.gui

    library:connection(camera:GetPropertyChangedSignal("ViewportSize"), function()
        UI_SCALE = get_ui_scale()
        if us then us.Scale = UI_SCALE end
    end)

    local main = library:create("Frame", {
        Parent = library.gui, BackgroundTransparency = 1,
        Position = dim2(0.5, -cfg.size.X.Offset / 2, 0.5, -cfg.size.Y.Offset / 2),
        Size = cfg.size, BorderSizePixel = 0,
    })
    apply_corner(main, 8)
    library:resizify(main); library:draggify(main)

    local outer = library:create("Frame", {
        Parent = main, BackgroundColor3 = themes.preset.a,
        BorderSizePixel = 0, Size = dim2(1, 0, 1, 0),
    })
    apply_corner(outer, 8)
    library:apply_theme(outer, "a", "BackgroundColor3")

    local panel = library:create("Frame", {
        Parent = outer, BackgroundColor3 = themes.preset.b,
        BorderSizePixel = 0, Position = dim2(0, 1, 0, 1),
        Size = dim2(1, -2, 1, -2),
    })
    apply_corner(panel, 7)
    library:apply_theme(panel, "b", "BackgroundColor3")

    local header_h = 26

    local header = library:create("Frame", {
        Parent = panel, BackgroundColor3 = themes.preset.header,
        BorderSizePixel = 0, Size = dim2(1, 0, 0, header_h),
    })
    apply_corner(header, 7)
    library:apply_theme(header, "header", "BackgroundColor3")

    library:create("Frame", {
        Parent = header, BackgroundColor3 = themes.preset.header,
        BorderSizePixel = 0, Position = dim2(0, 0, 1, -6), Size = dim2(1, 0, 0, 6), ZIndex = 1,
    })

    library:create("TextLabel", {
        Parent = header, BackgroundTransparency = 1, FontFace = library.font,
        Text = "◈", TextColor3 = themes.preset.accent, TextSize = 16,
        Position = dim2(0, 10, 0, 0), Size = dim2(0, 16, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 3,
    })

    library:create("TextLabel", {
        Parent = header, BackgroundTransparency = 1, FontFace = library.font,
        Text = cfg.name:lower(), TextColor3 = themes.preset.text, TextSize = 12,
        Position = dim2(0, 30, 0, 0), Size = dim2(0, 200, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3,
    })

    local close = library:create("TextButton", {
        Parent = header, BackgroundColor3 = themes.preset.b,
        BorderSizePixel = 0, Text = "X", FontFace = library.font,
        TextColor3 = themes.preset.text_dim, TextSize = 11,
        Position = dim2(1, -20, 0, 5), Size = dim2(0, 15, 0, 15),
        ZIndex = 3, AutoButtonColor = false,
    })
    apply_corner(close, 4)
    close.MouseEnter:Connect(function()
        tween_service:Create(close, TweenInfo.new(0.15), {BackgroundColor3 = themes.preset.accent_alt, TextColor3 = rgb(255,255,255)}):Play()
    end)
    close.MouseLeave:Connect(function()
        tween_service:Create(close, TweenInfo.new(0.15), {BackgroundColor3 = themes.preset.b, TextColor3 = themes.preset.text_dim}):Play()
    end)
    close.MouseButton1Click:Connect(function() library:unload_menu() end)

    library:create("Frame", {
        Parent = panel, BackgroundColor3 = themes.preset.border,
        BorderSizePixel = 0, Position = dim2(0, 0, 0, header_h),
        Size = dim2(1, 0, 0, 1), ZIndex = 3,
    })

    local icon_w = is_mobile and 32 or 34

    local sidebar = library:create("Frame", {
        Parent = panel, BackgroundColor3 = themes.preset.a,
        BorderSizePixel = 0, Position = dim2(0, 0, 0, header_h + 1),
        Size = dim2(0, icon_w, 1, -(header_h + 1)),
    })
    library:apply_theme(sidebar, "a", "BackgroundColor3")

    library:create("UIListLayout", {
        Parent = sidebar, Padding = dim(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    })
    library:create("UIPadding", { Parent = sidebar, PaddingTop = dim(0, 6) })

    library:create("Frame", {
        Parent = panel, BackgroundColor3 = themes.preset.border,
        BorderSizePixel = 0, Position = dim2(0, icon_w, 0, header_h + 1),
        Size = dim2(0, 1, 1, -(header_h + 1)), ZIndex = 3,
    })

    local content = library:create("Frame", {
        Parent = panel, BackgroundTransparency = 1,
        Position = dim2(0, icon_w + 1, 0, header_h + 1),
        Size = dim2(1, -(icon_w + 1), 1, -(header_h + 1)),
        BorderSizePixel = 0,
    })

    cfg.icon_holder = sidebar
    cfg.content = content
    cfg.panel = panel
    cfg.header = header

    return setmetatable(cfg, library)
end

-- =========================================================
-- TAB
-- =========================================================
function library:tab(props)
    local cfg = {
        name = props.name or "tab",
        icon = props.icon or nil,
        subtabs = {},
        selected_sub,
    }

    local icon_size = is_mobile and 24 or 26
    insert(self.tabs, cfg)

    local btn = library:create("TextButton", {
        Parent = self.icon_holder, BackgroundColor3 = themes.preset.b,
        BorderSizePixel = 0, Size = dim2(0, icon_size, 0, icon_size),
        Text = "", AutoButtonColor = false,
        LayoutOrder = #self.tabs,
    })
    apply_corner(btn, 5)

    local bar = library:create("Frame", {
        Parent = btn, BackgroundColor3 = themes.preset.accent,
        BorderSizePixel = 0, Position = dim2(0, -5, 0.5, -6),
        Size = dim2(0, 2, 0, 12), Visible = false, ZIndex = 5,
    })
    apply_corner(bar, 1)
    library:apply_theme(bar, "accent", "BackgroundColor3")

    local icon_img, icon_text
    if cfg.icon and tostring(cfg.icon):find("rbxassetid") then
        icon_img = library:create("ImageLabel", {
            Parent = btn, BackgroundTransparency = 1, Image = cfg.icon,
            ImageColor3 = themes.preset.text_dim,
            Size = dim2(0, icon_size - 12, 0, icon_size - 12),
            Position = dim2(0.5, -(icon_size - 12) / 2, 0.5, -(icon_size - 12) / 2),
            BorderSizePixel = 0, ZIndex = 2,
        })
    else
        icon_text = library:create("TextLabel", {
            Parent = btn, BackgroundTransparency = 1, FontFace = library.font,
            Text = cfg.icon or cfg.name:sub(1, 1):upper(),
            TextColor3 = themes.preset.text_dim,
            TextSize = is_mobile and 10 or 11,
            Size = dim2(1, 0, 1, 0), BorderSizePixel = 0, ZIndex = 2,
        })
    end

    local page = library:create("Frame", {
        Parent = self.content, BackgroundTransparency = 1,
        Size = dim2(1, 0, 1, 0), Visible = false, BorderSizePixel = 0,
    })
    cfg.page = page

    local sub_bar = library:create("Frame", {
        Parent = page, BackgroundTransparency = 1,
        Size = dim2(1, 0, 0, 24), BorderSizePixel = 0,
    })
    library:create("UIListLayout", {
        Parent = sub_bar, FillDirection = Enum.FillDirection.Horizontal,
        Padding = dim(0, 4), SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    })
    library:create("UIPadding", { Parent = sub_bar, PaddingLeft = dim(0, 6), PaddingTop = dim(0, 4) })
    cfg.sub_bar = sub_bar

    local sub_holder = library:create("Frame", {
        Parent = page, BackgroundTransparency = 1,
        Position = dim2(0, 0, 0, 26), Size = dim2(1, 0, 1, -26),
        BorderSizePixel = 0,
    })
    cfg.sub_holder = sub_holder

    function cfg.open_tab()
        if self.selected_tab then
            local p = self.selected_tab
            p.page.Visible = false
            p.btn.BackgroundColor3 = themes.preset.b
            p.bar.Visible = false
            if p.icon_img then p.icon_img.ImageColor3 = themes.preset.text_dim end
            if p.icon_text then p.icon_text.TextColor3 = themes.preset.text_dim end
        end
        page.Visible = true
        btn.BackgroundColor3 = themes.preset.c
        bar.Visible = true
        if icon_img then icon_img.ImageColor3 = themes.preset.accent end
        if icon_text then icon_text.TextColor3 = themes.preset.accent end
        self.selected_tab = cfg

        if not cfg.selected_sub and #cfg.subtabs > 0 then
            cfg.subtabs[1].open()
        end
    end

    cfg.btn = btn; cfg.bar = bar
    cfg.icon_img = icon_img; cfg.icon_text = icon_text

    btn.MouseButton1Down:Connect(function() cfg.open_tab() end)
    btn.MouseEnter:Connect(function()
        if self.selected_tab ~= cfg then btn.BackgroundColor3 = themes.preset.c end
    end)
    btn.MouseLeave:Connect(function()
        if self.selected_tab ~= cfg then btn.BackgroundColor3 = themes.preset.b end
    end)

    function cfg:subtab(p)
        local sub = { name = p.name or "sub", label = p.label or p.name or "?" }

        local badge = library:create("TextButton", {
            Parent = sub_bar, BackgroundColor3 = themes.preset.c,
            BorderSizePixel = 0,
            Size = dim2(0, 18, 0, 14),
            Text = string.upper(sub.label:sub(1, 1)),
            FontFace = library.font,
            TextColor3 = themes.preset.text_dim,
            TextSize = 10,
            AutoButtonColor = false,
            LayoutOrder = #cfg.subtabs + 1,
        })
        apply_corner(badge, 3)

        local line = library:create("Frame", {
            Parent = badge, BackgroundColor3 = themes.preset.accent,
            BorderSizePixel = 0, Position = dim2(0, 0, 1, -1),
            Size = dim2(1, 0, 0, 1), Visible = false,
        })
        apply_corner(line, 1)
        library:apply_theme(line, "accent", "BackgroundColor3")

        local sp = library:create("Frame", {
            Parent = sub_holder, BackgroundTransparency = 1,
            Size = dim2(1, 0, 1, 0), Visible = false, BorderSizePixel = 0,
        })
        library:create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Parent = sp, Padding = dim(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalFlex = Enum.UIFlexAlignment.Fill,
        })
        library:create("UIPadding", {
            PaddingTop = dim(0, 4), PaddingBottom = dim(0, 6),
            Parent = sp, PaddingRight = dim(0, 6), PaddingLeft = dim(0, 6),
        })

        local left = library:create("Frame", { Parent = sp, BackgroundTransparency = 1, BorderSizePixel = 0 })
        library:create("UIListLayout", {
            Parent = left, Padding = dim(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            VerticalFlex = Enum.UIFlexAlignment.Fill,
        })
        local right = library:create("Frame", { Parent = sp, BackgroundTransparency = 1, BorderSizePixel = 0 })
        library:create("UIListLayout", {
            Parent = right, Padding = dim(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            VerticalFlex = Enum.UIFlexAlignment.Fill,
        })

        sub.left = left; sub.right = right; sub.page = sp
        sub.badge = badge; sub.line = line
        sub.parent_tab = cfg

        function sub.open()
            if cfg.selected_sub then
                cfg.selected_sub.page.Visible = false
                cfg.selected_sub.line.Visible = false
                cfg.selected_sub.badge.BackgroundColor3 = themes.preset.c
                cfg.selected_sub.badge.TextColor3 = themes.preset.text_dim
            end
            sp.Visible = true
            line.Visible = true
            badge.BackgroundColor3 = themes.preset.accent
            badge.TextColor3 = rgb(255, 255, 255)
            cfg.selected_sub = sub
        end

        badge.MouseButton1Down:Connect(function() sub.open() end)
        insert(cfg.subtabs, sub)

        return setmetatable(sub, {__index = library})
    end

    if not self.selected_tab then cfg.open_tab() end

    return setmetatable(cfg, library)
end

-- =========================================================
-- SECTION
-- =========================================================
function library:section(props, parent_sub)
    local cfg = {
        name = props.name or "section",
        side = props.side or "left",
        label = props.label or "A",
    }

    local parent = parent_sub and parent_sub[cfg.side] or self[cfg.side]
    if not parent then parent = self.elements end

    local section = library:create("Frame", {
        Parent = parent, BackgroundTransparency = 1,
        BorderSizePixel = 0, Size = dim2(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })

    local a = library:create("Frame", {
        Parent = section, BorderSizePixel = 0,
        BackgroundColor3 = themes.preset.a,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = dim2(1, 0, 0, 0),
    })
    apply_corner(a, 5)
    library:apply_theme(a, "a", "BackgroundColor3")

    local c = library:create("Frame", {
        Parent = a, Position = dim2(0, 1, 0, 1),
        BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.Y,
        Size = dim2(1, -2, 0, 0), BackgroundColor3 = themes.preset.c,
    })
    apply_corner(c, 4)
    library:apply_theme(c, "c", "BackgroundColor3")

    local header = library:create("Frame", {
        Parent = c, BackgroundTransparency = 1,
        Size = dim2(1, 0, 0, 20), ZIndex = 2,
    })

    local badge = library:create("Frame", {
        Parent = header, BackgroundColor3 = themes.preset.a,
        BorderSizePixel = 0,
        Position = dim2(0, 6, 0, 5),
        Size = dim2(0, 12, 0, 12),
        ZIndex = 4,
    })
    apply_corner(badge, 3)

    library:create("TextLabel", {
        Parent = badge, BackgroundTransparency = 1,
        FontFace = library.font, Text = cfg.label,
        TextColor3 = themes.preset.text_dim, TextSize = 9,
        Size = dim2(1, 0, 1, 0), ZIndex = 5,
    })

    library:create("TextLabel", {
        Parent = header, BackgroundTransparency = 1,
        FontFace = library.font, Text = cfg.name,
        TextColor3 = themes.preset.text, TextSize = 10,
        Size = dim2(1, -30, 1, 0),
        Position = dim2(0, 24, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    })

    local scrolling = library:create("ScrollingFrame", {
        Parent = c, BackgroundTransparency = 1,
        Position = dim2(0, 0, 0, 20),
        Size = dim2(1, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = dim2(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = themes.preset.accent,
        BorderSizePixel = 0, ZIndex = 2,
    })
    library:apply_theme(scrolling, "accent", "ScrollBarImageColor3")

    local elements = library:create("Frame", {
        Parent = scrolling, BackgroundTransparency = 1,
        Position = dim2(0, 5, 0, 3),
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = dim2(1, -10, 0, 0), BorderSizePixel = 0,
    })
    cfg.elements = elements

    local layout = library:create("UIListLayout", {
        Parent = elements, Padding = dim(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    library:create("UIPadding", { PaddingBottom = dim(0, 5), Parent = elements })

    local function update()
        local h = layout.AbsoluteContentSize.Y + 8
        a.Size = dim2(1, 0, 0, 20 + h)
        c.Size = dim2(1, -2, 0, 20 + h)
        scrolling.Size = dim2(1, 0, 0, h)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
    task.defer(update)

    return setmetatable(cfg, library)
end

-- =========================================================
-- ELEMENTS
-- =========================================================

function library:label(options)
    local cfg = { name = options.name or "label" }
    local label = library:create("Frame", {
        Parent = self.elements, BackgroundTransparency = 1,
        Size = dim2(1, 0, 0, 12), BorderSizePixel = 0,
    })
    library:create("TextLabel", {
        FontFace = library.font, TextColor3 = themes.preset.text_dim,
        Text = cfg.name, Parent = label,
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 10, BorderSizePixel = 0,
    })
    local right = library:create("Frame", {
        Parent = label, Position = dim2(1, 0, 0, 0),
        BackgroundTransparency = 1, Size = dim2(0, 0, 1, 0), BorderSizePixel = 0,
    })
    cfg.right_components = right
    library:create("UIListLayout", {
        Parent = right, Padding = dim(0, 3),
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    return setmetatable(cfg, library)
end

function library:toggle(options)
    local cfg = {
        name = options.name or "Toggle",
        flag = options.flag or tostring(random(1, 9999999)),
        default = options.value or options.default or false,
        callback = options.callback or function() end,
    }

    local row = library:create("TextButton", {
        Parent = self.elements, BackgroundTransparency = 1,
        Size = dim2(1, 0, 0, is_mobile and 18 or 14), BorderSizePixel = 0,
        Text = "", AutoButtonColor = false,
    })

    library:create("TextLabel", {
        FontFace = library.font, TextColor3 = themes.preset.text,
        Text = cfg.name, Parent = row,
        AutomaticSize = Enum.AutomaticSize.XY,
        Position = dim2(0, 0, 0, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 10, BorderSizePixel = 0, ZIndex = 2,
    })

    local box_s = is_mobile and 12 or 10
    local box = library:create("Frame", {
        Parent = row, Position = dim2(1, -box_s, 0, 2),
        Size = dim2(0, box_s, 0, box_s),
        BorderSizePixel = 0, BackgroundColor3 = themes.preset.d,
    })
    apply_corner(box, 2)
    library:apply_theme(box, "d", "BackgroundColor3")

    local check = library:create("Frame", {
        Parent = box, Position = dim2(0.5, -3, 0.5, -3),
        Size = dim2(0, 6, 0, 6),
        BorderSizePixel = 0, BackgroundColor3 = themes.preset.accent,
        Visible = false,
    })
    apply_corner(check, 2)
    library:apply_theme(check, "accent", "BackgroundColor3")

    function cfg.set(v)
        check.Visible = v
        cfg.enabled = v
        cfg.callback(v)
    end
    cfg.set(cfg.default)
    config_flags[cfg.flag] = cfg.set
    flags[cfg.flag] = cfg.default

    row.MouseButton1Click:Connect(function()
        cfg.enabled = not cfg.enabled
        cfg.set(cfg.enabled)
    end)
    return setmetatable(cfg, library)
end

function library:slider(options)
    local cfg = {
        name = options.name or "Slider",
        suffix = options.suffix or "",
        flag = options.flag or tostring(2^789),
        callback = options.callback or function() end,
        min = options.min or 0,
        max = options.max or 100,
        intervals = options.interval or 1,
        default = options.value or options.default or 10,
        dragging = false,
    }

    local row_h = is_mobile and 34 or 28
    local obj = library:create("Frame", {
        Parent = self.elements, BackgroundTransparency = 1,
        Size = dim2(1, 0, 0, row_h), BorderSizePixel = 0,
    })

    library:create("TextLabel", {
        FontFace = library.font, TextColor3 = themes.preset.text,
        Text = cfg.name, Parent = obj,
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 10, BorderSizePixel = 0, ZIndex = 2,
    })

    local val = library:create("TextLabel", {
        FontFace = library.font, TextColor3 = themes.preset.accent,
        Text = tostring(cfg.default) .. cfg.suffix,
        Parent = obj, AutomaticSize = Enum.AutomaticSize.XY,
        AnchorPoint = vec2(1, 0), Position = dim2(1, 0, 0, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextSize = 10, BorderSizePixel = 0, ZIndex = 2,
    })
    library:apply_theme(val, "accent", "TextColor3")

    local track = library:create("TextButton", {
        Parent = obj, Position = dim2(0, 0, 0, 14),
        BorderSizePixel = 0,
        Size = dim2(1, 0, 0, is_mobile and 10 or 6),
        AutoButtonColor = false, Text = "",
        BackgroundColor3 = themes.preset.d,
    })
    apply_corner(track, 3)
    library:apply_theme(track, "d", "BackgroundColor3")

    local bg = library:create("Frame", {
        Parent = track, Position = dim2(0, 1, 0, 1),
        BorderSizePixel = 0, Size = dim2(1, -2, 1, -2),
        BackgroundColor3 = themes.preset.e,
    })
    apply_corner(bg, 3)
    library:apply_theme(bg, "e", "BackgroundColor3")

    local fill = library:create("Frame", {
        Parent = bg, BorderSizePixel = 0,
        Size = dim2(0.5, 0, 1, 0),
        BackgroundColor3 = themes.preset.accent,
    })
    apply_corner(fill, 3)
    library:apply_theme(fill, "accent", "BackgroundColor3")

    function cfg.set(v)
        local n = tonumber(v); if not n then return end
        cfg.value = clamp(library:round(n, cfg.intervals), cfg.min, cfg.max)
        fill.Size = dim2((cfg.value - cfg.min) / (cfg.max - cfg.min), 0, 1, 0)
        val.Text = tostring(cfg.value) .. cfg.suffix
        flags[cfg.flag] = cfg.value
        cfg.callback(cfg.value)
    end

    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            cfg.dragging = true
            local sx = (i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            cfg.set(((cfg.max - cfg.min) * sx) + cfg.min)
        end
    end)
    library:connection(uis.InputChanged, function(i)
        if cfg.dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local sx = (i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            cfg.set(((cfg.max - cfg.min) * sx) + cfg.min)
        end
    end)
    library:connection(uis.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            cfg.dragging = false
        end
    end)

    cfg.set(cfg.default)
    config_flags[cfg.flag] = cfg.set
    return setmetatable(cfg, library)
end

function library:button(options)
    local cfg = {
        name = options.name or "Button",
        callback = options.callback or function() end,
    }

    local btn = library:create("TextButton", {
        Parent = self.elements, Text = "",
        BorderSizePixel = 0,
        Size = dim2(1, 0, 0, is_mobile and 22 or 18),
        BackgroundColor3 = themes.preset.d, AutoButtonColor = false,
    })
    apply_corner(btn, 3)
    library:apply_theme(btn, "d", "BackgroundColor3")

    local inl = library:create("Frame", {
        Parent = btn, Position = dim2(0, 1, 0, 1),
        BorderSizePixel = 0, Size = dim2(1, -2, 1, -2),
        BackgroundColor3 = themes.preset.e,
    })
    apply_corner(inl, 3)
    library:apply_theme(inl, "e", "BackgroundColor3")

    library:create("TextLabel", {
        FontFace = library.font, TextColor3 = themes.preset.text,
        Text = cfg.name, Parent = inl, BackgroundTransparency = 1,
        Size = dim2(1, 0, 1, 0), BorderSizePixel = 0, TextSize = 10,
    })

    btn.MouseEnter:Connect(function() inl.BackgroundColor3 = themes.preset.g end)
    btn.MouseLeave:Connect(function() inl.BackgroundColor3 = themes.preset.e end)
    btn.MouseButton1Click:Connect(function() cfg.callback() end)
    return setmetatable(cfg, library)
end

function library:dropdown(options)
    local cfg = {
        name = options.name or "Dropdown",
        flag = options.flag or tostring(random(1, 9999999)),
        items = options.items or {""},
        callback = options.callback or function() end,
        multi = options.multi or false,
        open = false,
        option_instances = {},
        multi_items = {},
    }
    cfg.default = options.value or options.default or (cfg.multi and {cfg.items[1]}) or cfg.items[1] or "None"
    flags[cfg.flag] = {}

    local row_h = is_mobile and 36 or 30
    local obj = library:create("Frame", {
        Parent = self.elements, BackgroundTransparency = 1,
        Size = dim2(1, 0, 0, row_h), BorderSizePixel = 0,
    })

    library:create("TextLabel", {
        FontFace = library.font, TextColor3 = themes.preset.text,
        Text = cfg.name, Parent = obj,
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 10, BorderSizePixel = 0,
    })

    local holder = library:create("TextButton", {
        Parent = obj, Text = "", Position = dim2(0, 0, 0, 14),
        BorderSizePixel = 0,
        Size = dim2(1, 0, 0, is_mobile and 18 or 14),
        BackgroundColor3 = themes.preset.d, AutoButtonColor = false,
    })
    apply_corner(holder, 3)
    library:apply_theme(holder, "d", "BackgroundColor3")

    local inl = library:create("Frame", {
        Parent = holder, Position = dim2(0, 1, 0, 1),
        BorderSizePixel = 0, Size = dim2(1, -2, 1, -2),
        BackgroundColor3 = themes.preset.e,
    })
    apply_corner(inl, 3)
    library:apply_theme(inl, "e", "BackgroundColor3")

    local txt = library:create("TextLabel", {
        FontFace = library.font, Parent = inl,
        TextColor3 = themes.preset.text, Text = "ERROR",
        Size = dim2(1, -16, 1, 0), Position = dim2(0, 5, 0, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 10, BorderSizePixel = 0, ZIndex = 2,
    })

    local arrow = library:create("TextLabel", {
        FontFace = library.font, Parent = inl,
        TextColor3 = themes.preset.text_dim, Text = "v",
        Size = dim2(0, 12, 1, 0), Position = dim2(1, -13, 0, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextSize = 10, BorderSizePixel = 0, ZIndex = 2,
    })

    local items = library:create("Frame", {
        Parent = library.gui, Visible = false, BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y, Size = dim2(0, 120, 0, 0),
        BackgroundColor3 = themes.preset.a, ZIndex = 100,
    })
    apply_corner(items, 4)
    library:apply_theme(items, "a", "BackgroundColor3")

    local hi = library:create("Frame", {
        Parent = items, Size = dim2(1, -2, 0, 0),
        Position = dim2(0, 1, 0, 1), BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = themes.preset.c, ZIndex = 101,
    })
    apply_corner(hi, 3)
    library:apply_theme(hi, "c", "BackgroundColor3")

    library:create("UIListLayout", { Parent = hi, Padding = dim(0, 1), SortOrder = Enum.SortOrder.LayoutOrder })
    library:create("UIPadding", {
        PaddingTop = dim(0, 3), PaddingBottom = dim(0, 3),
        PaddingLeft = dim(0, 3), PaddingRight = dim(0, 3), Parent = hi,
    })

    function cfg.set_visible(b) items.Visible = b; arrow.Text = b and "^" or "v" end

    function cfg.set(v)
        local sel = {}
        local isT = type(v) == "table"
        if v == nil then return end
        for _, opt in next, cfg.option_instances do
            if opt.Text == v or (isT and find(v, opt.Text)) then
                insert(sel, opt.Text); cfg.multi_items = sel
                opt.TextColor3 = themes.preset.accent
            else
                opt.TextColor3 = themes.preset.text
            end
        end
        txt.Text = if isT then concat(sel, ", ") else (sel[1] or "None")
        flags[cfg.flag] = if isT then sel else sel[1]
        cfg.callback(flags[cfg.flag])
    end

    function cfg.refresh_options(list)
        for _, o in next, cfg.option_instances do o:Destroy() end
        cfg.option_instances = {}
        for _, o in next, list do
            local btn = library:create("TextButton", {
                FontFace = library.font, TextColor3 = themes.preset.text,
                BorderSizePixel = 0, Text = o, Parent = hi,
                Size = dim2(1, 0, 0, is_mobile and 18 or 14),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextSize = 10, AutoButtonColor = false, ZIndex = 102,
            })
            insert(cfg.option_instances, btn)
            btn.MouseButton1Down:Connect(function()
                if cfg.multi then
                    local idx = find(cfg.multi_items, btn.Text)
                    if idx then remove(cfg.multi_items, idx) else insert(cfg.multi_items, btn.Text) end
                    cfg.set(cfg.multi_items)
                else
                    cfg.set_visible(false); cfg.open = false; cfg.set(btn.Text)
                end
            end)
        end
    end

    cfg.refresh_options(cfg.items)
    cfg.set(cfg.default)
    config_flags[cfg.flag] = cfg.set

    holder.MouseButton1Click:Connect(function()
        cfg.open = not cfg.open
        items.Size = dim2(0, holder.AbsoluteSize.X, 0, items.Size.Y.Offset)
        items.Position = dim_offset(holder.AbsolutePosition.X, holder.AbsolutePosition.Y + holder.AbsoluteSize.Y + 2)
        cfg.set_visible(cfg.open)
    end)

    library:connection(uis.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            if not (library:mouse_in_frame(items) or library:mouse_in_frame(holder)) then
                cfg.open = false; cfg.set_visible(false)
            end
        end
    end)

    return setmetatable(cfg, library)
end

function library:textbox(options)
    local cfg = {
        name = options.name or "TextBox",
        placeholder = options.placeholder or "type...",
        default = options.value or options.default,
        flag = options.flag or "flag",
        callback = options.callback or function() end,
    }
    local obj = library:create("Frame", {
        Parent = self.elements, BackgroundTransparency = 1,
        Size = dim2(1, 0, 0, is_mobile and 36 or 30), BorderSizePixel = 0,
    })
    library:create("TextLabel", {
        FontFace = library.font, TextColor3 = themes.preset.text,
        Text = cfg.name, Parent = obj,
        AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 10, BorderSizePixel = 0,
    })
    local box = library:create("Frame", {
        Parent = obj, Position = dim2(0, 0, 0, 14),
        BorderSizePixel = 0, Size = dim2(1, 0, 0, is_mobile and 18 or 14),
        BackgroundColor3 = themes.preset.d,
    })
    apply_corner(box, 3)
    library:apply_theme(box, "d", "BackgroundColor3")

    local inl = library:create("Frame", {
        Parent = box, Position = dim2(0, 1, 0, 1),
        BorderSizePixel = 0, Size = dim2(1, -2, 1, -2),
        BackgroundColor3 = themes.preset.e,
    })
    apply_corner(inl, 3)
    library:apply_theme(inl, "e", "BackgroundColor3")

    local input = library:create("TextBox", {
        FontFace = library.font, TextColor3 = themes.preset.text,
        BorderSizePixel = 0, Text = "", Parent = inl,
        BackgroundTransparency = 1,
        PlaceholderColor3 = themes.preset.text_dim,
        PlaceholderText = cfg.placeholder,
        Size = dim2(1, -10, 1, 0), Position = dim2(0, 5, 0, 0),
        TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left,
    })

    function cfg.set(t) flags[cfg.flag] = t; input.Text = t; cfg.callback(t) end
    config_flags[cfg.flag] = cfg.set
    if cfg.default then cfg.set(cfg.default) end
    input.FocusLost:Connect(function() cfg.set(input.Text) end)
    return setmetatable(cfg, library)
end

function library:keybind(options)
    local cfg = {
        flag = options.flag or "kb_flag",
        callback = options.callback or function() end,
        name = options.name or nil,
        key = options.key or nil,
        mode = options.mode or "Hold",
        active = options.default or false,
        hold_instances = {},
        open = false,
        binding = nil,
    }
    flags[cfg.flag] = {}

    if not self.right_components then
        cfg.label = self:label({name = cfg.name or "Keybind"})
    end

    local element = library:create("TextButton", {
        Parent = self.right_components or cfg.label.right_components,
        Size = dim2(0, 48, 0, 12), BorderSizePixel = 0, Text = "",
        AutoButtonColor = false, BackgroundColor3 = themes.preset.d,
    })
    apply_corner(element, 3)
    library:apply_theme(element, "d", "BackgroundColor3")

    local inl = library:create("Frame", {
        Parent = element, Size = dim2(1, -2, 1, -2),
        Position = dim2(0, 1, 0, 1), BorderSizePixel = 0,
        BackgroundColor3 = themes.preset.e,
    })
    apply_corner(inl, 3)
    library:apply_theme(inl, "e", "BackgroundColor3")

    local key_text = library:create("TextLabel", {
        FontFace = library.font, TextColor3 = themes.preset.text,
        BorderSizePixel = 0, Text = "...", Parent = inl,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center,
        Size = dim2(1, 0, 1, 0), TextSize = 10, ZIndex = 2,
    })

    local popup = library:create("Frame", {
        Parent = library.gui, Visible = false, BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = themes.preset.a, ZIndex = 100,
    })
    apply_corner(popup, 4)
    library:apply_theme(popup, "a", "BackgroundColor3")

    local ph = library:create("Frame", {
        Parent = popup, Position = dim2(0, 1, 0, 1),
        BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = themes.preset.c, ZIndex = 101,
    })
    apply_corner(ph, 3)
    library:apply_theme(ph, "c", "BackgroundColor3")
    library:create("UIListLayout", { Parent = ph, Padding = dim(0, 2), SortOrder = Enum.SortOrder.LayoutOrder })
    library:create("UIPadding", {
        PaddingTop = dim(0, 3), PaddingBottom = dim(0, 3),
        PaddingLeft = dim(0, 6), PaddingRight = dim(0, 6), Parent = ph,
    })

    for _, m in {"Hold", "Toggle", "Always"} do
        local o = library:create("TextButton", {
            FontFace = library.font, TextColor3 = themes.preset.text,
            BorderSizePixel = 0, Text = m, Parent = ph,
            BackgroundTransparency = 1, Size = dim2(0, 45, 0, 12),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 10, AutoButtonColor = false, ZIndex = 102,
        })
        cfg.hold_instances[m] = o
        o.MouseButton1Click:Connect(function()
            cfg.set(m); cfg.set_visible(false); cfg.open = false
        end)
    end

    function cfg.modify_mode_color(mode)
        for _, v in ph:GetChildren() do
            if v:IsA("TextButton") then v.TextColor3 = themes.preset.text end
        end
        if cfg.hold_instances[mode] then cfg.hold_instances[mode].TextColor3 = themes.preset.accent end
    end

    function cfg.set_mode(mode)
        cfg.mode = mode
        if mode == "Always" then cfg.set(true) elseif mode == "Hold" then cfg.set(false) end
        flags[cfg.flag]["mode"] = mode
        cfg.modify_mode_color(mode)
    end

    function cfg.set(input)
        if type(input) == "boolean" then
            local c = input
            if cfg.mode == "Always" then c = true end
            cfg.active = c; cfg.callback(c)
        elseif tostring(input):find("Enum") then
            input = input.Name == "Escape" and "..." or input
            cfg.key = input or "..."
            cfg.callback(cfg.active or false)
        elseif find({"Toggle", "Hold", "Always"}, input) then
            cfg.set_mode(input)
            if input == "Always" then cfg.active = true end
            cfg.callback(cfg.active or false)
        elseif type(input) == "table" then
            input.key = type(input.key) == "string" and input.key ~= "..." and library:convert_enum(input.key) or input.key
            input.key = input.key == Enum.KeyCode.Escape and "..." or input.key
            cfg.key = input.key or "..."
            cfg.mode = input.mode or "Toggle"
            cfg.set_mode(input.mode)
            if input.active then cfg.active = input.active end
        end
        flags[cfg.flag] = {mode = cfg.mode, key = cfg.key, active = cfg.active}
        local t = tostring(cfg.key) ~= "Enums" and (keys[cfg.key] or tostring(cfg.key):gsub("Enum.", "")) or nil
        local tt = t and (tostring(t):gsub("KeyCode.", ""):gsub("UserInputType.", ""))
        key_text.Text = tt and (" " .. tt .. " ") or "..."
        key_text.TextColor3 = cfg.active and themes.preset.accent or themes.preset.text
    end

    function cfg.set_visible(b)
        popup.Visible = b
        popup.Position = dim_offset(element.AbsolutePosition.X - 20, element.AbsolutePosition.Y + element.AbsoluteSize.Y + 2)
    end

    element.MouseButton1Down:Connect(function()
        task.wait()
        key_text.Text = "..."
        cfg.binding = library:connection(uis.InputBegan, function(kc)
            cfg.set(kc.KeyCode or kc.UserInputType)
            if cfg.binding then cfg.binding:Disconnect(); cfg.binding = nil end
        end)
    end)
    element.MouseButton2Down:Connect(function()
        cfg.open = not cfg.open; cfg.set_visible(cfg.open)
    end)

    library:connection(uis.InputBegan, function(i, g)
        if not g and i.KeyCode == cfg.key then
            if cfg.mode == "Toggle" then cfg.active = not cfg.active; cfg.set(cfg.active)
            elseif cfg.mode == "Hold" then cfg.set(true) end
        end
    end)
    library:connection(uis.InputEnded, function(i, g)
        if g then return end
        local sk = i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode or i.UserInputType
        if sk == cfg.key and cfg.mode == "Hold" then cfg.set(false) end
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            if not (library:mouse_in_frame(element) or library:mouse_in_frame(ph)) then
                cfg.open = false; cfg.set_visible(false)
            end
        end
    end)

    config_flags[cfg.flag] = cfg.set
    cfg.set({mode = cfg.mode, active = cfg.active, key = cfg.key})
    cfg.modify_mode_color(cfg.mode)
    return setmetatable(cfg, library)
end

function library:colorpicker(options)
    local cfg = {
        name = options.name or "Color",
        flag = options.flag or tostring(2^789),
        color = options.color or color(1, 1, 1),
        alpha = options.alpha and 1 - options.alpha or 0,
        open = false,
        callback = options.callback or function() end,
    }
    if not self.right_components then
        cfg.label = self:label({name = cfg.name})
    end
    local element = library:create("TextButton", {
        Parent = self.right_components or cfg.label.right_components,
        BorderSizePixel = 0, Size = dim2(0, 24, 0, 12), Text = "",
        AutoButtonColor = false, BackgroundColor3 = themes.preset.d,
    })
    apply_corner(element, 3)
    library:apply_theme(element, "d", "BackgroundColor3")
    local ec = library:create("Frame", {
        Parent = element, Position = dim2(0, 1, 0, 1),
        BorderSizePixel = 0, Size = dim2(1, -2, 1, -2),
        BackgroundColor3 = rgb(255, 194, 11),
    })
    apply_corner(ec, 2)

    local picker = library:create("Frame", {
        Parent = library.gui, BorderSizePixel = 0, Visible = false,
        Size = dim2(0, 170, 0, 150), BackgroundColor3 = themes.preset.a, ZIndex = 50,
    })
    apply_corner(picker, 5)
    library:apply_theme(picker, "a", "BackgroundColor3")

    local inner = library:create("Frame", {
        Parent = picker, Position = dim2(0, 1, 0, 1),
        BorderSizePixel = 0, Size = dim2(1, -2, 1, -2),
        BackgroundColor3 = themes.preset.c, ZIndex = 51,
    })
    apply_corner(inner, 4)
    library:apply_theme(inner, "c", "BackgroundColor3")
    library:create("UIPadding", {
        PaddingTop = dim(0, 5), PaddingBottom = dim(0, 5),
        PaddingLeft = dim(0, 5), PaddingRight = dim(0, 5), Parent = inner,
    })

    local sv = library:create("TextButton", {
        Parent = inner, BorderSizePixel = 0,
        Size = dim2(1, -18, 0, 95), Text = "",
        AutoButtonColor = false, BackgroundColor3 = rgb(255, 0, 0), ZIndex = 52,
    })
    apply_corner(sv, 3)

    local svv = library:create("Frame", {
        Parent = sv, BorderSizePixel = 0,
        Size = dim2(1, 0, 1, 0), BackgroundColor3 = rgb(255, 255, 255), ZIndex = 53,
    })
    apply_corner(svv, 3)
    library:create("UIGradient", { Parent = svv, Transparency = numseq{numkey(0, 0), numkey(1, 1)} })

    local svs = library:create("TextButton", {
        Parent = sv, Text = "", AutoButtonColor = false,
        BorderSizePixel = 0, Size = dim2(1, 0, 1, 0),
        BackgroundColor3 = rgb(255, 255, 255), ZIndex = 55,
    })
    library:create("UIGradient", {
        Rotation = 270, Transparency = numseq{numkey(0, 0), numkey(1, 1)},
        Color = rgbseq{rgbkey(0, rgb(0,0,0)), rgbkey(1, rgb(0,0,0))}, Parent = svs,
    })

    local svp = library:create("Frame", {
        Parent = sv, BorderColor3 = rgb(255,255,255), BorderSizePixel = 2,
        Size = dim2(0, 5, 0, 5), BackgroundColor3 = rgb(0,0,0), ZIndex = 56,
    })
    apply_corner(svp, 3)

    local hue = library:create("TextButton", {
        Parent = inner, Position = dim2(1, -12, 0, 0),
        BorderSizePixel = 0, Size = dim2(0, 12, 0, 95),
        Text = "", AutoButtonColor = false,
        BackgroundColor3 = rgb(255, 0, 0), ZIndex = 52,
    })
    apply_corner(hue, 3)
    library:create("UIGradient", {
        Rotation = 90, Parent = hue,
        Color = rgbseq{
            rgbkey(0, rgb(255,0,0)), rgbkey(0.17, rgb(255,255,0)),
            rgbkey(0.33, rgb(0,255,0)), rgbkey(0.5, rgb(0,255,255)),
            rgbkey(0.67, rgb(0,0,255)), rgbkey(0.83, rgb(255,0,255)),
            rgbkey(1, rgb(255,0,0)),
        },
    })

    local hp = library:create("Frame", {
        Parent = hue, BorderSizePixel = 2, BorderColor3 = rgb(255,255,255),
        Size = dim2(1, 2, 0, 4), Position = dim2(0, -1, 0, -2),
        BackgroundColor3 = rgb(255,255,255), ZIndex = 53,
    })

    local alpha = library:create("TextButton", {
        Parent = inner, Position = dim2(0, 0, 1, -12),
        BorderSizePixel = 0, Size = dim2(1, -18, 0, 8),
        Text = "", AutoButtonColor = false, BackgroundColor3 = rgb(255,0,0), ZIndex = 52,
    })
    apply_corner(alpha, 2)
    library:create("ImageLabel", {
        ScaleType = Enum.ScaleType.Tile, Parent = alpha,
        Image = "rbxassetid://18274452449", BackgroundTransparency = 1,
        Size = dim2(1, 0, 1, 0), TileSize = dim2(0, 5, 0, 5),
        BorderSizePixel = 0, ZIndex = 53,
    })
    local af = library:create("Frame", {
        Parent = alpha, Size = dim2(1, 0, 1, 0),
        BorderSizePixel = 0, BackgroundColor3 = rgb(255,0,0), ZIndex = 54,
    })
    apply_corner(af, 2)
    local ap = library:create("Frame", {
        Parent = alpha, BorderSizePixel = 2, BorderColor3 = rgb(255,255,255),
        Size = dim2(0, 3, 1, 2), Position = dim2(0, -1, 0, -1),
        BackgroundColor3 = rgb(255,255,255), ZIndex = 55,
    })

    local tbi = library:create("TextBox", {
        FontFace = library.font, Parent = inner,
        TextColor3 = themes.preset.text, Text = "",
        PlaceholderText = "R, G, B, A",
        PlaceholderColor3 = themes.preset.text_dim,
        BackgroundTransparency = 1,
        Position = dim2(0, 0, 1, -10), Size = dim2(0, 100, 0, 10),
        TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 55,
    })

    local dsv, dh, da = false, false, false
    local h, s, v = cfg.color:ToHSV()
    local a = cfg.alpha
    flags[cfg.flag] = {}

    function cfg.set_visible(b)
        picker.Visible = b
        picker.Position = dim_offset(element.AbsolutePosition.X - 100, element.AbsolutePosition.Y + element.AbsoluteSize.Y + 2)
    end

    function cfg.set(c, av)
        if c then h, s, v = c:ToHSV() end
        if av then a = av end
        local C = Color3.fromHSV(h, s, v)
        hp.Position = dim2(0, -1, 1 - h, -2)
        ap.Position = dim2(1 - a, -1, 0, -1)
        svp.Position = dim2(s, -2, 1 - v, -2)
        sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        ec.BackgroundColor3 = C
        af.BackgroundColor3 = C
        flags[cfg.flag] = {Color = C, Transparency = a}
        local c2 = ec.BackgroundColor3
        tbi.Text = string.format("%d,%d,%d,%.2f",
            library:round(c2.R * 255), library:round(c2.G * 255), library:round(c2.B * 255), library:round(1 - a, 0.01))
        cfg.callback(C, a)
    end

    function cfg.update_color()
        local m = uis:GetMouseLocation()
        local o = vec2(m.X, m.Y - gui_offset)
        if dsv then
            s = clamp((o - sv.AbsolutePosition).X / sv.AbsoluteSize.X, 0, 1)
            v = 1 - clamp((o - sv.AbsolutePosition).Y / sv.AbsoluteSize.Y, 0, 1)
        elseif dh then
            h = 1 - clamp((o - hue.AbsolutePosition).Y / hue.AbsoluteSize.Y, 0, 1)
        elseif da then
            a = 1 - clamp((o - alpha.AbsolutePosition).X / alpha.AbsoluteSize.X, 0, 1)
        end
        cfg.set(nil, nil)
    end

    cfg.set(cfg.color, cfg.alpha)
    config_flags[cfg.flag] = cfg.set

    element.MouseButton1Click:Connect(function()
        cfg.open = not cfg.open; cfg.set_visible(cfg.open)
    end)
    sv.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dsv = true; cfg.update_color()
        end
    end)
    hue.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dh = true; cfg.update_color()
        end
    end)
    alpha.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            da = true; cfg.update_color()
        end
    end)
    library:connection(uis.InputChanged, function(i)
        if (dsv or dh or da) and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            cfg.update_color()
        end
    end)
    library:connection(uis.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dsv, dh, da = false, false, false
            if not (library:mouse_in_frame(element) or library:mouse_in_frame(picker)) then
                cfg.open = false; cfg.set_visible(false)
            end
        end
    end)
    tbi.FocusLost:Connect(function()
        local r, g, b, al = library:convert(tbi.Text)
        if r and g and b and al then cfg.set(rgb(r, g, b), 1 - al) end
    end)
    return setmetatable(cfg, library)
end

-- =========================================================
-- NOTIFICATIONS
-- =========================================================
local notifications = { notifs = {} }

function notifications:refresh_notifs()
    for i, v in notifications.notifs do
        tween_service:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
            {Position = dim_offset(14, 14 + (i * 26))}):Play()
    end
end

function notifications:fade(p, out)
    local t = out and 1 or 0
    tween_service:Create(p, TweenInfo.new(0.5), {BackgroundTransparency = t}):Play()
    for _, inst in p:GetDescendants() do
        if inst:IsA("TextLabel") then
            tween_service:Create(inst, TweenInfo.new(0.5), {TextTransparency = t}):Play()
        elseif inst:IsA("Frame") then
            tween_service:Create(inst, TweenInfo.new(0.5), {BackgroundTransparency = t}):Play()
        end
    end
end

local sgui = library:create("ScreenGui", {
    Name = "gs_notifs",
    Parent = (gethui and gethui()) or coregui,
})

function notifications:create_notification(options)
    local cfg = { name = options.name or "notification" }
    local o = library:create("Frame", {
        Parent = sgui, Size = dim2(0, 0, 0, 0),
        Position = dim_offset(14, 14 + (#notifications.notifs * 26)),
        BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = themes.preset.a,
    })
    apply_corner(o, 4)
    library:apply_theme(o, "a", "BackgroundColor3")

    local inl = library:create("Frame", {
        Parent = o, Position = dim2(0, 1, 0, 1),
        BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = themes.preset.c,
    })
    apply_corner(inl, 3)
    library:apply_theme(inl, "c", "BackgroundColor3")

    library:create("Frame", {
        Parent = o, BackgroundColor3 = themes.preset.accent,
        BorderSizePixel = 0, Position = dim2(0, 0, 0, 2),
        Size = dim2(0, 2, 1, -4), ZIndex = 3,
    })
    library:apply_theme(o, "accent", "BackgroundColor3")

    library:create("UIPadding", {
        PaddingTop = dim(0, 5), PaddingBottom = dim(0, 5),
        PaddingLeft = dim(0, 8), PaddingRight = dim(0, 8), Parent = inl,
    })

    library:create("TextLabel", {
        FontFace = library.font, Parent = inl,
        TextColor3 = themes.preset.text, Text = cfg.name,
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 10, ZIndex = 2,
    })

    local idx = #notifications.notifs + 1
    notifications.notifs[idx] = o
    notifications:refresh_notifs()
    notifications:fade(o, false)

    task.spawn(function()
        task.wait(3)
        notifications.notifs[idx] = nil
        notifications:fade(o, true)
        task.wait(1)
        o:Destroy()
    end)
end

-- =========================================================
return library, notifications
