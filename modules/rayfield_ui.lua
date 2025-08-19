-- modules/rayfield_ui.lua
-- Rayfield UI Interface Module for AutoFish System

local RayfieldUI = {}

-- Use globally loaded Rayfield Library or load it if not available
local function getRayfieldLib()
    print("🔍 Checking for Rayfield Library...")
    
    if getgenv().RayfieldLib then
        print("✅ Using globally loaded Rayfield Library")
        return getgenv().RayfieldLib
    else
        print("📚 Loading Rayfield Library for UI module...")
        local success, RayfieldLib = pcall(function()
            local url = "https://raw.githubusercontent.com/MELLISAEFFENDY/fullversion/main/rayfield_lib.lua"
            print("📡 Downloading from:", url)
            local code = game:HttpGet(url)
            if code and code ~= "" then
                print("✅ Code downloaded, length:", #code)
                local func = loadstring(code)
                if func then
                    print("✅ Code compiled, executing...")
                    return func()
                else
                    print("❌ Failed to compile Rayfield Library code")
                end
            else
                print("❌ Failed to download Rayfield Library or empty response")
            end
        end)
        
        if success and RayfieldLib then
            print("✅ Rayfield Library loaded successfully")
            getgenv().RayfieldLib = RayfieldLib
            return RayfieldLib
        else
            print("❌ Failed to load Rayfield Library:", tostring(RayfieldLib))
            return nil
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
function RayfieldUI.initialize(modules)
    print("📱 RayfieldUI: Initializing...")
    return RayfieldUI.init(modules)
end

function RayfieldUI.init(modules)
    if not modules then
        error("❌ No modules provided to Rayfield UI")
    end
    
    RayfieldUI.modules = modules
    
    -- Initialize Fish Tracker if available
    if modules.fish_tracker then
        print("🐟 Initializing Fish Tracker...")
        if modules.fish_tracker.initialize then
            modules.fish_tracker.initialize()
        else
            print("⚠️ Fish Tracker has no initialize method")
        end
        
        -- Set up callback for UI updates
        if modules.fish_tracker.setUpdateCallback then
            modules.fish_tracker.setUpdateCallback(function(stats)
                if RayfieldUI.updateFishStats then
                    RayfieldUI.updateFishStats(stats)
                end
            end)
        end
    end
    
    -- Get Rayfield Library
    local RayfieldLib = getRayfieldLib()
    if not RayfieldLib then
        error("❌ Rayfield Library not available")
    end
    
    if not RayfieldLib.CreateWindow then
        error("❌ Rayfield Library missing CreateWindow function")
    end
    
    print("🎨 Creating Rayfield UI Window...")
    print("📋 Window config:", config.Name)
    
    -- Create main window
    local success, window = pcall(function()
        print("📱 Calling RayfieldLib:CreateWindow...")
        local w = RayfieldLib:CreateWindow(config)
        print("📱 Window created:", w and "✅" or "❌")
        return w
    end)
    
    if not success then
        print("❌ Error creating window:", tostring(window))
        error("❌ Failed to create Rayfield window: " .. tostring(window))
    elseif not window then
        print("❌ Window is nil")
        error("❌ Rayfield window is nil")
    end
    
    RayfieldUI.Window = window
    print("✅ Rayfield UI Window created and stored successfully")
    
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
    print("🔧 Creating all tabs...")
    
    -- AutoFish Tab
    pcall(function()
        print("📝 Creating AutoFish tab...")
        RayfieldUI.Tabs.AutoFish = RayfieldUI.Window:CreateTab({Name = "🎣 AutoFish"})
        RayfieldUI.createAutoFishTab()
        print("✅ AutoFish tab created")
    end)
    
    -- Enhanced Fishing Tab
    pcall(function()
        print("📝 Creating Enhanced Fishing tab...")
        RayfieldUI.Tabs.EnhancedFishing = RayfieldUI.Window:CreateTab({Name = "⚡ Enhanced Fishing"})
        RayfieldUI.createEnhancedFishingTab()
        print("✅ Enhanced Fishing tab created")
    end)
    
    -- Enhanced RISK Tab
    pcall(function()
        print("📝 Creating Enhanced RISK tab...")
        RayfieldUI.Tabs.EnhancedRisk = RayfieldUI.Window:CreateTab({Name = "⚠️ Enhanced RISK"})
        RayfieldUI.createEnhancedRiskTab()
        print("✅ Enhanced RISK tab created")
    end)
    
    -- Movement Tab
    pcall(function()
        print("📝 Creating Movement tab...")
        RayfieldUI.Tabs.Movement = RayfieldUI.Window:CreateTab({Name = "🚶 Movement"})
        RayfieldUI.createMovementTab()
        print("✅ Movement tab created")
    end)
    
    -- AutoSell Tab
    pcall(function()
        print("📝 Creating AutoSell tab...")
        RayfieldUI.Tabs.AutoSell = RayfieldUI.Window:CreateTab({Name = "💰 AutoSell"})
        RayfieldUI.createAutoSellTab()
        print("✅ AutoSell tab created")
    end)
    
    -- Security Tab
    pcall(function()
        print("📝 Creating Security tab...")
        RayfieldUI.Tabs.Security = RayfieldUI.Window:CreateTab({Name = "🛡️ Security"})
        RayfieldUI.createSecurityTab()
        print("✅ Security tab created")
    end)
    
    -- Settings Tab
    pcall(function()
        print("📝 Creating Settings tab...")
        RayfieldUI.Tabs.Settings = RayfieldUI.Window:CreateTab({Name = "⚙️ Settings"})
        RayfieldUI.createSettingsTab()
        print("✅ Settings tab created")
    end)
    
    -- Dashboard Tab
    pcall(function()
        print("📝 Creating Dashboard tab...")
        RayfieldUI.Tabs.Dashboard = RayfieldUI.Window:CreateTab({Name = "📊 Dashboard"})
        RayfieldUI.createDashboardTab()
        print("✅ Dashboard tab created")
    end)
    
    print("✅ All tabs creation completed!")
end

-- AutoFish Tab
function RayfieldUI.createAutoFishTab()
    local tab = RayfieldUI.Tabs.AutoFish
    local autofish = RayfieldUI.modules.autofish
    
    if not tab then
        print("❌ AutoFish tab not created")
        return
    end
    
    if not autofish then
        print("❌ AutoFish module not available")
        tab:CreateButton({
            Name = "AutoFish Module Not Available",
            Callback = function() end
        })
        return
    end
    
    print("✅ AutoFish tab and module available, creating controls...")
    
    -- Info section
    pcall(function()
        tab:CreateLabel({
            Text = "AutoFish Configuration"
        })
    end)
    
    -- AutoFish Toggle
    pcall(function()
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
        print("✅ AutoFish toggle created")
    end)
    
    -- Cast Power Slider
    pcall(function()
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
        print("✅ Cast power slider created")
    end)
    
    -- Auto Cast Toggle
    pcall(function()
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
        print("✅ Auto cast toggle created")
    end)
    
    -- Fish Detection Toggle
    pcall(function()
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
        print("✅ Fish detection toggle created")
    end)
    
    -- AutoFish Mode Selection (using buttons instead of dropdown)
    pcall(function()
        tab:CreateLabel({
            Text = "AutoFish Mode Selection:"
        })
        
        RayfieldUI.Elements.SmartModeButton = tab:CreateButton({
            Name = "Smart Mode (Current)",
            Callback = function()
                if autofish.setMode then
                    autofish.setMode("smart")
                    print("AutoFish mode changed to: Smart")
                end
            end
        })
        
        RayfieldUI.Elements.SecureModeButton = tab:CreateButton({
            Name = "Secure Mode",
            Callback = function()
                if autofish.setMode then
                    autofish.setMode("secure")
                    print("AutoFish mode changed to: Secure")
                end
            end
        })
        print("✅ Mode selection buttons created")
    end)
    
    -- Mode Info Labels
    pcall(function()
        tab:CreateLabel({
            Text = "• Smart: High efficiency, medium safety"
        })
        
        tab:CreateLabel({
            Text = "• Secure: Lower efficiency, high safety"
        })
        print("✅ Mode info labels created")
    end)
    
    -- Recast Delay Slider
    pcall(function()
        RayfieldUI.Elements.RecastDelaySlider = tab:CreateSlider({
            Name = "Recast Delay (seconds)",
            Range = {0.1, 3.0},
            Increment = 0.1,
            CurrentValue = 0.4,
            Flag = "RecastDelay",
            Callback = function(value)
                if autofish.setCastDelay then
                    autofish.setCastDelay(value)
                    print("Recast delay set to: " .. value .. "s")
                end
            end
        })
        print("✅ Recast delay slider created")
    end)
    
    -- Perfect Catch Toggle
    pcall(function()
        RayfieldUI.Elements.PerfectCatchToggle = tab:CreateToggle({
            Name = "Perfect Catch Mode",
            CurrentValue = false,
            Flag = "PerfectCatch",
            Callback = function(value)
                if autofish.setPerfectCatch then
                    autofish.setPerfectCatch(value)
                end
            end
        })
        print("✅ Perfect catch toggle created")
    end)
    
    -- Safe Mode Chance Slider
    pcall(function()
        RayfieldUI.Elements.SafeModeChanceSlider = tab:CreateSlider({
            Name = "Perfect Catch Rate (%)",
            Range = {0, 100},
            Increment = 5,
            CurrentValue = 70,
            Flag = "SafeModeChance",
            Callback = function(value)
                if autofish.config then
                    autofish.config.safeModeChance = value
                    print("Perfect catch rate set to: " .. value .. "%")
                end
            end
        })
        print("✅ Perfect catch rate slider created")
    end)
    
    -- Auto Recast Toggle
    pcall(function()
        RayfieldUI.Elements.AutoRecastToggle = tab:CreateToggle({
            Name = "Auto Recast",
            CurrentValue = true,
            Flag = "AutoRecast",
            Callback = function(value)
                if autofish.setAutoRecast then
                    autofish.setAutoRecast(value)
                end
            end
        })
        print("✅ Auto recast toggle created")
    end)
    
    print("✅ AutoFish tab completed successfully!")
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
    
    -- Helper text for floating button
    tab:CreateLabel({
        Text = "Left Click: Toggle UI | Right Click: Toggle AutoFish"
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

-- Update fish statistics from Fish Tracker
function RayfieldUI.updateFishStats(stats)
    if not stats then return end
    
    pcall(function()
        -- Update fish caught display
        if RayfieldUI.Elements.FishCaughtLabel and stats.totalFish then
            RayfieldUI.Elements.FishCaughtLabel.Name = "🐟 Fish Caught: " .. tostring(stats.totalFish)
        end
        
        -- Update revenue display
        if RayfieldUI.Elements.RevenueLabel and stats.totalValue then
            RayfieldUI.Elements.RevenueLabel.Name = "💰 Total Revenue: $" .. tostring(stats.totalValue)
        end
        
        -- Update runtime display
        if RayfieldUI.Elements.RuntimeLabel and stats.sessionTime then
            local hours = math.floor(stats.sessionTime / 3600)
            local minutes = math.floor((stats.sessionTime % 3600) / 60)
            local seconds = math.floor(stats.sessionTime % 60)
            local timeStr = string.format("%02d:%02d:%02d", hours, minutes, seconds)
            RayfieldUI.Elements.RuntimeLabel.Name = "⏱️ Runtime: " .. timeStr
        end
        
        -- Update status based on activity
        if RayfieldUI.Elements.StatusLabel then
            local status = "Idle"
            if RayfieldUI.modules.autofish and RayfieldUI.modules.autofish.isRunning and RayfieldUI.modules.autofish.isRunning() then
                status = "Fishing Active"
            elseif stats.lastCatch and (tick() - stats.lastCatch) < 30 then
                status = "Recently Active"
            end
            RayfieldUI.Elements.StatusLabel.Name = "📊 Status: " .. status
        end
        
        print("🔄 Dashboard updated with fish stats: " .. tostring(stats.totalFish) .. " fish caught")
    end)
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
        
        -- Click to toggle UI visibility (left click)
        FloatingButton.MouseButton1Click:Connect(function()
            if not dragging then
                if RayfieldUI.Window and RayfieldUI.Window.MainFrame then
                    local currentVisibility = RayfieldUI.Window.MainFrame.Visible
                    
                    if currentVisibility then
                        -- Minimize UI
                        if RayfieldUI.Window.Minimize then
                            RayfieldUI.Window:Minimize()
                        else
                            RayfieldUI.Window.MainFrame.Visible = false
                        end
                        print("� UI minimized to floating button")
                        FloatingButton.Text = "📱"
                    else
                        -- Show UI
                        if RayfieldUI.Window.Show then
                            RayfieldUI.Window:Show()
                        else
                            RayfieldUI.Window.MainFrame.Visible = true
                        end
                        print("🔸 UI shown from floating button")
                        FloatingButton.Text = "🎣"
                    end
                else
                    print("❌ Window not available for toggle")
                end
            end
        end)
        
        -- Right click to toggle AutoFish
        FloatingButton.MouseButton2Click:Connect(function()
            if not dragging then
                if RayfieldUI.modules and RayfieldUI.modules.autofish then
                    local isRunning = RayfieldUI.modules.autofish.isRunning and RayfieldUI.modules.autofish.isRunning() or false
                    
                    if isRunning then
                        if RayfieldUI.modules.autofish.stop then
                            RayfieldUI.modules.autofish.stop()
                            print("🛑 AutoFish stopped via floating button")
                        end
                    else
                        if RayfieldUI.modules.autofish.start then
                            RayfieldUI.modules.autofish.start()
                            print("🎣 AutoFish started via floating button")
                        end
                    end
                    
                    -- Update UI toggle if available
                    if RayfieldUI.Elements.AutoFishToggle then
                        RayfieldUI.Elements.AutoFishToggle:Set(not isRunning)
                    end
                    
                    -- Update button appearance based on autofish state
                    RayfieldUI.updateFloatingButtonAppearance()
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
        
        RayfieldUI.FloatingButton = {
            ScreenGui = ScreenGui,
            Button = FloatingButton
        }
        
        print("🎯 Floating Button: Created with UI toggle (Left Click) and AutoFish toggle (Right Click)")
    end)
end

-- Update Floating Button Appearance
function RayfieldUI.updateFloatingButtonAppearance()
    if RayfieldUI.FloatingButton and RayfieldUI.FloatingButton.Button then
        local button = RayfieldUI.FloatingButton.Button
        
        -- Check AutoFish status
        local isAutoFishRunning = false
        if RayfieldUI.modules and RayfieldUI.modules.autofish then
            isAutoFishRunning = RayfieldUI.modules.autofish.isRunning and RayfieldUI.modules.autofish.isRunning() or false
        end
        
        -- Check UI visibility
        local isUIVisible = true
        if RayfieldUI.Window and RayfieldUI.Window.MainFrame then
            isUIVisible = RayfieldUI.Window.MainFrame.Visible
        end
        
        -- Update button appearance based on states
        if isAutoFishRunning then
            button.BackgroundColor3 = Color3.fromRGB(80, 200, 120) -- Green for active
            button.Text = isUIVisible and "🟢" or "🟢"
        else
            button.BackgroundColor3 = Color3.fromRGB(120, 80, 200) -- Purple for inactive
            button.Text = isUIVisible and "🎣" or "📱"
        end
    end
end

-- Enhanced UI Toggle Function with Multiple Fallbacks
function RayfieldUI.toggleUIVisibility()
    print("🔸 Attempting to toggle UI visibility...")
    local toggleSuccess = false
    
    -- Method 1: Direct Window access
    if RayfieldUI.Window then
        print("🔍 Method 1: Direct Window access")
        
        -- Try to determine current state
        local isVisible = true
        if RayfieldUI.Window.MainFrame and RayfieldUI.Window.MainFrame.Visible ~= nil then
            isVisible = RayfieldUI.Window.MainFrame.Visible
            print("🔍 Current MainFrame visibility:", isVisible)
        end
        
        if isVisible then
            -- Try to minimize
            if RayfieldUI.Window.Minimize then
                print("🔸 Using Window:Minimize()")
                RayfieldUI.Window:Minimize()
                toggleSuccess = true
            elseif RayfieldUI.Window.MainFrame then
                print("🔸 Setting MainFrame.Visible = false")
                RayfieldUI.Window.MainFrame.Visible = false
                toggleSuccess = true
            end
        else
            -- Try to show
            if RayfieldUI.Window.Show then
                print("🔸 Using Window:Show()")
                RayfieldUI.Window:Show()
                toggleSuccess = true
            elseif RayfieldUI.Window.MainFrame then
                print("🔸 Setting MainFrame.Visible = true")
                RayfieldUI.Window.MainFrame.Visible = true
                toggleSuccess = true
            end
        end
    end
    
    -- Method 2: getgenv API access
    if not toggleSuccess then
        print("🔍 Method 2: getgenv API access")
        if getgenv().AutoFishPro then
            -- Check current floating button state to determine action
            local shouldShow = true
            if RayfieldUI.FloatingButton and RayfieldUI.FloatingButton.Button then
                shouldShow = RayfieldUI.FloatingButton.Button.Text == "📱"
            end
            
            if shouldShow and getgenv().AutoFishPro.showUI then
                getgenv().AutoFishPro.showUI()
                toggleSuccess = true
            elseif not shouldShow and getgenv().AutoFishPro.hideUI then
                getgenv().AutoFishPro.hideUI()
                toggleSuccess = true
            end
        end
    end
    
    print("🔸 Toggle result:", toggleSuccess and "Success" or "Failed")
    return toggleSuccess
end

-- Enhanced Fishing Tab (Simplified)
function RayfieldUI.createEnhancedFishingTab()
    local tab = RayfieldUI.Tabs.EnhancedFishing
    if not tab then 
        print("❌ Enhanced Fishing Tab not found")
        return 
    end
    
    print("🔧 Creating Enhanced Fishing Tab content...")
    
    -- Header
    tab:CreateLabel({
        Text = "⚡ Enhanced Fishing System"
    })
    
    tab:CreateLabel({
        Text = "Advanced fishing features using safe methods"
    })
    
    -- Separator
    tab:CreateLabel({
        Text = "🎣 Fishing Enhancements"
    })
    
    -- Enhanced AutoFish Toggle
    RayfieldUI.Elements.EnhancedAutoFish = tab:CreateToggle({
        Name = "🚀 Enhanced AutoFish",
        CurrentValue = false,
        Callback = function(Value)
            print("🚀 Enhanced AutoFish: " .. (Value and "Enabled" or "Disabled"))
            -- TODO: Implement enhanced autofishing logic
        end
    })
    
    -- Smart Timing Toggle
    RayfieldUI.Elements.SmartTiming = tab:CreateToggle({
        Name = "⏱️ Smart Timing",
        CurrentValue = false,
        Callback = function(Value)
            print("⏱️ Smart Timing: " .. (Value and "Enabled" or "Disabled"))
            -- TODO: Implement timing optimization
        end
    })
    
    -- Auto Equip Best Gear
    RayfieldUI.Elements.AutoEquipGear = tab:CreateToggle({
        Name = "🎣 Auto Equip Best Gear",
        CurrentValue = false,
        Callback = function(Value)
            print("🎣 Auto Equip Best Gear: " .. (Value and "Enabled" or "Disabled"))
            -- TODO: Implement auto equipment
        end
    })
    
    -- Perfect Cast Toggle
    RayfieldUI.Elements.PerfectCast = tab:CreateToggle({
        Name = "🎯 Perfect Cast",
        CurrentValue = false,
        Callback = function(Value)
            print("🎯 Perfect Cast: " .. (Value and "Enabled" or "Disabled"))
            -- TODO: Implement perfect casting
        end
    })
    
    -- Fishing Speed Boost
    RayfieldUI.Elements.FishingSpeedBoost = tab:CreateSlider({
        Name = "⚡ Fishing Speed Multiplier",
        Range = {1, 5},
        Increment = 0.1,
        CurrentValue = 1,
        Callback = function(Value)
            print("⚡ Fishing Speed set to: " .. Value .. "x")
            -- TODO: Implement speed boost
        end
    })
    
    -- Luck Multiplier
    RayfieldUI.Elements.LuckMultiplier = tab:CreateSlider({
        Name = "🍀 Luck Multiplier",
        Range = {1, 10},
        Increment = 0.5,
        CurrentValue = 1,
        Callback = function(Value)
            print("🍀 Luck Multiplier set to: " .. Value .. "x")
            -- TODO: Implement luck boost
        end
    })
    
    -- Separator
    tab:CreateLabel({
        Text = "💰 Auto Management"
    })
    
    -- Auto Sell Management
    RayfieldUI.Elements.AutoSellManagement = tab:CreateToggle({
        Name = "💰 Smart Auto Sell",
        CurrentValue = false,
        Callback = function(Value)
            print("💰 Smart Auto Sell: " .. (Value and "Enabled" or "Disabled"))
            -- TODO: Implement smart selling
        end
    })
    
    -- Auto Buy Bait
    RayfieldUI.Elements.AutoBuyBait = tab:CreateToggle({
        Name = "🪱 Auto Buy Bait",
        CurrentValue = false,
        Callback = function(Value)
            print("🪱 Auto Buy Bait: " .. (Value and "Enabled" or "Disabled"))
            -- TODO: Implement auto bait buying
        end
    })
    
    -- Auto Upgrade Rod
    RayfieldUI.Elements.AutoUpgradeRod = tab:CreateToggle({
        Name = "🎣 Auto Upgrade Rod",
        CurrentValue = false,
        Callback = function(Value)
            print("🎣 Auto Upgrade Rod: " .. (Value and "Enabled" or "Disabled"))
            -- TODO: Implement auto rod upgrading
        end
    })
    
    -- Separator
    tab:CreateLabel({
        Text = "📊 Statistics & Actions"
    })
    
    -- Statistics Display
    RayfieldUI.Elements.EnhancedStats = tab:CreateLabel({
        Text = "🎣 Fish Caught: 0 | ⏱️ Session: 0s | 📈 Rate: 0/h | 💰 Value: 0"
    })
    
    -- Manual Actions
    tab:CreateButton({
        Name = "🔄 Optimize Everything",
        Callback = function()
            print("🔄 Running full optimization...")
            -- TODO: Run all optimizations
        end
    })
    
    tab:CreateButton({
        Name = "📍 Find Best Fishing Spot",
        Callback = function()
            print("📍 Finding best fishing location...")
            -- TODO: Implement location finder
        end
    })
    
    tab:CreateButton({
        Name = "💎 Collect All Valuables",
        Callback = function()
            print("💎 Collecting all valuable items...")
            -- TODO: Implement valuable collection
        end
    })
    
    -- Safety Section
    tab:CreateLabel({
        Text = "🛡️ Safety & Detection"
    })
    
    -- Anti-Detection Mode
    RayfieldUI.Elements.AntiDetection = tab:CreateToggle({
        Name = "🛡️ Anti-Detection Mode",
        CurrentValue = true,
        Callback = function(Value)
            print("🛡️ Anti-Detection: " .. (Value and "Enabled" or "Disabled"))
            -- TODO: Implement anti-detection measures
        end
    })
    
    -- Human-like Behavior
    RayfieldUI.Elements.HumanBehavior = tab:CreateToggle({
        Name = "🧑 Human-like Behavior",
        CurrentValue = true,
        Callback = function(Value)
            print("🧑 Human-like Behavior: " .. (Value and "Enabled" or "Disabled"))
            -- TODO: Implement human simulation
        end
    })
    
    -- Detection Risk Level
    RayfieldUI.Elements.RiskLevel = tab:CreateLabel({
        Text = "🔍 Detection Risk: LOW ✅"
    })
    
    -- Update Statistics Loop (simplified)
    spawn(function()
        local sessionStart = tick()
        local fishCount = 0
        
        while RayfieldUI.autoUpdateEnabled do
            wait(2)
            pcall(function()
                if RayfieldUI.Elements.EnhancedStats then
                    local sessionTime = math.floor(tick() - sessionStart)
                    local fishPerHour = math.floor(fishCount / (sessionTime / 3600))
                    local totalValue = fishCount * 100 -- Placeholder calculation
                    
                    local text = string.format(
                        "🎣 Fish: %d | ⏱️ Time: %ds | � Rate: %d/h | 💰 Value: %d",
                        fishCount,
                        sessionTime,
                        fishPerHour,
                        totalValue
                    )
                    RayfieldUI.Elements.EnhancedStats:Set({Text = text})
                end
                
                -- Update risk level based on active features
                if RayfieldUI.Elements.RiskLevel then
                    local riskText = "🔍 Detection Risk: LOW ✅"
                    if RayfieldUI.Elements.LuckMultiplier and RayfieldUI.Elements.LuckMultiplier.CurrentValue > 5 then
                        riskText = "🔍 Detection Risk: HIGH ⚠️"
                    elseif RayfieldUI.Elements.FishingSpeedBoost and RayfieldUI.Elements.FishingSpeedBoost.CurrentValue > 3 then
                        riskText = "🔍 Detection Risk: MEDIUM ⚠️"
                    end
                    RayfieldUI.Elements.RiskLevel:Set({Text = riskText})
                end
            end)
        end
    end)
    
    print("✅ Enhanced Fishing Tab created successfully!")
end

-- Enhanced RISK Tab (High Risk Exploits)
function RayfieldUI.createEnhancedRiskTab()
    local tab = RayfieldUI.Tabs.EnhancedRisk
    if not tab then 
        print("❌ Enhanced RISK Tab not found")
        return 
    end
    
    print("🔧 Creating Enhanced RISK Tab content...")
    
    -- WARNING HEADER
    tab:CreateLabel({
        Text = "⚠️ WARNING: HIGH RISK EXPLOITS"
    })
    
    tab:CreateLabel({
        Text = "🚨 These features have HIGH DETECTION RISK!"
    })
    
    tab:CreateLabel({
        Text = "💀 Use at your own risk - may result in ban!"
    })
    
    tab:CreateLabel({
        Text = "🛡️ Enable Anti-Detection features before using"
    })
    
    -- Separator
    tab:CreateLabel({
        Text = "🎯 Minigame Exploits (VERY HIGH RISK)"
    })
    
    -- Minigame Bypass
    RayfieldUI.Elements.MinigameBypass = tab:CreateToggle({
        Name = "🚫 Minigame Bypass",
        CurrentValue = false,
        Callback = function(Value)
            print("🚫 Minigame Bypass: " .. (Value and "ENABLED - VERY HIGH RISK!" or "Disabled"))
            if Value then
                print("⚠️ WARNING: Bypassing minigames is highly detectable!")
            end
            -- TODO: Implement minigame bypass
        end
    })
    
    -- Perfect Minigame Timing
    RayfieldUI.Elements.PerfectTiming = tab:CreateToggle({
        Name = "🎯 Perfect Minigame Timing",
        CurrentValue = false,
        Callback = function(Value)
            print("🎯 Perfect Timing: " .. (Value and "ENABLED - HIGH RISK!" or "Disabled"))
            if Value then
                print("⚠️ WARNING: Always perfect timing is suspicious!")
            end
            -- TODO: Implement perfect timing
        end
    })
    
    -- Auto Minigame Solver
    RayfieldUI.Elements.AutoMinigame = tab:CreateToggle({
        Name = "🤖 Auto Minigame Solver",
        CurrentValue = false,
        Callback = function(Value)
            print("🤖 Auto Minigame: " .. (Value and "ENABLED - VERY HIGH RISK!" or "Disabled"))
            -- TODO: Implement auto solver
        end
    })
    
    -- Separator
    tab:CreateLabel({
        Text = "🔮 Fish Manipulation (VERY HIGH RISK)"
    })
    
    -- Fish Rarity Hack
    RayfieldUI.Elements.RarityHack = tab:CreateToggle({
        Name = "💎 Force Rare Fish",
        CurrentValue = false,
        Callback = function(Value)
            print("💎 Rare Fish Hack: " .. (Value and "ENABLED - EXTREME RISK!" or "Disabled"))
            if Value then
                print("🚨 EXTREME RISK: This will be very obvious to detection systems!")
            end
            -- TODO: Implement rarity manipulation
        end
    })
    
    -- Fish Weight Manipulation
    RayfieldUI.Elements.WeightHack = tab:CreateToggle({
        Name = "⚖️ Force Heavy Fish",
        CurrentValue = false,
        Callback = function(Value)
            print("⚖️ Weight Hack: " .. (Value and "ENABLED - VERY HIGH RISK!" or "Disabled"))
            -- TODO: Implement weight manipulation
        end
    })
    
    -- Fish Value Multiplier
    RayfieldUI.Elements.ValueMultiplier = tab:CreateSlider({
        Name = "💰 Fish Value Multiplier",
        Range = {1, 100},
        Increment = 1,
        CurrentValue = 1,
        Callback = function(Value)
            print("💰 Value Multiplier set to: " .. Value .. "x")
            if Value > 10 then
                print("🚨 WARNING: High multipliers are extremely risky!")
            end
            -- TODO: Implement value multiplication
        end
    })
    
    -- Separator
    tab:CreateLabel({
        Text = "🎣 Rod & Equipment Hacks (HIGH RISK)"
    })
    
    -- Rod Stats Injection
    RayfieldUI.Elements.RodStatsHack = tab:CreateToggle({
        Name = "📊 Inject Impossible Rod Stats",
        CurrentValue = false,
        Callback = function(Value)
            print("📊 Rod Stats Hack: " .. (Value and "ENABLED - VERY HIGH RISK!" or "Disabled"))
            -- TODO: Implement rod stats injection
        end
    })
    
    -- Infinite Bait
    RayfieldUI.Elements.InfiniteBait = tab:CreateToggle({
        Name = "🪱 Infinite Bait",
        CurrentValue = false,
        Callback = function(Value)
            print("🪱 Infinite Bait: " .. (Value and "ENABLED - HIGH RISK!" or "Disabled"))
            -- TODO: Implement infinite bait
        end
    })
    
    -- Rod Durability Hack
    RayfieldUI.Elements.InfiniteDurability = tab:CreateToggle({
        Name = "🛡️ Infinite Rod Durability",
        CurrentValue = false,
        Callback = function(Value)
            print("🛡️ Infinite Durability: " .. (Value and "ENABLED - MEDIUM RISK" or "Disabled"))
            -- TODO: Implement durability hack
        end
    })
    
    -- Separator
    tab:CreateLabel({
        Text = "⚡ Speed & Performance Hacks (MEDIUM-HIGH RISK)"
    })
    
    -- Extreme Speed Boost
    RayfieldUI.Elements.ExtremeSpeed = tab:CreateSlider({
        Name = "🚀 Extreme Fishing Speed",
        Range = {1, 50},
        Increment = 1,
        CurrentValue = 1,
        Callback = function(Value)
            print("🚀 Extreme Speed set to: " .. Value .. "x")
            if Value > 10 then
                print("⚠️ WARNING: Extreme speeds are highly detectable!")
            end
            -- TODO: Implement extreme speed
        end
    })
    
    -- Cast Distance Hack
    RayfieldUI.Elements.InfiniteCast = tab:CreateToggle({
        Name = "🎯 Infinite Cast Distance",
        CurrentValue = false,
        Callback = function(Value)
            print("🎯 Infinite Cast: " .. (Value and "ENABLED - HIGH RISK!" or "Disabled"))
            -- TODO: Implement infinite casting
        end
    })
    
    -- No Cooldown Hack
    RayfieldUI.Elements.NoCooldown = tab:CreateToggle({
        Name = "⏱️ Remove All Cooldowns",
        CurrentValue = false,
        Callback = function(Value)
            print("⏱️ No Cooldowns: " .. (Value and "ENABLED - VERY HIGH RISK!" or "Disabled"))
            -- TODO: Implement cooldown removal
        end
    })
    
    -- Separator
    tab:CreateLabel({
        Text = "💰 Economy Exploits (EXTREME RISK)"
    })
    
    -- Money Hack
    RayfieldUI.Elements.MoneyHack = tab:CreateButton({
        Name = "💸 Add Money (EXTREME RISK)",
        Callback = function()
            print("💸 Money Hack executed - EXTREME RISK!")
            print("🚨 This is the most detectable exploit!")
            -- TODO: Implement money hack (NOT RECOMMENDED)
        end
    })
    
    -- Item Duplication
    RayfieldUI.Elements.ItemDupe = tab:CreateButton({
        Name = "📦 Duplicate Items (EXTREME RISK)",
        Callback = function()
            print("📦 Item Duplication - EXTREME RISK!")
            -- TODO: Implement item duplication
        end
    })
    
    -- Unlock All Items
    RayfieldUI.Elements.UnlockAll = tab:CreateButton({
        Name = "🔓 Unlock All Items (HIGH RISK)",
        Callback = function()
            print("🔓 Unlock All Items - HIGH RISK!")
            -- TODO: Implement unlock all
        end
    })
    
    -- Separator
    tab:CreateLabel({
        Text = "🛡️ Protection & Monitoring"
    })
    
    -- Auto Disable on Detection
    RayfieldUI.Elements.AutoDisable = tab:CreateToggle({
        Name = "🛡️ Auto Disable on Detection Risk",
        CurrentValue = true,
        Callback = function(Value)
            print("🛡️ Auto Protection: " .. (Value and "Enabled" or "Disabled"))
            -- TODO: Implement auto protection
        end
    })
    
    -- Risk Monitor
    RayfieldUI.Elements.RiskMonitor = tab:CreateLabel({
        Text = "🔍 Current Risk Level: EXTREME ⛔"
    })
    
    -- Detection Alerts
    RayfieldUI.Elements.DetectionAlerts = tab:CreateToggle({
        Name = "🚨 Detection Risk Alerts",
        CurrentValue = true,
        Callback = function(Value)
            print("🚨 Detection Alerts: " .. (Value and "Enabled" or "Disabled"))
        end
    })
    
    -- Manual Risk Actions
    tab:CreateLabel({
        Text = "🔧 Emergency Actions"
    })
    
    -- Disable All Risk Features
    tab:CreateButton({
        Name = "🛑 DISABLE ALL RISK FEATURES",
        Callback = function()
            print("🛑 Disabling all risky features...")
            -- Disable all toggles
            if RayfieldUI.Elements.MinigameBypass then RayfieldUI.Elements.MinigameBypass:Set(false) end
            if RayfieldUI.Elements.PerfectTiming then RayfieldUI.Elements.PerfectTiming:Set(false) end
            if RayfieldUI.Elements.AutoMinigame then RayfieldUI.Elements.AutoMinigame:Set(false) end
            if RayfieldUI.Elements.RarityHack then RayfieldUI.Elements.RarityHack:Set(false) end
            if RayfieldUI.Elements.WeightHack then RayfieldUI.Elements.WeightHack:Set(false) end
            if RayfieldUI.Elements.RodStatsHack then RayfieldUI.Elements.RodStatsHack:Set(false) end
            if RayfieldUI.Elements.InfiniteBait then RayfieldUI.Elements.InfiniteBait:Set(false) end
            if RayfieldUI.Elements.InfiniteDurability then RayfieldUI.Elements.InfiniteDurability:Set(false) end
            if RayfieldUI.Elements.InfiniteCast then RayfieldUI.Elements.InfiniteCast:Set(false) end
            if RayfieldUI.Elements.NoCooldown then RayfieldUI.Elements.NoCooldown:Set(false) end
            print("✅ All risky features disabled!")
        end
    })
    
    -- Reset to Safe Mode
    tab:CreateButton({
        Name = "🔄 Reset to Safe Mode",
        Callback = function()
            print("🔄 Resetting to safe configuration...")
            -- Reset all sliders to safe values
            if RayfieldUI.Elements.ValueMultiplier then RayfieldUI.Elements.ValueMultiplier:Set(1) end
            if RayfieldUI.Elements.ExtremeSpeed then RayfieldUI.Elements.ExtremeSpeed:Set(1) end
            print("✅ Reset to safe mode complete!")
        end
    })
    
    -- Update Risk Level Monitoring
    spawn(function()
        while RayfieldUI.autoUpdateEnabled do
            wait(1)
            pcall(function()
                if RayfieldUI.Elements.RiskMonitor then
                    local riskLevel = "LOW ✅"
                    local riskColor = "🟢"
                    local activeRisks = 0
                    
                    -- Check active risky features
                    if RayfieldUI.Elements.MinigameBypass and RayfieldUI.Elements.MinigameBypass.CurrentValue then
                        activeRisks = activeRisks + 3
                    end
                    if RayfieldUI.Elements.RarityHack and RayfieldUI.Elements.RarityHack.CurrentValue then
                        activeRisks = activeRisks + 5
                    end
                    if RayfieldUI.Elements.ValueMultiplier and RayfieldUI.Elements.ValueMultiplier.CurrentValue > 5 then
                        activeRisks = activeRisks + 2
                    end
                    if RayfieldUI.Elements.ExtremeSpeed and RayfieldUI.Elements.ExtremeSpeed.CurrentValue > 10 then
                        activeRisks = activeRisks + 3
                    end
                    
                    -- Determine risk level
                    if activeRisks >= 8 then
                        riskLevel = "EXTREME ⛔"
                        riskColor = "🔴"
                    elseif activeRisks >= 5 then
                        riskLevel = "VERY HIGH 🚨"
                        riskColor = "🟠"
                    elseif activeRisks >= 3 then
                        riskLevel = "HIGH ⚠️"
                        riskColor = "🟡"
                    elseif activeRisks >= 1 then
                        riskLevel = "MEDIUM ⚠️"
                        riskColor = "🟠"
                    end
                    
                    RayfieldUI.Elements.RiskMonitor:Set({
                        Text = string.format("🔍 Current Risk Level: %s %s (Active Risks: %d)", 
                            riskLevel, riskColor, activeRisks)
                    })
                end
            end)
        end
    end)
    
    -- Final Warning
    tab:CreateLabel({
        Text = "💀 FINAL WARNING: These exploits are EXPERIMENTAL"
    })
    
    tab:CreateLabel({
        Text = "🚫 NOT RECOMMENDED for main accounts"
    })
    
    tab:CreateLabel({
        Text = "📚 For educational/testing purposes only"
    })
    
    print("✅ Enhanced RISK Tab created successfully!")
end

function RayfieldUI.destroyFloatingButton()
    if RayfieldUI.FloatingButton and RayfieldUI.FloatingButton.ScreenGui then
        RayfieldUI.FloatingButton.ScreenGui:Destroy()
        RayfieldUI.FloatingButton = nil
        print("🎯 Floating Button: Destroyed")
    end
end

-- Runtime fixes for floating button functionality
spawn(function()
    wait(2) -- Wait for UI to initialize
    
    -- Fix floating button click handlers if they exist
    if RayfieldUI.FloatingButton and RayfieldUI.FloatingButton.Button then
        local button = RayfieldUI.FloatingButton.Button
        print("🔧 Applying floating button fixes...")
        
        -- Override MouseButton1Click with improved logic
        button.MouseButton1Click:Connect(function()
            print("🔸 Enhanced floating button clicked")
            
            -- Simple toggle logic with multiple fallbacks
            local toggleSuccess = false
            
            if RayfieldUI.Window then
                if RayfieldUI.Window.MainFrame then
                    local isVisible = RayfieldUI.Window.MainFrame.Visible
                    RayfieldUI.Window.MainFrame.Visible = not isVisible
                    toggleSuccess = true
                    print("🔸 Toggled MainFrame visibility to:", not isVisible)
                    button.Text = isVisible and "📱" or "🎣"
                end
            end
            
            if not toggleSuccess then
                print("🔄 Trying alternative methods...")
                -- Try getgenv access
                if getgenv().AutoFishPro then
                    if button.Text == "📱" then
                        if getgenv().AutoFishPro.showUI then
                            getgenv().AutoFishPro.showUI()
                            button.Text = "🎣"
                        end
                    else
                        if getgenv().AutoFishPro.hideUI then
                            getgenv().AutoFishPro.hideUI()
                            button.Text = "📱"
                        end
                    end
                end
            end
        end)
    end
end)

return RayfieldUI
