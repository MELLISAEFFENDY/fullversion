-- UI Module for Modern AutoFish
-- Part of Modern AutoFish Modular System

local UI = {}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- Configuration
UI.config = {
    theme = "dark",
    position = {x = 10, y = 10},
    size = {width = 400, height = 600}, -- Increased height for more sections
    transparency = 0.1
}

-- UI State
local screenGui = nil
local mainFrame = nil
local modules = {}
local isVisible = true

-- Colors based on theme
local colors = {
    dark = {
        background = Color3.fromRGB(25, 25, 25),
        secondary = Color3.fromRGB(35, 35, 35),
        accent = Color3.fromRGB(0, 162, 255),
        text = Color3.fromRGB(255, 255, 255),
        success = Color3.fromRGB(46, 204, 113),
        warning = Color3.fromRGB(255, 193, 7),
        danger = Color3.fromRGB(231, 76, 60)
    }
}

-- Helper functions
local function createFrame(parent, props)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BackgroundColor3 = props.BackgroundColor3 or colors.dark.background
    frame.BorderSizePixel = 0
    frame.Size = props.Size or UDim2.new(1, 0, 0, 50)
    frame.Position = props.Position or UDim2.new(0, 0, 0, 0)
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    return frame
end

local function createButton(parent, props)
    local button = Instance.new("TextButton")
    button.Parent = parent
    button.BackgroundColor3 = props.BackgroundColor3 or colors.dark.accent
    button.BorderSizePixel = 0
    button.Size = props.Size or UDim2.new(0, 100, 0, 30)
    button.Position = props.Position or UDim2.new(0, 0, 0, 0)
    button.Text = props.Text or "Button"
    button.TextColor3 = colors.dark.text
    button.TextScaled = true
    button.Font = Enum.Font.SourceSansBold
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(
                math.min(255, button.BackgroundColor3.R * 255 + 20),
                math.min(255, button.BackgroundColor3.G * 255 + 20),
                math.min(255, button.BackgroundColor3.B * 255 + 20)
            )
        })
        tween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = props.BackgroundColor3 or colors.dark.accent
        })
        tween:Play()
    end)
    
    if props.OnClick then
        button.MouseButton1Click:Connect(props.OnClick)
    end
    
    return button
end

local function createLabel(parent, props)
    local label = Instance.new("TextLabel")
    label.Parent = parent
    label.BackgroundTransparency = 1
    label.Size = props.Size or UDim2.new(1, 0, 0, 20)
    label.Position = props.Position or UDim2.new(0, 0, 0, 0)
    label.Text = props.Text or "Label"
    label.TextColor3 = props.TextColor3 or colors.dark.text
    label.TextScaled = props.TextScaled or false
    label.TextSize = props.TextSize or 14
    label.Font = props.Font or Enum.Font.SourceSans
    label.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
    
    return label
end

local function createToggle(parent, props)
    local frame = createFrame(parent, {
        Size = UDim2.new(1, -10, 0, 40),
        Position = props.Position,
        BackgroundColor3 = colors.dark.secondary
    })
    
    local label = createLabel(frame, {
        Text = props.Text or "Toggle",
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        TextSize = 16,
        Font = Enum.Font.SourceSansBold
    })
    
    local toggle = createButton(frame, {
        Text = props.Enabled and "ON" or "OFF",
        Size = UDim2.new(0, 60, 0, 25),
        Position = UDim2.new(1, -70, 0.5, -12.5),
        BackgroundColor3 = props.Enabled and colors.dark.success or colors.dark.danger,
        OnClick = function()
            props.Enabled = not props.Enabled
            toggle.Text = props.Enabled and "ON" or "OFF"
            toggle.BackgroundColor3 = props.Enabled and colors.dark.success or colors.dark.danger
            if props.OnToggle then
                props.OnToggle(props.Enabled)
            end
        end
    })
    
    return frame, toggle
end

-- Create main UI
local function createMainUI()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ModernAutoFishUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- Main frame
    mainFrame = createFrame(screenGui, {
        Size = UDim2.new(0, UI.config.size.width, 0, UI.config.size.height),
        Position = UDim2.new(0, UI.config.position.x, 0, UI.config.position.y),
        BackgroundColor3 = colors.dark.background
    })
    
    -- Title bar
    local titleBar = createFrame(mainFrame, {
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = colors.dark.accent
    })
    
    local title = createLabel(titleBar, {
        Text = "🎣 Modern AutoFish v2.0",
        Size = UDim2.new(0.8, 0, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        TextSize = 18,
        Font = Enum.Font.SourceSansBold,
        TextColor3 = colors.dark.text
    })
    
    -- Close button
    local closeBtn = createButton(titleBar, {
        Text = "✕",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0, 5),
        BackgroundColor3 = colors.dark.danger,
        OnClick = function()
            UI.toggle()
        end
    })
    
    -- Content area
    local content = createFrame(mainFrame, {
        Size = UDim2.new(1, -20, 1, -60),
        Position = UDim2.new(0, 10, 0, 50),
        BackgroundColor3 = colors.dark.secondary
    })
    
    -- Scroll frame for content
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Parent = content
    scrollFrame.Size = UDim2.new(1, -10, 1, -10)
    scrollFrame.Position = UDim2.new(0, 5, 0, 5)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.ScrollBarImageColor3 = colors.dark.accent
    
    -- Layout
    local layout = Instance.new("UIListLayout")
    layout.Parent = scrollFrame
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    
    return scrollFrame
end

-- Create AutoFish section
local function createAutoFishSection(parent)
    if not modules.autofish then return end
    
    local section = createFrame(parent, {
        Size = UDim2.new(1, 0, 0, 120),
        BackgroundColor3 = colors.dark.background
    })
    section.LayoutOrder = 1
    
    local sectionTitle = createLabel(section, {
        Text = "🎣 AutoFishing",
        Position = UDim2.new(0, 10, 0, 5),
        TextSize = 16,
        Font = Enum.Font.SourceSansBold
    })
    
    -- AutoFish toggle
    local _, fishToggle = createToggle(section, {
        Text = "Enable AutoFish",
        Position = UDim2.new(0, 5, 0, 25),
        Enabled = modules.autofish.getStatus().enabled,
        OnToggle = function(enabled)
            if enabled then
                modules.autofish.start()
            else
                modules.autofish.stop()
            end
        end
    })
    
    -- Mode buttons
    local smartBtn = createButton(section, {
        Text = "Smart Mode",
        Size = UDim2.new(0.45, 0, 0, 25),
        Position = UDim2.new(0, 10, 0, 75),
        BackgroundColor3 = colors.dark.success,
        OnClick = function()
            modules.autofish.setMode("smart")
        end
    })
    
    local secureBtn = createButton(section, {
        Text = "Secure Mode", 
        Size = UDim2.new(0.45, 0, 0, 25),
        Position = UDim2.new(0.55, 0, 0, 75),
        BackgroundColor3 = colors.dark.warning,
        OnClick = function()
            modules.autofish.setMode("secure")
        end
    })
end

-- Create Movement section
local function createMovementSection(parent)
    if not modules.movement then return end
    
    local section = createFrame(parent, {
        Size = UDim2.new(1, 0, 0, 160),
        BackgroundColor3 = colors.dark.background
    })
    section.LayoutOrder = 2
    
    local sectionTitle = createLabel(section, {
        Text = "🚀 Movement Enhancement",
        Position = UDim2.new(0, 10, 0, 5),
        TextSize = 16,
        Font = Enum.Font.SourceSansBold
    })
    
    -- Float toggle
    createToggle(section, {
        Text = "Float Mode",
        Position = UDim2.new(0, 5, 0, 25),
        Enabled = modules.movement.getConfig().floatEnabled,
        OnToggle = function(enabled)
            if enabled then
                modules.movement.enableFloat()
            else
                modules.movement.disableFloat()
            end
        end
    })
    
    -- NoClip toggle
    createToggle(section, {
        Text = "No Clip",
        Position = UDim2.new(0, 5, 0, 70),
        Enabled = modules.movement.getConfig().noClipEnabled,
        OnToggle = function(enabled)
            if enabled then
                modules.movement.enableNoClip()
            else
                modules.movement.disableNoClip()
            end
        end
    })
    
    -- Spinner toggle
    createToggle(section, {
        Text = "Auto Spinner",
        Position = UDim2.new(0, 5, 0, 115),
        Enabled = modules.movement.getConfig().spinnerEnabled,
        OnToggle = function(enabled)
            if enabled then
                modules.movement.enableAutoSpinner()
            else
                modules.movement.disableAutoSpinner()
            end
        end
    })
end

-- Create Dashboard section
local function createDashboardSection(parent)
    if not modules.dashboard then return end
    
    local section = createFrame(parent, {
        Size = UDim2.new(1, 0, 0, 200),
        BackgroundColor3 = colors.dark.background
    })
    section.LayoutOrder = 3
    
    local sectionTitle = createLabel(section, {
        Text = "📊 Dashboard & Statistics",
        Position = UDim2.new(0, 10, 0, 5),
        TextSize = 16,
        Font = Enum.Font.SourceSansBold
    })
    
    -- Stats display area
    local statsFrame = createFrame(section, {
        Size = UDim2.new(1, -20, 0, 120),
        Position = UDim2.new(0, 10, 0, 25),
        BackgroundColor3 = colors.dark.secondary
    })
    
    -- Fish count label
    local fishCountLabel = createLabel(statsFrame, {
        Text = "Fish Caught: 0",
        Position = UDim2.new(0, 10, 0, 5),
        TextSize = 14,
        Font = Enum.Font.SourceSansBold,
        TextColor3 = colors.dark.success
    })
    
    -- Rare fish label
    local rareFishLabel = createLabel(statsFrame, {
        Text = "Rare Fish: 0 (0%)",
        Position = UDim2.new(0, 10, 0, 25),
        TextSize = 14,
        Font = Enum.Font.SourceSansBold,
        TextColor3 = colors.dark.warning
    })
    
    -- Session time label
    local sessionTimeLabel = createLabel(statsFrame, {
        Text = "Session Time: 0m",
        Position = UDim2.new(0, 10, 0, 45),
        TextSize = 14,
        Font = Enum.Font.SourceSans
    })
    
    -- Current location label
    local locationLabel = createLabel(statsFrame, {
        Text = "Location: Unknown",
        Position = UDim2.new(0, 10, 0, 65),
        TextSize = 14,
        Font = Enum.Font.SourceSans
    })
    
    -- Fish per hour label
    local fishPerHourLabel = createLabel(statsFrame, {
        Text = "Fish/Hour: 0",
        Position = UDim2.new(0, 10, 0, 85),
        TextSize = 14,
        Font = Enum.Font.SourceSans
    })
    
    -- Reset stats button
    local resetBtn = createButton(section, {
        Text = "Reset Stats",
        Size = UDim2.new(0.3, 0, 0, 25),
        Position = UDim2.new(0, 10, 0, 155),
        BackgroundColor3 = colors.dark.danger,
        OnClick = function()
            if modules.dashboard.resetStats then
                modules.dashboard.resetStats()
            end
        end
    })
    
    -- Export data button
    local exportBtn = createButton(section, {
        Text = "Export Data",
        Size = UDim2.new(0.3, 0, 0, 25),
        Position = UDim2.new(0.35, 0, 0, 155),
        BackgroundColor3 = colors.dark.accent,
        OnClick = function()
            if modules.dashboard.printSummary then
                modules.dashboard.printSummary()
            end
        end
    })
    
    -- Update stats function
    local function updateStats()
        if modules.dashboard and modules.dashboard.getSessionStats then
            local stats = modules.dashboard.getSessionStats()
            fishCountLabel.Text = "Fish Caught: " .. stats.fishCount
            rareFishLabel.Text = string.format("Rare Fish: %d (%.1f%%)", stats.rareCount, stats.rarePercentage)
            sessionTimeLabel.Text = string.format("Session Time: %.1fm", stats.sessionTime / 60)
            locationLabel.Text = "Location: " .. stats.currentLocation
            fishPerHourLabel.Text = string.format("Fish/Hour: %.1f", stats.fishPerHour)
        end
    end
    
    -- Update stats every 2 seconds
    task.spawn(function()
        while true do
            updateStats()
            task.wait(2)
        end
    end)
end

-- Create Auto Sell section
local function createAutoSellSection(parent)
    if not modules.autosell then return end
    
    local section = createFrame(parent, {
        Size = UDim2.new(1, 0, 0, 140),
        BackgroundColor3 = colors.dark.background
    })
    section.LayoutOrder = 4
    
    local sectionTitle = createLabel(section, {
        Text = "🛒 Auto Sell System",
        Position = UDim2.new(0, 10, 0, 5),
        TextSize = 16,
        Font = Enum.Font.SourceSansBold
    })
    
    -- Auto sell toggle
    local _, sellToggle = createToggle(section, {
        Text = "Enable Auto Sell",
        Position = UDim2.new(0, 5, 0, 25),
        Enabled = modules.autosell.getStatus().enabled,
        OnToggle = function(enabled)
            if enabled then
                modules.autosell.enable()
            else
                modules.autosell.disable()
            end
        end
    })
    
    -- Threshold label and controls
    local thresholdLabel = createLabel(section, {
        Text = "Sell Threshold: " .. modules.autosell.getThreshold() .. " fish",
        Position = UDim2.new(0, 10, 0, 75),
        TextSize = 14,
        Font = Enum.Font.SourceSans
    })
    
    -- Threshold buttons
    local decreaseBtn = createButton(section, {
        Text = "-",
        Size = UDim2.new(0, 30, 0, 25),
        Position = UDim2.new(0, 10, 0, 95),
        BackgroundColor3 = colors.dark.danger,
        OnClick = function()
            local currentThreshold = modules.autosell.getThreshold()
            local newThreshold = math.max(1, currentThreshold - 5)
            if modules.autosell.setThreshold(newThreshold) then
                thresholdLabel.Text = "Sell Threshold: " .. newThreshold .. " fish"
            end
        end
    })
    
    local increaseBtn = createButton(section, {
        Text = "+",
        Size = UDim2.new(0, 30, 0, 25),
        Position = UDim2.new(0, 45, 0, 95),
        BackgroundColor3 = colors.dark.success,
        OnClick = function()
            local currentThreshold = modules.autosell.getThreshold()
            local newThreshold = math.min(1000, currentThreshold + 5)
            if modules.autosell.setThreshold(newThreshold) then
                thresholdLabel.Text = "Sell Threshold: " .. newThreshold .. " fish"
            end
        end
    })
    
    local sellNowBtn = createButton(section, {
        Text = "Sell Now",
        Size = UDim2.new(0.4, 0, 0, 25),
        Position = UDim2.new(0.55, 0, 0, 95),
        BackgroundColor3 = colors.dark.warning,
        OnClick = function()
            modules.autosell.sellNow()
        end
    })
end

-- Create Settings section
local function createSettingsSection(parent)
    if not modules.security then return end
    
    local section = createFrame(parent, {
        Size = UDim2.new(1, 0, 0, 100),
        BackgroundColor3 = colors.dark.background
    })
    section.LayoutOrder = 5
    
    local sectionTitle = createLabel(section, {
        Text = "⚙️ Settings",
        Position = UDim2.new(0, 10, 0, 5),
        TextSize = 16,
        Font = Enum.Font.SourceSansBold
    })
    
    -- AntiAFK toggle
    createToggle(section, {
        Text = "Anti-AFK",
        Position = UDim2.new(0, 5, 0, 25),
        Enabled = modules.security.getStatus().antiAfkEnabled,
        OnToggle = function(enabled)
            if enabled then
                modules.security.enableAntiAfk()
            else
                modules.security.disableAntiAfk()
            end
        end
    })
    
    -- Auto Reconnect toggle  
    createToggle(section, {
        Text = "Auto Reconnect",
        Position = UDim2.new(0, 5, 0, 65),
        Enabled = modules.security.getStatus().autoReconnectEnabled,
        OnToggle = function(enabled)
            if enabled then
                modules.security.enableAutoReconnect()
            else
                modules.security.disableAutoReconnect()
            end
        end
    })
end

-- Make UI draggable
local function makeDraggable()
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    local titleBar = mainFrame:FindFirstChild("Frame") -- Title bar
    if not titleBar then return end
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Create floating button
local floatingButton = nil
local function createFloatingButton()
    if floatingButton then
        floatingButton:Destroy()
    end
    
    floatingButton = Instance.new("TextButton")
    floatingButton.Parent = screenGui
    floatingButton.Size = UDim2.new(0, 60, 0, 60)
    floatingButton.Position = UDim2.new(1, -80, 0.5, -30)
    floatingButton.BackgroundColor3 = colors.dark.accent
    floatingButton.BorderSizePixel = 0
    floatingButton.Text = "🎣"
    floatingButton.TextColor3 = colors.dark.text
    floatingButton.TextScaled = true
    floatingButton.Font = Enum.Font.SourceSansBold
    floatingButton.ZIndex = 100
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 30)
    corner.Parent = floatingButton
    
    -- Add shadow effect
    local shadow = Instance.new("Frame")
    shadow.Parent = screenGui
    shadow.Size = UDim2.new(0, 64, 0, 64)
    shadow.Position = UDim2.new(1, -82, 0.5, -32)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.5
    shadow.BorderSizePixel = 0
    shadow.ZIndex = 99
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 32)
    shadowCorner.Parent = shadow
    
    -- Floating button animations
    floatingButton.MouseEnter:Connect(function()
        local tween = TweenService:Create(floatingButton, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 65, 0, 65),
            BackgroundColor3 = Color3.fromRGB(
                math.min(255, colors.dark.accent.R * 255 + 30),
                math.min(255, colors.dark.accent.G * 255 + 30),
                math.min(255, colors.dark.accent.B * 255 + 30)
            )
        })
        tween:Play()
    end)
    
    floatingButton.MouseLeave:Connect(function()
        local tween = TweenService:Create(floatingButton, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 60, 0, 60),
            BackgroundColor3 = colors.dark.accent
        })
        tween:Play()
    end)
    
    -- Click to toggle main UI
    floatingButton.MouseButton1Click:Connect(function()
        UI.toggle()
    end)
    
    -- Make floating button draggable
    local floatDragging = false
    local floatDragStart = nil
    local floatStartPos = nil
    
    floatingButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            floatDragging = true
            floatDragStart = input.Position
            floatStartPos = floatingButton.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if floatDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - floatDragStart
            local newPos = UDim2.new(
                floatStartPos.X.Scale,
                floatStartPos.X.Offset + delta.X,
                floatStartPos.Y.Scale,
                floatStartPos.Y.Offset + delta.Y
            )
            floatingButton.Position = newPos
            shadow.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset - 2, newPos.Y.Scale, newPos.Y.Offset - 2)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            floatDragging = false
        end
    end)
end

-- Public API
function UI.createInterface(moduleInstances)
    if screenGui then
        screenGui:Destroy()
    end
    
    modules = moduleInstances or {}
    
    local content = createMainUI()
    
    -- Create sections
    createAutoFishSection(content)
    createMovementSection(content)
    createDashboardSection(content)
    createAutoSellSection(content)
    createSettingsSection(content)
    
    -- Make draggable
    makeDraggable()
    
    -- Create floating button
    createFloatingButton()
    
    -- Update canvas size
    local layout = content:FindFirstChild("UIListLayout")
    if layout then
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
        end)
    end
    
    print("🖥️ UI created successfully")
    return true
end

function UI.toggle()
    if not mainFrame then return false end
    
    isVisible = not isVisible
    local targetPosition = isVisible and 
        UDim2.new(0, UI.config.position.x, 0, UI.config.position.y) or
        UDim2.new(0, -UI.config.size.width, 0, UI.config.position.y)
    
    local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
        Position = targetPosition
    })
    tween:Play()
    
    return isVisible
end

function UI.show()
    if not mainFrame then return false end
    isVisible = true
    mainFrame.Position = UDim2.new(0, UI.config.position.x, 0, UI.config.position.y)
    return true
end

function UI.hide()
    if not mainFrame then return false end
    isVisible = false
    mainFrame.Position = UDim2.new(0, -UI.config.size.width, 0, UI.config.position.y)
    return true
end

function UI.init(config)
    if config and config.ui then
        for key, value in pairs(config.ui) do
            if UI.config[key] ~= nil then
                UI.config[key] = value
            end
        end
    end
    
    print("🖥️ UI module initialized")
    return true
end

function UI.cleanup()
    if screenGui then
        screenGui:Destroy()
        screenGui = nil
        mainFrame = nil
    end
    
    if floatingButton then
        floatingButton:Destroy()
        floatingButton = nil
    end
    
    print("🧹 UI module cleaned up")
end

return UI
