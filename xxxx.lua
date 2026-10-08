--[[
    monolithhh.lua — Liquid Glass Edition
    - V1 (normal) / V2 (large)
    - Sub-tabs imbriqués
    - Glassify : reflets + shadow + gradient + stroke
]]

-- ============================================================================
-- SERVICES
-- ============================================================================
local uis = game:GetService("UserInputService")
local players = game:GetService("Players")
local ws = game:GetService("Workspace")
local rs = game:GetService("ReplicatedStorage")
local http_service = game:GetService("HttpService")
local gui_service = game:GetService("GuiService")
local coregui = game:GetService("CoreGui")
local tween_service = game:GetService("TweenService")

local camera = ws.CurrentCamera
local lp = players.LocalPlayer
local mouse = lp:GetMouse()
local gui_offset = gui_service:GetGuiInset().Y

local vec2 = Vector2.new
local dim2 = UDim2.new
local dim = UDim.new
local rect = Rect.new
local dim_offset = UDim2.fromOffset

local rgb = Color3.fromRGB
local hex = Color3.fromHex
local rgbseq = ColorSequence.new
local rgbkey = ColorSequenceKeypoint.new
local numseq = NumberSequence.new
local numkey = NumberSequenceKeypoint.new

local floor = math.floor
local clamp = math.clamp
local insert = table.insert
local find = table.find
local remove = table.remove
local concat = table.concat

-- ============================================================================
-- GLASS THEME
-- ============================================================================
local glass_theme = {
    -- surfaces
    background   = rgb(18, 18, 24),
    surface      = rgb(34, 34, 44),
    surface_light= rgb(46, 46, 58),
    surface_dark = rgb(14, 14, 18),

    -- accent
    accent       = rgb(130, 170, 255),
    accent_dim   = rgb(90, 130, 210),

    -- text
    text         = rgb(240, 240, 250),
    text_dim     = rgb(172, 174, 190),
    text_muted   = rgb(112, 114, 130),

    -- glass layers
    glass_top    = rgb(255, 255, 255),
    glass_bot    = rgb(0, 0, 0),
    glass_border = rgb(255, 255, 255),

    -- radii
    corner_radius       = 12,
    corner_radius_small = 9,
    corner_radius_tiny  = 7,

    -- anim
    tween_speed = 0.28,
    tween_style = Enum.EasingStyle.Quint,
}

-- ============================================================================
-- LIBRARY INIT
-- ============================================================================
getgenv().library = {
    directory = "monolithhh",
    folders = { "/fonts", "/configs" },
    flags = {},
    config_flags = {},
    connections = {},
    notifications = { notifs = {} },
    current = nil,
    theme = glass_theme,
}

local keys = {
    [Enum.KeyCode.LeftShift] = "LS",
    [Enum.KeyCode.RightShift] = "RS",
    [Enum.KeyCode.LeftControl] = "LC",
    [Enum.KeyCode.RightControl] = "RC",
    [Enum.KeyCode.Insert] = "INS",
    [Enum.KeyCode.Backspace] = "BS",
    [Enum.KeyCode.Return] = "Ent",
    [Enum.KeyCode.LeftAlt] = "LA",
    [Enum.KeyCode.RightAlt] = "RA",
    [Enum.KeyCode.CapsLock] = "CAPS",
    [Enum.KeyCode.One] = "1",
    [Enum.KeyCode.Two] = "2",
    [Enum.KeyCode.Three] = "3",
    [Enum.KeyCode.Four] = "4",
    [Enum.KeyCode.Five] = "5",
    [Enum.KeyCode.Six] = "6",
    [Enum.KeyCode.Seven] = "7",
    [Enum.KeyCode.Eight] = "8",
    [Enum.KeyCode.Nine] = "9",
    [Enum.KeyCode.Zero] = "0",
    [Enum.KeyCode.Minus] = "-",
    [Enum.KeyCode.Equals] = "=",
    [Enum.UserInputType.MouseButton1] = "MB1",
    [Enum.UserInputType.MouseButton2] = "MB2",
    [Enum.UserInputType.MouseButton3] = "MB3",
    [Enum.KeyCode.Escape] = "ESC",
    [Enum.KeyCode.Space] = "SPC",
}

library.__index = library

pcall(function()
    for _, path in next, library.folders do
        if not isfolder(library.directory .. path) then
            makefolder(library.directory .. path)
        end
    end
end)

local flags = library.flags
local config_flags = library.config_flags
local notifications = library.notifications

-- ============================================================================
-- FONT (with fallback)
-- ============================================================================
local font_ok = pcall(function()
    local font_path = library.directory .. "/fonts/main.ttf"
    local encoded_path = library.directory .. "/fonts/main_encoded.ttf"
    if not isfile(font_path) then
        writefile(font_path, game:HttpGet("https://github.com/f1nobe7650/Nebula/raw/refs/heads/main/Minecraftia-Regular.ttf"))
    end
    local minecraftia = {
        name = "Minecraftia",
        faces = {{ name = "Regular", weight = 400, style = "normal", assetId = getcustomasset(font_path) }},
    }
    if not isfile(encoded_path) then
        writefile(encoded_path, http_service:JSONEncode(minecraftia))
    end
    library.font = Font.new(getcustomasset(encoded_path), Enum.FontWeight.Regular)
end)

if not font_ok or not library.font then
    library.font = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular)
    warn("[monolithhh] fallback font")
end

-- ============================================================================
-- CORE HELPERS
-- ============================================================================
function library:tween(obj, properties, easing_style, time)
    local t = tween_service:Create(
        obj,
        TweenInfo.new(time or glass_theme.tween_speed, easing_style or glass_theme.tween_style, Enum.EasingDirection.InOut),
        properties
    )
    t:Play()
    return t
end

function library:get_transparency(obj)
    if obj:IsA("Frame") then return { "BackgroundTransparency" }
    elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then return { "TextTransparency", "BackgroundTransparency" }
    elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then return { "BackgroundTransparency", "ImageTransparency" }
    elseif obj:IsA("ScrollingFrame") then return { "BackgroundTransparency", "ScrollBarImageTransparency" }
    elseif obj:IsA("TextBox") then return { "TextTransparency", "BackgroundTransparency" }
    elseif obj:IsA("UIStroke") then return { "Transparency" }
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

function library:create(instance, options)
    local ins = Instance.new(instance)
    for prop, value in pairs(options or {}) do
        ins[prop] = value
    end
    return ins
end

function library:connection(signal, callback)
    local c = signal:Connect(callback)
    insert(library.connections, c)
    return c
end

function library:mouse_in_frame(uiobject)
    local y = uiobject.AbsolutePosition.Y <= mouse.Y and mouse.Y <= uiobject.AbsolutePosition.Y + uiobject.AbsoluteSize.Y
    local x = uiobject.AbsolutePosition.X <= mouse.X and mouse.X <= uiobject.AbsolutePosition.X + uiobject.AbsoluteSize.X
    return y and x
end

function library:round(number, float)
    local m = 1 / (float or 1)
    return floor(number * m + 0.5) / m
end

function library:convert_enum(enum)
    local parts = {}
    for p in string.gmatch(enum, "[%w_]+") do insert(parts, p) end
    local t = Enum
    for i = 2, #parts do t = t[parts[i]] end
    return t
end

function library:close_current_element(cfg)
    local path = library.current
    if path and path ~= cfg and path.set_visible then
        path.set_visible(false)
        path.open = false
    end
end

-- ============================================================================
-- GLASSIFY — reflets + shadow + gradient + stroke
-- ============================================================================
function library:glassify(frame, radius, intensity)
    radius = radius or glass_theme.corner_radius
    intensity = intensity or 1

    frame.BorderSizePixel = 0

    local existing = frame:FindFirstChildOfClass("UICorner")
    if existing then
        existing.CornerRadius = dim(0, radius)
    else
        library:create("UICorner", { Parent = frame, CornerRadius = dim(0, radius) })
    end

    local stroke = frame:FindFirstChild("GlassStroke")
    if not stroke then
        stroke = library:create("UIStroke", {
            Parent = frame, Name = "GlassStroke",
            Color = glass_theme.glass_border,
            Thickness = 1,
            Transparency = 0.78,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        })
    end

    local grad = frame:FindFirstChild("GlassGrad")
    if not grad then
        grad = library:create("UIGradient", { Parent = frame, Name = "GlassGrad", Rotation = 90 })
    end
    grad.Color = rgbseq {
        rgbkey(0,   glass_theme.surface_light),
        rgbkey(0.5, glass_theme.surface),
        rgbkey(1,   glass_theme.surface_dark),
    }
    grad.Transparency = numseq {
        numkey(0,   0.10 * intensity),
        numkey(0.5, 0.22 * intensity),
        numkey(1,   0.42 * intensity),
    }

    local hi = frame:FindFirstChild("GlassHighlight")
    if not hi then
        hi = library:create("Frame", {
            Parent = frame, Name = "GlassHighlight",
            BackgroundColor3 = glass_theme.glass_top,
            BackgroundTransparency = 0.80,
            BorderSizePixel = 0,
            Size = dim2(1, -2, 0, 1),
            Position = dim2(0, 1, 0, 0),
            ZIndex = frame.ZIndex + 1,
        })
        library:create("UICorner", { Parent = hi, CornerRadius = dim(0, 2) })
    end

    local sh = frame:FindFirstChild("GlassShadow")
    if not sh then
        sh = library:create("Frame", {
            Parent = frame, Name = "GlassShadow",
            BackgroundColor3 = glass_theme.glass_bot,
            BackgroundTransparency = 0.6,
            BorderSizePixel = 0,
            Size = dim2(1, -2, 0, 1),
            Position = dim2(0, 1, 1, -1),
            ZIndex = frame.ZIndex + 1,
        })
        library:create("UICorner", { Parent = sh, CornerRadius = dim(0, 2) })
    end

    return frame
end

-- ============================================================================
-- DRAGGIFY / RESIZIFY
-- ============================================================================
function library:draggify(frame)
    local dragging = false
    local start_size = frame.Position
    local start

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            start = input.Position
            start_size = frame.Position
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    library:connection(uis.InputChanged, function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local vx = camera.ViewportSize.X
            local vy = camera.ViewportSize.Y
            frame.Position = dim2(
                0, clamp(start_size.X.Offset + (input.Position.X - start.X), 0, vx - frame.Size.X.Offset),
                0, clamp(start_size.Y.Offset + (input.Position.Y - start.Y), 0, vy - frame.Size.Y.Offset)
            )
            library:close_current_element(nil)
        end
    end)
end

function library:resizify(frame)
    local grip = library:create("TextButton", {
        Parent = frame, Name = "ResizeGrip",
        Position = dim2(1, -12, 1, -12),
        Size = dim2(0, 12, 0, 12),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 100,
    })

    local resizing = false
    local start_size
    local start
    local og_size = frame.Size

    grip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            start = input.Position
            start_size = frame.Size
        end
    end)
    grip.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)

    library:connection(uis.InputChanged, function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            frame.Size = dim2(
                start_size.X.Scale,
                clamp(start_size.X.Offset + (input.Position.X - start.X), og_size.X.Offset, camera.ViewportSize.X),
                start_size.Y.Scale,
                clamp(start_size.Y.Offset + (input.Position.Y - start.Y), og_size.Y.Offset, camera.ViewportSize.Y)
            )
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

    local cfg = {
        name = properties.name or properties.Name or "monolithhh",
        size = properties.size or properties.Size or dim2(0, size_cfg.width, 0, size_cfg.height),
        logo = properties.logo or properties.Logo or "rbxassetid://128155293790451",
        mode = mode,
        selected_tab = nil,
        items = {},
        tweening = false,
    }

    library.items = library:create("ScreenGui", {
        Parent = coregui, Name = "\0", Enabled = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true,
    })
    library.other = library:create("ScreenGui", {
        Parent = coregui, Name = "\0", Enabled = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true,
    })

    local items = cfg.items

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

    -- top bar
    items.top_frame = library:create("Frame", {
        Parent = items.window, Name = "TopBar",
        Size = dim2(1, 0, 0, 45),
        Position = dim2(0, 0, 0, 0),
        BackgroundColor3 = glass_theme.surface_light,
        BorderSizePixel = 0,
    })
    library:glassify(items.top_frame, glass_theme.corner_radius, 0.9)

    items.logo = library:create("ImageLabel", {
        Parent = items.top_frame, Name = "Logo",
        Image = cfg.logo,
        BackgroundTransparency = 1,
        Position = dim2(0, 16, 0, 7),
        Size = dim2(0, 32, 0, 32),
    })

    items.ui_title = library:create("TextLabel", {
        Parent = items.top_frame, Name = "Title",
        FontFace = library.font,
        TextColor3 = glass_theme.text,
        Text = cfg.name,
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 1, 0),
        TextSize = 26,
    })

    -- sidebar
    items.inline = library:create("Frame", {
        Parent = items.window, Name = "Sidebar",
        Position = dim2(0, 0, 0, 44),
        Size = dim2(0, 63, 1, -44),
        BackgroundColor3 = glass_theme.background,
        BorderSizePixel = 0,
    })
    library:glassify(items.inline, glass_theme.corner_radius, 0.7)

    items.tab_button_holder = library:create("Frame", {
        Parent = items.inline, Name = "TabHolder",
        Position = dim2(0, 1, 0, 1),
        Size = dim2(1, -2, 1, -2),
        BackgroundColor3 = glass_theme.background,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
    })
    library:create("UICorner", { Parent = items.tab_button_holder, CornerRadius = dim(0, glass_theme.corner_radius) })
    library:create("UIPadding", { Parent = items.tab_button_holder, PaddingTop = dim(0, 37) })
    library:create("UIListLayout", {
        Parent = items.tab_button_holder,
        Padding = dim(0, 24),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    -- page holder
    items.page_holder = library:create("Frame", {
        Parent = items.window, Name = "PageHolder",
        Position = dim2(0, 63, 0, 45),
        Size = dim2(1, -63, 1, -45),
        BackgroundColor3 = glass_theme.surface_dark,
        BorderSizePixel = 0,
    })
    library:glassify(items.page_holder, glass_theme.corner_radius, 0.8)

    library:draggify(items.window)
    library:resizify(items.window)

    function cfg.toggle_menu(bool)
        if cfg.tweening then return end
        cfg.tweening = true

        if bool then items.window.Visible = true end

        local children = items.window:GetDescendants()
        insert(children, items.window)

        local last
        for _, obj in ipairs(children) do
            local idx = library:get_transparency(obj)
            if idx then
                if type(idx) == "table" then
                    for _, p in ipairs(idx) do last = library:fade(obj, p, bool) end
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
-- TAB (with SubTab support)
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

    -- tab button (sidebar)
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

    -- main page
    items.tab = library:create("Frame", {
        Parent = library.items,
        BackgroundTransparency = 1,
        Visible = false,
        Size = dim2(1, 0, 1, 0),
        BorderSizePixel = 0,
    })

    -- subtab bar (top of tab)
    items.subtab_bar = library:create("Frame", {
        Parent = items.tab, Name = "SubTabBar",
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

    -- separator under subtab bar
    items.subtab_sep = library:create("Frame", {
        Parent = items.tab, Name = "SubTabSep",
        Size = dim2(1, -24, 0, 1),
        Position = dim2(0, 12, 0, 42),
        BackgroundColor3 = glass_theme.glass_border,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        Visible = false,
    })

    -- subtab content holder
    items.subtab_holder = library:create("Frame", {
        Parent = items.tab, Name = "SubTabHolder",
        Size = dim2(1, 0, 1, 0),
        Position = dim2(0, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    })

    -- columns will be re-pointed to active subtab
    items.left = nil
    items.right = nil

    -- subtab factory
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
            Parent = st_frame, Name = "Left",
            BackgroundTransparency = 1,
            Size = dim2(0, 100, 0, 100),
        })
        local right = library:create("Frame", {
            Parent = st_frame, Name = "Right",
            BackgroundTransparency = 1,
            Size = dim2(0, 100, 0, 100),
        })

        st.items.left = left
        st.items.right = right
        st.items.elements_left = left
        st.items.elements_right = right
        st.items.frame = st_frame
        st.items.button = nil

        setmetatable(st, library)

        -- subtab button in the bar
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
        st.items.button = btn

        st.button = btn
        st.frame = st_frame

        insert(cfg.subtabs, st)

        btn.MouseButton1Click:Connect(function()
            cfg:SetActiveSubTab(name)
        end)

        if #cfg.subtabs == 1 then
            cfg:SetActiveSubTab(name)
        else
            items.subtab_bar.Visible = true
            items.subtab_sep.Visible = true
        end

        return st
    end

    function cfg:SetActiveSubTab(name)
        cfg.active_subtab = name
        items.subtab_bar.Visible = (#cfg.subtabs > 1)
        items.subtab_sep.Visible = (#cfg.subtabs > 1)

        for _, st in ipairs(cfg.subtabs) do
            local is_active = (st.name == name)
            st.frame.Visible = is_active
            if st.button then
                library:tween(st.button, {
                    BackgroundTransparency = is_active and 0 or 0.5,
                    TextColor3 = is_active and glass_theme.text or glass_theme.text_dim,
                })
            end
            if is_active then
                items.left = st.items.left
                items.right = st.items.right
            end
        end
    end

    -- auto-create default subtab
    cfg:SubTab("Main")

    function cfg.open_tab()
        local selected = self.selected_tab
        if selected then
            selected[1].ImageColor3 = glass_theme.text_dim
            selected[2].Parent = library.items
            selected[2].Visible = false
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
        icon = properties.icon or properties.Icon or "http://www.roblox.com/asset/?id=6022668898",
        items = {},
    }

    local parent = self.items[cfg.side]
    if not parent then
        warn("[monolithhh] Section: no column for side=" .. tostring(cfg.side))
        parent = self.items.left or self.items.right
    end

    local items = cfg.items

    items.section_outline = library:create("Frame", {
        Parent = parent, Name = "Section",
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 1, 0),
        BorderSizePixel = 0,
    })

    items.section_shadow = library:create("Frame", {
        Parent = items.section_outline, Name = "Glass",
        Position = dim2(0, 1, 0, 1),
        Size = dim2(1, -2, 1, -2),
        BackgroundColor3 = glass_theme.surface,
        BorderSizePixel = 0,
    })
    library:glassify(items.section_shadow, glass_theme.corner_radius, 1.0)

    items.scrolling = library:create("ScrollingFrame", {
        Parent = items.section_shadow, Name = "Scroll",
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
        Parent = items.scrolling, Name = "Elements",
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
        library:tween(items.line, { Size = dim2(1, 0, 0, 1) })
        library:tween(items.text, { TextColor3 = glass_theme.text })
    end)
    items.section_outline.MouseLeave:Connect(function()
        library:tween(items.line, { Size = dim2(0, 0, 0, 1) })
        library:tween(items.text, { TextColor3 = glass_theme.text_dim })
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
        flag = options.flag or options.Flag or options.name or options.Name or "flag_" .. tostring(math.random(1, 99999)),
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
        library:tween(items.text, { TextColor3 = bool and glass_theme.text or glass_theme.text_dim })
        library:tween(items.toggle_outline, { BackgroundColor3 = bool and glass_theme.accent or glass_theme.surface_dark, BackgroundTransparency = bool and 0.05 or 0.4 })
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

    items.track.MouseButton1Down:Connect(function() cfg.dragging = true end)
    library:connection(uis.InputChanged, function(input)
        if cfg.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pct = (input.Position.X - items.track.AbsolutePosition.X) / items.track.AbsoluteSize.X
            cfg.set((cfg.max - cfg.min) * pct + cfg.min)
        end
    end)
    library:connection(uis.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            cfg.dragging = false
        end
    end)

    cfg.set(cfg.default)
    config_flags[cfg.flag] = cfg.set
    return setmetatable(cfg, library)
end

-- ============================================================================
-- DROPDOWN (texte centré verticalement, aligné à gauche)
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

    items.dropdown_outline = library:create("TextButton", {
        Parent = items.object,
        Text = "",
        AutoButtonColor = false,
        Size = dim2(0, 0, 0, 18),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = glass_theme.surface_dark,
        BorderSizePixel = 0,
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

    items.dropdown_holder = library:create("Frame", {
        Parent = library.items,
        Size = dim2(0, 114, 0, 0),
        Visible = false,
        Position = dim2(0, 0, 0, 0),
        BackgroundColor3 = glass_theme.surface_dark,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    library:glassify(items.dropdown_holder, glass_theme.corner_radius_tiny, 1.0)

    items.dropdown_list = library:create("Frame", {
        Parent = items.dropdown_holder,
        Size = dim2(1, -2, 0, -2),
        Position = dim2(0, 1, 0, 1),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        BorderSizePixel = 0,
    })
    library:create("UIListLayout", {
        Parent = items.dropdown_list,
        Padding = dim(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    library:create("UIPadding", {
        Parent = items.dropdown_list,
        PaddingBottom = dim(0, 6),
        PaddingTop = dim(0, 6),
        PaddingLeft = dim(0, 6),
        PaddingRight = dim(0, 6),
    })

    function cfg.render_option(text)
        local btn = library:create("TextButton", {
            Parent = items.dropdown_list,
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
        library:create("UIPadding", { Parent = btn, PaddingLeft = dim(0, 6), PaddingRight = dim(0, 6) })
        return btn
    end

    function cfg.set_visible(bool)
        items.dropdown_holder.Visible = bool
        items.arrow.Rotation = bool and 180 or 0
        items.dropdown_holder.Size = dim2(0, items.dropdown_outline.AbsoluteSize.X, 0, 0)
        items.dropdown_holder.Position = dim2(
            0,
            items.dropdown_outline.AbsolutePosition.X,
            0,
            items.dropdown_outline.AbsolutePosition.Y + items.dropdown_outline.AbsoluteSize.Y + 2
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
        for _, opt in ipairs(cfg.option_instances) do opt:Destroy() end
        cfg.option_instances = {}
        for _, opt in ipairs(list) do
            local b = cfg.render_option(opt)
            insert(cfg.option_instances, b)
            b.MouseButton1Down:Connect(function()
                if cfg.multi then
                    local i = find(cfg.multi_items, b.Text)
                    if i then remove(cfg.multi_items, i) else insert(cfg.multi_items, b.Text) end
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

    library:connection(uis.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if not (library:mouse_in_frame(items.dropdown_holder) or library:mouse_in_frame(items.object)) then
                cfg.open = false
                cfg.set_visible(false)
            end
        end
    end)

    cfg.refresh_options(cfg.options)
    cfg.set(cfg.default)

    local set = setmetatable(cfg, library)

    if cfg.name then
        local lbl = library:create("TextLabel", {
            Parent = items.object,
            FontFace = library.font,
            TextColor3 = glass_theme.text_dim,
            Text = cfg.name,
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.XY,
            TextSize = 10,
            BorderSizePixel = 0,
        })
        items.object.Size = dim2(1, 0, 0, 30)
        items.object.AutomaticSize = Enum.AutomaticSize.Y
        library:create("UIListLayout", {
            Parent = items.object,
            Padding = dim(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
        lbl.LayoutOrder = 0
        items.dropdown_outline.LayoutOrder = 1
        items.object.Size = dim2(1, 0, 0, 0)
    end

    config_flags[cfg.flag] = cfg.set
    return set
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
        color = options.color or options.Color or Color3.new(1, 1, 1),
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

    items.gear = library:create("TextButton", {
        Parent = items.row,
        BackgroundColor3 = glass_theme.surface_dark,
        BackgroundTransparency = 0.3,
        Size = dim2(0, 16, 0, 16),
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
    })
    library:create("UICorner", { Parent = items.gear, CornerRadius = dim(0, 4) })
    library:create("UIGradient", {
        Parent = items.gear,
        Color = rgbseq { rgbkey(0, cfg.color), rgbkey(1, cfg.color) },
    })

    items.name = library:create("TextLabel", {
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

    -- picker panel
    items.panel = library:create("Frame", {
        Parent = library.items,
        Visible = false,
        Size = dim2(0, 180, 0, 180),
        BackgroundColor3 = glass_theme.surface_dark,
        BorderSizePixel = 0,
        ZIndex = 100,
    })
    library:glassify(items.panel, glass_theme.corner_radius_small, 1.2)

    -- SV area
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

    items.sv_cursor = library:create("Frame", {
        Parent = items.sv,
        Size = dim2(0, 8, 0, 8),
        AnchorPoint = vec2(0.5, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 5,
    })
    library:create("UICorner", { Parent = items.sv_cursor, CornerRadius = dim(1, 0) })

    -- hue
    items.hue = library:create("TextButton", {
        Parent = items.panel,
        Size = dim2(0, 8, 1, -40),
        Position = dim2(1, -18, 0, 10),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
    })
    library:create("UICorner", { Parent = items.hue, CornerRadius = dim(0, 4) })
    library:create("UIGradient", {
        Parent = items.hue,
        Rotation = 270,
        Color = rgbseq {
            rgbkey(0, Color3.fromRGB(255, 0, 0)),
            rgbkey(0.17, Color3.fromRGB(255, 255, 0)),
            rgbkey(0.33, Color3.fromRGB(0, 255, 0)),
            rgbkey(0.5, Color3.fromRGB(0, 255, 255)),
            rgbkey(0.67, Color3.fromRGB(0, 0, 255)),
            rgbkey(0.83, Color3.fromRGB(255, 0, 255)),
            rgbkey(1, Color3.fromRGB(255, 0, 0)),
        },
    })

    items.hue_cursor = library:create("Frame", {
        Parent = items.hue,
        Size = dim2(1, 2, 0, 3),
        Position = dim2(0, -1, 0, -1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 5,
    })

    -- alpha
    items.alpha = library:create("TextButton", {
        Parent = items.panel,
        Size = dim2(1, -22, 0, 8),
        Position = dim2(0, 10, 1, -20),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
    })
    library:create("UICorner", { Parent = items.alpha, CornerRadius = dim(0, 4) })
    library:create("UIGradient", {
        Parent = items.alpha,
        Color = rgbseq { rgbkey(0, Color3.new(0, 0, 0)), rgbkey(1, Color3.new(1, 1, 1)) },
    })

    items.alpha_cursor = library:create("Frame", {
        Parent = items.alpha,
        Size = dim2(0, 3, 1, 2),
        Position = dim2(0, -1, 0, -1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 5,
    })

    local ds, dh, da = false, false, false

    function cfg.set_visible(bool)
        items.panel.Visible = bool
        items.panel.Position = dim2(0, items.gear.AbsolutePosition.X - 90, 0, items.gear.AbsolutePosition.Y + 22)
        library.current = cfg
    end

    function cfg.set(col, alpha)
        if col then h, s, v = col:ToHSV() end
        if alpha then a = alpha end
        local Color = Color3.fromHSV(h, s, v)

        items.hue_cursor.Position = dim2(0, -1, 1 - h, -1)
        items.alpha_cursor.Position = dim2(1 - a, -1, 0, -1)
        items.sv_cursor.Position = dim2(s, 0, 1 - v, 0)

        items.sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        items.gear.BackgroundColor3 = Color

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

    library:connection(uis.InputChanged, function(input)
        if (ds or dh or da) and input.UserInputType == Enum.UserInputType.MouseMovement then
            cfg.update_color()
        end
    end)

    library:connection(uis.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            ds, dh, da = false, false, false
        end
    end)

    items.gear.MouseButton1Click:Connect(function()
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
        items.name = library:create("TextLabel", {
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
    library:create("UIPadding", { Parent = items.box, PaddingLeft = dim(0, 8), PaddingRight = dim(0, 8) })

    function cfg.set(text)
        if type(text) == "boolean" then return end
        flags[cfg.flag] = text
        items.box.Text = text
        cfg.callback(text)
    end

    items.box:GetPropertyChangedSignal("Text"):Connect(function()
        cfg.set(items.box.Text)
    end)

    if cfg.default ~= "" then cfg.set(cfg.default) end
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
        items.name = library:create("TextLabel", {
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
            if input.active then cfg.active = input.active end
            items.btn.Text = cfg.key and (keys[cfg.key] or (typeof(cfg.key) == "EnumItem" and cfg.key.Name) or "NONE") or "NONE"
        end
        cfg.callback(cfg.active)
        flags[cfg.flag] = { mode = cfg.mode, key = cfg.key, active = cfg.active }
    end

    items.btn.MouseButton1Down:Connect(function()
        items.btn.Text = "..."
        local conn
        conn = uis.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                cfg.set(input.KeyCode)
                conn:Disconnect()
            end
        end)
    end)

    library:connection(uis.InputBegan, function(input, gp)
        if gp then return end
        local k = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType
        if k == cfg.key then
            if cfg.mode == "Toggle" then
                cfg.active = not cfg.active
                cfg.set(cfg.active)
            elseif cfg.mode == "Hold" then
                cfg.set(true)
            end
        end
    end)

    library:connection(uis.InputEnded, function(input)
        local k = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType
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
        library:tween(btn, { BackgroundTransparency = 0.05, TextColor3 = glass_theme.accent })
    end)
    btn.MouseLeave:Connect(function()
        library:tween(btn, { BackgroundTransparency = 0.3, TextColor3 = glass_theme.text })
    end)
    btn.MouseButton1Click:Connect(function()
        cfg.callback()
    end)

    return setmetatable(cfg, library)
end

-- ============================================================================
-- INIT CONFIG
-- ============================================================================
function library:init_config(window)
    local textbox
    local main = window:Tab({ name = "Configs", icon = "rbxassetid://72506063321241" })
    local section = main:Section({ name = "Settings", side = "left" })

    config_holder = section:Dropdown({
        name = "Configs",
        options = { "Default" },
        callback = function(opt) if textbox then textbox.set(opt) end end,
        flag = "config_name_list",
    })

    textbox = section:Textbox({ name = "Config name:", flag = "config_name_text" })

    section:Button({
        name = "Save",
        callback = function()
            local name = flags["config_name_text"]
            if name and name ~= "" then
                writefile(library.directory .. "/configs/" .. name .. ".cfg", library:get_config())
                library:update_config_list()
            end
        end,
    })
    section:Button({
        name = "Load",
        callback = function()
            local name = flags["config_name_text"]
            if name and isfile(library.directory .. "/configs/" .. name .. ".cfg") then
                library:load_config(readfile(library.directory .. "/configs/" .. name .. ".cfg"))
            end
        end,
    })
    section:Button({
        name = "Delete",
        callback = function()
            local name = flags["config_name_text"]
            if name and isfile(library.directory .. "/configs/" .. name .. ".cfg") then
                delfile(library.directory .. "/configs/" .. name .. ".cfg")
                library:update_config_list()
            end
        end,
    })

    section:Label({ name = "UI Bind" }):Keybind({
        callback = function(bool) window.toggle_menu(bool) end,
    })
end

function library:update_config_list()
    if not config_holder then return end
    local list = {}
    local ok, files = pcall(function() return listfiles(library.directory .. "/configs") end)
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
    local ok, cfg = pcall(function() return http_service:JSONDecode(json) end)
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
-- NOTIFICATIONS
-- ============================================================================
local notif = library.notifications

function notif:refresh()
    local y = 50
    for _, v in pairs(notif.notifs) do
        if v and v.Parent then
            tween_service:Create(v, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), { Position = dim_offset(20, y) }):Play()
            y = y + v.AbsoluteSize.Y + 10
        end
    end
end

function notif:create(options)
    options = options or {}
    local name = options.name or "Notification"
    local color = options.color or glass_theme.accent

    if not library.items then return end

    local card = library:create("TextButton", {
        Parent = library.items,
        Size = dim2(0, 240, 0, 34),
        BackgroundColor3 = glass_theme.surface_dark,
        BackgroundTransparency = 0.15,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
    })
    library:glassify(card, glass_theme.corner_radius_small, 1.1)

    library:create("Frame", {
        Parent = card, Name = "Accent",
        Size = dim2(0, 3, 1, -8),
        Position = dim2(0, 4, 0, 4),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
    })

    library:create("TextLabel", {
        Parent = card,
        FontFace = library.font,
        TextColor3 = glass_theme.text,
        Text = name,
        BackgroundTransparency = 1,
        Position = dim2(0, 14, 0, 0),
        Size = dim2(1, -18, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 10,
        BorderSizePixel = 0,
    })

    local i = #notif.notifs + 1
    notif.notifs[i] = card
    notif:refresh()

    task.delay(4, function()
        notif.notifs[i] = nil
        if card and card.Parent then card:Destroy() end
        notif:refresh()
    end)
end

print("[monolithhh] loaded — Liquid Glass V1/V2 + sub-tabs")
return library, notifications
