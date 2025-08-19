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
    
    return RayfieldUI
end

-- Create UI tabs
function RayfieldUI.createTabs()
    -- AutoFish Tab
    RayfieldUI.Tabs.AutoFish = RayfieldUI.Window:CreateTab({Name = "🎣 AutoFish"})
    RayfieldUI.createAutoFishTab()
    
    -- Movement Tab
    RayfieldUI.Tabs.Movement = RayfieldUI.Window:CreateTab({Name = "🚶 Movement"})
    RayfieldUI.createMovementTab()
    
    -- AutoSell Tab
    RayfieldUI.Tabs.AutoSell = RayfieldUI.Window:CreateTab({Name = "💰 AutoSell"})
    RayfieldUI.createAutoSellTab()
    
    -- Security Tab
    RayfieldUI.Tabs.Security = RayfieldUI.Window:CreateTab({Name = "🛡️ Security"})
    RayfieldUI.createSecurityTab()
    
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

return RayfieldUI
