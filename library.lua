-- REASON: Discontinued nobody wanted to buy it either... I can see why vaderhaxx was super ugly lol
-- Rewritten: Gamesense CS2 style + icon sidebar + sub-tabs + rounded + mobile + auto-size

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

-- ===== MOBILE DETECTION =====
local is_mobile = uis.TouchEnabled and not uis.MouseEnabled
local is_tablet = uis.TouchEnabled and uis.MouseEnabled and not uis.KeyboardEnabled

local function get_ui_scale()
    local vp = camera.ViewportSize
    local base_w, base_h = 900, 620
    if is_mobile then
        return clamp(min(vp.X / base_w, vp.Y / base_h), 0.55, 1)
    elseif is_tablet then
        return clamp(min(vp.X / base_w, vp.Y / base_h), 0.7, 1)
    end
    return 1
end

local UI_SCALE = get_ui_scale()

-- ===== LIBRARY INIT =====
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
        accent_alt  = rgb(230, 60, 60),
        text        = rgb(230, 230, 230),
        text_dim    = rgb(140, 140, 140),
        text_outline= rgb(0, 0, 0),
        a = rgb(10, 10, 10),
        b = rgb(28, 28, 28),
        c = rgb(22, 22, 22),
        d = rgb(15, 15, 15),
        e = rgb(35, 35, 35),
        f = rgb(55, 55, 55),
        g = rgb(45, 45, 45),
        header = rgb(18, 18, 18),
        border = rgb(60, 60, 60),
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

local keys = {
    [Enum.KeyCode.LeftShift] = "LS", [Enum.KeyCode.RightShift] = "RS",
    [Enum.KeyCode.LeftControl] = "LC", [Enum.KeyCode.RightControl] = "RC",
    [Enum.KeyCode.Insert] = "INS", [Enum.KeyCode.Backspace] = "BS",
    [Enum.KeyCode.Return] = "Ent", [Enum.KeyCode.LeftAlt] = "LA",
    [Enum.KeyCode.RightAlt] = "RA", [Enum.KeyCode.CapsLock] = "CAPS",
    [Enum.KeyCode.One] = "1", [Enum.KeyCode.Two] = "2", [Enum.KeyCode.Three] = "3",
    [Enum.KeyCode.Four] = "4", [Enum.KeyCode.Five] = "5", [Enum.KeyCode.Six] = "6",
    [Enum.KeyCode.Seven] = "7", [Enum.KeyCode.Eight] = "8", [Enum.KeyCode.Nine] = "9",
    [Enum.KeyCode.Zero] = "0",
    [Enum.KeyCode.KeypadOne] = "N1", [Enum.KeyCode.KeypadTwo] = "N2",
    [Enum.KeyCode.KeypadThree] = "N3", [Enum.KeyCode.KeypadFour] = "N4",
    [Enum.KeyCode.KeypadFive] = "N5", [Enum.KeyCode.KeypadSix] = "N6",
    [Enum.KeyCode.KeypadSeven] = "N7", [Enum.KeyCode.KeypadEight] = "N8",
    [Enum.KeyCode.KeypadNine] = "N9", [Enum.KeyCode.KeypadZero] = "N0",
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
        writefile(library.directory .. "/fonts/main.ttf", game:HttpGet("https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/ProggyClean.ttf"))
    end)
end

local proggy_clean = {
    name = "ProggyClean",
    faces = {{
        name = "Regular",
        weight = 400,
        style = "normal",
        assetId = getcustomasset(library.directory .. "/fonts/main.ttf")
    }}
}

if not isfile(library.directory .. "/fonts/main_encoded.ttf") then
    writefile(library.directory .. "/fonts/main_encoded.ttf", http_service:JSONEncode(proggy_clean))
end

library.font = Font.new(getcustomasset(library.directory .. "/fonts/main_encoded.ttf"), Enum.FontWeight.Regular)

-- =========================================================
-- HELPERS
-- =========================================================
local function apply_corner(instance, radius)
    if instance:FindFirstChildOfClass("UICorner") then return end
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 4)
    corner.Parent = instance
    return corner
end
library.apply_corner = apply_corner

-- =========================================================
-- LIBRARY FUNCTIONS
-- =========================================================
function library:tween(obj, properties)
    return tween_service:Create(obj, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0), properties):Play()
end

function library:resizify(frame)
    local handle = Instance.new("TextButton")
    handle.Position = dim2(1, -14, 1, -14)
    handle.Size = dim2(0, 14, 0, 14)
    handle.BackgroundTransparency = 1
    handle.Text = ""
    handle.Parent = frame
    if is_mobile then
        handle.Position = dim2(1, -24, 1, -24)
        handle.Size = dim2(0, 24, 0, 24)
    end

    local resizing = false
    local start_size, start, og_size = nil, nil, frame.Size

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            start = input.Position
            start_size = frame.Size
        end
    end)

    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            resizing = false
        end
    end)

    library:connection(uis.InputChanged, function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local vx, vy = camera.ViewportSize.X, camera.ViewportSize.Y
            frame.Size = dim2(
                start_size.X.Scale,
                clamp(start_size.X.Offset + (input.Position.X - start.X), og_size.X.Offset, vx),
                start_size.Y.Scale,
                clamp(start_size.Y.Offset + (input.Position.Y - start.Y), og_size.Y.Offset, vy)
            )
        end
    end)
end

function library:mouse_in_frame(uiobject)
    local pos = uis:GetMouseLocation()
    local y_cond = uiobject.AbsolutePosition.Y <= pos.Y and pos.Y <= uiobject.AbsolutePosition.Y + uiobject.AbsoluteSize.Y
    local x_cond = uiobject.AbsolutePosition.X <= pos.X and pos.X <= uiobject.AbsolutePosition.X + uiobject.AbsoluteSize.X
    return (y_cond and x_cond)
end

library.lerp = function(start, finish, t)
    t = t or 1 / 8
    return start * (1 - t) + finish * t
end

function library:draggify(frame)
    local dragging = false
    local start_size = frame.Position
    local start

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            start = input.Position
            start_size = frame.Position
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
            local vx, vy = camera.ViewportSize.X, camera.ViewportSize.Y
            frame.Position = dim2(
                0,
                clamp(start_size.X.Offset + (input.Position.X - start.X), 0, vx - frame.Size.X.Offset * UI_SCALE),
                0,
                clamp(start_size.Y.Offset + (input.Position.Y - start.Y), 0, vy - frame.Size.Y.Offset * UI_SCALE)
            )
        end
    end)
end

function library:convert(str)
    local values = {}
    for value in string.gmatch(str, "[^,]+") do
        insert(values, tonumber(value))
    end
    if #values == 4 then return unpack(values) end
end

function library:convert_enum(enum)
    local enum_parts = {}
    for part in string.gmatch(enum, "[%w_]+") do
        insert(enum_parts, part)
    end
    local enum_table = Enum
    for i = 2, #enum_parts do
        enum_table = enum_table[enum_parts[i]]
    end
    return enum_table
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

function library:round(number, float)
    local multiplier = 1 / (float or 1)
    return floor(number * multiplier + 0.5) / multiplier
end

function library:apply_theme(instance, theme, property)
    if not themes.utility[theme] then return end
    if not themes.utility[theme][property] then return end
    insert(themes.utility[theme][property], instance)
end

function library:connection(signal, callback)
    local connection = signal:Connect(callback)
    insert(library.connections, connection)
    return connection
end

function library:create(instance, options)
    local ins = Instance.new(instance)
    for prop, value in next, options do
        ins[prop] = value
    end

    -- Auto rounded corners
    if ins:IsA("GuiObject") then
        if not ins:FindFirstChildOfClass("UICorner") then
            apply_corner(ins, 4)
        end
    end

    if instance == "TextLabel" or instance == "TextButton" or instance == "TextBox" then
        library:apply_theme(ins, "text", "TextColor3")
    end

    return ins
end

function library:unload_menu()
    if library.gui then library.gui:Destroy() end
    for _, connection in next, library.connections do
        pcall(function() connection:Disconnect() end)
    end
    library = nil
end

-- =========================================================
-- WINDOW
-- =========================================================
function library:window(properties)
    local cfg = {
        name = properties.name or properties.Name or "gamesense",
        size = properties.size or properties.Size or dim2(0, 720, 0, 480),
        selected_tab,
        tabs = {},
    }

    if is_mobile then
        local vp = camera.ViewportSize
        cfg.size = dim2(1, -30, 0, clamp(vp.Y * 0.78, 320, 540))
    end

    library.gui = library:create("ScreenGui", {
        Parent = coregui,
        Name = "\0",
        Enabled = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })

    local ui_scale = Instance.new("UIScale")
    ui_scale.Scale = UI_SCALE
    ui_scale.Parent = library.gui

    library:connection(camera:GetPropertyChangedSignal("ViewportSize"), function()
        UI_SCALE = get_ui_scale()
        if ui_scale then ui_scale.Scale = UI_SCALE end
    end)

    -- MAIN FRAME
    local main = library:create("Frame", {
        Parent = library.gui,
        BackgroundTransparency = 1,
        Position = dim2(0.5, -cfg.size.X.Offset / 2, 0.5, -cfg.size.Y.Offset / 2),
        Size = cfg.size,
        BorderSizePixel = 0,
    })
    apply_corner(main, 6)
    library:resizify(main)
    library:draggify(main)

    local outer = library:create("Frame", {
        Parent = main,
        BackgroundColor3 = themes.preset.a,
        BorderSizePixel = 0,
        Size = dim2(1, 0, 1, 0),
    })
    apply_corner(outer, 6)
    library:apply_theme(outer, "a", "BackgroundColor3")

    local panel = library:create("Frame", {
        Parent = outer,
        BackgroundColor3 = themes.preset.b,
        BorderSizePixel = 0,
        Position = dim2(0, 1, 0, 1),
        Size = dim2(1, -2, 1, -2),
    })
    apply_corner(panel, 5)
    library:apply_theme(panel, "b", "BackgroundColor3")

    -- HEADER
    local header = library:create("Frame", {
        Parent = panel,
        BackgroundColor3 = themes.preset.header,
        BorderSizePixel = 0,
        Position = dim2(0, 0, 0, 0),
        Size = dim2(1, 0, 0, 26),
    })
    apply_corner(header, 5)
    library:apply_theme(header, "header", "BackgroundColor3")

    library:create("Frame", {
        Parent = header,
        BackgroundColor3 = themes.preset.header,
        BorderSizePixel = 0,
        Position = dim2(0, 0, 1, -6),
        Size = dim2(1, 0, 0, 6),
        ZIndex = 1,
    })

    library:create("TextLabel", {
        Parent = header,
        BackgroundTransparency = 1,
        FontFace = library.font,
        Text = cfg.name:lower(),
        TextColor3 = themes.preset.accent,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = dim2(0, 14, 0, 0),
        Size = dim2(0, 200, 1, 0),
        ZIndex = 2,
    })

    local close = library:create("TextButton", {
        Parent = header,
        BackgroundColor3 = themes.preset.accent_alt,
        BorderSizePixel = 0,
        Text = "X",
        FontFace = library.font,
        TextColor3 = rgb(255, 255, 255),
        TextSize = 11,
        Position = dim2(1, -22, 0, 6),
        Size = dim2(0, 16, 0, 14),
        ZIndex = 4,
        AutoButtonColor = false,
    })
    apply_corner(close, 3)
    close.MouseButton1Click:Connect(function() library:unload_menu() end)

    library:create("Frame", {
        Parent = panel,
        BackgroundColor3 = themes.preset.border,
        BorderSizePixel = 0,
        Position = dim2(0, 0, 0, 26),
        Size = dim2(1, 0, 0, 1),
        ZIndex = 3,
    })

    -- ICON SIDEBAR
    local icon_w = is_mobile and 40 or 48

    local sidebar = library:create("Frame", {
        Parent = panel,
        BackgroundColor3 = themes.preset.a,
        BorderSizePixel = 0,
        Position = dim2(0, 0, 0, 27),
        Size = dim2(0, icon_w, 1, -27),
    })
    library:apply_theme(sidebar, "a", "BackgroundColor3")

    library:create("UIListLayout", {
        Parent = sidebar,
        Padding = dim(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    })
    library:create("UIPadding", {
        Parent = sidebar,
        PaddingTop = dim(0, 8),
    })

    library:create("Frame", {
        Parent = panel,
        BackgroundColor3 = themes.preset.border,
        BorderSizePixel = 0,
        Position = dim2(0, icon_w, 0, 27),
        Size = dim2(0, 1, 1, -27),
        ZIndex = 3,
    })

    -- CONTENT AREA
    local content = library:create("Frame", {
        Parent = panel,
        BackgroundTransparency = 1,
        Position = dim2(0, icon_w + 1, 0, 27),
        Size = dim2(1, -(icon_w + 1), 1, -27),
        BorderSizePixel = 0,
    })

    cfg.icon_holder = sidebar
    cfg.content = content
    cfg.panel = panel

    return setmetatable(cfg, library)
end

-- =========================================================
-- TAB (icône dans sidebar)
-- =========================================================
function library:tab(properties)
    local cfg = {
        name = properties.name or "tab",
        icon = properties.icon or nil,
        subtabs = {},
        selected_sub,
    }

    local icon_size = is_mobile and 28 or 32
    local order = #self.tabs + 1
    insert(self.tabs, cfg)

    -- ICON BUTTON
    local icon_btn = library:create("TextButton", {
        Parent = self.icon_holder,
        BackgroundColor3 = themes.preset.b,
        BorderSizePixel = 0,
        Size = dim2(0, icon_size, 0, icon_size),
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = order,
    })
    apply_corner(icon_btn, 4)

    local accent_bar = library:create("Frame", {
        Parent = icon_btn,
        BackgroundColor3 = themes.preset.accent,
        BorderSizePixel = 0,
        Position = dim2(0, -6, 0.5, -10),
        Size = dim2(0, 2, 0, 20),
        Visible = false,
        ZIndex = 5,
    })
    apply_corner(accent_bar, 1)
    library:apply_theme(accent_bar, "accent", "BackgroundColor3")

    local icon_img, icon_text
    if cfg.icon and tostring(cfg.icon):find("rbxassetid") then
        icon_img = library:create("ImageLabel", {
            Parent = icon_btn,
            BackgroundTransparency = 1,
            Image = cfg.icon,
            ImageColor3 = themes.preset.text_dim,
            Size = dim2(0, icon_size - 12, 0, icon_size - 12),
            Position = dim2(0.5, -(icon_size - 12) / 2, 0.5, -(icon_size - 12) / 2),
            BorderSizePixel = 0,
            ZIndex = 2,
        })
    else
        icon_text = library:create("TextLabel", {
            Parent = icon_btn,
            BackgroundTransparency = 1,
            FontFace = library.font,
            Text = cfg.icon or cfg.name:sub(1, 2):upper(),
            TextColor3 = themes.preset.text_dim,
            TextSize = is_mobile and 11 or 12,
            Size = dim2(1, 0, 1, 0),
            BorderSizePixel = 0,
            ZIndex = 2,
        })
    end

    -- PAGE
    local page = library:create("Frame", {
        Parent = self.content,
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 1, 0),
        Visible = false,
        BorderSizePixel = 0,
    })
    cfg.page = page

    -- SUB TAB BAR
    local sub_bar = library:create("Frame", {
        Parent = page,
        BackgroundColor3 = themes.preset.header,
        BorderSizePixel = 0,
        Size = dim2(1, 0, 0, 26),
    })
    library:apply_theme(sub_bar, "header", "BackgroundColor3")
    cfg.sub_bar = sub_bar

    library:create("UIListLayout", {
        Parent = sub_bar,
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = dim(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    })
    library:create("UIPadding", {
        Parent = sub_bar,
        PaddingLeft = dim(0, 8),
    })

    library:create("Frame", {
        Parent = page,
        BackgroundColor3 = themes.preset.border,
        BorderSizePixel = 0,
        Position = dim2(0, 0, 0, 26),
        Size = dim2(1, 0, 0, 1),
    })

    -- SUB CONTENT HOLDER
    local sub_holder = library:create("Frame", {
        Parent = page,
        BackgroundTransparency = 1,
        Position = dim2(0, 0, 0, 27),
        Size = dim2(1, 0, 1, -27),
        BorderSizePixel = 0,
    })
    cfg.sub_holder = sub_holder

    -- OPEN TAB
    function cfg.open_tab()
        if self.selected_tab then
            local prev = self.selected_tab
            prev.page.Visible = false
            prev.icon_btn.BackgroundColor3 = themes.preset.b
            prev.accent_bar.Visible = false
            if prev.icon_img then prev.icon_img.ImageColor3 = themes.preset.text_dim end
            if prev.icon_text then prev.icon_text.TextColor3 = themes.preset.text_dim end
        end

        page.Visible = true
        icon_btn.BackgroundColor3 = themes.preset.c
        accent_bar.Visible = true
        if icon_img then icon_img.ImageColor3 = themes.preset.accent end
        if icon_text then icon_text.TextColor3 = themes.preset.accent end

        self.selected_tab = cfg

        if not cfg.selected_sub and #cfg.subtabs > 0 then
            cfg.subtabs[1].open()
        end
    end

    cfg.icon_btn = icon_btn
    cfg.accent_bar = accent_bar
    cfg.icon_img = icon_img
    cfg.icon_text = icon_text

    icon_btn.MouseButton1Down:Connect(function()
        cfg.open_tab()
    end)

    icon_btn.MouseEnter:Connect(function()
        if self.selected_tab ~= cfg then
            icon_btn.BackgroundColor3 = themes.preset.c
        end
    end)
    icon_btn.MouseLeave:Connect(function()
        if self.selected_tab ~= cfg then
            icon_btn.BackgroundColor3 = themes.preset.b
        end
    end)

    -- SUB-TAB API
    function cfg:subtab(props)
        local sub = {
            name = props.name or "sub",
            parent_tab = cfg,
        }

        local btn = library:create("TextButton", {
            Parent = sub_bar,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = string.lower(sub.name),
            FontFace = library.font,
            TextColor3 = themes.preset.text_dim,
            TextSize = 11,
            Size = dim2(0, 80, 1, 0),
            AutoButtonColor = false,
            LayoutOrder = #cfg.subtabs + 1,
        })

        local line = library:create("Frame", {
            Parent = btn,
            BackgroundColor3 = themes.preset.accent,
            BorderSizePixel = 0,
            Position = dim2(0, 0, 1, -2),
            Size = dim2(1, 0, 0, 2),
            Visible = false,
        })
        apply_corner(line, 1)
        library:apply_theme(line, "accent", "BackgroundColor3")

        local sub_page = library:create("Frame", {
            Parent = sub_holder,
            BackgroundTransparency = 1,
            Size = dim2(1, 0, 1, 0),
            Visible = false,
            BorderSizePixel = 0,
        })
        library:create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Parent = sub_page,
            Padding = dim(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalFlex = Enum.UIFlexAlignment.Fill,
        })
        library:create("UIPadding", {
            PaddingTop = dim(0, 10),
            PaddingBottom = dim(0, 10),
            Parent = sub_page,
            PaddingRight = dim(0, 10),
            PaddingLeft = dim(0, 10),
        })

        local left = library:create("Frame", {
            Parent = sub_page,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        })
        library:create("UIListLayout", {
            Parent = left,
            Padding = dim(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            VerticalFlex = Enum.UIFlexAlignment.Fill,
        })

        local right = library:create("Frame", {
            Parent = sub_page,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        })
        library:create("UIListLayout", {
            Parent = right,
            Padding = dim(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            VerticalFlex = Enum.UIFlexAlignment.Fill,
        })

        sub.left = left
        sub.right = right
        sub.page = sub_page
        sub.btn = btn
        sub.line = line

        function sub.open()
            if cfg.selected_sub then
                cfg.selected_sub.page.Visible = false
                cfg.selected_sub.line.Visible = false
                cfg.selected_sub.btn.TextColor3 = themes.preset.text_dim
            end
            sub_page.Visible = true
            line.Visible = true
            btn.TextColor3 = themes.preset.accent
            cfg.selected_sub = sub
        end

        btn.MouseButton1Down:Connect(function()
            sub.open()
        end)

        insert(cfg.subtabs, sub)

        return setmetatable(sub, {__index = library})
    end

    -- Init : premier tab s'ouvre tout seul
    if not self.selected_tab then
        cfg.open_tab()
    end

    return setmetatable(cfg, library)
end

-- =========================================================
-- SECTION (accepte un sub-tab en parent)
-- =========================================================
function library:section(properties, parent_sub)
    local cfg = {
        name = properties.name or properties.Name or "section",
        side = properties.side or "left",
        fill = properties.fill or 1,
    }

    local parent = parent_sub and parent_sub[cfg.side] or self[cfg.side]

    local section = library:create("Frame", {
        Parent = parent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = dim2(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })

    local a = library:create("Frame", {
        Parent = section,
        BorderSizePixel = 0,
        BackgroundColor3 = themes.preset.a,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = dim2(1, 0, 0, 0),
    })
    apply_corner(a, 4)

    local c = library:create("Frame", {
        Parent = a,
        Position = dim2(0, 1, 0, 1),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = dim2(1, -2, 0, 0),
        BackgroundColor3 = themes.preset.b,
    })
    apply_corner(c, 3)
    library:apply_theme(c, "b", "BackgroundColor3")

    local header = library:create("Frame", {
        Parent = c,
        BackgroundColor3 = themes.preset.e,
        BorderSizePixel = 0,
        Size = dim2(1, 0, 0, 20),
        ZIndex = 2,
    })
    apply_corner(header, 3)
    library:apply_theme(header, "e", "BackgroundColor3")

    library:create("Frame", {
        Parent = header,
        BackgroundColor3 = themes.preset.e,
        BorderSizePixel = 0,
        Position = dim2(0, 0, 1, -6),
        Size = dim2(1, 0, 0, 6),
        ZIndex = 3,
    })

    library:create("TextLabel", {
        FontFace = library.font,
        Parent = header,
        TextColor3 = themes.preset.text,
        Text = cfg.name,
        Size = dim2(1, -16, 1, 0),
        Position = dim2(0, 8, 0, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        ZIndex = 4,
        TextSize = 11,
    })

    local scrolling = library:create("ScrollingFrame", {
        Parent = c,
        BackgroundTransparency = 1,
        Position = dim2(0, 0, 0, 20),
        Size = dim2(1, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = dim2(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = themes.preset.accent,
        BorderSizePixel = 0,
        ZIndex = 2,
    })
    apply_corner(scrolling, 3)

    local elements = library:create("Frame", {
        Parent = scrolling,
        BackgroundTransparency = 1,
        Position = dim2(0, 6, 0, 4),
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = dim2(1, -12, 0, 0),
        BorderSizePixel = 0,
    })
    cfg.elements = elements

    local layout = library:create("UIListLayout", {
        Parent = elements,
        Padding = dim(0, is_mobile and 8 or 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    library:create("UIPadding", {
        PaddingBottom = dim(0, 6),
        Parent = elements,
    })

    local function update_size()
        local h = layout.AbsoluteContentSize.Y + 10
        a.Size = dim2(1, 0, 0, 20 + h)
        c.Size = dim2(1, -2, 0, 20 + h)
        scrolling.Size = dim2(1, 0, 0, h)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update_size)
    task.defer(update_size)

    return setmetatable(cfg, library)
end

-- =========================================================
-- ELEMENTS
-- =========================================================

-- LABEL
function library:label(options)
    local cfg = { name = options.name or "label" }

    local label = library:create("Frame", {
        Parent = self.elements,
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 0, 14),
        BorderSizePixel = 0,
    })

    library:create("TextLabel", {
        FontFace = library.font,
        TextColor3 = themes.preset.text_dim,
        Text = cfg.name,
        Parent = label,
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        TextSize = 11,
    })

    local right_components = library:create("Frame", {
        Parent = label,
        Position = dim2(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Size = dim2(0, 0, 1, 0),
        BorderSizePixel = 0,
    })
    cfg.right_components = right_components

    library:create("UIListLayout", {
        Parent = right_components,
        Padding = dim(0, 4),
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    return setmetatable(cfg, library)
end

-- TOGGLE
function library:toggle(options)
    local cfg = {
        enabled = options.enabled or nil,
        name = options.name or "Toggle",
        flag = options.flag or tostring(random(1, 9999999)),
        default = options.value or options.default or false,
        folding = options.folding or false,
        callback = options.callback or function() end,
    }

    local toggle = library:create("TextButton", {
        FontFace = library.font,
        BorderSizePixel = 0,
        Text = "",
        Parent = self.elements,
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 0, is_mobile and 22 or 18),
        TextSize = 12,
        AutoButtonColor = false,
    })

    library:create("TextLabel", {
        FontFace = library.font,
        TextColor3 = themes.preset.text,
        Text = cfg.name,
        Parent = toggle,
        AutomaticSize = Enum.AutomaticSize.XY,
        Position = dim2(0, 0, 0, -1),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        ZIndex = 2,
        TextSize = 11,
    })

    local box_size = is_mobile and 16 or 13
    local box = library:create("Frame", {
        Parent = toggle,
        Position = dim2(1, -box_size, 0, 2),
        Size = dim2(0, box_size, 0, box_size),
        BorderSizePixel = 0,
        BackgroundColor3 = themes.preset.d,
    })
    apply_corner(box, 3)
    library:apply_theme(box, "d", "BackgroundColor3")

    local box_border = library:create("Frame", {
        Parent = box,
        Position = dim2(0, 1, 0, 1),
        Size = dim2(1, -2, 1, -2),
        BorderSizePixel = 0,
        BackgroundColor3 = themes.preset.e,
    })
    apply_corner(box_border, 2)
    library:apply_theme(box_border, "e", "BackgroundColor3")

    local check = library:create("Frame", {
        Parent = box_border,
        Position = dim2(0.5, -4, 0.5, -4),
        Size = dim2(0, 8, 0, 8),
        BorderSizePixel = 0,
        BackgroundColor3 = themes.preset.accent,
        Visible = false,
    })
    apply_corner(check, 2)
    library:apply_theme(check, "accent", "BackgroundColor3")

    local elements
    if cfg.folding then
        elements = library:create("Frame", {
            Parent = self.elements,
            BackgroundTransparency = 1,
            Size = dim2(1, 0, 0, 0),
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = false,
        })
        cfg.elements = elements
        library:create("UIListLayout", {
            Parent = elements,
            Padding = dim(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
    end

    function cfg.set(bool)
        check.Visible = bool
        cfg.enabled = bool
        cfg.callback(bool)
        if cfg.folding and elements then
            elements.Visible = bool
        end
    end

    cfg.set(cfg.default)
    config_flags[cfg.flag] = cfg.set
    flags[cfg.flag] = cfg.default

    toggle.MouseButton1Click:Connect(function()
        cfg.enabled = not cfg.enabled
        cfg.set(cfg.enabled)
    end)

    return setmetatable(cfg, library)
end

-- SLIDER
function library:slider(options)
    local cfg = {
        name = options.name or nil,
        suffix = options.suffix or "",
        flag = options.flag or tostring(2^789),
        callback = options.callback or function() end,
        min = options.min or options.minimum or 0,
        max = options.max or options.maximum or 100,
        intervals = options.interval or options.decimal or 1,
        default = options.value or options.default or 10,
        ignore = options.ignore or false,
        dragging = false,
    }

    local row_h = is_mobile and 44 or 36

    local object = library:create("Frame", {
        Parent = self.elements,
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 0, row_h),
        BorderSizePixel = 0,
    })

    library:create("TextLabel", {
        FontFace = library.font,
        TextColor3 = themes.preset.text,
        Text = cfg.name,
        Parent = object,
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        TextSize = 11,
        ZIndex = 2,
    })

    local value_display = library:create("TextLabel", {
        FontFace = library.font,
        TextColor3 = themes.preset.accent,
        Text = tostring(cfg.default),
        Parent = object,
        AutomaticSize = Enum.AutomaticSize.XY,
        AnchorPoint = vec2(1, 0),
        Position = dim2(1, 0, 0, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Right,
        BorderSizePixel = 0,
        TextSize = 11,
        ZIndex = 2,
    })
    library:apply_theme(value_display, "accent", "TextColor3")

    local slider_frame = library:create("TextButton", {
        Parent = object,
        Position = dim2(0, 0, 0, 18),
        BorderSizePixel = 0,
        Size = dim2(1, 0, 0, is_mobile and 14 or 8),
        AutoButtonColor = false,
        Text = "",
        BackgroundColor3 = themes.preset.d,
    })
    apply_corner(slider_frame, 3)
    library:apply_theme(slider_frame, "d", "BackgroundColor3")

    local background = library:create("Frame", {
        Parent = slider_frame,
        Position = dim2(0, 1, 0, 1),
        BorderSizePixel = 0,
        Size = dim2(1, -2, 1, -2),
        BackgroundColor3 = themes.preset.e,
    })
    apply_corner(background, 3)
    library:apply_theme(background, "e", "BackgroundColor3")

    local fill = library:create("Frame", {
        Parent = background,
        BorderSizePixel = 0,
        Size = dim2(0.5, 0, 1, 0),
        BackgroundColor3 = themes.preset.accent,
    })
    apply_corner(fill, 3)
    library:apply_theme(fill, "accent", "BackgroundColor3")

    function cfg.set(value)
        local valuee = tonumber(value)
        if valuee == nil then return end
        cfg.value = clamp(library:round(value, cfg.intervals), cfg.min, cfg.max)
        fill.Size = dim2((cfg.value - cfg.min) / (cfg.max - cfg.min), 0, 1, 0)
        value_display.Text = tostring(cfg.value) .. cfg.suffix
        flags[cfg.flag] = cfg.value
        cfg.callback(flags[cfg.flag])
    end

    slider_frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            cfg.dragging = true
            local size_x = (input.Position.X - slider_frame.AbsolutePosition.X) / slider_frame.AbsoluteSize.X
            local value = ((cfg.max - cfg.min) * size_x) + cfg.min
            cfg.set(value)
        end
    end)

    library:connection(uis.InputChanged, function(input)
        if cfg.dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local size_x = (input.Position.X - slider_frame.AbsolutePosition.X) / slider_frame.AbsoluteSize.X
            local value = ((cfg.max - cfg.min) * size_x) + cfg.min
            cfg.set(value)
        end
    end)

    library:connection(uis.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            cfg.dragging = false
        end
    end)

    cfg.set(cfg.default)
    config_flags[cfg.flag] = cfg.set

    return setmetatable(cfg, library)
end

-- DROPDOWN
function library:dropdown(options)
    local cfg = {
        name = options.name or nil,
        flag = options.flag or tostring(random(1, 9999999)),
        items = options.items or {""},
        callback = options.callback or function() end,
        multi = options.multi or false,
        open = false,
        option_instances = {},
        multi_items = {},
        ignore = options.ignore or false,
    }

    cfg.default = options.value or options.default or (cfg.multi and {cfg.items[1]}) or cfg.items[1] or "None"
    flags[cfg.flag] = {}

    local row_h = is_mobile and 44 or 38

    local object = library:create("Frame", {
        Parent = self.elements,
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 0, row_h),
        BorderSizePixel = 0,
    })

    library:create("TextLabel", {
        FontFace = library.font,
        TextColor3 = themes.preset.text,
        Text = cfg.name,
        Parent = object,
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        TextSize = 11,
        ZIndex = 2,
    })

    local holder = library:create("TextButton", {
        Parent = object,
        Text = "",
        Position = dim2(0, 0, 0, 18),
        BorderSizePixel = 0,
        Size = dim2(1, 0, 0, is_mobile and 22 or 18),
        BackgroundColor3 = themes.preset.d,
        AutoButtonColor = false,
    })
    apply_corner(holder, 3)
    library:apply_theme(holder, "d", "BackgroundColor3")

    local inline = library:create("Frame", {
        Parent = holder,
        Position = dim2(0, 1, 0, 1),
        BorderSizePixel = 0,
        Size = dim2(1, -2, 1, -2),
        BackgroundColor3 = themes.preset.e,
    })
    apply_corner(inline, 3)
    library:apply_theme(inline, "e", "BackgroundColor3")

    local text = library:create("TextLabel", {
        FontFace = library.font,
        Parent = inline,
        TextColor3 = themes.preset.text,
        Text = "ERROR",
        Size = dim2(1, -18, 1, 0),
        Position = dim2(0, 6, 0, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        ZIndex = 2,
        TextSize = 11,
    })

    local arrow = library:create("TextLabel", {
        FontFace = library.font,
        Parent = inline,
        TextColor3 = themes.preset.text_dim,
        Text = "v",
        Size = dim2(0, 12, 1, 0),
        Position = dim2(1, -14, 0, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center,
        BorderSizePixel = 0,
        ZIndex = 2,
        TextSize = 12,
    })

    local items = library:create("Frame", {
        Parent = library.gui,
        Visible = false,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = dim2(0, 150, 0, 0),
        BackgroundColor3 = themes.preset.a,
        ZIndex = 100,
    })
    apply_corner(items, 4)
    library:apply_theme(items, "a", "BackgroundColor3")

    local holder_items = library:create("Frame", {
        Parent = items,
        Size = dim2(1, -2, 0, 0),
        Position = dim2(0, 1, 0, 1),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = themes.preset.c,
        ZIndex = 101,
    })
    apply_corner(holder_items, 3)
    library:apply_theme(holder_items, "c", "BackgroundColor3")

    library:create("UIListLayout", {
        Parent = holder_items,
        Padding = dim(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    library:create("UIPadding", {
        PaddingTop = dim(0, 4),
        PaddingBottom = dim(0, 4),
        Parent = holder_items,
        PaddingRight = dim(0, 4),
        PaddingLeft = dim(0, 4),
    })

    function cfg.render_option(txt)
        return library:create("TextButton", {
            FontFace = library.font,
            TextColor3 = themes.preset.text,
            BorderSizePixel = 0,
            Text = txt,
            Parent = holder_items,
            Size = dim2(1, 0, 0, is_mobile and 22 or 18),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 11,
            AutoButtonColor = false,
            ZIndex = 102,
        })
    end

    function cfg.set_visible(bool)
        items.Visible = bool
        arrow.Text = bool and "^" or "v"
    end

    function cfg.set(value)
        local selected = {}
        local isTable = type(value) == "table"
        if value == nil then return end

        for _, option in next, cfg.option_instances do
            if option.Text == value or (isTable and find(value, option.Text)) then
                insert(selected, option.Text)
                cfg.multi_items = selected
                option.TextColor3 = themes.preset.accent
            else
                option.TextColor3 = themes.preset.text
            end
        end

        text.Text = if isTable then concat(selected, ", ") else (selected[1] or "None")
        flags[cfg.flag] = if isTable then selected else selected[1]
        cfg.callback(flags[cfg.flag])
    end

    function cfg.refresh_options(list)
        for _, option in next, cfg.option_instances do
            option:Destroy()
        end
        cfg.option_instances = {}

        for _, option in next, list do
            local button = cfg.render_option(option)
            insert(cfg.option_instances, button)

            button.MouseButton1Down:Connect(function()
                if cfg.multi then
                    local selected_index = find(cfg.multi_items, button.Text)
                    if selected_index then
                        remove(cfg.multi_items, selected_index)
                    else
                        insert(cfg.multi_items, button.Text)
                    end
                    cfg.set(cfg.multi_items)
                else
                    cfg.set_visible(false)
                    cfg.open = false
                    cfg.set(button.Text)
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

    library:connection(uis.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            if not (library:mouse_in_frame(items) or library:mouse_in_frame(holder)) then
                cfg.open = false
                cfg.set_visible(false)
            end
        end
    end)

    return setmetatable(cfg, library)
end

-- BUTTON
function library:button(options)
    local cfg = {
        name = options.name or "Button",
        callback = options.callback or function() end,
    }

    local button = library:create("TextButton", {
        Parent = self.elements,
        Text = "",
        BorderSizePixel = 0,
        Size = dim2(1, 0, 0, is_mobile and 26 or 20),
        BackgroundColor3 = themes.preset.d,
        AutoButtonColor = false,
    })
    apply_corner(button, 3)
    library:apply_theme(button, "d", "BackgroundColor3")

    local inline = library:create("Frame", {
        Parent = button,
        Position = dim2(0, 1, 0, 1),
        BorderSizePixel = 0,
        Size = dim2(1, -2, 1, -2),
        BackgroundColor3 = themes.preset.e,
    })
    apply_corner(inline, 3)
    library:apply_theme(inline, "e", "BackgroundColor3")

    library:create("TextLabel", {
        FontFace = library.font,
        TextColor3 = themes.preset.text,
        Text = cfg.name,
        Parent = inline,
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 1, 0),
        BorderSizePixel = 0,
        TextSize = 11,
    })

    button.MouseEnter:Connect(function()
        inline.BackgroundColor3 = themes.preset.g
    end)
    button.MouseLeave:Connect(function()
        inline.BackgroundColor3 = themes.preset.e
    end)

    button.MouseButton1Click:Connect(function()
        cfg.callback()
    end)

    return setmetatable(cfg, library)
end

-- TEXTBOX
function library:textbox(options)
    local cfg = {
        name = options.name or "TextBox",
        placeholder = options.placeholder or "type here...",
        default = options.value or options.default,
        flag = options.flag or "flag",
        callback = options.callback or function() end,
        visible = options.visible or true,
    }

    local object = library:create("Frame", {
        Parent = self.elements,
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 0, is_mobile and 44 or 38),
        BorderSizePixel = 0,
    })

    library:create("TextLabel", {
        FontFace = library.font,
        TextColor3 = themes.preset.text,
        Text = cfg.name,
        Parent = object,
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        TextSize = 11,
    })

    local box = library:create("Frame", {
        Parent = object,
        Position = dim2(0, 0, 0, 18),
        BorderSizePixel = 0,
        Size = dim2(1, 0, 0, is_mobile and 22 or 18),
        BackgroundColor3 = themes.preset.d,
    })
    apply_corner(box, 3)
    library:apply_theme(box, "d", "BackgroundColor3")

    local inline = library:create("Frame", {
        Parent = box,
        Position = dim2(0, 1, 0, 1),
        BorderSizePixel = 0,
        Size = dim2(1, -2, 1, -2),
        BackgroundColor3 = themes.preset.e,
    })
    apply_corner(inline, 3)
    library:apply_theme(inline, "e", "BackgroundColor3")

    local input = library:create("TextBox", {
        FontFace = library.font,
        TextColor3 = themes.preset.text,
        BorderSizePixel = 0,
        Text = "",
        Parent = inline,
        BackgroundTransparency = 1,
        PlaceholderColor3 = themes.preset.text_dim,
        PlaceholderText = cfg.placeholder,
        Size = dim2(1, -12, 1, 0),
        Position = dim2(0, 6, 0, 0),
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    function cfg.set(text)
        flags[cfg.flag] = text
        input.Text = text
        cfg.callback(text)
    end
    config_flags[cfg.flag] = cfg.set

    if cfg.default then cfg.set(cfg.default) end

    input.FocusLost:Connect(function()
        cfg.set(input.Text)
    end)

    return setmetatable(cfg, library)
end

-- COLORPICKER
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
        BorderSizePixel = 0,
        Size = dim2(0, 30, 0, 14),
        Text = "",
        AutoButtonColor = false,
        BackgroundColor3 = themes.preset.d,
    })
    apply_corner(element, 3)
    library:apply_theme(element, "d", "BackgroundColor3")

    local element_color = library:create("Frame", {
        Parent = element,
        Position = dim2(0, 1, 0, 1),
        BorderSizePixel = 0,
        Size = dim2(1, -2, 1, -2),
        BackgroundColor3 = rgb(255, 194, 11),
    })
    apply_corner(element_color, 2)

    local picker = library:create("Frame", {
        Parent = library.gui,
        BorderSizePixel = 0,
        Visible = false,
        Size = dim2(0, 200, 0, 180),
        BackgroundColor3 = themes.preset.a,
        ZIndex = 50,
    })
    apply_corner(picker, 4)
    library:apply_theme(picker, "a", "BackgroundColor3")

    local inner = library:create("Frame", {
        Parent = picker,
        Position = dim2(0, 1, 0, 1),
        BorderSizePixel = 0,
        Size = dim2(1, -2, 1, -2),
        BackgroundColor3 = themes.preset.c,
        ZIndex = 51,
    })
    apply_corner(inner, 3)
    library:apply_theme(inner, "c", "BackgroundColor3")

    library:create("UIPadding", {
        PaddingTop = dim(0, 6), PaddingBottom = dim(0, 6),
        PaddingRight = dim(0, 6), PaddingLeft = dim(0, 6),
        Parent = inner,
    })

    local sv = library:create("TextButton", {
        Parent = inner,
        BorderSizePixel = 0,
        Size = dim2(1, -20, 0, 110),
        Text = "",
        AutoButtonColor = false,
        BackgroundColor3 = rgb(255, 0, 0),
        ZIndex = 52,
    })
    apply_corner(sv, 3)

    local sv_val = library:create("Frame", {
        Parent = sv,
        BorderSizePixel = 0,
        Size = dim2(1, 0, 1, 0),
        BackgroundColor3 = rgb(255, 255, 255),
        ZIndex = 53,
    })
    apply_corner(sv_val, 3)
    library:create("UIGradient", {
        Parent = sv_val,
        Transparency = numseq{numkey(0, 0), numkey(1, 1)},
    })

    local sv_sat = library:create("TextButton", {
        Parent = sv,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        Size = dim2(1, 0, 1, 0),
        BackgroundColor3 = rgb(255, 255, 255),
        ZIndex = 55,
    })
    library:create("UIGradient", {
        Rotation = 270,
        Transparency = numseq{numkey(0, 0), numkey(1, 1)},
        Color = rgbseq{rgbkey(0, rgb(0, 0, 0)), rgbkey(1, rgb(0, 0, 0))},
        Parent = sv_sat,
    })

    local sv_picker = library:create("Frame", {
        Parent = sv,
        BorderColor3 = rgb(255, 255, 255),
        BorderSizePixel = 2,
        Size = dim2(0, 6, 0, 6),
        BackgroundColor3 = rgb(0, 0, 0),
        ZIndex = 56,
    })
    apply_corner(sv_picker, 3)

    local hue = library:create("TextButton", {
        Parent = inner,
        Position = dim2(1, -14, 0, 0),
        BorderSizePixel = 0,
        Size = dim2(0, 14, 0, 110),
        Text = "",
        AutoButtonColor = false,
        BackgroundColor3 = rgb(255, 0, 0),
        ZIndex = 52,
    })
    apply_corner(hue, 3)

    library:create("UIGradient", {
        Rotation = 90,
        Parent = hue,
        Color = rgbseq{
            rgbkey(0, rgb(255, 0, 0)), rgbkey(0.17, rgb(255, 255, 0)),
            rgbkey(0.33, rgb(0, 255, 0)), rgbkey(0.5, rgb(0, 255, 255)),
            rgbkey(0.67, rgb(0, 0, 255)), rgbkey(0.83, rgb(255, 0, 255)),
            rgbkey(1, rgb(255, 0, 0))
        },
    })

    local hue_picker = library:create("Frame", {
        Parent = hue,
        BorderSizePixel = 2,
        BorderColor3 = rgb(255, 255, 255),
        Size = dim2(1, 2, 0, 4),
        Position = dim2(0, -1, 0, -2),
        BackgroundColor3 = rgb(255, 255, 255),
        ZIndex = 53,
    })

    local alpha = library:create("TextButton", {
        Parent = inner,
        Position = dim2(0, 0, 1, -14),
        BorderSizePixel = 0,
        Size = dim2(1, -20, 0, 10),
        Text = "",
        AutoButtonColor = false,
        BackgroundColor3 = rgb(255, 0, 0),
        ZIndex = 52,
    })
    apply_corner(alpha, 2)

    local alpha_checker = library:create("ImageLabel", {
        ScaleType = Enum.ScaleType.Tile,
        Parent = alpha,
        Image = "rbxassetid://18274452449",
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 1, 0),
        TileSize = dim2(0, 5, 0, 5),
        BorderSizePixel = 0,
        ZIndex = 53,
    })

    local alpha_fill = library:create("Frame", {
        Parent = alpha,
        Size = dim2(1, 0, 1, 0),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 0, 0),
        ZIndex = 54,
    })
    apply_corner(alpha_fill, 2)

    local alpha_picker = library:create("Frame", {
        Parent = alpha,
        BorderSizePixel = 2,
        BorderColor3 = rgb(255, 255, 255),
        Size = dim2(0, 3, 1, 2),
        Position = dim2(0, -1, 0, -1),
        BackgroundColor3 = rgb(255, 255, 255),
        ZIndex = 55,
    })

    local tb_input = library:create("TextBox", {
        FontFace = library.font,
        Parent = inner,
        TextColor3 = themes.preset.text,
        Text = "",
        PlaceholderText = "R, G, B, A",
        PlaceholderColor3 = themes.preset.text_dim,
        BackgroundTransparency = 1,
        Position = dim2(0, 0, 1, -14),
        Size = dim2(0, 100, 0, 12),
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 55,
    })

    local dragging_sv, dragging_hue, dragging_alpha = false, false, false
    local h, s, v = cfg.color:ToHSV()
    local a = cfg.alpha

    flags[cfg.flag] = {}

    function cfg.set_visible(bool)
        picker.Visible = bool
        picker.Position = dim_offset(element.AbsolutePosition.X, element.AbsolutePosition.Y + element.AbsoluteSize.Y + 2)
    end

    function cfg.set(c, alpha_v)
        if c then h, s, v = c:ToHSV() end
        if alpha_v then a = alpha_v end

        local Color = Color3.fromHSV(h, s, v)

        hue_picker.Position = dim2(0, -1, 1 - h, -2)
        alpha_picker.Position = dim2(1 - a, -1, 0, -1)
        sv_picker.Position = dim2(s, -3, 1 - v, -3)

        sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        element_color.BackgroundColor3 = Color
        alpha_fill.BackgroundColor3 = Color

        flags[cfg.flag] = {Color = Color, Transparency = a}

        local c2 = element_color.BackgroundColor3
        tb_input.Text = string.format("%d, %d, %d, %.2f",
            library:round(c2.R * 255), library:round(c2.G * 255), library:round(c2.B * 255), library:round(1 - a, 0.01))

        cfg.callback(Color, a)
    end

    function cfg.update_color()
        local m = uis:GetMouseLocation()
        local offset = vec2(m.X, m.Y - gui_offset)

        if dragging_sv then
            s = clamp((offset - sv.AbsolutePosition).X / sv.AbsoluteSize.X, 0, 1)
            v = 1 - clamp((offset - sv.AbsolutePosition).Y / sv.AbsoluteSize.Y, 0, 1)
        elseif dragging_hue then
            h = 1 - clamp((offset - hue.AbsolutePosition).Y / hue.AbsoluteSize.Y, 0, 1)
        elseif dragging_alpha then
            a = 1 - clamp((offset - alpha.AbsolutePosition).X / alpha.AbsoluteSize.X, 0, 1)
        end
        cfg.set(nil, nil)
    end

    cfg.set(cfg.color, cfg.alpha)
    config_flags[cfg.flag] = cfg.set

    element.MouseButton1Click:Connect(function()
        cfg.open = not cfg.open
        cfg.set_visible(cfg.open)
    end)

    sv.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging_sv = true
            cfg.update_color()
        end
    end)
    hue.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging_hue = true
            cfg.update_color()
        end
    end)
    alpha.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging_alpha = true
            cfg.update_color()
        end
    end)

    library:connection(uis.InputChanged, function(input)
        if (dragging_sv or dragging_hue or dragging_alpha)
        and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            cfg.update_color()
        end
    end)

    library:connection(uis.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging_sv, dragging_hue, dragging_alpha = false, false, false

            if not (library:mouse_in_frame(element) or library:mouse_in_frame(picker)) then
                cfg.open = false
                cfg.set_visible(false)
            end
        end
    end)

    tb_input.FocusLost:Connect(function()
        local r, g, b, al = library:convert(tb_input.Text)
        if r and g and b and al then
            cfg.set(rgb(r, g, b), 1 - al)
        end
    end)

    return setmetatable(cfg, library)
end

-- KEYBIND
function library:keybind(options)
    local cfg = {
        flag = options.flag or "flag_keybind",
        callback = options.callback or function() end,
        name = options.name or nil,
        ignore_key = options.ignore or false,
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
        Size = dim2(0, 60, 0, 14),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        BackgroundColor3 = themes.preset.d,
    })
    apply_corner(element, 3)
    library:apply_theme(element, "d", "BackgroundColor3")

    local b = library:create("Frame", {
        Parent = element,
        Size = dim2(1, -2, 1, -2),
        Position = dim2(0, 1, 0, 1),
        BorderSizePixel = 0,
        BackgroundColor3 = themes.preset.e,
    })
    apply_corner(b, 3)
    library:apply_theme(b, "e", "BackgroundColor3")

    local key_text = library:create("TextLabel", {
        FontFace = library.font,
        TextColor3 = themes.preset.text,
        BorderSizePixel = 0,
        Text = "...",
        Parent = b,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center,
        Size = dim2(1, 0, 1, 0),
        TextSize = 11,
        ZIndex = 2,
    })

    local mode_popup = library:create("Frame", {
        Parent = library.gui,
        Visible = false,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = themes.preset.a,
        ZIndex = 100,
    })
    apply_corner(mode_popup, 4)
    library:apply_theme(mode_popup, "a", "BackgroundColor3")

    local mode_holder = library:create("Frame", {
        Parent = mode_popup,
        Position = dim2(0, 1, 0, 1),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = themes.preset.c,
        ZIndex = 101,
    })
    apply_corner(mode_holder, 3)
    library:apply_theme(mode_holder, "c", "BackgroundColor3")

    library:create("UIListLayout", {
        Parent = mode_holder,
        Padding = dim(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    library:create("UIPadding", {
        PaddingTop = dim(0, 4), PaddingBottom = dim(0, 4),
        PaddingLeft = dim(0, 8), PaddingRight = dim(0, 8),
        Parent = mode_holder,
    })

    for _, m in {"Hold", "Toggle", "Always"} do
        local opt = library:create("TextButton", {
            FontFace = library.font,
            TextColor3 = themes.preset.text,
            BorderSizePixel = 0,
            Text = m,
            Parent = mode_holder,
            BackgroundTransparency = 1,
            Size = dim2(0, 60, 0, 16),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 11,
            AutoButtonColor = false,
            ZIndex = 102,
        })
        cfg.hold_instances[m] = opt

        opt.MouseButton1Click:Connect(function()
            cfg.set(m)
            cfg.set_visible(false)
            cfg.open = false
        end)
    end

    function cfg.modify_mode_color(mode)
        for _, v in mode_holder:GetChildren() do
            if v:IsA("TextButton") then
                v.TextColor3 = themes.preset.text
            end
        end
        if cfg.hold_instances[mode] then
            cfg.hold_instances[mode].TextColor3 = themes.preset.accent
        end
    end

    function cfg.set_mode(mode)
        cfg.mode = mode
        if mode == "Always" then cfg.set(true)
        elseif mode == "Hold" then cfg.set(false) end
        flags[cfg.flag]["mode"] = mode
        cfg.modify_mode_color(mode)
    end

    function cfg.set(input)
        if type(input) == "boolean" then
            local cached = input
            if cfg.mode == "Always" then cached = true end
            cfg.active = cached
            cfg.callback(cached)
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

        local txt = tostring(cfg.key) ~= "Enums" and (keys[cfg.key] or tostring(cfg.key):gsub("Enum.", "")) or nil
        local _txt = txt and (tostring(txt):gsub("KeyCode.", ""):gsub("UserInputType.", ""))
        key_text.Text = _txt and (" " .. _txt .. " ") or "..."
        key_text.TextColor3 = cfg.active and themes.preset.accent or themes.preset.text
    end

    function cfg.set_visible(bool)
        mode_popup.Visible = bool
        mode_popup.Position = dim_offset(element.AbsolutePosition.X - 40, element.AbsolutePosition.Y + element.AbsoluteSize.Y + 2)
    end

    element.MouseButton1Down:Connect(function()
        task.wait()
        key_text.Text = "..."
        cfg.binding = library:connection(uis.InputBegan, function(keycode, game_event)
            cfg.set(keycode.KeyCode or keycode.UserInputType)
            if cfg.binding then
                cfg.binding:Disconnect()
                cfg.binding = nil
            end
        end)
    end)

    element.MouseButton2Down:Connect(function()
        cfg.open = not cfg.open
        cfg.set_visible(cfg.open)
    end)

    library:connection(uis.InputBegan, function(input, game_event)
        if not game_event then
            if input.KeyCode == cfg.key then
                if cfg.mode == "Toggle" then
                    cfg.active = not cfg.active
                    cfg.set(cfg.active)
                elseif cfg.mode == "Hold" then
                    cfg.set(true)
                end
            end
        end
    end)

    library:connection(uis.InputEnded, function(input, game_event)
        if game_event then return end
        local selected_key = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType
        if selected_key == cfg.key and cfg.mode == "Hold" then
            cfg.set(false)
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            if not (library:mouse_in_frame(element) or library:mouse_in_frame(mode_holder)) then
                cfg.open = false
                cfg.set_visible(false)
            end
        end
    end)

    config_flags[cfg.flag] = cfg.set
    cfg.set({mode = cfg.mode, active = cfg.active, key = cfg.key})
    cfg.modify_mode_color(cfg.mode)

    return setmetatable(cfg, library)
end

-- =========================================================
-- NOTIFICATIONS
-- =========================================================
local notifications = { notifs = {} }

function notifications:refresh_notifs()
    for i, v in notifications.notifs do
        local Position = vec2(20, 20)
        tween_service:Create(v, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = dim_offset(Position.X, Position.Y + (i * 34))}):Play()
    end
end

function notifications:fade(path, is_fading)
    local fading = is_fading and 1 or 0
    tween_service:Create(path, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = fading}):Play()
    for _, instance in path:GetDescendants() do
        if not instance:IsA("GuiObject") then continue end
        if instance:IsA("TextLabel") then
            tween_service:Create(instance, TweenInfo.new(0.6), {TextTransparency = fading}):Play()
        elseif instance:IsA("Frame") then
            tween_service:Create(instance, TweenInfo.new(0.6), {BackgroundTransparency = fading}):Play()
        end
    end
end

local sgui = library:create("ScreenGui", {
    Name = "gs_notifs",
    Parent = (gethui and gethui()) or coregui,
})

function notifications:create_notification(options)
    local cfg = { name = options.name or "notification" }

    local outline = library:create("Frame", {
        Parent = sgui,
        Size = dim2(0, 0, 0, 0),
        Position = dim_offset(20, 20 + (#notifications.notifs * 34)),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = themes.preset.a,
    })
    apply_corner(outline, 4)
    library:apply_theme(outline, "a", "BackgroundColor3")

    local inline = library:create("Frame", {
        Parent = outline,
        Position = dim2(0, 1, 0, 1),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = themes.preset.header,
    })
    apply_corner(inline, 3)
    library:apply_theme(inline, "header", "BackgroundColor3")

    library:create("Frame", {
        Parent = outline,
        BackgroundColor3 = themes.preset.accent,
        BorderSizePixel = 0,
        Position = dim2(0, 0, 0, 2),
        Size = dim2(0, 2, 1, -4),
        ZIndex = 3,
    })
    library:apply_theme(outline, "accent", "BackgroundColor3")

    library:create("UIPadding", {
        PaddingTop = dim(0, 7),
        PaddingBottom = dim(0, 6),
        Parent = inline,
        PaddingRight = dim(0, 10),
        PaddingLeft = dim(0, 10),
    })

    library:create("TextLabel", {
        FontFace = library.font,
        Parent = inline,
        TextColor3 = themes.preset.text,
        Text = cfg.name,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = dim2(1, -4, 1, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        ZIndex = 2,
        TextSize = 12,
    })

    local index = #notifications.notifs + 1
    notifications.notifs[index] = outline
    notifications:refresh_notifs()
    notifications:fade(outline, false)

    task.spawn(function()
        task.wait(3)
        notifications.notifs[index] = nil
        notifications:fade(outline, true)
        task.wait(1)
        outline:Destroy()
    end)
end

-- =========================================================
-- EXPORT
-- =========================================================
return library, notifications
