-- orion_lib.lua
-- Custom ORION-like UI Library for AutoFish Pro
-- Hosted locally in our GitHub repository

local OrionLib = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Configuration
local Config = {
    Theme = {
        MainColor = Color3.fromRGB(25, 25, 25),
        SecondaryColor = Color3.fromRGB(35, 35, 35),
        AccentColor = Color3.fromRGB(0, 162, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        TabColor = Color3.fromRGB(45, 45, 45),
        FloatingButtonColor = Color3.fromRGB(0, 162, 255)
    },
    Animation = {
        Duration = 0.3,
        Style = Enum.EasingStyle.Quad,
        Direction = Enum.EasingDirection.Out
    },
    UI = {
        BackgroundTransparency = 0.15,
        WindowDraggable = true,
        FloatingButton = true
    }
}

-- Utility Functions
local function CreateTween(object, properties, duration)
    duration = duration or Config.Animation.Duration
    local tweenInfo = TweenInfo.new(
        duration,
        Config.Animation.Style,
        Config.Animation.Direction
    )
    return TweenService:Create(object, tweenInfo, properties)
end

local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Config.Theme.AccentColor
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

local function CreatePadding(parent, padding)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, padding or 5)
    pad.PaddingBottom = UDim.new(0, padding or 5)
    pad.PaddingLeft = UDim.new(0, padding or 5)
    pad.PaddingRight = UDim.new(0, padding or 5)
    pad.Parent = parent
    return pad
end

-- Window Class
local Window = {}
Window.__index = Window

function Window:new(options)
    local success, result = pcall(function()
        local self = setmetatable({}, Window)
        
        -- Default options
        self.Options = {
            Name = options.Name or "Orion Library",
            HidePremium = options.HidePremium or true,
            SaveConfig = options.SaveConfig or false,
            ConfigFolder = options.ConfigFolder or "OrionConfig",
            IntroEnabled = options.IntroEnabled or false,
            IntroText = options.IntroText or "Welcome!",
            IntroIcon = options.IntroIcon or ""
        }
        
        self.Tabs = {}
        self.CurrentTab = nil
        self.Visible = true
        
        self:CreateWindow()
        
        return self
    end)
    
    if success and result then
        return result
    else
        error("Failed to create window: " .. tostring(result))
    end
end

function Window:CreateWindow()
    local success, error_msg = pcall(function()
        -- Main ScreenGui
        self.ScreenGui = Instance.new("ScreenGui")
        self.ScreenGui.Name = "OrionUI"
        self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        self.ScreenGui.ResetOnSpawn = false
        
        -- Protect from deletion
        if syn and syn.protect_gui then
            syn.protect_gui(self.ScreenGui)
        elseif gethui then
            self.ScreenGui.Parent = gethui()
        else
            self.ScreenGui.Parent = CoreGui
        end
        
        -- Main Frame
        self.MainFrame = Instance.new("Frame")
        self.MainFrame.Name = "MainFrame"
        self.MainFrame.Size = UDim2.new(0, 600, 0, 400)
        self.MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    self.MainFrame.BackgroundColor3 = Config.Theme.MainColor
    self.MainFrame.BackgroundTransparency = Config.UI.BackgroundTransparency
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui
    self.MainFrame.Active = true
    self.MainFrame.Draggable = Config.UI.WindowDraggable
    
    CreateCorner(self.MainFrame, 12)
    CreateStroke(self.MainFrame, Config.Theme.AccentColor, 2)
    
    -- Title Bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 40)
    self.TitleBar.BackgroundColor3 = Config.Theme.SecondaryColor
    self.TitleBar.BackgroundTransparency = Config.UI.BackgroundTransparency
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Parent = self.MainFrame
    
    CreateCorner(self.TitleBar, 8)
    
    -- Title
    self.Title = Instance.new("TextLabel")
    self.Title.Size = UDim2.new(1, -50, 1, 0)
    self.Title.Position = UDim2.new(0, 15, 0, 0)
    self.Title.BackgroundTransparency = 1
    self.Title.Text = self.Options.Name
    self.Title.TextColor3 = Config.Theme.TextColor
    self.Title.TextXAlignment = Enum.TextXAlignment.Left
    self.Title.TextSize = 18
    self.Title.Font = Enum.Font.SourceSansBold
    self.Title.Parent = self.TitleBar
    
    -- Close Button
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Size = UDim2.new(0, 30, 0, 30)
    self.CloseButton.Position = UDim2.new(1, -75, 0, 5)
    self.CloseButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    self.CloseButton.Text = "×"
    self.CloseButton.TextColor3 = Config.Theme.TextColor
    self.CloseButton.TextSize = 20
    self.CloseButton.Font = Enum.Font.SourceSansBold
    self.CloseButton.BorderSizePixel = 0
    self.CloseButton.Parent = self.TitleBar
    
    CreateCorner(self.CloseButton, 6)
    
    self.CloseButton.MouseButton1Click:Connect(function()
        self:SetVisible(false)
    end)
    
    -- Minimize Button
    self.MinimizeButton = Instance.new("TextButton")
    self.MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    self.MinimizeButton.Position = UDim2.new(1, -40, 0, 5)
    self.MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
    self.MinimizeButton.Text = "–"
    self.MinimizeButton.TextColor3 = Config.Theme.TextColor
    self.MinimizeButton.TextSize = 20
    self.MinimizeButton.Font = Enum.Font.SourceSansBold
    self.MinimizeButton.BorderSizePixel = 0
    self.MinimizeButton.Parent = self.TitleBar
    
    CreateCorner(self.MinimizeButton, 6)
    
    self.MinimizeButton.MouseButton1Click:Connect(function()
        self:Minimize()
    end)
    
    -- Tab Container
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(0, 150, 1, -50)
    self.TabContainer.Position = UDim2.new(0, 10, 0, 45)
    self.TabContainer.BackgroundColor3 = Config.Theme.SecondaryColor
    self.TabContainer.BackgroundTransparency = Config.UI.BackgroundTransparency
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.Parent = self.MainFrame
    
    CreateCorner(self.TabContainer, 8)
    
    -- Tab Layout
    self.TabLayout = Instance.new("UIListLayout")
    self.TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    self.TabLayout.Padding = UDim.new(0, 5)
    self.TabLayout.Parent = self.TabContainer
    
    CreatePadding(self.TabContainer, 10)
    
    -- Content Container
    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Name = "ContentContainer"
    self.ContentContainer.Size = UDim2.new(1, -180, 1, -50)
    self.ContentContainer.Position = UDim2.new(0, 170, 0, 45)
    self.ContentContainer.BackgroundColor3 = Config.Theme.SecondaryColor
    self.ContentContainer.BackgroundTransparency = Config.UI.BackgroundTransparency
    self.ContentContainer.BorderSizePixel = 0
    self.ContentContainer.Parent = self.MainFrame
    
    CreateCorner(self.ContentContainer, 8)
    
    -- Create floating button if enabled
    if Config.UI.FloatingButton then
        self:CreateFloatingButton()
    end
    end)
    
    if not success then
        error("Failed to create ORION window: " .. tostring(error_msg))
    end
end

function Window:MakeTab(options)
    local Tab = {}
    
    Tab.Name = options.Name or "Tab"
    Tab.Icon = options.Icon or ""
    Tab.PremiumOnly = options.PremiumOnly or false
    Tab.Elements = {}
    
    -- Tab Button
    Tab.Button = Instance.new("TextButton")
    Tab.Button.Size = UDim2.new(1, 0, 0, 35)
    Tab.Button.BackgroundColor3 = Config.Theme.TabColor
    Tab.Button.Text = Tab.Name
    Tab.Button.TextColor3 = Config.Theme.TextColor
    Tab.Button.TextSize = 14
    Tab.Button.Font = Enum.Font.SourceSans
    Tab.Button.BorderSizePixel = 0
    Tab.Button.Parent = self.TabContainer
    
    CreateCorner(Tab.Button, 6)
    
    -- Tab Content
    Tab.Content = Instance.new("ScrollingFrame")
    Tab.Content.Size = UDim2.new(1, 0, 1, 0)
    Tab.Content.BackgroundTransparency = 1
    Tab.Content.BorderSizePixel = 0
    Tab.Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Tab.Content.ScrollBarThickness = 4
    Tab.Content.ScrollBarImageColor3 = Config.Theme.AccentColor
    Tab.Content.Visible = false
    Tab.Content.Parent = self.ContentContainer
    
    -- Content Layout
    Tab.Layout = Instance.new("UIListLayout")
    Tab.Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Tab.Layout.Padding = UDim.new(0, 5)
    Tab.Layout.Parent = Tab.Content
    
    CreatePadding(Tab.Content, 10)
    
    -- Update canvas size automatically
    Tab.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Tab.Content.CanvasSize = UDim2.new(0, 0, 0, Tab.Layout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Tab Button Click
    Tab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(Tab)
    end)
    
    -- Add tab functions
    function Tab:AddSection(options)
        local Section = {}
        Section.Name = options.Name or "Section"
        
        local SectionFrame = Instance.new("Frame")
        SectionFrame.Size = UDim2.new(1, 0, 0, 30)
        SectionFrame.BackgroundTransparency = 1
        SectionFrame.Parent = Tab.Content
        
        local SectionLabel = Instance.new("TextLabel")
        SectionLabel.Size = UDim2.new(1, 0, 1, 0)
        SectionLabel.BackgroundTransparency = 1
        SectionLabel.Text = Section.Name
        SectionLabel.TextColor3 = Config.Theme.AccentColor
        SectionLabel.TextSize = 16
        SectionLabel.Font = Enum.Font.SourceSansBold
        SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
        SectionLabel.Parent = SectionFrame
        
        return Section
    end
    
    function Tab:AddButton(options)
        local Button = {}
        Button.Name = options.Name or "Button"
        Button.Callback = options.Callback or function() end
        
        local ButtonFrame = Instance.new("TextButton")
        ButtonFrame.Size = UDim2.new(1, 0, 0, 35)
        ButtonFrame.BackgroundColor3 = Config.Theme.AccentColor
        ButtonFrame.Text = Button.Name
        ButtonFrame.TextColor3 = Config.Theme.TextColor
        ButtonFrame.TextSize = 14
        ButtonFrame.Font = Enum.Font.SourceSans
        ButtonFrame.BorderSizePixel = 0
        ButtonFrame.Parent = Tab.Content
        
        CreateCorner(ButtonFrame, 6)
        
        ButtonFrame.MouseButton1Click:Connect(function()
            Button.Callback()
        end)
        
        -- Hover effect
        ButtonFrame.MouseEnter:Connect(function()
            CreateTween(ButtonFrame, {BackgroundColor3 = Color3.fromRGB(0, 140, 220)}, 0.1):Play()
        end)
        
        ButtonFrame.MouseLeave:Connect(function()
            CreateTween(ButtonFrame, {BackgroundColor3 = Config.Theme.AccentColor}, 0.1):Play()
        end)
        
        return Button
    end
    
    function Tab:AddToggle(options)
        local Toggle = {}
        Toggle.Name = options.Name or "Toggle"
        Toggle.Default = options.Default or false
        Toggle.Callback = options.Callback or function() end
        Toggle.State = Toggle.Default
        
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
        ToggleFrame.BackgroundColor3 = Config.Theme.TabColor
        ToggleFrame.BackgroundTransparency = Config.UI.BackgroundTransparency
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Parent = Tab.Content
        
        CreateCorner(ToggleFrame, 6)
        
        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
        ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Text = Toggle.Name
        ToggleLabel.TextColor3 = Config.Theme.TextColor
        ToggleLabel.TextSize = 14
        ToggleLabel.Font = Enum.Font.SourceSans
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.Parent = ToggleFrame
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Size = UDim2.new(0, 35, 0, 20)
        ToggleButton.Position = UDim2.new(1, -45, 0.5, -10)
        ToggleButton.BackgroundColor3 = Toggle.State and Config.Theme.AccentColor or Color3.fromRGB(100, 100, 100)
        ToggleButton.Text = ""
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Parent = ToggleFrame
        
        CreateCorner(ToggleButton, 10)
        
        local ToggleIndicator = Instance.new("Frame")
        ToggleIndicator.Size = UDim2.new(0, 16, 0, 16)
        ToggleIndicator.Position = Toggle.State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        ToggleIndicator.BackgroundColor3 = Config.Theme.TextColor
        ToggleIndicator.BorderSizePixel = 0
        ToggleIndicator.Parent = ToggleButton
        
        CreateCorner(ToggleIndicator, 8)
        
        function Toggle:Set(value)
            Toggle.State = value
            
            CreateTween(ToggleButton, {
                BackgroundColor3 = Toggle.State and Config.Theme.AccentColor or Color3.fromRGB(100, 100, 100)
            }):Play()
            
            CreateTween(ToggleIndicator, {
                Position = Toggle.State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            }):Play()
            
            Toggle.Callback(Toggle.State)
        end
        
        ToggleButton.MouseButton1Click:Connect(function()
            Toggle:Set(not Toggle.State)
        end)
        
        -- Initialize
        if Toggle.Default then
            Toggle:Set(Toggle.Default)
        end
        
        return Toggle
    end
    
    function Tab:AddSlider(options)
        local Slider = {}
        Slider.Name = options.Name or "Slider"
        Slider.Min = options.Min or 0
        Slider.Max = options.Max or 100
        Slider.Default = options.Default or Slider.Min
        Slider.Increment = options.Increment or 1
        Slider.ValueName = options.ValueName or ""
        Slider.Callback = options.Callback or function() end
        Slider.Value = Slider.Default
        
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, 0, 0, 50)
        SliderFrame.BackgroundColor3 = Config.Theme.TabColor
        SliderFrame.BackgroundTransparency = Config.UI.BackgroundTransparency
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Parent = Tab.Content
        
        CreateCorner(SliderFrame, 6)
        
        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Size = UDim2.new(1, 0, 0, 20)
        SliderLabel.Position = UDim2.new(0, 10, 0, 5)
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Text = Slider.Name .. ": " .. Slider.Value .. Slider.ValueName
        SliderLabel.TextColor3 = Config.Theme.TextColor
        SliderLabel.TextSize = 14
        SliderLabel.Font = Enum.Font.SourceSans
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        SliderLabel.Parent = SliderFrame
        
        local SliderTrack = Instance.new("Frame")
        SliderTrack.Size = UDim2.new(1, -20, 0, 6)
        SliderTrack.Position = UDim2.new(0, 10, 1, -15)
        SliderTrack.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        SliderTrack.BorderSizePixel = 0
        SliderTrack.Parent = SliderFrame
        
        CreateCorner(SliderTrack, 3)
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Size = UDim2.new(0, 0, 1, 0)
        SliderFill.BackgroundColor3 = Config.Theme.AccentColor
        SliderFill.BorderSizePixel = 0
        SliderFill.Parent = SliderTrack
        
        CreateCorner(SliderFill, 3)
        
        local SliderButton = Instance.new("TextButton")
        SliderButton.Size = UDim2.new(0, 20, 0, 20)
        SliderButton.Position = UDim2.new(0, 0, 0.5, -10)
        SliderButton.BackgroundColor3 = Config.Theme.TextColor
        SliderButton.Text = ""
        SliderButton.BorderSizePixel = 0
        SliderButton.Parent = SliderTrack
        
        CreateCorner(SliderButton, 10)
        
        function Slider:Set(value)
            value = math.clamp(value, Slider.Min, Slider.Max)
            value = math.floor(value / Slider.Increment) * Slider.Increment
            Slider.Value = value
            
            local percentage = (value - Slider.Min) / (Slider.Max - Slider.Min)
            
            CreateTween(SliderFill, {Size = UDim2.new(percentage, 0, 1, 0)}):Play()
            CreateTween(SliderButton, {Position = UDim2.new(percentage, -10, 0.5, -10)}):Play()
            
            SliderLabel.Text = Slider.Name .. ": " .. value .. Slider.ValueName
            Slider.Callback(value)
        end
        
        local dragging = false
        
        SliderButton.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mouse = UserInputService:GetMouseLocation()
                local trackPos = SliderTrack.AbsolutePosition.X
                local trackSize = SliderTrack.AbsoluteSize.X
                local percentage = math.clamp((mouse.X - trackPos) / trackSize, 0, 1)
                local value = Slider.Min + (percentage * (Slider.Max - Slider.Min))
                Slider:Set(value)
            end
        end)
        
        -- Initialize
        Slider:Set(Slider.Default)
        
        return Slider
    end
    
    function Tab:AddDropdown(options)
        local Dropdown = {}
        Dropdown.Name = options.Name or "Dropdown"
        Dropdown.Default = options.Default or ""
        Dropdown.Options = options.Options or {}
        Dropdown.Callback = options.Callback or function() end
        Dropdown.Value = Dropdown.Default
        Dropdown.Open = false
        
        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Size = UDim2.new(1, 0, 0, 35)
        DropdownFrame.BackgroundColor3 = Config.Theme.TabColor
        DropdownFrame.BackgroundTransparency = Config.UI.BackgroundTransparency
        DropdownFrame.BorderSizePixel = 0
        DropdownFrame.Parent = Tab.Content
        
        CreateCorner(DropdownFrame, 6)
        
        local DropdownLabel = Instance.new("TextLabel")
        DropdownLabel.Size = UDim2.new(0.5, 0, 1, 0)
        DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
        DropdownLabel.BackgroundTransparency = 1
        DropdownLabel.Text = Dropdown.Name
        DropdownLabel.TextColor3 = Config.Theme.TextColor
        DropdownLabel.TextSize = 14
        DropdownLabel.Font = Enum.Font.SourceSans
        DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
        DropdownLabel.Parent = DropdownFrame
        
        local DropdownButton = Instance.new("TextButton")
        DropdownButton.Size = UDim2.new(0.5, -20, 0, 25)
        DropdownButton.Position = UDim2.new(0.5, 10, 0.5, -12.5)
        DropdownButton.BackgroundColor3 = Config.Theme.MainColor
        DropdownButton.Text = Dropdown.Value
        DropdownButton.TextColor3 = Config.Theme.TextColor
        DropdownButton.TextSize = 12
        DropdownButton.Font = Enum.Font.SourceSans
        DropdownButton.BorderSizePixel = 0
        DropdownButton.Parent = DropdownFrame
        
        CreateCorner(DropdownButton, 4)
        
        local DropdownList = Instance.new("Frame")
        DropdownList.Size = UDim2.new(0.5, -20, 0, 0)
        DropdownList.Position = UDim2.new(0.5, 10, 1, 5)
        DropdownList.BackgroundColor3 = Config.Theme.MainColor
        DropdownList.BorderSizePixel = 0
        DropdownList.Visible = false
        DropdownList.ZIndex = 10
        DropdownList.Parent = DropdownFrame
        
        CreateCorner(DropdownList, 4)
        CreateStroke(DropdownList, Config.Theme.AccentColor, 1)
        
        local ListLayout = Instance.new("UIListLayout")
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Parent = DropdownList
        
        function Dropdown:Set(value)
            Dropdown.Value = value
            DropdownButton.Text = value
            Dropdown.Callback(value)
        end
        
        function Dropdown:Toggle()
            Dropdown.Open = not Dropdown.Open
            DropdownList.Visible = Dropdown.Open
            
            if Dropdown.Open then
                DropdownList.Size = UDim2.new(0.5, -20, 0, #Dropdown.Options * 25)
            end
        end
        
        DropdownButton.MouseButton1Click:Connect(function()
            Dropdown:Toggle()
        end)
        
        -- Create option buttons
        for _, option in ipairs(Dropdown.Options) do
            local OptionButton = Instance.new("TextButton")
            OptionButton.Size = UDim2.new(1, 0, 0, 25)
            OptionButton.BackgroundColor3 = Config.Theme.TabColor
            OptionButton.Text = option
            OptionButton.TextColor3 = Config.Theme.TextColor
            OptionButton.TextSize = 12
            OptionButton.Font = Enum.Font.SourceSans
            OptionButton.BorderSizePixel = 0
            OptionButton.Parent = DropdownList
            
            OptionButton.MouseButton1Click:Connect(function()
                Dropdown:Set(option)
                Dropdown:Toggle()
            end)
            
            OptionButton.MouseEnter:Connect(function()
                CreateTween(OptionButton, {BackgroundColor3 = Config.Theme.AccentColor}, 0.1):Play()
            end)
            
            OptionButton.MouseLeave:Connect(function()
                CreateTween(OptionButton, {BackgroundColor3 = Config.Theme.TabColor}, 0.1):Play()
            end)
        end
        
        -- Initialize
        if Dropdown.Default ~= "" then
            Dropdown:Set(Dropdown.Default)
        end
        
        return Dropdown
    end
    
    function Tab:AddLabel(text)
        local Label = {}
        Label.Text = text or "Label"
        
        local LabelFrame = Instance.new("TextLabel")
        LabelFrame.Size = UDim2.new(1, 0, 0, 25)
        LabelFrame.BackgroundTransparency = 1
        LabelFrame.Text = Label.Text
        LabelFrame.TextColor3 = Config.Theme.TextColor
        LabelFrame.TextSize = 14
        LabelFrame.Font = Enum.Font.SourceSans
        LabelFrame.TextXAlignment = Enum.TextXAlignment.Left
        LabelFrame.Parent = Tab.Content
        
        function Label:Set(newText)
            Label.Text = newText
            LabelFrame.Text = newText
        end
        
        return Label
    end
    
    -- Store tab
    table.insert(self.Tabs, Tab)
    
    -- Select first tab
    if #self.Tabs == 1 then
        self:SelectTab(Tab)
    end
    
    return Tab
end

function Window:SelectTab(tab)
    -- Hide all tabs
    for _, t in ipairs(self.Tabs) do
        t.Content.Visible = false
        CreateTween(t.Button, {BackgroundColor3 = Config.Theme.TabColor}):Play()
    end
    
    -- Show selected tab
    tab.Content.Visible = true
    CreateTween(tab.Button, {BackgroundColor3 = Config.Theme.AccentColor}):Play()
    
    self.CurrentTab = tab
end

function Window:SetVisible(visible)
    self.Visible = visible
    self.ScreenGui.Enabled = visible
    
    if self.FloatingButton then
        self.FloatingButton.Visible = not visible
    end
end

function Window:Minimize()
    self.Minimized = not self.Minimized
    
    if self.Minimized then
        -- Store original size and minimize
        self.OriginalSize = self.MainFrame.Size
        CreateTween(self.MainFrame, {
            Size = UDim2.new(0, 300, 0, 40)
        }):Play()
        
        -- Hide containers
        self.TabContainer.Visible = false
        self.ContentContainer.Visible = false
        
        self.MinimizeButton.Text = "+"
    else
        -- Restore original size
        CreateTween(self.MainFrame, {
            Size = self.OriginalSize or UDim2.new(0, 600, 0, 400)
        }):Play()
        
        -- Show containers
        self.TabContainer.Visible = true
        self.ContentContainer.Visible = true
        
        self.MinimizeButton.Text = "–"
    end
end

function Window:CreateFloatingButton()
    -- Create floating button
    self.FloatingButton = Instance.new("TextButton")
    self.FloatingButton.Name = "FloatingButton"
    self.FloatingButton.Size = UDim2.new(0, 60, 0, 60)
    self.FloatingButton.Position = UDim2.new(1, -80, 0, 20)
    self.FloatingButton.BackgroundColor3 = Config.Theme.FloatingButtonColor
    self.FloatingButton.Text = "🎣"
    self.FloatingButton.TextColor3 = Config.Theme.TextColor
    self.FloatingButton.TextSize = 24
    self.FloatingButton.Font = Enum.Font.SourceSansBold
    self.FloatingButton.BorderSizePixel = 0
    self.FloatingButton.Visible = false
    self.FloatingButton.Active = true
    self.FloatingButton.Draggable = true
    self.FloatingButton.Parent = self.ScreenGui
    
    CreateCorner(self.FloatingButton, 30)
    CreateStroke(self.FloatingButton, Config.Theme.AccentColor, 2)
    
    -- Floating button click
    self.FloatingButton.MouseButton1Click:Connect(function()
        self:SetVisible(true)
    end)
    
    -- Floating button hover effects
    self.FloatingButton.MouseEnter:Connect(function()
        CreateTween(self.FloatingButton, {
            Size = UDim2.new(0, 70, 0, 70),
            BackgroundColor3 = Color3.fromRGB(0, 140, 220)
        }, 0.2):Play()
    end)
    
    self.FloatingButton.MouseLeave:Connect(function()
        CreateTween(self.FloatingButton, {
            Size = UDim2.new(0, 60, 0, 60),
            BackgroundColor3 = Config.Theme.FloatingButtonColor
        }, 0.2):Play()
    end)
    
    -- Add tooltip
    local tooltip = Instance.new("TextLabel")
    tooltip.Size = UDim2.new(0, 120, 0, 30)
    tooltip.Position = UDim2.new(0, -130, 0.5, -15)
    tooltip.BackgroundColor3 = Config.Theme.MainColor
    tooltip.BackgroundTransparency = 0.1
    tooltip.Text = "Click to open AutoFish"
    tooltip.TextColor3 = Config.Theme.TextColor
    tooltip.TextSize = 12
    tooltip.Font = Enum.Font.SourceSans
    tooltip.TextWrapped = true
    tooltip.BorderSizePixel = 0
    tooltip.Visible = false
    tooltip.Parent = self.FloatingButton
    
    CreateCorner(tooltip, 4)
    
    -- Show tooltip on hover
    self.FloatingButton.MouseEnter:Connect(function()
        tooltip.Visible = true
        CreateTween(tooltip, {BackgroundTransparency = 0.1}, 0.2):Play()
    end)
    
    self.FloatingButton.MouseLeave:Connect(function()
        CreateTween(tooltip, {BackgroundTransparency = 1}, 0.2):Play()
        wait(0.2)
        tooltip.Visible = false
    end)
    
    -- Add pulsing animation
    spawn(function()
        while self.FloatingButton do
            if self.FloatingButton.Visible then
                CreateTween(self.FloatingButton, {
                    BackgroundTransparency = 0.3
                }, 1):Play()
                wait(1)
                CreateTween(self.FloatingButton, {
                    BackgroundTransparency = 0
                }, 1):Play()
                wait(1)
            else
                wait(0.1)
            end
        end
    end)
end

-- Notification system
function OrionLib:MakeNotification(options)
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 300, 0, 80)
    notification.Position = UDim2.new(1, -320, 1, -100)
    notification.BackgroundColor3 = Config.Theme.MainColor
    notification.BackgroundTransparency = Config.UI.BackgroundTransparency
    notification.BorderSizePixel = 0
    
    if CoreGui:FindFirstChild("OrionNotifications") then
        notification.Parent = CoreGui.OrionNotifications
    else
        local notifGui = Instance.new("ScreenGui")
        notifGui.Name = "OrionNotifications"
        notifGui.Parent = CoreGui
        notification.Parent = notifGui
    end
    
    CreateCorner(notification, 8)
    CreateStroke(notification, Config.Theme.AccentColor, 1)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -10, 0, 25)
    title.Position = UDim2.new(0, 5, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = options.Name or "Notification"
    title.TextColor3 = Config.Theme.AccentColor
    title.TextSize = 16
    title.Font = Enum.Font.SourceSansBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = notification
    
    local content = Instance.new("TextLabel")
    content.Size = UDim2.new(1, -10, 1, -30)
    content.Position = UDim2.new(0, 5, 0, 25)
    content.BackgroundTransparency = 1
    content.Text = options.Content or "No content"
    content.TextColor3 = Config.Theme.TextColor
    content.TextSize = 14
    content.Font = Enum.Font.SourceSans
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextWrapped = true
    content.Parent = notification
    
    -- Animation
    notification.Position = UDim2.new(1, 0, 1, -100)
    CreateTween(notification, {Position = UDim2.new(1, -320, 1, -100)}):Play()
    
    -- Auto dismiss
    task.wait(options.Time or 3)
    CreateTween(notification, {Position = UDim2.new(1, 0, 1, -100)}):Play()
    task.wait(0.3)
    notification:Destroy()
end

-- Cleanup
function OrionLib:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

-- Theme management
function OrionLib:SetTheme(theme)
    if theme == "Dark" then
        Config.Theme.MainColor = Color3.fromRGB(15, 15, 15)
        Config.Theme.SecondaryColor = Color3.fromRGB(25, 25, 25)
        Config.Theme.AccentColor = Color3.fromRGB(255, 100, 100)
    elseif theme == "Ocean" then
        Config.Theme.MainColor = Color3.fromRGB(20, 30, 50)
        Config.Theme.SecondaryColor = Color3.fromRGB(30, 40, 60)
        Config.Theme.AccentColor = Color3.fromRGB(100, 200, 255)
    elseif theme == "Space" then
        Config.Theme.MainColor = Color3.fromRGB(10, 5, 20)
        Config.Theme.SecondaryColor = Color3.fromRGB(20, 10, 30)
        Config.Theme.AccentColor = Color3.fromRGB(200, 100, 255)
    else -- Default
        Config.Theme.MainColor = Color3.fromRGB(25, 25, 25)
        Config.Theme.SecondaryColor = Color3.fromRGB(35, 35, 35)
        Config.Theme.AccentColor = Color3.fromRGB(0, 162, 255)
    end
end

-- Transparency management
function OrionLib:SetTransparency(transparency)
    Config.UI.BackgroundTransparency = math.clamp(transparency, 0, 0.8)
end

-- Main function
function OrionLib:MakeWindow(options)
    local success, window = pcall(function()
        return Window:new(options)
    end)
    
    if success and window then
        return window
    else
        print("⚠️ Warning: Failed to create ORION window: " .. tostring(window))
        return nil
    end
end

return OrionLib
