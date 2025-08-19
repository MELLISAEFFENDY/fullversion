-- floating_button.lua
-- Modern Floating Button for AutoFish Pro
-- Draggable floating button with quick access menu

local FloatingButton = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Configuration
local Config = {
    Button = {
        Size = {60, 60},
        Position = {50, 200}, -- Default position from left, top
        BackgroundColor = Color3.fromRGB(120, 80, 200), -- Purple theme
        IconColor = Color3.fromRGB(255, 255, 255),
        BorderColor = Color3.fromRGB(150, 100, 220),
        Shadow = true
    },
    Menu = {
        Size = {200, 300},
        BackgroundColor = Color3.fromRGB(25, 25, 25),
        ItemHeight = 40,
        Spacing = 5
    },
    Animation = {
        Duration = 0.3,
        Style = Enum.EasingStyle.Back,
        Direction = Enum.EasingDirection.Out
    }
}

-- State
FloatingButton.isVisible = false
FloatingButton.menuOpen = false
FloatingButton.modules = nil

-- Create floating button
function FloatingButton.create(modules)
    FloatingButton.modules = modules
    
    -- Main ScreenGui
    FloatingButton.ScreenGui = Instance.new("ScreenGui")
    FloatingButton.ScreenGui.Name = "AutoFishFloatingButton"
    FloatingButton.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    FloatingButton.ScreenGui.ResetOnSpawn = false
    
    -- Protect GUI
    if gethui then
        FloatingButton.ScreenGui.Parent = gethui()
    else
        FloatingButton.ScreenGui.Parent = CoreGui
    end
    
    -- Main Button Frame
    FloatingButton.MainButton = Instance.new("TextButton")
    FloatingButton.MainButton.Name = "FloatingButton"
    FloatingButton.MainButton.Size = UDim2.new(0, Config.Button.Size[1], 0, Config.Button.Size[2])
    FloatingButton.MainButton.Position = UDim2.new(0, Config.Button.Position[1], 0, Config.Button.Position[2])
    FloatingButton.MainButton.BackgroundColor3 = Config.Button.BackgroundColor
    FloatingButton.MainButton.BorderSizePixel = 0
    FloatingButton.MainButton.Text = ""
    FloatingButton.MainButton.AutoButtonColor = false
    FloatingButton.MainButton.Active = true
    FloatingButton.MainButton.Draggable = true
    FloatingButton.MainButton.Parent = FloatingButton.ScreenGui
    
    -- Button Corner
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0.5, 0) -- Circle
    buttonCorner.Parent = FloatingButton.MainButton
    
    -- Button Border
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = Config.Button.BorderColor
    buttonStroke.Thickness = 2
    buttonStroke.Parent = FloatingButton.MainButton
    
    -- Button Shadow
    if Config.Button.Shadow then
        local shadow = Instance.new("Frame")
        shadow.Name = "Shadow"
        shadow.Size = UDim2.new(1, 4, 1, 4)
        shadow.Position = UDim2.new(0, 2, 0, 2)
        shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        shadow.BackgroundTransparency = 0.7
        shadow.BorderSizePixel = 0
        shadow.ZIndex = FloatingButton.MainButton.ZIndex - 1
        shadow.Parent = FloatingButton.ScreenGui
        
        local shadowCorner = Instance.new("UICorner")
        shadowCorner.CornerRadius = UDim.new(0.5, 0)
        shadowCorner.Parent = shadow
        
        -- Update shadow position when button moves
        FloatingButton.MainButton:GetPropertyChangedSignal("Position"):Connect(function()
            shadow.Position = UDim2.new(FloatingButton.MainButton.Position.X.Scale, FloatingButton.MainButton.Position.X.Offset + 2, 
                                       FloatingButton.MainButton.Position.Y.Scale, FloatingButton.MainButton.Position.Y.Offset + 2)
        end)
    end
    
    -- Fish Icon
    FloatingButton.Icon = Instance.new("TextLabel")
    FloatingButton.Icon.Size = UDim2.new(0.6, 0, 0.6, 0)
    FloatingButton.Icon.Position = UDim2.new(0.2, 0, 0.2, 0)
    FloatingButton.Icon.BackgroundTransparency = 1
    FloatingButton.Icon.Text = "🎣"
    FloatingButton.Icon.TextColor3 = Config.Button.IconColor
    FloatingButton.Icon.TextScaled = true
    FloatingButton.Icon.Font = Enum.Font.SourceSansBold
    FloatingButton.Icon.Parent = FloatingButton.MainButton
    
    -- Status Indicator
    FloatingButton.StatusIndicator = Instance.new("Frame")
    FloatingButton.StatusIndicator.Name = "StatusIndicator"
    FloatingButton.StatusIndicator.Size = UDim2.new(0, 12, 0, 12)
    FloatingButton.StatusIndicator.Position = UDim2.new(1, -16, 0, 4)
    FloatingButton.StatusIndicator.BackgroundColor3 = Color3.fromRGB(255, 85, 85) -- Red = inactive
    FloatingButton.StatusIndicator.BorderSizePixel = 0
    FloatingButton.StatusIndicator.Parent = FloatingButton.MainButton
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0.5, 0)
    indicatorCorner.Parent = FloatingButton.StatusIndicator
    
    -- Create popup menu
    FloatingButton.createMenu()
    
    -- Button interactions
    FloatingButton.setupInteractions()
    
    -- Auto-update status
    FloatingButton.startStatusUpdate()
    
    FloatingButton.isVisible = true
    print("🎮 Floating button created successfully!")
    
    return FloatingButton
end

-- Create popup menu
function FloatingButton.createMenu()
    -- Menu Frame
    FloatingButton.MenuFrame = Instance.new("Frame")
    FloatingButton.MenuFrame.Name = "FloatingMenu"
    FloatingButton.MenuFrame.Size = UDim2.new(0, Config.Menu.Size[1], 0, Config.Menu.Size[2])
    FloatingButton.MenuFrame.Position = UDim2.new(0, Config.Button.Position[1] + 70, 0, Config.Button.Position[2])
    FloatingButton.MenuFrame.BackgroundColor3 = Config.Menu.BackgroundColor
    FloatingButton.MenuFrame.BorderSizePixel = 0
    FloatingButton.MenuFrame.Visible = false
    FloatingButton.MenuFrame.Parent = FloatingButton.ScreenGui
    
    -- Menu Corner
    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, 12)
    menuCorner.Parent = FloatingButton.MenuFrame
    
    -- Menu Border
    local menuStroke = Instance.new("UIStroke")
    menuStroke.Color = Config.Button.BorderColor
    menuStroke.Thickness = 1
    menuStroke.Parent = FloatingButton.MenuFrame
    
    -- Menu Layout
    local menuLayout = Instance.new("UIListLayout")
    menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
    menuLayout.Padding = UDim.new(0, Config.Menu.Spacing)
    menuLayout.Parent = FloatingButton.MenuFrame
    
    -- Menu Padding
    local menuPadding = Instance.new("UIPadding")
    menuPadding.PaddingTop = UDim.new(0, 10)
    menuPadding.PaddingBottom = UDim.new(0, 10)
    menuPadding.PaddingLeft = UDim.new(0, 10)
    menuPadding.PaddingRight = UDim.new(0, 10)
    menuPadding.Parent = FloatingButton.MenuFrame
    
    -- Menu Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "🎣 AutoFish Pro"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.LayoutOrder = 1
    title.Parent = FloatingButton.MenuFrame
    
    -- Menu Items
    FloatingButton.createMenuItem("🎣 Toggle AutoFish", 2, function()
        FloatingButton.toggleAutoFish()
    end)
    
    FloatingButton.createMenuItem("🚶 Toggle Float", 3, function()
        FloatingButton.toggleFloat()
    end)
    
    FloatingButton.createMenuItem("💰 Sell All Fish", 4, function()
        FloatingButton.sellAllFish()
    end)
    
    FloatingButton.createMenuItem("📊 Show Dashboard", 5, function()
        FloatingButton.showMainUI()
    end)
    
    FloatingButton.createMenuItem("⚙️ Settings", 6, function()
        FloatingButton.openSettings()
    end)
    
    FloatingButton.createMenuItem("❌ Close Menu", 7, function()
        FloatingButton.toggleMenu()
    end)
end

-- Create menu item
function FloatingButton.createMenuItem(text, order, callback)
    local item = Instance.new("TextButton")
    item.Name = "MenuItem" .. order
    item.Size = UDim2.new(1, 0, 0, Config.Menu.ItemHeight)
    item.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    item.BorderSizePixel = 0
    item.Text = text
    item.TextColor3 = Color3.fromRGB(255, 255, 255)
    item.TextSize = 14
    item.Font = Enum.Font.Gotham
    item.TextXAlignment = Enum.TextXAlignment.Left
    item.LayoutOrder = order
    item.Parent = FloatingButton.MenuFrame
    
    -- Item Corner
    local itemCorner = Instance.new("UICorner")
    itemCorner.CornerRadius = UDim.new(0, 8)
    itemCorner.Parent = item
    
    -- Item Padding
    local itemPadding = Instance.new("UIPadding")
    itemPadding.PaddingLeft = UDim.new(0, 10)
    itemPadding.Parent = item
    
    -- Item Interactions
    item.MouseButton1Click:Connect(function()
        callback()
    end)
    
    item.MouseEnter:Connect(function()
        TweenService:Create(item, TweenInfo.new(0.2), {
            BackgroundColor3 = Config.Button.BackgroundColor
        }):Play()
    end)
    
    item.MouseLeave:Connect(function()
        TweenService:Create(item, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        }):Play()
    end)
    
    return item
end

-- Setup button interactions
function FloatingButton.setupInteractions()
    -- Main button click
    FloatingButton.MainButton.MouseButton1Click:Connect(function()
        FloatingButton.toggleMenu()
    end)
    
    -- Button hover effects
    FloatingButton.MainButton.MouseEnter:Connect(function()
        TweenService:Create(FloatingButton.MainButton, TweenInfo.new(0.2), {
            Size = UDim2.new(0, Config.Button.Size[1] + 5, 0, Config.Button.Size[2] + 5),
            BackgroundColor3 = Color3.fromRGB(140, 100, 220)
        }):Play()
    end)
    
    FloatingButton.MainButton.MouseLeave:Connect(function()
        TweenService:Create(FloatingButton.MainButton, TweenInfo.new(0.2), {
            Size = UDim2.new(0, Config.Button.Size[1], 0, Config.Button.Size[2]),
            BackgroundColor3 = Config.Button.BackgroundColor
        }):Play()
    end)
    
    -- Close menu when clicking outside
    FloatingButton.ScreenGui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and FloatingButton.menuOpen then
            local mousePos = UserInputService:GetMouseLocation()
            local menuPos = FloatingButton.MenuFrame.AbsolutePosition
            local menuSize = FloatingButton.MenuFrame.AbsoluteSize
            
            -- Check if click is outside menu
            if mousePos.X < menuPos.X or mousePos.X > menuPos.X + menuSize.X or
               mousePos.Y < menuPos.Y or mousePos.Y > menuPos.Y + menuSize.Y then
                FloatingButton.toggleMenu()
            end
        end
    end)
end

-- Toggle menu
function FloatingButton.toggleMenu()
    FloatingButton.menuOpen = not FloatingButton.menuOpen
    
    if FloatingButton.menuOpen then
        -- Show menu
        FloatingButton.MenuFrame.Visible = true
        FloatingButton.MenuFrame.Size = UDim2.new(0, 0, 0, 0)
        
        TweenService:Create(FloatingButton.MenuFrame, TweenInfo.new(Config.Animation.Duration, Config.Animation.Style, Config.Animation.Direction), {
            Size = UDim2.new(0, Config.Menu.Size[1], 0, Config.Menu.Size[2])
        }):Play()
        
        -- Rotate icon
        TweenService:Create(FloatingButton.Icon, TweenInfo.new(0.3), {
            Rotation = 180
        }):Play()
    else
        -- Hide menu
        TweenService:Create(FloatingButton.MenuFrame, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        
        wait(0.2)
        FloatingButton.MenuFrame.Visible = false
        
        -- Reset icon rotation
        TweenService:Create(FloatingButton.Icon, TweenInfo.new(0.3), {
            Rotation = 0
        }):Play()
    end
end

-- Action functions
function FloatingButton.toggleAutoFish()
    if FloatingButton.modules and FloatingButton.modules.autofish then
        local autofish = FloatingButton.modules.autofish
        if autofish.isRunning and autofish.isRunning() then
            if autofish.stop then autofish.stop() end
            print("🎣 AutoFish stopped")
        else
            if autofish.start then autofish.start() end
            print("🎣 AutoFish started")
        end
    end
    FloatingButton.toggleMenu()
end

function FloatingButton.toggleFloat()
    if FloatingButton.modules and FloatingButton.modules.movement then
        local movement = FloatingButton.modules.movement
        if movement.toggleFloat then
            movement.toggleFloat()
            print("🚶 Float mode toggled")
        end
    end
    FloatingButton.toggleMenu()
end

function FloatingButton.sellAllFish()
    if FloatingButton.modules and FloatingButton.modules.autosell then
        local autosell = FloatingButton.modules.autosell
        if autosell.sellAll then
            autosell.sellAll()
            print("💰 Selling all fish...")
        end
    end
    FloatingButton.toggleMenu()
end

function FloatingButton.showMainUI()
    -- Try to show main UI if available
    if getgenv().AutoFishPro and getgenv().AutoFishPro.showUI then
        getgenv().AutoFishPro.showUI()
        print("📊 Main UI opened")
    end
    FloatingButton.toggleMenu()
end

function FloatingButton.openSettings()
    print("⚙️ Settings coming soon...")
    FloatingButton.toggleMenu()
end

-- Status update
function FloatingButton.startStatusUpdate()
    spawn(function()
        while FloatingButton.isVisible and FloatingButton.StatusIndicator do
            local isActive = false
            
            -- Check if autofish is running
            if FloatingButton.modules and FloatingButton.modules.autofish then
                local autofish = FloatingButton.modules.autofish
                if autofish.isRunning and autofish.isRunning() then
                    isActive = true
                end
            end
            
            -- Update status indicator color
            local newColor = isActive and Color3.fromRGB(85, 255, 85) or Color3.fromRGB(255, 85, 85)
            TweenService:Create(FloatingButton.StatusIndicator, TweenInfo.new(0.5), {
                BackgroundColor3 = newColor
            }):Play()
            
            wait(1)
        end
    end)
end

-- Destroy floating button
function FloatingButton.destroy()
    FloatingButton.isVisible = false
    if FloatingButton.ScreenGui then
        FloatingButton.ScreenGui:Destroy()
    end
end

return FloatingButton
