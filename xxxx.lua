-- Variables 
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
    local teleport_service = game:GetService("TeleportService")

    local vec2 = Vector2.new
    local vec3 = Vector3.new
    local dim2 = UDim2.new
    local dim = UDim.new 
    local rect = Rect.new
    local cfr = CFrame.new
    local empty_cfr = cfr()
    local point_object_space = empty_cfr.PointToObjectSpace
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
-- 

-- Library init
    getgenv().library = {
        directory = "monolithhh",
        folders = {
            "/fonts",
            "/configs",
        },
        flags = {},
        config_flags = {},
        connections = {},   
        notifications = {notifs = {}},
        current_open; 
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
        [Enum.KeyCode.KeypadOne] = "Num1",
        [Enum.KeyCode.KeypadTwo] = "Num2",
        [Enum.KeyCode.KeypadThree] = "Num3",
        [Enum.KeyCode.KeypadFour] = "Num4",
        [Enum.KeyCode.KeypadFive] = "Num5",
        [Enum.KeyCode.KeypadSix] = "Num6",
        [Enum.KeyCode.KeypadSeven] = "Num7",
        [Enum.KeyCode.KeypadEight] = "Num8",
        [Enum.KeyCode.KeypadNine] = "Num9",
        [Enum.KeyCode.KeypadZero] = "Num0",
        [Enum.KeyCode.Minus] = "-",
        [Enum.KeyCode.Equals] = "=",
        [Enum.KeyCode.Tilde] = "~",
        [Enum.KeyCode.LeftBracket] = "[",
        [Enum.KeyCode.RightBracket] = "]",
        [Enum.KeyCode.RightParenthesis] = ")",
        [Enum.KeyCode.LeftParenthesis] = "(",
        [Enum.KeyCode.Semicolon] = ",",
        [Enum.KeyCode.Quote] = "'",
        [Enum.KeyCode.BackSlash] = "\\",
        [Enum.KeyCode.Comma] = ",",
        [Enum.KeyCode.Period] = ".",
        [Enum.KeyCode.Slash] = "/",
        [Enum.KeyCode.Asterisk] = "*",
        [Enum.KeyCode.Plus] = "+",
        [Enum.KeyCode.Period] = ".",
        [Enum.KeyCode.Backquote] = "`",
        [Enum.UserInputType.MouseButton1] = "MB1",
        [Enum.UserInputType.MouseButton2] = "MB2",
        [Enum.UserInputType.MouseButton3] = "MB3",
        [Enum.KeyCode.Escape] = "ESC",
        [Enum.KeyCode.Space] = "SPC",
    }
        
    library.__index = library

    for _, path in next, library.folders do 
        makefolder(library.directory .. path)
    end

    local flags = library.flags 
    local config_flags = library.config_flags
    local notifications = library.notifications 

    -- Font importing system
        library.font = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular)

        local font_path = library.directory .. "/fonts/main.ttf"
        local encoded_font_path = library.directory .. "/fonts/main_encoded.ttf"
        local font_loaded, font_error = pcall(function()
            if not isfile(font_path) then
                local font_data = game:HttpGet("https://github.com/f1nobe7650/Nebula/raw/refs/heads/main/Minecraftia-Regular.ttf")
                writefile(font_path, font_data)
            end

            local minecraftia = {
                name = "Minecraftia",
                faces = {
                    {
                        name = "Regular",
                        weight = 400,
                        style = "normal",
                        assetId = getcustomasset(font_path)
                    }
                }
            }

            writefile(encoded_font_path, http_service:JSONEncode(minecraftia))
            library.font = Font.new(getcustomasset(encoded_font_path), Enum.FontWeight.Regular)
        end)

        if not font_loaded then
            warn("[library] Custom font unavailable; using Source Sans Pro:", font_error)
        end
    --
--

-- Library functions 
    -- Misc functions
        function library:tween(obj, properties, easing_style, time) 
            local tween = tween_service:Create(obj, TweenInfo.new(time or 0.25, easing_style or Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, 0, false, 0), properties)
            tween:Play()
                
            return tween
        end

        function library:get_transparency(obj)
            if obj:IsA("Frame") then
                return {"BackgroundTransparency"}
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

        function library:fade(obj, prop, vis, speed)
            if not (obj and prop) then
                return
            end

            local OldTransparency = obj[prop]
            obj[prop] = vis and 1 or OldTransparency

            local Tween = library:tween(obj, { [prop] = vis and OldTransparency or 1 })

            library:connection(Tween.Completed, function()
                if not vis then
                    task.wait()
                    obj[prop] = OldTransparency
                end
            end)

            return Tween
        end

        function library:resizify(frame) 
            local Frame = Instance.new("TextButton")
            Frame.Position = dim2(1, -10, 1, -10)
            Frame.BorderColor3 = rgb(0, 0, 0)
            Frame.Size = dim2(0, 10, 0, 10)
            Frame.BorderSizePixel = 0
            Frame.BackgroundColor3 = rgb(255, 255, 255)
            Frame.Parent = frame
            Frame.BackgroundTransparency = 1 
            Frame.Text = ""

            local resizing = false 
            local start_size 
            local start 
            local min_width = 200
            local min_height = 200

            Frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    resizing = true
                    start = input.Position
                    start_size = frame.Size
                end
            end)

            Frame.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    resizing = false
                end
            end)

            library:connection(uis.InputChanged, function(input, game_event) 
                if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local viewport_x = camera.ViewportSize.X
                    local viewport_y = camera.ViewportSize.Y

                    local current_size = dim2(
                        start_size.X.Scale,
                        math.clamp(
                            start_size.X.Offset + (input.Position.X - start.X),
                            min_width,
                            math.max(min_width, viewport_x - 8)
                        ),
                        start_size.Y.Scale,
                        math.clamp(
                            start_size.Y.Offset + (input.Position.Y - start.Y),
                            min_height,
                            math.max(min_height, viewport_y - 8)
                        )
                    )

                    -- library:tween(frame, {Size = current_size}, Enum.EasingStyle.Linear, 0.05) -- nobody will ntoice this aswell 👿
                    frame.Size = current_size
                end
            end)
        end 

        function library:mouse_in_frame(uiobject)
            local y_cond = uiobject.AbsolutePosition.Y <= mouse.Y and mouse.Y <= uiobject.AbsolutePosition.Y + uiobject.AbsoluteSize.Y
            local x_cond = uiobject.AbsolutePosition.X <= mouse.X and mouse.X <= uiobject.AbsolutePosition.X + uiobject.AbsoluteSize.X

            return (y_cond and x_cond)
        end

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

            library:connection(uis.InputChanged, function(input, game_event) 
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local viewport_x = camera.ViewportSize.X
                    local viewport_y = camera.ViewportSize.Y

                    local current_position = dim2(
                        0,
                        clamp(
                            start_size.X.Offset + (input.Position.X - start.X),
                            0,
                            viewport_x - frame.Size.X.Offset
                        ),
                        0,
                        math.clamp(
                            start_size.Y.Offset + (input.Position.Y - start.Y),
                            0,
                            viewport_y - frame.Size.Y.Offset
                        )
                    )

                    -- library:tween(frame, {Position = current_position}, Enum.EasingStyle.Linear, 0) -- heh, nobody will notice 
                    frame.Position = current_position
                    library:close_current_element(nil) 
                end
            end)
        end 

        function library:convert(str)
            local values = {}

            for value in string.gmatch(str, "[^,]+") do
                insert(values, tonumber(value))
            end
            
            if #values == 4 then              
                return unpack(values)
            else 
                return
            end
        end
        
        function library:convert_enum(enum)
            local enum_parts = {}
        
            for part in string.gmatch(enum, "[%w_]+") do
                insert(enum_parts, part)
            end
        
            local enum_table = Enum
            for i = 2, #enum_parts do
                local enum_item = enum_table[enum_parts[i]]
        
                enum_table = enum_item
            end
        
            return enum_table
        end

        local config_holder;
        function library:update_config_list() 
            if not config_holder then 
                return 
            end
            
            local list = {}
            
            for idx, file in listfiles(library.directory .. "/configs") do
                local name = file:gsub(library.directory .. "/configs\\", ""):gsub(".cfg", ""):gsub(library.directory .. "\\configs\\", "")
                list[#list + 1] = name
            end

            config_holder.refresh_options(list)
        end 

        function library:get_config()
            local Config = {}
            
            for _, v in next, flags do
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
            
            for _, v in config do 
                local function_set = library.config_flags[_]
                
                if _ == "config_name_list" then 
                    continue 
                end

                if function_set then 
                    if type(v) == "table" and v["Transparency"] and v["Color"] then
                        function_set(hex(v["Color"]), v["Transparency"])
                    elseif type(v) == "table" and v["active"] then 
                        function_set(v)
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

        library.themes = {
            dark = {
                background = rgb(12, 12, 12),
                panel = rgb(14, 14, 14),
                panel_alt = rgb(8, 8, 8),
                border = rgb(0, 0, 0),
                text = rgb(255, 255, 255),
                muted = rgb(178, 178, 178),
                accent = rgb(255, 255, 255),
                accent_soft = rgb(93, 93, 93),
                accent_dark = rgb(33, 33, 33),
                muted_dark = rgb(74, 74, 74),
                shadow = rgb(0, 0, 0)
            },
            light = {
                background = rgb(235, 235, 235),
                panel = rgb(248, 248, 248),
                panel_alt = rgb(222, 222, 222),
                border = rgb(204, 204, 204),
                text = rgb(25, 25, 25),
                muted = rgb(96, 96, 96),
                accent = rgb(52, 110, 255),
                accent_soft = rgb(170, 190, 255),
                accent_dark = rgb(80, 128, 255),
                muted_dark = rgb(144, 144, 144),
                shadow = rgb(72, 72, 72)
            },
            neon = {
                background = rgb(10, 12, 22),
                panel = rgb(16, 19, 30),
                panel_alt = rgb(23, 27, 40),
                border = rgb(77, 92, 255),
                text = rgb(241, 247, 255),
                muted = rgb(152, 170, 204),
                accent = rgb(110, 220, 255),
                accent_soft = rgb(77, 92, 255),
                accent_dark = rgb(40, 64, 144),
                muted_dark = rgb(35, 48, 76),
                shadow = rgb(15, 15, 35)
            },
            purple = {
                background = rgb(18, 12, 24),
                panel = rgb(28, 20, 35),
                panel_alt = rgb(39, 27, 48),
                border = rgb(155, 110, 255),
                text = rgb(250, 244, 255),
                muted = rgb(198, 175, 235),
                accent = rgb(192, 124, 255),
                accent_soft = rgb(110, 74, 176),
                accent_dark = rgb(71, 42, 120),
                muted_dark = rgb(80, 63, 98),
                shadow = rgb(24, 15, 40)
            },
            sunset = {
                background = rgb(27, 16, 18),
                panel = rgb(38, 23, 27),
                panel_alt = rgb(48, 28, 32),
                border = rgb(255, 149, 71),
                text = rgb(255, 244, 232),
                muted = rgb(230, 177, 148),
                accent = rgb(255, 157, 84),
                accent_soft = rgb(255, 107, 84),
                accent_dark = rgb(155, 67, 35),
                muted_dark = rgb(108, 71, 64),
                shadow = rgb(38, 20, 24)
            }
        }

        library.styles = {
            premium = {
                radius = 18,
                shadow = 16,
                padding = 12,
                glow = true,
                accent = rgb(255, 255, 255),
                section_radius = 14,
                tab_radius = 14,
                slider_radius = 12,
                dropdown_radius = 12
            },
            glass = {
                radius = 20,
                shadow = 18,
                padding = 12,
                glow = true,
                accent = rgb(110, 220, 255),
                section_radius = 16,
                tab_radius = 10,
                slider_radius = 10,
                dropdown_radius = 10
            },
            cyber = {
                radius = 16,
                shadow = 14,
                padding = 10,
                glow = true,
                accent = rgb(192, 124, 255),
                section_radius = 12,
                tab_radius = 12,
                slider_radius = 8,
                dropdown_radius = 10
            },
            minimal = {
                radius = 12,
                shadow = 10,
                padding = 8,
                glow = false,
                accent = rgb(52, 110, 255),
                section_radius = 10,
                tab_radius = 10,
                slider_radius = 8,
                dropdown_radius = 8
            }
        }

        library.theme = library.themes.dark
        library.style = library.styles.premium
        library.style.accent = library.theme.accent

        function library:resolve_theme(theme)
            if type(theme) == "string" then
                return library.themes[theme] or library.themes.dark
            elseif type(theme) == "table" then
                return theme
            end

            return library.theme or library.themes.dark
        end

        function library:resolve_style(style)
            if type(style) == "string" then
                return library.styles[style] or library.styles.premium
            elseif type(style) == "table" then
                return style
            end

            return library.style or library.styles.premium
        end

        function library:merge_theme(base, override)
            local merged = {}
            for key, value in pairs(base or {}) do
                merged[key] = value
            end

            if type(override) == "table" then
                for key, value in pairs(override) do
                    merged[key] = value
                end
            end

            return merged
        end

        function library:set_theme(name)
            local theme = library.themes[name] or library.themes.dark
            library.theme = theme
            if library.style then
                library.style.accent = theme.accent
            end
            return theme
        end

        function library:custom_theme(name, custom)
            if type(name) == "table" then
                local theme = library:merge_theme(library.themes.dark, name)
                library.theme = theme
                return theme
            end

            local theme = library:merge_theme(library.themes.dark, custom or {})
            library.themes[name] = theme
            library.theme = theme
            if library.style then
                library.style.accent = theme.accent
            end
            return theme
        end

        function library:apply_theme(theme)
            local palette = library:resolve_theme(theme)
            library.theme = palette
            if library.style then
                library.style.accent = palette.accent
            end
            return palette
        end

        function library:apply_style(style)
            local resolved = library:resolve_style(style)
            library.style = resolved
            if library.style and library.theme and library.style.accent == nil then
                library.style.accent = library.theme.accent
            end
            return library.style
        end

        function library:set_style(name)
            local style = library:resolve_style(name)
            return library:apply_style(style)
        end

        function library:configure_style(style)
            local current = library.style or {}
            local resolved = style
            if type(style) == "string" then
                resolved = library:resolve_style(style)
            end
            for key, value in pairs(resolved or {}) do
                current[key] = value
            end
            library.style = current
            if library.style and library.theme and library.style.accent == nil then
                library.style.accent = library.theme.accent
            end
            return library.style
        end

        function library:ThemeManager(options)
            local cfg = {
                default = options and (options.default or options.Default or "dark") or "dark",
                themes = options and (options.themes or library.themes) or library.themes,
                current = nil,
                items = {}
            }

            function cfg.set(name)
                local theme = cfg.themes[name] or cfg.themes.dark
                library:set_theme(name)
                if library.style then
                    library.style.accent = theme.accent
                end
                cfg.current = name
                return theme
            end

            cfg.set(cfg.default)
            return setmetatable(cfg, library)
        end

        function library:StyleManager(options)
            local cfg = {
                default = options and (options.default or options.Default or "premium") or "premium",
                styles = options and (options.styles or library.styles) or library.styles,
                current = nil,
                items = {}
            }

            function cfg.set(name)
                local style = cfg.styles[name] or cfg.styles.premium
                library:apply_style(style)
                cfg.current = name
                return style
            end

            cfg.set(cfg.default)
            return setmetatable(cfg, library)
        end

        function library:connection(signal, callback)
            local connection = signal:Connect(callback)
            
            insert(library.connections, connection)

            return connection 
        end

        function library:close_current_element(cfg) 
			local path = library.current 

			if path and path ~= cfg then 
				path.set_visible(false)
				path.open = false 
			end
		end

        function library:roundify(obj, radius)
            if not obj then
                return nil
            end

            local pickable = {
                Frame = true,
                TextButton = true,
                TextLabel = true,
                ImageLabel = true,
                ImageButton = true,
                ScrollingFrame = true,
                TextBox = true,
            }

            if not pickable[obj.ClassName] then
                return nil
            end

            local existing = obj:FindFirstChildOfClass("UICorner")
            if existing then
                existing.CornerRadius = radius or UDim.new(0, 8)
                return existing
            end

            local corner = Instance.new("UICorner")
            corner.CornerRadius = radius or UDim.new(0, 8)
            corner.Parent = obj

            return corner
        end

        function library:create(instance, options)
            local ins = Instance.new(instance) 
            local supports_rounding = instance == "Frame"
                or instance == "TextButton"
                or instance == "TextLabel"
                or instance == "ImageLabel"
                or instance == "ImageButton"
                or instance == "ScrollingFrame"
                or instance == "TextBox"
            
            for prop, value in options do 
                if not supports_rounding
                    or (prop ~= "CornerRadius"
                        and prop ~= "corner_radius"
                        and prop ~= "round"
                        and prop ~= "Round") then
                    ins[prop] = value
                end
            end

            if supports_rounding then
                local corner_radius = options.CornerRadius or options.corner_radius or options.round or options.Round or 8
                if typeof(corner_radius) == "number" then
                    corner_radius = UDim.new(0, corner_radius)
                end
                library:roundify(ins, corner_radius)
            end
            
            return ins 
        end

        function library:unload_menu() 
            if library[ "items" ] then 
                library[ "items" ]:Destroy()
            end

            if library[ "other" ] then 
                library[ "other" ]:Destroy()
            end 
            
            for index, connection in library.connections do 
                connection:Disconnect() 
                connection = nil 
            end
            
            library = nil 
        end 
    --
    
    -- Library element functions
        function library:window(properties)
            local cfg = { 
                -- Properties
                name = properties.name or properties.Name or "nebula";
                size = properties.size or properties.Size or dim2(0, 650, 0, 400);
                logo = properties.logo or properties.Logo or "rbxassetid://128155293790451";
                theme = library:resolve_theme(properties.theme or properties.Theme or library.theme),
                style = library:configure_style(properties.style or properties.Style or library.style),
                auto_size = properties.auto_size ~= false and properties.AutoSize ~= false,

                selected_tab;
                items = {};
                tweening;
            }
            
            local theme = cfg.theme
            local style = cfg.style
            local viewport = (ws.CurrentCamera or camera).ViewportSize

            local function get_window_size(viewport_size)
                if not cfg.auto_size then
                    return cfg.size
                end

                return dim2(
                    0,
                    math.min(cfg.size.X.Offset, math.max(1, viewport_size.X * 0.94)),
                    0,
                    math.min(cfg.size.Y.Offset, math.max(1, viewport_size.Y * 0.9))
                )
            end

            local initial_size = get_window_size(viewport)
            
            library[ "items" ] = library:create( "ScreenGui" , {
                Parent = coregui;
                Name = "\0";
                Enabled = true;
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
                IgnoreGuiInset = true;
            });
            
            library[ "other" ] = library:create( "ScreenGui" , {
                Parent = coregui;
                Name = "\0";
                Enabled = false;
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
                IgnoreGuiInset = true;
            }); 

            local items = cfg.items; do
                items[ "window" ] = library:create( "Frame" , {
                    Parent = library.items;
                    Name = "\0";
                    Visible = false;
                    Position = dim2(0.5, -initial_size.X.Offset / 2, 0.5, -initial_size.Y.Offset / 2);
                    BorderColor3 = theme.border or rgb(0, 0, 0);
                    Size = initial_size;
                    BorderSizePixel = 0;
                    BackgroundColor3 = theme.background or rgb(12, 12, 12),
                    CornerRadius = UDim.new(0, style.radius or 14)
                });

                local function update_window_size()
                    local current_camera = ws.CurrentCamera or camera
                    if not current_camera then
                        return
                    end

                    local new_size = get_window_size(current_camera.ViewportSize)
                    items["window"].Size = new_size
                    items["window"].Position = dim2(
                        0.5,
                        -new_size.X.Offset / 2,
                        0.5,
                        -new_size.Y.Offset / 2
                    )
                end

                local viewport_connection
                local function bind_camera_viewport()
                    if viewport_connection then
                        viewport_connection:Disconnect()
                    end

                    local current_camera = ws.CurrentCamera
                    if current_camera then
                        viewport_connection = library:connection(
                            current_camera:GetPropertyChangedSignal("ViewportSize"),
                            update_window_size
                        )
                    end
                    update_window_size()
                end

                library:connection(ws:GetPropertyChangedSignal("CurrentCamera"), bind_camera_viewport)
                bind_camera_viewport()

                items[ "top_frame" ] = library:create( "Frame" , {
                    Name = "\0";
                    Parent = items[ "window" ];
                    BorderColor3 = theme.border or rgb(0, 0, 0);
                    Size = dim2(1, 0, 0, 45);
                    BorderSizePixel = 0;
                    BackgroundColor3 = theme.panel or rgb(14, 14, 14),
                    CornerRadius = UDim.new(0, style.radius or 14)
                });
                
                items[ "logo" ] = library:create( "ImageLabel" , {
                    BorderColor3 = rgb(0, 0, 0);
                    Parent = items[ "top_frame" ];
                    Name = "\0";
                    Image = cfg.logo;
                    BackgroundTransparency = 1;
                    Position = dim2(0, 16, 0, 7);
                    Size = dim2(0, 32, 0, 32);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                items[ "ui_title" ] = library:create( "TextLabel" , {
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal);
                    TextColor3 = theme.text or rgb(255, 255, 255);
                    TextStrokeColor3 = theme.text or rgb(255, 255, 255);
                    Text = cfg.name;
                    Parent = items[ "top_frame" ];
                    Name = "\0";
                    BackgroundTransparency = 1;
                    Size = dim2(1, 0, 1, 0);
                    BorderSizePixel = 0;
                    BorderColor3 = theme.border or rgb(0, 0, 0);
                    TextSize = 35;
                    BackgroundColor3 = theme.panel or rgb(14, 14, 14)
                });
                
                items[ "inline" ] = library:create( "Frame" , {
                    Parent = items[ "window" ];
                    Name = "\0";
                    Position = dim2(0, 0, 0, 44);
                    BorderColor3 = theme.border or rgb(0, 0, 0);
                    Size = dim2(0, 63, 1, -44);
                    BorderSizePixel = 0;
                    BackgroundColor3 = theme.panel_alt or rgb(8, 8, 8),
                    CornerRadius = UDim.new(0, style.radius or 14)
                });
                
                items[ "tab_button_holder" ] = library:create( "Frame" , {
                    Parent = items[ "inline" ];
                    Name = "\0";
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = theme.border or rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = theme.panel or rgb(14, 14, 14),
                    CornerRadius = UDim.new(0, style.tab_radius or 12)
                });
                
                library:create( "UIPadding" , {
                    Parent = items[ "tab_button_holder" ];
                    PaddingTop = dim(0, 37)
                });
                
                library:create( "UIListLayout" , {
                    Parent = items[ "tab_button_holder" ];
                    Padding = dim(0, 24);
                    SortOrder = Enum.SortOrder.LayoutOrder
                });
                
                items[ "page_holder" ] = library:create( "Frame" , {
                    Parent = items[ "window" ];
                    Name = "\0";
                    Position = dim2(0, 63, 0, 45);
                    BorderColor3 = theme.border or rgb(0, 0, 0);
                    Size = dim2(1, -63, 1, -45);
                    BorderSizePixel = 0;
                    BackgroundColor3 = theme.background or rgb(12, 12, 12),
                    CornerRadius = UDim.new(0, style.radius or 14)
                });                
            end 

            do -- Dashboard view fills the page area when no tab is selected
                local accent = theme.accent or rgb(255, 255, 255)
                local dashboard = library:create("ScrollingFrame", {
                    Name = "Dashboard",
                    Parent = items["page_holder"],
                    Position = dim2(0, 0, 0, 0),
                    Size = dim2(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    CanvasSize = dim2(0, 0, 0, 0),
                    ScrollingDirection = Enum.ScrollingDirection.Y,
                    ScrollBarThickness = 4,
                    ScrollBarImageColor3 = accent,
                    AutomaticCanvasSize = Enum.AutomaticSize.None
                })
                items["dashboard"] = dashboard
                dashboard.Visible = false
                library:create("TextLabel", {
                    Name = "DashboardTitle",
                    Parent = dashboard,
                    Position = dim2(0, 16, 0, 12),
                    Size = dim2(1, -32, 0, 36),
                    BackgroundTransparency = 1,
                    FontFace = library.font,
                    Text = "PLAYER DASHBOARD",
                    TextColor3 = accent,
                    TextSize = 16,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center
                })
                local player_panel = library:create("Frame", {
                    Name = "PlayerPanel",
                    Parent = dashboard,
                    Position = dim2(0, 16, 0, 58),
                    Size = dim2(0.5, -24, 1, -74),
                    BorderSizePixel = 0,
                    BackgroundColor3 = theme.panel or rgb(14, 14, 14)
                })
                library:roundify(player_panel, dim(0, style.section_radius or 12))
                local server_panel = library:create("Frame", {
                    Name = "ServerPanel",
                    Parent = dashboard,
                    Position = dim2(0.5, 8, 0, 58),
                    Size = dim2(0.5, -24, 1, -74),
                    BorderSizePixel = 0,
                    BackgroundColor3 = theme.panel or rgb(14, 14, 14)
                })
                library:roundify(server_panel, dim(0, style.section_radius or 12))

                local function make_dashboard_column(panel)
                    library:create("UIPadding", {
                        Parent = panel,
                        PaddingTop = dim(0, 12),
                        PaddingBottom = dim(0, 12),
                        PaddingLeft = dim(0, 12),
                        PaddingRight = dim(0, 12)
                    })
                    return library:create("UIGridLayout", {
                        Parent = panel,
                        CellPadding = dim2(0, 8, 0, 8),
                        CellSize = dim2(0.5, -4, 0, 96),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })
                end
                local player_grid = make_dashboard_column(player_panel)
                local server_grid = make_dashboard_column(server_panel)

                local function add_dashboard_label(parent, name, text, height, text_color, text_size)
                    local label = library:create("TextLabel", {
                        Name = name,
                        Parent = parent,
                        Size = dim2(1, 0, 0, height),
                        BorderSizePixel = 0,
                        BackgroundColor3 = theme.panel_alt or rgb(8, 8, 8),
                        BackgroundTransparency = 0,
                        FontFace = library.font,
                        Text = text,
                        TextColor3 = text_color or theme.text or rgb(255, 255, 255),
                        TextSize = text_size or 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Center,
                        TextWrapped = true
                    })
                    library:roundify(label, dim(0, 8))
                    library:create("UIPadding", {
                        Parent = label,
                        PaddingLeft = dim(0, 9),
                        PaddingRight = dim(0, 6)
                    })
                    return label
                end

                local function add_dashboard_button(name, text, callback)
                    local button = library:create("TextButton", {
                        Name = name,
                        Parent = server_panel,
                        Size = dim2(1, 0, 0, 34),
                        BorderSizePixel = 0,
                        BackgroundColor3 = accent,
                        BackgroundTransparency = 0.08,
                        AutoButtonColor = true,
                        FontFace = library.font,
                        Text = text,
                        TextColor3 = theme.background or rgb(12, 12, 12),
                        TextSize = 11
                    })
                    library:roundify(button, dim(0, 9))
                    button.MouseButton1Click:Connect(callback)
                    return button
                end

                add_dashboard_label(player_panel, "DashboardPlayerHeading", "PLAYER TRACKER", 34, accent, 12)
                add_dashboard_label(player_panel, "DashboardPlayer", "Joueur: " .. lp.DisplayName, 40)
                add_dashboard_label(player_panel, "DashboardUsername", "Utilisateur: @" .. lp.Name, 34)
                add_dashboard_label(player_panel, "DashboardUserId", "User ID: " .. tostring(lp.UserId), 34)
                local time_label = add_dashboard_label(player_panel, "DashboardTime", "Heure locale: --:--:--", 34)
                local session_label = add_dashboard_label(player_panel, "DashboardSession", "Session: 00:00:00", 34)
                local ping_label = add_dashboard_label(player_panel, "DashboardPing", "Ping: --", 34)
                local fps_label = add_dashboard_label(player_panel, "DashboardFPS", "FPS: --", 34)

                add_dashboard_label(server_panel, "DashboardServerHeading", "SERVER TRACKER", 34, accent, 12)
                local player_count_label = add_dashboard_label(server_panel, "DashboardPlayerCount", "Joueurs: --", 34)
                add_dashboard_label(server_panel, "DashboardPlaceId", "Place ID: " .. tostring(game.PlaceId), 34)
                local job_id = game.JobId
                local short_job_id = #job_id > 12 and (string.sub(job_id, 1, 12) .. "...") or job_id
                add_dashboard_label(server_panel, "DashboardServerId", "Serveur: " .. short_job_id, 34)
                add_dashboard_label(server_panel, "DashboardRegion", "Région: non fournie par Roblox", 40)
                local status_label = add_dashboard_label(server_panel, "DashboardStatus", "Prêt", 42, theme.muted or rgb(178, 178, 178), 10)

                add_dashboard_button("DashboardRejoin", "REJOIN SERVER", function()
                    status_label.Text = "Reconnexion au serveur..."
                    task.spawn(function()
                        local ok, err = pcall(function()
                            teleport_service:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
                        end)
                        if not ok then
                            status_label.Text = "Échec de reconnexion"
                            warn("[Dashboard] Rejoin failed:", err)
                        end
                    end)
                end)

                add_dashboard_button("DashboardServerHop", "HOP — MOINS REMPLI", function()
                    status_label.Text = "Recherche d'un serveur moins rempli..."
                    task.spawn(function()
                        local request_ok, response = pcall(function()
                            return game:HttpGet(
                                "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId)
                                    .. "/servers/Public?sortOrder=Asc&limit=100"
                            )
                        end)
                        if not request_ok then
                            status_label.Text = "Impossible de récupérer les serveurs"
                            warn("[Dashboard] Server list request failed:", response)
                            return
                        end

                        local decode_ok, server_data = pcall(function()
                            return http_service:JSONDecode(response)
                        end)
                        if not decode_ok then
                            status_label.Text = "Réponse serveur invalide"
                            warn("[Dashboard] Server list JSON decode failed:", server_data)
                            return
                        end
                        if type(server_data) ~= "table" or type(server_data.data) ~= "table" then
                            status_label.Text = "Liste des serveurs indisponible"
                            warn("[Dashboard] Server list response has no data array")
                            return
                        end

                        local candidates = {}
                        local least_players = math.huge
                        for _, server in ipairs(server_data.data or {}) do
                            if type(server) == "table"
                                and type(server.id) == "string"
                                and type(server.playing) == "number"
                                and type(server.maxPlayers) == "number"
                                and server.id ~= game.JobId
                                and server.playing < server.maxPlayers then
                                if server.playing < least_players then
                                    least_players = server.playing
                                    candidates = {server}
                                elseif server.playing == least_players then
                                    table.insert(candidates, server)
                                end
                            end
                        end

                        if #candidates == 0 then
                            status_label.Text = "Aucun autre serveur disponible"
                            return
                        end

                        local target = candidates[random(1, #candidates)]
                        status_label.Text = "Hop vers un serveur moins rempli..."
                        local teleport_ok, teleport_error = pcall(function()
                            teleport_service:TeleportToPlaceInstance(game.PlaceId, target.id, lp)
                        end)
                        if not teleport_ok then
                            status_label.Text = "Échec du changement de serveur"
                            warn("[Dashboard] Server hop failed:", teleport_error)
                        end
                    end)
                end)

                local started_at = os.clock()
                local last_refresh = started_at
                local frame_count = 0
                local last_dashboard_layout = 0
                library:connection(run.RenderStepped, function()
                    frame_count = frame_count + 1
                    local now = os.clock()

                    if now - last_refresh >= 1 then
                        local elapsed = now - last_refresh
                        time_label.Text = "Heure locale: " .. os.date("%H:%M:%S")
                        local session_seconds = floor(now - started_at)
                        session_label.Text = string.format(
                            "Session: %02d:%02d:%02d",
                            floor(session_seconds / 3600),
                            floor(session_seconds / 60) % 60,
                            session_seconds % 60
                        )

                        local ping_ok, ping_value = pcall(function()
                            return stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
                        end)
                        ping_label.Text = "Ping: " .. (ping_ok and tostring(ping_value) or "indisponible")
                        fps_label.Text = "FPS: " .. tostring(floor(frame_count / elapsed + 0.5))
                        player_count_label.Text = "Joueurs: " .. tostring(#players:GetPlayers()) .. "/" .. tostring(players.MaxPlayers)

                        frame_count = 0
                        last_refresh = now
                    end

                    if now - last_dashboard_layout >= 0.2 then
                        local dashboard_width = dashboard.AbsoluteSize.X
                        local panel_width = math.max(1, (dashboard_width - 40) / 2)
                        local grid_columns = panel_width < 190 and 1 or 2
                        local tile_side = math.clamp(
                            (panel_width - 24 - (grid_columns == 2 and 8 or 0)) / grid_columns,
                            52,
                            136
                        )
                        local grid_rows = math.ceil(8 / grid_columns)
                        local panel_height = 24 + (tile_side * grid_rows) + (8 * (grid_rows - 1))
                        local grid_cell_size = dim2(
                            1 / grid_columns,
                            grid_columns == 2 and -4 or 0,
                            0,
                            tile_side
                        )
                        player_grid.CellSize = grid_cell_size
                        server_grid.CellSize = grid_cell_size

                        player_panel.Position = dim2(0, 16, 0, 58)
                        player_panel.Size = dim2(0.5, -24, 0, panel_height)
                        server_panel.Position = dim2(0.5, 8, 0, 58)
                        server_panel.Size = dim2(0.5, -24, 0, panel_height)
                        dashboard.CanvasSize = dim2(0, 0, 0, 58 + panel_height + 16)
                        last_dashboard_layout = now
                    end
                end)
            end
            
            do -- Other
                library:draggify(items[ "window" ])
                library:resizify(items[ "window" ])
            end 
            
            function cfg.toggle_menu(bool) 
                if cfg.tweening or items["window"].Visible == bool then
                    return 
                end 

                cfg.tweening = true 

                if bool then 
                    items[ "window" ].Visible = true
                end

                local Children = items[ "window" ]:GetDescendants()
                table.insert(Children, items[ "window" ])

                local Tween;
                for _,obj in Children do
                    local Index = library:get_transparency(obj)

                    if not Index then 
                        continue 
                    end

                    if type(Index) == "table" then
                        for _,prop in Index do
                            Tween = library:fade(obj, prop, bool)
                        end
                    else
                        Tween = library:fade(obj, Index, bool)
                    end
                end

                if Tween then
                    library:connection(Tween.Completed, function()
                        cfg.tweening = false
                        items["window"].Visible = bool
                    end)
                else
                    cfg.tweening = false
                    items["window"].Visible = bool
                end
            end 
                
            return setmetatable(cfg, library)
        end 

        function library:Tab(properties)
            local cfg = {
                -- properties
                name = properties.name or properties.Name or "visuals"; 
                icon = properties.icon or properties.Icon or "http://www.roblox.com/asset/?id=6034767608";
                theme = library:resolve_theme(properties.theme or properties.Theme or library.theme),
                style = library:configure_style(properties.style or properties.Style or library.style),
                
                items = {};
            } 

            local items = cfg.items; do                
                -- Tab buttons 
                    items[ "tab_button" ] = library:create( "TextButton" , {
                        Parent = self.items[ "tab_button_holder" ];
                        BackgroundTransparency = 1;
                        Text = "";
                        Size = dim2(1, 0, 0, 0);
                        BorderColor3 = rgb(0, 0, 0);
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.Y;
                            BackgroundColor3 = rgb(255, 255, 255),
                            CornerRadius = UDim.new(0, (cfg.style and cfg.style.tab_radius) or 12)
                        });
                    
                    items[ "image" ] = library:create( "ImageLabel" , {
                        ImageColor3 = rgb(128, 128, 128);
                        Active = true;
                        BorderColor3 = rgb(0, 0, 0);
                        Parent = items[ "tab_button" ];
                        Name = "\0";
                        Size = dim2(0, 32, 0, 32);
                        AnchorPoint = vec2(0.5, 0);
                        Image = cfg.icon;
                        BackgroundTransparency = 1;
                        Position = dim2(0.5, 0, 0, 0);
                        Selectable = true;
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });                       
                -- 

                -- Page directory
                    items[ "tab" ] = library:create( "Frame" , {
                        Parent = library.items;
                        BackgroundTransparency = 1;
                        Name = "\0";
                        Visible = false;
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, 0, 1, 0);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    
                    library:create( "UIListLayout" , {
                        FillDirection = Enum.FillDirection.Horizontal;
                        HorizontalFlex = Enum.UIFlexAlignment.Fill;
                        Parent = items[ "tab" ];
                        Padding = dim(0, 21);
                        SortOrder = Enum.SortOrder.LayoutOrder;
                        VerticalFlex = Enum.UIFlexAlignment.Fill
                    });
                    
                    library:create( "UIPadding" , {
                        PaddingTop = dim(0, 24);
                        PaddingBottom = dim(0, 21);
                        Parent = items[ "tab" ];
                        PaddingRight = dim(0, 21);
                        PaddingLeft = dim(0, 21)
                    });     
                    
                    for _,column in {"left", "right"} do 
                        items[ column ] = library:create( "Frame" , {
                            Parent = items[ "tab" ];
                            BackgroundTransparency = 1;
                            Name = "\0";
                            BorderColor3 = rgb(0, 0, 0);
                            Size = dim2(0, 100, 0, 100);
                            BorderSizePixel = 0;
                            BackgroundColor3 = rgb(8, 8, 8)
                        }); 
                    end                  
                -- 
            end 

            function cfg.open_tab() 
                local selected_tab = self.selected_tab
                local theme = cfg.theme or library.theme

                if selected_tab and selected_tab[2] == items.tab then
                    selected_tab[1].ImageColor3 = theme.muted or rgb(128, 128, 128)
                    selected_tab[2].Parent = library.items
                    selected_tab[2].Visible = false
                    self.selected_tab = nil
                    self.items["dashboard"].Visible = true
                    library:close_current_element(nil)
                    return
                end
                
                if selected_tab then 
                   selected_tab[ 1 ].ImageColor3 = theme.muted or rgb(128, 128, 128)
                   selected_tab[ 2 ].Parent = library.items
                   selected_tab[ 2 ].Visible = false
                end
                 
                self.items["dashboard"].Visible = false
                items.image.ImageColor3 = theme.text or rgb(255, 255, 255)
                items.tab.Parent = self.items[ "page_holder" ]
                items.tab.Visible = true

                self.selected_tab = {
                    items.image;
                    items.tab;
                }

                library:close_current_element(nil) 
            end

            items[ "tab_button" ].MouseButton1Down:Connect(function()
                cfg.open_tab()
            end)

            if not self.selected_tab then 
                cfg.open_tab(true) 
            end

            return setmetatable(cfg, library)
        end

        function library:Section(properties)
            local cfg = {
                name = properties.name or properties.Name or "section"; 
                side = properties.side or properties.Side or "left";
                default = properties.default or properties.Default or false;
                size = properties.size or properties.Size or 0.5; 
                icon = properties.icon or properties.Icon or "http://www.roblox.com/asset/?id=6022668898";
                fading_toggle = properties.fading or properties.Fading or false;
                theme = library:resolve_theme(properties.theme or properties.Theme or library.theme),
                style = library:configure_style(properties.style or properties.Style or library.style),
                items = {};
            };
            
            local theme = cfg.theme
            local items = cfg.items; do 
                items[ "section_outline" ] = library:create( "Frame" , {
                    Name = "\0";
                    BackgroundTransparency = 1;
                    Parent = self.items[ cfg.side ];
                    BorderColor3 = theme.border or rgb(0, 0, 0);
                    Size = dim2(1, 0, 1, 0);
                    BorderSizePixel = 0;
                    BackgroundColor3 = theme.panel_alt or rgb(8, 8, 8),
                    CornerRadius = UDim.new(0, cfg.style.section_radius or 12)
                });
                
                items[ "section_shadow" ] = library:create( "Frame" , {
                    Parent = items[ "section_outline" ];
                    Name = "\0";
                    Position = dim2(0, 1, 0, 1);
                    BackgroundTransparency = 1;
                    BorderColor3 = theme.border or rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = theme.panel_alt or rgb(5, 5, 5),
                    CornerRadius = UDim.new(0, (cfg.style.section_radius or 12) + 2)
                });
                
                items[ "section_shadow_one" ] = library:create( "Frame" , {
                    Parent = items[ "section_shadow" ];
                    Name = "\0";
                    Position = dim2(0, 1, 0, 1);
                    BackgroundTransparency = 1;
                    BorderColor3 = theme.border or rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = theme.panel_alt or rgb(0, 0, 0),
                    CornerRadius = UDim.new(0, (cfg.style.section_radius or 12) + 1)
                });
                
                items[ "section_shadow_two" ] = library:create( "Frame" , {
                    Parent = items[ "section_shadow_one" ];
                    Name = "\0";
                    BackgroundTransparency = 1;
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = theme.border or rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = theme.panel_alt or rgb(0, 0, 0),
                    CornerRadius = UDim.new(0, cfg.style.section_radius or 12)
                });
                
                items[ "section_shadow_three" ] = library:create( "Frame" , {
                    Name = "\0";
                    BackgroundTransparency = 1;
                    Parent = items[ "section_shadow_two" ];
                    BorderColor3 = theme.border or rgb(0, 0, 0);
                    Size = dim2(1, 0, 1, 0);
                    BorderSizePixel = 0;
                    BackgroundColor3 = theme.panel or rgb(14, 14, 14),
                    CornerRadius = UDim.new(0, 12)
                });
                
                library:create( "UICorner" , {
                    Parent = items[ "section_shadow_three" ];
                    CornerRadius = dim(0, 0)
                });
                
                items[ "scrolling" ] = library:create( "ScrollingFrame" , {
                    ScrollBarImageColor3 = rgb(0, 0, 0);
                    Active = true;
                    AutomaticCanvasSize = Enum.AutomaticSize.Y;
                    ScrollBarThickness = 0;
                    Parent = items[ "section_shadow_three" ];
                    Name = "\0";
                    BackgroundTransparency = 1;
                    Size = dim2(1, 0, 1, 0);
                    BackgroundColor3 = rgb(255, 255, 255);
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    CanvasSize = dim2(0, 0, 0, 0)
                });
                
                items[ "elements" ] = library:create( "Frame" , {
                    BorderColor3 = rgb(0, 0, 0);
                    Parent = items[ "scrolling" ];
                    Name = "\0";
                    BackgroundTransparency = 1;
                    Position = dim2(0, 12, 0, 12);
                    Size = dim2(1, -24, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                library:create( "UIListLayout" , {
                    Parent = items[ "elements" ];
                    Padding = dim(0, 5);
                    SortOrder = Enum.SortOrder.LayoutOrder
                });
                
                library:create( "UICorner" , {
                    Parent = items[ "section_shadow_two" ];
                    CornerRadius = dim(0, 0)
                });
                
                library:create( "UICorner" , {
                    Parent = items[ "section_shadow_one" ];
                    CornerRadius = dim(0, 0)
                });
                
                library:create( "UICorner" , {
                    Parent = items[ "section_shadow" ];
                    CornerRadius = dim(0, 0)
                });
                
                items.text = library:create( "TextLabel" , {
                    FontFace = library.font;
                    TextColor3 = theme.muted or rgb(178, 178, 178);
                    BorderColor3 = theme.border or rgb(0, 0, 0);
                    Text = cfg.name;
                    Parent = items[ "section_outline" ];
                    BackgroundTransparency = 1;
                    Position = dim2(0, 8, 0, -15);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    TextSize = 10;
                    BackgroundColor3 = theme.panel or rgb(255, 255, 255)
                });
                
                items.line = library:create( "Frame" , {
                    Parent = items.text;
                    Position = dim2(0, 0, 1, 2);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(0, 0, 0, 1);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });                

                library:create( "UIStroke" , {
                    Parent = items.text;
                });
                
                library:create( "UICorner" , {
                    Parent = items[ "section_outline" ];
                    CornerRadius = dim(0, 0)
                });                
            end;

            items[ "section_outline" ].MouseEnter:Connect(function()
                for _,instance in items[ "section_outline" ]:GetDescendants() do 
                    if instance:IsA("UICorner") then 
                        library:tween(instance, {CornerRadius = dim(0, 8)})
                    end 
                end 

                for _,section in {"section_shadow_three", "section_shadow_two", "section_shadow_one", "section_shadow"} do 
                    library:tween(items[ section ], {BackgroundTransparency = 0})
                end 
                
                library:tween(items.line, {Size = dim2(1, 0, 0, 1)})
                library:tween(items.text, {TextColor3 = cfg.theme.accent or rgb(255, 255, 255)})
            end)

            items[ "section_outline" ].MouseLeave:Connect(function()
                for _,instance in items[ "section_outline" ]:GetDescendants() do 
                    if instance:IsA("UICorner") then 
                        library:tween(instance, {CornerRadius = dim(0, 0)})
                    end 
                end 

                for _,section in {"section_shadow_three", "section_shadow_two", "section_shadow_one", "section_shadow"} do 
                    library:tween(items[ section ], {BackgroundTransparency = 1})
                end

                library:tween(items.line, {Size = dim2(0, 0, 0, 1)})
                library:tween(items.text, {TextColor3 = cfg.theme.muted or rgb(178, 178, 178)})
            end)

            return setmetatable(cfg, library)
        end  

        function library:Toggle(options) 
            local cfg = {
                enabled = options.enabled or options.Enabled or nil,
                name = options.name or options.Name or "Toggle",
                flag = options.flag or options.Flag or options.name or options.Name or "please set me a flag 🥺",
                theme = library:resolve_theme(options.theme or options.Theme or library.theme),
                
                default = options.default or options.Default or false,
                callback = options.callback or options.Callback or function() end,

                items = {};
            }

            local theme = cfg.theme
            local items = cfg.items; do 
                items[ "object" ] = library:create( "TextButton" , {
                    Parent = self.items[ "elements" ];
                    Text = "";
                    Name = "\0";
                    BackgroundTransparency = 1;
                    Size = dim2(1, 0, 0, 12);
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    -- AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                items[ "toggle_outline" ] = library:create( "Frame" , {
                    Parent = items[ "object" ];
                    BackgroundTransparency = 1;
                    Name = "\0";
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(0, 12, 0, 12);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(0, 0, 0)
                });
                
                items[ "toggle_shading" ] = library:create( "Frame" , {
                    Parent = items[ "toggle_outline" ];
                    Name = "\0";
                    BackgroundTransparency = 1;
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(92, 92, 92)
                });
                
                items[ "toggle_inline" ] = library:create( "Frame" , {
                    Parent = items[ "toggle_shading" ];
                    Name = "\0";
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(54, 54, 54)
                });
                
                library:create( "UIListLayout" , {
                    Parent = items[ "object" ];
                    Padding = dim(0, 5);
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    FillDirection = Enum.FillDirection.Horizontal
                });
                
                items[ "text" ] = library:create( "TextLabel" , {
                    FontFace = library.font;
                    TextColor3 = rgb(178, 178, 178);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = cfg.name;
                    Parent = items[ "object" ];
                    BackgroundTransparency = 1;
                    Position = dim2(0, 12, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    TextSize = 10;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                library:create( "UIStroke" , {
                    Parent = items[ "text" ]
                });
                
                library:create( "UIPadding" , {
                    PaddingLeft = dim(0, 1);
                    Parent = items[ "text" ]
                });
            end;
            
            function cfg.set(bool)
                library:tween(items[ "text" ], {TextColor3 = bool and (theme.text or rgb(255, 255, 255)) or (theme.muted or rgb(178, 178, 178))})
                library:tween(items[ "toggle_outline" ], {BackgroundTransparency = bool and 0 or 1})
                library:tween(items[ "toggle_shading" ], {BackgroundTransparency = bool and 0 or 1})
                library:tween(items[ "toggle_inline" ], {BackgroundColor3 = bool and (theme.accent or rgb(255, 255, 255)) or (theme.muted_dark or rgb(74, 74, 74))})

                cfg.callback(bool)
                
                flags[cfg.flag] = bool
            end 
            
            items[ "object" ].MouseButton1Click:Connect(function()
                cfg.enabled = not cfg.enabled 
                cfg.set(cfg.enabled)
            end)
            
            cfg.set(cfg.default)

            config_flags[cfg.flag] = cfg.set

            return setmetatable(cfg, library)
        end 
        
        function library:Slider(options) 
            local cfg = {
                -- Options
                name = options.name or options.Name or nil;
                suffix = options.suffix or options.Suffix or "";
                flag = options.flag or options.Flag or options.name or options.Name or "please set me a flag 🥺";
                callback = options.callback or options.Callback or function() end; 
                show_value = options.ShowValue or options.show_value or true; 
                theme = library:resolve_theme(options.theme or options.Theme or library.theme),

                -- value settings
                min = options.min or options.minimum or options.Min or options.Minimum or 0;
                max = options.max or options.maximum or options.Max or options.Maximum or 100;
                intervals = options.interval or options.decimal or options.Interval or options.Decimal or 1;
                default = options.default or options.Default or 10;
                value = options.default or options.default or 10; 

                -- ignore
                dragging = false;
                items = {}
            } 

            local theme = cfg.theme
            local items = cfg.items; do
                items[ "object" ] = library:create( "Frame" , {
                    Parent = self.items.object or self.items.elements;
                    Name = "\0";
                    BackgroundTransparency = 1;
                    Size = dim2(0, 0, 0, 12);
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                library:create( "UIListLayout" , {
                    Parent = items[ "object" ];
                    Padding = dim(0, 5);
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    FillDirection = Enum.FillDirection.Horizontal
                });
                
                items[ "slider_parent" ] = library:create( "TextButton" , {
                    Parent = items[ "object" ];
                    BackgroundTransparency = 1;
                    Text = "";
                    Name = "\0";
                    BorderColor3 = theme.border or rgb(0, 0, 0);
                    Size = dim2(0, 130, 1, 0);
                    BorderSizePixel = 0;
                    BackgroundColor3 = theme.panel or rgb(255, 255, 255),
                    CornerRadius = UDim.new(0, 10)
                });
                
                items[ "slider_holder" ] = library:create( "Frame" , {
                    AnchorPoint = vec2(0, 0.5);
                    Parent = items[ "slider_parent" ];
                    Name = "\0";
                    Position = dim2(0, 0, 0.5, 0);
                    BorderColor3 = theme.border or rgb(0, 0, 0);
                    Size = dim2(1, 0, 0, 8);
                    BorderSizePixel = 0;
                    BackgroundColor3 = theme.panel_alt or rgb(0, 0, 0),
                    CornerRadius = UDim.new(0, 8)
                });
                
                items[ "gradient_holder" ] = library:create( "Frame" , {
                    Parent = items[ "slider_holder" ];
                    Name = "\0";
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = theme.border or rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = theme.accent_soft or rgb(255, 255, 255),
                    CornerRadius = UDim.new(0, 7)
                });
                
                library:create( "UIGradient" , {
                    Color = rgbseq{rgbkey(0, rgb(255, 255, 255)), rgbkey(1, rgb(93, 93, 93))};
                    Parent = items[ "gradient_holder" ]
                });
                
                items[ "slider" ] = library:create( "Frame" , {
                    AnchorPoint = vec2(0, 0.5);
                    Parent = items[ "gradient_holder" ];
                    Name = "\0";
                    Position = dim2(0, 0, 0.5, 0);
                    BorderColor3 = theme.border or rgb(0, 0, 0);
                    Size = dim2(0, 8, 0, 14);
                    BorderSizePixel = 0;
                    BackgroundColor3 = theme.text or rgb(0, 0, 0),
                    CornerRadius = UDim.new(0, 8)
                });
                
                items[ "inline" ] = library:create( "Frame" , {
                    Parent = items[ "slider" ];
                    Name = "\0";
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = theme.border or rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = theme.accent or rgb(255, 255, 255),
                    CornerRadius = UDim.new(0, 7)
                });
                
                if cfg.name then
                    items[ "name" ] = setmetatable(cfg, library):Label({padding_top = 1})
                end

                if cfg.show_value then 
                    items[ "value" ] = setmetatable(cfg, library):Label({padding_top = 1})
                end       
            end 

            function cfg.set(value)
                cfg.value = clamp(library:round(value, cfg.intervals), cfg.min, cfg.max)
                
                items[ "slider" ].Position = dim2((cfg.value - cfg.min) / (cfg.max - cfg.min), 0, 0.5, 0)

                if items[ "value" ] then
                    items[ "value" ].set(tostring(cfg.value) .. cfg.suffix)
                end

                flags[cfg.flag] = cfg.value
                cfg.callback(flags[cfg.flag])
            end

            items[ "slider_parent" ].MouseButton1Down:Connect(function()
                cfg.dragging = true 
            end)

            library:connection(uis.InputChanged, function(input)
                if cfg.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then 
                    local size_x = (input.Position.X - items[ "gradient_holder" ].AbsolutePosition.X) / items[ "gradient_holder" ].AbsoluteSize.X
                    local value = ((cfg.max - cfg.min) * size_x) + cfg.min
                    cfg.set(value)
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

        function library:Dropdown(options) 
            local cfg = {
                obj_type = "dropdown";

                -- Options
                name = options.name or options.Name or nil;
                flag = options.flag or options.Flag or options.name or options.Name or "please set me a flag 🥺";
                options = options.items or options.Items or {"1", "2", "3"};
                callback = options.callback or options.Callback or function() end;
                multi = options.multi or options.Multi or false;
                theme = library:resolve_theme(options.theme or options.Theme or library.theme),

                -- Ignore these 
                open = false;
                option_instances = {};
                multi_items = {};
                items = {};
            }   

            local theme = cfg.theme

            cfg.default = options.default or (cfg.multi and {cfg.items[1]}) or cfg.items[1] or "None"
            flags[cfg.flag] = cfg.default
            
            local items = cfg.items; do 
                -- Element
                    items[ "object" ] = library:create( "Frame" , {
                        Parent = self.items.object or self.items.elements;
                        Name = "\0";
                        BackgroundTransparency = 1;
                        Size = dim2(0, 0, 0, 12);
                        BorderColor3 = rgb(0, 0, 0);
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.XY;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });

                    if self.items.object then 
                        library:create( "UIPadding" , {
                            Parent = items[ "object" ];
                            PaddingTop = dim(0, -2)
                        });                        
                    end 
                    
                    items[ "dropdown_outline" ] = library:create( "TextButton" , {
                        Parent = items[ "object" ];
                        Text = "";
                        AutoButtonColor = false;
                        Name = "\0";
                        Size = dim2(0, 0, 0, 16);
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.X;
                        BackgroundColor3 = theme.panel_alt or rgb(0, 0, 0),
                        CornerRadius = UDim.new(0, 8)
                    });
   
                    items[ "dropdown_shading" ] = library:create( "Frame" , {
                        Parent = items[ "dropdown_outline" ];
                        Size = dim2(0, -2, 1, -2);
                        Name = "\0";
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = theme.border or rgb(0, 0, 0);
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.X;
                        BackgroundColor3 = theme.panel or rgb(255, 255, 255),
                        CornerRadius = UDim.new(0, 7)
                    });
                    
                    library:create( "UIGradient" , {
                        Rotation = 90;
                        Parent = items[ "dropdown_shading" ];
                        Color = rgbseq{rgbkey(0, rgb(33, 33, 33)), rgbkey(1, rgb(8, 8, 8))}
                    });
                    
                    items.inner_text = library:create( "TextLabel" , {
                        FontFace = library.font;
                        TextColor3 = theme.muted or rgb(178, 178, 178);
                        BorderColor3 = theme.border or rgb(0, 0, 0);
                        Text = "Combat";
                        Parent = items[ "dropdown_shading" ];
                        AnchorPoint = vec2(0, 0.5);
                        Size = dim2(1, 0, 1, 0);
                        BackgroundTransparency = 1;
                        Position = dim2(0, 0, 0.5, 0);
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.XY;
                        TextSize = 10;
                        BackgroundColor3 = theme.panel or rgb(255, 255, 255)
                    });
                    
                    library:create( "UIStroke" , {
                        Parent = items[ "TextLabel" ]
                    });
                    
                    library:create( "UIPadding" , {
                        Parent = items[ "TextLabel" ]
                    });
                    
                    library:create( "UIPadding" , {
                        Parent = items[ "dropdown_shading" ];
                        PaddingRight = dim(0, 40);
                        PaddingLeft = dim(0, 40)
                    });
                    
                    library:create( "UIPadding" , {
                        PaddingRight = dim(0, 1);
                        Parent = items[ "dropdown_outline" ]
                    });
                    
                    items[ "arrow" ] = library:create( "ImageLabel" , {
                        ImageColor3 = theme.muted or rgb(178, 178, 178);
                        BorderColor3 = theme.border or rgb(0, 0, 0);
                        Parent = items[ "dropdown_outline" ];
                        Name = "\0";
                        AnchorPoint = vec2(1, 0.5);
                        Image = "rbxassetid://76667213487638";
                        BackgroundTransparency = 1;
                        Position = dim2(1, -4, 0.5, 0);
                        Size = dim2(0, 7, 0, 4);
                        BorderSizePixel = 0;
                        BackgroundColor3 = theme.panel or rgb(255, 255, 255)
                    });
                    
                    library:create( "UIListLayout" , {
                        Parent = items[ "object" ];
                        Padding = dim(0, 5);
                        SortOrder = Enum.SortOrder.LayoutOrder;
                        FillDirection = Enum.FillDirection.Horizontal
                    });
                -- 

                -- Element Holder
                    items[ "dropdown_holder" ] = library:create( "Frame" , {
                        Parent = library.items;
                        Size = dim2(0, 114, 0, 0);
                        Visible = false;
                        Name = "\0";
                        Position = dim2(0.05823293328285217, 0, 0.19430045783519745, 0);
                        BorderColor3 = rgb(0, 0, 0);
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.Y;
                        BackgroundColor3 = rgb(0, 0, 0),
                        CornerRadius = UDim.new(0, 10)
                    });
                    
                    items[ "dropdown_shading" ] = library:create( "Frame" , {
                        Parent = items[ "dropdown_holder" ];
                        Size = dim2(1, -2, 0, -2);
                        Name = "\0";
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.Y;
                        BackgroundColor3 = rgb(255, 255, 255),
                        CornerRadius = UDim.new(0, 9)
                    });
                    
                    library:create( "UIGradient" , {
                        Rotation = 90;
                        Parent = items[ "dropdown_shading" ];
                        Color = rgbseq{rgbkey(0, rgb(33, 33, 33)), rgbkey(1, rgb(8, 8, 8))}
                    });
                    
                    library:create( "UIListLayout" , {
                        Parent = items[ "dropdown_shading" ];
                        Padding = dim(0, 5);
                        SortOrder = Enum.SortOrder.LayoutOrder
                    });
                    
                    library:create( "UIPadding" , {
                        PaddingBottom = dim(0, 5);
                        PaddingTop = dim(0, 5);
                        Parent = items[ "dropdown_shading" ]
                    });            
                -- 
            end 

            function cfg.render_option(text)
                local button = library:create( "TextButton" , {
                    FontFace = library.font;
                    TextColor3 = theme.muted or rgb(178, 178, 178);
                    BorderColor3 = theme.border or rgb(0, 0, 0);
                    Text = text;
                    Parent = items[ "dropdown_shading" ];
                    Size = dim2(1, 0, 0, 0);
                    BackgroundTransparency = 1;
                    TextXAlignment = Enum.TextXAlignment.Center;
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    TextSize = 10;
                    BackgroundColor3 = theme.panel or rgb(255, 255, 255),
                    CornerRadius = UDim.new(0, 6)
                });
                
                library:create( "UIStroke" , {
                    Parent = button
                });
                
                library:create( "UIPadding" , {
                    Parent = button
                });

                return button
            end
            
            function cfg.set_visible(bool)
                local a = bool and cfg.y_size or 0
                items[ "dropdown_holder" ].Visible = bool 
                items[ "arrow" ].Rotation = bool and 180 or 0

                items[ "dropdown_holder" ].Size = dim2(0, items.dropdown_outline.AbsoluteSize.X, 0, 0)
                items[ "dropdown_holder" ].Position = dim2(0, items.dropdown_outline.AbsolutePosition.X, 0, items.dropdown_outline.AbsolutePosition.Y + 75)
                
                library.current = cfg
            end
            
            function cfg.set(value)
                local selected = {}
                local isTable = type(value) == "table"

                for _, option in cfg.option_instances do 
                    if option.Text == value or (isTable and find(value, option.Text)) then 
                        insert(selected, option.Text)
                        cfg.multi_items = selected
                        option.TextColor3 = rgb(255, 255, 255)
                    else
                        option.TextColor3 = rgb(174, 174, 174)
                    end
                end

                items.inner_text.Text = if isTable then concat(selected, ", ") else selected[1] or ""
                flags[cfg.flag] = if isTable then selected else selected[1]
                
                cfg.callback(flags[cfg.flag]) 
            end
            
            function cfg.refresh_options(list) 
                for _, option in cfg.option_instances do 
                    option:Destroy() 
                end
                
                cfg.option_instances = {} 

                for _, option in list do 
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
            
            flags[cfg.flag] = {} 
            config_flags[cfg.flag] = cfg.set
            
            cfg.refresh_options(cfg.options)
            cfg.set(cfg.default)

            local set = setmetatable(cfg, library)

            if cfg.name then 
                set:Label({name = cfg.name, padding_bottom = 2})
            end 

            return set
        end

        function library:Label(options)
            local cfg = {
                name = options.Name or options.name or "Label",
                theme = library:resolve_theme(options.theme or options.Theme or library.theme),

                -- ignore
                padding_top = options.PaddingTop or options.padding_top or 0; -- used because roblox cant make proper layouts
                padding_top = options.PaddingBottom or options.padding_bottom or 0;

                items = {};
            }

            local theme = cfg.theme
            local items = cfg.items; do 
                items[ "object" ] = library:create( "TextButton" , {
                    Parent = self.items.object or self.items.elements;
                    Text = "";
                    Name = "\0";
                    BackgroundTransparency = 1;
                    Size = dim2(1, 0, 0, 12);
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });

                items.text = library:create( "TextLabel" , {
                    FontFace = library.font;
                    TextColor3 = theme.muted or rgb(178, 178, 178);
                    BorderColor3 = theme.border or rgb(0, 0, 0);
                    Text = cfg.name;
                    RichText = true;
                    Parent = items.object;
                    BackgroundTransparency = 1;
                    Position = dim2(0, 12, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    TextSize = 10;
                    BackgroundColor3 = theme.panel or rgb(255, 255, 255)
                });

                library:create( "UIListLayout" , {
                    Parent = items[ "object" ];
                    Padding = dim(0, 5);
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    FillDirection = Enum.FillDirection.Horizontal
                });

                library:create( "UIStroke" , {
                    Parent = items.text
                });

                library:create( "UIPadding" , {
                    PaddingLeft = dim(0, 1);
                    PaddingTop = dim(0, cfg.padding_top);
                    PaddingBottom = dim(0, cfg.padding_bottom);
                    Parent = items.text
                });
            end 

            function cfg.set(text)
                items.text.Text = text
            end

            return setmetatable(cfg, library)
        end 
        
        function library:Colorpicker(options) 
            local cfg = {
                -- options
                name = options.name or options.Name or "", 
                flag = options.flag or options.Flag or options.name or options.Name or "please set me a flag 🥺",
                color = options.color or options.Color or color(1, 1, 1), -- Default to white color if not provided
                alpha = (options.alpha and 1 - options.alpha) or (options.Alpha and 1 - options.Alpha) or 0,
                callback = options.callback or options.Callback or function() end,

                -- ignore
                open = false, 
                items = {};
            }

            local dragging_sat = false 
            local dragging_hue = false 
            local dragging_alpha = false 

            local h, s, v = cfg.color:ToHSV() 
            local a = cfg.alpha 

            flags[cfg.flag] = {Color = cfg.color, Transparency = cfg.alpha}

            local items = cfg.items; do 
                -- Component
                    items[ "gear_holder" ] = library:create( "TextButton" , {
                        Parent = self.items.object;
                        AutoButtonColor = false;
                        Text = "";
                        BackgroundTransparency = 1;
                        Name = "\0";
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(0, 12, 0, 12);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    
                    items[ "gear" ] = library:create( "ImageLabel" , {
                        ImageColor3 = rgb(178, 178, 178);
                        BorderColor3 = rgb(0, 0, 0);
                        Parent = items[ "gear_holder" ];
                        Image = "rbxassetid://99473719385675";
                        BackgroundTransparency = 1;
                        Name = "\0";
                        Size = dim2(0, 12, 0, 12);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    
                    library:create( "UIPadding" , {
                        Parent = items[ "gear_holder" ];
                        PaddingTop = dim(0, -1)
                    });                
                --
                
                -- Colorpicker
                    items[ "colorpicker_outline" ] = library:create( "Frame" , {
                        Parent = library.items;
                        Visible = false;
                        Size = dim2(0, 161, 0, 180);
                        Name = "\0";
                        BorderColor3 = rgb(0, 0, 0);
                        ZIndex = 100;
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });
                    
                    items[ "_" ] = library:create( "UICorner" , {
                        Parent = items[ "colorpicker_outline" ];
                        Name = "\0";
                        CornerRadius = dim(0, 0)
                    });
                    
                    items[ "colorpicker_inline" ] = library:create( "Frame" , {
                        Parent = items[ "colorpicker_outline" ];
                        Size = dim2(1, -2, 1, -2);
                        Name = "\0";
                        ClipsDescendants = true;
                        BorderColor3 = rgb(0, 0, 0);
                        Position = dim2(0, 1, 0, 1);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(32, 32, 32)
                    });
                    
                    items[ "_" ] = library:create( "UICorner" , {
                        Parent = items[ "colorpicker_inline" ];
                        Name = "\0";
                        CornerRadius = dim(0, 0)
                    });
                    
                    items[ "colorpicker_background" ] = library:create( "Frame" , {
                        Parent = items[ "colorpicker_inline" ];
                        Size = dim2(1, -2, 1, -2);
                        Name = "\0";
                        ClipsDescendants = true;
                        BorderColor3 = rgb(0, 0, 0);
                        Position = dim2(0, 1, 0, 1);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(8, 8, 8)
                    });
                    
                    items[ "_" ] = library:create( "UICorner" , {
                        Parent = items[ "colorpicker_background" ];
                        Name = "\0";
                        CornerRadius = dim(0, 0)
                    });
                    
                    items[ "_" ] = library:create( "UIPadding" , {
                        PaddingTop = dim(0, 18);
                        Name = "\0";
                        PaddingBottom = dim(0, 3);
                        Parent = items[ "colorpicker_background" ];
                        PaddingRight = dim(0, 3);
                        PaddingLeft = dim(0, 3)
                    });
                    
                    items[ "saturation_outline" ] = library:create( "TextButton" , {
                        Name = "\0";
                        AutoButtonColor = false;
                        Text = "";
                        Parent = items[ "colorpicker_background" ];
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -12, 1, -12);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });
                    
                    items[ "color_saturation" ] = library:create( "Frame" , {
                        Parent = items[ "saturation_outline" ];
                        Name = "\0";
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 39, 39)
                    });
                    
                    items[ "sat" ] = library:create( "Frame" , {
                        Parent = items[ "color_saturation" ];
                        Name = "\0";
                        Size = dim2(1, 0, 1, 0);
                        BorderColor3 = rgb(0, 0, 0);
                        ZIndex = 2;
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    
                    library:create( "UIGradient" , {
                        Rotation = 270;
                        Transparency = numseq{numkey(0, 0), numkey(1, 1)};
                        Parent = items[ "sat" ];
                        Color = rgbseq{rgbkey(0, rgb(0, 0, 0)), rgbkey(1, rgb(0, 0, 0))}
                    });
                    
                    items[ "satval_picker" ] = library:create( "Frame" , {
                        Parent = items[ "color_saturation" ];
                        Size = dim2(0, 3, 0, 3);
                        Name = "\0";
                        Position = dim2(0, 1, 0.5, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        ZIndex = 4;
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });
                    
                    items[ "_" ] = library:create( "Frame" , {
                        Parent = items[ "satval_picker" ];
                        Size = dim2(1, -2, 1, -2);
                        Name = "\0";
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        ZIndex = 2;
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    
                    items[ "val" ] = library:create( "Frame" , {
                        Name = "\0";
                        Parent = items[ "color_saturation" ];
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, 0, 1, 0);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    
                    library:create( "UIGradient" , {
                        Parent = items[ "val" ];
                        Transparency = numseq{numkey(0, 0), numkey(1, 1)}
                    });
                    
                    items[ "hue_slider" ] = library:create( "TextButton" , {
                        Parent = items[ "colorpicker_background" ];
                        Name = "\0";
                        AutoButtonColor = false;
                        Text = "";
                        Position = dim2(1, -10, 0, 0);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(0, 10, 1, -12);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });
                    
                    items[ "hue_components" ] = library:create( "Frame" , {
                        Parent = items[ "hue_slider" ];
                        Name = "\0";
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    
                    items[ "_" ] = library:create( "UIGradient" , {
                        Rotation = 270;
                        Parent = items[ "hue_components" ];
                        Name = "\0";
                        Color = rgbseq{rgbkey(0, rgb(255, 0, 0)), rgbkey(0.17, rgb(255, 255, 0)), rgbkey(0.33, rgb(0, 255, 0)), rgbkey(0.5, rgb(0, 255, 255)), rgbkey(0.67, rgb(0, 0, 255)), rgbkey(0.83, rgb(255, 0, 255)), rgbkey(1, rgb(255, 0, 0))}
                    });
                    
                    items[ "hue_picker" ] = library:create( "Frame" , {
                        Parent = items[ "hue_components" ];
                        Size = dim2(1, 2, 0, 3);
                        Name = "\0";
                        Position = dim2(0, -1, 0, -1);
                        BorderColor3 = rgb(0, 0, 0);
                        ZIndex = 4;
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });
                    
                    items[ "_" ] = library:create( "Frame" , {
                        Parent = items[ "hue_picker" ];
                        Size = dim2(1, -2, 1, -2);
                        Name = "\0";
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        ZIndex = 2;
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    
                    items[ "alpha_slider" ] = library:create( "TextButton" , {
                        Parent = items[ "colorpicker_background" ];
                        Name = "\0";
                        AutoButtonColor = false;
                        Text = "";
                        Position = dim2(0, 0, 1, -10);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -12, 0, 10);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });
                    
                    items[ "alpha_components" ] = library:create( "Frame" , {
                        Parent = items[ "alpha_slider" ];
                        Name = "\0";
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    
                    items[ "_" ] = library:create( "UIGradient" , {
                        Color = rgbseq{rgbkey(0, rgb(0, 0, 0)), rgbkey(1, rgb(255, 255, 255))};
                        Name = "\0";
                        Parent = items[ "alpha_components" ]
                    });
                    
                    items[ "alpha_picker" ] = library:create( "Frame" , {
                        Parent = items[ "alpha_components" ];
                        Size = dim2(0, 3, 1, 2);
                        Name = "\0";
                        Position = dim2(0, -1, 0, -1);
                        BorderColor3 = rgb(0, 0, 0);
                        ZIndex = 4;
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });
                    
                    items[ "_" ] = library:create( "Frame" , {
                        Parent = items[ "alpha_picker" ];
                        Size = dim2(1, -2, 1, -2);
                        Name = "\0";
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        ZIndex = 2;
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    
                    items[ "visualize_outline" ] = library:create( "Frame" , {
                        AnchorPoint = vec2(1, 1);
                        Parent = items[ "colorpicker_background" ];
                        Name = "\0";
                        Position = dim2(1, 0, 1, 0);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(0, 10, 0, 10);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });
                    
                    items[ "visualizer" ] = library:create( "Frame" , {
                        Parent = items[ "visualize_outline" ];
                        Name = "\0";
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(123, 83, 255)
                    });
                    
                    items[ "alpha_visualizer" ] = library:create( "ImageLabel" , {
                        ScaleType = Enum.ScaleType.Tile;
                        ImageTransparency = 0.41999998688697815;
                        BorderColor3 = rgb(0, 0, 0);
                        Parent = items[ "visualizer" ];
                        Name = "\0";
                        Image = "rbxassetid://18274452449";
                        BackgroundTransparency = 1;
                        Size = dim2(1, 0, 1, 0);
                        
                        TileSize = dim2(0, 2, 0, 2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    
                    items[ "gear" ] = library:create( "ImageButton" , {
                        ImageColor3 = rgb(178, 178, 178);
                        AutoButtonColor = false;
                        BorderColor3 = rgb(0, 0, 0);
                        Parent = items[ "colorpicker_inline" ];
                        Name = "\0";
                        Image = "rbxassetid://99473719385675";
                        BackgroundTransparency = 1;
                        Position = dim2(0, 4, 0, 3);
                        
                        Size = dim2(0, 12, 0, 12);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    
                    library:create( "TextLabel" , {
                        FontFace = library.font;
                        TextColor3 = rgb(178, 178, 178);
                        BorderColor3 = rgb(0, 0, 0);
                        Text = cfg.name;
                        Parent = items[ "colorpicker_outline" ];
                        BackgroundTransparency = 1;
                        Position = dim2(0, 20, 0, 5);
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.XY;
                        TextSize = 10;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    
                    library:create( "UIStroke" , {
                        Parent = items[ "TextLabel" ]
                    });
                    
                    library:create( "UIPadding" , {
                        PaddingLeft = dim(0, 1);
                        Parent = items[ "TextLabel" ]
                    });                
                --  
            end;

            function cfg.set_visible(bool) 
                items.colorpicker_outline.Visible = bool
                items.colorpicker_outline.Position = dim2(0, items.gear_holder.AbsolutePosition.X - 5, 0, items.gear_holder.AbsolutePosition.Y + items.gear_holder.AbsoluteSize.Y + 60 - 19)

                library.current = cfg
            end

            function cfg.set(color, alpha)
                if color then
                    h, s, v = color:ToHSV()
                end
                
                if alpha then 
                    a = alpha
                end 
                
                local Color = Color3.fromHSV(h, s, v)
                
                items.hue_picker.Position = dim2(0, -1, 1 - h, -1)
                items.alpha_picker.Position = dim2(1 - a, -1, 0, -1)
                items.satval_picker.Position = dim2(s, -1, 1 - v, -1)

                items.color_saturation.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                items.color_saturation.BackgroundColor3 = Color3.fromHSV(h, 1, 1)

                items.alpha_visualizer.ImageTransparency = 1 - a 
                items.visualizer.BackgroundColor3 = Color

                flags[cfg.flag] = {
                    Color = Color;
                    Transparency = a 
                }
                
                cfg.callback(Color, a)
            end

            function cfg.update_color() 
                local mouse = uis:GetMouseLocation() 
                local offset = vec2(mouse.X, mouse.Y - gui_offset) 

                if dragging_sat then	
                    s = math.clamp((offset - items.sat.AbsolutePosition).X / items.sat.AbsoluteSize.X, 0, 1)
                    v = 1 - math.clamp((offset - items.val.AbsolutePosition).Y / items.val.AbsoluteSize.Y, 0, 1)
                elseif dragging_hue then
                    h = 1 - math.clamp((offset - items.hue_slider.AbsolutePosition).Y / items.hue_slider.AbsoluteSize.Y, 0, 1)
                elseif dragging_alpha then
                    a = 1 - math.clamp((offset - items.alpha_slider.AbsolutePosition).X / items.alpha_slider.AbsoluteSize.X, 0, 1)
                end

                cfg.set(nil, nil)
            end

            items.gear_holder.MouseButton1Click:Connect(function()
                cfg.set_visible(true)            
            end)

            items.gear.MouseButton1Click:Connect(function()
                cfg.set_visible(false)            
            end)

            uis.InputChanged:Connect(function(input)
                if (dragging_sat or dragging_hue or dragging_alpha) and input.UserInputType == Enum.UserInputType.MouseMovement then
                    cfg.update_color() 
                end
            end)

            library:connection(uis.InputEnded, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging_sat = false
                    dragging_hue = false
                    dragging_alpha = false  

                    if not (library:mouse_in_frame(items.gear_holder) or library:mouse_in_frame(items.colorpicker_outline)) then 
                        cfg.open = false
                        cfg.set_visible(false)
                    end
                end
            end)

            items.alpha_slider.MouseButton1Down:Connect(function()
                dragging_alpha = true 
            end)
            
            items.hue_slider.MouseButton1Down:Connect(function()
                dragging_hue = true 
            end)
            
            items.saturation_outline.MouseButton1Down:Connect(function()
                print("hiu")
                dragging_sat = true  
            end)

            cfg.set(cfg.color, cfg.alpha)
            config_flags[cfg.flag] = cfg.set

            return setmetatable(cfg, library)
        end 

        function library:Textbox(options) 
            local cfg = {
                name = options.name or options.Name or "TextBox",
                placeholder = options.placeholder or options.PlaceHolder or "type here...",
                default = options.default or options.Default or "",
                flag = options.flag or options.name or "please set me a flag 🥺",
                callback = options.callback or options.Callback or function() end,
                visible = options.visible or true,
                items = {};
            }

            flags[cfg.flag] = cfg.default

            local items = cfg.items; do 
                items[ "object" ] = library:create( "Frame" , {
                    BorderColor3 = rgb(0, 0, 0);
                    Parent = self.items[ "elements" ];
                    BackgroundTransparency = 1;
                    Name = "\0";
                    Size = dim2(1, 0, 0, 16);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                items[ "textbox_outline" ] = library:create( "Frame" , {
                    Name = "\0";
                    Parent = items[ "object" ];
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, 0, 0, 20);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(0, 0, 0)
                });
                
                items[ "textbox_shading" ] = library:create( "Frame" , {
                    Parent = items[ "textbox_outline" ];
                    Name = "\0";
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                items[ "textbox" ] = library:create( "TextBox" , {
                    FontFace = library.font;
                    Active = false;
                    Selectable = false;
                    PlaceholderText = cfg.placeholder;
                    TextSize = 10;
                    Size = dim2(1, 0, 1, 0);
                    TextColor3 = rgb(180, 180, 180);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "";
                    Parent = items[ "textbox_shading" ];
                    Name = "\0";
                    CursorPosition = -1;
                    BackgroundTransparency = 1;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    BorderSizePixel = 0;
                    TextWrapped = true;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                library:create( "UIPadding" , {
                    PaddingLeft = dim(0, 7);
                    Parent = items[ "textbox" ]
                });
                
                library:create( "UIStroke" , {
                    Parent = items[ "textbox" ]
                });
                
                library:create( "UIGradient" , {
                    Rotation = 90;
                    Parent = items[ "textbox_shading" ];
                    Color = rgbseq{rgbkey(0, rgb(33, 33, 33)), rgbkey(1, rgb(8, 8, 8))}
                });
                
                library:create( "UIListLayout" , {
                    Parent = items[ "object" ];
                    Padding = dim(0, 5);
                    SortOrder = Enum.SortOrder.LayoutOrder
                });                
            end 
            
            function cfg.set(text) 
                if type(text) == "boolean" then 
                    return 
                end 

                flags[cfg.flag] = text

                items[ "textbox" ].Text = text

                cfg.callback(text)
            end 
            
            items[ "textbox" ]:GetPropertyChangedSignal("Text"):Connect(function()
                cfg.set(items[ "textbox" ].Text) 
            end)

            items[ "textbox" ].Focused:Connect(function()
                library:tween(items[ "textbox" ], {TextColor3 = rgb(245, 245, 245)})
            end)

            items[ "textbox" ].FocusLost:Connect(function()
                library:tween(items[ "textbox" ], {TextColor3 = rgb(72, 72, 72)})
            end)
                
            if cfg.default then 
                cfg.set(cfg.default) 
            end

            config_flags[cfg.flag] = cfg.set

            return setmetatable(cfg, library)
        end

        function library:Keybind(options) 
            local cfg = {
                -- options
                flag = options.flag or options.Flag or options.name or options.Name or "please set me a flag 🥺",
                callback = options.callback or options.Callback or function() end,
                name = options.name or options.Name or nil, 
                key = options.key or options.Key or nil, 
                mode = options.mode or options.Mode or "Toggle",
                active = options.default or options.Default or false, 

                -- ignore
                open = false,
                binding = nil, 
                hold_instances = {},
                items = {};
            }

            flags[cfg.flag] = {
                mode = cfg.mode,
                key = cfg.key, 
                active = cfg.active
            }

            local items = cfg.items; do 
                -- Component
                    items.text_label = library:create( "TextButton" , {
                        FontFace = library.font;
                        AutoButtonColor = false;
                        TextColor3 = rgb(178, 178, 178);
                        BorderColor3 = rgb(0, 0, 0);
                        Text = "J";
                        Parent = self.items.object;
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.XY;
                        TextSize = 10;
                        BackgroundColor3 = rgb(38, 38, 38)
                    });

                    library:create( "UIStroke" , {
                        Parent = items.text_label
                    });

                    library:create( "UIPadding" , {
                        Parent = items.text_label;
                        PaddingRight = dim(0, 4);
                        PaddingLeft = dim(0, 4)
                    });

                    if cfg.name then
                        self:Label({Name = cfg.name})
                    end 
                -- 
                
                -- Mode Holder
                    items[ "modes" ] = library:create( "Frame" , {
                        Parent = library.items;
                        Visible = false;
                        Size = dim2(0, 114, 0, 0);
                        Name = "\0";
                        BorderColor3 = rgb(0, 0, 0);
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.Y;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });
                    
                    items[ "mode_shading" ] = library:create( "Frame" , {
                        Parent = items[ "modes" ];
                        Size = dim2(0, -2, 0, -2);
                        Name = "\0";
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.XY;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    
                    library:create( "UIGradient" , {
                        Rotation = 90;
                        Parent = items[ "mode_shading" ];
                        Color = rgbseq{rgbkey(0, rgb(33, 33, 33)), rgbkey(1, rgb(8, 8, 8))}
                    });
                    
                    library:create( "UIListLayout" , {
                        Parent = items[ "mode_shading" ];
                        Padding = dim(0, 5);
                        SortOrder = Enum.SortOrder.LayoutOrder
                    });
                    
                    library:create( "UIPadding" , {
                        PaddingBottom = dim(0, 5);
                        PaddingTop = dim(0, 5);
                        Parent = items[ "mode_shading" ]
                    });
                    
                    library:create( "UIPadding" , {
                        PaddingRight = dim(0, 1);
                        Parent = items[ "modes" ]
                    });
                    
                
                    local options = {"Hold", "Toggle", "Always"}
                    
                    for _,option in options do
                        local name = library:create( "TextButton" , {
                            FontFace = library.font;
                            AutoButtonColor = false;
                            TextColor3 = rgb(178, 178, 178);
                            BorderColor3 = rgb(0, 0, 0);
                            Text = option;
                            Parent = items[ "mode_shading" ];
                            BackgroundTransparency = 1;
                            Size = dim2(1, 0, 0, 0);
                            BorderSizePixel = 0;
                            AutomaticSize = Enum.AutomaticSize.XY;
                            TextSize = 10;
                            BackgroundColor3 = rgb(255, 255, 255)
                        }); cfg.hold_instances[option] = name
                        
                        library:create( "UIStroke" , {
                            Parent = items[ "TextLabel" ]
                        });
                        
                        library:create( "UIPadding" , {
                            PaddingLeft = dim(0, 5);
                            Parent = items[ "TextLabel" ]
                        });
                                                
                        -- cfg.y_size += name.AbsoluteSize.Y

                        library:create( "UIPadding" , {
                            Parent = name;
                            PaddingTop = dim(0, 1);
                            PaddingRight = dim(0, 5);
                            PaddingLeft = dim(0, 5)
                        });

                        name.MouseButton1Click:Connect(function()
                            cfg.set(option)
                            cfg.set_visible(false)
                            cfg.open = false
                        end)
                    end
                -- 
            end 
            
            function cfg.modify_mode_color(path) -- ts so frikin tuff 💀
                for _,v in cfg.hold_instances do 
                    v.TextColor3 = rgb(178, 178, 178)
                end 

                cfg.hold_instances[path].TextColor3 = rgb(255, 255, 255)
            end

            function cfg.set_mode(mode) 
                cfg.mode = mode 

                if mode == "Always" then
                    cfg.set(true)
                elseif mode == "Hold" then
                    cfg.set(false)
                end

                flags[cfg.flag]["mode"] = mode
                cfg.modify_mode_color(mode)
            end 

            function cfg.set(input)
                if type(input) == "boolean" then 
                    cfg.active = input

                    if cfg.mode == "Always" then 
                        cfg.active = true
                    end
                elseif tostring(input):find("Enum") then 
                    input = input.Name == "Escape" and "NONE" or input
                    
                    cfg.key = input or "NONE"	
                elseif find({"Toggle", "Hold", "Always"}, input) then 
                    if input == "Always" then 
                        cfg.active = true 
                    end 

                    cfg.mode = input
                    cfg.set_mode(cfg.mode) 
                elseif type(input) == "table" then 
                    input.key = type(input.key) == "string" and input.key ~= "NONE" and library:convert_enum(input.key) or input.key
                    input.key = input.key == Enum.KeyCode.Escape and "NONE" or input.key

                    cfg.key = input.key or "NONE"
                    cfg.mode = input.mode or "Toggle"

                    if input.active then
                        cfg.active = input.active
                    end

                    cfg.set_mode(cfg.mode) 
                end 

                cfg.callback(cfg.active)

                local text = tostring(cfg.key) ~= "Enums" and (keys[cfg.key] or tostring(cfg.key):gsub("Enum.", "")) or nil
                local __text = text and (tostring(text):gsub("KeyCode.", ""):gsub("UserInputType.", ""))
                
                items.text_label.Text = __text

                flags[cfg.flag] = {
                    mode = cfg.mode,
                    key = cfg.key, 
                    active = cfg.active
                }
            end

            function cfg.set_visible(bool)
                -- local size = bool and cfg.y_size or 0
                -- library:tween(items.object, {Size = dim_offset(items.text_label.AbsoluteSize.X, size)})
                items.modes.Visible = bool 
                items.modes.Position = dim_offset(items.text_label.AbsolutePosition.X + items.text_label.AbsoluteSize.X + 5, items.text_label.AbsolutePosition.Y + 58)

                library.current = cfg
            end
            
            items.text_label.MouseButton1Down:Connect(function()
                task.wait()
                items.text_label.Text = "..."	

                cfg.binding = library:connection(uis.InputBegan, function(keycode, game_event)  
                    cfg.set(keycode.KeyCode ~= Enum.KeyCode.Unknown and keycode.KeyCode or keycode.UserInputType)
                    
                    cfg.binding:Disconnect() 
                    cfg.binding = nil
                end)
            end)

            items.text_label.MouseButton2Down:Connect(function()
                cfg.open = not cfg.open 

                cfg.set_visible(cfg.open)
            end)

            library:connection(uis.InputBegan, function(input, game_event) 
                if not game_event then
                    local selected_key = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType

                    if selected_key == cfg.key then 
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
                if game_event then 
                    return 
                end 

                local selected_key = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType
    
                if selected_key == cfg.key then
                    if cfg.mode == "Hold" then 
                        cfg.set(false)
                    end
                end
            end)

            library:connection(uis.InputEnded, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if not (library:mouse_in_frame(items[ "modes" ]) or library:mouse_in_frame(items.text_label)) then 
                        cfg.open = false
                        cfg.set_visible(false)
                    end
                end
            end)
            
            cfg.set({mode = cfg.mode, active = cfg.active, key = cfg.key})           
            config_flags[cfg.flag] = cfg.set

            return setmetatable(cfg, library)
        end

        function library:Button(options) 
            local cfg = {
                -- options
                name = options.name or options.Name or "TextBox",
                callback = options.callback or options.Callback or function() end,

                -- ignore
                items = {};
            }
            
            local items = cfg.items; do 
                items[ "button" ] = library:create( "TextButton" , {
                    Parent = self.items[ "elements" ];
                    Name = "\0";
                    AutoButtonColor = false;
                    BackgroundTransparency = 1;
                    Size = dim2(1, 0, 0, 16);
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                items[ "button_outline" ] = library:create( "Frame" , {
                    Name = "\0";
                    Parent = items[ "button" ];
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, 0, 0, 20);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(0, 0, 0)
                });
                
                items[ "button_shading" ] = library:create( "Frame" , {
                    Parent = items[ "button_outline" ];
                    Name = "\0";
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                library:create( "UIGradient" , {
                    Rotation = 90;
                    Parent = items[ "button_shading" ];
                    Color = rgbseq{rgbkey(0, rgb(33, 33, 33)), rgbkey(1, rgb(8, 8, 8))}
                });
                
                items[ "button_text" ] = library:create( "TextLabel" , {
                    FontFace = library.font;
                    TextColor3 = rgb(178, 178, 178);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = cfg.name;
                    Parent = items[ "button_shading" ];
                    Name = "\0";
                    BackgroundTransparency = 1;
                    Size = dim2(1, 0, 1, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    TextSize = 10;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                library:create( "UIStroke" , {
                    Parent = items[ "button_text" ]
                });
                
                library:create( "UIListLayout" , {
                    Parent = items[ "button" ];
                    Padding = dim(0, 5);
                    SortOrder = Enum.SortOrder.LayoutOrder
                });                             
            end 

            items[ "button" ].MouseButton1Click:Connect(function()
                cfg.callback()

                items[ "button_text" ].TextColor3 = rgb(255, 255, 255) 
                library:tween(items[ "button_text" ], {TextColor3 = rgb(178, 178, 178)})
            end)
            
            return setmetatable(cfg, library)
        end

        function library:list(properties) 
            local cfg = {
                items = {};
                options = properties.options or {"1", "2", "3"};
                flag = properties.flag or options.name or "please set me a flag 🥺";    
                callback = properties.callback or function() end;
                data_store = {};        
                current_element;
            }

            local items = cfg.items; do
                items[ "list" ] = library:create( "Frame" , {
                    Parent = self.items[ "elements" ];
                    BackgroundTransparency = 1;
                    Name = "\0";
                    Size = dim2(1, 0, 0, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                library:create( "UIListLayout" , {
                    Parent = items[ "list" ];
                    Padding = dim(0, 10);
                    SortOrder = Enum.SortOrder.LayoutOrder
                });
                
                library:create( "UIPadding" , {
                    Parent = items[ "list" ];
                    PaddingRight = dim(0, 4);
                    PaddingLeft = dim(0, 4)
                });
            end 

            function cfg.refresh_options(options_to_refresh) -- ignore goofy parameter
                for _,option in cfg.data_store do 
                    option:Destroy()
                end

                for _, option_data in options_to_refresh do -- haha u skids no next >_<
                    local button = library:create( "TextButton" , {
                        FontFace = fonts.small;
                        TextColor3 = rgb(0, 0, 0);
                        BorderColor3 = rgb(0, 0, 0);
                        Text = "";
                        AutoButtonColor = false;
                        AnchorPoint = vec2(1, 0);
                        Parent = items[ "list" ];
                        Name = "\0";
                        Position = dim2(1, 0, 0, 0);
                        Size = dim2(1, 0, 0, 30);
                        BorderSizePixel = 0;
                        TextSize = 14;
                        BackgroundColor3 = rgb(33, 33, 35)
                    }); cfg.data_store[#cfg.data_store + 1] = button;

                    local name = library:create( "TextLabel" , {
                        FontFace = library.font;
                        TextColor3 = rgb(72, 72, 73);
                        BorderColor3 = rgb(0, 0, 0);
                        Text = option_data;
                        Parent = button;
                        Name = "\0";
                        BackgroundTransparency = 1;
                        Size = dim2(1, 0, 1, 0);
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.XY;
                        TextSize = 14;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    
                    library:create( "UICorner" , {
                        Parent = button;
                        CornerRadius = dim(0, 3)
                    });     

                    button.MouseButton1Click:Connect(function()
                        local current = cfg.current_element 
                        if current and current ~= name then 
                            library:tween(current, {TextColor3 = rgb(72, 72, 72)})
                        end

                        flags[cfg.flag] = option_data
                        cfg.callback(option_data)
                        library:tween(name, {TextColor3 = rgb(245, 245, 245)})
                        cfg.current_element = name
                    end)

                    name.MouseEnter:Connect(function()
                        if cfg.current_element == name then 
                            return 
                        end 

                        library:tween(name, {TextColor3 = rgb(140, 140, 140)})
                    end)

                    name.MouseLeave:Connect(function()
                        if cfg.current_element == name then 
                            return 
                        end 

                        library:tween(name, {TextColor3 = rgb(72, 72, 72)})
                    end)
                end
            end

            cfg.refresh_options(cfg.options)

            return setmetatable(cfg, library)
        end 

        function library:init_config(window) 
            local textbox;
            local main = window:Tab({name = "Configs", icon = "rbxassetid://72506063321241"})
            local section = main:Section({name = "Settings", side = "right", size = 1, default = true})
            config_holder = section:Dropdown({Name = "Configs", options = {"Report", "This", "Error", "To", "Finobe"}, callback = function(option) if textbox then textbox.set(option) end end, flag = "config_name_list"}); library:update_config_list()
            textbox = section:Textbox({name = "Config name:", flag = "config_name_text"})
            section:Button({name = "Save", callback = function() writefile(library.directory .. "/configs/" .. flags["config_name_text"] .. ".cfg", library:get_config()) library:update_config_list() end}) 
            section:Button({name = "Load", callback = function() library:load_config(readfile(library.directory .. "/configs/" .. flags["config_name_text"] .. ".cfg"))  library:update_config_list() end})
            section:Button({name = "Delete", callback = function() delfile(library.directory .. "/configs/" .. flags["config_name_text"] .. ".cfg")  library:update_config_list() end})
            
            section:Label({Name = "UI Bind"}):Keybind({callback = function(bool) window.toggle_menu(bool) print(window.tweening) end, default = false})
        end
    --

    -- Notification library
		local notifications = library.notifications

		function notifications:refresh_notifs() 
			local yOffset = 50
			for i, v in notifications.notifs do
				local Position = vec2(20, yOffset)
				tween_service:Create(v, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = dim_offset(Position.X, Position.Y)}):Play()
				yOffset = yOffset + v.AbsoluteSize.Y + 10
			end
		end
		
		function notifications:fade(path, is_fading)
			local fading = is_fading and 1 or 0 
			
			tween_service:Create(path, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = fading}):Play()

			for _, instance in path:GetDescendants() do 
				if instance:IsA("UIStroke") then
					tween_service:Create(instance, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Transparency = fading}):Play()
				elseif instance:IsA("TextLabel") then
					tween_service:Create(instance, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = fading}):Play()
				elseif instance:IsA("Frame") then
					tween_service:Create(instance, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = fading}):Play()
				end
			end
		end 

		function notifications:create_notification(options)
			local cfg = {
				name = options.name or "Hit: q3sm (finobe) in the Head for 100 Damage!",
				color = options.color or rgb(255, 255, 255);
				clickable = options.click or false;
			}
			
			-- Instances
				local outline = library:create("TextButton", {
					Parent = library.items;
					Size = dim2(0, 0, 0, 0);
					BorderColor3 = rgb(0, 0, 0);
					BorderSizePixel = 0;
					AutoButtonColor = false;
					Text = "";
					AutomaticSize = Enum.AutomaticSize.XY;
					BackgroundColor3 = rgb(46, 46, 46)
				});

				local inline = library:create("Frame", {
					Parent = outline;
					Position = dim2(0, 1, 0, 1);
					BorderColor3 = rgb(0, 0, 0);
					BorderSizePixel = 0;
					AutomaticSize = Enum.AutomaticSize.XY;
					BackgroundColor3 = rgb(21, 21, 21)
				});	
				
				local uigradient = library:create("UIGradient", {
					Color = rgbseq{rgbkey(0, rgb(255, 0, 0)), rgbkey(0.17, rgb(255, 255, 0)), rgbkey(0.33, rgb(0, 255, 0)), rgbkey(0.5, rgb(0, 255, 255)), rgbkey(0.67, rgb(0, 0, 255)), rgbkey(0.83, rgb(255, 0, 255)), rgbkey(1, rgb(255, 0, 0))};
					Transparency = numseq{numkey(0, -1), numkey(1, -1)};
					Parent = menu_title
				});
				
				library:create("UIPadding", {
					PaddingTop = dim(0, 7);
					PaddingBottom = dim(0, 6);
					Parent = inline;
					PaddingRight = dim(0, 8);
					PaddingLeft = dim(0, 4)
				});
				
				local misc_text = library:create("TextLabel", {
					FontFace = library.font;
					Parent = inline;
					LineHeight = 1.75;
					TextColor3 = rgb(255, 255, 255);
					BorderColor3 = rgb(0, 0, 0);
					Text = cfg.name; -- string.format("[ cht name ] %s", cfg.name);
					AutomaticSize = Enum.AutomaticSize.XY;
					Size = dim2(1, -4, 1, 0);
					Position = dim2(0, 4, 0, -2);
					BackgroundTransparency = 1;
					TextXAlignment = Enum.TextXAlignment.Left;
					BorderSizePixel = 0;
					ZIndex = 2;
					TextSize = 10;
					BackgroundColor3 = rgb(255, 255, 255)
				});
				
				library:create("UIPadding", {
					PaddingBottom = dim(0, 1);
					PaddingRight = dim(0, 1);
					Parent = outline
				});

				local line = library:create( "Frame" , {
					Parent = outline;
					Name = "\0";
					Position = dim2(0, 1, 1, -1);
					BorderColor3 = rgb(0, 0, 0);
					Size = dim2(0, 0, 0, 1);
					BorderSizePixel = 0;
					BackgroundColor3 = cfg.color
				});
				
				local accent = library:create( "Frame" , {
					Parent = outline;
					Name = "\0";
					Position = dim2(0, 1, 0, 1);
					BorderColor3 = rgb(0, 0, 0);
					Size = dim2(0, 1, 1, -1);
					BorderSizePixel = 0;
					BackgroundColor3 = cfg.color
				});
			-- 
			
			local index = #notifications.notifs + 1
			notifications.notifs[index] = outline
			
			notifications:refresh_notifs()
			tween_service:Create(outline, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {AnchorPoint = vec2(0, 0)}):Play()
			
			for _, obj in outline:GetDescendants() do
                if obj:IsA("Frame") or obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
                    library:fade(obj, "BackgroundTransparency", true)
        
                elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
                    library:fade(obj, "TextTransparency", true)
                    
                elseif obj:IsA("UIStroke") then
                    library:fade(obj, "Transparency", true)
        
                elseif obj:IsA("ScrollingFrame") then
                    library:fade(obj, "ScrollBarImageTransparency", true)
                end
            end
            print("fade1")

			outline.Position = dim2(0, 20, 0, #notifications.notifs * 20);

			if cfg.clickable then 
				outline.MouseButton1Click:Connect(function()
					notifications.notifs[index] = nil
					task.wait(1)
					outline:Destroy() 
					notifications:refresh_notifs()
				end)
			else 
                -- booty code
				task.spawn(function()
					tween_service:Create(line, TweenInfo.new(3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = dim2(1, -1, 0, 1)}):Play()
					task.wait(5)
                    print("fade2")
					notifications.notifs[index] = nil
					for _, obj in outline:GetDescendants() do
                        if obj:IsA("Frame") or obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
                            library:fade(obj, "BackgroundTransparency", false)
                
                        elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
                            library:fade(obj, "TextTransparency", false)
                
                        elseif obj:IsA("UIStroke") then
                            library:fade(obj, "Transparency", false)
                
                        elseif obj:IsA("ScrollingFrame") then
                            library:fade(obj, "ScrollBarImageTransparency", false)
                        end
                    end
					task.wait(1)
					outline:Destroy() 
					notifications:refresh_notifs()
				end)
			end
		end
	-- 
-- 

return library, notifications