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
    size = {width = 400, height = 500},
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
    
    -- Make draggable
    makeDraggable()
    
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
    
    print("🧹 UI module cleaned up")
end

return UI
