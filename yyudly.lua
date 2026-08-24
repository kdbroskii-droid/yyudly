-- yyudly.lua
-- UI library for Roblox experiences
-- Fixed: CreateTab, Notify, Label:Set, sliders, dropdowns,
-- toggles, keybinds, mobile layout, visibility and cleanup.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local yyudly = {}
yyudly.__index = yyudly

yyudly.Theme = {
    Background = Color3.fromRGB(18, 18, 22),
    Sidebar = Color3.fromRGB(14, 14, 18),
    Element = Color3.fromRGB(28, 28, 34),
    ElementHover = Color3.fromRGB(38, 38, 46),
    Accent = Color3.fromRGB(125, 85, 255),
    Text = Color3.fromRGB(240, 240, 245),
    SubText = Color3.fromRGB(160, 160, 170),
    Stroke = Color3.fromRGB(50, 50, 60)
}

function yyudly:GetDevice()
    local platform = UserInputService:GetPlatform()

    if platform == Enum.Platform.Android
        or platform == Enum.Platform.IOS then
        return "Mobile"
    end

    return "PC"
end

local function tween(object, properties, duration)
    local info = TweenInfo.new(
        duration or 0.15,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )

    return TweenService:Create(object, info, properties)
end

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

function yyudly:CreateWindow(options)
    options = options or {}

    local Device = self:GetDevice()

    local Name = options.Name or "yyudly"
    local SubtitleText = options.Subtitle or ""
    local Transparency = options.Transparency
    if Transparency == nil then
        Transparency = 0.08
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "yyudly"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Position = UDim2.fromScale(0.5, 0.5)
    Main.BackgroundColor3 = self.Theme.Background
    Main.BackgroundTransparency = Transparency
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui

    if Device == "Mobile" then
        Main.Size = UDim2.new(0.94, 0, 0.82, 0)
    else
        Main.Size = options.Size or UDim2.fromOffset(700, 500)
    end

    corner(Main, 12)

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = self.Theme.Stroke
    Stroke.Transparency = 0.35
    Stroke.Parent = Main

    --------------------------------------------------
    -- TOP BAR
    --------------------------------------------------

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 58)
    TopBar.BackgroundTransparency = 1
    TopBar.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Position = UDim2.fromOffset(18, 7)
    Title.Size = UDim2.new(1, -36, 0, 25)
    Title.BackgroundTransparency = 1
    Title.Text = Name
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = self.Theme.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Position = UDim2.fromOffset(19, 32)
    Subtitle.Size = UDim2.new(1, -38, 0, 18)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = SubtitleText .. " • " .. Device
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = 11
    Subtitle.TextColor3 = self.Theme.SubText
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.Parent = TopBar

    --------------------------------------------------
    -- SIDEBAR
    --------------------------------------------------

    local SidebarWidth

    if Device == "Mobile" then
        SidebarWidth = 105
    else
        SidebarWidth = 155
    end

    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Position = UDim2.fromOffset(0, 58)
    Sidebar.Size = UDim2.new(0, SidebarWidth, 1, -58)
    Sidebar.BackgroundColor3 = self.Theme.Sidebar
    Sidebar.BackgroundTransparency = math.clamp(
        Transparency + 0.05,
        0,
        0.95
    )
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main

    corner(Sidebar, 12)

    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.PaddingTop = UDim.new(0, 10)
    SidebarPadding.PaddingLeft = UDim.new(0, 7)
    SidebarPadding.PaddingRight = UDim.new(0, 7)
    SidebarPadding.Parent = Sidebar

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 6)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = Sidebar

    --------------------------------------------------
    -- CONTENT
    --------------------------------------------------

    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Position = UDim2.fromOffset(SidebarWidth, 58)
    Content.Size = UDim2.new(1, -SidebarWidth, 1, -58)
    Content.BackgroundTransparency = 1
    Content.Parent = Main

    local Pages = {}
    local Buttons = {}
    local Tabs = {}
    local CurrentTab = nil

    --------------------------------------------------
    -- NOTIFICATION SYSTEM
    --------------------------------------------------

    local NotificationHolder = Instance.new("Frame")
    NotificationHolder.Name = "Notifications"
    NotificationHolder.AnchorPoint = Vector2.new(1, 0)
    NotificationHolder.Position = UDim2.new(1, -12, 0, 12)
    NotificationHolder.Size = UDim2.new(0, 280, 1, -24)
    NotificationHolder.BackgroundTransparency = 1
    NotificationHolder.Parent = ScreenGui

    local NotificationLayout = Instance.new("UIListLayout")
    NotificationLayout.Padding = UDim.new(0, 8)
    NotificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    NotificationLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    NotificationLayout.Parent = NotificationHolder

    function yyudly:Notify(notification)
        notification = notification or {}

        local notificationTitle =
            notification.Title or "Notification"

        local content =
            notification.Content or ""

        local duration =
            notification.Duration or 3

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 65)
        frame.BackgroundColor3 = self.Theme.Element
        frame.BackgroundTransparency = 0.03
        frame.BorderSizePixel = 0
        frame.Parent = NotificationHolder

        corner(frame, 8)

        local stroke = Instance.new("UIStroke")
        stroke.Color = self.Theme.Accent
        stroke.Transparency = 0.45
        stroke.Parent = frame

        local title = Instance.new("TextLabel")
        title.Position = UDim2.fromOffset(12, 7)
        title.Size = UDim2.new(1, -24, 0, 20)
        title.BackgroundTransparency = 1
        title.Text = notificationTitle
        title.Font = Enum.Font.GothamBold
        title.TextSize = 13
        title.TextColor3 = self.Theme.Text
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = frame

        local text = Instance.new("TextLabel")
        text.Position = UDim2.fromOffset(12, 29)
        text.Size = UDim2.new(1, -24, 0, 28)
        text.BackgroundTransparency = 1
        text.Text = content
        text.Font = Enum.Font.Gotham
        text.TextSize = 11
        text.TextColor3 = self.Theme.SubText
        text.TextWrapped = true
        text.TextXAlignment = Enum.TextXAlignment.Left
        text.Parent = frame

        frame.BackgroundTransparency = 1

        tween(frame, {
            BackgroundTransparency = 0.03
        }, 0.2):Play()

        task.delay(duration, function()
            if frame.Parent then
                local t = tween(frame, {
                    BackgroundTransparency = 1
                }, 0.2)

                t:Play()
                t.Completed:Wait()

                if frame then
                    frame:Destroy()
                end
            end
        end)

        return frame
    end

    --------------------------------------------------
    -- CREATE TAB
    --------------------------------------------------

    local function CreateTab(TabName)
        TabName = tostring(TabName or "Tab")

        if Pages[TabName] then
            return Tabs[TabName]
        end

        local TabButton = Instance.new("TextButton")
        TabButton.Name = TabName
        TabButton.Size = UDim2.new(1, 0, 0, 36)
        TabButton.BackgroundColor3 = self.Theme.Accent
        TabButton.BackgroundTransparency = 1
        TabButton.Text = TabName
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.TextSize = Device == "Mobile" and 11 or 13
        TabButton.TextColor3 = self.Theme.SubText
        TabButton.AutoButtonColor = false
        TabButton.Parent = Sidebar

        corner(TabButton, 7)

        local Page = Instance.new("ScrollingFrame")
        Page.Name = TabName .. "Page"
        Page.Position = UDim2.fromOffset(15, 10)
        Page.Size = UDim2.new(1, -30, 1, -20)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = self.Theme.Accent
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.CanvasSize = UDim2.new()
        Page.Visible = false
        Page.Parent = Content

        local Layout = Instance.new("UIListLayout")
        Layout.Padding = UDim.new(0, 8)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Parent = Page

        Pages[TabName] = Page
        Buttons[TabName] = TabButton

        local function Select()
            for name, page in pairs(Pages) do
                page.Visible = name == TabName
            end

            for name, button in pairs(Buttons) do
                if name == TabName then
                    button.BackgroundTransparency = 0
                    button.TextColor3 = Color3.new(1, 1, 1)
                else
                    button.BackgroundTransparency = 1
                    button.TextColor3 = self.Theme.SubText
                end
            end

            CurrentTab = TabName
        end

        TabButton.MouseButton1Click:Connect(Select)

        if not CurrentTab then
            Select()
        end

        local Tab = {}

        --------------------------------------------------
        -- LABEL
        --------------------------------------------------

        function Tab:CreateLabel(text)
            local Label = Instance.new("TextLabel")

            Label.Size = UDim2.new(1, 0, 0, 30)
            Label.BackgroundTransparency = 1
            Label.Text = tostring(text or "")
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 13
            Label.TextColor3 = yyudly.Theme.SubText
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.TextWrapped = true
            Label.Parent = Page

            function Label:Set(newText)
                Label.Text = tostring(newText or "")
            end

            return Label
        end

        --------------------------------------------------
        -- SECTION
        --------------------------------------------------

        function Tab:CreateSection(text)
            local Section = Instance.new("TextLabel")

            Section.Size = UDim2.new(1, 0, 0, 25)
            Section.BackgroundTransparency = 1
            Section.Text = tostring(text or "")
            Section.Font = Enum.Font.GothamBold
            Section.TextSize = 12
            Section.TextColor3 = yyudly.Theme.Accent
            Section.TextXAlignment = Enum.TextXAlignment.Left
            Section.Parent = Page

            return Section
        end

        --------------------------------------------------
        -- BUTTON
        --------------------------------------------------

        function Tab:CreateButton(options)
            options = options or {}

            local Button = Instance.new("TextButton")

            Button.Size = UDim2.new(1, 0, 0, 42)
            Button.BackgroundColor3 = yyudly.Theme.Element
            Button.Text = options.Name or "Button"
            Button.Font = Enum.Font.GothamMedium
            Button.TextSize = 13
            Button.TextColor3 = yyudly.Theme.Text
            Button.AutoButtonColor = false
            Button.Parent = Page

            corner(Button, 8)

            Button.MouseEnter:Connect(function()
                tween(Button, {
                    BackgroundColor3 = yyudly.Theme.ElementHover
                }):Play()
            end)

            Button.MouseLeave:Connect(function()
                tween(Button, {
                    BackgroundColor3 = yyudly.Theme.Element
                }):Play()
            end)

            Button.MouseButton1Click:Connect(function()
                if typeof(options.Callback) == "function" then
                    options.Callback()
                end
            end)

            return Button
        end

        --------------------------------------------------
        -- TOGGLE
        --------------------------------------------------

        function Tab:CreateToggle(options)
            options = options or {}

            local Toggle = {}

            Toggle.CurrentValue =
                options.CurrentValue == true

            Toggle.Callback =
                options.Callback

            local Button = Instance.new("TextButton")

            Button.Size = UDim2.new(1, 0, 0, 42)
            Button.BackgroundColor3 = yyudly.Theme.Element
            Button.TextColor3 = yyudly.Theme.Text
            Button.Font = Enum.Font.GothamMedium
            Button.TextSize = 13
            Button.TextXAlignment = Enum.TextXAlignment.Left
            Button.AutoButtonColor = false
            Button.Parent = Page

            corner(Button, 8)

            local Padding = Instance.new("UIPadding")
            Padding.PaddingLeft = UDim.new(0, 12)
            Padding.PaddingRight = UDim.new(0, 55)
            Padding.Parent = Button

            local Indicator = Instance.new("Frame")
            Indicator.AnchorPoint = Vector2.new(1, 0.5)
            Indicator.Position = UDim2.new(1, -12, 0.5, 0)
            Indicator.Size = UDim2.fromOffset(34, 18)
            Indicator.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
            Indicator.Parent = Button

            corner(Indicator, 9)

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.fromOffset(14, 14)
            Knob.AnchorPoint = Vector2.new(0, 0.5)
            Knob.Position = UDim2.new(0, 2, 0.5, 0)
            Knob.BackgroundColor3 = Color3.fromRGB(220, 220, 225)
            Knob.Parent = Indicator

            corner(Knob, 7)

            local function updateVisual()
                Button.Text =
                    (options.Name or "Toggle")
                    .. " : "
                    .. (Toggle.CurrentValue and "ON" or "OFF")

                if Toggle.CurrentValue then
                    Indicator.BackgroundColor3 =
                        yyudly.Theme.Accent

                    Knob.Position =
                        UDim2.new(1, -16, 0.5, 0)
                else
                    Indicator.BackgroundColor3 =
                        Color3.fromRGB(55, 55, 65)

                    Knob.Position =
                        UDim2.new(0, 2, 0.5, 0)
                end
            end

            function Toggle:Set(value)
                Toggle.CurrentValue = value == true
                updateVisual()

                if typeof(Toggle.Callback) == "function" then
                    Toggle.Callback(Toggle.CurrentValue)
                end
            end

            Button.MouseButton1Click:Connect(function()
                Toggle:Set(not Toggle.CurrentValue)
            end)

            updateVisual()

            return Toggle
        end

        --------------------------------------------------
        -- SLIDER
        --------------------------------------------------

        function Tab:CreateSlider(options)
            options = options or {}

            local Slider = {}

            Slider.Min = tonumber(options.Min) or 0
            Slider.Max = tonumber(options.Max) or 100

            if Slider.Max <= Slider.Min then
                Slider.Max = Slider.Min + 1
            end

            Slider.CurrentValue =
                tonumber(options.Default)
                or Slider.Min

            Slider.Callback =
                options.Callback

            local Holder = Instance.new("Frame")

            Holder.Size = UDim2.new(1, 0, 0, 62)
            Holder.BackgroundColor3 = yyudly.Theme.Element
            Holder.Parent = Page

            corner(Holder, 8)

            local Label = Instance.new("TextLabel")
            Label.Position = UDim2.fromOffset(12, 5)
            Label.Size = UDim2.new(1, -80, 0, 22)
            Label.BackgroundTransparency = 1
            Label.Text = options.Name or "Slider"
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 13
            Label.TextColor3 = yyudly.Theme.Text
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Holder

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.AnchorPoint = Vector2.new(1, 0)
            ValueLabel.Position = UDim2.new(1, -12, 0, 5)
            ValueLabel.Size = UDim2.fromOffset(55, 22)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Font = Enum.Font.Gotham
            ValueLabel.TextSize = 12
            ValueLabel.TextColor3 = yyudly.Theme.Accent
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = Holder

            local Bar = Instance.new("Frame")
            Bar.Position = UDim2.fromOffset(12, 38)
            Bar.Size = UDim2.new(1, -24, 0, 7)
            Bar.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
            Bar.Parent = Holder

            corner(Bar, 5)

            local Fill = Instance.new("Frame")
            Fill.BackgroundColor3 = yyudly.Theme.Accent
            Fill.Size = UDim2.new(0, 0, 1, 0)
            Fill.Parent = Bar

            corner(Fill, 5)

            local dragging = false

            local function setFromX(x)
                local percent =
                    math.clamp(
                        (x - Bar.AbsolutePosition.X)
                        / Bar.AbsoluteSize.X,
                        0,
                        1
                    )

                local value =
                    Slider.Min
                    + ((Slider.Max - Slider.Min) * percent)

                Slider:Set(value)
            end

            function Slider:Set(value)
                value = tonumber(value) or Slider.Min

                value = math.clamp(
                    value,
                    Slider.Min,
                    Slider.Max
                )

                Slider.CurrentValue = value

                local percent =
                    (value - Slider.Min)
                    / (Slider.Max - Slider.Min)

                Fill.Size =
                    UDim2.new(percent, 0, 1, 0)

                ValueLabel.Text =
                    tostring(math.floor(value * 100) / 100)

                if typeof(Slider.Callback) == "function" then
                    Slider.Callback(value)
                end
            end

            Bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then

                    dragging = true
                    setFromX(input.Position.X)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if not dragging then
                    return
                end

                if input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch then

                    setFromX(input.Position.X)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then

                    dragging = false
                end
            end)

            Slider:Set(Slider.CurrentValue)

            return Slider
        end

        --------------------------------------------------
        -- DROPDOWN
        --------------------------------------------------

        function Tab:CreateDropdown(options)
            options = options or {}

            local Dropdown = {}

            Dropdown.Options = options.Options or {}

            Dropdown.CurrentOption =
                options.CurrentOption
                or Dropdown.Options[1]

            Dropdown.Callback =
                options.Callback

            local Holder = Instance.new("Frame")

            Holder.Size = UDim2.new(1, 0, 0, 42)
            Holder.BackgroundTransparency = 1
            Holder.Parent = Page

            local Button = Instance.new("TextButton")

            Button.Size = UDim2.new(1, 0, 1, 0)
            Button.BackgroundColor3 = yyudly.Theme.Element
            Button.TextColor3 = yyudly.Theme.Text
            Button.Font = Enum.Font.GothamMedium
            Button.TextSize = 13
            Button.AutoButtonColor = false
            Button.Parent = Holder

            corner(Button, 8)

            local Open = false

            local List = Instance.new("Frame")

            List.Position = UDim2.new(0, 0, 1, 4)
            List.Size = UDim2.new(1, 0, 0, 0)
            List.BackgroundColor3 = yyudly.Theme.Element
            List.Visible = false
            List.ZIndex = 20
            List.Parent = Holder

            corner(List, 8)

            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Padding = UDim.new(0, 2)
            ListLayout.Parent = List

            local function updateText()
                Button.Text =
                    (options.Name or "Dropdown")
                    .. " : "
                    .. tostring(
                        Dropdown.CurrentOption or "None"
                    )
            end

            local function rebuild()
                for _, child in ipairs(List:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end

                for _, option in ipairs(Dropdown.Options) do
                    local optionButton =
                        Instance.new("TextButton")

                    optionButton.Size =
                        UDim2.new(1, 0, 0, 30)

                    optionButton.BackgroundTransparency = 1
                    optionButton.Text = tostring(option)
                    optionButton.TextColor3 =
                        yyudly.Theme.Text

                    optionButton.Font =
                        Enum.Font.Gotham

                    optionButton.TextSize = 12
                    optionButton.ZIndex = 21
                    optionButton.Parent = List

                    optionButton.MouseButton1Click:Connect(
                        function()
                            Dropdown:Set(option)
                            Open = false
                            List.Visible = false
                        end
                    )
                end

                List.Size =
                    UDim2.new(
                        1,
                        0,
                        0,
                        math.min(#Dropdown.Options * 32, 160)
                    )
            end

            function Dropdown:Set(value)
                for _, option in ipairs(Dropdown.Options) do
                    if option == value then
                        Dropdown.CurrentOption = value
                        updateText()

                        if typeof(Dropdown.Callback) == "function" then
                            Dropdown.Callback(value)
                        end

                        return
                    end
                end
            end

            Button.MouseButton1Click:Connect(function()
                Open = not Open
                List.Visible = Open
            end)

            rebuild()
            updateText()

            return Dropdown
        end

        --------------------------------------------------
        -- TEXTBOX
        --------------------------------------------------

        function Tab:CreateTextbox(options)
            options = options or {}

            local Box = Instance.new("TextBox")

            Box.Size = UDim2.new(1, 0, 0, 42)
            Box.BackgroundColor3 = yyudly.Theme.Element
            Box.Text = options.CurrentValue or ""
            Box.PlaceholderText =
                options.PlaceholderText or "Enter text..."

            Box.Font = Enum.Font.Gotham
            Box.TextSize = 13
            Box.TextColor3 = yyudly.Theme.Text
            Box.PlaceholderColor3 = yyudly.Theme.SubText
            Box.ClearTextOnFocus = false
            Box.Parent = Page

            corner(Box, 8)

            Box.FocusLost:Connect(function()
                if typeof(options.Callback) == "function" then
                    options.Callback(Box.Text)
                end
            end)

            return Box
        end

        --------------------------------------------------
        -- KEYBIND
        --------------------------------------------------

        function Tab:CreateKeybind(options)
            options = options or {}

            local Keybind = {}

            local CurrentKey =
                options.CurrentKeybind
                or Enum.KeyCode.RightShift

            local Listening = false

            local Button = Instance.new("TextButton")

            Button.Size = UDim2.new(1, 0, 0, 42)
            Button.BackgroundColor3 = yyudly.Theme.Element
            Button.TextColor3 = yyudly.Theme.Text
            Button.Font = Enum.Font.GothamMedium
            Button.TextSize = 13
            Button.AutoButtonColor = false
            Button.Parent = Page

            corner(Button, 8)

            local function update()
                Button.Text =
                    (options.Name or "Keybind")
                    .. " : "
                    .. CurrentKey.Name
            end

            Button.MouseButton1Click:Connect(function()
                Listening = true
                Button.Text = "Press a key..."
            end)

            UserInputService.InputBegan:Connect(
                function(input, processed)
                    if processed then
                        return
                    end

                    if Listening then
                        if input.KeyCode ~= Enum.KeyCode.Unknown then
                            CurrentKey = input.KeyCode
                            Listening = false
                            update()
                        end

                        return
                    end

                    if input.KeyCode == CurrentKey then
                        if typeof(options.Callback) == "function" then
                            options.Callback(CurrentKey)
                        end
                    end
                end
            )

            function Keybind:Set(key)
                if typeof(key) == "EnumItem"
                    and key.EnumType == Enum.KeyCode then

                    CurrentKey = key
                    update()
                end
            end

            update()

            return Keybind
        end

        function Tab:Select()
            Select()
        end

        Tabs[TabName] = Tab

        return Tab
    end

    --------------------------------------------------
    -- WINDOW API
    --------------------------------------------------

    local Window = {}

    function Window:CreateTab(name)
        return CreateTab(name)
    end

    function Window:GetDevice()
        return Device
    end

    function Window:SetVisible(value)
        ScreenGui.Enabled = value == true
    end

    function Window:IsVisible()
        return ScreenGui.Enabled
    end

    function Window:Destroy()
        if ScreenGui then
            ScreenGui:Destroy()
        end

        Pages = {}
        Buttons = {}
        Tabs = {}
        CurrentTab = nil
    end

    function Window:SelectTab(name)
        local tab = Tabs[name]

        if tab and tab.Select then
            tab:Select()
        end
    end

    return Window
end

return yyudl    task.spawn(function()
        pcall(Callback, ...)
    end)
end

--------------------------------------------------
-- DEVICE
--------------------------------------------------

function yyudly:GetDevice()

    local Platform = UserInputService:GetPlatform()

    if Platform == Enum.Platform.Android
        or Platform == Enum.Platform.IOS then

        return "Mobile"
    end

    return "PC"
end

--------------------------------------------------
-- NOTIFICATIONS
--------------------------------------------------

function yyudly:Notify(Options)

    Options = Options or {}

    local Title = tostring(
        Options.Title or "Notification"
    )

    local Content = tostring(
        Options.Content or ""
    )

    local Duration = tonumber(
        Options.Duration
    ) or 3

    local PlayerGui =
        LocalPlayer:WaitForChild("PlayerGui")

    local NotificationGui =
        PlayerGui:FindFirstChild("yyudlyNotifications")

    if not NotificationGui then

        NotificationGui =
            Instance.new("ScreenGui")

        NotificationGui.Name =
            "yyudlyNotifications"

        NotificationGui.ResetOnSpawn = false
        NotificationGui.IgnoreGuiInset = true
        NotificationGui.DisplayOrder = 999999
        NotificationGui.Parent = PlayerGui

        local Holder =
            Instance.new("Frame")

        Holder.Name = "Holder"
        Holder.AnchorPoint =
            Vector2.new(1, 0)

        Holder.Position =
            UDim2.new(1, -15, 0, 15)

        Holder.Size =
            UDim2.fromOffset(300, 0)

        Holder.AutomaticSize =
            Enum.AutomaticSize.Y

        Holder.BackgroundTransparency = 1
        Holder.Parent = NotificationGui

        local Layout =
            Instance.new("UIListLayout")

        Layout.Padding =
            UDim.new(0, 8)

        Layout.HorizontalAlignment =
            Enum.HorizontalAlignment.Right

        Layout.SortOrder =
            Enum.SortOrder.LayoutOrder

        Layout.Parent = Holder
    end

    local Holder =
        NotificationGui:FindFirstChild("Holder")

    local Notification =
        Instance.new("Frame")

    Notification.Name =
        "Notification"

    Notification.Size =
        UDim2.fromOffset(300, 72)

    Notification.BackgroundColor3 =
        yyudly.Theme.Background

    Notification.BackgroundTransparency =
        0.05

    Notification.BorderSizePixel = 0
    Notification.ClipsDescendants = true
    Notification.Parent = Holder

    MakeCorner(Notification, 10)
    MakeStroke(Notification)

    local Accent =
        Instance.new("Frame")

    Accent.Size =
        UDim2.new(0, 4, 1, 0)

    Accent.BackgroundColor3 =
        yyudly.Theme.Accent

    Accent.BorderSizePixel = 0
    Accent.Parent = Notification

    local TitleLabel =
        Instance.new("TextLabel")

    TitleLabel.Position =
        UDim2.fromOffset(15, 9)

    TitleLabel.Size =
        UDim2.new(1, -25, 0, 20)

    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Title
    TitleLabel.Font =
        Enum.Font.GothamBold

    TitleLabel.TextSize = 14
    TitleLabel.TextColor3 =
        yyudly.Theme.Text

    TitleLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    TitleLabel.Parent = Notification

    local ContentLabel =
        Instance.new("TextLabel")

    ContentLabel.Position =
        UDim2.fromOffset(15, 32)

    ContentLabel.Size =
        UDim2.new(1, -25, 0, 30)

    ContentLabel.BackgroundTransparency = 1
    ContentLabel.Text = Content

    ContentLabel.Font =
        Enum.Font.Gotham

    ContentLabel.TextSize = 11
    ContentLabel.TextColor3 =
        yyudly.Theme.SubText

    ContentLabel.TextWrapped = true

    ContentLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    ContentLabel.TextYAlignment =
        Enum.TextYAlignment.Top

    ContentLabel.Parent = Notification

    Notification.Position =
        UDim2.new(1, 20, 0, 0)

    Tween(
        Notification,
        {
            Position = UDim2.new(0, 0, 0, 0)
        },
        0.2
    )

    task.delay(Duration, function()

        if not Notification.Parent then
            return
        end

        local Animation =
            Tween(
                Notification,
                {
                    Position =
                        UDim2.new(1, 20, 0, 0)
                },
                0.2
            )

        Animation.Completed:Wait()

        if Notification then
            Notification:Destroy()
        end
    end)

    return Notification
end

--------------------------------------------------
-- WINDOW
--------------------------------------------------

function yyudly:CreateWindow(Options)

    Options = Options or {}

    local Device =
        self:GetDevice()

    local WindowName =
        Options.Name or "yyudly"

    local SubtitleText =
        Options.Subtitle or ""

    local Transparency =
        tonumber(Options.Transparency)

    if Transparency == nil then
        Transparency = 0.55
    end

    local ScreenGui =
        Instance.new("ScreenGui")

    ScreenGui.Name =
        "yyudly"

    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior =
        Enum.ZIndexBehavior.Sibling

    ScreenGui.Parent =
        LocalPlayer:WaitForChild("PlayerGui")

    --------------------------------------------------
    -- SIZE
    --------------------------------------------------

    local Size

    if Device == "Mobile" then

        Size =
            UDim2.new(
                0.94,
                0,
                0.82,
                0
            )

    else

        Size =
            Options.Size
            or UDim2.fromOffset(650, 480)

    end

    --------------------------------------------------
    -- MAIN
    --------------------------------------------------

    local Main =
        Instance.new("Frame")

    Main.Name = "Main"
    Main.Size = Size

    Main.Position =
        UDim2.fromScale(0.5, 0.5)

    Main.AnchorPoint =
        Vector2.new(0.5, 0.5)

    Main.BackgroundColor3 =
        yyudly.Theme.Background

    Main.BackgroundTransparency =
        Transparency

    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui

    MakeCorner(Main, 12)
    MakeStroke(Main)

    --------------------------------------------------
    -- TOP BAR
    --------------------------------------------------

    local TopBar =
        Instance.new("Frame")

    TopBar.Size =
        UDim2.new(1, 0, 0, 55)

    TopBar.BackgroundTransparency = 1
    TopBar.Parent = Main

    local Title =
        Instance.new("TextLabel")

    Title.Position =
        UDim2.fromOffset(18, 7)

    Title.Size =
        UDim2.new(1, -36, 0, 24)

    Title.BackgroundTransparency = 1
    Title.Text = WindowName

    Title.Font =
        Enum.Font.GothamBold

    Title.TextSize = 18
    Title.TextColor3 =
        yyudly.Theme.Text

    Title.TextXAlignment =
        Enum.TextXAlignment.Left

    Title.Parent = TopBar

    local Subtitle =
        Instance.new("TextLabel")

    Subtitle.Position =
        UDim2.fromOffset(19, 30)

    Subtitle.Size =
        UDim2.new(1, -38, 0, 17)

    Subtitle.BackgroundTransparency = 1

    Subtitle.Text =
        SubtitleText
        .. " • "
        .. Device

    Subtitle.Font =
        Enum.Font.Gotham

    Subtitle.TextSize = 11

    Subtitle.TextColor3 =
        yyudly.Theme.SubText

    Subtitle.TextXAlignment =
        Enum.TextXAlignment.Left

    Subtitle.Parent = TopBar

    --------------------------------------------------
    -- SIDEBAR
    --------------------------------------------------

    local SidebarWidth

    if Device == "Mobile" then
        SidebarWidth = 105
    else
        SidebarWidth = 155
    end

    local Sidebar =
        Instance.new("Frame")

    Sidebar.Name = "Sidebar"

    Sidebar.Position =
        UDim2.fromOffset(0, 55)

    Sidebar.Size =
        UDim2.new(
            0,
            SidebarWidth,
            1,
            -55
        )

    Sidebar.BackgroundColor3 =
        yyudly.Theme.Sidebar

    Sidebar.BackgroundTransparency =
        math.clamp(
            Transparency + 0.1,
            0,
            0.95
        )

    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main

    MakeCorner(Sidebar, 12)

    local TabPadding =
        Instance.new("UIPadding")

    TabPadding.PaddingTop =
        UDim.new(0, 10)

    TabPadding.PaddingLeft =
        UDim.new(0, 7)

    TabPadding.PaddingRight =
        UDim.new(0, 7)

    TabPadding.Parent = Sidebar

    local TabLayout =
        Instance.new("UIListLayout")

    TabLayout.Padding =
        UDim.new(0, 6)

    TabLayout.Parent = Sidebar

    --------------------------------------------------
    -- CONTENT
    --------------------------------------------------

    local Content =
        Instance.new("Frame")

    Content.Name = "Content"

    Content.Position =
        UDim2.fromOffset(
            SidebarWidth,
            55
        )

    Content.Size =
        UDim2.new(
            1,
            -SidebarWidth,
            1,
            -55
        )

    Content.BackgroundTransparency = 1
    Content.Parent = Main

    --------------------------------------------------
    -- TAB STATE
    --------------------------------------------------

    local Pages = {}
    local Buttons = {}
    local Tabs = {}

    local CurrentTab = nil

    --------------------------------------------------
    -- SELECT TAB
    --------------------------------------------------

    local function SelectTab(Name)

        for TabName, Page in pairs(Pages) do
            Page.Visible =
                TabName == Name
        end

        for TabName, Button in pairs(Buttons) do

            if TabName == Name then

                Button.BackgroundTransparency = 0
                Button.BackgroundColor3 =
                    yyudly.Theme.Accent

                Button.TextColor3 =
                    Color3.new(1, 1, 1)

            else

                Button.BackgroundTransparency = 1

                Button.TextColor3 =
                    yyudly.Theme.SubText

            end
        end

        CurrentTab = Name
    end

    --------------------------------------------------
    -- CREATE TAB
    --------------------------------------------------

    local function CreateTab(TabName)

        TabName =
            tostring(TabName or "Tab")

        if Pages[TabName] then
            return Tabs[TabName]
        end

        --------------------------------------------------
        -- TAB BUTTON
        --------------------------------------------------

        local TabButton =
            Instance.new("TextButton")

        TabButton.Name =
            TabName .. "Button"

        TabButton.Size =
            UDim2.new(1, 0, 0, 36)

        TabButton.BackgroundColor3 =
            yyudly.Theme.Accent

        TabButton.BackgroundTransparency = 1

        TabButton.Text = TabName

        TabButton.Font =
            Enum.Font.GothamMedium

        TabButton.TextSize = 13

        TabButton.TextColor3 =
            yyudly.Theme.SubText

        TabButton.AutoButtonColor = false
        TabButton.Parent = Sidebar

        MakeCorner(TabButton, 7)

        --------------------------------------------------
        -- PAGE
        --------------------------------------------------

        local Page =
            Instance.new("ScrollingFrame")

        Page.Name =
            TabName .. "Page"

        Page.Position =
            UDim2.fromOffset(15, 10)

        Page.Size =
            UDim2.new(
                1,
                -30,
                1,
                -20
            )

        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0

        Page.ScrollBarThickness = 3

        Page.ScrollBarImageColor3 =
            yyudly.Theme.Accent

        Page.AutomaticCanvasSize =
            Enum.AutomaticSize.Y

        Page.CanvasSize =
            UDim2.new()

        Page.Visible = false
        Page.Parent = Content

        local Layout =
            Instance.new("UIListLayout")

        Layout.Padding =
            UDim.new(0, 8)

        Layout.SortOrder =
            Enum.SortOrder.LayoutOrder

        Layout.Parent = Page

        Pages[TabName] = Page
        Buttons[TabName] = TabButton

        --------------------------------------------------
        -- TAB OBJECT
        --------------------------------------------------

        local Tab = {}

        --------------------------------------------------
        -- LABEL
        --------------------------------------------------

        function Tab:CreateLabel(Text)

            local LabelObject =
                Instance.new("TextLabel")

            LabelObject.Size =
                UDim2.new(1, 0, 0, 30)

            LabelObject.BackgroundTransparency = 1

            LabelObject.Text =
                tostring(Text or "")

            LabelObject.Font =
                Enum.Font.Gotham

            LabelObject.TextSize = 13

            LabelObject.TextColor3 =
                yyudly.Theme.SubText

            LabelObject.TextXAlignment =
                Enum.TextXAlignment.Left

            LabelObject.TextWrapped = true

            LabelObject.Parent = Page

            local Label = {}

            Label.Instance =
                LabelObject

            function Label:Set(NewText)

                LabelObject.Text =
                    tostring(NewText or "")

            end

            function Label:Get()

                return LabelObject.Text

            end

            function Label:Destroy()

                LabelObject:Destroy()

            end

            return Label
        end

        --------------------------------------------------
        -- SECTION
        --------------------------------------------------

        function Tab:CreateSection(Text)

            local Section =
                Instance.new("TextLabel")

            Section.Size =
                UDim2.new(1, 0, 0, 25)

            Section.BackgroundTransparency = 1

            Section.Text =
                tostring(Text or "")

            Section.Font =
                Enum.Font.GothamBold

            Section.TextSize = 12

            Section.TextColor3 =
                yyudly.Theme.Accent

            Section.TextXAlignment =
                Enum.TextXAlignment.Left

            Section.Parent = Page

            return Section
        end

        --------------------------------------------------
        -- BUTTON
        --------------------------------------------------

        function Tab:CreateButton(Options)

            Options = Options or {}

            local Button =
                Instance.new("TextButton")

            Button.Size =
                UDim2.new(1, 0, 0, 42)

            Button.BackgroundColor3 =
                yyudly.Theme.Element

            Button.Text =
                Options.Name or "Button"

            Button.Font =
                Enum.Font.GothamMedium

            Button.TextSize = 13

            Button.TextColor3 =
                yyudly.Theme.Text

            Button.AutoButtonColor = false

            Button.Parent = Page

            MakeCorner(Button, 8)

            Button.MouseEnter:Connect(function()

                Tween(
                    Button,
                    {
                        BackgroundColor3 =
                            yyudly.Theme.ElementHover
                    }
                )

            end)

            Button.MouseLeave:Connect(function()

                Tween(
                    Button,
                    {
                        BackgroundColor3 =
                            yyudly.Theme.Element
                    }
                )

            end)

            Button.MouseButton1Click:Connect(function()

                SafeCallback(
                    Options.Callback
                )

            end)

            return Button
        end

        --------------------------------------------------
        -- TOGGLE
        --------------------------------------------------

        function Tab:CreateToggle(Options)

            Options = Options or {}

            local Toggle = {}

            Toggle.CurrentValue =
                Options.CurrentValue == true

            Toggle.Callback =
                Options.Callback

            local Button =
                Instance.new("TextButton")

            Button.Size =
                UDim2.new(1, 0, 0, 42)

            Button.BackgroundColor3 =
                yyudly.Theme.Element

            Button.TextColor3 =
                yyudly.Theme.Text

            Button.Font =
                Enum.Font.GothamMedium

            Button.TextSize = 13

            Button.TextXAlignment =
                Enum.TextXAlignment.Left

            Button.AutoButtonColor = false
            Button.Parent = Page

            MakeCorner(Button, 8)

            local Padding =
                Instance.new("UIPadding")

            Padding.PaddingLeft =
                UDim.new(0, 12)

            Padding.PaddingRight =
                UDim.new(0, 12)

            Padding.Parent = Button

            local function Update()

                Button.Text =
                    tostring(
                        Options.Name or "Toggle"
                    )
                    .. " : "
                    .. (
                        Toggle.CurrentValue
                        and "ON"
                        or "OFF"
                    )

                Button.BackgroundColor3 =
                    Toggle.CurrentValue
                    and yyudly.Theme.ElementHover
                    or yyudly.Theme.Element

            end

            function Toggle:Set(Value, FireCallback)

                Toggle.CurrentValue =
                    Value == true

                Update()

                if FireCallback ~= false then
                    SafeCallback(
                        Toggle.Callback,
                        Toggle.CurrentValue
                    )
                end
            end

            function Toggle:Get()

                return Toggle.CurrentValue

            end

            function Toggle:Destroy()

                Button:Destroy()

            end

            Button.MouseButton1Click:Connect(function()

                Toggle:Set(
                    not Toggle.CurrentValue
                )

            end)

            Toggle:Set(
                Toggle.CurrentValue,
                false
            )

            return Toggle
        end

        --------------------------------------------------
        -- SLIDER
        --------------------------------------------------

        function Tab:CreateSlider(Options)

            Options = Options or {}

            local Slider = {}

            Slider.Min =
                tonumber(Options.Min) or 0

            Slider.Max =
                tonumber(Options.Max) or 100

            if Slider.Max <= Slider.Min then
                Slider.Max =
                    Slider.Min + 1
            end

            Slider.CurrentValue =
                tonumber(
                    Options.Default
                ) or Slider.Min

            Slider.CurrentValue =
                math.clamp(
                    Slider.CurrentValue,
                    Slider.Min,
                    Slider.Max
                )

            Slider.Callback =
                Options.Callback

            local Holder =
                Instance.new("Frame")

            Holder.Size =
                UDim2.new(1, 0, 0, 62)

            Holder.BackgroundColor3 =
                yyudly.Theme.Element

            Holder.Parent = Page

            MakeCorner(Holder, 8)

            local Label =
                Instance.new("TextLabel")

            Label.Position =
                UDim2.fromOffset(12, 6)

            Label.Size =
                UDim2.new(
                    1,
                    -80,
                    0,
                    20
                )

            Label.BackgroundTransparency = 1

            Label.Text =
                Options.Name or "Slider"

            Label.Font =
                Enum.Font.GothamMedium

            Label.TextSize = 13

            Label.TextColor3 =
                yyudly.Theme.Text

            Label.TextXAlignment =
                Enum.TextXAlignment.Left

            Label.Parent = Holder

            local Value =
                Instance.new("TextLabel")

            Value.Position =
                UDim2.new(
                    1,
                    -60,
                    0,
                    6
                )

            Value.Size =
                UDim2.fromOffset(48, 20)

            Value.BackgroundTransparency = 1

            Value.TextColor3 =
                yyudly.Theme.Accent

            Value.TextXAlignment =
                Enum.TextXAlignment.Right

            Value.Font =
                Enum.Font.GothamMedium

            Value.TextSize = 12

            Value.Parent = Holder

            local Bar =
                Instance.new("Frame")

            Bar.Position =
                UDim2.fromOffset(12, 39)

            Bar.Size =
                UDim2.new(
                    1,
                    -24,
                    0,
                    6
                )

            Bar.BackgroundColor3 =
                Color3.fromRGB(
                    55,
                    55,
                    65
                )

            Bar.BorderSizePixel = 0
            Bar.Parent = Holder

            MakeCorner(Bar, 6)

            local Fill =
                Instance.new("Frame")

            Fill.BackgroundColor3 =
                yyudly.Theme.Accent

            Fill.BorderSizePixel = 0
            Fill.Size =
                UDim2.new(0, 0, 1, 0)

            Fill.Parent = Bar

            MakeCorner(Fill, 6)

            local Dragging = false

            local function SetFromX(X)

                local Percentage =
                    math.clamp(
                        (
                            X
                            - Bar.AbsolutePosition.X
                        )
                        / Bar.AbsoluteSize.X,
                        0,
                        1
                    )

                local ValueNumber =
                    Slider.Min
                    + (
                        Slider.Max
                        - Slider.Min
                    )
                    * Percentage

                ValueNumber =
                    math.floor(
                        ValueNumber + 0.5
                    )

                Slider:Set(ValueNumber)

            end

            Bar.InputBegan:Connect(function(Input)

                if Input.UserInputType ==
                    Enum.UserInputType.MouseButton1
                    or Input.UserInputType ==
                    Enum.UserInputType.Touch then

                    Dragging = true
                    SetFromX(Input.Position.X)

                end

            end)

            UserInputService.InputChanged:Connect(function(Input)

                if not Dragging then
                    return
                end

                if Input.UserInputType ==
                    Enum.UserInputType.MouseMovement
                    or Input.UserInputType ==
                    Enum.UserInputType.Touch then

                    SetFromX(Input.Position.X)

                end

            end)

            UserInputService.InputEnded:Connect(function(Input)

                if Input.UserInputType ==
                    Enum.UserInputType.MouseButton1
                    or Input.UserInputType ==
                    Enum.UserInputType.Touch then

                    Dragging = false

                end

            end)

            function Slider:Set(NewValue, FireCallback)

                NewValue =
                    tonumber(NewValue)
                    or Slider.Min

                NewValue =
                    math.clamp(
                        NewValue,
                        Slider.Min,
                        Slider.Max
                    )

                Slider.CurrentValue =
                    NewValue

                local Percentage =
                    (
                        NewValue
                        - Slider.Min
                    )
                    /
                    (
                        Slider.Max
                        - Slider.Min
                    )

                Fill.Size =
                    UDim2.new(
                        Percentage,
                        0,
                        1,
                        0
                    )

                Value.Text =
                    tostring(NewValue)

                if FireCallback ~= false then

                    SafeCallback(
                        Slider.Callback,
                        NewValue
                    )

                end
            end

            function Slider:Get()

                return Slider.CurrentValue

            end

            function Slider:Destroy()

                Holder:Destroy()

            end

            Slider:Set(
                Slider.CurrentValue,
                false
            )

            return Slider
        end

        --------------------------------------------------
        -- DROPDOWN
        --------------------------------------------------

        function Tab:CreateDropdown(Options)

            Options = Options or {}

            local Dropdown = {}

            Dropdown.Options =
                Options.Options or {}

            Dropdown.CurrentOption =
                Options.CurrentOption
                or Dropdown.Options[1]

            Dropdown.Callback =
                Options.Callback

            local Index = 1

            for Number, Option
                in ipairs(Dropdown.Options) do

                if Option ==
                    Dropdown.CurrentOption then

                    Index = Number
                    break

                end
            end

            local Button =
                Instance.new("TextButton")

            Button.Size =
                UDim2.new(1, 0, 0, 42)

            Button.BackgroundColor3 =
                yyudly.Theme.Element

            Button.TextColor3 =
                yyudly.Theme.Text

            Button.Font =
                Enum.Font.GothamMedium

            Button.TextSize = 13

            Button.AutoButtonColor = false
            Button.Parent = Page

            MakeCorner(Button, 8)

            local function Update()

                Button.Text =
                    tostring(
                        Options.Name or "Dropdown"
                    )
                    .. " : "
                    .. tostring(
                        Dropdown.CurrentOption
                        or "None"
                    )

            end

            function Dropdown:Set(NewValue, FireCallback)

                for Number, Option
                    in ipairs(Dropdown.Options) do

                    if Option == NewValue then

                        Index = Number

                        Dropdown.CurrentOption =
                            NewValue

                        Update()

                        if FireCallback ~= false then

                            SafeCallback(
                                Dropdown.Callback,
                                NewValue
                            )

                        end

                        return true
                    end
                end

                return false
            end

            function Dropdown:SetOptions(NewOptions)

                if typeof(NewOptions) ~= "table" then
                    return
                end

                Dropdown.Options =
                    NewOptions

                Index = 1

                Dropdown.CurrentOption =
                    Dropdown.Options[1]

                Update()

            end

            function Dropdown:Get()

                return Dropdown.CurrentOption

            end

            function Dropdown:Destroy()

                Button:Destroy()

            end

            Button.MouseButton1Click:Connect(function()

                if #Dropdown.Options == 0 then
                    return
                end

                Index += 1

                if Index > #Dropdown.Options then
                    Index = 1
                end

                Dropdown:Set(
                    Dropdown.Options[Index]
                )

            end)

            Update()

            return Dropdown
        end

        --------------------------------------------------
        -- TEXTBOX
        --------------------------------------------------

        function Tab:CreateTextbox(Options)

            Options = Options or {}

            local Box =
                Instance.new("TextBox")

            Box.Size =
                UDim2.new(1, 0, 0, 42)

            Box.BackgroundColor3 =
                yyudly.Theme.Element

            Box.Text =
                Options.CurrentValue or ""

            Box.PlaceholderText =
                Options.PlaceholderText
                or "Enter text..."

            Box.Font =
                Enum.Font.Gotham

            Box.TextSize = 13

            Box.TextColor3 =
                yyudly.Theme.Text

            Box.PlaceholderColor3 =
                yyudly.Theme.SubText

            Box.ClearTextOnFocus = false
            Box.Parent = Page

            MakeCorner(Box, 8)

            Box.FocusLost:Connect(function()

                SafeCallback(
                    Options.Callback,
                    Box.Text
                )

            end)

            function Box:Set(Text)

                Box.Text =
                    tostring(Text or "")

            end

            return Box
        end

        --------------------------------------------------
        -- KEYBIND
        --------------------------------------------------

        function Tab:CreateKeybind(Options)

            Options = Options or {}

            local Keybind = {}

            Keybind.CurrentKey =
                Options.CurrentKeybind
                or Enum.KeyCode.RightShift

            Keybind.Callback =
                Options.Callback

            local Holder =
                Instance.new("Frame")

            Holder.Size =
                UDim2.new(1, 0, 0, 42)

            Holder.BackgroundColor3 =
                yyudly.Theme.Element

            Holder.Parent = Page

            MakeCorner(Holder, 8)

            local Button =
                Instance.new("TextButton")

            Button.Size =
                UDim2.fromScale(1, 1)

            Button.BackgroundTransparency = 1
            Button.Font =
                Enum.Font.GothamMedium

            Button.TextSize = 13

            Button.TextColor3 =
                yyudly.Theme.Text

            Button.Parent = Holder

            local Listening = false

            local function Update()

                if Listening then

                    Button.Text =
                        tostring(
                            Options.Name
                            or "Keybind"
                        )
                        .. " : Press a key..."

                else

                    Button.Text =
                        tostring(
                            Options.Name
                            or "Keybind"
                        )
                        .. " : "
                        .. Keybind.CurrentKey.Name

                end
            end

            Button.MouseButton1Click:Connect(function()

                Listening = true
                Update()

            end)

            local InputConnection

            InputConnection =
                UserInputService.InputBegan:Connect(
                    function(Input, Processed)

                        if Processed then
                            return
                        end

                        if Listening then

                            if Input.KeyCode ==
                                Enum.KeyCode.Unknown then
                                return
                            end

                            Keybind.CurrentKey =
                                Input.KeyCode

                            Listening = false

                            Update()

                            return
                        end

                        if Input.KeyCode ==
                            Keybind.CurrentKey then

                            SafeCallback(
                                Keybind.Callback,
                                Keybind.CurrentKey
                            )

                        end
                    end
                )

            function Keybind:Set(Key)

                if typeof(Key) ~= "EnumItem" then
                    return
                end

                Keybind.CurrentKey =
                    Key

                Listening = false

                Update()

            end

            function Keybind:Get()

                return Keybind.CurrentKey

            end

            function Keybind:Destroy()

                if InputConnection then
                    InputConnection:Disconnect()
                    InputConnection = nil
                end

                Holder:Destroy()

            end

            Update()

            return Keybind
        end

        --------------------------------------------------
        -- TAB BUTTON
        --------------------------------------------------

        TabButton.MouseButton1Click:Connect(function()

            SelectTab(TabName)

        end)

        Tabs[TabName] = Tab

        --------------------------------------------------
        -- FIRST TAB
        --------------------------------------------------

        if not CurrentTab then
            SelectTab(TabName)
        end

        return Tab
    end

    --------------------------------------------------
    -- WINDOW OBJECT
    --------------------------------------------------

    local Window = {}

    Window.ScreenGui = ScreenGui
    Window.Main = Main
    Window.Content = Content
    Window.Sidebar = Sidebar

    function Window:GetDevice()

        return Device

    end

    --------------------------------------------------
    -- THIS FIXES YOUR CreateTab ERROR
    --------------------------------------------------

    function Window:CreateTab(TabName)

        return CreateTab(TabName)

    end

    --------------------------------------------------
    -- VISIBILITY
    --------------------------------------------------

    function Window:SetVisible(Value)

        ScreenGui.Enabled =
            Value == true

    end

    function Window:GetVisible()

        return ScreenGui.Enabled

    end

    --------------------------------------------------
    -- DESTROY
    --------------------------------------------------

    function Window:Destroy()

        for _, Object in pairs(
            ScreenGui:GetDescendants()
        ) do

            if Object:IsA("UIStroke") then
                Object:Destroy()
            end

        end

        if ScreenGui then
            ScreenGui:Destroy()
        end

        for Index, ExistingWindow
            in ipairs(yyudly.Windows) do

            if ExistingWindow == Window then

                table.remove(
                    yyudly.Windows,
                    Index
                )

                break
            end
        end
    end

    --------------------------------------------------
    -- ADD WINDOW TO LIBRARY
    --------------------------------------------------

    table.insert(
        yyudly.Windows,
        Window
    )

    return Window
end

--------------------------------------------------
-- RETURN LIBRARY
--------------------------------------------------

return yyudly
