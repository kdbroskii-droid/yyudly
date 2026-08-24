-- yyudly.lua
-- Complete UI library + example

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
-- DEVICE
--------------------------------------------------

function yyudly:GetDevice()

    local Platform = UserInputService:GetPlatform()

    local isMobile =
        Platform == Enum.Platform.iOS
        or Platform == Enum.Platform.Android

    if isMobile then
        return "Mobile"
    end

    return "PC"
end

--------------------------------------------------
-- WINDOW
--------------------------------------------------

function yyudly:CreateWindow(Options)

    Options = Options or {}

    Options.Name = Options.Name or "yyudly"
    Options.Subtitle = Options.Subtitle or ""
    Options.Transparency = Options.Transparency or 0.55

    local Device = self:GetDevice()

    local Size

    if Device == "Mobile" then
        Size = UDim2.new(0.92, 0, 0.78, 0)
    else
        Size = Options.Size or UDim2.fromOffset(650, 480)
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "yyudly"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = Size
    Main.Position = UDim2.fromScale(0.5, 0.5)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = self.Theme.Background
    Main.BackgroundTransparency = Options.Transparency
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = Main

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 55)
    TopBar.BackgroundTransparency = 1
    TopBar.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Position = UDim2.fromOffset(18, 7)
    Title.Size = UDim2.new(1, -36, 0, 24)
    Title.BackgroundTransparency = 1
    Title.Text = Options.Name
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = self.Theme.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Position = UDim2.fromOffset(19, 30)
    Subtitle.Size = UDim2.new(1, -38, 0, 17)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = Options.Subtitle .. " • " .. Device
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = 11
    Subtitle.TextColor3 = self.Theme.SubText
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.Parent = TopBar

    --------------------------------------------------
    -- SIDEBAR
    --------------------------------------------------

    local SidebarWidth = Device == "Mobile" and 105 or 155

    local Sidebar = Instance.new("Frame")
    Sidebar.Position = UDim2.fromOffset(0, 55)
    Sidebar.Size = UDim2.new(0, SidebarWidth, 1, -55)
    Sidebar.BackgroundColor3 = self.Theme.Sidebar
    Sidebar.BackgroundTransparency =
        math.clamp(Options.Transparency + 0.1, 0, 0.95)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main

    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 12)
    SidebarCorner.Parent = Sidebar

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 6)
    TabLayout.Parent = Sidebar

    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingTop = UDim.new(0, 10)
    TabPadding.PaddingLeft = UDim.new(0, 7)
    TabPadding.PaddingRight = UDim.new(0, 7)
    TabPadding.Parent = Sidebar

    --------------------------------------------------
    -- CONTENT
    --------------------------------------------------

    local Content = Instance.new("Frame")
    Content.Position = UDim2.fromOffset(SidebarWidth, 55)
    Content.Size = UDim2.new(1, -SidebarWidth, 1, -55)
    Content.BackgroundTransparency = 1
    Content.Parent = Main

    local Pages = {}
    local Buttons = {}
    local CurrentTab

    --------------------------------------------------
    -- TAB
    --------------------------------------------------

    local function CreateTab(TabName)

        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, 0, 0, 36)
        TabButton.BackgroundColor3 = self.Theme.Accent
        TabButton.BackgroundTransparency = 1
        TabButton.Text = TabName
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.TextSize = 13
        TabButton.TextColor3 = self.Theme.SubText
        TabButton.AutoButtonColor = false
        TabButton.Parent = Sidebar

        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 7)
        ButtonCorner.Parent = TabButton

        local Page = Instance.new("ScrollingFrame")
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
        Layout.Parent = Page

        Pages[TabName] = Page
        Buttons[TabName] = TabButton

        local function Select()

            for Name, PageObject in pairs(Pages) do
                PageObject.Visible = Name == TabName
            end

            for Name, ButtonObject in pairs(Buttons) do

                if Name == TabName then
                    ButtonObject.BackgroundTransparency = 0
                    ButtonObject.TextColor3 =
                        Color3.new(1, 1, 1)
                else
                    ButtonObject.BackgroundTransparency = 1
                    ButtonObject.TextColor3 =
                        self.Theme.SubText
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

        function Tab:CreateLabel(Text)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, 0, 0, 30)
            Label.BackgroundTransparency = 1
            Label.Text = Text or ""
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 13
            Label.TextColor3 = yyudly.Theme.SubText
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Page

            return Label
        end

        --------------------------------------------------
        -- SECTION
        --------------------------------------------------

        function Tab:CreateSection(Text)

            local Section = Instance.new("TextLabel")
            Section.Size = UDim2.new(1, 0, 0, 25)
            Section.BackgroundTransparency = 1
            Section.Text = Text or ""
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

        function Tab:CreateButton(Options)

            Options = Options or {}

            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, 0, 0, 42)
            Button.BackgroundColor3 = yyudly.Theme.Element
            Button.BackgroundTransparency = 0.1
            Button.Text = Options.Name or "Button"
            Button.Font = Enum.Font.GothamMedium
            Button.TextSize = 13
            Button.TextColor3 = yyudly.Theme.Text
            Button.AutoButtonColor = false
            Button.Parent = Page

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 8)
            Corner.Parent = Button

            Button.MouseButton1Click:Connect(function()

                if Options.Callback then
                    Options.Callback()
                end

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
                Options.CurrentValue or false

            Toggle.Callback =
                Options.Callback

            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, 0, 0, 42)
            Button.BackgroundColor3 = yyudly.Theme.Element
            Button.BackgroundTransparency = 0.1
            Button.Text = Options.Name or "Toggle"
            Button.Font = Enum.Font.GothamMedium
            Button.TextSize = 13
            Button.TextColor3 = yyudly.Theme.Text
            Button.TextXAlignment = Enum.TextXAlignment.Left
            Button.AutoButtonColor = false
            Button.Parent = Page

            local Padding = Instance.new("UIPadding")
            Padding.PaddingLeft = UDim.new(0, 12)
            Padding.Parent = Button

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 8)
            Corner.Parent = Button

            function Toggle:Set(Value)

                Toggle.CurrentValue = Value

                Button.Text =
                    (Options.Name or "Toggle")
                    .. " : "
                    .. (Value and "ON" or "OFF")

                if Toggle.Callback then
                    Toggle.Callback(Value)
                end

            end

            Button.MouseButton1Click:Connect(function()

                Toggle:Set(
                    not Toggle.CurrentValue
                )

            end)

            Toggle:Set(Toggle.CurrentValue)

            return Toggle
        end

        --------------------------------------------------
        -- SLIDER
        --------------------------------------------------

        function Tab:CreateSlider(Options)

            Options = Options or {}

            local Slider = {}

            Slider.Min = Options.Min or 0
            Slider.Max = Options.Max or 100
            Slider.CurrentValue =
                Options.Default or Slider.Min
            Slider.Callback =
                Options.Callback

            local Holder = Instance.new("Frame")
            Holder.Size = UDim2.new(1, 0, 0, 62)
            Holder.BackgroundColor3 = yyudly.Theme.Element
            Holder.BackgroundTransparency = 0.1
            Holder.Parent = Page

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 8)
            Corner.Parent = Holder

            local Label = Instance.new("TextLabel")
            Label.Position = UDim2.fromOffset(12, 6)
            Label.Size = UDim2.new(1, -24, 0, 20)
            Label.BackgroundTransparency = 1
            Label.Text = Options.Name or "Slider"
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 13
            Label.TextColor3 = yyudly.Theme.Text
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Holder

            local Value = Instance.new("TextLabel")
            Value.Position = UDim2.new(1, -60, 0, 6)
            Value.Size = UDim2.fromOffset(48, 20)
            Value.BackgroundTransparency = 1
            Value.TextColor3 = yyudly.Theme.Accent
            Value.Text = tostring(Slider.CurrentValue)
            Value.Parent = Holder

            local Bar = Instance.new("Frame")
            Bar.Position = UDim2.fromOffset(12, 39)
            Bar.Size = UDim2.new(1, -24, 0, 6)
            Bar.BackgroundColor3 =
                Color3.fromRGB(55, 55, 65)
            Bar.Parent = Holder

            local BarCorner = Instance.new("UICorner")
            BarCorner.CornerRadius = UDim.new(0, 6)
            BarCorner.Parent = Bar

            local Fill = Instance.new("Frame")
            Fill.BackgroundColor3 =
                yyudly.Theme.Accent
            Fill.Size = UDim2.new(0, 0, 1, 0)
            Fill.Parent = Bar

            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(0, 6)
            FillCorner.Parent = Fill

            function Slider:Set(NewValue)

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
                    (NewValue - Slider.Min)
                    /
                    (Slider.Max - Slider.Min)

                Fill.Size =
                    UDim2.new(
                        Percentage,
                        0,
                        1,
                        0
                    )

                Value.Text =
                    tostring(NewValue)

                if Slider.Callback then
                    Slider.Callback(NewValue)
                end

            end

            Slider:Set(Slider.CurrentValue)

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

            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, 0, 0, 42)
            Button.BackgroundColor3 =
                yyudly.Theme.Element
            Button.Text =
                (Options.Name or "Dropdown")
                .. " : "
                .. tostring(
                    Dropdown.CurrentOption or "None"
                )
            Button.Font = Enum.Font.GothamMedium
            Button.TextSize = 13
            Button.TextColor3 =
                yyudly.Theme.Text
            Button.AutoButtonColor = false
            Button.Parent = Page

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 8)
            Corner.Parent = Button

            local Index = 1

            function Dropdown:Set(NewValue)

                for Number, Option
                    in ipairs(Dropdown.Options) do

                    if Option == NewValue then

                        Index = Number
                        Dropdown.CurrentOption =
                            NewValue

                        Button.Text =
                            (Options.Name or "Dropdown")
                            .. " : "
                            .. tostring(NewValue)

                        if Dropdown.Callback then
                            Dropdown.Callback(NewValue)
                        end

                        break
                    end
                end
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

            return Dropdown
        end

        --------------------------------------------------
        -- TEXTBOX
        --------------------------------------------------

        function Tab:CreateTextbox(Options)

            Options = Options or {}

            local Box = Instance.new("TextBox")
            Box.Size = UDim2.new(1, 0, 0, 42)
            Box.BackgroundColor3 =
                yyudly.Theme.Element
            Box.Text =
                Options.CurrentValue or ""
            Box.PlaceholderText =
                Options.PlaceholderText
                or "Enter text..."
            Box.Font = Enum.Font.Gotham
            Box.TextSize = 13
            Box.TextColor3 =
                yyudly.Theme.Text
            Box.PlaceholderColor3 =
                yyudly.Theme.SubText
            Box.ClearTextOnFocus = false
            Box.Parent = Page

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 8)
            Corner.Parent = Box

            Box.FocusLost:Connect(function()

                if Options.Callback then
                    Options.Callback(Box.Text)
                end

            end)

            return Box
        end

        --------------------------------------------------
        -- KEYBIND
        --------------------------------------------------

        function Tab:CreateKeybind(Options)

            Options = Options or {}

            local Keybind =
                Instance.new("Frame")

            Keybind.Size =
                UDim2.new(1, 0, 0, 42)

            Keybind.BackgroundColor3 =
                yyudly.Theme.Element

            Keybind.Parent = Page

            local Corner =
                Instance.new("UICorner")

            Corner.CornerRadius =
                UDim.new(0, 8)

            Corner.Parent = Keybind

            local CurrentKey =
                Options.CurrentKeybind
                or Enum.KeyCode.RightShift

            local Button =
                Instance.new("TextButton")

            Button.Size =
                UDim2.new(1, 0, 1, 0)

            Button.BackgroundTransparency = 1

            Button.Text =
                (Options.Name or "Keybind")
                .. " : "
                .. CurrentKey.Name

            Button.Font =
                Enum.Font.GothamMedium

            Button.TextSize = 13

            Button.TextColor3 =
                yyudly.Theme.Text

            Button.Parent = Keybind

            local Listening = false

            Button.MouseButton1Click:Connect(function()

                Listening = true
                Button.Text = "Press a key..."

            end)

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

                        CurrentKey =
                            Input.KeyCode

                        Listening = false

                        Button.Text =
                            (Options.Name or "Keybind")
                            .. " : "
                            .. CurrentKey.Name

                        return
                    end

                    if Input.KeyCode ==
                        CurrentKey then

                        if Options.Callback then
                            Options.Callback(CurrentKey)
                        end

                    end
                end
            )

            function Keybind:Set(Key)

                CurrentKey = Key

                Button.Text =
                    (Options.Name or "Keybind")
                    .. " : "
                    .. Key.Name

            end

            return Keybind
        end

        return Tab
    end

    --------------------------------------------------
    -- WINDOW OBJECT
    --------------------------------------------------

    local Window = {}

    function Window:GetDevice()
        return Device
    end

    function Window:SetVisible(Value)
        ScreenGui.Enabled = Value
    end

    function Window:Destroy()
        ScreenGui:Destroy()
    end

    return Window
end

--------------------------------------------------
-- EXAMPLE
--------------------------------------------------

local yyudlygui = yyudly:CreateWindow({
    Name = "AI Aimbot",
    Subtitle = "Advanced Roblox Aimbot",
    Transparency = 0.55
})

local yyudlytab =
    yyudlygui:CreateTab("Main")

yyudlytab:CreateSection("Example Controls")

yyudlytab:CreateLabel(
    "yyudly UI Library"
)

yyudlytab:CreateButton({
    Name = "Test Button",

    Callback = function()

        print("yyudly button works!")

    end
})

local Toggle =
    yyudlytab:CreateToggle({

        Name = "Example Toggle",

        CurrentValue = false,

        Callback = function(Value)

            print(
                "Toggle:",
                Value
            )

        end
    })

local Slider =
    yyudlytab:CreateSlider({

        Name = "Example Slider",

        Min = 0,

        Max = 100,

        Default = 50,

        Callback = function(Value)

            print(
                "Slider:",
                Value
            )

        end
    })

yyudlytab:CreateDropdown({

    Name = "Example Dropdown",

    Options = {
        "Option 1",
        "Option 2",
        "Option 3"
    },

    CurrentOption =
        "Option 1",

    Callback = function(Value)

        print(
            "Selected:",
            Value
        )

    end
})

yyudlytab:CreateTextbox({

    Name = "Example Textbox",

    PlaceholderText =
        "Type something...",

    Callback = function(Text)

        print(
            "Text:",
            Text
        )

    end
})

yyudlytab:CreateKeybind({

    Name = "Example Keybind",

    CurrentKeybind =
        Enum.KeyCode.RightShift,

    Callback = function(Key)

        print(
            "Key pressed:",
            Key.Name
        )

    end
})

yyudlytab:CreateSection(
    "Device Information"
)

yyudlytab:CreateLabel(
    "Device: "
    .. yyudlygui:GetDevice()
)

--------------------------------------------------
-- DONE
--------------------------------------------------

print(
    "yyudly loaded on "
    .. yyudlygui:GetDevice()
)yyudly.Theme = {
    Background = Color3.fromRGB(18, 18, 22),
    Sidebar = Color3.fromRGB(14, 14, 18),

    Element = Color3.fromRGB(27, 27, 33),
    ElementHover = Color3.fromRGB(37, 37, 45),

    Accent = Color3.fromRGB(125, 85, 255),

    Text = Color3.fromRGB(240, 240, 245),
    SubText = Color3.fromRGB(160, 160, 170),

    Stroke = Color3.fromRGB(48, 48, 58),

    BackgroundTransparency = 0.12,
    SidebarTransparency = 0.16,
    ElementTransparency = 0.10
}

--------------------------------------------------
-- UTILITY
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
    local tween = TweenService:Create(
        object,
        TweenInfo.new(
            duration or 0.15,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        properties
    )

    tween:Play()

    return tween
end

--------------------------------------------------
-- DEVICE DETECTION
--------------------------------------------------

function yyudly:GetDevice()

    local touch = UserInputService.TouchEnabled
    local keyboard = UserInputService.KeyboardEnabled
    local mouse = UserInputService.MouseEnabled
    local gamepad = UserInputService.GamepadEnabled

    local camera = workspace.CurrentCamera

    local viewport = Vector2.new(1920, 1080)

    if camera then
        viewport = camera.ViewportSize
    end

    -- Console
    if gamepad and not keyboard and not touch then
        return "Console"
    end

    -- Touch devices
    if touch then

        -- Tablet
        if viewport.X >= 700 or viewport.Y >= 700 then
            return "Tablet"
        end

        -- Phone
        return "Mobile"
    end

    -- PC / Laptop
    if keyboard and mouse then
        return "PC"
    end

    return "Unknown"
end

--------------------------------------------------
-- DEVICE SIZE
--------------------------------------------------

function yyudly:GetDeviceSize(device)

    device = device or self:GetDevice()

    if device == "Mobile" then
        return UDim2.new(0.92, 0, 0.78, 0)
    end

    if device == "Tablet" then
        return UDim2.new(0.78, 0, 0.78, 0)
    end

    if device == "Console" then
        return UDim2.fromOffset(700, 450)
    end

    if device == "PC" then
        return UDim2.fromOffset(650, 430)
    end

    return UDim2.fromOffset(650, 430)
end

--------------------------------------------------
-- WINDOW
--------------------------------------------------

function yyudly:CreateWindow(settings)

    settings = settings or {}

    local windowName = settings.Name or "yyudly"
    local customSubtitle = settings.Subtitle or "yyudly UI Library"

    local device = self:GetDevice()

    local windowSize =
        settings.Size
        or self:GetDeviceSize(device)

    local transparency =
        settings.Transparency
        or self.Theme.BackgroundTransparency

    local sidebarTransparency =
        settings.SidebarTransparency
        or self.Theme.SidebarTransparency

    local elementTransparency =
        settings.ElementTransparency
        or self.Theme.ElementTransparency

    --------------------------------------------------
    -- GUI
    --------------------------------------------------

    local gui = Create("ScreenGui", {
        Name = "yyudly",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    --------------------------------------------------
    -- DEVICE LABEL
    --------------------------------------------------

    local subtitleText =
        customSubtitle .. " • " .. device

    --------------------------------------------------
    -- MAIN WINDOW
    --------------------------------------------------

    local main = Create("Frame", {
        Name = "Window",

        Size = windowSize,

        Position = UDim2.fromScale(0.5, 0.5),

        AnchorPoint = Vector2.new(0.5, 0.5),

        BackgroundColor3 = self.Theme.Background,

        BackgroundTransparency = transparency,

        BorderSizePixel = 0
    })

    main.Parent = gui

    AddCorner(main, 12)
    AddStroke(main, self.Theme.Stroke, 1)

    --------------------------------------------------
    -- TOP BAR
    --------------------------------------------------

    local topbar = Create("Frame", {
        Name = "Topbar",

        Size = UDim2.new(1, 0, 0, 55),

        BackgroundTransparency = 1
    })

    topbar.Parent = main

    --------------------------------------------------
    -- TITLE
    --------------------------------------------------

    local title = Create("TextLabel", {
        Position = UDim2.fromOffset(18, 8),

        Size = UDim2.new(1, -36, 0, 22),

        BackgroundTransparency = 1,

        Text = windowName,

        Font = Enum.Font.GothamBold,

        TextSize = 18,

        TextColor3 = self.Theme.Text,

        TextXAlignment = Enum.TextXAlignment.Left
    })

    title.Parent = topbar

    --------------------------------------------------
    -- SUBTITLE
    --------------------------------------------------

    local subtitle = Create("TextLabel", {
        Position = UDim2.fromOffset(19, 30),

        Size = UDim2.new(1, -38, 0, 16),

        BackgroundTransparency = 1,

        Text = subtitleText,

        Font = Enum.Font.Gotham,

        TextSize = 11,

        TextColor3 = self.Theme.SubText,

        TextXAlignment = Enum.TextXAlignment.Left
    })

    subtitle.Parent = topbar

    --------------------------------------------------
    -- SIDEBAR SIZE
    --------------------------------------------------

    local sidebarWidth = 155

    if device == "Mobile" then
        sidebarWidth = 105
    elseif device == "Tablet" then
        sidebarWidth = 130
    elseif device == "Console" then
        sidebarWidth = 150
    end

    --------------------------------------------------
    -- SIDEBAR
    --------------------------------------------------

    local sidebar = Create("Frame", {
        Name = "Sidebar",

        Position = UDim2.fromOffset(0, 55),

        Size = UDim2.new(
            0,
            sidebarWidth,
            1,
            -55
        ),

        BackgroundColor3 = self.Theme.Sidebar,

        BackgroundTransparency = sidebarTransparency,

        BorderSizePixel = 0
    })

    sidebar.Parent = main

    AddCorner(sidebar, 12)

    local sidebarPadding = Instance.new("UIPadding")

    sidebarPadding.PaddingTop = UDim.new(0, 12)
    sidebarPadding.PaddingLeft = UDim.new(0, 8)
    sidebarPadding.PaddingRight = UDim.new(0, 8)

    sidebarPadding.Parent = sidebar

    local tabLayout = Instance.new("UIListLayout")

    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    tabLayout.Parent = sidebar

    --------------------------------------------------
    -- CONTENT
    --------------------------------------------------

    local content = Create("Frame", {
        Name = "Content",

        Position = UDim2.fromOffset(
            sidebarWidth,
            55
        ),

        Size = UDim2.new(
            1,
            -sidebarWidth,
            1,
            -55
        ),

        BackgroundTransparency = 1
    })

    content.Parent = main

    --------------------------------------------------
    -- TABLES
    --------------------------------------------------

    local pages = {}
    local tabButtons = {}

    local currentTab = nil

    --------------------------------------------------
    -- NOTIFICATIONS
    --------------------------------------------------

    local notificationContainer = Create("Frame", {
        Name = "Notifications",

        Position = UDim2.new(
            1,
            -310,
            0,
            15
        ),

        Size = UDim2.fromOffset(
            295,
            0
        ),

        AutomaticSize = Enum.AutomaticSize.Y,

        BackgroundTransparency = 1
    })

    notificationContainer.Parent = gui

    local notificationLayout = Instance.new("UIListLayout")

    notificationLayout.Padding = UDim.new(0, 8)

    notificationLayout.HorizontalAlignment =
        Enum.HorizontalAlignment.Right

    notificationLayout.SortOrder =
        Enum.SortOrder.LayoutOrder

    notificationLayout.Parent =
        notificationContainer

    --------------------------------------------------
    -- NOTIFY
    --------------------------------------------------

    function yyudly:Notify(data)

        data = data or {}

        local notification = Create("Frame", {
            Size = UDim2.fromOffset(280, 72),

            BackgroundColor3 =
                self.Theme.Element,

            BackgroundTransparency = 1,

            BorderSizePixel = 0
        })

        notification.Parent =
            notificationContainer

        AddCorner(notification, 9)

        AddStroke(
            notification,
            self.Theme.Stroke
        )

        local notificationTitle =
            Create("TextLabel", {

                Position =
                    UDim2.fromOffset(12, 8),

                Size =
                    UDim2.new(1, -24, 0, 20),

                BackgroundTransparency = 1,

                Text =
                    data.Title or "yyudly",

                Font =
                    Enum.Font.GothamBold,

                TextSize = 14,

                TextColor3 =
                    self.Theme.Text,

                TextTransparency = 1,

                TextXAlignment =
                    Enum.TextXAlignment.Left
            })

        notificationTitle.Parent =
            notification

        local notificationContent =
            Create("TextLabel", {

                Position =
                    UDim2.fromOffset(12, 30),

                Size =
                    UDim2.new(1, -24, 0, 30),

                BackgroundTransparency = 1,

                Text =
                    data.Content or "",

                Font =
                    Enum.Font.Gotham,

                TextSize = 12,

                TextColor3 =
                    self.Theme.SubText,

                TextTransparency = 1,

                TextWrapped = true,

                TextXAlignment =
                    Enum.TextXAlignment.Left
            })

        notificationContent.Parent =
            notification

        Tween(
            notification,
            {
                BackgroundTransparency = 0
            },
            0.2
        )

        Tween(
            notificationTitle,
            {
                TextTransparency = 0
            },
            0.2
        )

        Tween(
            notificationContent,
            {
                TextTransparency = 0
            },
            0.2
        )

        task.delay(
            data.Duration or 3,
            function()

                if not notification.Parent then
                    return
                end

                Tween(
                    notification,
                    {
                        BackgroundTransparency = 1
                    },
                    0.2
                )

                Tween(
                    notificationTitle,
                    {
                        TextTransparency = 1
                    },
                    0.2
                )

                Tween(
                    notificationContent,
                    {
                        TextTransparency = 1
                    },
                    0.2
                )

                task.wait(0.25)

                notification:Destroy()

            end
        )
    end

    --------------------------------------------------
    -- CREATE TAB
    --------------------------------------------------

    function window:CreateTab(tabName)

        local tabButton = Create("TextButton", {

            Name = tabName,

            Size = UDim2.new(
                1,
                0,
                0,
                36
            ),

            BackgroundColor3 =
                yyudly.Theme.Accent,

            BackgroundTransparency = 1,

            BorderSizePixel = 0,

            Text = tabName,

            Font =
                Enum.Font.GothamMedium,

            TextSize = 13,

            TextColor3 =
                yyudly.Theme.SubText,

            AutoButtonColor = false
        })

        tabButton.Parent = sidebar

        AddCorner(tabButton, 7)

        --------------------------------------------------
        -- PAGE
        --------------------------------------------------

        local page = Create("ScrollingFrame", {

            Name =
                tabName .. "_Page",

            Position =
                UDim2.fromOffset(15, 10),

            Size =
                UDim2.new(
                    1,
                    -30,
                    1,
                    -20
                ),

            BackgroundTransparency = 1,

            BorderSizePixel = 0,

            ScrollBarThickness = 3,

            ScrollBarImageColor3 =
                yyudly.Theme.Accent,

            CanvasSize =
                UDim2.new(0, 0, 0, 0),

            AutomaticCanvasSize =
                Enum.AutomaticSize.Y
        })

        page.Parent = content

        local padding =
            Instance.new("UIPadding")

        padding.PaddingLeft =
            UDim.new(0, 3)

        padding.PaddingRight =
            UDim.new(0, 3)

        padding.PaddingBottom =
            UDim.new(0, 10)

        padding.Parent = page

        local layout =
            Instance.new("UIListLayout")

        layout.Padding =
            UDim.new(0, 8)

        layout.SortOrder =
            Enum.SortOrder.LayoutOrder

        layout.Parent = page

        pages[tabName] = page
        tabButtons[tabName] = tabButton

        --------------------------------------------------
        -- SELECT TAB
        --------------------------------------------------

        local function selectTab()

            for name, otherPage in pairs(pages) do

                otherPage.Visible =
                    name == tabName

            end

            for name, otherButton in
                pairs(tabButtons) do

                if name == tabName then

                    otherButton.BackgroundTransparency =
                        0

                    otherButton.BackgroundColor3 =
                        yyudly.Theme.Accent

                    otherButton.TextColor3 =
                        Color3.new(1, 1, 1)

                else

                    otherButton.BackgroundTransparency =
                        1

                    otherButton.TextColor3 =
                        yyudly.Theme.SubText

                end
            end

            currentTab = tabName
        end

        tabButton.MouseButton1Click:Connect(
            selectTab
        )

        if not currentTab then
            selectTab()
        end

        --------------------------------------------------
        -- TAB OBJECT
        --------------------------------------------------

        local tab = {}

        --------------------------------------------------
        -- LABEL
        --------------------------------------------------

        function tab:CreateLabel(text)

            local label = Create(
                "TextLabel",
                {

                    Size =
                        UDim2.new(1, 0, 0, 30),

                    BackgroundTransparency = 1,

                    Text = text,

                    Font =
                        Enum.Font.Gotham,

                    TextSize = 13,

                    TextColor3 =
                        yyudly.Theme.SubText,

                    TextXAlignment =
                        Enum.TextXAlignment.Left
                }
            )

            label.Parent = page

            return label
        end

        --------------------------------------------------
        -- SECTION
        --------------------------------------------------

        function tab:CreateSection(text)

            local section = Create(
                "TextLabel",
                {

                    Size =
                        UDim2.new(1, 0, 0, 25),

                    BackgroundTransparency = 1,

                    Text = text,

                    Font =
                        Enum.Font.GothamBold,

                    TextSize = 12,

                    TextColor3 =
                        yyudly.Theme.Accent,

                    TextXAlignment =
                        Enum.TextXAlignment.Left
                }
            )

            section.Parent = page

            return section
        end

        --------------------------------------------------
        -- BUTTON
        --------------------------------------------------

        function tab:CreateButton(data)

            data = data or {}

            local button = Create(
                "TextButton",
                {

                    Size =
                        UDim2.new(1, 0, 0, 42),

                    BackgroundColor3 =
                        yyudly.Theme.Element,

                    BackgroundTransparency =
                        elementTransparency,

                    BorderSizePixel = 0,

                    Text =
                        data.Name or "Button",

                    Font =
                        Enum.Font.GothamMedium,

                    TextSize = 13,

                    TextColor3 =
                        yyudly.Theme.Text,

                    AutoButtonColor = false
                }
            )

            button.Parent = page

            AddCorner(button, 8)

            button.MouseEnter:Connect(
                function()

                    Tween(
                        button,
                        {
                            BackgroundColor3 =
                                yyudly.Theme.ElementHover
                        },
                        0.15
                    )

                end
            )

            button.MouseLeave:Connect(
                function()

                    Tween(
                        button,
                        {
                            BackgroundColor3 =
                                yyudly.Theme.Element
                        },
                        0.15
                    )

                end
            )

            button.MouseButton1Click:Connect(
                function()

                    if data.Callback then
                        data.Callback()
                    end

                end
            )

            return button
        end

        --------------------------------------------------
        -- TOGGLE
        --------------------------------------------------

        function tab:CreateToggle(data)

            data = data or {}

            local value =
                data.CurrentValue or false

            local holder = Create(
                "TextButton",
                {

                    Size =
                        UDim2.new(1, 0, 0, 42),

                    BackgroundColor3 =
                        yyudly.Theme.Element,

                    BackgroundTransparency =
                        elementTransparency,

                    BorderSizePixel = 0,

                    Text = "",

                    AutoButtonColor = false
                }
            )

            holder.Parent = page

            AddCorner(holder, 8)

            local label = Create(
                "TextLabel",
                {

                    Position =
                        UDim2.fromOffset(12, 0),

                    Size =
                        UDim2.new(
                            1,
                            -70,
                            1,
                            0
                        ),

                    BackgroundTransparency = 1,

                    Text =
                        data.Name or "Toggle",

                    Font =
                        Enum.Font.GothamMedium,

                    TextSize = 13,

                    TextColor3 =
                        yyudly.Theme.Text,

                    TextXAlignment =
                        Enum.TextXAlignment.Left
                }
            )

            label.Parent = holder

            local switch = Create(
                "Frame",
                {

                    Position =
                        UDim2.new(
                            1,
                            -48,
                            0.5,
                            -10
                        ),

                    Size =
                        UDim2.fromOffset(36, 20),

                    BackgroundColor3 =
                        Color3.fromRGB(
                            50,
                            50,
                            58
                        ),

                    BorderSizePixel = 0
                }
            )

            switch.Parent = holder

            AddCorner(switch, 10)

            local knob = Create(
                "Frame",
                {

                    Position =
                        UDim2.fromOffset(3, 3),

                    Size =
                        UDim2.fromOffset(14, 14),

                    BackgroundColor3 =
                        Color3.fromRGB(
                            230,
                            230,
                            235
                        ),

                    BorderSizePixel = 0
                }
            )

            knob.Parent = switch

            AddCorner(knob, 20)

            local function update()

                Tween(
                    switch,
                    {
                        BackgroundColor3 =
                            value
                            and yyudly.Theme.Accent
                            or Color3.fromRGB(
                                50,
                                50,
                                58
                            )
                    }
                )

                Tween(
                    knob,
                    {
                        Position =
                            value
                            and UDim2.new(
                                1,
                                -17,
                                0,
                                3
                            )
                            or UDim2.fromOffset(
                                3,
                                3
                            )
                    }
                )

                if data.Callback then
                    data.Callback(value)
                end
            end

            holder.MouseButton1Click:Connect(
                function()

                    value = not value

                    update()

                end
            )

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
        -- SLIDER
        --------------------------------------------------

        function tab:CreateSlider(data)

            data = data or {}

            local minimum =
                data.Min or 0

            local maximum =
                data.Max or 100

            local value =
                math.clamp(
                    data.Default or minimum,
                    minimum,
                    maximum
                )

            local holder = Create(
                "Frame",
                {

                    Size =
                        UDim2.new(1, 0, 0, 62),

                    BackgroundColor3 =
                        yyudly.Theme.Element,

                    BackgroundTransparency =
                        elementTransparency,

                    BorderSizePixel = 0
                }
            )

            holder.Parent = page

            AddCorner(holder, 8)

            local label = Create(
                "TextLabel",
                {

                    Position =
                        UDim2.fromOffset(12, 7),

                    Size =
                        UDim2.new(
                            1,
                            -70,
                            0,
                            20
                        ),

                    BackgroundTransparency = 1,

                    Text =
                        data.Name or "Slider",

                    Font =
                        Enum.Font.GothamMedium,

                    TextSize = 13,

                    TextColor3 =
                        yyudly.Theme.Text,

                    TextXAlignment =
                        Enum.TextXAlignment.Left
                }
            )

            label.Parent = holder

            local valueLabel = Create(
                "TextLabel",
                {

                    Position =
                        UDim2.new(
                            1,
                            -60,
                            0,
                            7
                        ),

                    Size =
                        UDim2.fromOffset(
                            48,
                            20
                        ),

                    BackgroundTransparency = 1,

                    Text =
                        tostring(value),

                    Font =
                        Enum.Font.GothamMedium,

                    TextSize = 12,

                    TextColor3 =
                        yyudly.Theme.Accent,

                    TextXAlignment =
                        Enum.TextXAlignment.Right
                }
            )

            valueLabel.Parent = holder

            local bar = Create(
                "Frame",
                {

                    Position =
                        UDim2.fromOffset(
                            12,
                            38
                        ),

                    Size =
                        UDim2.new(
                            1,
                            -24,
                            0,
                            6
                        ),

                    BackgroundColor3 =
                        Color3.fromRGB(
                            50,
                            50,
                            58
                        ),

                    BorderSizePixel = 0
                }
            )

            bar.Parent = holder

            AddCorner(bar, 6)

            local percentage =
                (value - minimum) /
                (maximum - minimum)

            local fill = Create(
                "Frame",
                {

                    Size =
                        UDim2.new(
                            percentage,
                            0,
                            1,
                            0
                        ),

                    BackgroundColor3 =
                        yyudly.Theme.Accent,

                    BorderSizePixel = 0
                }
            )

            fill.Parent = bar

            AddCorner(fill, 6)

            local dragging = false

            local function setValue(x)

                local percent =
                    math.clamp(
                        (
                            x -
                            bar.AbsolutePosition.X
                        )
                        /
                        bar.AbsoluteSize.X,

                        0,
                        1
                    )

                value =
                    math.floor(
                        minimum +
                        (
                            maximum -
                            minimum
                        )
                        *
                        percent
                    )

                fill.Size =
                    UDim2.new(
                        percent,
                        0,
                        1,
                        0
                    )

                valueLabel.Text =
                    tostring(value)

                if data.Callback then
                    data.Callback(value)
                end
            end

            bar.InputBegan:Connect(
                function(input)

                    if input.UserInputType ==
                        Enum.UserInputType.MouseButton1
                        or
                        input.UserInputType ==
                        Enum.UserInputType.Touch then

                        dragging = true

                        setValue(
                            input.Position.X
                        )
                    end
                end
            )

            UserInputService.InputChanged:Connect(
                function(input)

                    if not dragging then
                        return
                    end

                    if input.UserInputType ==
                        Enum.UserInputType.MouseMovement
                        or
                        input.UserInputType ==
                        Enum.UserInputType.Touch then

                        setValue(
                            input.Position.X
                        )
                    end
                end
            )

            UserInputService.InputEnded:Connect(
                function(input)

                    if input.UserInputType ==
                        Enum.UserInputType.MouseButton1
                        or
                        input.UserInputType ==
                        Enum.UserInputType.Touch then

                        dragging = false
                    end
                end
            )

            return {

                Set = function(_, newValue)

                    value =
                        math.clamp(
                            newValue,
                            minimum,
                            maximum
                        )

                    local percent =
                        (
                            value -
                            minimum
                        )
                        /
                        (
                            maximum -
                            minimum
                        )

                    fill.Size =
                        UDim2.new(
                            percent,
                            0,
                            1,
                            0
                        )

                    valueLabel.Text =
                        tostring(value)

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
        -- DROPDOWN
        --------------------------------------------------

        function tab:CreateDropdown(data)

            data = data or {}

            local options =
                data.Options or {}

            local selected =
                data.CurrentOption
                or options[1]

            local holder = Create(
                "TextButton",
                {

                    Size =
                        UDim2.new(1, 0, 0, 42),

                    BackgroundColor3 =
                        yyudly.Theme.Element,

                    BackgroundTransparency =
                        elementTransparency,

                    BorderSizePixel = 0,

                    Text = "",

                    AutoButtonColor = false
                }
            )

            holder.Parent = page

            AddCorner(holder, 8)

            local nameLabel = Create(
                "TextLabel",
                {

                    Position =
                        UDim2.fromOffset(12, 0),

                    Size =
                        UDim2.new(
                            0.5,
                            0,
                            1,
                            0
                        ),

                    BackgroundTransparency = 1,

                    Text =
                        data.Name or "Dropdown",

                    Font =
                        Enum.Font.GothamMedium,

                    TextSize = 13,

                    TextColor3 =
                        yyudly.Theme.Text,

                    TextXAlignment =
                        Enum.TextXAlignment.Left
                }
            )

            nameLabel.Parent = holder

            local selectedLabel = Create(
                "TextLabel",
                {

                    Position =
                        UDim2.new(
                            0.5,
                            0,
                            0,
                            0
                        ),

                    Size =
                        UDim2.new(
                            0.5,
                            -12,
                            1,
                            0
                        ),

                    BackgroundTransparency = 1,

                    Text =
                        tostring(
                            selected
                            or "None"
                        ),

                    Font =
                        Enum.Font.Gotham,

                    TextSize = 12,

                    TextColor3 =
                        yyudly.Theme.Accent,

                    TextXAlignment =
                        Enum.TextXAlignment.Right
                }
            )

            selectedLabel.Parent = holder

            local index = 1

            for i, option in
                ipairs(options) do

                if option == selected then
                    index = i
                    break
                end
            end

            holder.MouseButton1Click:Connect(
                function()

                    if #options == 0 then
                        return
                    end

                    index += 1

                    if index > #options then
                        index = 1
                    end

                    selected =
                        options[index]

                    selectedLabel.Text =
                        tostring(selected)

                    if data.Callback then
                        data.Callback(
                            selected
                        )
                    end
                end
            )

            return {

                Set = function(_, option)

                    for i, value in
                        ipairs(options) do

                        if value == option then

                            index = i
                            selected = option

                            selectedLabel.Text =
                                tostring(option)

                            if data.Callback then
                                data.Callback(
                                    option
                                )
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
        -- TEXTBOX
        --------------------------------------------------

        function tab:CreateTextbox(data)

            data = data or {}

            local holder = Create(
                "Frame",
                {

                    Size =
                        UDim2.new(
                            1,
                            0,
                            0,
                            52
                        ),

                    BackgroundColor3 =
                        yyudly.Theme.Element,

                    BackgroundTransparency =
                        elementTransparency,

                    BorderSizePixel = 0
                }
            )

            holder.Parent = page

            AddCorner(holder, 8)

            local label = Create(
                "TextLabel",
                {

                    Position =
                        UDim2.fromOffset(
                            12,
                            6
                        ),

                    Size =
                        UDim2.new(
                            0.4,
                            0,
                            0,
                            18
                        ),

                    BackgroundTransparency = 1,

                    Text =
                        data.Name
                        or "Textbox",

                    Font =
                        Enum.Font.GothamMedium,

                    TextSize = 12,

                    TextColor3 =
                        yyudly.Theme.Text,

                    TextXAlignment =
                        Enum.TextXAlignment.Left
                }
            )

            label.Parent = holder

            local textbox = Create(
                "TextBox",
                {

                    Position =
                        UDim2.new(
                            0.4,
                            0,
                            0,
                            7
                        ),

                    Size =
                        UDim2.new(
                            0.6,
                            -12,
                            0,
                            32
                        ),

                    BackgroundColor3 =
                        yyudly.Theme.Background,

                    BackgroundTransparency =
                        math.min(
                            transparency + 0.05,
                            0.9
                        ),

                    BorderSizePixel = 0,

                    Text =
                        data.CurrentValue
                        or "",

                    PlaceholderText =
                        data.PlaceholderText
                        or "Enter text...",

                    Font =
                        Enum.Font.Gotham,

                    TextSize = 12,

                    TextColor3 =
                        yyudly.Theme.Text,

                    PlaceholderColor3 =
                        yyudly.Theme.SubText,

                    ClearTextOnFocus = false
                }
            )

            textbox.Parent = holder

            AddCorner(textbox, 6)

            local textboxPadding =
                Instance.new("UIPadding")

            textboxPadding.PaddingLeft =
                UDim.new(0, 8)

            textboxPadding.PaddingRight =
                UDim.new(0, 8)

            textboxPadding.Parent =
                textbox

            textbox.FocusLost:Connect(
                function()

                    if data.Callback then
                        data.Callback(
                            textbox.Text
                        )
                    end
                end
            )

            return textbox
        end

        --------------------------------------------------
        -- KEYBIND
        --------------------------------------------------

        function tab:CreateKeybind(data)

            data = data or {}

            local key =
                data.CurrentKeybind
                or Enum.KeyCode.RightShift

            local listening = false

            local holder = Create(
                "TextButton",
                {

                    Size =
                        UDim2.new(
                            1,
                            0,
                            0,
                            42
                        ),

                    BackgroundColor3 =
                        yyudly.Theme.Element,

                    BackgroundTransparency =
                        elementTransparency,

                    BorderSizePixel = 0,

                    Text = "",

                    AutoButtonColor = false
                }
            )

            holder.Parent = page

            AddCorner(holder, 8)

            local nameLabel = Create(
                "TextLabel",
                {

                    Position =
                        UDim2.fromOffset(
                            12,
                            0
                        ),

                    Size =
                        UDim2.new(
                            0.6,
                            0,
                            1,
                            0
                        ),

                    BackgroundTransparency = 1,

                    Text =
                        data.Name
                        or "Keybind",

                    Font =
                        Enum.Font.GothamMedium,

                    TextSize = 13,

                    TextColor3 =
                        yyudly.Theme.Text,

                    TextXAlignment =
                        Enum.TextXAlignment.Left
                }
            )

            nameLabel.Parent = holder

            local keyLabel = Create(
                "TextLabel",
                {

                    Position =
                        UDim2.new(
                            0.6,
                            0,
                            0,
                            0
                        ),

                    Size =
                        UDim2.new(
                            0.4,
                            -12,
                            1,
                            0
                        ),

                    BackgroundTransparency = 1,

                    Text = key.Name,

                    Font =
                        Enum.Font.GothamMedium,

                    TextSize = 12,

                    TextColor3 =
                        yyudly.Theme.Accent,

                    TextXAlignment =
                        Enum.TextXAlignment.Right
                }
            )

            keyLabel.Parent = holder

            holder.MouseButton1Click:Connect(
                function()

                    listening = true

                    keyLabel.Text =
                        "Press key..."

                end
            )

            UserInputService.InputBegan:Connect(
                function(input, processed)

                    if processed then
                        return
                    end

                    if listening then

                        if input.KeyCode ~=
                            Enum.KeyCode.Unknown then

                            key =
                                input.KeyCode

                            keyLabel.Text =
                                key.Name

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
                end
            )

            return {

                Set = function(_, newKey)

                    key = newKey

                    keyLabel.Text =
                        newKey.Name

                end,

                Get = function()
                    return key
                end
            }
        end

        --------------------------------------------------
        -- RETURN TAB
        --------------------------------------------------

        return tab
    end

    --------------------------------------------------
    -- WINDOW DRAGGING
    --------------------------------------------------

    local dragging = false
    local dragStart
    local startPosition

    topbar.InputBegan:Connect(
        function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
                or
                input.UserInputType ==
                Enum.UserInputType.Touch then

                dragging = true

                dragStart =
                    input.Position

                startPosition =
                    main.Position
            end
        end
    )

    UserInputService.InputChanged:Connect(
        function(input)

            if not dragging then
                return
            end

            if input.UserInputType ~=
                Enum.UserInputType.MouseMovement
                and
                input.UserInputType ~=
                Enum.UserInputType.Touch then

                return
            end

            local delta =
                input.Position -
                dragStart

            main.Position =
                UDim2.new(

                    startPosition.X.Scale,

                    startPosition.X.Offset +
                        delta.X,

                    startPosition.Y.Scale,

                    startPosition.Y.Offset +
                        delta.Y
                )
        end
    )

    UserInputService.InputEnded:Connect(
        function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
                or
                input.UserInputType ==
                Enum.UserInputType.Touch then

                dragging = false
            end
        end
    )

    --------------------------------------------------
    -- WINDOW OBJECT
    --------------------------------------------------

    local window = {}

    function window:SetVisible(value)
        gui.Enabled = value
    end

    function window:Destroy()
        gui:Destroy()
    end

    function window:GetGui()
        return gui
    end

    function window:GetDevice()
        return device
    end

    function window:SetTransparency(value)

        transparency =
            math.clamp(
                value,
                0,
                0.95
            )

        main.BackgroundTransparency =
            transparency
    end

    return window
end

--------------------------------------------------
-- RETURN LIBRARY
--------------------------------------------------

return yyudly    for property, value in pairs(properties or {}) do
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
