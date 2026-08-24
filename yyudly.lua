--[[
    yyudly.lua
    UI Library
    Version: 2.0

    Compatible API:
        yyudly:CreateWindow()
        Window:CreateTab()
        Tab:CreateSection()
        Tab:CreateLabel()
        Tab:CreateButton()
        Tab:CreateToggle()
        Tab:CreateSlider()
        Tab:CreateDropdown()
        Tab:CreateTextbox()
        Tab:CreateKeybind()

        Toggle:Set()
        Slider:Set()
        Dropdown:Set()
        Label:Set()
        Keybind:Set()

        yyudly:Notify()
        Window:SetVisible()
        Window:Destroy()
        Window:GetDevice()
]]

--------------------------------------------------
-- SERVICES
--------------------------------------------------

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

--------------------------------------------------
-- LIBRARY
--------------------------------------------------

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

--------------------------------------------------
-- INTERNAL STATE
--------------------------------------------------

yyudly.Windows = {}
yyudly.Notifications = {}

--------------------------------------------------
-- HELPERS
--------------------------------------------------

local function MakeCorner(Object, Radius)
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, Radius or 8)
    Corner.Parent = Object
    return Corner
end

local function MakeStroke(Object, Color, Transparency)
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color or yyudly.Theme.Stroke
    Stroke.Transparency = Transparency or 0
    Stroke.Thickness = 1
    Stroke.Parent = Object
    return Stroke
end

local function Tween(Object, Properties, Duration)
    local Info = TweenInfo.new(
        Duration or 0.15,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )

    local Animation = TweenService:Create(
        Object,
        Info,
        Properties
    )

    Animation:Play()

    return Animation
end

local function SafeCallback(Callback, ...)
    if typeof(Callback) ~= "function" then
        return
    end

    task.spawn(function()
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
