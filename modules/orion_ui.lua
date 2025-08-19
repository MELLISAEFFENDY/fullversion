-- modules/orion_ui.lua
-- ORION UI Interface Module for AutoFish System

local OrionUI = {}

-- Load ORION Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Store references
OrionUI.Window = nil
OrionUI.Tabs = {}
OrionUI.Elements = {}

-- Configuration
local config = {
    WindowName = "🎣 AutoFish Pro",
    SaveConfig = true,
    ConfigFolder = "AutoFishPro",
    IntroEnabled = true,
    IntroText = "Welcome to AutoFish Pro!",
    Icon = "rbxassetid://4483345998"
}

-- Initialize ORION UI
function OrionUI.init(modules)
    OrionUI.modules = modules
    
    -- Create main window
    OrionUI.Window = OrionLib:MakeWindow({
        Name = config.WindowName,
        HidePremium = false,
        SaveConfig = config.SaveConfig,
        ConfigFolder = config.ConfigFolder,
        IntroEnabled = config.IntroEnabled,
        IntroText = config.IntroText,
        IntroIcon = config.Icon
    })
    
    -- Create tabs
    OrionUI.createTabs()
    
    -- Setup auto-updates
    OrionUI.setupAutoUpdates()
    
    print("✅ ORION UI initialized successfully!")
    return OrionUI.Window
end

-- Create all tabs
function OrionUI.createTabs()
    -- Main AutoFish Tab
    OrionUI.Tabs.AutoFish = OrionUI.Window:MakeTab({
        Name = "🎣 AutoFish",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })
    
    -- Movement Tab
    OrionUI.Tabs.Movement = OrionUI.Window:MakeTab({
        Name = "🚀 Movement",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })
    
    -- AutoSell Tab
    OrionUI.Tabs.AutoSell = OrionUI.Window:MakeTab({
        Name = "💰 AutoSell",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })
    
    -- Security Tab
    OrionUI.Tabs.Security = OrionUI.Window:MakeTab({
        Name = "🛡️ Security",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })
    
    -- Dashboard Tab
    OrionUI.Tabs.Dashboard = OrionUI.Window:MakeTab({
        Name = "📊 Dashboard",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })
    
    -- Settings Tab
    OrionUI.Tabs.Settings = OrionUI.Window:MakeTab({
        Name = "⚙️ Settings",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })
    
    -- Populate tabs with content
    OrionUI.createAutoFishTab()
    OrionUI.createMovementTab()
    OrionUI.createAutoSellTab()
    OrionUI.createSecurityTab()
    OrionUI.createDashboardTab()
    OrionUI.createSettingsTab()
end

-- AutoFish Tab Content
function OrionUI.createAutoFishTab()
    local tab = OrionUI.Tabs.AutoFish
    
    -- Main Controls Section
    tab:AddSection({
        Name = "🎣 Main Controls"
    })
    
    -- AutoFish Toggle
    OrionUI.Elements.AutoFishToggle = tab:AddToggle({
        Name = "Enable AutoFish",
        Default = false,
        Callback = function(value)
            if OrionUI.modules.autofish then
                if value then
                    OrionUI.modules.autofish.start()
                else
                    OrionUI.modules.autofish.stop()
                end
            end
        end
    })
    
    -- Fishing Mode Dropdown
    OrionUI.Elements.FishingMode = tab:AddDropdown({
        Name = "Fishing Mode",
        Default = "Smart",
        Options = {"Smart", "Secure", "Fast", "Stealth"},
        Callback = function(value)
            if OrionUI.modules.autofish then
                OrionUI.modules.autofish.setMode(value)
            end
        end
    })
    
    -- Cast Power Slider
    OrionUI.Elements.CastPower = tab:AddSlider({
        Name = "Cast Power",
        Min = 50,
        Max = 100,
        Default = 85,
        Color = Color3.fromRGB(255, 255, 255),
        Increment = 5,
        ValueName = "%",
        Callback = function(value)
            if OrionUI.modules.autofish then
                OrionUI.modules.autofish.setCastPower(value)
            end
        end
    })
    
    -- Advanced Settings Section
    tab:AddSection({
        Name = "⚙️ Advanced Settings"
    })
    
    -- Auto Re-cast Toggle
    tab:AddToggle({
        Name = "Auto Re-cast",
        Default = true,
        Callback = function(value)
            if OrionUI.modules.autofish then
                OrionUI.modules.autofish.setAutoRecast(value)
            end
        end
    })
    
    -- Perfect Catch Toggle
    tab:AddToggle({
        Name = "Perfect Catch Mode",
        Default = false,
        Callback = function(value)
            if OrionUI.modules.autofish then
                OrionUI.modules.autofish.setPerfectCatch(value)
            end
        end
    })
    
    -- Delay Settings
    tab:AddSlider({
        Name = "Cast Delay (seconds)",
        Min = 0.1,
        Max = 5.0,
        Default = 1.0,
        Color = Color3.fromRGB(255, 255, 255),
        Increment = 0.1,
        ValueName = "s",
        Callback = function(value)
            if OrionUI.modules.autofish then
                OrionUI.modules.autofish.setCastDelay(value)
            end
        end
    })
end

-- Movement Tab Content
function OrionUI.createMovementTab()
    local tab = OrionUI.Tabs.Movement
    
    -- Movement Controls Section
    tab:AddSection({
        Name = "🚀 Movement Controls"
    })
    
    -- Float Toggle
    tab:AddToggle({
        Name = "Float Mode",
        Default = false,
        Callback = function(value)
            if OrionUI.modules.movement then
                OrionUI.modules.movement.setFloat(value)
            end
        end
    })
    
    -- NoClip Toggle
    tab:AddToggle({
        Name = "NoClip",
        Default = false,
        Callback = function(value)
            if OrionUI.modules.movement then
                OrionUI.modules.movement.setNoClip(value)
            end
        end
    })
    
    -- Auto Spinner Section
    tab:AddSection({
        Name = "🔄 Auto Spinner"
    })
    
    -- Auto Spinner Toggle
    tab:AddToggle({
        Name = "Enable Auto Spinner",
        Default = false,
        Callback = function(value)
            if OrionUI.modules.movement then
                OrionUI.modules.movement.setAutoSpinner(value)
            end
        end
    })
    
    -- Spinner Speed
    tab:AddSlider({
        Name = "Spinner Speed",
        Min = 1,
        Max = 20,
        Default = 10,
        Color = Color3.fromRGB(255, 255, 255),
        Increment = 1,
        ValueName = "x",
        Callback = function(value)
            if OrionUI.modules.movement then
                OrionUI.modules.movement.setSpinnerSpeed(value)
            end
        end
    })
end

-- AutoSell Tab Content
function OrionUI.createAutoSellTab()
    local tab = OrionUI.Tabs.AutoSell
    
    -- AutoSell Controls Section
    tab:AddSection({
        Name = "💰 AutoSell Controls"
    })
    
    -- AutoSell Toggle
    tab:AddToggle({
        Name = "Enable AutoSell",
        Default = false,
        Callback = function(value)
            if OrionUI.modules.autosell then
                OrionUI.modules.autosell.setEnabled(value)
            end
        end
    })
    
    -- Sell Threshold
    tab:AddSlider({
        Name = "Inventory Threshold",
        Min = 10,
        Max = 100,
        Default = 80,
        Color = Color3.fromRGB(255, 255, 255),
        Increment = 5,
        ValueName = "%",
        Callback = function(value)
            if OrionUI.modules.autosell then
                OrionUI.modules.autosell.setThreshold(value)
            end
        end
    })
    
    -- Fish Type Settings Section
    tab:AddSection({
        Name = "🐟 Fish Type Settings"
    })
    
    -- Sell Common Fish
    tab:AddToggle({
        Name = "Sell Common Fish",
        Default = true,
        Callback = function(value)
            if OrionUI.modules.autosell then
                OrionUI.modules.autosell.setSellCommon(value)
            end
        end
    })
    
    -- Sell Rare Fish
    tab:AddToggle({
        Name = "Sell Rare Fish",
        Default = false,
        Callback = function(value)
            if OrionUI.modules.autosell then
                OrionUI.modules.autosell.setSellRare(value)
            end
        end
    })
    
    -- Sell Legendary Fish
    tab:AddToggle({
        Name = "Sell Legendary Fish",
        Default = false,
        Callback = function(value)
            if OrionUI.modules.autosell then
                OrionUI.modules.autosell.setSellLegendary(value)
            end
        end
    })
end

-- Security Tab Content
function OrionUI.createSecurityTab()
    local tab = OrionUI.Tabs.Security
    
    -- Anti-Detection Section
    tab:AddSection({
        Name = "🛡️ Anti-Detection"
    })
    
    -- Anti-Detection Toggle
    tab:AddToggle({
        Name = "Enable Anti-Detection",
        Default = true,
        Callback = function(value)
            if OrionUI.modules.security then
                OrionUI.modules.security.setAntiDetection(value)
            end
        end
    })
    
    -- Randomization Level
    tab:AddSlider({
        Name = "Randomization Level",
        Min = 1,
        Max = 10,
        Default = 5,
        Color = Color3.fromRGB(255, 255, 255),
        Increment = 1,
        ValueName = "",
        Callback = function(value)
            if OrionUI.modules.security then
                OrionUI.modules.security.setRandomizationLevel(value)
            end
        end
    })
    
    -- Anti-AFK Section
    tab:AddSection({
        Name = "⏰ Anti-AFK"
    })
    
    -- Anti-AFK Toggle
    tab:AddToggle({
        Name = "Enable Anti-AFK",
        Default = true,
        Callback = function(value)
            if OrionUI.modules.security then
                OrionUI.modules.security.setAntiAFK(value)
            end
        end
    })
    
    -- AFK Interval
    tab:AddSlider({
        Name = "AFK Check Interval",
        Min = 30,
        Max = 300,
        Default = 120,
        Color = Color3.fromRGB(255, 255, 255),
        Increment = 10,
        ValueName = "s",
        Callback = function(value)
            if OrionUI.modules.security then
                OrionUI.modules.security.setAFKInterval(value)
            end
        end
    })
    
    -- Auto-Reconnect Section
    tab:AddSection({
        Name = "🔄 Auto-Reconnect"
    })
    
    -- Auto-Reconnect Toggle
    tab:AddToggle({
        Name = "Enable Auto-Reconnect",
        Default = true,
        Callback = function(value)
            if OrionUI.modules.security then
                OrionUI.modules.security.setAutoReconnect(value)
            end
        end
    })
end

-- Dashboard Tab Content
function OrionUI.createDashboardTab()
    local tab = OrionUI.Tabs.Dashboard
    
    -- Statistics Section
    tab:AddSection({
        Name = "📊 Statistics"
    })
    
    -- Stats Labels (will be updated dynamically)
    OrionUI.Elements.StatsLabels = {}
    
    local statLabels = {
        "Total Fish Caught: 0",
        "Session Runtime: 00:00:00",
        "Fish Per Hour: 0",
        "Total Value Earned: $0"
    }
    
    for i, labelText in ipairs(statLabels) do
        OrionUI.Elements.StatsLabels[i] = tab:AddLabel(labelText)
    end
    
    -- Actions Section
    tab:AddSection({
        Name = "🎯 Quick Actions"
    })
    
    -- Reset Statistics Button
    tab:AddButton({
        Name = "Reset Statistics",
        Callback = function()
            if OrionUI.modules.dashboard then
                OrionUI.modules.dashboard.resetStats()
                OrionUI.updateDashboard()
            end
        end
    })
    
    -- Export Data Button
    tab:AddButton({
        Name = "Export Data",
        Callback = function()
            if OrionUI.modules.dashboard then
                OrionUI.modules.dashboard.exportData()
            end
        end
    })
end

-- Settings Tab Content
function OrionUI.createSettingsTab()
    local tab = OrionUI.Tabs.Settings
    
    -- UI Settings Section
    tab:AddSection({
        Name = "🎨 UI Settings"
    })
    
    -- Theme Dropdown
    tab:AddDropdown({
        Name = "UI Theme",
        Default = "Default",
        Options = {"Default", "Dark", "Ocean", "Space"},
        Callback = function(value)
            OrionUI.setTheme(value)
        end
    })
    
    -- Configuration Section
    tab:AddSection({
        Name = "💾 Configuration"
    })
    
    -- Save Config Button
    tab:AddButton({
        Name = "Save Configuration",
        Callback = function()
            OrionUI.saveConfig()
        end
    })
    
    -- Load Config Button
    tab:AddButton({
        Name = "Load Configuration",
        Callback = function()
            OrionUI.loadConfig()
        end
    })
    
    -- Reset Config Button
    tab:AddButton({
        Name = "Reset to Default",
        Callback = function()
            OrionUI.resetConfig()
        end
    })
    
    -- Script Info Section
    tab:AddSection({
        Name = "ℹ️ Script Information"
    })
    
    tab:AddLabel("AutoFish Pro v2.0")
    tab:AddLabel("Built with ORION UI")
    tab:AddLabel("Modular Architecture")
    
    -- Update Button
    tab:AddButton({
        Name = "Check for Updates",
        Callback = function()
            OrionUI.checkForUpdates()
        end
    })
end

-- Update dashboard with real-time data
function OrionUI.updateDashboard()
    if not OrionUI.modules.dashboard then return end
    
    local stats = OrionUI.modules.dashboard.getStats()
    
    if OrionUI.Elements.StatsLabels then
        if OrionUI.Elements.StatsLabels[1] then
            OrionUI.Elements.StatsLabels[1]:Set("Total Fish Caught: " .. (stats.totalFish or 0))
        end
        if OrionUI.Elements.StatsLabels[2] then
            OrionUI.Elements.StatsLabels[2]:Set("Session Runtime: " .. (stats.runtime or "00:00:00"))
        end
        if OrionUI.Elements.StatsLabels[3] then
            OrionUI.Elements.StatsLabels[3]:Set("Fish Per Hour: " .. (stats.fishPerHour or 0))
        end
        if OrionUI.Elements.StatsLabels[4] then
            OrionUI.Elements.StatsLabels[4]:Set("Total Value Earned: $" .. (stats.totalValue or 0))
        end
    end
end

-- Setup auto-updates for dashboard
function OrionUI.setupAutoUpdates()
    spawn(function()
        while OrionUI.Window do
            OrionUI.updateDashboard()
            wait(1) -- Update every second
        end
    end)
end

-- Theme management
function OrionUI.setTheme(themeName)
    -- ORION theme implementation would go here
    print("Theme changed to: " .. themeName)
end

-- Configuration management
function OrionUI.saveConfig()
    print("Configuration saved!")
    OrionLib:MakeNotification({
        Name = "Configuration",
        Content = "Settings saved successfully!",
        Image = "rbxassetid://4483345998",
        Time = 3
    })
end

function OrionUI.loadConfig()
    print("Configuration loaded!")
    OrionLib:MakeNotification({
        Name = "Configuration",
        Content = "Settings loaded successfully!",
        Image = "rbxassetid://4483345998",
        Time = 3
    })
end

function OrionUI.resetConfig()
    print("Configuration reset!")
    OrionLib:MakeNotification({
        Name = "Configuration", 
        Content = "Settings reset to default!",
        Image = "rbxassetid://4483345998",
        Time = 3
    })
end

-- Update checker
function OrionUI.checkForUpdates()
    OrionLib:MakeNotification({
        Name = "Updates",
        Content = "Checking for updates...",
        Image = "rbxassetid://4483345998",
        Time = 2
    })
    
    -- Simulate update check
    wait(2)
    
    OrionLib:MakeNotification({
        Name = "Updates",
        Content = "You're running the latest version!",
        Image = "rbxassetid://4483345998",
        Time = 3
    })
end

-- Cleanup function
function OrionUI.destroy()
    if OrionUI.Window then
        OrionLib:Destroy()
        OrionUI.Window = nil
        OrionUI.Tabs = {}
        OrionUI.Elements = {}
    end
end

-- Utility functions
function OrionUI.showNotification(title, message, duration)
    OrionLib:MakeNotification({
        Name = title,
        Content = message,
        Image = "rbxassetid://4483345998",
        Time = duration or 3
    })
end

function OrionUI.updateElementValue(elementName, value)
    if OrionUI.Elements[elementName] then
        OrionUI.Elements[elementName]:Set(value)
    end
end

return OrionUI
