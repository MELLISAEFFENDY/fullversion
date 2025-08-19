-- rayfield_lib.lua
-- Custom Rayfield-like UI Library for AutoFish Pro
-- Simple, reliable, and lightweight

local RayfieldLib = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Configuration
local Config = {
    Theme = {
        Background = Color3.fromRGB(20, 20, 20),
        Topbar = Color3.fromRGB(30, 30, 30),
        Card = Color3.fromRGB(25, 25, 25),
        Accent = Color3.fromRGB(120, 80, 200),  -- Ungu gelap
        Text = Color3.fromRGB(255, 255, 255),
        SecondaryText = Color3.fromRGB(180, 180, 180)
    },
    Window = {
        Size = {600, 400},
        Draggable = true,
        BackgroundTransparency = 0.1
    }
}

-- Utility Functions
local function CreateCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = instance
    return corner
end

local function CreateStroke(instance, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Config.Theme.Accent
    stroke.Thickness = thickness or 1
    stroke.Parent = instance
    return stroke
end

local function CreatePadding(instance, padding)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, padding or 8)
    pad.PaddingBottom = UDim.new(0, padding or 8)
    pad.PaddingLeft = UDim.new(0, padding or 8)
    pad.PaddingRight = UDim.new(0, padding or 8)
    pad.Parent = instance
    return pad
end

local function Tween(instance, properties, duration, style, direction)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(
            duration or 0.3,
            style or Enum.EasingStyle.Quad,
            direction or Enum.EasingDirection.Out
        ),
        properties
    )
    tween:Play()
    return tween
end

-- Window Class
local Window = {}
Window.__index = Window

function Window:new(options)
    local self = setmetatable({}, Window)
    
    self.Options = {
        Name = options.Name or "Rayfield UI",
        LoadingTitle = options.LoadingTitle or "Loading...",
        LoadingSubtitle = options.LoadingSubtitle or "Please wait",
        ConfigurationSaving = {
            Enabled = options.ConfigurationSaving and options.ConfigurationSaving.Enabled or false,
            FolderName = options.ConfigurationSaving and options.ConfigurationSaving.FolderName or "RayfieldConfig"
        },
        Discord = options.Discord or {},
        KeySystem = options.KeySystem or false
    }
    
    self.Tabs = {}
    self.CurrentTab = nil
    self.Visible = true
    
    self:CreateWindow()
    
    return self
end

function Window:CreateWindow()
    -- Main ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "RayfieldUI"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.ResetOnSpawn = false
    
    -- Protect GUI
    if gethui then
        self.ScreenGui.Parent = gethui()
    else
        self.ScreenGui.Parent = CoreGui
    end
    
    -- Main Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, Config.Window.Size[1], 0, Config.Window.Size[2])
    self.MainFrame.Position = UDim2.new(0.5, -Config.Window.Size[1]/2, 0.5, -Config.Window.Size[2]/2)
    self.MainFrame.BackgroundColor3 = Config.Theme.Background
    self.MainFrame.BackgroundTransparency = Config.Window.BackgroundTransparency
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui
    
    if Config.Window.Draggable then
        self.MainFrame.Active = true
        self.MainFrame.Draggable = true
    end
    
    CreateCorner(self.MainFrame, 12)
    CreateStroke(self.MainFrame, Config.Theme.Accent, 2)
    
    -- Top Bar
    self.TopBar = Instance.new("Frame")
    self.TopBar.Name = "TopBar"
    self.TopBar.Size = UDim2.new(1, 0, 0, 50)
    self.TopBar.BackgroundColor3 = Config.Theme.Topbar
    self.TopBar.BorderSizePixel = 0
    self.TopBar.Parent = self.MainFrame
    
    CreateCorner(self.TopBar, 12)
    
    -- Title
    self.Title = Instance.new("TextLabel")
    self.Title.Size = UDim2.new(1, -100, 1, 0)
    self.Title.Position = UDim2.new(0, 20, 0, 0)
    self.Title.BackgroundTransparency = 1
    self.Title.Text = self.Options.Name
    self.Title.TextColor3 = Config.Theme.Text
    self.Title.TextXAlignment = Enum.TextXAlignment.Left
    self.Title.TextSize = 18
    self.Title.Font = Enum.Font.GothamBold
    self.Title.Parent = self.TopBar
    
    -- Close Button
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Size = UDim2.new(0, 30, 0, 30)
    self.CloseButton.Position = UDim2.new(1, -40, 0, 10)
    self.CloseButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
    self.CloseButton.Text = "×"
    self.CloseButton.TextColor3 = Config.Theme.Text
    self.CloseButton.TextSize = 16
    self.CloseButton.Font = Enum.Font.GothamBold
    self.CloseButton.BorderSizePixel = 0
    self.CloseButton.Parent = self.TopBar
    
    CreateCorner(self.CloseButton, 8)
    
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    -- Navigation Frame
    self.NavigationFrame = Instance.new("Frame")
    self.NavigationFrame.Name = "NavigationFrame"
    self.NavigationFrame.Size = UDim2.new(0, 150, 1, -60)
    self.NavigationFrame.Position = UDim2.new(0, 10, 0, 55)
    self.NavigationFrame.BackgroundColor3 = Config.Theme.Card
    self.NavigationFrame.BorderSizePixel = 0
    self.NavigationFrame.Parent = self.MainFrame
    
    CreateCorner(self.NavigationFrame, 8)
    CreatePadding(self.NavigationFrame, 5)
    
    -- Navigation Layout
    self.NavigationLayout = Instance.new("UIListLayout")
    self.NavigationLayout.SortOrder = Enum.SortOrder.LayoutOrder
    self.NavigationLayout.Padding = UDim.new(0, 3)
    self.NavigationLayout.Parent = self.NavigationFrame
    
    -- Content Frame
    self.ContentFrame = Instance.new("Frame")
    self.ContentFrame.Name = "ContentFrame"
    self.ContentFrame.Size = UDim2.new(1, -175, 1, -60)
    self.ContentFrame.Position = UDim2.new(0, 170, 0, 55)
    self.ContentFrame.BackgroundColor3 = Config.Theme.Card
    self.ContentFrame.BorderSizePixel = 0
    self.ContentFrame.Parent = self.MainFrame
    
    CreateCorner(self.ContentFrame, 8)
end

function Window:CreateTab(options)
    local Tab = {}
    Tab.Name = options.Name or "Tab"
    Tab.Image = options.Image or ""
    Tab.Elements = {}
    
    -- Tab Button
    Tab.Button = Instance.new("TextButton")
    Tab.Button.Size = UDim2.new(1, 0, 0, 35)
    Tab.Button.BackgroundColor3 = Config.Theme.Card
    Tab.Button.Text = Tab.Name
    Tab.Button.TextColor3 = Config.Theme.SecondaryText
    Tab.Button.TextSize = 14
    Tab.Button.Font = Enum.Font.Gotham
    Tab.Button.BorderSizePixel = 0
    Tab.Button.Parent = self.NavigationFrame
    
    CreateCorner(Tab.Button, 6)
    
    -- Tab Content
    Tab.Content = Instance.new("ScrollingFrame")
    Tab.Content.Name = Tab.Name .. "Content"
    Tab.Content.Size = UDim2.new(1, 0, 1, 0)
    Tab.Content.Position = UDim2.new(0, 0, 0, 0)
    Tab.Content.BackgroundTransparency = 1
    Tab.Content.BorderSizePixel = 0
    Tab.Content.ScrollBarThickness = 4
    Tab.Content.ScrollBarImageColor3 = Config.Theme.Accent
    Tab.Content.Parent = self.ContentFrame
    Tab.Content.Visible = false
    
    CreatePadding(Tab.Content, 10)
    
    -- Tab Layout
    Tab.Layout = Instance.new("UIListLayout")
    Tab.Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Tab.Layout.Padding = UDim.new(0, 8)
    Tab.Layout.Parent = Tab.Content
    
    -- Update content size when layout changes
    Tab.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Tab.Content.CanvasSize = UDim2.new(0, 0, 0, Tab.Layout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Tab Selection
    Tab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(Tab)
    end)
    
    -- Add to tabs list
    table.insert(self.Tabs, Tab)
    
    -- Select first tab
    if #self.Tabs == 1 then
        self:SelectTab(Tab)
    end
    
    -- Tab Functions
    function Tab:CreateLabel(options)
        local Label = {}
        Label.Text = options.Text or "Label"
        
        local LabelFrame = Instance.new("TextLabel")
        LabelFrame.Size = UDim2.new(1, 0, 0, 30)
        LabelFrame.BackgroundTransparency = 1
        LabelFrame.Text = Label.Text
        LabelFrame.TextColor3 = Config.Theme.Text
        LabelFrame.TextSize = 14
        LabelFrame.Font = Enum.Font.Gotham
        LabelFrame.TextXAlignment = Enum.TextXAlignment.Left
        LabelFrame.BorderSizePixel = 0
        LabelFrame.Parent = Tab.Content
        
        CreatePadding(LabelFrame, 5)
        
        function Label:Set(options)
            if options.Text then
                Label.Text = options.Text
                LabelFrame.Text = Label.Text
            end
        end
        
        table.insert(Tab.Elements, Label)
        return Label
    end
    
    function Tab:CreateButton(options)
        local Button = {}
        Button.Name = options.Name or "Button"
        Button.Callback = options.Callback or function() end
        
        local ButtonFrame = Instance.new("TextButton")
        ButtonFrame.Size = UDim2.new(1, 0, 0, 40)
        ButtonFrame.BackgroundColor3 = Config.Theme.Accent
        ButtonFrame.Text = Button.Name
        ButtonFrame.TextColor3 = Config.Theme.Text
        ButtonFrame.TextSize = 14
        ButtonFrame.Font = Enum.Font.Gotham
        ButtonFrame.BorderSizePixel = 0
        ButtonFrame.Parent = Tab.Content
        
        CreateCorner(ButtonFrame, 8)
        
        ButtonFrame.MouseButton1Click:Connect(function()
            Button.Callback()
        end)
        
        -- Hover effect
        ButtonFrame.MouseEnter:Connect(function()
            Tween(ButtonFrame, {BackgroundColor3 = Color3.fromRGB(100, 60, 160)}, 0.2)  -- Ungu gelap hover
        end)
        
        ButtonFrame.MouseLeave:Connect(function()
            Tween(ButtonFrame, {BackgroundColor3 = Config.Theme.Accent}, 0.2)
        end)
        
        table.insert(Tab.Elements, Button)
        return Button
    end
    
    function Tab:CreateToggle(options)
        local Toggle = {}
        Toggle.Name = options.Name or "Toggle"
        Toggle.CurrentValue = options.CurrentValue or false
        Toggle.Flag = options.Flag or ""
        Toggle.Callback = options.Callback or function() end
        
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
        ToggleFrame.BackgroundColor3 = Config.Theme.Background
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Parent = Tab.Content
        
        CreateCorner(ToggleFrame, 8)
        CreatePadding(ToggleFrame, 10)
        
        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
        ToggleLabel.Position = UDim2.new(0, 0, 0, 0)
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Text = Toggle.Name
        ToggleLabel.TextColor3 = Config.Theme.Text
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.TextSize = 14
        ToggleLabel.Font = Enum.Font.Gotham
        ToggleLabel.Parent = ToggleFrame
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Size = UDim2.new(0, 40, 0, 20)
        ToggleButton.Position = UDim2.new(1, -40, 0.5, -10)
        ToggleButton.BackgroundColor3 = Toggle.CurrentValue and Config.Theme.Accent or Color3.fromRGB(60, 60, 60)
        ToggleButton.Text = ""
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Parent = ToggleFrame
        
        CreateCorner(ToggleButton, 10)
        
        local ToggleIndicator = Instance.new("Frame")
        ToggleIndicator.Size = UDim2.new(0, 16, 0, 16)
        ToggleIndicator.Position = Toggle.CurrentValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        ToggleIndicator.BackgroundColor3 = Config.Theme.Text
        ToggleIndicator.BorderSizePixel = 0
        ToggleIndicator.Parent = ToggleButton
        
        CreateCorner(ToggleIndicator, 8)
        
        function Toggle:Set(value)
            Toggle.CurrentValue = value
            
            Tween(ToggleButton, {
                BackgroundColor3 = value and Config.Theme.Accent or Color3.fromRGB(60, 60, 60)
            }, 0.3)
            
            Tween(ToggleIndicator, {
                Position = value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            }, 0.3)
            
            Toggle.Callback(value)
        end
        
        ToggleButton.MouseButton1Click:Connect(function()
            Toggle:Set(not Toggle.CurrentValue)
        end)
        
        table.insert(Tab.Elements, Toggle)
        return Toggle
    end
    
    function Tab:CreateSlider(options)
        local Slider = {}
        Slider.Name = options.Name or "Slider"
        Slider.Range = options.Range or {0, 100}
        Slider.Increment = options.Increment or 1
        Slider.CurrentValue = options.CurrentValue or Slider.Range[1]
        Slider.Flag = options.Flag or ""
        Slider.Callback = options.Callback or function() end
        
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, 0, 0, 50)
        SliderFrame.BackgroundColor3 = Config.Theme.Background
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Parent = Tab.Content
        
        CreateCorner(SliderFrame, 8)
        CreatePadding(SliderFrame, 10)
        
        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Size = UDim2.new(1, 0, 0, 20)
        SliderLabel.Position = UDim2.new(0, 0, 0, 0)
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Text = Slider.Name .. ": " .. Slider.CurrentValue
        SliderLabel.TextColor3 = Config.Theme.Text
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        SliderLabel.TextSize = 14
        SliderLabel.Font = Enum.Font.Gotham
        SliderLabel.Parent = SliderFrame
        
        local SliderTrack = Instance.new("Frame")
        SliderTrack.Size = UDim2.new(1, 0, 0, 4)
        SliderTrack.Position = UDim2.new(0, 0, 1, -8)
        SliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        SliderTrack.BorderSizePixel = 0
        SliderTrack.Parent = SliderFrame
        
        CreateCorner(SliderTrack, 2)
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Size = UDim2.new((Slider.CurrentValue - Slider.Range[1]) / (Slider.Range[2] - Slider.Range[1]), 0, 1, 0)
        SliderFill.Position = UDim2.new(0, 0, 0, 0)
        SliderFill.BackgroundColor3 = Config.Theme.Accent
        SliderFill.BorderSizePixel = 0
        SliderFill.Parent = SliderTrack
        
        CreateCorner(SliderFill, 2)
        
        function Slider:Set(value)
            value = math.clamp(value, Slider.Range[1], Slider.Range[2])
            value = math.floor(value / Slider.Increment + 0.5) * Slider.Increment
            Slider.CurrentValue = value
            
            SliderLabel.Text = Slider.Name .. ": " .. value
            
            local percentage = (value - Slider.Range[1]) / (Slider.Range[2] - Slider.Range[1])
            Tween(SliderFill, {Size = UDim2.new(percentage, 0, 1, 0)}, 0.2)
            
            Slider.Callback(value)
        end
        
        local dragging = false
        SliderTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                local percentage = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                local value = Slider.Range[1] + percentage * (Slider.Range[2] - Slider.Range[1])
                Slider:Set(value)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local percentage = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                local value = Slider.Range[1] + percentage * (Slider.Range[2] - Slider.Range[1])
                Slider:Set(value)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        table.insert(Tab.Elements, Slider)
        return Slider
    end
    
    return Tab
end

function Window:SelectTab(tab)
    -- Hide all tabs
    for _, t in pairs(self.Tabs) do
        t.Content.Visible = false
        t.Button.BackgroundColor3 = Config.Theme.Card
        t.Button.TextColor3 = Config.Theme.SecondaryText
    end
    
    -- Show selected tab
    tab.Content.Visible = true
    tab.Button.BackgroundColor3 = Config.Theme.Accent
    tab.Button.TextColor3 = Config.Theme.Text
    
    self.CurrentTab = tab
end

function Window:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

-- Main Library Functions
function RayfieldLib:CreateWindow(options)
    return Window:new(options)
end

return RayfieldLib
