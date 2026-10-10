-- ==============================================================================
-- GAMESENSE UI LIBRARY (skeet.cc style)
-- Reusable Luau Library for Roblox
-- ==============================================================================

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local GuiInset = GuiService:GetGuiInset().Y

local TargetGui = (pcall(function() return CoreGui end) and CoreGui) or LocalPlayer:WaitForChild("PlayerGui")

local library = {
    flags = {},
    config_flags = {},
    connections = {},
    active_popups = {},
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

-- Helpers
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
-- WINDOW
-- ==============================================================================
function library:window(cfg)
    cfg = cfg or {}
    local window_name = cfg.name or "gamesense"
    local window_size = cfg.size or UDim2.new(0, 500, 0, 360)

    local screen = Instance.new("ScreenGui")
    screen.Name = "GameSense_" .. math.random(1000, 9999)
    screen.ResetOnSpawn = false
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screen.Parent = TargetGui
    self.screen = screen

    -- Cadre extérieur
    local main = Instance.new("Frame")
    main.Name = "MainFrame"
    main.Size = window_size
    main.Position = UDim2.new(0.5, -window_size.X.Offset / 2, 0.5, -window_size.Y.Offset / 2)
    main.BackgroundColor3 = self.theme.main_bg
    main.BorderSizePixel = 0
    main.Parent = screen
    make_corner(main, 4)
    make_stroke(main, self.theme.border, 1)
    make_draggable(main)

    -- Barre dégradée GameSense
    local top_bar = Instance.new("Frame")
    top_bar.Name = "RainbowGradient"
    top_bar.Size = UDim2.new(1, 0, 0, 2)
    top_bar.BorderSizePixel = 0
    top_bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    top_bar.Parent = main

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 220, 255)),   -- Cyan
        ColorSequenceKeypoint.new(0.35, Color3.fromRGB(215, 60, 255)),  -- Violet/Magenta
        ColorSequenceKeypoint.new(0.70, Color3.fromRGB(255, 60, 90)),   -- Rouge/Rose
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 215, 60))   -- Jaune
    })
    gradient.Parent = top_bar

    -- Sidebar (Navigation verticale)
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 44, 1, -2)
    sidebar.Position = UDim2.new(0, 0, 0, 2)
    sidebar.BackgroundColor3 = self.theme.main_bg
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main

    local sidebar_layout = Instance.new("UIListLayout")
    sidebar_layout.Padding = UDim.new(0, 4)
    sidebar_layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sidebar_layout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebar_layout.Parent = sidebar

    local sidebar_pad = Instance.new("UIPadding")
    sidebar_pad.PaddingTop = UDim.new(0, 8)
    sidebar_pad.Parent = sidebar

    -- Zone de contenu
    local content_holder = Instance.new("Frame")
    content_holder.Name = "Content"
    content_holder.Size = UDim2.new(1, -48, 1, -8)
    content_holder.Position = UDim2.new(0, 46, 0, 5)
    content_holder.BackgroundTransparency = 1
    content_holder.Parent = main

    local window_obj = {
        main = main,
        screen = screen,
        sidebar = sidebar,
        content = content_holder,
        tabs = {},
        current_tab = nil
    }

    -- Watermark method
    function window_obj:watermark(wcfg)
        wcfg = wcfg or {}
        local text = wcfg.name or "gamesense | user | 60 fps"
        local wm = Instance.new("Frame")
        wm.Name = "Watermark"
        wm.AutomaticSize = Enum.AutomaticSize.X
        wm.Size = UDim2.new(0, 0, 0, 18)
        wm.Position = UDim2.new(0, 20, 0, 20)
        wm.BackgroundColor3 = library.theme.panel_bg
        wm.BorderSizePixel = 0
        wm.Parent = screen
        make_corner(wm, 3)
        make_stroke(wm, library.theme.border, 1)
        make_draggable(wm)

        local line = Instance.new("Frame")
        line.Size = UDim2.new(1, 0, 0, 1)
        line.BackgroundColor3 = library.theme.accent
        line.BorderSizePixel = 0
        line.Parent = wm

        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 8)
        pad.PaddingRight = UDim.new(0, 8)
        pad.Parent = wm

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.SourceSansBold
        lbl.Text = text
        lbl.TextColor3 = library.theme.text
        lbl.TextSize = 11
        lbl.Parent = wm

        return {
            set = function(new_text) lbl.Text = new_text end,
            frame = wm
        }
    end

    -- Floating window method (ex: AI Anti-Aim Statistics)
    function window_obj:floating(fcfg)
        fcfg = fcfg or {}
        local title = fcfg.title or "Statistics"
        local size = fcfg.size or UDim2.new(0, 160, 0, 175)
        local pos = fcfg.position or UDim2.new(0.5, -345, 0.5, -170)

        local fw = Instance.new("Frame")
        fw.Name = "FloatingWindow"
        fw.Size = size
        fw.Position = pos
        fw.BackgroundColor3 = library.theme.main_bg
        fw.BorderSizePixel = 0
        fw.Parent = screen
        make_corner(fw, 3)
        make_stroke(fw, library.theme.border, 1)
        make_draggable(fw)

        local header = Instance.new("Frame")
        header.Size = UDim2.new(1, 0, 0, 20)
        header.BackgroundColor3 = library.theme.panel_bg
        header.BorderSizePixel = 0
        header.Parent = fw
        make_corner(header, 3)

        local title_lbl = Instance.new("TextLabel")
        title_lbl.Size = UDim2.new(1, 0, 1, 0)
        title_lbl.BackgroundTransparency = 1
        title_lbl.Font = Enum.Font.SourceSansBold
        title_lbl.Text = title
        title_lbl.TextColor3 = library.theme.text
        title_lbl.TextSize = 11
        title_lbl.Parent = header

        local float_obj = { frame = fw, next_y = 26 }

        function float_obj:row(lbl_text, val_text, val_col)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -16, 0, 14)
            row.Position = UDim2.new(0, 8, 0, self.next_y)
            row.BackgroundTransparency = 1
            row.Parent = fw
            self.next_y = self.next_y + 16

            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(0.6, 0, 1, 0)
            l.BackgroundTransparency = 1
            l.Font = Enum.Font.SourceSansBold
            l.Text = lbl_text
            l.TextColor3 = library.theme.text
            l.TextSize = 11
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Parent = row

            local v = Instance.new("TextLabel")
            v.Size = UDim2.new(0.4, 0, 1, 0)
            v.Position = UDim2.new(0.6, 0, 0, 0)
            v.BackgroundTransparency = 1
            v.Font = Enum.Font.SourceSansBold
            v.Text = val_text
            v.TextColor3 = val_col or library.theme.text
            v.TextSize = 11
            v.TextXAlignment = Enum.TextXAlignment.Right
            v.Parent = row

            return {
                set = function(t, c)
                    v.Text = t
                    if c then v.TextColor3 = c end
                end
            }
        end

        function float_obj:progress(percent, col)
            local bg = Instance.new("Frame")
            bg.Size = UDim2.new(1, -16, 0, 6)
            bg.Position = UDim2.new(0, 8, 0, self.next_y + 4)
            bg.BackgroundColor3 = library.theme.element_bg
            bg.BorderSizePixel = 0
            bg.Parent = fw
            make_stroke(bg, library.theme.border_dark, 1)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(math.clamp((percent or 50) / 100, 0, 1), 0, 1, 0)
            fill.BackgroundColor3 = col or library.theme.accent
            fill.BorderSizePixel = 0
            fill.Parent = bg

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
    -- TAB
    -- ==============================================================================
    function window_obj:tab(tcfg)
        tcfg = tcfg or {}
        local tab_name = tcfg.name or "Tab"
        local tab_icon = tcfg.icon or tab_name:sub(1, 1)

        local tab_btn = Instance.new("TextButton")
        tab_btn.Name = "Tab_" .. tab_name
        tab_btn.Size = UDim2.new(0, 34, 0, 32)
        tab_btn.BackgroundColor3 = library.theme.main_bg
        tab_btn.BorderSizePixel = 0
        tab_btn.Text = ""
        tab_btn.AutoButtonColor = false
        tab_btn.Parent = self.sidebar
        make_corner(tab_btn, 4)

        local stroke = make_stroke(tab_btn, library.theme.border_dark, 1)
        stroke.Enabled = false

        local icon_label
        if tostring(tab_icon):find("rbxassetid") then
            icon_label = Instance.new("ImageLabel")
            icon_label.Size = UDim2.new(0, 18, 0, 18)
            icon_label.Position = UDim2.new(0.5, -9, 0.5, -9)
            icon_label.BackgroundTransparency = 1
            icon_label.Image = tab_icon
            icon_label.ImageColor3 = library.theme.text_dark
            icon_label.Parent = tab_btn
        else
            icon_label = Instance.new("TextLabel")
            icon_label.Size = UDim2.new(1, 0, 1, 0)
            icon_label.BackgroundTransparency = 1
            icon_label.Font = Enum.Font.SourceSansBold
            icon_label.Text = tab_icon
            icon_label.TextColor3 = library.theme.text_dark
            icon_label.TextSize = 16
            icon_label.Parent = tab_btn
        end

        -- Page Tab
        local tab_page = Instance.new("Frame")
        tab_page.Name = "Page_" .. tab_name
        tab_page.Size = UDim2.new(1, 0, 1, 0)
        tab_page.BackgroundTransparency = 1
        tab_page.Visible = false
        tab_page.Parent = self.content

        -- Barre des sous-onglets horizontaux en haut
        local subtab_bar = Instance.new("Frame")
        subtab_bar.Name = "SubTabsBar"
        subtab_bar.Size = UDim2.new(1, 0, 0, 20)
        subtab_bar.BackgroundTransparency = 1
        subtab_bar.Parent = tab_page

        local subtab_layout = Instance.new("UIListLayout")
        subtab_layout.FillDirection = Enum.FillDirection.Horizontal
        subtab_layout.SortOrder = Enum.SortOrder.LayoutOrder
        subtab_layout.Padding = UDim.new(0, 6)
        subtab_layout.Parent = subtab_bar

        local sub_content = Instance.new("Frame")
        sub_content.Name = "SubContent"
        sub_content.Size = UDim2.new(1, 0, 1, -24)
        sub_content.Position = UDim2.new(0, 0, 0, 24)
        sub_content.BackgroundTransparency = 1
        sub_content.Parent = tab_page

        local tab_obj = {
            name = tab_name,
            btn = tab_btn,
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
                stroke.Enabled = false
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
            local sub_name = scfg.name or "SubTab"
            local sub_label = scfg.label or sub_name

            local sub_btn = Instance.new("TextButton")
            sub_btn.Name = "SubBtn_" .. sub_name
            sub_btn.AutomaticSize = Enum.AutomaticSize.X
            sub_btn.Size = UDim2.new(0, 24, 0, 18)
            sub_btn.BackgroundColor3 = library.theme.panel_bg
            sub_btn.BorderSizePixel = 0
            sub_btn.Font = Enum.Font.SourceSansBold
            sub_btn.Text = "  " .. sub_label .. "  "
            sub_btn.TextColor3 = library.theme.text_dim
            sub_btn.TextSize = 11
            sub_btn.AutoButtonColor = false
            sub_btn.Parent = subtab_bar
            make_corner(sub_btn, 3)
            local sub_stroke = make_stroke(sub_btn, library.theme.border_dark, 1)

            -- Conteneur à deux colonnes A et B
            local sub_view = Instance.new("Frame")
            sub_view.Name = "View_" .. sub_name
            sub_view.Size = UDim2.new(1, 0, 1, 0)
            sub_view.BackgroundTransparency = 1
            sub_view.Visible = false
            sub_view.Parent = sub_content

            -- Colonne A (Gauche)
            local col_a = Instance.new("Frame")
            col_a.Name = "ColumnA"
            col_a.Size = UDim2.new(0.5, -4, 1, 0)
            col_a.Position = UDim2.new(0, 0, 0, 0)
            col_a.BackgroundColor3 = library.theme.panel_bg
            col_a.BorderSizePixel = 0
            col_a.Parent = sub_view
            make_corner(col_a, 3)
            make_stroke(col_a, library.theme.border_dark, 1)

            -- Colonne B (Droite)
            local col_b = Instance.new("Frame")
            col_b.Name = "ColumnB"
            col_b.Size = UDim2.new(0.5, -4, 1, 0)
            col_b.Position = UDim2.new(0.5, 4, 0, 0)
            col_b.BackgroundColor3 = library.theme.panel_bg
            col_b.BorderSizePixel = 0
            col_b.Parent = sub_view
            make_corner(col_b, 3)
            make_stroke(col_b, library.theme.border_dark, 1)

            local sub_obj = {
                name = sub_name,
                btn = sub_btn,
                view = sub_view,
                left = col_a,
                right = col_b
            }

            function sub_obj:select()
                if tab_obj.current_sub then
                    local prev = tab_obj.current_sub
                    prev.view.Visible = false
                    prev.btn.TextColor3 = library.theme.text_dim
                    prev.btn.BackgroundColor3 = library.theme.panel_bg
                end
                tab_obj.current_sub = sub_obj
                sub_view.Visible = true
                sub_btn.TextColor3 = library.theme.text
                sub_btn.BackgroundColor3 = library.theme.element_bg
            end

            sub_btn.MouseButton1Click:Connect(function() sub_obj:select() end)

            -- ==============================================================================
            -- SECTION (Groupbox A / B)
            -- ==============================================================================
            function sub_obj:section(sec_cfg)
                sec_cfg = sec_cfg or {}
                local side = sec_cfg.side or "left"
                local sec_name = sec_cfg.name or "Section"
                local sec_label = sec_cfg.label or (side == "left" and "A" or "B")
                local parent_col = (side == "left" and col_a or col_b)

                local header_frame = Instance.new("Frame")
                header_frame.Name = "Header"
                header_frame.Size = UDim2.new(1, -12, 0, 18)
                header_frame.Position = UDim2.new(0, 6, 0, 4)
                header_frame.BackgroundTransparency = 1
                header_frame.Parent = parent_col

                local badge = Instance.new("TextLabel")
                badge.Size = UDim2.new(0, 12, 0, 12)
                badge.Position = UDim2.new(0, 0, 0.5, -6)
                badge.BackgroundColor3 = library.theme.main_bg
                badge.BorderSizePixel = 0
                badge.Font = Enum.Font.SourceSansBold
                badge.Text = sec_label
                badge.TextColor3 = library.theme.text_dark
                badge.TextSize = 10
                badge.Parent = header_frame
                make_corner(badge, 2)
                make_stroke(badge, library.theme.border_dark, 1)

                local title = Instance.new("TextLabel")
                title.Size = UDim2.new(1, -18, 1, 0)
                title.Position = UDim2.new(0, 16, 0, 0)
                title.BackgroundTransparency = 1
                title.Font = Enum.Font.SourceSansBold
                title.Text = sec_name
                title.TextColor3 = library.theme.text
                title.TextSize = 11
                title.TextXAlignment = Enum.TextXAlignment.Left
                title.Parent = header_frame

                local scroll = Instance.new("ScrollingFrame")
                scroll.Name = "Container"
                scroll.Size = UDim2.new(1, -12, 1, -26)
                scroll.Position = UDim2.new(0, 6, 0, 24)
                scroll.BackgroundTransparency = 1
                scroll.BorderSizePixel = 0
                scroll.ScrollBarThickness = 2
                scroll.ScrollBarImageColor3 = library.theme.accent
                scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
                scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                scroll.Parent = parent_col

                local list = Instance.new("UIListLayout")
                list.SortOrder = Enum.SortOrder.LayoutOrder
                list.Padding = UDim.new(0, 6)
                list.Parent = scroll

                local section_obj = { container = scroll }

                -- TOGGLE / CHECKBOX
                function section_obj:toggle(opts)
                    opts = opts or {}
                    local text = opts.name or "Toggle"
                    local flag = opts.flag or text
                    local default = opts.default or false
                    local callback = opts.callback or function() end

                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, 0, 0, 14)
                    btn.BackgroundTransparency = 1
                    btn.Text = ""
                    btn.Parent = scroll

                    local box = Instance.new("Frame")
                    box.Size = UDim2.new(0, 9, 0, 9)
                    box.Position = UDim2.new(0, 0, 0.5, -4)
                    box.BackgroundColor3 = library.theme.main_bg
                    box.BorderSizePixel = 0
                    box.Parent = btn
                    make_corner(box, 2)
                    make_stroke(box, library.theme.border, 1)

                    local check = Instance.new("Frame")
                    check.Size = UDim2.new(0, 5, 0, 5)
                    check.Position = UDim2.new(0.5, -2, 0.5, -2)
                    check.BackgroundColor3 = library.theme.accent
                    check.BorderSizePixel = 0
                    check.Visible = default
                    check.Parent = box
                    make_corner(check, 1)

                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1, -16, 1, 0)
                    lbl.Position = UDim2.new(0, 14, 0, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Font = Enum.Font.SourceSans
                    lbl.Text = text
                    lbl.TextColor3 = library.theme.text
                    lbl.TextSize = 11
                    lbl.TextXAlignment = Enum.TextXAlignment.Left
                    lbl.Parent = btn

                    local state = default
                    local function set(v)
                        state = v
                        check.Visible = state
                        library.flags[flag] = state
                        callback(state)
                    end

                    btn.MouseButton1Click:Connect(function() set(not state) end)
                    set(default)
                    library.config_flags[flag] = set

                    return { set = set }
                end

                -- BUTTON
                function section_obj:button(opts)
                    opts = opts or {}
                    local text = opts.name or "Button"
                    local callback = opts.callback or function() end

                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, 0, 0, 18)
                    btn.BackgroundColor3 = library.theme.element_bg
                    btn.BorderSizePixel = 0
                    btn.Font = Enum.Font.SourceSans
                    btn.Text = text
                    btn.TextColor3 = library.theme.text
                    btn.TextSize = 11
                    btn.AutoButtonColor = false
                    btn.Parent = scroll
                    make_corner(btn, 2)
                    make_stroke(btn, library.theme.border_dark, 1)

                    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35) end)
                    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = library.theme.element_bg end)
                    btn.MouseButton1Click:Connect(callback)

                    return btn
                end

                -- SLIDER
                function section_obj:slider(opts)
                    opts = opts or {}
                    local text = opts.name or "Slider"
                    local flag = opts.flag or text
                    local min = opts.min or 0
                    local max = opts.max or 100
                    local default = opts.default or min
                    local suffix = opts.suffix or ""
                    local callback = opts.callback or function() end

                    local holder = Instance.new("Frame")
                    holder.Size = UDim2.new(1, 0, 0, 24)
                    holder.BackgroundTransparency = 1
                    holder.Parent = scroll

                    local name_lbl = Instance.new("TextLabel")
                    name_lbl.Size = UDim2.new(1, -40, 0, 11)
                    name_lbl.BackgroundTransparency = 1
                    name_lbl.Font = Enum.Font.SourceSans
                    name_lbl.Text = text
                    name_lbl.TextColor3 = library.theme.text
                    name_lbl.TextSize = 10
                    name_lbl.TextXAlignment = Enum.TextXAlignment.Left
                    name_lbl.Parent = holder

                    local val_lbl = Instance.new("TextLabel")
                    val_lbl.Size = UDim2.new(0, 40, 0, 11)
                    val_lbl.Position = UDim2.new(1, -40, 0, 0)
                    val_lbl.BackgroundTransparency = 1
                    val_lbl.Font = Enum.Font.SourceSansBold
                    val_lbl.Text = tostring(default) .. suffix
                    val_lbl.TextColor3 = library.theme.yellow
                    val_lbl.TextSize = 10
                    val_lbl.TextXAlignment = Enum.TextXAlignment.Right
                    val_lbl.Parent = holder

                    local track = Instance.new("TextButton")
                    track.Size = UDim2.new(1, 0, 0, 8)
                    track.Position = UDim2.new(0, 0, 0, 13)
                    track.BackgroundColor3 = library.theme.element_bg
                    track.BorderSizePixel = 0
                    track.Text = ""
                    track.AutoButtonColor = false
                    track.Parent = holder
                    make_corner(track, 2)
                    make_stroke(track, library.theme.border_dark, 1)

                    local fill = Instance.new("Frame")
                    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                    fill.BackgroundColor3 = library.theme.yellow
                    fill.BorderSizePixel = 0
                    fill.Parent = track
                    make_corner(fill, 2)

                    local function set(v)
                        local val = math.clamp(math.floor(v + 0.5), min, max)
                        fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
                        val_lbl.Text = tostring(val) .. suffix
                        library.flags[flag] = val
                        callback(val)
                    end

                    local dragging = false
                    track.InputBegan:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                            dragging = true
                            local percent = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                            set(min + ((max - min) * percent))
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                            dragging = false
                        end
                    end)
                    UserInputService.InputChanged:Connect(function(i)
                        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                            local percent = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                            set(min + ((max - min) * percent))
                        end
                    end)

                    set(default)
                    library.config_flags[flag] = set
                    return { set = set }
                end

                -- DROPDOWN
                function section_obj:dropdown(opts)
                    opts = opts or {}
                    local text = opts.name or "Dropdown"
                    local flag = opts.flag or text
                    local items = opts.items or {}
                    local default = opts.default or items[1] or ""
                    local callback = opts.callback or function() end

                    local holder = Instance.new("Frame")
                    holder.Size = UDim2.new(1, 0, 0, 30)
                    holder.BackgroundTransparency = 1
                    holder.Parent = scroll

                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1, 0, 0, 11)
                    lbl.BackgroundTransparency = 1
                    lbl.Font = Enum.Font.SourceSans
                    lbl.Text = text
                    lbl.TextColor3 = library.theme.text
                    lbl.TextSize = 10
                    lbl.TextXAlignment = Enum.TextXAlignment.Left
                    lbl.Parent = holder

                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, 0, 0, 16)
                    btn.Position = UDim2.new(0, 0, 0, 13)
                    btn.BackgroundColor3 = library.theme.element_bg
                    btn.BorderSizePixel = 0
                    btn.Font = Enum.Font.SourceSans
                    btn.Text = "  " .. tostring(default)
                    btn.TextColor3 = library.theme.text
                    btn.TextSize = 10
                    btn.TextXAlignment = Enum.TextXAlignment.Left
                    btn.AutoButtonColor = false
                    btn.Parent = holder
                    make_corner(btn, 2)
                    make_stroke(btn, library.theme.border_dark, 1)

                    local arrow = Instance.new("TextLabel")
                    arrow.Size = UDim2.new(0, 14, 1, 0)
                    arrow.Position = UDim2.new(1, -14, 0, 0)
                    arrow.BackgroundTransparency = 1
                    arrow.Font = Enum.Font.SourceSans
                    arrow.Text = "v"
                    arrow.TextColor3 = library.theme.text_dark
                    arrow.TextSize = 9
                    arrow.Parent = btn

                    local popup = Instance.new("Frame")
                    popup.Size = UDim2.new(1, 0, 0, #items * 16)
                    popup.Position = UDim2.new(0, 0, 1, 2)
                    popup.BackgroundColor3 = library.theme.main_bg
                    popup.BorderSizePixel = 0
                    popup.Visible = false
                    popup.ZIndex = 50
                    popup.Parent = btn
                    make_corner(popup, 2)
                    make_stroke(popup, library.theme.border, 1)

                    local playout = Instance.new("UIListLayout")
                    playout.SortOrder = Enum.SortOrder.LayoutOrder
                    playout.Parent = popup

                    local function set(val)
                        btn.Text = "  " .. tostring(val)
                        library.flags[flag] = val
                        callback(val)
                    end

                    for _, item in ipairs(items) do
                        local opt_btn = Instance.new("TextButton")
                        opt_btn.Size = UDim2.new(1, 0, 0, 16)
                        opt_btn.BackgroundTransparency = 1
                        opt_btn.Font = Enum.Font.SourceSans
                        opt_btn.Text = "  " .. tostring(item)
                        opt_btn.TextColor3 = library.theme.text
                        opt_btn.TextSize = 10
                        opt_btn.TextXAlignment = Enum.TextXAlignment.Left
                        opt_btn.ZIndex = 51
                        opt_btn.Parent = popup

                        opt_btn.MouseButton1Click:Connect(function()
                            set(item)
                            popup.Visible = false
                            arrow.Text = "v"
                        end)
                    end

                    btn.MouseButton1Click:Connect(function()
                        popup.Visible = not popup.Visible
                        arrow.Text = popup.Visible and "^" or "v"
                    end)

                    set(default)
                    library.config_flags[flag] = set
                    return { set = set }
                end

                -- KEYBIND
                function section_obj:keybind(opts)
                    opts = opts or {}
                    local text = opts.name or "Keybind"
                    local flag = opts.flag or text
                    local default_key = opts.key or Enum.KeyCode.E
                    local callback = opts.callback or function() end

                    local holder = Instance.new("Frame")
                    holder.Size = UDim2.new(1, 0, 0, 14)
                    holder.BackgroundTransparency = 1
                    holder.Parent = scroll

                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1, -40, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Font = Enum.Font.SourceSans
                    lbl.Text = text
                    lbl.TextColor3 = library.theme.text
                    lbl.TextSize = 11
                    lbl.TextXAlignment = Enum.TextXAlignment.Left
                    lbl.Parent = holder

                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(0, 36, 1, 0)
                    btn.Position = UDim2.new(1, -36, 0, 0)
                    btn.BackgroundColor3 = library.theme.element_bg
                    btn.BorderSizePixel = 0
                    btn.Font = Enum.Font.SourceSansBold
                    btn.Text = "[" .. default_key.Name .. "]"
                    btn.TextColor3 = library.theme.text_dark
                    btn.TextSize = 10
                    btn.AutoButtonColor = false
                    btn.Parent = holder
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

                -- COLORPICKER
                function section_obj:colorpicker(opts)
                    opts = opts or {}
                    local text = opts.name or "Color"
                    local flag = opts.flag or text
                    local default_col = opts.color or Color3.fromRGB(0, 215, 165)
                    local callback = opts.callback or function() end

                    local holder = Instance.new("Frame")
                    holder.Size = UDim2.new(1, 0, 0, 14)
                    holder.BackgroundTransparency = 1
                    holder.Parent = scroll

                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1, -24, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Font = Enum.Font.SourceSans
                    lbl.Text = text
                    lbl.TextColor3 = library.theme.text
                    lbl.TextSize = 11
                    lbl.TextXAlignment = Enum.TextXAlignment.Left
                    lbl.Parent = holder

                    local col_btn = Instance.new("TextButton")
                    col_btn.Size = UDim2.new(0, 18, 0, 10)
                    col_btn.Position = UDim2.new(1, -18, 0.5, -5)
                    col_btn.BackgroundColor3 = default_col
                    col_btn.BorderSizePixel = 0
                    col_btn.Text = ""
                    col_btn.AutoButtonColor = false
                    col_btn.Parent = holder
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
