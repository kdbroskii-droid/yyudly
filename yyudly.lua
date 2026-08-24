-- yyudly.lua
-- Complete UI library

--------------------------------------------------
-- SERVICES
--------------------------------------------------

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

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
    local TouchEnabled = UserInputService.TouchEnabled
    local KeyboardEnabled = UserInputService.KeyboardEnabled

    if TouchEnabled and not KeyboardEnabled then
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

    if Options.Transparency == nil then
        Options.Transparency = 0.55
    end

    local Device = self:GetDevice()

    local Size

    if Device == "Mobile" then
        Size = UDim2.new(0.92, 0, 0.78, 0)
    else
        Size = Options.Size or UDim2.fromOffset(650, 480)
    end

    --------------------------------------------------
    -- SCREEN GUI
    --------------------------------------------------

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "yyudly"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    --------------------------------------------------
    -- MAIN
    --------------------------------------------------

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

    --------------------------------------------------
    -- TOP BAR
    --------------------------------------------------

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
    Sidebar.BackgroundTransparency = math.clamp(
        Options.Transparency + 0.1,
        0,
        0.95
    )
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
    -- WINDOW OBJECT
    --------------------------------------------------

    local Window = {}

    --------------------------------------------------
    -- CREATE TAB
    --------------------------------------------------

    function Window:CreateTab(TabName)

        assert(
            type(TabName) == "string",
            "CreateTab requires a string"
        )

        if Pages[TabName] then
            warn("yyudly: Tab already exists:", TabName)
            return nil
        end

        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, 0, 0, 36)
        TabButton.BackgroundColor3 = self.Theme
            and self.Theme.Accent
            or yyudly.Theme.Accent
        TabButton.BackgroundTransparency = 1
        TabButton.Text = TabName
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.TextSize = 13
        TabButton.TextColor3 = yyudly.Theme.SubText
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
        Page.ScrollBarImageColor3 = yyudly.Theme.Accent
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
                    ButtonObject.BackgroundColor3 =
                        yyudly.Theme.Accent
                    ButtonObject.TextColor3 =
                        Color3.new(1, 1, 1)
                else
                    ButtonObject.BackgroundTransparency = 1
                    ButtonObject.TextColor3 =
                        yyudly.Theme.SubText
                end

            end

            CurrentTab = TabName
        end

        TabButton.MouseButton1Click:Connect(Select)

        if not CurrentTab then
            Select()
        end

        --------------------------------------------------
        -- TAB OBJECT
        --------------------------------------------------

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
                if type(Options.Callback) == "function" then
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

            Toggle.CurrentValue = Options.CurrentValue == true
            Toggle.Callback = Options.Callback

            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, 0, 0, 42)
            Button.BackgroundColor3 = yyudly.Theme.Element
            Button.BackgroundTransparency = 0.1
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

                Value = Value == true

                Toggle.CurrentValue = Value

                Button.Text =
                    (Options.Name or "Toggle")
                    .. " : "
                    .. (Value and "ON" or "OFF")

                if type(Toggle.Callback) == "function" then
                    Toggle.Callback(Value)
                end
            end

            Button.MouseButton1Click:Connect(function()
                Toggle:Set(not Toggle.CurrentValue)
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

            Slider.Min = tonumber(Options.Min) or 0
            Slider.Max = tonumber(Options.Max) or 100

            if Slider.Max < Slider.Min then
                Slider.Min, Slider.Max =
                    Slider.Max, Slider.Min
            end

            Slider.CurrentValue =
                tonumber(Options.Default)
                or Slider.Min

            Slider.Callback = Options.Callback

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
            Label.Size = UDim2.new(1, -75, 0, 20)
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
            Value.Font = Enum.Font.Gotham
            Value.TextSize = 12
            Value.TextColor3 = yyudly.Theme.Accent
            Value.Parent = Holder

            local Bar = Instance.new("Frame")
            Bar.Position = UDim2.fromOffset(12, 39)
            Bar.Size = UDim2.new(1, -24, 0, 6)
            Bar.BackgroundColor3 =
                Color3.fromRGB(55, 55, 65)
            Bar.BorderSizePixel = 0
            Bar.Parent = Holder

            local BarCorner = Instance.new("UICorner")
            BarCorner.CornerRadius = UDim.new(0, 6)
            BarCorner.Parent = Bar

            local Fill = Instance.new("Frame")
            Fill.BackgroundColor3 =
                yyudly.Theme.Accent
            Fill.Size = UDim2.new(0, 0, 1, 0)
            Fill.BorderSizePixel = 0
            Fill.Parent = Bar

            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(0, 6)
            FillCorner.Parent = Fill

            function Slider:Set(NewValue)

                NewValue =
                    tonumber(NewValue)
                    or Slider.Min

                NewValue = math.clamp(
                    NewValue,
                    Slider.Min,
                    Slider.Max
                )

                Slider.CurrentValue = NewValue

                local Percentage = 0

                if Slider.Max ~= Slider.Min then
                    Percentage =
                        (NewValue - Slider.Min)
                        / (Slider.Max - Slider.Min)
                end

                Fill.Size =
                    UDim2.new(
                        Percentage,
                        0,
                        1,
                        0
                    )

                Value.Text = tostring(NewValue)

                if type(Slider.Callback) == "function" then
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

            Dropdown.Options = Options.Options or {}

            Dropdown.CurrentOption =
                Options.CurrentOption
                or Dropdown.Options[1]

            Dropdown.Callback = Options.Callback

            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, 0, 0, 42)
            Button.BackgroundColor3 = yyudly.Theme.Element
            Button.Text =
                (Options.Name or "Dropdown")
                .. " : "
                .. tostring(
                    Dropdown.CurrentOption or "None"
                )
            Button.Font = Enum.Font.GothamMedium
            Button.TextSize = 13
            Button.TextColor3 = yyudly.Theme.Text
            Button.AutoButtonColor = false
            Button.Parent = Page

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 8)
            Corner.Parent = Button

            local Index = 1

            if Dropdown.CurrentOption then
                for Number, Option in ipairs(Dropdown.Options) do
                    if Option == Dropdown.CurrentOption then
                        Index = Number
                        break
                    end
                end
            end

            function Dropdown:Set(NewValue)

                for Number, Option in ipairs(Dropdown.Options) do

                    if Option == NewValue then

                        Index = Number
                        Dropdown.CurrentOption = NewValue

                        Button.Text =
                            (Options.Name or "Dropdown")
                            .. " : "
                            .. tostring(NewValue)

                        if type(Dropdown.Callback) == "function" then
                            Dropdown.Callback(NewValue)
                        end

                        return
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

                Dropdown:Set(Dropdown.Options[Index])
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
            Box.BackgroundColor3 = yyudly.Theme.Element
            Box.Text = Options.CurrentValue or ""
            Box.PlaceholderText =
                Options.PlaceholderText
                or "Enter text..."
            Box.Font = Enum.Font.Gotham
            Box.TextSize = 13
            Box.TextColor3 = yyudly.Theme.Text
            Box.PlaceholderColor3 = yyudly.Theme.SubText
            Box.ClearTextOnFocus = false
            Box.Parent = Page

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 8)
            Corner.Parent = Box

            Box.FocusLost:Connect(function()
                if type(Options.Callback) == "function" then
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

            local Keybind = {}

            local CurrentKey =
                Options.CurrentKeybind
                or Enum.KeyCode.RightShift

            Keybind.CurrentKey = CurrentKey

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 42)
            Frame.BackgroundColor3 = yyudly.Theme.Element
            Frame.Parent = Page

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 8)
            Corner.Parent = Frame

            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, 0, 1, 0)
            Button.BackgroundTransparency = 1
            Button.Text =
                (Options.Name or "Keybind")
                .. " : "
                .. CurrentKey.Name
            Button.Font = Enum.Font.GothamMedium
            Button.TextSize = 13
            Button.TextColor3 = yyudly.Theme.Text
            Button.Parent = Frame

            local Listening = false

            Button.MouseButton1Click:Connect(function()
                Listening = true
                Button.Text = "Press a key..."
            end)

            local Connection

            Connection = UserInputService.InputBegan:Connect(
                function(Input, Processed)

                    if Processed then
                        return
                    end

                    if Listening then

                        if Input.KeyCode == Enum.KeyCode.Unknown then
                            return
                        end

                        CurrentKey = Input.KeyCode
                        Keybind.CurrentKey = CurrentKey
                        Listening = false

                        Button.Text =
                            (Options.Name or "Keybind")
                            .. " : "
                            .. CurrentKey.Name

                        return
                    end

                    if Input.KeyCode == CurrentKey then
                        if type(Options.Callback) == "function" then
                            Options.Callback(CurrentKey)
                        end
                    end
                end
            )

            function Keybind:Set(Key)

                if typeof(Key) ~= "EnumItem"
                    or Key.EnumType ~= Enum.KeyCode then
                    return
                end

                CurrentKey = Key
                Keybind.CurrentKey = Key

                Button.Text =
                    (Options.Name or "Keybind")
                    .. " : "
                    .. Key.Name
            end

            Frame.Destroying:Connect(function()
                if Connection then
                    Connection:Disconnect()
                    Connection = nil
                end
            end)

            return Keybind
        end

        return Tab
    end

    --------------------------------------------------
    -- WINDOW METHODS
    --------------------------------------------------

    function Window:GetDevice()
        return Device
    end

    function Window:SetVisible(Value)
        ScreenGui.Enabled = Value == true
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
    Name = "yyudly",
    Subtitle = "UI Library",
    Transparency = 0.55
})

local yyudlytab = yyudlygui:CreateTab("Main")

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

yyudlytab:CreateToggle({
    Name = "Example Toggle",
    CurrentValue = false,

    Callback = function(Value)
        print("Toggle:", Value)
    end
})

yyudlytab:CreateSlider({
    Name = "Example Slider",
    Min = 0,
    Max = 100,
    Default = 50,

    Callback = function(Value)
        print("Slider:", Value)
    end
})

yyudlytab:CreateDropdown({
    Name = "Example Dropdown",

    Options = {
        "Option 1",
        "Option 2",
        "Option 3"
    },

    CurrentOption = "Option 1",

    Callback = function(Value)
        print("Selected:", Value)
    end
})

yyudlytab:CreateTextbox({
    Name = "Example Textbox",
    PlaceholderText = "Type something...",

    Callback = function(Text)
        print("Text:", Text)
    end
})

yyudlytab:CreateKeybind({
    Name = "Example Keybind",
    CurrentKeybind = Enum.KeyCode.RightShift,

    Callback = function(Key)
        print("Key pressed:", Key.Name)
    end
})

yyudlytab:CreateSection("Device Information")

yyudlytab:CreateLabel(
    "Device: " .. yyudlygui:GetDevice()
)

print(
    "yyudly loaded on "
    .. yyudlygui:GetDevice()
)
