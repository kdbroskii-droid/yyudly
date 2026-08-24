-- yyudly.lua
-- yyudly UI Library
-- Made for Roblox Studio experiences

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local yyudly = {}
yyudly.__index = yyudly

yyudly.Version = "1.0.0"

yyudly.Theme = {
    Background = Color3.fromRGB(18, 18, 22),
    Sidebar = Color3.fromRGB(14, 14, 18),
    Element = Color3.fromRGB(27, 27, 33),
    ElementHover = Color3.fromRGB(35, 35, 42),

    Accent = Color3.fromRGB(125, 85, 255),

    Text = Color3.fromRGB(240, 240, 245),
    SubText = Color3.fromRGB(160, 160, 170),

    Stroke = Color3.fromRGB(48, 48, 58)
}

--------------------------------------------------
-- Utility
--------------------------------------------------

local function Create(className, properties)
    local object = Instance.new(className)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    return object
end

local function AddCorner(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = object
    return corner
end

local function AddStroke(object, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness or 1
    stroke.Parent = object
    return stroke
end

local function Tween(object, properties, duration)
    return TweenService:Create(
        object,
        TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        properties
    )
end

--------------------------------------------------
-- Window
--------------------------------------------------

function yyudly:CreateWindow(settings)

    settings = settings or {}

    local windowName = settings.Name or "yyudly"
    local subtitleText = settings.Subtitle or "yyudly UI Library"
    local windowSize = settings.Size or UDim2.fromOffset(650, 430)

    local gui = Create("ScreenGui", {
        Name = "yyudly",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    --------------------------------------------------
    -- Main Window
    --------------------------------------------------

    local main = Create("Frame", {
        Name = "Window",
        Size = windowSize,
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),

        BackgroundColor3 = yyudly.Theme.Background,
        BorderSizePixel = 0
    })

    main.Parent = gui

    AddCorner(main, 12)
    AddStroke(main, yyudly.Theme.Stroke, 1)

    --------------------------------------------------
    -- Top Bar
    --------------------------------------------------

    local topbar = Create("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, 55),
        BackgroundTransparency = 1
    })

    topbar.Parent = main

    local title = Create("TextLabel", {
        Position = UDim2.fromOffset(18, 8),
        Size = UDim2.new(1, -36, 0, 22),

        BackgroundTransparency = 1,

        Text = windowName,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = yyudly.Theme.Text,

        TextXAlignment = Enum.TextXAlignment.Left
    })

    title.Parent = topbar

    local subtitle = Create("TextLabel", {
        Position = UDim2.fromOffset(19, 30),
        Size = UDim2.new(1, -38, 0, 16),

        BackgroundTransparency = 1,

        Text = subtitleText,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = yyudly.Theme.SubText,

        TextXAlignment = Enum.TextXAlignment.Left
    })

    subtitle.Parent = topbar

    --------------------------------------------------
    -- Sidebar
    --------------------------------------------------

    local sidebar = Create("Frame", {
        Name = "Sidebar",

        Position = UDim2.fromOffset(0, 55),
        Size = UDim2.new(0, 155, 1, -55),

        BackgroundColor3 = yyudly.Theme.Sidebar,
        BorderSizePixel = 0
    })

    sidebar.Parent = main

    AddCorner(sidebar, 12)

    local sidebarPadding = Instance.new("UIPadding")

    sidebarPadding.PaddingTop = UDim.new(0, 12)
    sidebarPadding.PaddingLeft = UDim.new(0, 10)
    sidebarPadding.PaddingRight = UDim.new(0, 10)

    sidebarPadding.Parent = sidebar

    local tabLayout = Instance.new("UIListLayout")

    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    tabLayout.Parent = sidebar

    --------------------------------------------------
    -- Content
    --------------------------------------------------

    local content = Create("Frame", {
        Name = "Content",

        Position = UDim2.fromOffset(155, 55),
        Size = UDim2.new(1, -155, 1, -55),

        BackgroundTransparency = 1
    })

    content.Parent = main

    local pages = {}
    local tabButtons = {}
    local currentTab

    --------------------------------------------------
    -- Notification Container
    --------------------------------------------------

    local notificationContainer = Create("Frame", {
        Name = "Notifications",

        Position = UDim2.new(1, -310, 0, 15),
        Size = UDim2.fromOffset(295, 0),

        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1
    })

    notificationContainer.Parent = gui

    local notificationLayout = Instance.new("UIListLayout")

    notificationLayout.Padding = UDim.new(0, 8)
    notificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right

    notificationLayout.Parent = notificationContainer

    --------------------------------------------------
    -- Notification
    --------------------------------------------------

    function yyudly:Notify(data)

        data = data or {}

        local notification = Create("Frame", {
            Size = UDim2.fromOffset(280, 72),

            BackgroundColor3 = yyudly.Theme.Element,
            BackgroundTransparency = 1,

            BorderSizePixel = 0
        })

        notification.Parent = notificationContainer

        AddCorner(notification, 9)
        AddStroke(notification, yyudly.Theme.Stroke)

        local notificationTitle = Create("TextLabel", {
            Position = UDim2.fromOffset(12, 8),
            Size = UDim2.new(1, -24, 0, 20),

            BackgroundTransparency = 1,

            Text = data.Title or "yyudly",
            Font = Enum.Font.GothamBold,
            TextSize = 14,

            TextColor3 = yyudly.Theme.Text,
            TextTransparency = 1,

            TextXAlignment = Enum.TextXAlignment.Left
        })

        notificationTitle.Parent = notification

        local notificationContent = Create("TextLabel", {
            Position = UDim2.fromOffset(12, 30),
            Size = UDim2.new(1, -24, 0, 30),

            BackgroundTransparency = 1,

            Text = data.Content or "",
            Font = Enum.Font.Gotham,
            TextSize = 12,

            TextColor3 = yyudly.Theme.SubText,
            TextTransparency = 1,

            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        notificationContent.Parent = notification

        Tween(notification, {
            BackgroundTransparency = 0
        }, 0.2):Play()

        Tween(notificationTitle, {
            TextTransparency = 0
        }, 0.2):Play()

        Tween(notificationContent, {
            TextTransparency = 0
        }, 0.2):Play()

        task.delay(data.Duration or 3, function()

            if not notification.Parent then
                return
            end

            Tween(notification, {
                BackgroundTransparency = 1
            }, 0.2):Play()

            Tween(notificationTitle, {
                TextTransparency = 1
            }, 0.2):Play()

            Tween(notificationContent, {
                TextTransparency = 1
            }, 0.2):Play()

            task.wait(0.25)

            notification:Destroy()
        end)
    end

    --------------------------------------------------
    -- Create Tab
    --------------------------------------------------

    function yyudly:CreateTab(tabName)

        local button = Create("TextButton", {
            Name = tabName,

            Size = UDim2.new(1, 0, 0, 36),

            BackgroundColor3 = yyudly.Theme.Accent,
            BackgroundTransparency = 1,

            BorderSizePixel = 0,

            Text = tabName,

            Font = Enum.Font.GothamMedium,
            TextSize = 13,

            TextColor3 = yyudly.Theme.SubText,

            AutoButtonColor = false
        })

        button.Parent = sidebar

        AddCorner(button, 7)

        local page = Create("ScrollingFrame", {
            Name = tabName .. "_Page",

            Position = UDim2.fromOffset(15, 10),
            Size = UDim2.new(1, -30, 1, -20),

            BackgroundTransparency = 1,

            BorderSizePixel = 0,

            ScrollBarThickness = 3,
            ScrollBarImageColor3 = yyudly.Theme.Accent,

            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })

        page.Parent = content

        local padding = Instance.new("UIPadding")

        padding.PaddingLeft = UDim.new(0, 3)
        padding.PaddingRight = UDim.new(0, 3)
        padding.PaddingBottom = UDim.new(0, 10)

        padding.Parent = page

        local layout = Instance.new("UIListLayout")

        layout.Padding = UDim.new(0, 8)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        layout.Parent = page

        pages[tabName] = page
        tabButtons[tabName] = button

        --------------------------------------------------
        -- Select Tab
        --------------------------------------------------

        local function selectTab()

            for name, otherPage in pairs(pages) do
                otherPage.Visible = name == tabName
            end

            for name, otherButton in pairs(tabButtons) do

                if name == tabName then

                    otherButton.BackgroundTransparency = 0
                    otherButton.BackgroundColor3 = yyudly.Theme.Accent
                    otherButton.TextColor3 = Color3.new(1, 1, 1)

                else

                    otherButton.BackgroundTransparency = 1
                    otherButton.TextColor3 = yyudly.Theme.SubText

                end
            end

            currentTab = tabName
        end

        button.MouseButton1Click:Connect(selectTab)

        if not currentTab then
            selectTab()
        end

        --------------------------------------------------
        -- Tab Object
        --------------------------------------------------

        local tab = {}

        --------------------------------------------------
        -- Label
        --------------------------------------------------

        function tab:CreateLabel(text)

            local label = Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 30),

                BackgroundTransparency = 1,

                Text = text,

                Font = Enum.Font.Gotham,
                TextSize = 13,

                TextColor3 = yyudly.Theme.SubText,

                TextXAlignment = Enum.TextXAlignment.Left
            })

            label.Parent = page

            return label
        end

        --------------------------------------------------
        -- Section
        --------------------------------------------------

        function tab:CreateSection(text)

            local section = Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 25),

                BackgroundTransparency = 1,

                Text = text,

                Font = Enum.Font.GothamBold,
                TextSize = 12,

                TextColor3 = yyudly.Theme.Accent,

                TextXAlignment = Enum.TextXAlignment.Left
            })

            section.Parent = page

            return section
        end

        --------------------------------------------------
        -- Button
        --------------------------------------------------

        function tab:CreateButton(data)

            local button = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 42),

                BackgroundColor3 = yyudly.Theme.Element,

                BorderSizePixel = 0,

                Text = data.Name or "Button",

                Font = Enum.Font.GothamMedium,
                TextSize = 13,

                TextColor3 = yyudly.Theme.Text,

                AutoButtonColor = false
            })

            button.Parent = page

            AddCorner(button, 8)

            button.MouseEnter:Connect(function()

                Tween(button, {
                    BackgroundColor3 = yyudly.Theme.ElementHover
                }):Play()

            end)

            button.MouseLeave:Connect(function()

                Tween(button, {
                    BackgroundColor3 = yyudly.Theme.Element
                }):Play()

            end)

            button.MouseButton1Click:Connect(function()

                if data.Callback then
                    data.Callback()
                end

            end)

            return button
        end

        --------------------------------------------------
        -- Toggle
        --------------------------------------------------

        function tab:CreateToggle(data)

            local value = data.CurrentValue or false

            local holder = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 42),

                BackgroundColor3 = yyudly.Theme.Element,

                BorderSizePixel = 0,

                Text = "",

                AutoButtonColor = false
            })

            holder.Parent = page

            AddCorner(holder, 8)

            local label = Create("TextLabel", {
                Position = UDim2.fromOffset(12, 0),

                Size = UDim2.new(1, -70, 1, 0),

                BackgroundTransparency = 1,

                Text = data.Name or "Toggle",

                Font = Enum.Font.GothamMedium,
                TextSize = 13,

                TextColor3 = yyudly.Theme.Text,

                TextXAlignment = Enum.TextXAlignment.Left
            })

            label.Parent = holder

            local switch = Create("Frame", {
                Position = UDim2.new(1, -48, 0.5, -10),

                Size = UDim2.fromOffset(36, 20),

                BackgroundColor3 = Color3.fromRGB(50, 50, 58),

                BorderSizePixel = 0
            })

            switch.Parent = holder

            AddCorner(switch, 10)

            local knob = Create("Frame", {
                Position = UDim2.fromOffset(3, 3),

                Size = UDim2.fromOffset(14, 14),

                BackgroundColor3 = Color3.fromRGB(230, 230, 235),

                BorderSizePixel = 0
            })

            knob.Parent = switch

            AddCorner(knob, 20)

            local function update()

                Tween(switch, {
                    BackgroundColor3 = value
                        and yyudly.Theme.Accent
                        or Color3.fromRGB(50, 50, 58)
                }):Play()

                Tween(knob, {
                    Position = value
                        and UDim2.new(1, -17, 0, 3)
                        or UDim2.fromOffset(3, 3)
                }):Play()

                if data.Callback then
                    data.Callback(value)
                end
            end

            holder.MouseButton1Click:Connect(function()

                value = not value

                update()
            end)

            update()

            return {
                Set = function(_, newValue)
                    value = newValue
                    update()
                end,

                Get = function()
                    return value
                end
            }
        end

        --------------------------------------------------
        -- Slider
        --------------------------------------------------

        function tab:CreateSlider(data)

            local minimum = data.Min or 0
            local maximum = data.Max or 100
            local value = math.clamp(
                data.Default or minimum,
                minimum,
                maximum
            )

            local holder = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 62),

                BackgroundColor3 = yyudly.Theme.Element,

                BorderSizePixel = 0
            })

            holder.Parent = page

            AddCorner(holder, 8)

            local label = Create("TextLabel", {
                Position = UDim2.fromOffset(12, 7),

                Size = UDim2.new(1, -70, 0, 20),

                BackgroundTransparency = 1,

                Text = data.Name or "Slider",

                Font = Enum.Font.GothamMedium,
                TextSize = 13,

                TextColor3 = yyudly.Theme.Text,

                TextXAlignment = Enum.TextXAlignment.Left
            })

            label.Parent = holder

            local valueLabel = Create("TextLabel", {
                Position = UDim2.new(1, -60, 0, 7),

                Size = UDim2.fromOffset(48, 20),

                BackgroundTransparency = 1,

                Text = tostring(value),

                Font = Enum.Font.GothamMedium,
                TextSize = 12,

                TextColor3 = yyudly.Theme.Accent,

                TextXAlignment = Enum.TextXAlignment.Right
            })

            valueLabel.Parent = holder

            local bar = Create("Frame", {
                Position = UDim2.fromOffset(12, 38),

                Size = UDim2.new(1, -24, 0, 6),

                BackgroundColor3 = Color3.fromRGB(50, 50, 58),

                BorderSizePixel = 0
            })

            bar.Parent = holder

            AddCorner(bar, 6)

            local fill = Create("Frame", {
                Size = UDim2.new(
                    (value - minimum) / (maximum - minimum),
                    0,
                    1,
                    0
                ),

                BackgroundColor3 = yyudly.Theme.Accent,

                BorderSizePixel = 0
            })

            fill.Parent = bar

            AddCorner(fill, 6)

            local dragging = false

            local function setValue(x)

                local percentage = math.clamp(
                    (x - bar.AbsolutePosition.X) /
                    bar.AbsoluteSize.X,

                    0,
                    1
                )

                value = math.floor(
                    minimum +
                    ((maximum - minimum) * percentage)
                )

                fill.Size = UDim2.new(
                    percentage,
                    0,
                    1,
                    0
                )

                valueLabel.Text = tostring(value)

                if data.Callback then
                    data.Callback(value)
                end
            end

            bar.InputBegan:Connect(function(input)

                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then

                    dragging = true

                    setValue(input.Position.X)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)

                if not dragging then
                    return
                end

                if input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch then

                    setValue(input.Position.X)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)

                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then

                    dragging = false
                end
            end)

            return {
                Set = function(_, newValue)

                    value = math.clamp(
                        newValue,
                        minimum,
                        maximum
                    )

                    local percentage =
                        (value - minimum) /
                        (maximum - minimum)

                    fill.Size = UDim2.new(
                        percentage,
                        0,
                        1,
                        0
                    )

                    valueLabel.Text = tostring(value)

                    if data.Callback then
                        data.Callback(value)
                    end
                end,

                Get = function()
                    return value
                end
            }
        end

        --------------------------------------------------
        -- Dropdown
        --------------------------------------------------

        function tab:CreateDropdown(data)

            local options = data.Options or {}

            local selected = data.CurrentOption or options[1]

            local holder = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 42),

                BackgroundColor3 = yyudly.Theme.Element,

                BorderSizePixel = 0,

                Text = "",

                AutoButtonColor = false
            })

            holder.Parent = page

            AddCorner(holder, 8)

            local nameLabel = Create("TextLabel", {
                Position = UDim2.fromOffset(12, 0),

                Size = UDim2.new(0.5, 0, 1, 0),

                BackgroundTransparency = 1,

                Text = data.Name or "Dropdown",

                Font = Enum.Font.GothamMedium,
                TextSize = 13,

                TextColor3 = yyudly.Theme.Text,

                TextXAlignment = Enum.TextXAlignment.Left
            })

            nameLabel.Parent = holder

            local selectedLabel = Create("TextLabel", {
                Position = UDim2.new(0.5, 0, 0, 0),

                Size = UDim2.new(0.5, -12, 1, 0),

                BackgroundTransparency = 1,

                Text = tostring(selected or "None"),

                Font = Enum.Font.Gotham,

                TextSize = 12,

                TextColor3 = yyudly.Theme.Accent,

                TextXAlignment = Enum.TextXAlignment.Right
            })

            selectedLabel.Parent = holder

            local index = 1

            for i, option in ipairs(options) do

                if option == selected then
                    index = i
                    break
                end
            end

            holder.MouseButton1Click:Connect(function()

                if #options == 0 then
                    return
                end

                index += 1

                if index > #options then
                    index = 1
                end

                selected = options[index]

                selectedLabel.Text = tostring(selected)

                if data.Callback then
                    data.Callback(selected)
                end
            end)

            return {
                Set = function(_, option)

                    for i, value in ipairs(options) do

                        if value == option then

                            index = i
                            selected = option

                            selectedLabel.Text = tostring(option)

                            if data.Callback then
                                data.Callback(option)
                            end

                            break
                        end
                    end
                end,

                Get = function()
                    return selected
                end
            }
        end

        --------------------------------------------------
        -- Textbox
        --------------------------------------------------

        function tab:CreateTextbox(data)

            local holder = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 52),

                BackgroundColor3 = yyudly.Theme.Element,

                BorderSizePixel = 0
            })

            holder.Parent = page

            AddCorner(holder, 8)

            local label = Create("TextLabel", {
                Position = UDim2.fromOffset(12, 6),

                Size = UDim2.new(0.4, 0, 0, 18),

                BackgroundTransparency = 1,

                Text = data.Name or "Textbox",

                Font = Enum.Font.GothamMedium,

                TextSize = 12,

                TextColor3 = yyudly.Theme.Text,

                TextXAlignment = Enum.TextXAlignment.Left
            })

            label.Parent = holder

            local textbox = Create("TextBox", {
                Position = UDim2.new(0.4, 0, 0, 7),

                Size = UDim2.new(0.6, -12, 0, 32),

                BackgroundColor3 = yyudly.Theme.Background,

                BorderSizePixel = 0,

                Text = data.CurrentValue or "",

                PlaceholderText = data.PlaceholderText or "Enter text...",

                Font = Enum.Font.Gotham,

                TextSize = 12,

                TextColor3 = yyudly.Theme.Text,

                PlaceholderColor3 = yyudly.Theme.SubText,

                ClearTextOnFocus = false
            })

            textbox.Parent = holder

            AddCorner(textbox, 6)

            local padding = Instance.new("UIPadding")
            padding.PaddingLeft = UDim.new(0, 8)
            padding.PaddingRight = UDim.new(0, 8)
            padding.Parent = textbox

            textbox.FocusLost:Connect(function()

                if data.Callback then
                    data.Callback(textbox.Text)
                end
            end)

            return textbox
        end

        --------------------------------------------------
        -- Keybind
        --------------------------------------------------

        function tab:CreateKeybind(data)

            local key = data.CurrentKeybind or Enum.KeyCode.RightShift
            local listening = false

            local holder = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 42),

                BackgroundColor3 = yyudly.Theme.Element,

                BorderSizePixel = 0,

                Text = "",

                AutoButtonColor = false
            })

            holder.Parent = page

            AddCorner(holder, 8)

            local nameLabel = Create("TextLabel", {
                Position = UDim2.fromOffset(12, 0),

                Size = UDim2.new(0.6, 0, 1, 0),

                BackgroundTransparency = 1,

                Text = data.Name or "Keybind",

                Font = Enum.Font.GothamMedium,

                TextSize = 13,

                TextColor3 = yyudly.Theme.Text,

                TextXAlignment = Enum.TextXAlignment.Left
            })

            nameLabel.Parent = holder

            local keyLabel = Create("TextLabel", {
                Position = UDim2.new(0.6, 0, 0, 0),

                Size = UDim2.new(0.4, -12, 1, 0),

                BackgroundTransparency = 1,

                Text = key.Name,

                Font = Enum.Font.GothamMedium,

                TextSize = 12,

                TextColor3 = yyudly.Theme.Accent,

                TextXAlignment = Enum.TextXAlignment.Right
            })

            keyLabel.Parent = holder

            holder.MouseButton1Click:Connect(function()

                listening = true
                keyLabel.Text = "Press key..."

            end)

            UserInputService.InputBegan:Connect(function(input, processed)

                if processed then
                    return
                end

                if listening then

                    if input.KeyCode ~= Enum.KeyCode.Unknown then

                        key = input.KeyCode
                        keyLabel.Text = key.Name

                        listening = false

                        if data.Callback then
                            data.Callback(key)
                        end
                    end

                    return
                end

                if input.KeyCode == key then

                    if data.Callback then
                        data.Callback(key)
                    end
                end
            end)

            return {
                Set = function(_, newKey)

                    key = newKey
                    keyLabel.Text = newKey.Name

                end,

                Get = function()
                    return key
                end
            }
        end

        return tab
    end

    --------------------------------------------------
    -- Window Controls
    --------------------------------------------------

    local dragging = false
    local dragStart
    local startPosition

    topbar.InputBegan:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true

            dragStart = input.Position
            startPosition = main.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)

        if not dragging then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,

            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end)

    UserInputService.InputEnded:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = false
        end
    end)

    --------------------------------------------------
    -- Window Object
    --------------------------------------------------

    local window = {}

    function window:CreateTab(name)
        return yyudly:CreateTab(name)
    end

    function window:SetVisible(visible)
        gui.Enabled = visible
    end

    function window:Destroy()
        gui:Destroy()
    end

    function window:GetGui()
        return gui
    end

    return window
end

return yyudly
