-- ==============================================================================
-- GAMESENSE UI LIBRARY (skeet.cc style + Obsidian / Library 5 API Compatibility)
-- Integrated ThemeManager & SaveManager (ConfigManager)
-- Reusable Luau Library for Roblox
-- ==============================================================================

local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)
local clonefunction = (clonefunction or copyfunction or function(func)
    return func
end)

local UserInputService: UserInputService = cloneref(game:GetService("UserInputService"))
local Players: Players                   = cloneref(game:GetService("Players"))
local TweenService: TweenService         = cloneref(game:GetService("TweenService"))
local CoreGui: CoreGui                   = cloneref(game:GetService("CoreGui"))
local RunService: RunService             = cloneref(game:GetService("RunService"))
local GuiService: GuiService             = cloneref(game:GetService("GuiService"))
local HttpService: HttpService           = cloneref(game:GetService("HttpService"))
local MarketplaceService: MarketplaceService = cloneref(game:GetService("MarketplaceService"))
local TextService: TextService               = cloneref(game:GetService("TextService"))

local isfolder   = isfolder or function(_) return false end
local isfile     = isfile or function(_) return false end
local makefolder = makefolder or function(_) end
local writefile  = writefile or function(_, _) end
local readfile   = readfile or function(_) return "" end
local delfile    = delfile or function(_) end
local listfiles  = listfiles or function(_) return {} end

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = LocalPlayer:GetMouse()
local GuiInset = GuiService:GetGuiInset().Y

local function resolve_gui_parent()
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    if syn and syn.protect_gui then
        local folder = Instance.new("Folder")
        pcall(syn.protect_gui, folder)
        folder.Parent = CoreGui
        return folder
    end
    local ok, res = pcall(function()
        local test = Instance.new("Folder")
        test.Name = "TestCore"
        test.Parent = CoreGui
        test:Destroy()
        return CoreGui
    end)
    if ok and res then return res end
    return LocalPlayer:WaitForChild("PlayerGui", 5) or LocalPlayer:FindFirstChildOfClass("PlayerGui")
end
local TargetGui = resolve_gui_parent()

-- Registry and state tables
local Labels   = {}
local Buttons  = {}
local Toggles  = {}
local Options  = {}
local Tooltips = {}

-- ThemeManager and SaveManager defined below

local library = {
    flags = {},
    config_flags = {},
    connections = {},
    notifications = { notifs = {} },

    -- Obsidian / Library 5 API compatibility
    Options = Options,
    Toggles = Toggles,
    Labels = Labels,
    Buttons = Buttons,
    Tooltips = Tooltips,
    Registry = {},
    Tabs = {},
    TabButtons = {},

    Toggled = true,
    Unloaded = false,
    ToggleKeybind = Enum.KeyCode.RightControl,

    Scheme = {
        BackgroundColor = Color3.fromRGB(13, 11, 20),
        MainColor       = Color3.fromRGB(20, 17, 30),
        AccentColor     = Color3.fromRGB(157, 92, 255),      -- Violet Électronique
        OutlineColor    = Color3.fromRGB(45, 38, 65),
        FontColor       = Color3.fromRGB(235, 235, 245),
        Font            = Font.fromEnum(Enum.Font.SourceSans),
        BackgroundImage = "rbxassetid://2151741365",
    },

    theme = {
        main_bg     = Color3.fromRGB(13, 11, 20),
        panel_bg    = Color3.fromRGB(18, 15, 28),
        section_bg  = Color3.fromRGB(23, 20, 35),
        element_bg  = Color3.fromRGB(28, 24, 42),
        border      = Color3.fromRGB(48, 40, 70),
        border_dark = Color3.fromRGB(35, 29, 52),
        accent      = Color3.fromRGB(157, 92, 255),          -- Violet Électronique
        yellow      = Color3.fromRGB(235, 215, 90),
        text        = Color3.fromRGB(235, 235, 245),
        text_dark   = Color3.fromRGB(150, 145, 175),
        text_dim    = Color3.fromRGB(100, 95, 125),
    },

    ThemeGradients = {
        ["Electric Violet"] = { Color3.fromRGB(16, 12, 28), Color3.fromRGB(28, 15, 48) },
        ["Cyber Matrix"]   = { Color3.fromRGB(7, 16, 11),  Color3.fromRGB(12, 32, 20) },
        ["Default"]        = { Color3.fromRGB(18, 18, 22), Color3.fromRGB(10, 26, 22) },
        ["BBot"]           = { Color3.fromRGB(28, 26, 32), Color3.fromRGB(22, 16, 28) },
        ["Fatality"]       = { Color3.fromRGB(24, 18, 48), Color3.fromRGB(42, 14, 38) },
        ["Jester"]         = { Color3.fromRGB(26, 22, 28), Color3.fromRGB(38, 18, 28) },
        ["Mint"]           = { Color3.fromRGB(22, 28, 26), Color3.fromRGB(16, 34, 28) },
        ["Tokyo Night"]    = { Color3.fromRGB(20, 20, 32), Color3.fromRGB(32, 24, 52) },
        ["Ubuntu"]         = { Color3.fromRGB(36, 30, 30), Color3.fromRGB(48, 22, 14) },
        ["Quartz"]         = { Color3.fromRGB(22, 24, 34), Color3.fromRGB(24, 36, 48) },
        ["Nord"]           = { Color3.fromRGB(42, 48, 60), Color3.fromRGB(32, 38, 48) },
        ["Dracula"]        = { Color3.fromRGB(34, 32, 48), Color3.fromRGB(48, 28, 52) },
        ["Monokai"]        = { Color3.fromRGB(28, 28, 24), Color3.fromRGB(38, 22, 30) },
        ["Gruvbox"]        = { Color3.fromRGB(36, 34, 30), Color3.fromRGB(44, 26, 22) },
        ["Solarized"]      = { Color3.fromRGB(6, 40, 50),  Color3.fromRGB(0, 24, 32) },
        ["Catppuccin"]     = { Color3.fromRGB(28, 26, 42), Color3.fromRGB(44, 28, 48) },
        ["One Dark"]       = { Color3.fromRGB(28, 32, 40), Color3.fromRGB(40, 28, 48) },
        ["Cyberpunk"]      = { Color3.fromRGB(24, 20, 42), Color3.fromRGB(12, 38, 30) },
        ["Oceanic Next"]   = { Color3.fromRGB(20, 32, 38), Color3.fromRGB(16, 26, 36) },
        ["Material"]       = { Color3.fromRGB(20, 22, 26), Color3.fromRGB(24, 30, 44) },
    },
    current_theme_name = "Electric Violet",
}
library.__index = library

function library:GetThemeGradient(scheme, theme_name)
    if theme_name and self.ThemeGradients[theme_name] then
        local pair = self.ThemeGradients[theme_name]
        return ColorSequence.new({
            ColorSequenceKeypoint.new(0, pair[1]),
            ColorSequenceKeypoint.new(1, pair[2]),
        })
    end

    scheme = scheme or self.Scheme
    local bg = scheme.BackgroundColor or Color3.fromRGB(13, 11, 20)
    local accent = scheme.AccentColor or Color3.fromRGB(157, 92, 255)

    local c1 = Color3.fromRGB(
        math.clamp(math.floor(bg.R * 255 * 1.05 + 2), 0, 255),
        math.clamp(math.floor(bg.G * 255 * 1.05 + 2), 0, 255),
        math.clamp(math.floor(bg.B * 255 * 1.05 + 2), 0, 255)
    )
    local c2 = Color3.fromRGB(
        math.clamp(math.floor(bg.R * 255 * 0.65 + accent.R * 255 * 0.16), 0, 255),
        math.clamp(math.floor(bg.G * 255 * 0.65 + accent.G * 255 * 0.16), 0, 255),
        math.clamp(math.floor(bg.B * 255 * 0.65 + accent.B * 255 * 0.16), 0, 255)
    )

    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, c1),
        ColorSequenceKeypoint.new(1, c2),
    })
end

-- ==============================================================================
-- HELPERS & UTILITY
-- ==============================================================================
function library:create(instance, options)
    local ins = Instance.new(instance)
    for prop, value in pairs(options) do
        ins[prop] = value
    end
    return ins
end

function library:tween(obj, properties, easing_style, time)
    local tw = TweenService:Create(obj, TweenInfo.new(time or 0.2, easing_style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
    tw:Play()
    return tw
end

function library:round(number, float)
    local mult = 1 / (float or 1)
    return math.floor(number * mult + 0.5) / mult
end

function library:mouse_in_frame(uiobject)
    if not uiobject or not uiobject.Parent then return false end
    local p = UserInputService:GetMouseLocation()
    return uiobject.AbsolutePosition.Y <= p.Y and p.Y <= uiobject.AbsolutePosition.Y + uiobject.AbsoluteSize.Y
       and uiobject.AbsolutePosition.X <= p.X and p.X <= uiobject.AbsolutePosition.X + uiobject.AbsoluteSize.X
end

function library:connection(sig, callback)
    local conn = sig:Connect(callback)
    table.insert(library.connections, conn)
    return conn
end

local function make_corner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 3)
    corner.Parent = instance
    return corner
end

local function make_stroke(instance, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = color or library.theme.border
    stroke.Thickness = thickness or 1
    stroke.Parent = instance
    return stroke
end

local function make_draggable(frame, drag_handle)
    local handle = drag_handle or frame
    local dragging, dragStart, startPos = false, nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ==============================================================================
-- REGISTRY & THEME SYNCHRONIZATION
-- ==============================================================================
function library:AddToRegistry(instance, properties, isScheme)
    if not instance then return end
    library.Registry[instance] = {
        Properties = properties,
        IsScheme = isScheme or false
    }
end

function library:RemoveFromRegistry(instance)
    library.Registry[instance] = nil
end

function library:UpdateTheme()
    library.theme.main_bg = library.Scheme.BackgroundColor
    library.theme.panel_bg = library.Scheme.MainColor
    library.theme.section_bg = library.Scheme.MainColor
    library.theme.element_bg = Color3.fromRGB(
        math.clamp(math.floor(library.Scheme.MainColor.R * 255 + 6), 0, 255),
        math.clamp(math.floor(library.Scheme.MainColor.G * 255 + 6), 0, 255),
        math.clamp(math.floor(library.Scheme.MainColor.B * 255 + 6), 0, 255)
    )
    library.theme.border = library.Scheme.OutlineColor
    library.theme.border_dark = Color3.fromRGB(
        math.clamp(math.floor(library.Scheme.OutlineColor.R * 255 * 0.75), 0, 255),
        math.clamp(math.floor(library.Scheme.OutlineColor.G * 255 * 0.75), 0, 255),
        math.clamp(math.floor(library.Scheme.OutlineColor.B * 255 * 0.75), 0, 255)
    )
    library.theme.accent = library.Scheme.AccentColor
    library.theme.text = library.Scheme.FontColor

    -- 1. Update Registry items
    for instance, data in pairs(library.Registry) do
        if instance and instance.Parent then
            pcall(function()
                for prop, schemeIndex in pairs(data.Properties) do
                    if schemeIndex == "BackgroundColor" then
                        instance[prop] = library.Scheme.BackgroundColor
                    elseif schemeIndex == "MainColor" then
                        instance[prop] = library.Scheme.MainColor
                    elseif schemeIndex == "AccentColor" then
                        instance[prop] = library.Scheme.AccentColor
                    elseif schemeIndex == "OutlineColor" then
                        instance[prop] = library.Scheme.OutlineColor
                    elseif schemeIndex == "FontColor" then
                        instance[prop] = library.Scheme.FontColor
                    end
                end
            end)
        end
    end

    -- 2. Dynamically update Window hierarchy colors and background gradient
    if library.Window and library.Window.main then
        local main = library.Window.main
        if library.Window.bg_gradient then
            library.Window.bg_gradient.Color = library:GetThemeGradient(library.Scheme, library.current_theme_name)
        end
        if library.Window.title_label then
            library.Window.title_label.Text = '<font color="#FFFFFF">ezwin</font><font color="#' .. library.Scheme.AccentColor:ToHex() .. '">.cc</font>'
        end
        if library.Window.sidebar then
            library.Window.sidebar.BackgroundColor3 = library.Scheme.BackgroundColor
        end

        for _, desc in ipairs(main:GetDescendants()) do
            pcall(function()
                if desc:IsA("UIStroke") then
                    if desc.Name ~= "AccentStroke" then
                        desc.Color = library.Scheme.OutlineColor
                    else
                        desc.Color = library.Scheme.AccentColor
                    end
                elseif desc:IsA("Frame") then
                    if desc.Name:match("^Section_") or desc.Name:match("^Card_") or desc.Name == "WelcomeBanner" or desc.Name == "FriendsInner" then
                        desc.BackgroundColor3 = library.Scheme.MainColor
                    elseif desc.Name == "TopAccent" or desc.Name == "AccentLine" or desc.Name == "TopStripe" then
                        desc.BackgroundColor3 = library.Scheme.AccentColor
                    end
                elseif desc:IsA("ScrollingFrame") then
                    desc.ScrollBarImageColor3 = library.Scheme.AccentColor
                end
            end)
        end
    end

    -- 3. Update theme in screen popups
    if library.screen then
        for _, desc in ipairs(library.screen:GetChildren()) do
            pcall(function()
                if desc.Name:match("^DropdownPopup_") or desc.Name:match("^ColorPickerPopup_") then
                    desc.BackgroundColor3 = library.Scheme.MainColor
                    local stroke = desc:FindFirstChildOfClass("UIStroke")
                    if stroke then stroke.Color = library.Scheme.OutlineColor end
                end
            end)
        end
    end
end

function library:SetFont(font)
    if typeof(font) == "EnumItem" then
        library.Scheme.Font = Font.fromEnum(font)
    elseif typeof(font) == "Font" then
        library.Scheme.Font = font
    end
end

function library:SetBackgroundImage(url)
    library.Scheme.BackgroundImage = url or ""
    if library.Window and library.Window.background_image then
        library.Window.background_image.Image = url or ""
        library.Window.background_image.Visible = (url ~= nil and url ~= "")
    end
end

-- ==============================================================================
-- NOTIFICATION SYSTEM (gamesense sleek toast)
-- ==============================================================================
local notif_container = nil
local function ensure_notif_container()
    if notif_container and notif_container.Parent then return notif_container end
    notif_container = library:create("Frame", {
        Name = "GameSense_Notifs",
        Size = UDim2.new(0, 260, 1, -20),
        Position = UDim2.new(1, -270, 0, 10),
        BackgroundTransparency = 1,
        Parent = TargetGui
    })
    library:create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 6),
        Parent = notif_container
    })
    return notif_container
end

function library:Notify(options)
    local title = "Notification"
    local desc = ""
    local duration = 4

    if type(options) == "string" then
        desc = options
    elseif type(options) == "table" then
        title = options.Title or options.title or title
        desc = options.Description or options.description or options.Text or options.text or ""
        duration = options.Time or options.time or options.Duration or duration
    end

    local holder = ensure_notif_container()

    local toast = library:create("Frame", {
        Name = "Toast",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = library.theme.panel_bg,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 40, 0, 0),
        BackgroundTransparency = 0,
        Parent = holder
    })
    make_corner(toast, 3)
    make_stroke(toast, library.theme.border, 1)

    local top_bar = library:create("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = library.theme.accent,
        BorderSizePixel = 0,
        Parent = toast
    })

    local pad = library:create("UIPadding", {
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = toast
    })

    local content_box = library:create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = toast
    })
    library:create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = content_box
    })

    if title and title ~= "" then
        library:create("TextLabel", {
            Text = title,
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            TextColor3 = library.theme.text,
            TextSize = 12,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = content_box
        })
    end

    if desc and desc ~= "" then
        library:create("TextLabel", {
            Text = desc,
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            TextColor3 = library.theme.text_dark,
            TextSize = 11,
            TextWrapped = true,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = content_box
        })
    end

    -- Timer bar tween
    top_bar.Size = UDim2.new(1, 0, 0, 2)
    library:tween(top_bar, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear, duration)

    task.delay(duration, function()
        if toast and toast.Parent then
            local tw = library:tween(toast, { BackgroundTransparency = 1 }, nil, 0.25)
            tw.Completed:Connect(function()
                toast:Destroy()
            end)
        end
    end)

    return toast
end

-- ==============================================================================
-- LUCIDE ICON API
-- ==============================================================================
local FetchIcons = false
local Icons = nil

local function is_valid_custom_icon(icon)
    return typeof(icon) == "string" and (icon:match("^rbxasset://textures/") or icon:match("roblox%.com/asset/%?id=") or icon:match("^rbxthumb://type="))
end

local function is_custom_asset_icon(icon, include_asset_id)
    return typeof(icon) == "string" and (icon:match("^content://") or icon:match("^rbxasset://%x+/") or icon:match("^rbxasset://[^/]+/") or (include_asset_id == true and icon:match("^rbxassetid://")))
end

function library:GetIcon(icon_name)
    if not FetchIcons or not Icons then
        return nil
    end

    local success, icon = pcall(Icons.GetAsset, icon_name)
    if not success or not icon then
        return nil
    end

    local font_success, font_icon = false, nil
    if Icons.GetFontAsset then
        font_success, font_icon = pcall(Icons.GetFontAsset, icon_name)
    end

    if font_success and font_icon and font_icon.FontFace and font_icon.Text then
        local merged = table.clone(icon)
        merged.FontFace = font_icon.FontFace
        merged.Text = font_icon.Text
        return merged
    end

    return icon
end

function library:GetCustomIcon(icon_name)
    if not icon_name then
        return nil
    end

    if tonumber(icon_name) then
        icon_name = string.format("rbxassetid://%s", tostring(icon_name))
    end

    if is_custom_asset_icon(icon_name, true) then
        return {
            Url = icon_name,
            ImageRectOffset = Vector2.zero,
            ImageRectSize = Vector2.zero,
        }
    elseif is_valid_custom_icon(icon_name) then
        return {
            Url = icon_name,
            ImageRectOffset = Vector2.zero,
            ImageRectSize = Vector2.zero,
            Custom = true,
        }
    end

    return library:GetIcon(icon_name)
end

function library:ApplyIcon(image_gui, icon, rotation)
    if not image_gui or not icon then
        return
    end

    if not (image_gui:IsA("ImageLabel") or image_gui:IsA("ImageButton")) then
        return
    end

    image_gui.Rotation = rotation or image_gui.Rotation

    local font_label = image_gui:FindFirstChild("__IconFont")
    if icon.FontFace and icon.Text then
        if not font_label then
            font_label = library:create("TextLabel", {
                Name = "__IconFont",
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                RichText = false,
                TextScaled = false,
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Center,
                Parent = image_gui,
            })

            local function sync_label()
                if not font_label.Parent then return end
                font_label.TextColor3 = image_gui.ImageColor3
                font_label.TextTransparency = image_gui.ImageTransparency
            end

            local function sync_size()
                if not font_label.Parent then return end
                local absolute = image_gui.AbsoluteSize
                local side = math.min(absolute.X, absolute.Y)
                font_label.TextSize = math.max(1, math.floor(side + 0.5))
            end

            sync_label()
            sync_size()

            image_gui:GetPropertyChangedSignal("ImageColor3"):Connect(sync_label)
            image_gui:GetPropertyChangedSignal("ImageTransparency"):Connect(sync_label)
            image_gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(sync_size)
        end

        font_label.FontFace = icon.FontFace
        font_label.Text = icon.Text
        font_label.TextScaled = false
        font_label.TextWrapped = false
        font_label.TextXAlignment = Enum.TextXAlignment.Center
        font_label.TextYAlignment = Enum.TextYAlignment.Center
        font_label.TextColor3 = image_gui.ImageColor3
        font_label.TextTransparency = image_gui.ImageTransparency

        local absolute = image_gui.AbsoluteSize
        local side = math.min(absolute.X, absolute.Y)
        if side > 0 then
            font_label.TextSize = math.max(1, math.floor(side + 0.5))
        else
            font_label.TextSize = math.max(1, math.floor(math.min(image_gui.Size.X.Offset, image_gui.Size.Y.Offset) + 0.5))
        end

        font_label.Visible = true
        image_gui.ClipsDescendants = true
        image_gui.Image = ""
        return
    end

    if font_label then
        font_label:Destroy()
    end

    image_gui.Image = icon.Url or image_gui.Image
    image_gui.ImageRectOffset = icon.ImageRectOffset or image_gui.ImageRectOffset
    image_gui.ImageRectSize = icon.ImageRectSize or image_gui.ImageRectSize
end

-- Chargeur Lucide en ligne
local icons_ok, icons_module = pcall(function()
    return (loadstring(game:HttpGet("https://raw.githubusercontent.com/notpoiu/lucide-roblox-direct/refs/heads/main/source.lua")))()
end)
if icons_ok and icons_module then
    FetchIcons = true
    Icons = icons_module
end

-- ==============================================================================
-- ESP PREVIEW BUILDER
-- ==============================================================================
local ESP_BONES_R15 = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
}

local ESP_BONES_R6 = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
    {"Torso", "Left Leg"}, {"Torso", "Right Leg"},
}

local function resolve_image(src)
    if type(src) ~= "string" or src == "" then return "" end
    if src:match("^%d+$") then return "rbxassetid://" .. src end
    if src:match("^rbxassetid://") or src:match("^rbxasset://") or src:match("^rbxthumb://") then
        return src
    end
    if src:match("^https?://") then
        local ok, id = pcall(function()
            local data = game:HttpGet(src)
            local fname = "esp_preview_" .. tostring(math.random(1, 2147483647)) .. ".png"
            writefile(fname, data)
            local getasset = getcustomasset or getsynasset
            return getasset(fname)
        end)
        if ok and type(id) == "string" and id ~= "" then return id end
    end
    return src
end

function library:BuildESPPreview(parent, options)
    options = options or {}
    local height = options.height or 200
    local esp_color = options.color or options.Color or library.theme.accent
    local player_name = options.player or options.Player or (LocalPlayer.Name or "Player")
    local image_src = options.image or options.Image

    local show_char = options.character
    if show_char == nil then show_char = (image_src == nil) end
    local show_box = options.box
    if show_box == nil then show_box = true end
    local show_skel = options.skeleton
    if show_skel == nil then show_skel = true end
    local show_health = options.health
    if show_health == nil then show_health = true end
    local show_name = options.nametag
    if show_name == nil then show_name = true end

    local char_transparency = options.transparency
    if char_transparency == nil then char_transparency = 0.35 end

    local holder = library:create("Frame", {
        Parent = parent,
        Name = "ESPPreview",
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = Color3.fromRGB(11, 11, 11),
        BorderSizePixel = 0,
    })
    make_corner(holder, 3)
    make_stroke(holder, library.theme.border_dark, 1)

    local image_label = library:create("ImageLabel", {
        Name = "CustomImage",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = image_src and resolve_image(image_src) or "",
        ImageTransparency = options.image_transparency or 0,
        ScaleType = Enum.ScaleType.Fit,
        Visible = image_src ~= nil,
        ZIndex = 1,
        Parent = holder,
    })
    make_corner(image_label, 3)

    local viewport = library:create("ViewportFrame", {
        Name = "CharacterView",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LightColor = Color3.fromRGB(255, 255, 255),
        LightDirection = Vector3.new(-1, -0.6, -1),
        Ambient = Color3.fromRGB(215, 215, 215),
        ZIndex = 2,
        Parent = holder,
    })
    make_corner(viewport, 3)

    local view_cam = Instance.new("Camera")
    view_cam.FieldOfView = 40
    viewport.CurrentCamera = view_cam
    view_cam.Parent = viewport

    local world = library:create("WorldModel", {
        Name = "World",
        Parent = viewport,
    })

    local box = library:create("Frame", {
        Name = "Box",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 2),
        Size = UDim2.new(0.42, 0, 0.85, 0),
        BackgroundTransparency = 1,
        Visible = show_box,
        ZIndex = 3,
        Parent = holder,
    })
    local box_stroke = make_stroke(box, esp_color, 1)

    local health_bg = library:create("Frame", {
        Name = "Health",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(0.29, -3, 0.5, 2),
        Size = UDim2.new(0, 3, 0.85, 0),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        Visible = show_health,
        ZIndex = 3,
        Parent = holder,
    })
    local health_fill = library:create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(90, 220, 120),
        BorderSizePixel = 0,
        ZIndex = 4,
        Parent = health_bg,
    })

    local name_label = library:create("TextLabel", {
        Name = "NameTag",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 3),
        Size = UDim2.new(1, -16, 0, 14),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSansBold,
        Text = player_name,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 11,
        TextStrokeTransparency = 0.4,
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 4,
        Visible = show_name,
        Parent = holder,
    })

    local function clear_view()
        for _, child in ipairs(world:GetChildren()) do
            child:Destroy()
        end
    end

    local function build_dummy()
        local model = Instance.new("Model")
        model.Name = "Dummy"
        local function mk(name, size, pos, color)
            local p = Instance.new("Part")
            p.Name = name
            p.Size = size
            p.Position = pos
            p.Anchored = true
            p.CanCollide = false
            p.CanQuery = false
            p.Material = Enum.Material.SmoothPlastic
            p.Color = color
            p.Transparency = 0.3
            p.Parent = model
            return p
        end
        local skin = Color3.fromRGB(225, 195, 160)
        local shirt = Color3.fromRGB(45, 85, 140)
        local pants = Color3.fromRGB(35, 40, 50)
        local head = mk("Head", Vector3.new(1.2, 1.2, 1.2), Vector3.new(0, 4.5, 0), skin)
        local torso = mk("Torso", Vector3.new(2, 2, 1), Vector3.new(0, 3, 0), shirt)
        mk("Left Arm", Vector3.new(1, 2, 1), Vector3.new(-1.5, 3, 0), shirt)
        mk("Right Arm", Vector3.new(1, 2, 1), Vector3.new(1.5, 3, 0), shirt)
        mk("Left Leg", Vector3.new(1, 2, 1), Vector3.new(-0.5, 1, 0), pants)
        mk("Right Leg", Vector3.new(1, 2, 1), Vector3.new(0.5, 1, 0), pants)
        model.PrimaryPart = torso
        return model
    end

    local center = Vector3.new(0, 2.5, 0)
    local dist = 8
    local current_yaw = 0
    local current_pitch = 0

    local function update_cam_transform()
        if not view_cam or not center then return end
        local cam_cf = CFrame.new(center)
            * CFrame.Angles(0, current_yaw, 0)
            * CFrame.Angles(current_pitch, 0, 0)
            * CFrame.new(0, 0, -dist)
        view_cam.CFrame = CFrame.lookAt(cam_cf.Position, center)
    end

    local is_dragging_rot = false
    local last_rot_pos = nil
    local last_click_time = 0

    holder.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local now = tick()
            if now - last_click_time < 0.28 then
                current_yaw = 0
                current_pitch = 0
                update_cam_transform()
                is_dragging_rot = false
                return
            end
            last_click_time = now
            is_dragging_rot = true
            last_rot_pos = input.Position
        end
    end)

    holder.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and is_dragging_rot and last_rot_pos then
            local delta = input.Position - last_rot_pos
            last_rot_pos = input.Position
            current_yaw = current_yaw + (delta.X * 0.018)
            current_pitch = math.clamp(current_pitch - (delta.Y * 0.01), math.rad(-30), math.rad(30))
            update_cam_transform()
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            is_dragging_rot = false
            last_rot_pos = nil
        end
    end)

    local function render()
        clear_view()
        local clone = nil
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.Archivable = true
            clone = char:Clone()
            char.Archivable = false
        end

        if not clone then
            clone = build_dummy()
        end

        local root = clone:FindFirstChild("HumanoidRootPart") or clone:FindFirstChild("Torso") or clone.PrimaryPart
        if not root then
            clone:Destroy()
            return
        end

        for _, item in ipairs(clone:GetDescendants()) do
            if item:IsA("Script") or item:IsA("LocalScript") or item:IsA("Sound") or item:IsA("ParticleEmitter") then
                item:Destroy()
            elseif item:IsA("BasePart") then
                item.Anchored = true
                item.CanCollide = false
                item.CanTouch = false
                item.CanQuery = false
                if not show_char then
                    item.Transparency = 1
                else
                    item.Transparency = math.clamp(char_transparency, 0, 1)
                end
            end
        end

        clone.Parent = world
        clone.PrimaryPart = root
        -- Réinitialiser la CFrame du clone pour qu'il soit parfaitement droit et orienté vers l'avant (de face)
        clone:PivotTo(CFrame.new(0, 0, 0))

        local cf, size = clone:GetBoundingBox()
        center = cf.Position
        local max_dim = math.max(size.X, size.Y, size.Z)
        dist = max_dim / (2 * math.tan(math.rad(view_cam.FieldOfView / 2))) * 1.08

        update_cam_transform()

        if show_skel then
            local is_r15 = clone:FindFirstChild("UpperTorso") ~= nil
            local bone_pairs = is_r15 and ESP_BONES_R15 or ESP_BONES_R6

            for _, pair in ipairs(bone_pairs) do
                local a = clone:FindFirstChild(pair[1])
                local b = clone:FindFirstChild(pair[2])
                if a and b then
                    local aPos = a.Position
                    local bPos = b.Position
                    local len = (bPos - aPos).Magnitude
                    if len > 0.05 then
                        local bone = Instance.new("Part")
                        bone.Anchored = true
                        bone.CanCollide = false
                        bone.CanQuery = false
                        bone.Material = Enum.Material.SmoothPlastic
                        bone.Color = esp_color
                        bone.Size = Vector3.new(0.07, 0.07, len)
                        bone.CFrame = CFrame.lookAt((aPos + bPos) * 0.5, bPos)
                        bone.Parent = world
                    end
                end
            end
        end
    end

    render()

    local char_conn = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.35)
        render()
    end)

    return {
        frame = holder,
        viewport = viewport,
        connection = char_conn,
        set_box = function(v) show_box = v; box.Visible = v end,
        set_skeleton = function(v) show_skel = v; render() end,
        set_character = function(v) show_char = v; render() end,
        set_transparency = function(v) char_transparency = v; render() end,
        set_health = function(v) health_bg.Visible = v end,
        set_name = function(v) name_label.Text = v end,
        set_image = function(src)
            image_src = src
            image_label.Image = resolve_image(src)
            image_label.Visible = src ~= nil and src ~= ""
            if src ~= nil and src ~= "" and options.character == nil then
                show_char = false
                render()
            end
        end,
        set_player = function(n) name_label.Text = n end,
        set_color = function(c) esp_color = c; box_stroke.Color = c; render() end,
        set_health_percent = function(p)
            health_fill.Size = UDim2.new(math.clamp(p, 0, 1), 0, 1, 0)
        refresh = render,
        reset_rotation = function()
            current_yaw = 0
            current_pitch = 0
            update_cam_transform()
        end,
        set_rotation = function(yaw, pitch)
            current_yaw = yaw or 0
            current_pitch = pitch or 0
            update_cam_transform()
        end,
    }
end

-- ==============================================================================
-- THEME MANAGER (Obsidian Addon Ported & Embedded)
-- ==============================================================================
local ThemeManager = {
    Library = nil,
    Folder = "ObsidianLibSettings",
    AppliedToTab = false,
    DefaultThemeName = nil,
    ContrastLabel = nil,

    BuiltInThemes = {
        ["Electric Violet"] = {
            1,
            { FontColor = "ebebf5", MainColor = "14111e", AccentColor = "9d5cff", BackgroundColor = "0d0b14", OutlineColor = "2d2641", BackgroundImage = "rbxassetid://2151741365" },
        },
        ["Cyber Matrix"] = {
            2,
            { FontColor = "e6ffe6", MainColor = "0d1811", AccentColor = "00ff9f", BackgroundColor = "08100b", OutlineColor = "183824", BackgroundImage = "rbxassetid://2151741365" },
        },
        ["Default"] = {
            3,
            { FontColor = "ffffff", MainColor = "191919", AccentColor = "00d7a5", BackgroundColor = "0f0f0f", OutlineColor = "282828", BackgroundImage = "" },
        },
        ["BBot"] = {
            2,
            { FontColor = "ffffff", MainColor = "1e1e1e", AccentColor = "7e48a3", BackgroundColor = "232323", OutlineColor = "141414", BackgroundImage = "" },
        },
        ["Fatality"] = {
            3,
            { FontColor = "ffffff", MainColor = "1e1842", AccentColor = "c50754", BackgroundColor = "191335", OutlineColor = "3c355d", BackgroundImage = "" },
        },
        ["Jester"] = {
            4,
            { FontColor = "ffffff", MainColor = "242424", AccentColor = "db4467", BackgroundColor = "1c1c1c", OutlineColor = "373737", BackgroundImage = "" },
        },
        ["Mint"] = {
            5,
            { FontColor = "ffffff", MainColor = "242424", AccentColor = "3db488", BackgroundColor = "1c1c1c", OutlineColor = "373737", BackgroundImage = "" },
        },
        ["Tokyo Night"] = {
            6,
            { FontColor = "ffffff", MainColor = "191925", AccentColor = "6759b3", BackgroundColor = "16161f", OutlineColor = "323232", BackgroundImage = "" },
        },
        ["Ubuntu"] = {
            7,
            { FontColor = "ffffff", MainColor = "3e3e3e", AccentColor = "e2581e", BackgroundColor = "323232", OutlineColor = "191919", BackgroundImage = "" },
        },
        ["Quartz"] = {
            8,
            { FontColor = "ffffff", MainColor = "232330", AccentColor = "426e87", BackgroundColor = "1d1b26", OutlineColor = "27232f", BackgroundImage = "" },
        },
        ["Nord"] = {
            9,
            { FontColor = "eceff4", MainColor = "3b4252", AccentColor = "88c0d0", BackgroundColor = "2e3440", OutlineColor = "4c566a", BackgroundImage = "" },
        },
        ["Dracula"] = {
            10,
            { FontColor = "f8f8f2", MainColor = "44475a", AccentColor = "ff79c6", BackgroundColor = "282a36", OutlineColor = "6272a4", BackgroundImage = "" },
        },
        ["Monokai"] = {
            11,
            { FontColor = "f8f8f2", MainColor = "272822", AccentColor = "f92672", BackgroundColor = "1e1f1c", OutlineColor = "49483e", BackgroundImage = "" },
        },
        ["Gruvbox"] = {
            12,
            { FontColor = "ebdbb2", MainColor = "3c3836", AccentColor = "fb4934", BackgroundColor = "282828", OutlineColor = "504945", BackgroundImage = "" },
        },
        ["Solarized"] = {
            13,
            { FontColor = "839496", MainColor = "073642", AccentColor = "cb4b16", BackgroundColor = "002b36", OutlineColor = "586e75", BackgroundImage = "" },
        },
        ["Catppuccin"] = {
            14,
            { FontColor = "d9e0ee", MainColor = "302d41", AccentColor = "f5c2e7", BackgroundColor = "1e1e2e", OutlineColor = "575268", BackgroundImage = "" },
        },
        ["One Dark"] = {
            15,
            { FontColor = "abb2bf", MainColor = "282c34", AccentColor = "c678dd", BackgroundColor = "21252b", OutlineColor = "5c6370", BackgroundImage = "" },
        },
        ["Cyberpunk"] = {
            16,
            { FontColor = "f9f9f9", MainColor = "262335", AccentColor = "00ff9f", BackgroundColor = "1a1a2e", OutlineColor = "413c5e", BackgroundImage = "" },
        },
        ["Oceanic Next"] = {
            17,
            { FontColor = "d8dee9", MainColor = "1b2b34", AccentColor = "6699cc", BackgroundColor = "16232a", OutlineColor = "343d46", BackgroundImage = "" },
        },
        ["Material"] = {
            18,
            { FontColor = "eeffff", MainColor = "212121", AccentColor = "82aaff", BackgroundColor = "151515", OutlineColor = "424242", BackgroundImage = "" },
        }
    }
}

function ThemeManager:SetLibrary(Lib)
    ThemeManager.Library = Lib or library
end

function ThemeManager:SetFolder(folder)
    ThemeManager.Folder = folder or "ObsidianLibSettings"
    pcall(makefolder, ThemeManager.Folder)
    pcall(makefolder, ThemeManager.Folder .. "/themes")
end

local function GetThemePath(name)
    return string.format("%s/themes/%s.json", ThemeManager.Folder, name)
end

local function GetDefaultThemePath()
    return string.format("%s/themes/default.txt", ThemeManager.Folder)
end

function ThemeManager:GetDefaultTheme()
    local path = GetDefaultThemePath()
    if not isfile(path) then return "Default", false, "Not set" end
    local ok, content = pcall(readfile, path)
    if ok and content ~= "" then
        return content, true
    end
    return "Default", false
end

function ThemeManager:SaveDefault(name)
    pcall(makefolder, ThemeManager.Folder .. "/themes")
    pcall(writefile, GetDefaultThemePath(), name)
    ThemeManager.DefaultThemeName = name
end

function ThemeManager:ReloadCustomThemes()
    local themes_path = ThemeManager.Folder .. "/themes"
    pcall(makefolder, themes_path)
    local ok, files = pcall(listfiles, themes_path)
    if not ok or type(files) ~= "table" then return {} end
    local list = {}
    for _, f in ipairs(files) do
        local name = f:match("([^/\\]+)%.json$")
        if name and name ~= "default" then
            table.insert(list, name)
        end
    end
    return list
end

function ThemeManager:GetCustomTheme(name)
    local path = GetThemePath(name)
    if not isfile(path) then return nil end
    local ok, content = pcall(readfile, path)
    if not ok then return nil end
    local ok_dec, decoded = pcall(HttpService.JSONDecode, HttpService, content)
    if ok_dec and type(decoded) == "table" then
        return decoded
    end
    return nil
end

function ThemeManager:ApplyThemeData(data)
    local lib = ThemeManager.Library or library
    local SchemeIndexes = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }

    for index, val in pairs(data) do
        local opt = lib.Options[index]
        if index == "FontFace" then
            if Enum.Font[val] then lib:SetFont(Enum.Font[val]) end
        elseif index == "BackgroundImage" then
            lib:SetBackgroundImage(val)
        elseif table.find(SchemeIndexes, index) then
            local ok, col = pcall(Color3.fromHex, val)
            if ok then
                lib.Scheme[index] = col
                if opt and opt.SetValueRGB then
                    opt:SetValueRGB(col, 0)
                elseif opt and opt.SetValue then
                    opt:SetValue(col)
                end
            end
        end
    end
    ThemeManager:ThemeUpdate()
    return true
end

function ThemeManager:ApplyTheme(name)
    if not name or name == "" then return false end
    local lib = ThemeManager.Library or library
    lib.current_theme_name = name
    local custom = ThemeManager:GetCustomTheme(name)
    if custom then
        return ThemeManager:ApplyThemeData(custom)
    end
    local builtIn = ThemeManager.BuiltInThemes[name]
    if builtIn then
        return ThemeManager:ApplyThemeData(builtIn[2])
    end
    return false
end

function ThemeManager:SaveCustomTheme(name)
    if not name or name == "" then return false end
    local lib = ThemeManager.Library or library
    local data = {
        BackgroundColor = lib.Scheme.BackgroundColor:ToHex(),
        MainColor = lib.Scheme.MainColor:ToHex(),
        AccentColor = lib.Scheme.AccentColor:ToHex(),
        OutlineColor = lib.Scheme.OutlineColor:ToHex(),
        FontColor = lib.Scheme.FontColor:ToHex(),
        BackgroundImage = lib.Scheme.BackgroundImage or "",
    }
    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, data)
    if ok then
        pcall(makefolder, ThemeManager.Folder .. "/themes")
        pcall(writefile, GetThemePath(name), encoded)
        return true
    end
    return false
end

function ThemeManager:DeleteCustomTheme(name)
    local path = GetThemePath(name)
    if isfile(path) then
        pcall(delfile, path)
        return true
    end
    return false
end

function ThemeManager:ThemeUpdate()
    local lib = ThemeManager.Library or library
    lib:UpdateTheme()
end

function ThemeManager:LoadDefault()
    local def = ThemeManager:GetDefaultTheme()
    ThemeManager:ApplyTheme(def)
end

function ThemeManager:CreateGroupBox(tab, icon)
    return tab:AddGroupbox({
        Side = "Left",
        Name = "Themes",
        IconName = icon or "paintbrush"
    })
end

function ThemeManager:CreateThemeManager(groupbox)
    local lib = ThemeManager.Library or library
    assert(lib, "Library is not set!")

    local builtInNames = {}
    for name in pairs(ThemeManager.BuiltInThemes) do
        table.insert(builtInNames, name)
    end
    table.sort(builtInNames)

    groupbox:AddLabel("Background color"):AddColorPicker("BackgroundColor", {
        Default = lib.Scheme.BackgroundColor,
        Callback = function(c) lib.Scheme.BackgroundColor = c; ThemeManager:ThemeUpdate() end
    })
    groupbox:AddLabel("Main color"):AddColorPicker("MainColor", {
        Default = lib.Scheme.MainColor,
        Callback = function(c) lib.Scheme.MainColor = c; ThemeManager:ThemeUpdate() end
    })
    groupbox:AddLabel("Accent color"):AddColorPicker("AccentColor", {
        Default = lib.Scheme.AccentColor,
        Callback = function(c) lib.Scheme.AccentColor = c; ThemeManager:ThemeUpdate() end
    })
    groupbox:AddLabel("Outline color"):AddColorPicker("OutlineColor", {
        Default = lib.Scheme.OutlineColor,
        Callback = function(c) lib.Scheme.OutlineColor = c; ThemeManager:ThemeUpdate() end
    })
    groupbox:AddLabel("Font color"):AddColorPicker("FontColor", {
        Default = lib.Scheme.FontColor,
        Callback = function(c) lib.Scheme.FontColor = c; ThemeManager:ThemeUpdate() end
    })

    groupbox:AddInput("BackgroundImage", {
        Text = "Background Image URL",
        Default = lib.Scheme.BackgroundImage or "",
        Callback = function(url) lib:SetBackgroundImage(url) end
    })

    groupbox:AddDivider()

    local themeList = groupbox:AddDropdown("ThemeManager_ThemeList", {
        Text = "Theme list",
        Values = builtInNames,
        Default = "Default",
        Callback = function(theme)
            ThemeManager:ApplyTheme(theme)
        end
    })

    groupbox:AddButton("Set as default", function()
        local selected = themeList.Value
        if selected and selected ~= "" then
            ThemeManager:SaveDefault(selected)
            lib:Notify(string.format("Set default theme to %q", selected))
        end
    end)

    groupbox:AddDivider()

    local customName = groupbox:AddInput("ThemeManager_CustomThemeName", {
        Text = "Custom theme name",
        Default = ""
    })

    local customList = groupbox:AddDropdown("ThemeManager_CustomThemeList", {
        Text = "Custom themes",
        Values = ThemeManager:ReloadCustomThemes(),
        Default = "None",
        Callback = function(t)
            ThemeManager:ApplyTheme(t)
        end
    })

    groupbox:AddButton("Save custom theme", function()
        local name = customName.Value
        if name and name ~= "" then
            ThemeManager:SaveCustomTheme(name)
            customList:SetValues(ThemeManager:ReloadCustomThemes())
            lib:Notify(string.format("Saved custom theme %q", name))
        end
    end)

    groupbox:AddButton("Delete custom theme", function()
        local selected = customList.Value
        if selected and selected ~= "" and selected ~= "None" then
            ThemeManager:DeleteCustomTheme(selected)
            customList:SetValues(ThemeManager:ReloadCustomThemes())
            lib:Notify(string.format("Deleted custom theme %q", selected))
        end
    end)

    groupbox:AddButton("Refresh theme list", function()
        customList:SetValues(ThemeManager:ReloadCustomThemes())
        lib:Notify("Refreshed themes")
    end)

    ThemeManager.AppliedToTab = true
    return groupbox
end

function ThemeManager:ApplyToTab(tab, icon)
    if ThemeManager.AppliedToTab and ThemeManager.ThemeBox then
        return ThemeManager.ThemeBox
    end
    local gb = ThemeManager:CreateGroupBox(tab, icon)
    ThemeManager.ThemeBox = gb
    return ThemeManager:CreateThemeManager(gb)
end

function ThemeManager:ApplyToGroupbox(groupbox)
    return ThemeManager:CreateThemeManager(groupbox)
end

-- ==============================================================================
-- SAVE MANAGER / CONFIG MANAGER (Obsidian Addon Ported & Embedded)
-- ==============================================================================
local SaveManager = {
    Library = nil,
    Folder = "ObsidianLibSettings",
    SubFolder = "configs",
    Ignore = {},
    IgnoreIndexes = {},
    AutoloadConfig = nil,
}

function SaveManager:SetLibrary(Lib)
    SaveManager.Library = Lib or library
end

function SaveManager:SetFolder(folder)
    SaveManager.Folder = folder or "ObsidianLibSettings"
    pcall(makefolder, SaveManager.Folder)
end

function SaveManager:SetSubFolder(sub)
    SaveManager.SubFolder = sub or "configs"
end

function SaveManager:IgnoreThemeSettings()
    SaveManager.IgnoreIndexes["BackgroundColor"] = true
    SaveManager.IgnoreIndexes["MainColor"] = true
    SaveManager.IgnoreIndexes["AccentColor"] = true
    SaveManager.IgnoreIndexes["OutlineColor"] = true
    SaveManager.IgnoreIndexes["FontColor"] = true
    SaveManager.IgnoreIndexes["FontFace"] = true
    SaveManager.IgnoreIndexes["BackgroundImage"] = true
    SaveManager.IgnoreIndexes["ThemeManager_ThemeList"] = true
    SaveManager.IgnoreIndexes["ThemeManager_CustomThemeName"] = true
    SaveManager.IgnoreIndexes["ThemeManager_CustomThemeList"] = true
end

function SaveManager:SetIgnoreIndexes(indexes)
    for _, idx in ipairs(indexes) do
        SaveManager.IgnoreIndexes[idx] = true
    end
end

local function GetConfigFullPath(name)
    local basePath = SaveManager.Folder
    if SaveManager.SubFolder and SaveManager.SubFolder ~= "" then
        pcall(makefolder, basePath .. "/" .. SaveManager.SubFolder)
        return string.format("%s/%s/%s.json", basePath, SaveManager.SubFolder, name)
    end
    return string.format("%s/%s.json", basePath, name)
end

local function GetAutoloadFullPath()
    local basePath = SaveManager.Folder
    return string.format("%s/autoload.txt", basePath)
end

function SaveManager:RefreshConfigList()
    local targetPath = SaveManager.Folder
    if SaveManager.SubFolder and SaveManager.SubFolder ~= "" then
        targetPath = targetPath .. "/" .. SaveManager.SubFolder
    end
    pcall(makefolder, targetPath)
    local ok, files = pcall(listfiles, targetPath)
    if not ok or type(files) ~= "table" then return {} end
    local list = {}
    for _, f in ipairs(files) do
        local name = f:match("([^/\\]+)%.json$")
        if name and name ~= "autoload" then
            table.insert(list, name)
        end
    end
    return list
end

function SaveManager:Save(name)
    if not name or name == "" then return false, "No name" end
    local lib = SaveManager.Library or library

    local data = { objects = {} }

    for idx, toggle in pairs(lib.Toggles) do
        if not SaveManager.IgnoreIndexes[idx] then
            table.insert(data.objects, {
                type = "Toggle",
                idx = idx,
                value = toggle.Value
            })
        end
    end

    for idx, opt in pairs(lib.Options) do
        if not SaveManager.IgnoreIndexes[idx] and opt.Type ~= "Toggle" then
            if opt.Type == "Slider" then
                table.insert(data.objects, {
                    type = "Slider",
                    idx = idx,
                    value = tostring(opt.Value)
                })
            elseif opt.Type == "Dropdown" then
                table.insert(data.objects, {
                    type = "Dropdown",
                    idx = idx,
                    value = opt.Value,
                    multi = opt.Multi
                })
            elseif opt.Type == "ColorPicker" then
                table.insert(data.objects, {
                    type = "ColorPicker",
                    idx = idx,
                    value = opt.Value:ToHex(),
                    transparency = opt.Transparency or 0
                })
            elseif opt.Type == "KeyPicker" then
                table.insert(data.objects, {
                    type = "KeyPicker",
                    idx = idx,
                    key = opt.Value,
                    mode = opt.Mode or "Toggle",
                    toggled = opt.Toggled
                })
            elseif opt.Type == "Input" then
                table.insert(data.objects, {
                    type = "Input",
                    idx = idx,
                    text = opt.Value
                })
            end
        end
    end

    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, data)
    if ok then
        pcall(writefile, GetConfigFullPath(name), encoded)
        return true
    end
    return false, "JSON encoding error"
end

function SaveManager:Load(name)
    if not name or name == "" then return false, "No name" end
    local path = GetConfigFullPath(name)
    if not isfile(path) then return false, "File does not exist" end
    local ok, content = pcall(readfile, path)
    if not ok then return false, "Read failed" end
    local ok_dec, decoded = pcall(HttpService.JSONDecode, HttpService, content)
    if not ok_dec or type(decoded) ~= "table" then return false, "Decode failed" end

    local lib = SaveManager.Library or library
    for _, obj in ipairs(decoded.objects or {}) do
        if not SaveManager.IgnoreIndexes[obj.idx] then
            local element = (obj.type == "Toggle" and lib.Toggles[obj.idx]) or lib.Options[obj.idx]
            if element then
                pcall(function()
                    if obj.type == "Toggle" then
                        element:SetValue(obj.value)
                    elseif obj.type == "Slider" then
                        element:SetValue(tonumber(obj.value))
                    elseif obj.type == "Dropdown" then
                        element:SetValue(obj.value)
                    elseif obj.type == "ColorPicker" then
                        element:SetValueRGB(Color3.fromHex(obj.value), obj.transparency or 0)
                    elseif obj.type == "KeyPicker" then
                        element:SetValue(obj.key)
                    elseif obj.type == "Input" then
                        element:SetValue(obj.text)
                    end
                end)
            end
        end
    end
    return true
end

function SaveManager:Delete(name)
    local path = GetConfigFullPath(name)
    if isfile(path) then
        pcall(delfile, path)
        return true
    end
    return false
end

function SaveManager:GetAutoloadConfig()
    local path = GetAutoloadFullPath()
    if isfile(path) then
        local ok, content = pcall(readfile, path)
        if ok and content ~= "" then
            return content, true
        end
    end
    return nil, false
end

function SaveManager:SaveAutoloadConfig(name)
    pcall(makefolder, SaveManager.Folder)
    pcall(writefile, GetAutoloadFullPath(), name)
    SaveManager.AutoloadConfig = name
end

function SaveManager:DeleteAutoLoadConfig()
    local path = GetAutoloadFullPath()
    if isfile(path) then
        pcall(delfile, path)
    end
    SaveManager.AutoloadConfig = nil
end

function SaveManager:LoadAutoloadConfig()
    local name, ok = SaveManager:GetAutoloadConfig()
    if ok and name then
        SaveManager:Load(name)
    end
end

function SaveManager:BuildConfigSection(tab, icon)
    if SaveManager.BuiltConfigSection and SaveManager.ConfigBox then
        return SaveManager.ConfigBox
    end
    local lib = SaveManager.Library or library
    assert(lib, "Library is not set!")

    local configBox = tab:AddGroupbox({
        Side = "Right",
        Name = "Configuration",
        IconName = icon or "folder-cog"
    })
    SaveManager.ConfigBox = configBox
    SaveManager.BuiltConfigSection = true

    local configName = configBox:AddInput("SaveManager_ConfigName", {
        Text = "Config name",
        Default = ""
    })

    local configList = configBox:AddDropdown("SaveManager_ConfigList", {
        Text = "Config list",
        Values = SaveManager:RefreshConfigList(),
        Default = "None"
    })

    configBox:AddButton("Create config", function()
        local name = configName.Value
        if name and name ~= "" then
            SaveManager:Save(name)
            configList:SetValues(SaveManager:RefreshConfigList())
            lib:Notify(string.format("Created config %q", name))
        end
    end)

    configBox:AddButton("Load config", function()
        local selected = configList.Value
        if selected and selected ~= "" and selected ~= "None" then
            local ok, err = SaveManager:Load(selected)
            if ok then
                lib:Notify(string.format("Loaded config %q", selected))
            else
                lib:Notify(string.format("Failed to load config: %s", tostring(err)))
            end
        end
    end)

    configBox:AddButton("Overwrite config", function()
        local selected = configList.Value
        if selected and selected ~= "" and selected ~= "None" then
            SaveManager:Save(selected)
            lib:Notify(string.format("Overwrote config %q", selected))
        end
    end)

    configBox:AddButton("Delete config", function()
        local selected = configList.Value
        if selected and selected ~= "" and selected ~= "None" then
            SaveManager:Delete(selected)
            configList:SetValues(SaveManager:RefreshConfigList())
            lib:Notify(string.format("Deleted config %q", selected))
        end
    end)

    configBox:AddButton("Refresh list", function()
        configList:SetValues(SaveManager:RefreshConfigList())
        lib:Notify("Refreshed configs")
    end)

    configBox:AddDivider()

    configBox:AddButton("Set as autoload", function()
        local selected = configList.Value
        if selected and selected ~= "" and selected ~= "None" then
            SaveManager:SaveAutoloadConfig(selected)
            lib:Notify(string.format("Set %q as autoload config", selected))
        end
    end)

    configBox:AddButton("Reset autoload", function()
        SaveManager:DeleteAutoLoadConfig()
        lib:Notify("Reset autoload config")
    end)

    return configBox
end

-- Wire references and globals
library.ThemeManager = ThemeManager
library.SaveManager = SaveManager
library.ConfigManager = SaveManager

ThemeManager:SetLibrary(library)
SaveManager:SetLibrary(library)

getgenv().Library = library
getgenv().ThemeManager = ThemeManager
getgenv().SaveManager = SaveManager
getgenv().ConfigManager = SaveManager


-- ==============================================================================
-- WINDOW / CREATEWINDOW
-- ==============================================================================
function library:CreateWindow(cfg)
    return self:window(cfg)
end

function library:window(cfg)
    cfg = cfg or {}
    local window_name = cfg.Title or cfg.name or cfg.Name or "ezwin.cc"
    if window_name == "gamesense" or window_name == "" then
        window_name = "ezwin.cc"
    end
    local base_size = cfg.size or cfg.Size or UDim2.new(0, 520, 0, 380)
    local base_w = (base_size.X.Scale > 0 and base_size.X.Scale * 1000) or base_size.X.Offset
    local base_h = (base_size.Y.Scale > 0 and base_size.Y.Scale * 800) or base_size.Y.Offset
    if base_w <= 0 then base_w = 520 end
    if base_h <= 0 then base_h = 380 end

    local cam = workspace.CurrentCamera
    local function get_viewport()
        if cam and cam.ViewportSize.X > 0 and cam.ViewportSize.Y > 0 then
            return cam.ViewportSize
        end
        return Vector2.new(1920, 1080)
    end

    local function compute_responsive_menu_size()
        local vp = get_viewport()
        local is_touch = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
        local top_inset = GuiInset > 0 and GuiInset or 20
        local max_w = math.max(280, vp.X - 16)
        local max_h = math.max(240, vp.Y - (top_inset + 16))

        if is_touch or vp.X < (base_w + 24) or vp.Y < (base_h + 30) then
            local final_w = math.min(base_w, max_w)
            local final_h = math.min(base_h, max_h)

            if vp.X < 520 then
                final_w = math.clamp(vp.X - 16, 280, 480)
                final_h = math.clamp(vp.Y - (top_inset + 20), 240, 500)
            elseif vp.Y < 440 then
                final_h = math.clamp(vp.Y - (top_inset + 16), 240, 380)
                final_w = math.clamp(vp.X - 24, 300, base_w)
            end

            return UDim2.new(0, math.floor(final_w), 0, math.floor(final_h)), true
        end

        return UDim2.new(0, math.floor(base_w), 0, math.floor(base_h)), false
    end

    pcall(function()
        for _, g in ipairs(TargetGui:GetChildren()) do
            if g:IsA("ScreenGui") and g.Name:match("^GameSense_") then
                g:Destroy()
            end
        end
    end)

    local screen = library:create("ScreenGui", {
        Name = "GameSense_" .. math.random(1000, 9999),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })
    if syn and syn.protect_gui then
        pcall(syn.protect_gui, screen)
    end
    screen.Parent = TargetGui
    self.screen = screen
    self.ScreenGui = screen

    local initial_menu_size, is_mobile_mode = compute_responsive_menu_size()
    local main = library:create("Frame", {
        Name = "MainFrame",
        Size = initial_menu_size,
        Position = UDim2.new(0.5, -initial_menu_size.X.Offset / 2, 0.5, -initial_menu_size.Y.Offset / 2),
        BackgroundColor3 = self.theme.main_bg,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = screen
    })
    make_corner(main, 4)
    make_stroke(main, self.theme.border, 1)
    make_draggable(main)

    local function update_menu_responsive_bounds()
        local new_sz = compute_responsive_menu_size()
        main.Size = new_sz
        local vp = get_viewport()
        local cur_x = main.Position.X.Scale * vp.X + main.Position.X.Offset
        local cur_y = main.Position.Y.Scale * vp.Y + main.Position.Y.Offset
        local w = new_sz.X.Offset
        local h = new_sz.Y.Offset

        if cur_x < 0 or (cur_x + w) > vp.X or cur_y < 0 or (cur_y + h) > vp.Y then
            main.Position = UDim2.new(0.5, -w / 2, 0.5, -h / 2)
        end
    end

    if cam then
        library:connection(cam:GetPropertyChangedSignal("ViewportSize"), function()
            update_menu_responsive_bounds()
        end)
    end

    -- Background frame avec gradient dédié (totalement isolé pour ne toucher AUCUNE écriture)
    local menu_bg = library:create("Frame", {
        Name = "MenuBackground",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 0,
        Parent = main
    })
    make_corner(menu_bg, 4)

    local menu_bg_gradient = library:create("UIGradient", {
        Name = "MenuBackgroundGradient",
        Rotation = 45,
        Color = self:GetThemeGradient(self.Scheme, self.current_theme_name),
        Parent = menu_bg
    })

    local default_bg = cfg.BackgroundImage or cfg.background or library.Scheme.BackgroundImage
    if not default_bg or default_bg == "" then
        default_bg = "rbxassetid://2151741365"
    end
    library.Scheme.BackgroundImage = default_bg

    local bg_img = library:create("ImageLabel", {
        Name = "BackgroundImage",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = default_bg,
        ScaleType = Enum.ScaleType.Tile,
        TileSize = UDim2.new(0, 64, 0, 64),
        ImageTransparency = cfg.BackgroundTransparency or 0.85,
        Visible = true,
        ZIndex = 1,
        Parent = main
    })
    make_corner(bg_img, 4)

    -- Sidebar (Navigation verticale sur la gauche avec Logo Box en haut)
    local sidebar = library:create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 52, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(15, 14, 22),
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = main
    })
    make_corner(sidebar, 4)
    library:AddToRegistry(sidebar, { BackgroundColor = "BackgroundColor" })

    -- Square Logo Box en haut de la Sidebar (comme sur la capture)
    local logo_box = library:create("Frame", {
        Name = "LogoBox",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Color3.fromRGB(12, 11, 18),
        BorderSizePixel = 0,
        LayoutOrder = 0,
        ZIndex = 4,
        Parent = sidebar
    })
    make_corner(logo_box, 4)

    local function resolve_logo(logo_input)
        local fallback_rbx = "rbxassetid://135215559087473"

        if type(logo_input) == "number" or (type(logo_input) == "string" and logo_input:match("^%d+$")) then
            return "rbxassetid://" .. tostring(logo_input)
        elseif type(logo_input) == "string" and (logo_input:match("^rbxassetid://") or logo_input:match("^rbxasset://")) then
            return logo_input
        end

        local ok, asset = pcall(function()
            local getasset = getcustomasset or getsynasset or customasset
            if getasset and writefile and isfile and readfile then
                local filename = "ezwin_logo.png"
                if not isfile(filename) then
                    local target_url = "https://raw.githubusercontent.com/xvbxvvv/logo/main/0fb782bd-42a8-46bd-8a52-7df5bee0812a.jpg"
                    local s, d = pcall(game.HttpGet, game, target_url)
                    if s and d and #d > 0 then
                        pcall(writefile, filename, d)
                    end
                end
                if isfile(filename) then
                    return getasset(filename)
                end
            end
        end)

        if ok and type(asset) == "string" and asset ~= "" then
            return asset
        end

        return fallback_rbx
    end

    local logo_asset = resolve_logo(cfg.Logo or cfg.logo)

    local logo_img = library:create("ImageLabel", {
        Name = "LogoImage",
        Size = UDim2.new(0, 38, 0, 38),
        Position = UDim2.new(0.5, -19, 0.5, -19),
        BackgroundTransparency = 1,
        Image = logo_asset,
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 5,
        Parent = logo_box
    })
    make_corner(logo_img, 6)

    -- Séparateur sous le logo
    local logo_sep = library:create("Frame", {
        Name = "LogoSep",
        Size = UDim2.new(1, -12, 0, 1),
        Position = UDim2.new(0, 6, 1, -1),
        BackgroundColor3 = self.theme.border_dark,
        BorderSizePixel = 0,
        ZIndex = 4,
        Parent = logo_box
    })

    local tab_buttons_holder = library:create("Frame", {
        Name = "TabButtonsHolder",
        Size = UDim2.new(1, 0, 1, -52),
        Position = UDim2.new(0, 0, 0, 52),
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = sidebar
    })

    library:create("UIListLayout", {
        Padding = UDim.new(0, 6),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tab_buttons_holder
    })

    -- Titre "ezwin.cc" épuré et stylisé (simple mais beau, sans contour ni boîte)
    local raw_title = cfg.Title or cfg.name or cfg.Name or "ezwin.cc"
    if raw_title == "gamesense" or raw_title == "" then
        raw_title = "ezwin.cc"
    end

    local title_prefix, title_suffix = raw_title:match("^(.-)(%..+)$")
    if not title_prefix then
        title_prefix = raw_title
        title_suffix = ""
    end

    local title_container = library:create("Frame", {
        Name = "TitleContainer",
        Size = UDim2.new(0, 110, 0, 32),
        Position = UDim2.new(0, 60, 0, 10),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 4,
        Parent = main
    })

    -- Ombre ambiante pour le style code/minecraft net
    local title_shadow = library:create("TextLabel", {
        Name = "TitleShadow",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundTransparency = 1,
        Font = Enum.Font.Code,
        RichText = true,
        Text = '<font color="#000000">' .. title_prefix .. title_suffix .. '</font>',
        TextTransparency = 0.65,
        TextSize = 19,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 4,
        Parent = title_container
    })

    -- Texte principal avec police Code / Minecraft agrandie et .cc accentué
    local title_label = library:create("TextLabel", {
        Name = "TitleLabel",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Code,
        RichText = true,
        Text = '<font color="#FFFFFF">' .. title_prefix .. '</font><font color="#' .. self.theme.accent:ToHex() .. '">' .. title_suffix .. '</font>',
        TextSize = 19,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 5,
        Parent = title_container
    })

    -- Séparateur vertical minimaliste
    local title_sep = library:create("Frame", {
        Name = "TitleSep",
        Size = UDim2.new(0, 1, 0, 16),
        Position = UDim2.new(0, 174, 0, 18),
        BackgroundColor3 = self.theme.border_dark,
        BorderSizePixel = 0,
        ZIndex = 4,
        Parent = main
    })

    -- Zone supérieure de contenu avec Search Bar (placée à droite du titre)
    local top_search_bar = library:create("Frame", {
        Name = "TopSearchBar",
        Size = UDim2.new(1, -220, 0, 32),
        Position = UDim2.new(0, 184, 0, 10),
        BackgroundColor3 = Color3.fromRGB(26, 23, 38),
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = main
    })
    make_corner(top_search_bar, 6)
    make_stroke(top_search_bar, Color3.fromRGB(42, 38, 58), 1)

    -- Icône Loupe
    local search_icon = library:create("ImageLabel", {
        Name = "SearchIcon",
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, 12, 0.5, -7),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10709797288",
        ImageColor3 = Color3.fromRGB(155, 145, 185),
        ZIndex = 4,
        Parent = top_search_bar
    })

    -- Barre de séparation |
    library:create("TextLabel", {
        Name = "Divider",
        Size = UDim2.new(0, 8, 1, 0),
        Position = UDim2.new(0, 32, 0, 0),
        BackgroundTransparency = 1,
        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        Text = "|",
        TextColor3 = Color3.fromRGB(80, 75, 105),
        TextSize = 13,
        ZIndex = 4,
        Parent = top_search_bar
    })

    -- Input Search
    local search_input = library:create("TextBox", {
        Name = "SearchInput",
        Size = UDim2.new(1, -48, 1, 0),
        Position = UDim2.new(0, 44, 0, 0),
        BackgroundTransparency = 1,
        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        PlaceholderText = "Search...",
        PlaceholderColor3 = Color3.fromRGB(120, 115, 145),
        Text = "",
        TextColor3 = Color3.fromRGB(240, 240, 252),
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = 4,
        Parent = top_search_bar
    })

    -- Close / Hide button sur le coin supérieur droit
    local close_btn = library:create("TextButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -30, 0, 14),
        BackgroundColor3 = Color3.fromRGB(24, 22, 34),
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Text = "X",
        TextColor3 = Color3.fromRGB(165, 160, 185),
        TextSize = 12,
        AutoButtonColor = false,
        ZIndex = 5,
        Parent = main
    })
    make_corner(close_btn, 4)
    make_stroke(close_btn, self.theme.border_dark, 1)

    close_btn.MouseButton1Click:Connect(function()
        library:Toggle()
    end)
    close_btn.MouseEnter:Connect(function()
        close_btn.TextColor3 = Color3.fromRGB(255, 80, 80)
        close_btn.BackgroundColor3 = Color3.fromRGB(36, 26, 36)
    end)
    close_btn.MouseLeave:Connect(function()
        close_btn.TextColor3 = Color3.fromRGB(160, 155, 180)
        close_btn.BackgroundColor3 = Color3.fromRGB(24, 22, 34)
    end)

    -- Zone de contenu sous la Search Bar
    local content_holder = library:create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -66, 1, -54),
        Position = UDim2.new(0, 58, 0, 48),
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = main
    })

    local window_obj = {
        main = main,
        menu_bg = menu_bg,
        bg_gradient = menu_bg_gradient,
        screen = screen,
        sidebar = sidebar,
        content = content_holder,
        search_input = search_input,
        background_image = bg_img,
        title_label = title_label,
        tabs = {},
        Tabs = {},
        current_tab = nil,
        SettingsTab = nil,
        DashboardTab = nil,
    }
    library.Window = window_obj

    -- Live Search Filter sur l'onglet actif
    local function apply_search_filter()
        local query = search_input.Text:lower():gsub("^%s+", ""):gsub("%s+$", "")
        if not window_obj.current_tab then return end
        local active_page = window_obj.current_tab.page
        if not active_page then return end

        for _, descendant in ipairs(active_page:GetDescendants()) do
            if descendant:IsA("TextButton") and descendant.Parent and descendant.Parent.Name == "Container" then
                local row_text = descendant.Name:lower()
                for _, child in ipairs(descendant:GetChildren()) do
                    if child:IsA("TextLabel") and child.Text and child.Text ~= "" then
                        row_text = row_text .. " " .. child.Text:lower()
                    end
                end

                if query == "" or row_text:find(query, 1, true) then
                    descendant.Visible = true
                else
                    descendant.Visible = false
                end
            end
        end
    end

    search_input:GetPropertyChangedSignal("Text"):Connect(apply_search_filter)

    -- ==============================================================================
    -- DIALOG MODAL SYSTEM (pour SaveManager & ThemeManager)
    -- ==============================================================================
    function window_obj:AddDialog(index, options)
        options = options or {}
        local title = options.Title or options.name or "Dialog"
        local desc = options.Description or options.text or ""
        local footer_buttons = options.FooterButtons or {}

        local modal_bg = library:create("TextButton", {
            Name = "Modal_" .. tostring(index),
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.5,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 200,
            Parent = screen
        })

        local dialog_frame = library:create("Frame", {
            Size = UDim2.new(0, 280, 0, 130),
            Position = UDim2.new(0.5, -140, 0.5, -65),
            BackgroundColor3 = library.theme.panel_bg,
            BorderSizePixel = 0,
            ZIndex = 201,
            Parent = modal_bg
        })
        make_corner(dialog_frame, 4)
        make_stroke(dialog_frame, library.theme.border, 1)

        library:create("TextLabel", {
            Size = UDim2.new(1, -20, 0, 24),
            Position = UDim2.new(0, 10, 0, 8),
            BackgroundTransparency = 1,
            Font = Enum.Font.SourceSansBold,
            Text = title,
            TextColor3 = library.theme.text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 202,
            Parent = dialog_frame
        })

        library:create("TextLabel", {
            Size = UDim2.new(1, -20, 0, 48),
            Position = UDim2.new(0, 10, 0, 32),
            BackgroundTransparency = 1,
            Font = Enum.Font.SourceSans,
            Text = desc,
            TextColor3 = library.theme.text_dark,
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            ZIndex = 202,
            Parent = dialog_frame
        })

        local btn_container = library:create("Frame", {
            Size = UDim2.new(1, -20, 0, 24),
            Position = UDim2.new(0, 10, 1, -32),
            BackgroundTransparency = 1,
            ZIndex = 202,
            Parent = dialog_frame
        })
        library:create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = btn_container
        })

        local dialog_obj = {}
        function dialog_obj:Dismiss()
            modal_bg:Destroy()
        end

        for btn_name, btn_cfg in pairs(footer_buttons) do
            local btn = library:create("TextButton", {
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.new(0, 60, 1, 0),
                BackgroundColor3 = (btn_cfg.Variant == "Destructive" and Color3.fromRGB(180, 40, 40)) or library.theme.element_bg,
                BorderSizePixel = 0,
                Font = Enum.Font.SourceSansBold,
                Text = btn_cfg.Title or btn_name,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 11,
                LayoutOrder = btn_cfg.Order or 1,
                ZIndex = 203,
                Parent = btn_container
            })
            make_corner(btn, 3)
            make_stroke(btn, library.theme.border, 1)
            library:create("UIPadding", {
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                Parent = btn
            })

            btn.MouseButton1Click:Connect(function()
                if btn_cfg.Callback then
                    btn_cfg.Callback(dialog_obj)
                else
                    dialog_obj:Dismiss()
                end
            end)
        end

        return dialog_obj
    end

    -- Watermark (gamesense style avec auto-resize et show/hide)
    function window_obj:watermark(wcfg)
        wcfg = wcfg or {}
        local tag_name = wcfg.name or wcfg.text or "ezwin.cc"
        if tag_name:lower():match("^gamesense") then
            tag_name = tag_name:gsub("^gamesense", "ezwin.cc"):gsub("^GameSense", "ezwin.cc")
        end

        local is_touch = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
        local wm_pos = wcfg.position or (is_touch and UDim2.new(0, 10, 0, math.max(10, GuiInset + 4)) or UDim2.new(0, 20, 0, 20))

        local wm = library:create("Frame", {
            Name = "Watermark",
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.new(0, 0, 0, 20),
            Position = wm_pos,
            BackgroundColor3 = Color3.fromRGB(15, 13, 22),
            BorderSizePixel = 0,
            Visible = (wcfg.visible ~= false),
            Parent = screen
        })
        make_corner(wm, 4)
        make_stroke(wm, library.theme.border, 1)
        make_draggable(wm)

        local top_stripe = library:create("Frame", {
            Size = UDim2.new(1, 0, 0, 2),
            BackgroundColor3 = library.theme.accent,
            BorderSizePixel = 0,
            Parent = wm
        })
        library:AddToRegistry(top_stripe, { BackgroundColor = "AccentColor" })
        make_corner(top_stripe, 2)

        library:create("UIPadding", {
            PaddingLeft = UDim.new(0, 9),
            PaddingRight = UDim.new(0, 9),
            Parent = wm
        })

        local lbl = library:create("TextLabel", {
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            Text = tag_name .. " | " .. (LocalPlayer.DisplayName or LocalPlayer.Name) .. " | 00:00 | 60 fps",
            TextColor3 = Color3.fromRGB(240, 240, 250),
            TextSize = 11,
            Parent = wm
        })

        local last = tick()
        local frames = 0
        library:connection(RunService.RenderStepped, function()
            frames = frames + 1
            if tick() - last >= 1 then
                local date = os.date("*t")
                local h = string.format("%02d:%02d", date.hour, date.min)
                local fps = math.floor(frames / (tick() - last))
                lbl.Text = tag_name .. " | " .. (LocalPlayer.DisplayName or LocalPlayer.Name) .. " | " .. h .. " | " .. fps .. " fps"
                frames = 0
                last = tick()
            end
        end)

        local wm_obj = {
            frame = wm,
            label = lbl,
            set = function(new_text) lbl.Text = tostring(new_text) end,
            SetText = function(self_wm, new_text) lbl.Text = tostring(new_text) end,
            SetVisible = function(self_wm, visible)
                if type(self_wm) == "boolean" then visible = self_wm end
                wm.Visible = (visible == true)
            end,
            Toggle = function(self_wm)
                wm.Visible = not wm.Visible
                return wm.Visible
            end,
            Show = function(self_wm)
                wm.Visible = true
            end,
            Hide = function(self_wm)
                wm.Visible = false
            end,
            IsVisible = function(self_wm)
                return wm.Visible
            end,
            destroy = function(self_wm)
                wm:Destroy()
            end
        }

        window_obj.Watermark = wm_obj
        library.Watermark = wm_obj

        if library.Toggles and library.Toggles.ShowWatermark then
            wm.Visible = library.Toggles.ShowWatermark.Value
        end

        return wm_obj
    end

    -- Floating window (Feature list / Keybinds widget sleek style avec Auto-Resize)
    function window_obj:floating(fcfg)
        fcfg = fcfg or {}
        local title = fcfg.title or "Active Features"
        local initial_width = (fcfg.size and fcfg.size.X.Offset > 0 and fcfg.size.X.Offset) or 165

        local cam = workspace.CurrentCamera
        local function get_viewport_size()
            if cam and cam.ViewportSize.X > 0 and cam.ViewportSize.Y > 0 then
                return cam.ViewportSize
            end
            return Vector2.new(1920, 1080)
        end

        local vp = get_viewport_size()
        local is_touch = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

        local initial_pos = fcfg.position
        if not initial_pos then
            if is_touch or vp.X < 800 then
                initial_pos = UDim2.new(0, 12, 0, math.max(46, GuiInset + 34))
            else
                initial_pos = UDim2.new(0.5, -345, 0.5, 40)
            end
        else
            local abs_x = initial_pos.X.Scale * vp.X + initial_pos.X.Offset
            local abs_y = initial_pos.Y.Scale * vp.Y + initial_pos.Y.Offset
            if abs_x < 0 or abs_x > vp.X - 50 or abs_y < 0 or abs_y > vp.Y - 50 then
                initial_pos = UDim2.new(0, 12, 0, math.max(46, GuiInset + 34))
            end
        end

        local min_width = math.max(140, initial_width)

        local fw = library:create("Frame", {
            Name = "FloatingFeatures",
            Size = UDim2.new(0, min_width, 0, 0),
            Position = initial_pos,
            BackgroundColor3 = Color3.fromRGB(15, 13, 22),
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = (fcfg.visible ~= false),
            ZIndex = 20,
            Parent = screen
        })
        make_corner(fw, 5)
        make_stroke(fw, library.theme.border, 1)
        make_draggable(fw)

        -- Top Glowing Accent line
        local top_stripe = library:create("Frame", {
            Name = "TopAccent",
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = library.theme.accent,
            BorderSizePixel = 0,
            ZIndex = 22,
            Parent = fw
        })
        library:AddToRegistry(top_stripe, { BackgroundColor = "AccentColor" })
        make_corner(top_stripe, 2)

        -- Sleek Header
        local header = library:create("Frame", {
            Name = "Header",
            Size = UDim2.new(1, 0, 0, 24),
            Position = UDim2.new(0, 0, 0, 2),
            BackgroundColor3 = Color3.fromRGB(20, 17, 30),
            BorderSizePixel = 0,
            ZIndex = 21,
            Parent = fw
        })

        -- Glowing Status Pulse Dot
        local status_dot = library:create("Frame", {
            Name = "StatusDot",
            Size = UDim2.new(0, 6, 0, 6),
            Position = UDim2.new(0, 9, 0.5, -3),
            BackgroundColor3 = library.theme.accent,
            BorderSizePixel = 0,
            ZIndex = 22,
            Parent = header
        })
        make_corner(status_dot, 3)
        library:AddToRegistry(status_dot, { BackgroundColor = "AccentColor" })

        local title_lbl = library:create("TextLabel", {
            Name = "Title",
            Size = UDim2.new(1, -26, 1, 0),
            Position = UDim2.new(0, 20, 0, 0),
            BackgroundTransparency = 1,
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            Text = title,
            TextColor3 = Color3.fromRGB(240, 240, 250),
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 22,
            Parent = header
        })

        -- Header divider
        local header_sep = library:create("Frame", {
            Name = "Sep",
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, -1),
            BackgroundColor3 = library.theme.border_dark,
            BorderSizePixel = 0,
            ZIndex = 21,
            Parent = header
        })

        -- Container for features
        local container = library:create("Frame", {
            Name = "Container",
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 0, 26),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 21,
            Parent = fw
        })

        library:create("UIPadding", {
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 6),
            PaddingBottom = UDim.new(0, 6),
            Parent = container
        })

        library:create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4),
            Parent = container
        })

        local function measure_str(txt, font_weight, txt_sz)
            local ok, s = pcall(function()
                return TextService:GetTextSize(tostring(txt), txt_sz or 11, font_weight or Enum.Font.SourceSansBold, Vector2.new(2000, 100))
            end)
            if ok and s then return s.X end
            return #tostring(txt) * 7.5
        end

        local tracked_items = {}

        local function auto_resize_floating()
            local cur_vp = get_viewport_size()
            local needed = min_width

            local tw = measure_str(title, Enum.Font.SourceSansBold, 11) + 48
            if tw > needed then needed = tw end

            for _, it in ipairs(tracked_items) do
                if it.get_width then
                    local w = it.get_width()
                    if w > needed then needed = w end
                end
            end

            local max_safe = math.max(150, cur_vp.X - 24)
            local final_w = math.clamp(math.ceil(needed), min_width, max_safe)

            if math.abs(fw.Size.X.Offset - final_w) > 1 then
                library:tween(fw, { Size = UDim2.new(0, final_w, 0, 0) }, nil, 0.15)
            end
        end

        if cam then
            library:connection(cam:GetPropertyChangedSignal("ViewportSize"), function()
                auto_resize_floating()
                local cur_vp = get_viewport_size()
                local cur_x = fw.Position.X.Scale * cur_vp.X + fw.Position.X.Offset
                local cur_y = fw.Position.Y.Scale * cur_vp.Y + fw.Position.Y.Offset
                local cur_w = fw.Size.X.Offset
                local cur_h = fw.AbsoluteSize.Y
                if cur_x < 4 or (cur_x + cur_w) > cur_vp.X - 4 or cur_y < 4 or (cur_y + cur_h) > cur_vp.Y - 4 then
                    local safe_x = math.clamp(cur_x, 8, math.max(8, cur_vp.X - cur_w - 8))
                    local safe_y = math.clamp(cur_y, 8, math.max(8, cur_vp.Y - math.max(30, cur_h) - 8))
                    fw.Position = UDim2.new(0, safe_x, 0, safe_y)
                end
            end)
        end

        local float_obj = {
            frame = fw,
            container = container,
            header = header,
            title = title_lbl,
            AutoSize = auto_resize_floating,
            SetVisible = function(self_f, visible)
                if type(self_f) == "boolean" then visible = self_f end
                fw.Visible = (visible == true)
            end,
            Toggle = function(self_f)
                fw.Visible = not fw.Visible
                return fw.Visible
            end,
            Show = function(self_f)
                fw.Visible = true
            end,
            Hide = function(self_f)
                fw.Visible = false
            end,
            IsVisible = function(self_f)
                return fw.Visible
            end,
            destroy = function(self_f)
                fw:Destroy()
            end
        }

        window_obj.FloatingFeatures = float_obj
        library.FloatingFeatures = float_obj

        if library.Toggles and library.Toggles.ShowFeatures then
            fw.Visible = library.Toggles.ShowFeatures.Value
        end

        function float_obj:add(text)
            local item = library:create("Frame", {
                Name = "FeatureItem_" .. tostring(text),
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundColor3 = Color3.fromRGB(22, 19, 32),
                BackgroundTransparency = 0.4,
                BorderSizePixel = 0,
                ZIndex = 22,
                Parent = container
            })
            make_corner(item, 4)
            make_stroke(item, Color3.fromRGB(38, 33, 54), 1)

            -- Glowing mini dot
            local dot = library:create("Frame", {
                Size = UDim2.new(0, 4, 0, 4),
                Position = UDim2.new(0, 7, 0.5, -2),
                BackgroundColor3 = Color3.fromRGB(0, 255, 159),
                BorderSizePixel = 0,
                ZIndex = 23,
                Parent = item
            })
            make_corner(dot, 2)

            -- Feature Name Text
            local lbl = library:create("TextLabel", {
                Size = UDim2.new(1, -44, 1, 0),
                Position = UDim2.new(0, 16, 0, 0),
                BackgroundTransparency = 1,
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                Text = tostring(text),
                TextColor3 = Color3.fromRGB(235, 235, 245),
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 23,
                Parent = item
            })

            -- Status badge "ON"
            local badge = library:create("Frame", {
                Size = UDim2.new(0, 24, 0, 14),
                Position = UDim2.new(1, -28, 0.5, -7),
                BackgroundColor3 = Color3.fromRGB(15, 35, 25),
                BorderSizePixel = 0,
                ZIndex = 23,
                Parent = item
            })
            make_corner(badge, 3)
            make_stroke(badge, Color3.fromRGB(25, 60, 40), 1)

            local badge_lbl = library:create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                Text = "ON",
                TextColor3 = Color3.fromRGB(0, 255, 159),
                TextSize = 9,
                ZIndex = 24,
                Parent = badge
            })

            local item_entry = {
                id = item,
                get_width = function()
                    return measure_str(lbl.Text, Enum.Font.SourceSansSemibold, 11) + 64
                end
            }
            table.insert(tracked_items, item_entry)
            auto_resize_floating()

            return {
                frame = item,
                set = function(new_text)
                    lbl.Text = tostring(new_text)
                    auto_resize_floating()
                end,
                destroy = function()
                    for idx, e in ipairs(tracked_items) do
                        if e.id == item then
                            table.remove(tracked_items, idx)
                            break
                        end
                    end
                    item:Destroy()
                    auto_resize_floating()
                end
            }
        end

        function float_obj:remove(text)
            for i = #tracked_items, 1, -1 do
                local it = tracked_items[i].id
                if it and it.Parent and (it.Name == "FeatureItem_" .. tostring(text) or (it:FindFirstChildOfClass("TextLabel") and it:FindFirstChildOfClass("TextLabel").Text:match(tostring(text)))) then
                    table.remove(tracked_items, i)
                    it:Destroy()
                end
            end
            for _, v in ipairs(container:GetChildren()) do
                if v:IsA("Frame") and (v.Name == "FeatureItem_" .. tostring(text) or (v:FindFirstChildOfClass("TextLabel") and v:FindFirstChildOfClass("TextLabel").Text:match(tostring(text)))) then
                    v:Destroy()
                elseif v:IsA("TextLabel") and v.Text:match(tostring(text)) then
                    v:Destroy()
                end
            end
            auto_resize_floating()
        end

        function float_obj:row(lbl_text, val_text, val_col)
            local row = library:create("Frame", {
                Name = "FeatureRow_" .. tostring(lbl_text),
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundColor3 = Color3.fromRGB(20, 18, 30),
                BackgroundTransparency = 0.5,
                BorderSizePixel = 0,
                ZIndex = 22,
                Parent = container
            })
            make_corner(row, 4)
            make_stroke(row, Color3.fromRGB(35, 30, 50), 1)

            local l = library:create("TextLabel", {
                Size = UDim2.new(0.6, -8, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                Text = tostring(lbl_text),
                TextColor3 = Color3.fromRGB(175, 170, 195),
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 23,
                Parent = row
            })

            local val_pill = library:create("Frame", {
                Size = UDim2.new(0.4, 0, 0, 14),
                Position = UDim2.new(0.6, -6, 0.5, -7),
                BackgroundColor3 = Color3.fromRGB(15, 13, 24),
                BorderSizePixel = 0,
                ZIndex = 23,
                Parent = row
            })
            make_corner(val_pill, 3)

            local v = library:create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                Text = tostring(val_text),
                TextColor3 = val_col or library.theme.accent,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Center,
                ZIndex = 24,
                Parent = val_pill
            })

            local row_entry = {
                id = row,
                get_width = function()
                    local lw = measure_str(l.Text, Enum.Font.SourceSansMedium, 11)
                    local vw = measure_str(v.Text, Enum.Font.SourceSansBold, 10)
                    return lw + vw + 48
                end
            }
            table.insert(tracked_items, row_entry)
            auto_resize_floating()

            return {
                set = function(t, c)
                    v.Text = tostring(t)
                    if c then v.TextColor3 = c end
                    auto_resize_floating()
                end,
                frame = row,
                destroy = function()
                    for idx, e in ipairs(tracked_items) do
                        if e.id == row then
                            table.remove(tracked_items, idx)
                            break
                        end
                    end
                    row:Destroy()
                    auto_resize_floating()
                end
            }
        end

        return float_obj
    end

    -- Floating ESP preview
    function window_obj:esp_preview(options)
        options = options or {}
        local size = options.size or UDim2.new(0, 190, 0, 252)
        local pos = options.position or UDim2.new(0.5, 270, 0.5, -126)
        local title = options.title or "ESP Preview"

        local fw = library:create("Frame", {
            Name = "FloatingESP",
            Size = size,
            Position = pos,
            BackgroundColor3 = library.theme.main_bg,
            BorderSizePixel = 0,
            Parent = screen,
        })
        make_corner(fw, 3)
        make_stroke(fw, library.theme.border, 1)

        local header = library:create("Frame", {
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundColor3 = library.theme.panel_bg,
            BorderSizePixel = 0,
            Parent = fw,
        })
        make_corner(header, 3)
        make_draggable(fw, header)

        library:create("TextLabel", {
            Size = UDim2.new(1, -8, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.SourceSansBold,
            Text = title,
            TextColor3 = library.theme.text,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = header,
        })

        local content = library:create("Frame", {
            Size = UDim2.new(1, -8, 1, -28),
            Position = UDim2.new(0, 4, 0, 24),
            BackgroundTransparency = 1,
            Parent = fw,
        })

        local preview = library:BuildESPPreview(content, options)
        preview.window = fw
        preview.close = function() fw:Destroy() end
        return preview
    end

    -- ==============================================================================
    -- TABS (AddTab / tab)
    -- ==============================================================================
    function window_obj:AddTab(tcfg)
        return self:tab(tcfg)
    end

    function window_obj:tab(tcfg)
        tcfg = tcfg or {}
        if type(tcfg) == "string" then tcfg = { name = tcfg } end
        local tab_name = tcfg.Title or tcfg.name or tcfg.Name or "Tab"
        local tab_icon = tcfg.Icon or tcfg.icon or tab_name:sub(1, 1)

        if (tab_name == "Settings" or tab_name == "settings") and window_obj.SettingsTab then
            return window_obj.SettingsTab
        end
        if (tab_name == "Dashboard" or tab_name == "dashboard") and window_obj.DashboardTab then
            return window_obj.DashboardTab
        end

        local is_settings = (tab_name == "Settings" or tab_name == "settings")
        local is_dashboard = (tab_name == "Dashboard" or tab_name == "dashboard")
        local tab_order = is_dashboard and 1 or (is_settings and 9999 or (10 + #window_obj.tabs))
        local tab_btn = library:create("TextButton", {
            Name = "Tab_" .. tab_name,
            Size = UDim2.new(0, 34, 0, 32),
            BackgroundColor3 = library.theme.main_bg,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = tab_order,
            Parent = (self.sidebar:FindFirstChild('TabButtonsHolder') or self.sidebar)
        })
        make_corner(tab_btn, 4)

        local stroke = make_stroke(tab_btn, library.theme.border_dark, 1)
        stroke.Enabled = false

        local parsed_icon = library:GetCustomIcon(tab_icon)
        local icon_label
        if parsed_icon then
            icon_label = library:create("ImageLabel", {
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(0.5, -9, 0.5, -9),
                BackgroundTransparency = 1,
                ImageColor3 = library.theme.text_dark,
                Parent = tab_btn
            })
            library:ApplyIcon(icon_label, parsed_icon)
        else
            icon_label = library:create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.SourceSansBold,
                Text = tostring(tab_icon):sub(1, 1),
                TextColor3 = library.theme.text_dark,
                TextSize = 16,
                Parent = tab_btn
            })
        end

        local tab_page = library:create("Frame", {
            Name = "Page_" .. tab_name,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = self.content
        })

        local subtab_bar = library:create("Frame", {
            Name = "SubTabsBar",
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = tab_page
        })

        library:create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6),
            Parent = subtab_bar
        })

        local sub_content = library:create("Frame", {
            Name = "SubContent",
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Parent = tab_page
        })

        local tab_obj = {
            name = tab_name,
            btn = tab_btn,
            stroke = stroke,
            page = tab_page,
            subtab_bar = subtab_bar,
            sub_content = sub_content,
            subtabs = {},
            current_sub = nil
        }

        function tab_obj:select()
            if window_obj.current_tab == tab_obj then
                return
            end

            if window_obj.current_tab then
                local prev = window_obj.current_tab
                prev.page.Visible = false
                library:tween(prev.btn, {BackgroundColor3 = Color3.fromRGB(15, 14, 22)}, nil, 0.15)
                if prev.stroke then prev.stroke.Enabled = false end
                if prev.icon.ClassName == "ImageLabel" then
                    library:tween(prev.icon, {ImageColor3 = library.theme.text_dark}, nil, 0.15)
                else
                    library:tween(prev.icon, {TextColor3 = library.theme.text_dark}, nil, 0.15)
                end
            end

            window_obj.current_tab = tab_obj
            tab_page.Visible = true
            library:tween(tab_btn, {BackgroundColor3 = Color3.fromRGB(34, 30, 50)}, nil, 0.15)
            stroke.Color = library.theme.accent
            stroke.Enabled = true
            if icon_label.ClassName == "ImageLabel" then
                library:tween(icon_label, {ImageColor3 = Color3.fromRGB(255, 255, 255)}, nil, 0.15)
            else
                library:tween(icon_label, {TextColor3 = Color3.fromRGB(255, 255, 255)}, nil, 0.15)
            end

            if not tab_obj.current_sub and #tab_obj.subtabs > 0 then
                tab_obj.subtabs[1]:select()
            end

            if apply_search_filter and search_input and search_input.Text ~= "" then
                pcall(apply_search_filter)
            end
        end

        tab_btn.MouseEnter:Connect(function()
            if window_obj.current_tab ~= tab_obj then
                library:tween(tab_btn, {BackgroundColor3 = Color3.fromRGB(25, 23, 36)}, nil, 0.12)
                if icon_label.ClassName == "ImageLabel" then
                    library:tween(icon_label, {ImageColor3 = Color3.fromRGB(200, 195, 225)}, nil, 0.12)
                else
                    library:tween(icon_label, {TextColor3 = Color3.fromRGB(200, 195, 225)}, nil, 0.12)
                end
            end
        end)

        tab_btn.MouseLeave:Connect(function()
            if window_obj.current_tab ~= tab_obj then
                library:tween(tab_btn, {BackgroundColor3 = Color3.fromRGB(15, 14, 22)}, nil, 0.12)
                if icon_label.ClassName == "ImageLabel" then
                    library:tween(icon_label, {ImageColor3 = library.theme.text_dark}, nil, 0.12)
                else
                    library:tween(icon_label, {TextColor3 = library.theme.text_dark}, nil, 0.12)
                end
            end
        end)

        tab_obj.icon = icon_label
        tab_btn.MouseButton1Click:Connect(function() tab_obj:select() end)

        -- Helper to get or create default subtab when Obsidian AddLeftGroupbox/AddRightGroupbox is called
        local function ensure_default_sub()
            if #tab_obj.subtabs == 0 then
                local def = tab_obj:subtab({ name = "Main", label = "Main" })
                def:select()
                -- Keep subtab bar hidden for single default subtab
                subtab_bar.Visible = false
                sub_content.Position = UDim2.new(0, 0, 0, 0)
                sub_content.Size = UDim2.new(1, 0, 1, 0)
                return def
            end
            return tab_obj.current_sub or tab_obj.subtabs[1]
        end

        function tab_obj:AddLeftGroupbox(name)
            local sub = ensure_default_sub()
            return sub:section({ name = name, side = "left", label = "A" })
        end

        function tab_obj:AddRightGroupbox(name)
            local sub = ensure_default_sub()
            return sub:section({ name = name, side = "right", label = "B" })
        end

        function tab_obj:AddGroupbox(cfg)
            cfg = cfg or {}
            local side = (cfg.Side and cfg.Side:lower()) or "left"
            local name = cfg.Name or cfg.name or cfg.Title or "Groupbox"
            local sub = ensure_default_sub()
            return sub:section({ name = name, side = side, label = (side == "left" and "A" or "B") })
        end

        -- ==============================================================================
        -- SUBTAB
        -- ==============================================================================
        function tab_obj:subtab(scfg)
            scfg = scfg or {}
            local sub_name = scfg.name or scfg.Name or "SubTab"
            local sub_label = scfg.label or scfg.Label or sub_name

            -- Show subtab bar if we have multiple or explicit subtabs
            if #tab_obj.subtabs >= 1 or sub_name ~= "Main" then
                subtab_bar.Visible = true
                sub_content.Position = UDim2.new(0, 0, 0, 24)
                sub_content.Size = UDim2.new(1, 0, 1, -24)
            end

            local sub_btn = library:create("TextButton", {
                Name = "SubBtn_" .. sub_name,
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.new(0, 24, 0, 20),
                BackgroundColor3 = library.theme.panel_bg,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Font = Enum.Font.SourceSansBold,
                Text = sub_label,
                TextColor3 = Color3.fromRGB(200, 200, 200),
                TextSize = 11,
                AutoButtonColor = false,
                Parent = subtab_bar
            })
            make_corner(sub_btn, 3)
            local sub_stroke = make_stroke(sub_btn, library.theme.border, 1)
            sub_stroke.Enabled = false

            library:create("UIPadding", {
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                Parent = sub_btn
            })

            local sub_view = library:create("Frame", {
                Name = "View_" .. sub_name,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Visible = false,
                Parent = sub_content
            })

            local col_a = library:create("ScrollingFrame", {
                Name = "ColumnA",
                Size = UDim2.new(0.5, -4, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = library.theme.accent,
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                Parent = sub_view
            })
            library:create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8),
                Parent = col_a
            })

            local col_b = library:create("ScrollingFrame", {
                Name = "ColumnB",
                Size = UDim2.new(0.5, -4, 1, 0),
                Position = UDim2.new(0.5, 4, 0, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = library.theme.accent,
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                Parent = sub_view
            })
            library:create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8),
                Parent = col_b
            })

            local sub_obj = {
                name = sub_name,
                btn = sub_btn,
                view = sub_view,
                left = col_a,
                right = col_b,
                stroke = sub_stroke,
                active = false
            }

            function sub_obj:select()
                if tab_obj.current_sub == sub_obj then
                    return
                end

                if tab_obj.current_sub then
                    local prev = tab_obj.current_sub
                    prev.view.Visible = false
                    prev.active = false
                    if prev.stroke then prev.stroke.Enabled = false end
                    library:tween(prev.btn, {
                        TextColor3 = Color3.fromRGB(160, 155, 180),
                        BackgroundColor3 = library.theme.panel_bg
                    }, nil, 0.15)
                end
                tab_obj.current_sub = sub_obj
                sub_obj.active = true
                sub_view.Visible = true
                sub_stroke.Color = library.theme.accent
                sub_stroke.Enabled = true
                library:tween(sub_btn, {
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundColor3 = Color3.fromRGB(28, 25, 42)
                }, nil, 0.15)
            end

            sub_btn.MouseEnter:Connect(function()
                if not sub_obj.active then
                    library:tween(sub_btn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, nil, 0.12)
                end
            end)
            sub_btn.MouseLeave:Connect(function()
                if not sub_obj.active then
                    library:tween(sub_btn, {TextColor3 = Color3.fromRGB(180, 180, 180)}, nil, 0.12)
                end
            end)
            sub_btn.MouseButton1Click:Connect(function() sub_obj:select() end)

            -- ==============================================================================
            -- SECTION / GROUPBOX
            -- ==============================================================================
            function sub_obj:section(sec_cfg)
                sec_cfg = sec_cfg or {}
                local side = sec_cfg.side or sec_cfg.Side or "left"
                local sec_name = sec_cfg.name or sec_cfg.Name or sec_cfg.Title or "Section"
                local sec_label = sec_cfg.label or sec_cfg.Label or (side == "left" and "A" or "B")
                local parent_col = (side == "left" and col_a or col_b)

                local section_card = library:create("Frame", {
                    Name = "Section_" .. sec_name,
                    Size = UDim2.new(1, -4, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = library.theme.panel_bg,
                    BorderSizePixel = 0,
                    Parent = parent_col
                })
                make_corner(section_card, 4)
                make_stroke(section_card, library.theme.border_dark, 1)

                local header_frame = library:create("Frame", {
                    Name = "Header",
                    Size = UDim2.new(1, -12, 0, 20),
                    Position = UDim2.new(0, 6, 0, 4),
                    BackgroundTransparency = 1,
                    Parent = section_card
                })

                local badge = library:create("TextLabel", {
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(0, 0, 0.5, -6),
                    BackgroundColor3 = library.theme.main_bg,
                    BorderSizePixel = 0,
                    Font = Enum.Font.SourceSansBold,
                    Text = sec_label,
                    TextColor3 = library.theme.text_dark,
                    TextSize = 10,
                    Parent = header_frame
                })
                make_corner(badge, 2)
                make_stroke(badge, library.theme.border_dark, 1)

                library:create("TextLabel", {
                    Size = UDim2.new(1, -18, 1, 0),
                    Position = UDim2.new(0, 16, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.SourceSansBold,
                    Text = sec_name,
                    TextColor3 = library.theme.text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = header_frame
                })

                local scroll = library:create("Frame", {
                    Name = "Container",
                    Size = UDim2.new(1, -12, 0, 0),
                    Position = UDim2.new(0, 6, 0, 26),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = section_card
                })

                library:create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 6),
                    Parent = scroll
                })

                library:create("UIPadding", {
                    PaddingBottom = UDim.new(0, 8),
                    Parent = scroll
                })

                local section_obj = { container = scroll, elements = scroll, items = { elements = scroll } }

                -- Helper for normalization of args (Obsidian vs Gamesense)
                local function parse_args(arg1, arg2)
                    if type(arg1) == "string" then
                        local opts = arg2 or {}
                        return arg1, opts
                    else
                        local opts = arg1 or {}
                        local flag = opts.flag or opts.Flag or opts.name or opts.Name or opts.Text or "Option"
                        return flag, opts
                    end
                end

                -- =====================================================================
                -- TOGGLE (AddToggle)
                -- =====================================================================
                function section_obj:AddToggle(arg1, arg2)
                    local flag, options = parse_args(arg1, arg2)
                    local text = options.Text or options.text or options.name or options.Name or flag
                    local default = options.Default
                    if default == nil then default = options.default or false end
                    local callback = options.Callback or options.callback or function() end

                    local obj = library:create("TextButton", {
                        Parent = scroll,
                        Text = "",
                        Name = text,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 22),
                        BorderSizePixel = 0,
                        AutoButtonColor = false
                    })

                    -- Grand Checkbox Agrandie (16x16)
                    local toggle_box = library:create("Frame", {
                        Parent = obj,
                        Name = "ToggleBox",
                        Size = UDim2.new(0, 16, 0, 16),
                        Position = UDim2.new(0, 2, 0.5, -8),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(20, 20, 24)
                    })
                    make_corner(toggle_box, 3)
                    local box_stroke = make_stroke(toggle_box, library.theme.border_dark, 1)

                    -- Icône Checkmark
                    local check_icon = library:create("ImageLabel", {
                        Parent = toggle_box,
                        Name = "CheckIcon",
                        Size = UDim2.new(0, 12, 0, 12),
                        Position = UDim2.new(0.5, -6, 0.5, -6),
                        BackgroundTransparency = 1,
                        Image = "rbxassetid://10709790644",
                        ImageColor3 = Color3.fromRGB(255, 255, 255),
                        Visible = false
                    })

                    local lbl = library:create("TextLabel", {
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        TextColor3 = Color3.fromRGB(178, 178, 185),
                        Text = text,
                        Parent = obj,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 26, 0, 0),
                        Size = UDim2.new(1, -80, 1, 0),
                        BorderSizePixel = 0,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextSize = 12,
                    })

                    local extra_container = library:create("Frame", {
                        Size = UDim2.new(0, 50, 1, 0),
                        Position = UDim2.new(1, -50, 0, 0),
                        BackgroundTransparency = 1,
                        Parent = obj
                    })
                    library:create("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        Padding = UDim.new(0, 4),
                        Parent = extra_container
                    })

                    local state = false
                    local toggle_instance = {
                        Value = default,
                        Type = "Toggle",
                        ChangedCallbacks = {},
                    }

                    local function set(bool)
                        state = bool
                        toggle_instance.Value = bool
                        library:tween(lbl, {TextColor3 = bool and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(178, 178, 185)})
                        if bool then
                            toggle_box.BackgroundColor3 = library.theme.accent
                            box_stroke.Color = library.theme.accent
                            check_icon.Visible = true
                        else
                            toggle_box.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
                            box_stroke.Color = library.theme.border_dark
                            check_icon.Visible = false
                        end
                        library.flags[flag] = bool
                        pcall(callback, bool)
                        toggle_instance:RunChanged()
                    end

                    obj.MouseButton1Click:Connect(function()
                        set(not state)
                    end)

                    function toggle_instance:SetValue(val)
                        set(val)
                    end

                    function toggle_instance:OnChanged(fn)
                        table.insert(self.ChangedCallbacks, fn)
                        return {
                            Disconnect = function()
                                local idx = table.find(self.ChangedCallbacks, fn)
                                if idx then table.remove(self.ChangedCallbacks, idx) end
                            end
                        }
                    end

                    function toggle_instance:RunChanged()
                        for _, fn in ipairs(self.ChangedCallbacks) do
                            pcall(fn, self.Value)
                        end
                    end

                    -- Inline ColorPicker on Toggle
                    function toggle_instance:AddColorPicker(cp_arg1, cp_arg2)
                        local cp_flag, cp_opts = parse_args(cp_arg1, cp_arg2)
                        return section_obj:_create_color_widget(extra_container, cp_flag, cp_opts)
                    end

                    -- Inline KeyPicker on Toggle
                    function toggle_instance:AddKeyPicker(kp_arg1, kp_arg2)
                        local kp_flag, kp_opts = parse_args(kp_arg1, kp_arg2)
                        return section_obj:_create_key_widget(extra_container, kp_flag, kp_opts)
                    end

                    set(default)
                    library.Toggles[flag] = toggle_instance
                    library.Options[flag] = toggle_instance
                    library.config_flags[flag] = function(v) toggle_instance:SetValue(v) end

                    return toggle_instance
                end
                section_obj.Toggle = section_obj.AddToggle
                section_obj.toggle = section_obj.AddToggle

                -- =====================================================================
                -- SLIDER (AddSlider)
                -- =====================================================================
                function section_obj:AddSlider(arg1, arg2)
                    local flag, options = parse_args(arg1, arg2)
                    local text = options.Text or options.text or options.name or options.Name or flag
                    local suffix = options.Suffix or options.suffix or ""
                    local callback = options.Callback or options.callback or function() end
                    local min = options.Min or options.min or options.minimum or 0
                    local max = options.Max or options.max or options.maximum or 100
                    local intervals = options.Rounding or options.interval or options.decimal or 1
                    local default = options.Default
                    if default == nil then default = options.default or min end
                    local value = default

                    local holder = library:create("Frame", {
                        Parent = scroll,
                        Name = text,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 24),
                        BorderSizePixel = 0,
                    })

                    local name_lbl = library:create("TextLabel", {
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        TextColor3 = Color3.fromRGB(178, 178, 178),
                        Text = text,
                        Parent = holder,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(1, -45, 0, 11),
                        BorderSizePixel = 0,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })

                    local val_lbl = library:create("TextLabel", {
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        Text = tostring(default) .. suffix,
                        Parent = holder,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -45, 0, 0),
                        Size = UDim2.new(0, 45, 0, 11),
                        BorderSizePixel = 0,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Right,
                    })

                    local slider_parent = library:create("TextButton", {
                        Parent = holder,
                        BackgroundTransparency = 1,
                        Text = "",
                        Position = UDim2.new(0, 0, 0, 13),
                        Size = UDim2.new(1, 0, 0, 9),
                        BorderSizePixel = 0,
                        AutoButtonColor = false,
                    })

                    local slider_holder = library:create("Frame", {
                        AnchorPoint = Vector2.new(0, 0.5),
                        Parent = slider_parent,
                        Position = UDim2.new(0, 0, 0.5, 0),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        Size = UDim2.new(1, 0, 0, 5),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    })

                    local gradient_holder = library:create("Frame", {
                        Parent = slider_holder,
                        Position = UDim2.new(0, 1, 0, 1),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        Size = UDim2.new(1, -2, 1, -2),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    })

                    library:create("UIGradient", {
                        Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(93, 93, 93))
                        }),
                        Parent = gradient_holder
                    })

                    local slider_thumb = library:create("Frame", {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Parent = gradient_holder,
                        Position = UDim2.new(0, 0, 0.5, 0),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        Size = UDim2.new(0, 5, 0, 9),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                        ZIndex = 3,
                    })

                    library:create("Frame", {
                        Parent = slider_thumb,
                        Position = UDim2.new(0, 1, 0, 1),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        Size = UDim2.new(1, -2, 1, -2),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        ZIndex = 4,
                    })

                    local slider_instance = {
                        Value = default,
                        Type = "Slider",
                        ChangedCallbacks = {},
                    }

                    local function set(v)
                        value = math.clamp(library:round(tonumber(v) or min, intervals), min, max)
                        slider_instance.Value = value
                        local pct = (max == min and 0 or (value - min) / (max - min))
                        slider_thumb.Position = UDim2.new(pct, 0, 0.5, 0)
                        val_lbl.Text = tostring(value) .. suffix
                        library.flags[flag] = value
                        pcall(callback, value)
                        slider_instance:RunChanged()
                    end

                    local dragging = false
                    slider_parent.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = true
                            local sx = math.clamp((input.Position.X - gradient_holder.AbsolutePosition.X) / gradient_holder.AbsoluteSize.X, 0, 1)
                            set(((max - min) * sx) + min)
                        end
                    end)

                    library:connection(UserInputService.InputChanged, function(input)
                        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            local sx = math.clamp((input.Position.X - gradient_holder.AbsolutePosition.X) / gradient_holder.AbsoluteSize.X, 0, 1)
                            set(((max - min) * sx) + min)
                        end
                    end)

                    library:connection(UserInputService.InputEnded, function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = false
                        end
                    end)

                    function slider_instance:SetValue(v)
                        set(v)
                    end

                    function slider_instance:OnChanged(fn)
                        table.insert(self.ChangedCallbacks, fn)
                        return {
                            Disconnect = function()
                                local idx = table.find(self.ChangedCallbacks, fn)
                                if idx then table.remove(self.ChangedCallbacks, idx) end
                            end
                        }
                    end

                    function slider_instance:RunChanged()
                        for _, fn in ipairs(self.ChangedCallbacks) do
                            pcall(fn, self.Value)
                        end
                    end

                    set(default)
                    library.Options[flag] = slider_instance
                    library.config_flags[flag] = function(v) slider_instance:SetValue(v) end

                    return slider_instance
                end
                section_obj.Slider = section_obj.AddSlider
                section_obj.slider = section_obj.AddSlider
                -- =====================================================================
                -- DROPDOWN (AddDropdown)
                -- =====================================================================
                function section_obj:AddDropdown(arg1, arg2)
                    local flag, options = parse_args(arg1, arg2)
                    local text = options.Text or options.text or options.name or options.Name or flag
                    local items_list = options.Values or options.values or options.items or options.Items or {}
                    local callback = options.Callback or options.callback or function() end
                    local multi = options.Multi or options.multi or false

                    local default = options.Default or options.default or (multi and {items_list[1]} or items_list[1] or "None")
                    local open = false
                    local option_instances = {}
                    local multi_items = {}

                    local holder = library:create("Frame", {
                        Parent = scroll,
                        Name = text,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 34),
                        BorderSizePixel = 0,
                    })

                    local label_text = library:create("TextLabel", {
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        TextColor3 = Color3.fromRGB(180, 180, 185),
                        Text = text,
                        Parent = holder,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(1, 0, 0, 12),
                        BorderSizePixel = 0,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })

                    local dropdown_outline = library:create("TextButton", {
                        Parent = holder,
                        Text = "",
                        AutoButtonColor = false,
                        Position = UDim2.new(0, 0, 0, 14),
                        Size = UDim2.new(1, 0, 0, 18),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(12, 12, 15)
                    })
                    make_corner(dropdown_outline, 3)
                    make_stroke(dropdown_outline, library.theme.border_dark, 1)

                    local inner_text = library:create("TextLabel", {
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        TextColor3 = Color3.fromRGB(220, 220, 225),
                        Text = "None",
                        Parent = dropdown_outline,
                        Size = UDim2.new(1, -22, 1, 0),
                        Position = UDim2.new(0, 6, 0, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })

                    local arrow = library:create("ImageLabel", {
                        ImageColor3 = Color3.fromRGB(180, 180, 185),
                        Parent = dropdown_outline,
                        AnchorPoint = Vector2.new(1, 0.5),
                        Image = "rbxassetid://10709790948",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -6, 0.5, 0),
                        Size = UDim2.new(0, 10, 0, 10),
                        BorderSizePixel = 0,
                    })

                    -- Dropdown Popup Container
                    local dropdown_holder = library:create("Frame", {
                        Name = "DropdownPopup_" .. tostring(flag),
                        Parent = window_obj.screen,
                        Size = UDim2.new(0, 120, 0, 100),
                        Visible = false,
                        ZIndex = 500,
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(18, 18, 22),
                    })
                    make_corner(dropdown_holder, 4)
                    make_stroke(dropdown_holder, library.theme.border_dark, 1)

                    local options_scroll = library:create("ScrollingFrame", {
                        Name = "OptionsScroll",
                        Parent = dropdown_holder,
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        ScrollBarThickness = 2,
                        ScrollBarImageColor3 = library.theme.accent,
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        CanvasSize = UDim2.new(0, 0, 0, 0),
                        ZIndex = 501,
                    })

                    library:create("UIListLayout", {
                        Parent = options_scroll,
                        Padding = UDim.new(0, 2),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    })
                    library:create("UIPadding", {
                        PaddingBottom = UDim.new(0, 3),
                        PaddingTop = UDim.new(0, 3),
                        PaddingLeft = UDim.new(0, 3),
                        PaddingRight = UDim.new(0, 3),
                        Parent = options_scroll
                    })

                    local dropdown_instance = {
                        Value = default,
                        Values = items_list,
                        Multi = multi,
                        Type = "Dropdown",
                        ChangedCallbacks = {},
                    }

                    local function update_position()
                        local outline_pos = dropdown_outline.AbsolutePosition
                        local outline_size = dropdown_outline.AbsoluteSize
                        local main_pos = window_obj.main.AbsolutePosition
                        local count = #dropdown_instance.Values
                        local computed_height = math.clamp(count * 20 + 8, 26, 140)
                        local target_width = math.max(outline_size.X, 100)

                        dropdown_holder.Parent = window_obj.main
                        dropdown_holder.ZIndex = 500
                        dropdown_holder.AnchorPoint = Vector2.new(0, 0)
                        -- Toujours collé directement sous le bouton, déroulement vers le bas
                        dropdown_holder.Position = UDim2.new(0, outline_pos.X - main_pos.X, 0, (outline_pos.Y - main_pos.Y) + outline_size.Y + 2)
                        return target_width, computed_height
                    end

                    dropdown_outline:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
                        if open then
                            pcall(update_position)
                        end
                    end)

                    local function set_visible(bool)
                        if bool then
                            if library.ActiveDropdown and library.ActiveDropdown ~= dropdown_instance then
                                pcall(function() library.ActiveDropdown:Close() end)
                            end
                            library.ActiveDropdown = dropdown_instance
                            open = true
                            local target_width, computed_height = update_position()
                            dropdown_holder.ClipsDescendants = true
                            dropdown_holder.Size = UDim2.new(0, target_width, 0, 0)
                            dropdown_holder.Visible = true
                            library:tween(dropdown_holder, { Size = UDim2.new(0, target_width, 0, computed_height) }, Enum.EasingStyle.Quart, 0.2)
                            library:tween(arrow, { Rotation = 180 }, Enum.EasingStyle.Quad, 0.2)
                            make_stroke(dropdown_outline, library.theme.accent, 1)
                        else
                            open = false
                            make_stroke(dropdown_outline, library.theme.border_dark, 1)
                            library:tween(arrow, { Rotation = 0 }, Enum.EasingStyle.Quad, 0.15)
                            local tw = library:tween(dropdown_holder, { Size = UDim2.new(0, dropdown_holder.AbsoluteSize.X, 0, 0) }, Enum.EasingStyle.Quad, 0.15)
                            tw.Completed:Connect(function()
                                if not open then
                                    dropdown_holder.Visible = false
                                end
                            end)
                            if library.ActiveDropdown == dropdown_instance then
                                library.ActiveDropdown = nil
                            end
                        end
                    end

                    local function set(value)
                        local selected = {}
                        local isTable = type(value) == "table"

                        if type(value) == "number" and dropdown_instance.Values[value] then
                            value = dropdown_instance.Values[value]
                        end

                        if multi then
                            if isTable then
                                for k, v in pairs(value) do
                                    if type(k) == "string" and v == true then
                                        table.insert(selected, k)
                                    elseif type(v) == "string" then
                                        table.insert(selected, v)
                                    end
                                end
                            elseif value ~= nil and tostring(value) ~= "" and tostring(value) ~= "None" then
                                table.insert(selected, tostring(value))
                            end
                            multi_items = selected
                        else
                            if value ~= nil and tostring(value) ~= "" then
                                table.insert(selected, tostring(value))
                            end
                        end

                        for _, opt_btn in ipairs(option_instances) do
                            local opt_name = opt_btn:GetAttribute("ItemValue") or opt_btn.Text
                            local is_sel = false
                            if multi then
                                is_sel = table.find(multi_items, opt_name) ~= nil
                            else
                                is_sel = (selected[1] == opt_name)
                            end
                            if is_sel then
                                opt_btn.TextColor3 = library.theme.accent
                                opt_btn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
                                opt_btn.BackgroundTransparency = 0
                            else
                                opt_btn.TextColor3 = Color3.fromRGB(180, 180, 185)
                                opt_btn.BackgroundTransparency = 1
                            end
                        end

                        local res
                        if multi then
                            res = multi_items
                            inner_text.Text = #selected > 0 and table.concat(selected, ", ") or "None"
                        else
                            res = selected[1] or "None"
                            inner_text.Text = tostring(res)
                        end

                        dropdown_instance.Value = res
                        library.flags[flag] = res
                        pcall(callback, res)
                        dropdown_instance:RunChanged()
                    end

                    local function refresh_options(list)
                        list = list or {}
                        dropdown_instance.Values = list
                        for _, opt in ipairs(option_instances) do
                            pcall(function() opt:Destroy() end)
                        end
                        option_instances = {}

                        for idx, item_name in ipairs(list) do
                            local item_str = tostring(item_name)
                            local opt_btn = library:create("TextButton", {
                                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                                TextColor3 = Color3.fromRGB(180, 180, 185),
                                Text = "  " .. item_str,
                                Parent = options_scroll,
                                Size = UDim2.new(1, 0, 0, 18),
                                BackgroundColor3 = Color3.fromRGB(25, 25, 30),
                                BackgroundTransparency = 1,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                BorderSizePixel = 0,
                                TextSize = 11,
                                AutoButtonColor = false,
                                ZIndex = 502,
                                LayoutOrder = idx
                            })
                            make_corner(opt_btn, 2)
                            opt_btn:SetAttribute("ItemValue", item_str)
                            table.insert(option_instances, opt_btn)

                            opt_btn.MouseEnter:Connect(function()
                                opt_btn.BackgroundTransparency = 0.4
                                opt_btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                            end)
                            opt_btn.MouseLeave:Connect(function()
                                local is_sel = (multi and table.find(multi_items, item_str)) or (not multi and dropdown_instance.Value == item_str)
                                if is_sel then
                                    opt_btn.TextColor3 = library.theme.accent
                                    opt_btn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
                                    opt_btn.BackgroundTransparency = 0
                                else
                                    opt_btn.TextColor3 = Color3.fromRGB(180, 180, 185)
                                    opt_btn.BackgroundTransparency = 1
                                end
                            end)

                            opt_btn.MouseButton1Click:Connect(function()
                                if multi then
                                    local found = table.find(multi_items, item_str)
                                    if found then
                                        table.remove(multi_items, found)
                                    else
                                        table.insert(multi_items, item_str)
                                    end
                                    set(multi_items)
                                else
                                    set(item_str)
                                    set_visible(false)
                                end
                            end)
                        end

                        if open then update_position() end
                    end

                    dropdown_outline.MouseButton1Click:Connect(function()
                        set_visible(not open)
                    end)

                    library:connection(UserInputService.InputBegan, function(input)
                        if not open then return end
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            task.defer(function()
                                if not open then return end
                                local in_btn = dropdown_outline and library:mouse_in_frame(dropdown_outline)
                                local in_holder = dropdown_holder and library:mouse_in_frame(dropdown_holder)
                                if not in_btn and not in_holder then
                                    set_visible(false)
                                end
                            end)
                        end
                    end)

                    function dropdown_instance:SetValue(val)
                        set(val)
                    end

                    function dropdown_instance:SetValues(list)
                        refresh_options(list)
                        if not multi then
                            if not table.find(list, self.Value) then
                                set(list[1] or "None")
                            end
                        end
                    end

                    function dropdown_instance:GetActiveValues(return_count)
                        if multi then
                            return return_count and #self.Value or self.Value
                        else
                            return self.Value
                        end
                    end

                    function dropdown_instance:OnChanged(fn)
                        table.insert(self.ChangedCallbacks, fn)
                        return {
                            Disconnect = function()
                                local idx = table.find(self.ChangedCallbacks, fn)
                                if idx then table.remove(self.ChangedCallbacks, idx) end
                            end
                        }
                    end

                    function dropdown_instance:RunChanged()
                        for _, fn in ipairs(self.ChangedCallbacks) do
                            pcall(fn, self.Value)
                        end
                    end

                    function dropdown_instance:SetVisible(vis)
                        holder.Visible = vis
                    end

                    function dropdown_instance:SetDisabled(dis)
                        dropdown_outline.Active = not dis
                    end

                    function dropdown_instance:SetText(t)
                        label_text.Text = tostring(t)
                    end

                    function dropdown_instance:Display()
                        return self.Value
                    end

                    function dropdown_instance:Close()
                        set_visible(false)
                    end

                    function dropdown_instance:Open()
                        set_visible(true)
                    end

                    refresh_options(items_list)
                    set(default)
                    library.Options[flag] = dropdown_instance
                    library.config_flags[flag] = function(v) dropdown_instance:SetValue(v) end

                    return dropdown_instance
                end
                section_obj.Dropdown = section_obj.AddDropdown
                section_obj.dropdown = section_obj.AddDropdown
                -- =====================================================================
                -- COLORPICKER (AddColorPicker)
                -- =====================================================================
                function section_obj:_create_color_widget(parent_frame, flag, options)
                    local default_col = options.Default or options.default or options.color or options.Color or Color3.fromRGB(0, 215, 165)
                    local callback = options.Callback or options.callback or function() end
                    local title = options.Title or options.title or options.Text or options.text or flag

                    local col_btn = library:create("TextButton", {
                        Parent = parent_frame,
                        Size = UDim2.new(0, 20, 0, 11),
                        BackgroundColor3 = default_col,
                        BorderSizePixel = 0,
                        Text = "",
                        AutoButtonColor = false,
                    })
                    make_corner(col_btn, 2)
                    make_stroke(col_btn, library.theme.border_dark, 1)

                    local current_col = default_col
                    local current_alpha = 0
                    local hue, sat, vib = default_col:ToHSV()

                    local cp_instance = {
                        Value = default_col,
                        Transparency = 0,
                        Type = "ColorPicker",
                        ChangedCallbacks = {},
                    }

                    local function set(c, alpha)
                        current_col = c
                        current_alpha = alpha or 0
                        hue, sat, vib = c:ToHSV()
                        cp_instance.Value = c
                        cp_instance.Transparency = current_alpha
                        col_btn.BackgroundColor3 = c
                        library.flags[flag] = c
                        pcall(callback, c, current_alpha)
                        cp_instance:RunChanged()
                    end

                    function cp_instance:SetValue(c)
                        set(c, current_alpha)
                    end

                    function cp_instance:SetValueRGB(c, alpha)
                        set(c, alpha)
                    end

                    function cp_instance:ToHex()
                        return cp_instance.Value:ToHex()
                    end

                    function cp_instance:OnChanged(fn)
                        table.insert(self.ChangedCallbacks, fn)
                        return {
                            Disconnect = function()
                                local idx = table.find(self.ChangedCallbacks, fn)
                                if idx then table.remove(self.ChangedCallbacks, idx) end
                            end
                        }
                    end

                    function cp_instance:RunChanged()
                        for _, fn in ipairs(self.ChangedCallbacks) do
                            pcall(fn, self.Value, self.Transparency)
                        end
                    end

                    -- Real Interactive Color Picker Popup
                    local popup_open = false
                    local cp_popup = library:create("Frame", {
                        Name = "ColorPickerPopup_" .. tostring(flag),
                        Size = UDim2.new(0, 194, 0, 180),
                        BackgroundColor3 = Color3.fromRGB(20, 20, 24),
                        BorderSizePixel = 0,
                        Visible = false,
                        ZIndex = 600,
                        Parent = window_obj.screen
                    })
                    make_corner(cp_popup, 4)
                    make_stroke(cp_popup, library.theme.border_dark, 1)

                    -- Header
                    local cp_header = library:create("Frame", {
                        Size = UDim2.new(1, -12, 0, 20),
                        Position = UDim2.new(0, 6, 0, 4),
                        BackgroundTransparency = 1,
                        Parent = cp_popup,
                        ZIndex = 601
                    })

                    library:create("TextLabel", {
                        Size = UDim2.new(1, -20, 1, 0),
                        BackgroundTransparency = 1,
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                        Text = tostring(title),
                        TextColor3 = Color3.fromRGB(230, 230, 235),
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = cp_header,
                        ZIndex = 601
                    })

                    local close_btn = library:create("TextButton", {
                        Size = UDim2.new(0, 16, 0, 16),
                        Position = UDim2.new(1, -16, 0.5, -8),
                        BackgroundTransparency = 1,
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                        Text = "x",
                        TextColor3 = Color3.fromRGB(160, 160, 165),
                        TextSize = 12,
                        Parent = cp_header,
                        ZIndex = 601
                    })

                    -- Saturation / Value Map
                    local sv_map = library:create("ImageButton", {
                        Name = "SVMap",
                        Size = UDim2.new(0, 150, 0, 116),
                        Position = UDim2.new(0, 6, 0, 26),
                        BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
                        Image = "rbxassetid://4155801252",
                        BorderSizePixel = 0,
                        AutoButtonColor = false,
                        Parent = cp_popup,
                        ZIndex = 602
                    })
                    make_corner(sv_map, 3)

                    local sv_cursor = library:create("Frame", {
                        Size = UDim2.new(0, 6, 0, 6),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(sat, 0, 1 - vib, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BorderSizePixel = 0,
                        Parent = sv_map,
                        ZIndex = 603
                    })
                    make_corner(sv_cursor, 3)
                    make_stroke(sv_cursor, Color3.fromRGB(0, 0, 0), 1)

                    -- Hue Bar
                    local hue_bar = library:create("ImageButton", {
                        Name = "HueBar",
                        Size = UDim2.new(0, 20, 0, 116),
                        Position = UDim2.new(1, -26, 0, 26),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        AutoButtonColor = false,
                        Parent = cp_popup,
                        ZIndex = 602
                    })
                    make_corner(hue_bar, 3)
                    make_stroke(hue_bar, library.theme.border_dark, 1)

                    local hue_grad = library:create("UIGradient", {
                        Rotation = 90,
                        Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                            ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                            ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                            ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                            ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                        }),
                        Parent = hue_bar
                    })

                    local hue_cursor = library:create("Frame", {
                        Size = UDim2.new(1, 2, 0, 2),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 0, hue, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BorderSizePixel = 0,
                        Parent = hue_bar,
                        ZIndex = 603
                    })
                    make_stroke(hue_cursor, Color3.fromRGB(0, 0, 0), 1)

                    -- Bottom Info & Hex Input
                    local hex_box = library:create("TextBox", {
                        Size = UDim2.new(1, -12, 0, 22),
                        Position = UDim2.new(0, 6, 0, 148),
                        BackgroundColor3 = Color3.fromRGB(14, 14, 18),
                        BorderSizePixel = 0,
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        Text = "#" .. default_col:ToHex():upper() .. " • " .. string.format("%d, %d, %d", math.floor(default_col.R*255), math.floor(default_col.G*255), math.floor(default_col.B*255)),
                        TextColor3 = Color3.fromRGB(200, 200, 205),
                        TextSize = 11,
                        Parent = cp_popup,
                        ZIndex = 602
                    })
                    make_corner(hex_box, 3)
                    make_stroke(hex_box, library.theme.border_dark, 1)

                    local function update_popup_ui()
                        sv_map.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                        sv_cursor.Position = UDim2.new(sat, 0, 1 - vib, 0)
                        hue_cursor.Position = UDim2.new(0.5, 0, hue, 0)
                        hex_box.Text = "#" .. current_col:ToHex():upper() .. " • " .. string.format("%d, %d, %d", math.floor(current_col.R*255), math.floor(current_col.G*255), math.floor(current_col.B*255))
                    end

                    -- Accurate mouse synchronization via Mouse.X & Mouse.Y + RenderStepped
                    sv_map.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                                local min_x = sv_map.AbsolutePosition.X
                                local max_x = min_x + sv_map.AbsoluteSize.X
                                local loc_x = math.clamp(Mouse.X, min_x, max_x)

                                local min_y = sv_map.AbsolutePosition.Y
                                local max_y = min_y + sv_map.AbsoluteSize.Y
                                local loc_y = math.clamp(Mouse.Y, min_y, max_y)

                                sat = (loc_x - min_x) / (max_x - min_x)
                                vib = 1 - ((loc_y - min_y) / (max_y - min_y))

                                set(Color3.fromHSV(hue, sat, vib))
                                update_popup_ui()
                                RunService.RenderStepped:Wait()
                            end
                        end
                    end)

                    hue_bar.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                                local min_y = hue_bar.AbsolutePosition.Y
                                local max_y = min_y + hue_bar.AbsoluteSize.Y
                                local loc_y = math.clamp(Mouse.Y, min_y, max_y)

                                hue = (loc_y - min_y) / (max_y - min_y)

                                set(Color3.fromHSV(hue, sat, vib))
                                update_popup_ui()
                                RunService.RenderStepped:Wait()
                            end
                        end
                    end)

                    hex_box.FocusLost:Connect(function()
                        local clean = hex_box.Text:gsub("#", ""):gsub("%s.*$", "")
                        local ok, col = pcall(Color3.fromHex, clean)
                        if ok and col then
                            set(col)
                            update_popup_ui()
                        else
                            update_popup_ui()
                        end
                    end)

                    local function toggle_popup()
                        popup_open = not popup_open
                        cp_popup.Visible = popup_open
                        if popup_open then
                            local bpos = col_btn.AbsolutePosition
                            local bsize = col_btn.AbsoluteSize
                            local cam_y = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.Y) or 1000
                            local pop_h = 180
                            if bpos.Y + bsize.Y + pop_h > cam_y - 10 then
                                cp_popup.Position = UDim2.new(0, bpos.X - 170, 0, bpos.Y - pop_h - 2)
                            else
                                cp_popup.Position = UDim2.new(0, bpos.X - 170, 0, bpos.Y + bsize.Y + 2)
                            end
                            update_popup_ui()
                        end
                    end

                    col_btn.MouseButton1Click:Connect(toggle_popup)
                    close_btn.MouseButton1Click:Connect(function()
                        popup_open = false
                        cp_popup.Visible = false
                    end)

                    library:connection(UserInputService.InputBegan, function(input)
                        if not popup_open then return end
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            task.defer(function()
                                if not popup_open then return end
                                local in_btn = col_btn and library:mouse_in_frame(col_btn)
                                local in_popup = cp_popup and library:mouse_in_frame(cp_popup)
                                if not in_btn and not in_popup then
                                    popup_open = false
                                    cp_popup.Visible = false
                                end
                            end)
                        end
                    end)

                    set(default_col)
                    library.Options[flag] = cp_instance
                    library.config_flags[flag] = function(v) cp_instance:SetValue(v) end
                    return cp_instance
                end

                function section_obj:AddColorPicker(arg1, arg2)
                    local flag, options = parse_args(arg1, arg2)
                    local text = options.Title or options.title or options.Text or options.text or options.name or options.Name or flag

                    local holder = library:create("Frame", {
                        Parent = scroll,
                        Size = UDim2.new(1, 0, 0, 16),
                        BackgroundTransparency = 1,
                    })

                    library:create("TextLabel", {
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        TextColor3 = Color3.fromRGB(178, 178, 178),
                        Text = text,
                        Parent = holder,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, -24, 1, 0),
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })

                    local extra_box = library:create("Frame", {
                        Size = UDim2.new(0, 24, 1, 0),
                        Position = UDim2.new(1, -24, 0, 0),
                        BackgroundTransparency = 1,
                        Parent = holder
                    })
                    library:create("UIListLayout", {
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        Parent = extra_box
                    })

                    return section_obj:_create_color_widget(extra_box, flag, options)
                end
                section_obj.Colorpicker = section_obj.AddColorPicker
                section_obj.colorpicker = section_obj.AddColorPicker

                -- =====================================================================
                -- KEYPICKER (AddKeyPicker / Keybind)
                -- =====================================================================
                function section_obj:_create_key_widget(parent_frame, flag, options)
                    local raw_def = options.Default or options.default or options.key or options.Key or "None"
                    local default_key = raw_def
                    if typeof(raw_def) == "string" and Enum.KeyCode[raw_def] then
                        default_key = Enum.KeyCode[raw_def]
                    elseif typeof(raw_def) ~= "EnumItem" then
                        default_key = Enum.KeyCode.E
                    end

                    local mode = options.Mode or options.mode or "Toggle"
                    local callback = options.Callback or options.callback or function() end

                    local btn = library:create("TextButton", {
                        Parent = parent_frame,
                        Size = UDim2.new(0, 36, 0, 14),
                        BackgroundColor3 = library.theme.element_bg,
                        BorderSizePixel = 0,
                        Font = Enum.Font.SourceSansBold,
                        Text = "[" .. default_key.Name .. "]",
                        TextColor3 = Color3.fromRGB(178, 178, 178),
                        TextSize = 10,
                        AutoButtonColor = false,
                    })
                    make_corner(btn, 2)
                    make_stroke(btn, library.theme.border_dark, 1)

                    local current_key = default_key
                    local listening = false
                    local kp_instance = {
                        Value = default_key.Name,
                        Mode = mode,
                        Toggled = false,
                        Type = "KeyPicker",
                        ChangedCallbacks = {},
                    }

                    local function set(k)
                        if typeof(k) == "table" then
                            k = k[1]
                        end
                        if typeof(k) == "string" and Enum.KeyCode[k] then
                            current_key = Enum.KeyCode[k]
                        elseif typeof(k) == "EnumItem" then
                            current_key = k
                        end
                        kp_instance.Value = current_key.Name
                        btn.Text = "[" .. current_key.Name .. "]"
                        library.flags[flag] = current_key.Name
                        pcall(callback, current_key)
                        kp_instance:RunChanged()
                    end

                    btn.MouseButton1Click:Connect(function()
                        listening = true
                        btn.Text = "[...]"
                    end)

                    library:connection(UserInputService.InputBegan, function(input, gpe)
                        if listening and not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
                            listening = false
                            set(input.KeyCode)
                        elseif not gpe and input.KeyCode == current_key then
                            kp_instance.Toggled = not kp_instance.Toggled
                            pcall(callback, kp_instance.Toggled)
                        end
                    end)

                    function kp_instance:SetValue(val)
                        set(val)
                    end

                    function kp_instance:OnChanged(fn)
                        table.insert(self.ChangedCallbacks, fn)
                        return {
                            Disconnect = function()
                                local idx = table.find(self.ChangedCallbacks, fn)
                                if idx then table.remove(self.ChangedCallbacks, idx) end
                            end
                        }
                    end

                    function kp_instance:RunChanged()
                        for _, fn in ipairs(self.ChangedCallbacks) do
                            pcall(fn, self.Value)
                        end
                    end

                    set(default_key)
                    library.Options[flag] = kp_instance
                    return kp_instance
                end

                function section_obj:AddKeyPicker(arg1, arg2)
                    local flag, options = parse_args(arg1, arg2)
                    local text = options.Text or options.text or options.name or options.Name or flag

                    local holder = library:create("Frame", {
                        Parent = scroll,
                        Size = UDim2.new(1, 0, 0, 16),
                        BackgroundTransparency = 1,
                    })

                    library:create("TextLabel", {
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        TextColor3 = Color3.fromRGB(178, 178, 178),
                        Text = text,
                        Parent = holder,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, -40, 1, 0),
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })

                    local extra_box = library:create("Frame", {
                        Size = UDim2.new(0, 40, 1, 0),
                        Position = UDim2.new(1, -40, 0, 0),
                        BackgroundTransparency = 1,
                        Parent = holder
                    })
                    library:create("UIListLayout", {
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        Parent = extra_box
                    })

                    return section_obj:_create_key_widget(extra_box, flag, options)
                end
                section_obj.Keybind = section_obj.AddKeyPicker
                section_obj.keybind = section_obj.AddKeyPicker

                -- =====================================================================
                -- INPUT (AddInput)
                -- =====================================================================
                function section_obj:AddInput(arg1, arg2)
                    local flag, options = parse_args(arg1, arg2)
                    local text = options.Text or options.text or options.name or options.Name or flag
                    local default = options.Default or options.default or ""
                    local callback = options.Callback or options.callback or function() end

                    local holder = library:create("Frame", {
                        Parent = scroll,
                        Name = text,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 32),
                        BorderSizePixel = 0,
                    })

                    library:create("TextLabel", {
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        TextColor3 = Color3.fromRGB(178, 178, 178),
                        Text = text,
                        Parent = holder,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(1, 0, 0, 11),
                        BorderSizePixel = 0,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })

                    local input_outline = library:create("Frame", {
                        Parent = holder,
                        Position = UDim2.new(0, 0, 0, 13),
                        Size = UDim2.new(1, 0, 0, 17),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    })

                    local input_box = library:create("TextBox", {
                        Parent = input_outline,
                        Size = UDim2.new(1, -2, 1, -2),
                        Position = UDim2.new(0, 1, 0, 1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = library.theme.element_bg,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
                        PlaceholderText = "...",
                        Text = default,
                        ClearTextOnFocus = false,
                        Font = Enum.Font.SourceSans,
                        TextSize = 11,
                    })

                    local input_instance = {
                        Value = default,
                        Type = "Input",
                        ChangedCallbacks = {},
                    }

                    local function set(t)
                        t = tostring(t or "")
                        input_instance.Value = t
                        input_box.Text = t
                        library.flags[flag] = t
                        pcall(callback, t)
                        input_instance:RunChanged()
                    end

                    input_box.FocusLost:Connect(function()
                        set(input_box.Text)
                    end)

                    function input_instance:SetValue(t)
                        set(t)
                    end

                    function input_instance:OnChanged(fn)
                        table.insert(self.ChangedCallbacks, fn)
                        return {
                            Disconnect = function()
                                local idx = table.find(self.ChangedCallbacks, fn)
                                if idx then table.remove(self.ChangedCallbacks, idx) end
                            end
                        }
                    end

                    function input_instance:RunChanged()
                        for _, fn in ipairs(self.ChangedCallbacks) do
                            pcall(fn, self.Value)
                        end
                    end

                    set(default)
                    library.Options[flag] = input_instance
                    library.config_flags[flag] = function(v) input_instance:SetValue(v) end

                    return input_instance
                end
                section_obj.Input = section_obj.AddInput
                section_obj.input = section_obj.AddInput

                -- =====================================================================
                -- BUTTON (AddButton)
                -- =====================================================================
                function section_obj:AddButton(arg1, arg2)
                    local text, callback
                    if type(arg1) == "table" then
                        text = arg1.Text or arg1.text or arg1.Name or arg1.name or "Button"
                        callback = arg1.Func or arg1.func or arg1.Callback or arg1.callback or function() end
                    else
                        text = tostring(arg1 or "Button")
                        callback = arg2 or function() end
                    end

                    local btn = library:create("TextButton", {
                        Parent = scroll,
                        Name = text,
                        AutoButtonColor = false,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 20),
                        BorderSizePixel = 0,
                        Text = "",
                    })

                    local button_outline = library:create("Frame", {
                        Parent = btn,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        Size = UDim2.new(1, 0, 1, 0),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    })

                    local button_shading = library:create("Frame", {
                        Parent = button_outline,
                        Position = UDim2.new(0, 1, 0, 1),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        Size = UDim2.new(1, -2, 1, -2),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    })

                    library:create("UIGradient", {
                        Rotation = 90,
                        Parent = button_shading,
                        Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(33, 33, 33)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 8))
                        })
                    })

                    local button_text = library:create("TextLabel", {
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        TextColor3 = Color3.fromRGB(178, 178, 178),
                        Text = text,
                        Parent = button_shading,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        BorderSizePixel = 0,
                        TextSize = 11,
                    })

                    btn.MouseButton1Click:Connect(function()
                        pcall(callback)
                        button_text.TextColor3 = Color3.fromRGB(255, 255, 255)
                        library:tween(button_text, {TextColor3 = Color3.fromRGB(178, 178, 178)})
                    end)

                    return btn
                end
                section_obj.Button = section_obj.AddButton
                section_obj.button = section_obj.AddButton

                -- =====================================================================
                -- LABEL (AddLabel)
                -- =====================================================================
                function section_obj:AddLabel(arg1, arg2)
                    local text = ""
                    local subtext = nil
                    if type(arg1) == "table" then
                        text = arg1.Text or arg1.text or ""
                    else
                        text = tostring(arg1 or "")
                        subtext = arg2
                    end

                    local holder = library:create("Frame", {
                        Parent = scroll,
                        Size = UDim2.new(1, 0, 0, 16),
                        BackgroundTransparency = 1,
                    })

                    local lbl = library:create("TextLabel", {
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        TextColor3 = Color3.fromRGB(178, 178, 178),
                        Text = text,
                        Parent = holder,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, -60, 1, 0),
                        BorderSizePixel = 0,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })

                    local extra_container = library:create("Frame", {
                        Size = UDim2.new(0, 60, 1, 0),
                        Position = UDim2.new(1, -60, 0, 0),
                        BackgroundTransparency = 1,
                        Parent = holder
                    })
                    library:create("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        Padding = UDim.new(0, 4),
                        Parent = extra_container
                    })

                    if subtext and type(subtext) == "string" then
                        library:create("TextLabel", {
                            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                            TextColor3 = Color3.fromRGB(120, 120, 120),
                            Text = subtext,
                            Parent = extra_container,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 1, 0),
                            TextSize = 10,
                            TextXAlignment = Enum.TextXAlignment.Right,
                        })
                    end

                    local label_instance = {
                        TextLabel = lbl,
                        Destroyed = false,
                    }

                    function label_instance:SetText(t)
                        lbl.Text = tostring(t)
                    end

                    function label_instance:AddColorPicker(cp_arg1, cp_arg2)
                        local cp_flag, cp_opts = parse_args(cp_arg1, cp_arg2)
                        return section_obj:_create_color_widget(extra_container, cp_flag, cp_opts)
                    end

                    function label_instance:AddKeyPicker(kp_arg1, kp_arg2)
                        local kp_flag, kp_opts = parse_args(kp_arg1, kp_arg2)
                        return section_obj:_create_key_widget(extra_container, kp_flag, kp_opts)
                    end

                    return label_instance
                end
                section_obj.Label = section_obj.AddLabel
                section_obj.label = section_obj.AddLabel

                -- =====================================================================
                -- DIVIDER (AddDivider)
                -- =====================================================================
                function section_obj:AddDivider()
                    local d = library:create("Frame", {
                        Parent = scroll,
                        Size = UDim2.new(1, 0, 0, 6),
                        BackgroundTransparency = 1,
                    })
                    library:create("Frame", {
                        Parent = d,
                        Size = UDim2.new(1, 0, 0, 1),
                        Position = UDim2.new(0, 0, 0.5, 0),
                        BackgroundColor3 = library.theme.border_dark,
                        BorderSizePixel = 0,
                    })
                    return d
                end

                -- =====================================================================
                -- ESP PREVIEW
                -- =====================================================================
                function section_obj:ESPPreview(options)
                    options = options or {}
                    if options.floating or options.detached then
                        return window_obj:esp_preview(options)
                    end
                    return library:BuildESPPreview(scroll, options)
                end
                section_obj.esppreview = section_obj.ESPPreview
                section_obj.ESP = section_obj.ESPPreview

                return section_obj
            end

            table.insert(tab_obj.subtabs, sub_obj)
            return sub_obj
        end

        table.insert(window_obj.tabs, tab_obj)
        table.insert(library.Tabs, tab_obj)
        window_obj.Tabs[tab_name] = tab_obj

        if #window_obj.tabs == 1 then
            tab_obj:select()
        elseif #window_obj.tabs == 2 and window_obj.SettingsTab and window_obj.tabs[1] == window_obj.SettingsTab then
            tab_obj:select()
        end

        return tab_obj
    end

    -- ==============================================================================
    -- AUTO-DASHBOARD BUILDER
    -- ==============================================================================
    function window_obj:_build_dashboard(dcfg)
        dcfg = dcfg or {}
        local dash_tab = self:tab({
            Title = "Dashboard",
            name = "Dashboard",
            icon = "rbxassetid://10723424505"
        })
        self.DashboardTab = dash_tab
        self.Tabs["Dashboard"] = dash_tab

        -- Ensure subtab bar is hidden
        if dash_tab.subtab_bar then
            dash_tab.subtab_bar.Visible = false
        end
        if dash_tab.sub_content then
            dash_tab.sub_content.Visible = false
        end

        local container = library:create("ScrollingFrame", {
            Name = "DashboardContainer",
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = library.theme.accent,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Parent = dash_tab.page
        })

        library:create("UIPadding", {
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 6),
            PaddingBottom = UDim.new(0, 8),
            Parent = container
        })

        local list_layout = library:create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = container
        })

        -- -------------------------------------------------------------
        -- 1. TOP WELCOME BANNER
        -- -------------------------------------------------------------
        local banner = library:create("Frame", {
            Name = "WelcomeBanner",
            Size = UDim2.new(1, 0, 0, 68),
            BackgroundColor3 = library.theme.panel_bg,
            BorderSizePixel = 0,
            LayoutOrder = 1,
            Parent = container
        })
        make_corner(banner, 6)
        make_stroke(banner, library.theme.border_dark, 1)

        -- Avatar Image
        local avatar = library:create("ImageLabel", {
            Name = "Avatar",
            Size = UDim2.new(0, 52, 0, 52),
            Position = UDim2.new(0, 8, 0.5, -26),
            BackgroundColor3 = library.theme.main_bg,
            BorderSizePixel = 0,
            ScaleType = Enum.ScaleType.Fit,
            Parent = banner
        })
        make_corner(avatar, 8)
        make_stroke(avatar, library.theme.border_dark, 1)

        task.spawn(function()
            local success, url = pcall(function()
                return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            end)
            if success and url then
                avatar.Image = url
            end
        end)

        -- Welcome Texts
        local text_holder = library:create("Frame", {
            Name = "Texts",
            Size = UDim2.new(1, -210, 1, 0),
            Position = UDim2.new(0, 68, 0, 0),
            BackgroundTransparency = 1,
            Parent = banner
        })

        local welcome_lbl = library:create("TextLabel", {
            Name = "Title",
            Size = UDim2.new(1, 0, 0, 24),
            Position = UDim2.new(0, 0, 0, 14),
            BackgroundTransparency = 1,
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            Text = "Welcome, " .. (LocalPlayer.DisplayName or LocalPlayer.Name),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = text_holder
        })

        local sub_lbl = library:create("TextLabel", {
            Name = "Subtitle",
            Size = UDim2.new(1, 0, 0, 18),
            Position = UDim2.new(0, 0, 0, 36),
            BackgroundTransparency = 1,
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            Text = "How's Your Day Going? | " .. LocalPlayer.Name,
            TextColor3 = Color3.fromRGB(150, 150, 155),
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = text_holder
        })

        -- Clock & Date on right
        local clock_holder = library:create("Frame", {
            Name = "ClockDate",
            Size = UDim2.new(0, 130, 1, 0),
            Position = UDim2.new(1, -138, 0, 0),
            BackgroundTransparency = 1,
            Parent = banner
        })

        local clock_lbl = library:create("TextLabel", {
            Name = "Clock",
            Size = UDim2.new(1, 0, 0, 22),
            Position = UDim2.new(0, 0, 0, 14),
            BackgroundTransparency = 1,
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            Text = os.date("%H : %M : %S"),
            TextColor3 = Color3.fromRGB(240, 240, 245),
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = clock_holder
        })

        local date_lbl = library:create("TextLabel", {
            Name = "Date",
            Size = UDim2.new(1, 0, 0, 18),
            Position = UDim2.new(0, 0, 0, 36),
            BackgroundTransparency = 1,
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            Text = os.date("%d / %m / %y"),
            TextColor3 = Color3.fromRGB(160, 160, 165),
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = clock_holder
        })

        task.spawn(function()
            while task.wait(1) do
                if not banner.Parent then break end
                clock_lbl.Text = os.date("%H : %M : %S")
                date_lbl.Text = os.date("%d / %m / %y")
            end
        end)

        -- -------------------------------------------------------------
        -- 2. 3-COLUMNS GRID
        -- -------------------------------------------------------------
        local cols_frame = library:create("Frame", {
            Name = "ColumnsGrid",
            Size = UDim2.new(1, 0, 0, 280),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder = 2,
            Parent = container
        })

        local col1 = library:create("Frame", {
            Name = "Col1",
            Size = UDim2.new(0.325, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Parent = cols_frame
        })
        library:create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = col1 })

        local col2 = library:create("Frame", {
            Name = "Col2",
            Size = UDim2.new(0.325, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.337, 0, 0, 0),
            Parent = cols_frame
        })
        library:create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = col2 })

        local col3 = library:create("Frame", {
            Name = "Col3",
            Size = UDim2.new(0.325, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.675, 0, 0, 0),
            Parent = cols_frame
        })
        library:create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = col3 })

        local function create_card(parent, title, icon_id, height, layout_order)
            local card = library:create("Frame", {
                Name = "Card_" .. title,
                Size = UDim2.new(1, 0, 0, height or 120),
                BackgroundColor3 = library.theme.panel_bg,
                BorderSizePixel = 0,
                LayoutOrder = layout_order or 1,
                Parent = parent
            })
            make_corner(card, 6)
            make_stroke(card, library.theme.border_dark, 1)

            local card_head = library:create("Frame", {
                Name = "Header",
                Size = UDim2.new(1, -16, 0, 24),
                Position = UDim2.new(0, 8, 0, 8),
                BackgroundTransparency = 1,
                Parent = card
            })

            local icon_img = library:create("ImageLabel", {
                Name = "Icon",
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 0, 0.5, -8),
                BackgroundTransparency = 1,
                Image = icon_id or "rbxassetid://10723424505",
                ImageColor3 = Color3.fromRGB(255, 255, 255),
                Parent = card_head
            })

            local title_lbl = library:create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -24, 1, 0),
                Position = UDim2.new(0, 22, 0, 0),
                BackgroundTransparency = 1,
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                Text = title,
                TextColor3 = Color3.fromRGB(240, 240, 245),
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = card_head
            })

            local body = library:create("Frame", {
                Name = "Body",
                Size = UDim2.new(1, -16, 1, -38),
                Position = UDim2.new(0, 8, 0, 32),
                BackgroundTransparency = 1,
                Parent = card
            })

            return card, body
        end

        -- ====================
        -- COL 1: DISCORD + SERVER
        -- ====================
        -- Card: Discord
        local discord_card, discord_body = create_card(col1, "Discord", "rbxassetid://10709798433", 84, 1)
        local discord_btn = library:create("TextButton", {
            Name = "JoinBtn",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            Parent = discord_body
        })
        library:create("TextLabel", {
            Name = "Desc",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            Text = "Tap to join the discord of\nyour script.",
            TextColor3 = Color3.fromRGB(155, 155, 160),
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Parent = discord_body
        })
        discord_btn.MouseButton1Click:Connect(function()
            local link = dcfg.Discord or "https://discord.gg/ezwin"
            if setclipboard then
                setclipboard(link)
                library:Notify({ Title = "Discord", Text = "Link copied to clipboard!", Duration = 3 })
            else
                library:Notify({ Title = "Discord", Text = link, Duration = 4 })
            end
        end)

        -- Card: Server
        local server_card, server_body = create_card(col1, "Server", "rbxassetid://10709769598", 196, 2)
        local game_name = "Universal"
        pcall(function()
            local info = MarketplaceService:GetProductInfo(game.PlaceId)
            if info and info.Name then game_name = info.Name end
        end)

        library:create("TextLabel", {
            Name = "GameTitle",
            Size = UDim2.new(1, 0, 0, 14),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            Text = "Currently Playing " .. (game_name:sub(1, 18) .. (game_name:len() > 18 and "..." or "")),
            TextColor3 = Color3.fromRGB(140, 140, 145),
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = server_body
        })

        local s_stats_grid = library:create("Frame", {
            Name = "StatsGrid",
            Size = UDim2.new(1, 0, 1, -20),
            Position = UDim2.new(0, 0, 0, 18),
            BackgroundTransparency = 1,
            Parent = server_body
        })

        local function make_stat_box(parent, title, val, pos, size)
            local box = library:create("Frame", {
                Size = size,
                Position = pos,
                BackgroundTransparency = 1,
                Parent = parent
            })
            library:create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 13),
                BackgroundTransparency = 1,
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                Text = title,
                TextColor3 = Color3.fromRGB(220, 220, 225),
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = box
            })
            local v_lbl = library:create("TextLabel", {
                Size = UDim2.new(1, 0, 1, -13),
                Position = UDim2.new(0, 0, 0, 13),
                BackgroundTransparency = 1,
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                Text = val,
                TextColor3 = Color3.fromRGB(145, 145, 150),
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                Parent = box
            })
            return v_lbl
        end

        local p_cnt = tostring(#Players:GetPlayers()) .. " Players In\nThis Server"
        local p_cap = tostring(Players.MaxPlayers) .. " Players In\ncan join."
        local s_players_lbl = make_stat_box(s_stats_grid, "Players", p_cnt, UDim2.new(0, 0, 0, 0), UDim2.new(0.5, -2, 0.33, 0))
        local s_cap_lbl = make_stat_box(s_stats_grid, "Capacity", p_cap, UDim2.new(0.5, 2, 0, 0), UDim2.new(0.5, -2, 0.33, 0))

        local s_latency_lbl = make_stat_box(s_stats_grid, "Latency", "60 FPS\n20ms", UDim2.new(0, 0, 0.35, 0), UDim2.new(0.5, -2, 0.33, 0))
        local s_join_box = library:create("Frame", {
            Size = UDim2.new(0.5, -2, 0.33, 0),
            Position = UDim2.new(0.5, 2, 0.35, 0),
            BackgroundTransparency = 1,
            Parent = s_stats_grid
        })
        library:create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 13),
            BackgroundTransparency = 1,
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            Text = "Join Script",
            TextColor3 = Color3.fromRGB(220, 220, 225),
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = s_join_box
        })
        local s_rejoin_btn = library:create("TextButton", {
            Size = UDim2.new(1, 0, 0, 18),
            Position = UDim2.new(0, 0, 0, 14),
            BackgroundColor3 = library.theme.main_bg,
            BorderSizePixel = 0,
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            Text = "Copy / Rejoin",
            TextColor3 = library.theme.accent,
            TextSize = 10,
            AutoButtonColor = false,
            Parent = s_join_box
        })
        make_corner(s_rejoin_btn, 3)
        make_stroke(s_rejoin_btn, library.theme.border_dark, 1)
        s_rejoin_btn.MouseButton1Click:Connect(function()
            local scr = string.format("game:GetService('TeleportService'):TeleportToPlaceInstance(%d, '%s', game:GetService('Players').LocalPlayer)", game.PlaceId, game.JobId)
            if setclipboard then setclipboard(scr) end
            library:Notify({ Title = "Server", Text = "Teleport script copied to clipboard!", Duration = 3 })
        end)

        local start_tick = tick()
        local s_time_lbl = make_stat_box(s_stats_grid, "Playtime", "0m", UDim2.new(0, 0, 0.7, 0), UDim2.new(0.5, -2, 0.3, 0))
        local s_region_lbl = make_stat_box(s_stats_grid, "Region", "Auto", UDim2.new(0.5, 2, 0.7, 0), UDim2.new(0.5, -2, 0.3, 0))

        -- Live FPS, Ping, Playtime
        task.spawn(function()
            local frame_count = 0
            local last_fps_tick = tick()
            local current_fps = 60
            RunService.RenderStepped:Connect(function()
                frame_count = frame_count + 1
                if tick() - last_fps_tick >= 1 then
                    current_fps = math.floor(frame_count / (tick() - last_fps_tick))
                    frame_count = 0
                    last_fps_tick = tick()
                end
            end)

            while task.wait(1) do
                if not server_card.Parent then break end
                local ping_str = "20ms"
                pcall(function()
                    local stats = game:GetService("Stats")
                    local ping = math.floor(stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                    ping_str = tostring(ping) .. "ms"
                end)
                s_latency_lbl.Text = string.format("%d FPS\n%s", current_fps, ping_str)

                local minutes = math.floor((tick() - start_tick) / 60)
                s_time_lbl.Text = tostring(minutes) .. "m"

                s_players_lbl.Text = tostring(#Players:GetPlayers()) .. " Players In\nThis Server"
            end
        end)

        -- ====================
        -- COL 2: CHANGELOG + EXECUTOR
        -- ====================
        -- Card: Changelog
        local cl_card, cl_body = create_card(col2, "Changelog", "rbxassetid://10709778785", 196, 1)
        local cl_scroll = library:create("ScrollingFrame", {
            Name = "ChangelogScroll",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = library.theme.accent,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Parent = cl_body
        })
        library:create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5), Parent = cl_scroll })

        local logs = dcfg.Changelogs or {
            "+ Dashboard Tab Enabled",
            "+ ThemeManager Integrated (18 Themes)",
            "+ SaveManager Config System",
            "+ Full Obsidian & Gamesense API",
            "+ Live Server & Friends Monitor",
            "+ Optimized UI & Memory"
        }
        for idx, log_item in ipairs(logs) do
            library:create("TextLabel", {
                Name = "Log_" .. tostring(idx),
                Size = UDim2.new(1, -6, 0, 16),
                BackgroundTransparency = 1,
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                Text = tostring(log_item),
                TextColor3 = Color3.fromRGB(160, 160, 165),
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = idx,
                Parent = cl_scroll
            })
        end

        -- Card: Executor
        local exec_name = "Potassium"
        pcall(function()
            if identifyexecutor then
                exec_name = tostring(identifyexecutor())
            end
        end)
        local exec_card, exec_body = create_card(col2, exec_name, "rbxassetid://10709769841", 84, 2)
        library:create("TextLabel", {
            Name = "ExecDesc",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            Text = dcfg.SupportedExecutors or "Your Executor Seems To Be\nSupported By This Script.",
            TextColor3 = Color3.fromRGB(155, 155, 160),
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Parent = exec_body
        })

        -- ====================
        -- COL 3: ACCOUNT + FRIENDS
        -- ====================
        -- Card: Account
        local acc_card, acc_body = create_card(col3, "Account", "rbxassetid://10709794353", 84, 1)
        library:create("TextLabel", {
            Name = "AccDesc",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            Text = dcfg.AccountTier or "Coming Soon.",
            TextColor3 = Color3.fromRGB(155, 155, 160),
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Parent = acc_body
        })

        -- Card: Friends
        local friends_card, friends_body = create_card(col3, "Friends", "rbxassetid://10709797378", 196, 2)

        local friends_inner = library:create("Frame", {
            Name = "FriendsInner",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = library.theme.main_bg,
            BorderSizePixel = 0,
            Parent = friends_body
        })
        make_corner(friends_inner, 5)
        make_stroke(friends_inner, library.theme.border_dark, 1)

        local f_in_server = make_stat_box(friends_inner, "In Server", "0 friends", UDim2.new(0, 8, 0, 12), UDim2.new(0.5, -12, 0.45, 0))
        local f_offline = make_stat_box(friends_inner, "Offline", "0 friends", UDim2.new(0.5, 4, 0, 12), UDim2.new(0.5, -12, 0.45, 0))
        local f_online = make_stat_box(friends_inner, "Online", "0 friends", UDim2.new(0, 8, 0.5, 4), UDim2.new(0.5, -12, 0.45, 0))
        local f_total = make_stat_box(friends_inner, "Total", "0 friends", UDim2.new(0.5, 4, 0.5, 4), UDim2.new(0.5, -12, 0.45, 0))

        task.spawn(function()
            local function update_friends()
                local in_server_count = 0
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer then
                        local is_friend = false
                        pcall(function()
                            is_friend = LocalPlayer:IsFriendsWith(p.UserId)
                        end)
                        if is_friend then in_server_count = in_server_count + 1 end
                    end
                end
                f_in_server.Text = tostring(in_server_count) .. " friends"

                local total_friends = 0
                local online_friends = 0
                pcall(function()
                    local pages = Players:GetFriendsAsync(LocalPlayer.UserId)
                    while true do
                        local items = pages:GetCurrentPage()
                        total_friends = total_friends + #items
                        for _, item in ipairs(items) do
                            if item.IsOnline then online_friends = online_friends + 1 end
                        end
                        if pages.IsFinished then break end
                        pages:AdvanceToNextPageAsync()
                    end
                end)

                f_total.Text = tostring(total_friends) .. " friends"
                f_online.Text = tostring(online_friends) .. " friends"
                f_offline.Text = tostring(math.max(0, total_friends - online_friends)) .. " friends"
            end

            update_friends()
            while task.wait(30) do
                if not friends_card.Parent then break end
                update_friends()
            end
        end)

        return dash_tab
    end
    window_obj.AddDashboard = window_obj._build_dashboard
    window_obj.Dashboard = window_obj._build_dashboard

    -- Menu toggle keybind connection
    library:connection(UserInputService.InputBegan, function(input, gpe)
        if not gpe and input.KeyCode == library.ToggleKeybind then
            library:Toggle()
        end
    end)


    -- Auto-create Dashboard Tab
    if cfg.AutoDashboard ~= false then
        window_obj:_build_dashboard(cfg.Dashboard)
    end

    -- Auto-create Settings Tab with ThemeManager & SaveManager
    if cfg.AutoSettings ~= false then
        local settings_tab = window_obj:tab({
            Title = "Settings",
            name = "Settings",
            icon = "settings"
        })
        window_obj.SettingsTab = settings_tab

        -- Menu hotkey groupbox (Left)
        local menu_box = settings_tab:AddLeftGroupbox("Menu")
        menu_box:AddLabel("Toggle Menu", "Hotkey"):AddKeyPicker("MenuKeybind", {
            Default = "RightControl",
            NoUI = true,
            Mode = "Toggle",
            Text = "Menu Keybind",
        })
        menu_box:AddToggle("ShowWatermark", {
            Text = "Show Watermark",
            Default = true,
            Tooltip = "Afficher / masquer le watermark en haut de l'écran",
            Callback = function(v)
                library:SetWatermarkVisibility(v)
            end
        })
        menu_box:AddToggle("ShowFeatures", {
            Text = "Show Features List",
            Default = true,
            Tooltip = "Afficher / masquer la boîte flottante des features",
            Callback = function(v)
                library:SetFeaturesVisibility(v)
            end
        })
        menu_box:AddButton("Unload Script", function()
            library:Unload()
        end)
        if Options.MenuKeybind then
            library.ToggleKeybind = Enum.KeyCode[Options.MenuKeybind.Value] or Enum.KeyCode.RightControl
            Options.MenuKeybind:OnChanged(function(v)
                if typeof(v) == "string" and Enum.KeyCode[v] then
                    library.ToggleKeybind = Enum.KeyCode[v]
                elseif typeof(v) == "EnumItem" then
                    library.ToggleKeybind = v
                end
            end)
        end

        -- Themes groupbox (Left)
        ThemeManager:ApplyToTab(settings_tab)

        -- Configs groupbox (Right)
        SaveManager:BuildConfigSection(settings_tab)

        -- Auto-load defaults asynchronously
        task.defer(function()
            pcall(function() ThemeManager:LoadDefault() end)
            pcall(function() SaveManager:LoadAutoloadConfig() end)
        end)
    end

    return window_obj
end

function library:Toggle(state)
    if state == nil then
        state = not (self.screen and self.screen.Enabled)
    end
    if self.screen then
        self.screen.Enabled = state
    end
    self.Toggled = state
end

function library:SetWatermarkVisibility(visible)
    if self.Watermark then
        self.Watermark:SetVisible(visible)
    end
    if self.Toggles and self.Toggles.ShowWatermark and self.Toggles.ShowWatermark.Value ~= visible then
        self.Toggles.ShowWatermark:SetValue(visible)
    end
end

function library:ToggleWatermark()
    if self.Watermark then
        return self.Watermark:Toggle()
    end
end

function library:SetWatermark(text)
    if self.Watermark then
        self.Watermark:SetText(text)
    end
end

function library:SetFeaturesVisibility(visible)
    if self.FloatingFeatures then
        self.FloatingFeatures:SetVisible(visible)
    end
    if self.Toggles and self.Toggles.ShowFeatures and self.Toggles.ShowFeatures.Value ~= visible then
        self.Toggles.ShowFeatures:SetValue(visible)
    end
end

function library:ToggleFeatures()
    if self.FloatingFeatures then
        return self.FloatingFeatures:Toggle()
    end
end

function library:Unload()
    self.Unloaded = true
    for _, conn in ipairs(self.connections) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    if self.screen then
        self.screen:Destroy()
    end
    table.clear(self.Options)
    table.clear(self.Toggles)
    table.clear(self.Registry)
    getgenv().Library = nil
end

return library
