-- modules/rayfield_ui.lua
-- Rayfield UI Interface Module for AutoFish System

local RayfieldUI = {}

-- Use globally loaded Rayfield Library or load it if not available
local function getRayfieldLib()
    if getgenv().RayfieldLib then
        print("✅ Using globally loaded Rayfield Library")
        return getgenv().RayfieldLib
    else
        print("📚 Loading Rayfield Library for UI module...")
        local success, RayfieldLib = pcall(function()
            local url = "https://raw.githubusercontent.com/MELLISAEFFENDY/fullversion/main/rayfield_lib.lua"
            local code = game:HttpGet(url)
            if code and code ~= "" then
                local func = loadstring(code)
                if func then
                    return func()
                else
                    error("Failed to compile custom Rayfield library")
                end
            else
                error("Failed to download custom Rayfield library")
            end
        end)
        
        if success and RayfieldLib then
            print("✅ Custom Rayfield Library loaded successfully")
            getgenv().RayfieldLib = RayfieldLib -- Store globally for reuse
            return RayfieldLib
        else
            error("Failed to load custom Rayfield library: " .. tostring(RayfieldLib))
        end
    end
end

RayfieldUI.Window = nil
RayfieldUI.Tabs = {}
RayfieldUI.Elements = {}

-- UI State
RayfieldUI.autoUpdateEnabled = true
RayfieldUI.updateFrequency = 1

-- Configuration
local config = {
    Name = "🎣 AutoFish Pro",
    LoadingTitle = "AutoFish Pro",
    LoadingSubtitle = "Loading interface...",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "AutoFishPro"
    },
    KeySystem = false
}

-- Initialize Rayfield UI
function RayfieldUI.init(modules)
    if not modules then
        error("❌ No modules provided to Rayfield UI")
    end
    
    RayfieldUI.modules = modules
    
    -- Get Rayfield Library
    local RayfieldLib = getRayfieldLib()
    if not RayfieldLib then
        error("❌ Rayfield Library not available")
    end
    
    print("🎨 Creating Rayfield UI Window...")
    
    -- Create main window
    local success, window = pcall(function()
        return RayfieldLib:CreateWindow(config)
    end)
    
    if not success or not window then
        error("❌ Failed to create Rayfield window: " .. tostring(window))
    end
    
    RayfieldUI.Window = window
    print("✅ Rayfield UI Window created successfully")
    
    -- Create tabs with error handling
    local tabSuccess, tabError = pcall(function()
        RayfieldUI.createTabs()
    end)
    
    if not tabSuccess then
        print("⚠️ Warning: Failed to create some tabs: " .. tostring(tabError))
    end
    
    -- Start auto-update
    if RayfieldUI.autoUpdateEnabled then
        RayfieldUI.startAutoUpdate()
    end
    
    -- Initialize UI keybind
    RayfieldUI.toggleUIKeybind(true)
    
    return RayfieldUI
end

-- Create UI tabs
function RayfieldUI.createTabs()
    -- AutoFish Tab
    RayfieldUI.Tabs.AutoFish = RayfieldUI.Window:CreateTab({Name = "🎣 AutoFish"})
    RayfieldUI.createAutoFishTab()
    
    -- Enhanced Fishing Tab
    RayfieldUI.Tabs.EnhancedFishing = RayfieldUI.Window:CreateTab({Name = "⚡ Enhanced Fishing"})
    RayfieldUI.createEnhancedFishingTab()
    
    -- Movement Tab
    RayfieldUI.Tabs.Movement = RayfieldUI.Window:CreateTab({Name = "🚶 Movement"})
    RayfieldUI.createMovementTab()
    
    -- AutoSell Tab
    RayfieldUI.Tabs.AutoSell = RayfieldUI.Window:CreateTab({Name = "💰 AutoSell"})
    RayfieldUI.createAutoSellTab()
    
    -- Security Tab
    RayfieldUI.Tabs.Security = RayfieldUI.Window:CreateTab({Name = "🛡️ Security"})
    RayfieldUI.createSecurityTab()
    
    -- Settings Tab
    RayfieldUI.Tabs.Settings = RayfieldUI.Window:CreateTab({Name = "⚙️ Settings"})
    RayfieldUI.createSettingsTab()
    
    -- Dashboard Tab
    RayfieldUI.Tabs.Dashboard = RayfieldUI.Window:CreateTab({Name = "📊 Dashboard"})
    RayfieldUI.createDashboardTab()
end

-- AutoFish Tab
function RayfieldUI.createAutoFishTab()
    local tab = RayfieldUI.Tabs.AutoFish
    local autofish = RayfieldUI.modules.autofish
    
    if not autofish then
        tab:CreateButton({
            Name = "❌ AutoFish Module Not Available",
            Callback = function() end
        })
        return
    end
    
    -- AutoFish Toggle
    RayfieldUI.Elements.AutoFishToggle = tab:CreateToggle({
        Name = "Enable AutoFish",
        CurrentValue = false,
        Flag = "AutoFishEnabled",
        Callback = function(value)
            if value then
                if autofish.start then
                    autofish.start()
                end
            else
                if autofish.stop then
                    autofish.stop()
                end
            end
        end
    })
    
    -- Cast Power Slider
    RayfieldUI.Elements.CastPowerSlider = tab:CreateSlider({
        Name = "Cast Power",
        Range = {10, 100},
        Increment = 5,
        CurrentValue = 75,
        Flag = "CastPower",
        Callback = function(value)
            if autofish.setCastPower then
                autofish.setCastPower(value)
            end
        end
    })
    
    -- Auto Cast Toggle
    RayfieldUI.Elements.AutoCastToggle = tab:CreateToggle({
        Name = "Auto Cast",
        CurrentValue = true,
        Flag = "AutoCast",
        Callback = function(value)
            if autofish.setAutoCast then
                autofish.setAutoCast(value)
            end
        end
    })
    
    -- Fish Detection Toggle
    RayfieldUI.Elements.FishDetectionToggle = tab:CreateToggle({
        Name = "Fish Detection",
        CurrentValue = true,
        Flag = "FishDetection",
        Callback = function(value)
            if autofish.setFishDetection then
                autofish.setFishDetection(value)
            end
        end
    })
end

-- Movement Tab
function RayfieldUI.createMovementTab()
    local tab = RayfieldUI.Tabs.Movement
    local movement = RayfieldUI.modules.movement
    
    if not movement then
        tab:CreateButton({
            Name = "❌ Movement Module Not Available",
            Callback = function() end
        })
        return
    end
    
    -- Float Toggle
    RayfieldUI.Elements.FloatToggle = tab:CreateToggle({
        Name = "Float Mode",
        CurrentValue = false,
        Flag = "FloatMode",
        Callback = function(value)
            if movement.setFloat then
                movement.setFloat(value)
            end
        end
    })
    
    -- NoClip Toggle
    RayfieldUI.Elements.NoClipToggle = tab:CreateToggle({
        Name = "NoClip Mode",
        CurrentValue = false,
        Flag = "NoClipMode",
        Callback = function(value)
            if movement.setNoClip then
                movement.setNoClip(value)
            end
        end
    })
    
    -- Speed Slider
    RayfieldUI.Elements.SpeedSlider = tab:CreateSlider({
        Name = "Walk Speed",
        Range = {16, 100},
        Increment = 1,
        CurrentValue = 16,
        Flag = "WalkSpeed",
        Callback = function(value)
            if movement.setSpeed then
                movement.setSpeed(value)
            end
        end
    })
    
    -- Jump Power Slider
    RayfieldUI.Elements.JumpPowerSlider = tab:CreateSlider({
        Name = "Jump Power",
        Range = {50, 150},
        Increment = 5,
        CurrentValue = 50,
        Flag = "JumpPower",
        Callback = function(value)
            if movement.setJumpPower then
                movement.setJumpPower(value)
            end
        end
    })
end

-- AutoSell Tab
function RayfieldUI.createAutoSellTab()
    local tab = RayfieldUI.Tabs.AutoSell
    local autosell = RayfieldUI.modules.autosell
    
    if not autosell then
        tab:CreateButton({
            Name = "❌ AutoSell Module Not Available",
            Callback = function() end
        })
        return
    end
    
    -- AutoSell Toggle
    RayfieldUI.Elements.AutoSellToggle = tab:CreateToggle({
        Name = "Enable AutoSell",
        CurrentValue = false,
        Flag = "AutoSellEnabled",
        Callback = function(value)
            if autosell.setEnabled then
                autosell.setEnabled(value)
            end
        end
    })
    
    -- Inventory Threshold Slider
    RayfieldUI.Elements.InventoryThresholdSlider = tab:CreateSlider({
        Name = "Inventory Threshold (%)",
        Range = {50, 95},
        Increment = 5,
        CurrentValue = 80,
        Flag = "InventoryThreshold",
        Callback = function(value)
            if autosell.setThreshold then
                autosell.setThreshold(value)
            end
        end
    })
    
    -- Sell All Button
    RayfieldUI.Elements.SellAllButton = tab:CreateButton({
        Name = "💰 Sell All Fish Now",
        Callback = function()
            if autosell.sellAll then
                autosell.sellAll()
            end
        end
    })
end

-- Security Tab
function RayfieldUI.createSecurityTab()
    local tab = RayfieldUI.Tabs.Security
    local security = RayfieldUI.modules.security
    
    if not security then
        tab:CreateButton({
            Name = "❌ Security Module Not Available",
            Callback = function() end
        })
        return
    end
    
    -- Anti-Detection Toggle
    RayfieldUI.Elements.AntiDetectionToggle = tab:CreateToggle({
        Name = "Anti-Detection",
        CurrentValue = true,
        Flag = "AntiDetection",
        Callback = function(value)
            if security.setAntiDetection then
                security.setAntiDetection(value)
            end
        end
    })
    
    -- Anti-AFK Toggle
    RayfieldUI.Elements.AntiAFKToggle = tab:CreateToggle({
        Name = "Anti-AFK",
        CurrentValue = true,
        Flag = "AntiAFK",
        Callback = function(value)
            if security.setAntiAFK then
                security.setAntiAFK(value)
            end
        end
    })
    
    -- Randomization Slider
    RayfieldUI.Elements.RandomizationSlider = tab:CreateSlider({
        Name = "Action Randomization (%)",
        Range = {0, 50},
        Increment = 5,
        CurrentValue = 20,
        Flag = "Randomization",
        Callback = function(value)
            if security.setRandomization then
                security.setRandomization(value)
            end
        end
    })
end

-- Settings Tab
function RayfieldUI.createSettingsTab()
    local tab = RayfieldUI.Tabs.Settings
    
    -- Boost FPS Toggle
    RayfieldUI.Elements.BoostFPSToggle = tab:CreateToggle({
        Name = "🚀 Boost FPS",
        CurrentValue = false,
        Flag = "BoostFPS",
        Callback = function(value)
            RayfieldUI.toggleBoostFPS(value)
        end
    })
    
    -- HDR Shader Toggle
    RayfieldUI.Elements.HDRShaderToggle = tab:CreateToggle({
        Name = "🌈 HDR Shader",
        CurrentValue = false,
        Flag = "HDRShader",
        Callback = function(value)
            RayfieldUI.toggleHDRShader(value)
        end
    })
    
    -- Rejoin Server Button
    RayfieldUI.Elements.RejoinButton = tab:CreateButton({
        Name = "🔄 Rejoin Server",
        Callback = function()
            RayfieldUI.rejoinServer()
        end
    })
    
    -- Small Server Button
    RayfieldUI.Elements.SmallServerButton = tab:CreateButton({
        Name = "👥 Small Server",
        Callback = function()
            RayfieldUI.findSmallServer()
        end
    })
    
    -- Server Hop Button
    RayfieldUI.Elements.ServerHopButton = tab:CreateButton({
        Name = "🌐 Server Hop",
        Callback = function()
            RayfieldUI.serverHop()
        end
    })
    
    -- UI Toggle Keybind
    RayfieldUI.Elements.UIKeybindToggle = tab:CreateToggle({
        Name = "🎮 UI Toggle (Right Ctrl)",
        CurrentValue = true,
        Flag = "UIKeybind",
        Callback = function(value)
            RayfieldUI.toggleUIKeybind(value)
        end
    })
    
    -- Menu Visibility Toggle
    RayfieldUI.Elements.MenuVisibilityToggle = tab:CreateToggle({
        Name = "👁️ Show Menu",
        CurrentValue = true,
        Flag = "MenuVisibility",
        Callback = function(value)
            RayfieldUI.toggleMenuVisibility(value)
        end
    })
    
    -- Floating Button Toggle
    RayfieldUI.Elements.FloatingButtonToggle = tab:CreateToggle({
        Name = "🎯 Floating Button",
        CurrentValue = false,
        Flag = "FloatingButton",
        Callback = function(value)
            RayfieldUI.toggleFloatingButton(value)
        end
    })
end

-- Dashboard Tab
function RayfieldUI.createDashboardTab()
    local tab = RayfieldUI.Tabs.Dashboard
    
    -- Status Display
    RayfieldUI.Elements.StatusLabel = tab:CreateButton({
        Name = "📊 Status: Initializing...",
        Callback = function() end
    })
    
    -- Fish Caught Display
    RayfieldUI.Elements.FishCaughtLabel = tab:CreateButton({
        Name = "🐟 Fish Caught: 0",
        Callback = function() end
    })
    
    -- Runtime Display
    RayfieldUI.Elements.RuntimeLabel = tab:CreateButton({
        Name = "⏱️ Runtime: 00:00:00",
        Callback = function() end
    })
    
    -- Revenue Display
    RayfieldUI.Elements.RevenueLabel = tab:CreateButton({
        Name = "💰 Total Revenue: $0",
        Callback = function() end
    })
end

-- Auto-update dashboard
function RayfieldUI.startAutoUpdate()
    spawn(function()
        while RayfieldUI.autoUpdateEnabled and RayfieldUI.Window do
            pcall(function()
                RayfieldUI.updateDashboard()
            end)
            wait(RayfieldUI.updateFrequency)
        end
    end)
end

function RayfieldUI.updateDashboard()
    if not RayfieldUI.modules or not RayfieldUI.modules.dashboard then
        return
    end
    
    local dashboard = RayfieldUI.modules.dashboard
    local stats = dashboard.getStats and dashboard.getStats() or {}
    
    -- Update status
    if RayfieldUI.Elements.StatusLabel then
        local status = "Idle"
        if RayfieldUI.modules.autofish and RayfieldUI.modules.autofish.isRunning and RayfieldUI.modules.autofish.isRunning() then
            status = "Fishing Active"
        end
        -- Note: Rayfield doesn't have direct text update, so we'd need to recreate or use a different approach
    end
end

-- Utility functions
function RayfieldUI.showNotification(title, message, duration)
    print("📢 " .. title .. ": " .. message)
end

function RayfieldUI.destroy()
    RayfieldUI.autoUpdateEnabled = false
    if RayfieldUI.Window then
        RayfieldUI.Window:Destroy()
    end
end

-- Compatibility functions for other modules
function RayfieldUI.setMode(mode)
    print("🔧 Mode set to: " .. tostring(mode))
end

function RayfieldUI.setCastPower(power)
    if RayfieldUI.Elements.CastPowerSlider then
        RayfieldUI.Elements.CastPowerSlider:Set(power)
    end
end

function RayfieldUI.setFloat(enabled)
    if RayfieldUI.Elements.FloatToggle then
        RayfieldUI.Elements.FloatToggle:Set(enabled)
    end
end

function RayfieldUI.setAutoSell(enabled)
    if RayfieldUI.Elements.AutoSellToggle then
        RayfieldUI.Elements.AutoSellToggle:Set(enabled)
    end
end

-- Settings Functions
function RayfieldUI.toggleBoostFPS(enabled)
    pcall(function()
        local Lighting = game:GetService("Lighting")
        local Terrain = workspace.Terrain
        
        if enabled then
            -- Boost FPS settings
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.Brightness = 0
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 0
            
            -- Reduce graphics quality
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
                    obj.Material = Enum.Material.Plastic
                    obj.Reflectance = 0
                end
                if obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = 1
                end
            end
            
            print("🚀 FPS Boost: Enabled")
        else
            -- Restore normal settings
            Lighting.GlobalShadows = true
            Lighting.FogEnd = 100000
            Lighting.Brightness = 1
            Terrain.WaterWaveSize = 0.15
            Terrain.WaterWaveSpeed = 10
            Terrain.WaterReflectance = 0.04
            Terrain.WaterTransparency = 0.3
            
            print("🚀 FPS Boost: Disabled")
        end
    end)
end

function RayfieldUI.toggleHDRShader(enabled)
    pcall(function()
        local Lighting = game:GetService("Lighting")
        
        if enabled then
            -- HDR Shader effects
            local ColorCorrection = Instance.new("ColorCorrectionEffect")
            ColorCorrection.Name = "HDRShader"
            ColorCorrection.Brightness = 0.1
            ColorCorrection.Contrast = 0.2
            ColorCorrection.Saturation = 0.3
            ColorCorrection.TintColor = Color3.fromRGB(255, 240, 220)
            ColorCorrection.Parent = Lighting
            
            local Bloom = Instance.new("BloomEffect")
            Bloom.Name = "HDRBloom"
            Bloom.Intensity = 0.5
            Bloom.Size = 25
            Bloom.Threshold = 1.2
            Bloom.Parent = Lighting
            
            print("🌈 HDR Shader: Enabled")
        else
            -- Remove HDR effects
            if Lighting:FindFirstChild("HDRShader") then
                Lighting.HDRShader:Destroy()
            end
            if Lighting:FindFirstChild("HDRBloom") then
                Lighting.HDRBloom:Destroy()
            end
            
            print("🌈 HDR Shader: Disabled")
        end
    end)
end

function RayfieldUI.rejoinServer()
    pcall(function()
        local TeleportService = game:GetService("TeleportService")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        
        print("🔄 Rejoining server...")
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
end

function RayfieldUI.findSmallServer()
    pcall(function()
        local TeleportService = game:GetService("TeleportService")
        local HttpService = game:GetService("HttpService")
        local Players = game:GetService("Players")
        
        print("👥 Finding small server...")
        
        local success, servers = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        
        if success and servers.data then
            for _, server in pairs(servers.data) do
                if server.playing < 10 and server.playing > 0 and server.id ~= game.JobId then
                    print("👥 Found small server with " .. server.playing .. " players")
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                    return
                end
            end
        end
        
        print("👥 No small server found, rejoining current server")
        RayfieldUI.rejoinServer()
    end)
end

function RayfieldUI.serverHop()
    pcall(function()
        local TeleportService = game:GetService("TeleportService")
        local HttpService = game:GetService("HttpService")
        local Players = game:GetService("Players")
        
        print("🌐 Server hopping...")
        
        local success, servers = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        
        if success and servers.data then
            local randomServer = servers.data[math.random(1, #servers.data)]
            if randomServer.id ~= game.JobId then
                print("🌐 Hopping to server with " .. randomServer.playing .. " players")
                TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer.id)
                return
            end
        end
        
        print("🌐 Server hop failed, rejoining current server")
        RayfieldUI.rejoinServer()
    end)
end

-- UI Keybind system
RayfieldUI.keybindEnabled = true
RayfieldUI.keybindConnection = nil

function RayfieldUI.toggleUIKeybind(enabled)
    RayfieldUI.keybindEnabled = enabled
    
    if enabled then
        if not RayfieldUI.keybindConnection then
            local UserInputService = game:GetService("UserInputService")
            
            RayfieldUI.keybindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                
                if input.KeyCode == Enum.KeyCode.RightControl then
                    if RayfieldUI.Window then
                        local currentVisibility = RayfieldUI.Window.MainFrame.Visible
                        RayfieldUI.toggleMenuVisibility(not currentVisibility)
                        if RayfieldUI.Elements.MenuVisibilityToggle then
                            RayfieldUI.Elements.MenuVisibilityToggle:Set(not currentVisibility)
                        end
                    end
                end
            end)
        end
        print("🎮 UI Keybind: Enabled (Right Ctrl)")
    else
        if RayfieldUI.keybindConnection then
            RayfieldUI.keybindConnection:Disconnect()
            RayfieldUI.keybindConnection = nil
        end
        print("🎮 UI Keybind: Disabled")
    end
end

function RayfieldUI.toggleMenuVisibility(visible)
    if RayfieldUI.Window and RayfieldUI.Window.MainFrame then
        RayfieldUI.Window.MainFrame.Visible = visible
        print("👁️ Menu: " .. (visible and "Shown" or "Hidden"))
    end
end

-- Floating Button system
RayfieldUI.FloatingButton = nil

function RayfieldUI.toggleFloatingButton(enabled)
    if enabled then
        RayfieldUI.createFloatingButton()
    else
        RayfieldUI.destroyFloatingButton()
    end
end

function RayfieldUI.createFloatingButton()
    if RayfieldUI.FloatingButton then
        RayfieldUI.destroyFloatingButton()
    end
    
    pcall(function()
        local Players = game:GetService("Players")
        local TweenService = game:GetService("TweenService")
        local UserInputService = game:GetService("UserInputService")
        
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "AutoFishFloatingButton"
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.ResetOnSpawn = false
        
        if gethui then
            ScreenGui.Parent = gethui()
        else
            ScreenGui.Parent = game:GetService("CoreGui")
        end
        
        -- Main floating button
        local FloatingButton = Instance.new("TextButton")
        FloatingButton.Name = "FloatingButton"
        FloatingButton.Size = UDim2.new(0, 60, 0, 60)
        FloatingButton.Position = UDim2.new(1, -80, 0.5, -30)
        FloatingButton.BackgroundColor3 = Color3.fromRGB(120, 80, 200) -- Purple theme
        FloatingButton.Text = "🎣"
        FloatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        FloatingButton.TextSize = 24
        FloatingButton.Font = Enum.Font.GothamBold
        FloatingButton.BorderSizePixel = 0
        FloatingButton.Parent = ScreenGui
        
        -- Corner and shadow
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 30)
        Corner.Parent = FloatingButton
        
        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Color3.fromRGB(150, 100, 220)
        Stroke.Thickness = 2
        Stroke.Parent = FloatingButton
        
        -- Make draggable
        local dragging = false
        local dragStart = nil
        local startPos = nil
        
        FloatingButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = FloatingButton.Position
            end
        end)
        
        FloatingButton.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                local delta = input.Position - dragStart
                FloatingButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        
        FloatingButton.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        -- Click to toggle AutoFish
        FloatingButton.MouseButton1Click:Connect(function()
            if not dragging then
                if RayfieldUI.modules and RayfieldUI.modules.autofish then
                    local isRunning = RayfieldUI.modules.autofish.isRunning and RayfieldUI.modules.autofish.isRunning() or false
                    
                    if isRunning then
                        if RayfieldUI.modules.autofish.stop then
                            RayfieldUI.modules.autofish.stop()
                            FloatingButton.Text = "🎣"
                            FloatingButton.BackgroundColor3 = Color3.fromRGB(120, 80, 200)
                        end
                    else
                        if RayfieldUI.modules.autofish.start then
                            RayfieldUI.modules.autofish.start()
                            FloatingButton.Text = "🟢"
                            FloatingButton.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
                        end
                    end
                    
                    -- Update UI toggle if available
                    if RayfieldUI.Elements.AutoFishToggle then
                        RayfieldUI.Elements.AutoFishToggle:Set(not isRunning)
                    end
                end
            end
        end)
        
        -- Right click to show/hide main UI
        FloatingButton.MouseButton2Click:Connect(function()
            if RayfieldUI.Window and RayfieldUI.Window.MainFrame then
                local currentVisibility = RayfieldUI.Window.MainFrame.Visible
                RayfieldUI.toggleMenuVisibility(not currentVisibility)
                if RayfieldUI.Elements.MenuVisibilityToggle then
                    RayfieldUI.Elements.MenuVisibilityToggle:Set(not currentVisibility)
                end
            end
        end)
        
        -- Hover effects
        FloatingButton.MouseEnter:Connect(function()
            TweenService:Create(FloatingButton, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 70, 0, 70),
                BackgroundTransparency = 0.1
            }):Play()
        end)
        
        FloatingButton.MouseLeave:Connect(function()
            TweenService:Create(FloatingButton, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 60, 0, 60),
                BackgroundTransparency = 0
            }):Play()
        end)
        
        RayfieldUI.FloatingButton = ScreenGui
        print("🎯 Floating Button: Created")
    end)
end

-- Enhanced Fishing Tab
function RayfieldUI.createEnhancedFishingTab()
    local tab = RayfieldUI.Tabs.EnhancedFishing
    if not tab then return end
    
    -- Load Enhanced Fishing Module
    local EnhancedFishing
    pcall(function()
        local url = "https://raw.githubusercontent.com/MELLISAEFFENDY/fullversion/main/modules/enhanced_fishing.lua"
        local moduleCode = game:HttpGet(url)
        if moduleCode and moduleCode ~= "" then
            local moduleFunc = loadstring(moduleCode)
            if moduleFunc then
                EnhancedFishing = moduleFunc()
                EnhancedFishing.initialize()
                print("✅ Enhanced Fishing Module loaded")
            end
        end
    end)
    
    if not EnhancedFishing then
        tab:CreateLabel({
            Text = "❌ Enhanced Fishing Module failed to load"
        })
        return
    end
    
    -- Header
    tab:CreateLabel({
        Text = "⚡ Enhanced Fishing System"
    })
    
    tab:CreateLabel({
        Text = "Advanced fishing exploits using game's official systems"
    })
    
    -- Enhanced AutoFish Toggle
    RayfieldUI.Elements.EnhancedAutoFish = tab:CreateToggle({
        Name = "🚀 Enhanced AutoFish",
        CurrentValue = false,
        Callback = function(Value)
            if EnhancedFishing then
                local success = EnhancedFishing.toggleFeature("enhancedAutoFish")
                if success then
                    print("✅ Enhanced AutoFish: " .. (Value and "Enabled" or "Disabled"))
                else
                    print("❌ Enhanced AutoFish failed to toggle")
                end
            end
        end
    })
    
    -- Smart Timing Toggle
    RayfieldUI.Elements.SmartTiming = tab:CreateToggle({
        Name = "⏱️ Smart Timing",
        CurrentValue = false,
        Callback = function(Value)
            if EnhancedFishing then
                EnhancedFishing.toggleFeature("smartTiming")
                print("⏱️ Smart Timing: " .. (Value and "Enabled" or "Disabled"))
            end
        end
    })
    
    -- Auto Equip Best Gear
    RayfieldUI.Elements.AutoEquipGear = tab:CreateToggle({
        Name = "🎣 Auto Equip Best Gear",
        CurrentValue = true,
        Callback = function(Value)
            if EnhancedFishing then
                EnhancedFishing.toggleFeature("autoEquipBest")
                print("🎣 Auto Equip: " .. (Value and "Enabled" or "Disabled"))
            end
        end
    })
    
    -- Auto Sell Management
    RayfieldUI.Elements.AutoSellManagement = tab:CreateToggle({
        Name = "💰 Smart Auto Sell",
        CurrentValue = false,
        Callback = function(Value)
            if EnhancedFishing then
                EnhancedFishing.toggleFeature("autoSellManagement")
                print("💰 Smart Auto Sell: " .. (Value and "Enabled" or "Disabled"))
            end
        end
    })
    
    -- Separator
    tab:CreateLabel({
        Text = "📊 Enhanced Statistics"
    })
    
    -- Statistics Display
    RayfieldUI.Elements.EnhancedStats = tab:CreateLabel({
        Text = "🎣 Fish Caught: 0 | ⏱️ Session: 0s | 📈 Fish/Hour: 0"
    })
    
    -- Update Statistics
    spawn(function()
        while RayfieldUI.autoUpdateEnabled do
            wait(2)
            pcall(function()
                if EnhancedFishing and RayfieldUI.Elements.EnhancedStats then
                    local stats = EnhancedFishing.getStats()
                    local text = string.format(
                        "🎣 Fish Caught: %d | ⏱️ Session: %ds | 📈 Fish/Hour: %d | 💰 Value: %d",
                        stats.fishCaught,
                        stats.sessionTime, 
                        stats.fishPerHour,
                        stats.totalValue
                    )
                    RayfieldUI.Elements.EnhancedStats:Set({Text = text})
                end
            end)
        end
    end)
    
    -- Manual Actions Section
    tab:CreateLabel({
        Text = "🔧 Manual Actions"
    })
    
    -- Manual Gear Optimization
    tab:CreateButton({
        Name = "🔄 Optimize Gear Now",
        Callback = function()
            if EnhancedFishing then
                EnhancedFishing.autoEquipBestGear()
                print("🔄 Gear optimization executed")
            end
        end
    })
    
    -- Manual Position Optimization
    tab:CreateButton({
        Name = "📍 Optimize Position",
        Callback = function()
            if EnhancedFishing then
                EnhancedFishing.optimizePosition()
                print("📍 Position optimization executed")
            end
        end
    })
    
    -- Manual Speed Optimization
    tab:CreateButton({
        Name = "⚡ Optimize Speed",
        Callback = function()
            if EnhancedFishing then
                EnhancedFishing.optimizeFishingSpeed()
                print("⚡ Speed optimization executed")
            end
        end
    })
    
    -- Risk Warning
    tab:CreateLabel({
        Text = "⚠️ Safety Notice"
    })
    
    tab:CreateLabel({
        Text = "This uses game's official systems for maximum safety"
    })
    
    tab:CreateLabel({
        Text = "All features designed to appear natural"
    })
end

function RayfieldUI.destroyFloatingButton()
    if RayfieldUI.FloatingButton then
        RayfieldUI.FloatingButton:Destroy()
        RayfieldUI.FloatingButton = nil
        print("🎯 Floating Button: Destroyed")
    end
end

return RayfieldUI
