-- ==============================================================================
-- GAMESENSE UI LIBRARY (skeet.cc style + Monolith custom elements)
-- Reusable Luau Library for Roblox
-- ==============================================================================

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local GuiInset = GuiService:GetGuiInset().Y

local TargetGui = (pcall(function() return CoreGui end) and CoreGui) or LocalPlayer:WaitForChild("PlayerGui")

local library = {
    flags = {},
    config_flags = {},
    connections = {},
    notifications = { notifs = {} },
    theme = {
        main_bg     = Color3.fromRGB(15, 15, 15),
        panel_bg    = Color3.fromRGB(19, 19, 19),
        section_bg  = Color3.fromRGB(22, 22, 22),
        element_bg  = Color3.fromRGB(26, 26, 26),
        border      = Color3.fromRGB(42, 42, 42),
        border_dark = Color3.fromRGB(30, 30, 30),
        accent      = Color3.fromRGB(0, 215, 165),      -- Vert d'accent / cyan
        yellow      = Color3.fromRGB(235, 215, 90),      -- Jaune pour sliders
        text        = Color3.fromRGB(225, 225, 225),
        text_dark   = Color3.fromRGB(140, 140, 140),
        text_dim    = Color3.fromRGB(90, 90, 90),
    }
}
library.__index = library

-- Helpers & Utility
function library:create(instance, options)
    local ins = Instance.new(instance)
    for prop, value in options do
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

local function make_draggable(frame)
    local dragging, dragStart, startPos = false, nil, nil
    frame.InputBegan:Connect(function(input)
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
end

-- ==============================================================================
-- LUCIDE ICON API (identique à Library 5 / Obsidian)
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

-- Récupération en ligne du module d'icônes Lucide
local icons_ok, icons_module = pcall(function()
    return (loadstring(game:HttpGet("https://raw.githubusercontent.com/notpoiu/lucide-roblox-direct/refs/heads/main/source.lua")))()
end)
if icons_ok and icons_module then
    FetchIcons = true
    Icons = icons_module
end

-- ==============================================================================
-- ESP PREVIEW BUILDER
-- Rend le VRAI personnage du joueur (de face) + box + skeleton + vie + nom.
-- Utilisé à la fois en mode "intégré au menu" et "fenêtre flottante".
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

-- Résout une source d'image :
--   "123456789"                    -> rbxassetid://123456789
--   "rbxassetid://..." / "rbxasset://..." -> tel quel
--   "https://.../image.png" (raw)  -> téléchargé puis converti en asset local
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

    local holder = library:create("Frame", {
        Parent = parent,
        Name = "ESPPreview",
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = Color3.fromRGB(11, 11, 11),
        BorderSizePixel = 0,
    })
    make_corner(holder, 3)
    make_stroke(holder, library.theme.border_dark, 1)

    -- Image custom (id Roblox ou URL raw), affichée derrière le personnage
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

    -- ViewportFrame : c'est ici qu'est rendu le personnage
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

    -- Boîte englobante 2D
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

    -- Barre de vie
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

    -- Nom
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
        for _, child in viewport:GetChildren() do
            if child:IsA("Model") or child:IsA("BasePart") then
                child:Destroy()
            end
        end
    end

    -- Dummy de secours si le joueur n'a pas de personnage (évite un aperçu vide/noir)
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
        local skin = Color3.fromRGB(224, 200, 138)
        local cloth = Color3.fromRGB(58, 110, 168)
        local pant = Color3.fromRGB(46, 46, 52)
        mk("Head", Vector3.new(0.85, 0.85, 0.85), Vector3.new(0, 3.1, 0), skin)
        mk("UpperTorso", Vector3.new(1.35, 1.0, 0.6), Vector3.new(0, 2.15, 0), cloth)
        mk("LowerTorso", Vector3.new(1.25, 0.7, 0.6), Vector3.new(0, 1.3, 0), cloth)
        mk("LeftUpperArm", Vector3.new(0.32, 0.85, 0.32), Vector3.new(-0.85, 2.15, 0), skin)
        mk("RightUpperArm", Vector3.new(0.32, 0.85, 0.32), Vector3.new(0.85, 2.15, 0), skin)
        mk("LeftLowerArm", Vector3.new(0.32, 0.8, 0.32), Vector3.new(-0.85, 1.32, 0), skin)
        mk("RightLowerArm", Vector3.new(0.32, 0.8, 0.32), Vector3.new(0.85, 1.32, 0), skin)
        mk("LeftHand", Vector3.new(0.34, 0.34, 0.34), Vector3.new(-0.85, 0.82, 0), skin)
        mk("RightHand", Vector3.new(0.34, 0.34, 0.34), Vector3.new(0.85, 0.82, 0), skin)
        mk("LeftUpperLeg", Vector3.new(0.4, 0.85, 0.4), Vector3.new(-0.33, 0.85, 0), pant)
        mk("RightUpperLeg", Vector3.new(0.4, 0.85, 0.4), Vector3.new(0.33, 0.85, 0), pant)
        mk("LeftLowerLeg", Vector3.new(0.4, 0.85, 0.4), Vector3.new(-0.33, 0.0, 0), pant)
        mk("RightLowerLeg", Vector3.new(0.4, 0.85, 0.4), Vector3.new(0.33, 0.0, 0), pant)
        mk("LeftFoot", Vector3.new(0.4, 0.28, 0.62), Vector3.new(-0.33, -0.55, 0.1), Color3.fromRGB(28, 28, 32))
        mk("RightFoot", Vector3.new(0.4, 0.28, 0.62), Vector3.new(0.33, -0.55, 0.1), Color3.fromRGB(28, 28, 32))
        return model
    end

    local function render()
        clear_view()
        if not show_char then return end

        local clone
        local char = LocalPlayer and LocalPlayer.Character
        if char then
            local ok, c = pcall(function() return char:Clone() end)
            if ok then clone = c end
        end
        if not clone then
            clone = build_dummy()
        end

        for _, d in clone:GetDescendants() do
            if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript") then
                d:Destroy()
            elseif d:IsA("BasePart") then
                d.CanCollide = false
                d.Anchored = true
                d.LocalTransparencyModifier = 0
                d.Transparency = math.max(d.Transparency, 0.38)
            end
        end

        clone.Parent = viewport

        -- On centre le personnage sur l'origine puis on place la caméra face à lui.
        local bsize = Vector3.new(2, 5, 1)
        pcall(function()
            clone:PivotTo(CFrame.new(0, 0, 0))
            local bcf, size = clone:GetBoundingBox()
            bsize = size
            clone:PivotTo(CFrame.new(-bcf.Position))
        end)

        local dist = math.max((bsize.Y * 0.5) / math.tan(math.rad(view_cam.FieldOfView * 0.5)) * 1.18, 3)
        view_cam.CFrame = CFrame.lookAt(Vector3.new(0, 0, -dist), Vector3.new(0, 0, 0))

        -- Boîte ajustée à la carrure réelle
        local box_w = math.clamp((bsize.X / math.max(bsize.Y, 0.1)) * 0.9, 0.32, 0.85)
        box.Size = UDim2.new(box_w, 0, 0.85, 0)
        health_bg.Position = UDim2.new(0.5 - box_w / 2, -3, 0.5, 2)

        -- Squelette dessiné en 3D (donc parfaitement aligné sur le perso)
        if show_skel then
            local links = clone:FindFirstChild("UpperTorso") and ESP_BONES_R15 or ESP_BONES_R6
            for _, pair in links do
                local a = clone:FindFirstChild(pair[1])
                local b = clone:FindFirstChild(pair[2])
                if a and b then
                    local aPos, bPos = a.Position, b.Position
                    local len = (aPos - bPos).Magnitude
                    if len > 0 then
                        local bone = Instance.new("Part")
                        bone.Name = "Bone"
                        bone.Anchored = true
                        bone.CanCollide = false
                        bone.CanQuery = false
                        bone.CanTouch = false
                        bone.CastShadow = false
                        bone.Material = Enum.Material.SmoothPlastic
                        bone.Color = esp_color
                        bone.Size = Vector3.new(0.07, 0.07, len)
                        bone.CFrame = CFrame.lookAt((aPos + bPos) * 0.5, bPos)
                        bone.Parent = viewport
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
        set_health = function(v) health_bg.Visible = v end,
        set_name = function(v) name_label.Visible = v end,
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
        end,
        refresh = render,
    }
end

-- ==============================================================================
-- WINDOW
-- ==============================================================================
function library:window(cfg)
    cfg = cfg or {}
    local window_name = cfg.name or "gamesense"
    local window_size = cfg.size or UDim2.new(0, 500, 0, 360)

    local screen = library:create("ScreenGui", {
        Name = "GameSense_" .. math.random(1000, 9999),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = TargetGui
    })
    self.screen = screen

    -- Cadre extérieur principal
    local main = library:create("Frame", {
        Name = "MainFrame",
        Size = window_size,
        Position = UDim2.new(0.5, -window_size.X.Offset / 2, 0.5, -window_size.Y.Offset / 2),
        BackgroundColor3 = self.theme.main_bg,
        BorderSizePixel = 0,
        Parent = screen
    })
    make_corner(main, 4)
    make_stroke(main, self.theme.border, 1)
    make_draggable(main)

    -- Sidebar (Navigation verticale)
    local sidebar = library:create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 44, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = self.theme.main_bg,
        BorderSizePixel = 0,
        Parent = main
    })

    local sidebar_layout = library:create("UIListLayout", {
        Padding = UDim.new(0, 4),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = sidebar
    })

    library:create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        Parent = sidebar
    })

    -- Zone de contenu
    local content_holder = library:create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -48, 1, -6),
        Position = UDim2.new(0, 46, 0, 3),
        BackgroundTransparency = 1,
        Parent = main
    })

    local window_obj = {
        main = main,
        screen = screen,
        sidebar = sidebar,
        content = content_holder,
        tabs = {},
        current_tab = nil
    }

    -- Watermark
    function window_obj:watermark(wcfg)
        wcfg = wcfg or {}
        local text = wcfg.name or "gamesense | user | 60 fps"
        local wm = library:create("Frame", {
            Name = "Watermark",
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.new(0, 0, 0, 18),
            Position = UDim2.new(0, 20, 0, 20),
            BackgroundColor3 = library.theme.panel_bg,
            BorderSizePixel = 0,
            Parent = screen
        })
        make_corner(wm, 3)
        make_stroke(wm, library.theme.border, 1)
        make_draggable(wm)

        library:create("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = library.theme.accent,
            BorderSizePixel = 0,
            Parent = wm
        })

        library:create("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            Parent = wm
        })

        local lbl = library:create("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.SourceSansBold,
            Text = text,
            TextColor3 = library.theme.text,
            TextSize = 11,
            Parent = wm
        })

        return {
            set = function(new_text) lbl.Text = new_text end,
            frame = wm
        }
    end

    -- Floating window (Statistics)
    function window_obj:floating(fcfg)
        fcfg = fcfg or {}
        local title = fcfg.title or "Statistics"
        local size = fcfg.size or UDim2.new(0, 160, 0, 175)
        local pos = fcfg.position or UDim2.new(0.5, -345, 0.5, -170)

        local fw = library:create("Frame", {
            Name = "FloatingWindow",
            Size = size,
            Position = pos,
            BackgroundColor3 = library.theme.main_bg,
            BorderSizePixel = 0,
            Parent = screen
        })
        make_corner(fw, 3)
        make_stroke(fw, library.theme.border, 1)
        make_draggable(fw)

        local header = library:create("Frame", {
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundColor3 = library.theme.panel_bg,
            BorderSizePixel = 0,
            Parent = fw
        })
        make_corner(header, 3)

        library:create("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.SourceSansBold,
            Text = title,
            TextColor3 = library.theme.text,
            TextSize = 11,
            Parent = header
        })

        local float_obj = { frame = fw, next_y = 26 }

        function float_obj:row(lbl_text, val_text, val_col)
            local row = library:create("Frame", {
                Size = UDim2.new(1, -16, 0, 14),
                Position = UDim2.new(0, 8, 0, self.next_y),
                BackgroundTransparency = 1,
                Parent = fw
            })
            self.next_y = self.next_y + 16

            library:create("TextLabel", {
                Size = UDim2.new(0.6, 0, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.SourceSansBold,
                Text = lbl_text,
                TextColor3 = library.theme.text,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row
            })

            local v = library:create("TextLabel", {
                Size = UDim2.new(0.4, 0, 1, 0),
                Position = UDim2.new(0.6, 0, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.SourceSansBold,
                Text = val_text,
                TextColor3 = val_col or library.theme.text,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = row
            })

            return {
                set = function(t, c)
                    v.Text = t
                    if c then v.TextColor3 = c end
                end
            }
        end

        function float_obj:progress(percent, col)
            local bg = library:create("Frame", {
                Size = UDim2.new(1, -16, 0, 6),
                Position = UDim2.new(0, 8, 0, self.next_y + 4),
                BackgroundColor3 = library.theme.element_bg,
                BorderSizePixel = 0,
                Parent = fw
            })
            make_stroke(bg, library.theme.border_dark, 1)

            local fill = library:create("Frame", {
                Size = UDim2.new(math.clamp((percent or 50) / 100, 0, 1), 0, 1, 0),
                BackgroundColor3 = col or library.theme.accent,
                BorderSizePixel = 0,
                Parent = bg
            })

            self.next_y = self.next_y + 16
            return {
                set = function(p)
                    fill.Size = UDim2.new(math.clamp(p / 100, 0, 1), 0, 1, 0)
                end
            }
        end

        return float_obj
    end

    -- ==============================================================================
    -- ESP PREVIEW FLOTTANT (hors du menu, déplaçable)
    -- ==============================================================================
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
        make_draggable(fw)

        local header = library:create("Frame", {
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundColor3 = library.theme.panel_bg,
            BorderSizePixel = 0,
            Parent = fw,
        })
        make_corner(header, 3)

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
    -- TAB
    -- ==============================================================================
    function window_obj:tab(tcfg)
        tcfg = tcfg or {}
        local tab_name = tcfg.name or tcfg.Name or "Tab"
        local tab_icon = tcfg.icon or tcfg.Icon or tab_name:sub(1, 1)

        local tab_btn = library:create("TextButton", {
            Name = "Tab_" .. tab_name,
            Size = UDim2.new(0, 34, 0, 32),
            BackgroundColor3 = library.theme.main_bg,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            Parent = self.sidebar
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

        -- Page Tab
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
            Size = UDim2.new(1, 0, 1, -24),
            Position = UDim2.new(0, 0, 0, 24),
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
            if window_obj.current_tab then
                local prev = window_obj.current_tab
                prev.page.Visible = false
                prev.btn.BackgroundColor3 = library.theme.main_bg
                if prev.stroke then prev.stroke.Enabled = false end
                if prev.icon.ClassName == "ImageLabel" then
                    prev.icon.ImageColor3 = library.theme.text_dark
                else
                    prev.icon.TextColor3 = library.theme.text_dark
                end
            end

            window_obj.current_tab = tab_obj
            tab_page.Visible = true
            tab_btn.BackgroundColor3 = library.theme.section_bg
            stroke.Enabled = true
            if icon_label.ClassName == "ImageLabel" then
                icon_label.ImageColor3 = Color3.fromRGB(255, 255, 255)
            else
                icon_label.TextColor3 = Color3.fromRGB(255, 255, 255)
            end

            if not tab_obj.current_sub and #tab_obj.subtabs > 0 then
                tab_obj.subtabs[1]:select()
            end
        end

        tab_obj.icon = icon_label
        tab_btn.MouseButton1Click:Connect(function() tab_obj:select() end)

        -- ==============================================================================
        -- SUBTAB
        -- ==============================================================================
        function tab_obj:subtab(scfg)
            scfg = scfg or {}
            local sub_name = scfg.name or scfg.Name or "SubTab"
            local sub_label = scfg.label or scfg.Label or sub_name

            local sub_btn = library:create("TextButton", {
                Name = "SubBtn_" .. sub_name,
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.new(0, 24, 0, 20),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Font = Enum.Font.SourceSansBold,
                Text = sub_label,
                TextColor3 = library.theme.text_dim,
                TextSize = 11,
                AutoButtonColor = false,
                Parent = subtab_bar
            })
            make_corner(sub_btn, 3)

            library:create("UIGradient", {
                Rotation = 90,
                Parent = sub_btn,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(33, 33, 33)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 8))
                })
            })

            local sub_stroke = make_stroke(sub_btn, library.theme.border, 1)
            sub_stroke.Enabled = false

            library:create("UIPadding", {
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                Parent = sub_btn
            })

            -- Conteneur colonnes A et B
            local sub_view = library:create("Frame", {
                Name = "View_" .. sub_name,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Visible = false,
                Parent = sub_content
            })

            local col_a = library:create("Frame", {
                Name = "ColumnA",
                Size = UDim2.new(0.5, -4, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundColor3 = library.theme.panel_bg,
                BorderSizePixel = 0,
                Parent = sub_view
            })
            make_corner(col_a, 3)
            make_stroke(col_a, library.theme.border_dark, 1)

            local col_b = library:create("Frame", {
                Name = "ColumnB",
                Size = UDim2.new(0.5, -4, 1, 0),
                Position = UDim2.new(0.5, 4, 0, 0),
                BackgroundColor3 = library.theme.panel_bg,
                BorderSizePixel = 0,
                Parent = sub_view
            })
            make_corner(col_b, 3)
            make_stroke(col_b, library.theme.border_dark, 1)

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
                if tab_obj.current_sub then
                    local prev = tab_obj.current_sub
                    prev.view.Visible = false
                    prev.active = false
                    if prev.stroke then prev.stroke.Enabled = false end
                    library:tween(prev.btn, {
                        TextColor3 = library.theme.text_dim,
                        BackgroundTransparency = 1
                    }, nil, 0.15)
                end
                tab_obj.current_sub = sub_obj
                sub_obj.active = true
                sub_view.Visible = true
                sub_stroke.Enabled = true
                library:tween(sub_btn, {
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0
                }, nil, 0.15)
            end

            sub_btn.MouseEnter:Connect(function()
                if not sub_obj.active then
                    library:tween(sub_btn, {TextColor3 = library.theme.text_dark}, nil, 0.12)
                end
            end)

            sub_btn.MouseLeave:Connect(function()
                if not sub_obj.active then
                    library:tween(sub_btn, {TextColor3 = library.theme.text_dim}, nil, 0.12)
                end
            end)

            sub_btn.MouseButton1Click:Connect(function() sub_obj:select() end)

            -- ==============================================================================
            -- SECTION (Groupbox A / B)
            -- ==============================================================================
            function sub_obj:section(sec_cfg)
                sec_cfg = sec_cfg or {}
                local side = sec_cfg.side or sec_cfg.Side or "left"
                local sec_name = sec_cfg.name or sec_cfg.Name or "Section"
                local sec_label = sec_cfg.label or sec_cfg.Label or (side == "left" and "A" or "B")
                local parent_col = (side == "left" and col_a or col_b)

                local header_frame = library:create("Frame", {
                    Name = "Header",
                    Size = UDim2.new(1, -12, 0, 18),
                    Position = UDim2.new(0, 6, 0, 4),
                    BackgroundTransparency = 1,
                    Parent = parent_col
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

                local scroll = library:create("ScrollingFrame", {
                    Name = "Container",
                    Size = UDim2.new(1, -12, 1, -26),
                    Position = UDim2.new(0, 6, 0, 24),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = library.theme.accent,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    Parent = parent_col
                })

                library:create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 6),
                    Parent = scroll
                })

                local section_obj = { container = scroll, elements = scroll, items = { elements = scroll } }

                -- =====================================================================
                -- MONOLITH / SKEET TOGGLE
                -- =====================================================================
                function section_obj:Toggle(options)
                    options = options or {}
                    local text = options.name or options.Name or "Toggle"
                    local flag = options.flag or options.Flag or text
                    local default = options.default or options.Default or false
                    local callback = options.callback or options.Callback or function() end

                    local obj = library:create("TextButton", {
                        Parent = scroll,
                        Text = "",
                        Name = text,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 14),
                        BorderSizePixel = 0,
                        AutoButtonColor = false
                    })

                    local toggle_outline = library:create("Frame", {
                        Parent = obj,
                        BackgroundTransparency = 1,
                        Name = "Outline",
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        Size = UDim2.new(0, 12, 0, 12),
                        Position = UDim2.new(0, 0, 0.5, -6),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    })

                    local toggle_shading = library:create("Frame", {
                        Parent = toggle_outline,
                        Name = "Shading",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 1, 0, 1),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        Size = UDim2.new(1, -2, 1, -2),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(92, 92, 92)
                    })

                    local toggle_inline = library:create("Frame", {
                        Parent = toggle_shading,
                        Name = "Inline",
                        Position = UDim2.new(0, 1, 0, 1),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        Size = UDim2.new(1, -2, 1, -2),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(54, 54, 54)
                    })

                    local lbl = library:create("TextLabel", {
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        TextColor3 = Color3.fromRGB(178, 178, 178),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        Text = text,
                        Parent = obj,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 18, 0, 0),
                        Size = UDim2.new(1, -20, 1, 0),
                        BorderSizePixel = 0,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextSize = 11,
                    })

                    local state = false
                    local function set(bool)
                        state = bool
                        library:tween(lbl, {TextColor3 = bool and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(178, 178, 178)})
                        library:tween(toggle_outline, {BackgroundTransparency = bool and 0 or 1})
                        library:tween(toggle_shading, {BackgroundTransparency = bool and 0 or 1})
                        library:tween(toggle_inline, {BackgroundColor3 = bool and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(74, 74, 74)})

                        library.flags[flag] = bool
                        callback(bool)
                    end

                    obj.MouseButton1Click:Connect(function()
                        set(not state)
                    end)

                    set(default)
                    library.config_flags[flag] = set
                    return { set = set }
                end
                section_obj.toggle = section_obj.Toggle

                -- =====================================================================
                -- MONOLITH / SKEET SLIDER
                -- =====================================================================
                function section_obj:Slider(options)
                    options = options or {}
                    local text = options.name or options.Name or "Slider"
                    local suffix = options.suffix or options.Suffix or ""
                    local flag = options.flag or options.Flag or text
                    local callback = options.callback or options.Callback or function() end
                    local min = options.min or options.minimum or options.Min or options.Minimum or 0
                    local max = options.max or options.maximum or options.Max or options.Maximum or 100
                    local intervals = options.interval or options.decimal or options.Interval or options.Decimal or 1
                    local default = options.default or options.Default or min
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

                    local function set(v)
                        value = math.clamp(library:round(v, intervals), min, max)
                        local pct = (value - min) / (max - min)
                        slider_thumb.Position = UDim2.new(pct, 0, 0.5, 0)
                        val_lbl.Text = tostring(value) .. suffix
                        library.flags[flag] = value
                        callback(value)
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

                    set(default)
                    library.config_flags[flag] = set
                    return { set = set }
                end
                section_obj.slider = section_obj.Slider

                -- =====================================================================
                -- MONOLITH / SKEET DROPDOWN
                -- =====================================================================
                function section_obj:Dropdown(options)
                    options = options or {}
                    local text = options.name or options.Name or "Dropdown"
                    local flag = options.flag or options.Flag or text
                    local items_list = options.items or options.Items or {"1", "2", "3"}
                    local callback = options.callback or options.Callback or function() end
                    local multi = options.multi or options.Multi or false

                    local default = options.default or options.Default or (multi and {items_list[1]}) or items_list[1] or "None"
                    local open = false
                    local option_instances = {}
                    local multi_items = {}

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

                    local dropdown_outline = library:create("TextButton", {
                        Parent = holder,
                        Text = "",
                        AutoButtonColor = false,
                        Position = UDim2.new(0, 0, 0, 13),
                        Size = UDim2.new(1, 0, 0, 17),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    })

                    local dropdown_shading = library:create("Frame", {
                        Parent = dropdown_outline,
                        Size = UDim2.new(1, -2, 1, -2),
                        Position = UDim2.new(0, 1, 0, 1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    })

                    library:create("UIGradient", {
                        Rotation = 90,
                        Parent = dropdown_shading,
                        Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(33, 33, 33)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 8))
                        })
                    })

                    local inner_text = library:create("TextLabel", {
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        TextColor3 = Color3.fromRGB(178, 178, 178),
                        Text = "None",
                        Parent = dropdown_shading,
                        Size = UDim2.new(1, -18, 1, 0),
                        Position = UDim2.new(0, 6, 0, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })

                    local arrow = library:create("ImageLabel", {
                        ImageColor3 = Color3.fromRGB(178, 178, 178),
                        Parent = dropdown_outline,
                        AnchorPoint = Vector2.new(1, 0.5),
                        Image = "rbxassetid://76667213487638",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -5, 0.5, 0),
                        Size = UDim2.new(0, 7, 0, 4),
                        BorderSizePixel = 0,
                    })

                    local dropdown_holder = library:create("Frame", {
                        Parent = window_obj.screen,
                        Size = UDim2.new(0, 120, 0, 0),
                        Visible = false,
                        ZIndex = 150,
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    })

                    local pop_shading = library:create("Frame", {
                        Parent = dropdown_holder,
                        Size = UDim2.new(1, -2, 0, -2),
                        Position = UDim2.new(0, 1, 0, 1),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        ZIndex = 151,
                    })

                    library:create("UIGradient", {
                        Rotation = 90,
                        Parent = pop_shading,
                        Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(33, 33, 33)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 8))
                        })
                    })

                    library:create("UIListLayout", {
                        Parent = pop_shading,
                        Padding = UDim.new(0, 2),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    })
                    library:create("UIPadding", {
                        PaddingBottom = UDim.new(0, 4),
                        PaddingTop = UDim.new(0, 4),
                        Parent = pop_shading
                    })

                    local function set_visible(bool)
                        open = bool
                        dropdown_holder.Visible = bool
                        arrow.Rotation = bool and 180 or 0
                        if bool then
                            dropdown_holder.Size = UDim2.new(0, dropdown_outline.AbsoluteSize.X, 0, 0)
                            dropdown_holder.Position = UDim2.new(0, dropdown_outline.AbsolutePosition.X, 0, dropdown_outline.AbsolutePosition.Y + dropdown_outline.AbsoluteSize.Y + 2)
                        end
                    end

                    local function set(value)
                        local selected = {}
                        local isTable = type(value) == "table"

                        for _, option_btn in ipairs(option_instances) do
                            if option_btn.Text == value or (isTable and table.find(value, option_btn.Text)) then
                                table.insert(selected, option_btn.Text)
                                multi_items = selected
                                option_btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                            else
                                option_btn.TextColor3 = Color3.fromRGB(150, 150, 150)
                            end
                        end

                        inner_text.Text = if isTable then table.concat(selected, ", ") else (selected[1] or tostring(value))
                        library.flags[flag] = if isTable then selected else selected[1]
                        callback(library.flags[flag])
                    end

                    local function refresh_options(list)
                        for _, opt in ipairs(option_instances) do opt:Destroy() end
                        option_instances = {}

                        for _, item_name in ipairs(list) do
                            local opt_btn = library:create("TextButton", {
                                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                                TextColor3 = Color3.fromRGB(178, 178, 178),
                                Text = tostring(item_name),
                                Parent = pop_shading,
                                Size = UDim2.new(1, 0, 0, 15),
                                BackgroundTransparency = 1,
                                TextXAlignment = Enum.TextXAlignment.Center,
                                BorderSizePixel = 0,
                                TextSize = 10,
                                ZIndex = 152,
                            })
                            table.insert(option_instances, opt_btn)

                            opt_btn.MouseButton1Click:Connect(function()
                                if multi then
                                    local idx = table.find(multi_items, opt_btn.Text)
                                    if idx then
                                        table.remove(multi_items, idx)
                                    else
                                        table.insert(multi_items, opt_btn.Text)
                                    end
                                    set(multi_items)
                                else
                                    set_visible(false)
                                    set(opt_btn.Text)
                                end
                            end)
                        end
                    end

                    dropdown_outline.MouseButton1Click:Connect(function()
                        set_visible(not open)
                    end)

                    library:connection(UserInputService.InputEnded, function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            if open and not (library:mouse_in_frame(dropdown_holder) or library:mouse_in_frame(dropdown_outline)) then
                                set_visible(false)
                            end
                        end
                    end)

                    refresh_options(items_list)
                    set(default)
                    library.config_flags[flag] = set

                    return { set = set, refresh = refresh_options }
                end
                section_obj.dropdown = section_obj.Dropdown

                -- =====================================================================
                -- BUTTON
                -- =====================================================================
                function section_obj:Button(options)
                    options = options or {}
                    local text = options.name or options.Name or "Button"
                    local callback = options.callback or options.Callback or function() end

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
                        callback()
                        button_text.TextColor3 = Color3.fromRGB(255, 255, 255)
                        library:tween(button_text, {TextColor3 = Color3.fromRGB(178, 178, 178)})
                    end)

                    return btn
                end
                section_obj.button = section_obj.Button

                -- =====================================================================
                -- KEYBIND
                -- =====================================================================
                function section_obj:Keybind(options)
                    options = options or {}
                    local text = options.name or options.Name or "Keybind"
                    local flag = options.flag or options.Flag or text
                    local default_key = options.key or options.Key or Enum.KeyCode.E
                    local callback = options.callback or options.Callback or function() end

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

                    local btn = library:create("TextButton", {
                        Parent = holder,
                        Size = UDim2.new(0, 36, 1, 0),
                        Position = UDim2.new(1, -36, 0, 0),
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

                    btn.MouseButton1Click:Connect(function()
                        listening = true
                        btn.Text = "[...]"
                    end)

                    UserInputService.InputBegan:Connect(function(input, gpe)
                        if listening and not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
                            listening = false
                            current_key = input.KeyCode
                            btn.Text = "[" .. current_key.Name .. "]"
                            library.flags[flag] = current_key
                            callback(current_key)
                        elseif not gpe and input.KeyCode == current_key then
                            callback(true)
                        end
                    end)

                    library.flags[flag] = default_key
                    return {
                        set = function(k)
                            current_key = k
                            btn.Text = "[" .. k.Name .. "]"
                        end
                    }
                end
                section_obj.keybind = section_obj.Keybind

                -- =====================================================================
                -- COLORPICKER
                -- =====================================================================
                function section_obj:Colorpicker(options)
                    options = options or {}
                    local text = options.name or options.Name or "Color"
                    local flag = options.flag or options.Flag or text
                    local default_col = options.color or options.Color or Color3.fromRGB(0, 215, 165)
                    local callback = options.callback or options.Callback or function() end

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

                    local col_btn = library:create("TextButton", {
                        Parent = holder,
                        Size = UDim2.new(0, 18, 0, 10),
                        Position = UDim2.new(1, -18, 0.5, -5),
                        BackgroundColor3 = default_col,
                        BorderSizePixel = 0,
                        Text = "",
                        AutoButtonColor = false,
                    })
                    make_corner(col_btn, 2)
                    make_stroke(col_btn, library.theme.border, 1)

                    local current = default_col
                    library.flags[flag] = default_col

                    return {
                        set = function(c)
                            current = c
                            col_btn.BackgroundColor3 = c
                            library.flags[flag] = c
                            callback(c)
                        end
                    }
                end
                section_obj.colorpicker = section_obj.Colorpicker

                -- =====================================================================
                -- ESP PREVIEW (vrai personnage de face : box + skeleton + vie + nom)
                -- Intégré au menu, ou détaché en fenêtre flottante (options.floating)
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
        if #window_obj.tabs == 1 then
            tab_obj:select()
        end

        return tab_obj
    end

    return window_obj
end

return library
