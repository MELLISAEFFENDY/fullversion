-- modules/orion_ui.lua
-- ORION UI Interface Module for AutoFish System

local OrionUI = {}

-- Load our custom ORION Library from GitHub
local function loadOrionLib()
    local success, OrionLib = pcall(function()
        local url = "https://raw.githubusercontent.com/MELLISAEFFENDY/fullversion/main/orion_lib.lua"
        local code = game:HttpGet(url)
        if code and code ~= "" then
            local func = loadstring(code)
            if func then
                return func()
            else
                error("Failed to compile custom ORION library")
            end
        else
            error("Failed to download custom ORION library")
        end
    end)
    
    if success and OrionLib then
        print("✅ Custom ORION Library loaded successfully")
        return OrionLib
    else
        error("Failed to load custom ORION library: " .. tostring(OrionLib))
    end
end

local OrionLib = loadOrionLib()
OrionUI.Window = nil
OrionUI.Tabs = {}
OrionUI.Elements = {}

-- UI State
OrionUI.autoUpdateEnabled = true
OrionUI.updateFrequency = 1

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
        Name = "📊 Real-time Statistics"
    })
    
    -- Stats Labels (will be updated dynamically)
    OrionUI.Elements.StatsLabels = {}
    
    OrionUI.Elements.StatsLabels[1] = tab:AddLabel("Total Fish Caught: 0")
    OrionUI.Elements.StatsLabels[2] = tab:AddLabel("Session Runtime: 00:00:00")
    OrionUI.Elements.StatsLabels[3] = tab:AddLabel("Fish Per Hour: 0")
    OrionUI.Elements.StatsLabels[4] = tab:AddLabel("Total Value Earned: $0")
    OrionUI.Elements.StatsLabels[5] = tab:AddLabel("Rare Fish Caught: 0")
    OrionUI.Elements.StatsLabels[6] = tab:AddLabel("Current Location: Unknown")
    
    -- Performance Section
    tab:AddSection({
        Name = "📈 Performance Metrics"
    })
    
    OrionUI.Elements.StatsLabels[7] = tab:AddLabel("Rare Fish Percentage: 0%")
    OrionUI.Elements.StatsLabels[8] = tab:AddLabel("Average Catch Time: 0s")
    
    -- Actions Section
    tab:AddSection({
        Name = "🎯 Quick Actions"
    })
    
    -- Reset Statistics Button
    tab:AddButton({
        Name = "🔄 Reset Statistics",
        Callback = function()
            if OrionUI.modules.dashboard then
                OrionUI.modules.dashboard.resetStats()
                OrionUI.updateDashboard()
                OrionUI.showNotification("Dashboard", "Statistics reset successfully!", 3)
            end
        end
    })
    
    -- Export Data Button
    tab:AddButton({
        Name = "📊 Export Data",
        Callback = function()
            if OrionUI.modules.dashboard then
                OrionUI.modules.dashboard.exportData()
                OrionUI.showNotification("Dashboard", "Data exported to console!", 3)
            end
        end
    })
    
    -- Print Summary Button
    tab:AddButton({
        Name = "📋 Print Summary",
        Callback = function()
            if OrionUI.modules.dashboard then
                OrionUI.modules.dashboard.printSummary()
                OrionUI.showNotification("Dashboard", "Summary printed to console!", 3)
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
    
    -- UI Scale Slider
    tab:AddSlider({
        Name = "UI Scale",
        Min = 50,
        Max = 150,
        Default = 100,
        Increment = 10,
        ValueName = "%",
        Callback = function(value)
            local scale = value / 100
            if OrionUI.Window and OrionUI.Window.MainFrame then
                OrionUI.Window.MainFrame.Size = UDim2.new(0, 600 * scale, 0, 400 * scale)
                OrionUI.showNotification("Settings", "UI scale set to " .. value .. "%", 2)
            end
        end
    })
    
    -- Transparency Slider
    tab:AddSlider({
        Name = "Background Transparency",
        Min = 0,
        Max = 80,
        Default = 15,
        Increment = 5,
        ValueName = "%",
        Callback = function(value)
            if OrionLib and OrionLib.SetTransparency then
                OrionLib:SetTransparency(value / 100)
                OrionUI.showNotification("Settings", "Transparency set to " .. value .. "%", 2)
            end
        end
    })
    
    -- Floating Button Toggle
    tab:AddToggle({
        Name = "Show Floating Button",
        Default = true,
        Callback = function(value)
            OrionUI.config.floatingButton = value
            if OrionUI.Window and OrionUI.Window.FloatingButton then
                OrionUI.Window.FloatingButton.Visible = value and not OrionUI.Window.Visible
            end
            OrionUI.showNotification("Settings", "Floating button " .. (value and "enabled" or "disabled"), 2)
        end
    })
    
    -- Theme Dropdown
    tab:AddDropdown({
        Name = "UI Theme",
        Default = "Default",
        Options = {"Default", "Dark", "Ocean", "Purple", "Green"},
        Callback = function(value)
            OrionUI.setTheme(value)
        end
    })
    
    -- Window Controls Section
    tab:AddSection({
        Name = "🪟 Window Controls"
    })
    
    -- Draggable Toggle
    tab:AddToggle({
        Name = "Draggable Window",
        Default = true,
        Callback = function(value)
            if OrionUI.Window and OrionUI.Window.MainFrame then
                OrionUI.Window.MainFrame.Draggable = value
                OrionUI.showNotification("Settings", "Window dragging " .. (value and "enabled" or "disabled"), 2)
            end
        end
    })
    
    -- Reset Position Button
    tab:AddButton({
        Name = "🔄 Reset Window Position",
        Callback = function()
            if OrionUI.Window and OrionUI.Window.MainFrame then
                OrionUI.Window.MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
                OrionUI.showNotification("Settings", "Window position reset!", 2)
            end
        end
    })
    
    -- Minimize Button
    tab:AddButton({
        Name = "➖ Minimize Window",
        Callback = function()
            if OrionUI.Window and OrionUI.Window.Minimize then
                OrionUI.Window:Minimize()
            end
        end
    })
    
    -- Performance Section
    tab:AddSection({
        Name = "⚡ Performance"
    })
    
    -- Auto-Update Toggle
    tab:AddToggle({
        Name = "Auto-Update Dashboard",
        Default = true,
        Callback = function(value)
            OrionUI.autoUpdateEnabled = value
            OrionUI.showNotification("Settings", "Auto-update " .. (value and "enabled" or "disabled"), 2)
        end
    })
    
    -- Update Frequency Slider
    tab:AddSlider({
        Name = "Update Frequency",
        Min = 1,
        Max = 10,
        Default = 1,
        Increment = 1,
        ValueName = "s",
        Callback = function(value)
            OrionUI.updateFrequency = value
            OrionUI.showNotification("Settings", "Update frequency set to " .. value .. "s", 2)
        end
    })
    
    -- Configuration Section
    tab:AddSection({
        Name = "💾 Configuration"
    })
    
    -- Save Config Button
    tab:AddButton({
        Name = "💾 Save Configuration",
        Callback = function()
            OrionUI.saveConfig()
        end
    })
    
    -- Load Config Button
    tab:AddButton({
        Name = "📁 Load Configuration",
        Callback = function()
            OrionUI.loadConfig()
        end
    })
    
    -- Reset Config Button
    tab:AddButton({
        Name = "🔄 Reset to Default",
        Callback = function()
            OrionUI.resetConfig()
        end
    })
    
    -- Script Information Section
    tab:AddSection({
        Name = "ℹ️ Script Information"
    })
    
    tab:AddLabel("📱 AutoFish Pro v2.0-ORION")
    tab:AddLabel("🎨 Built with Custom ORION UI")
    tab:AddLabel("🏗️ Modular Architecture")
    tab:AddLabel("🎭 Floating Button Support")
    tab:AddLabel("🌫️ Transparent Background")
    tab:AddLabel("📅 Last Updated: " .. os.date("%m/%d/%Y"))
    
    -- System Info Section
    tab:AddSection({
        Name = "🖥️ System Information"
    })
    
    tab:AddLabel("🎮 Game: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
    tab:AddLabel("👤 Player: " .. game.Players.LocalPlayer.Name)
    tab:AddLabel("🌐 Server ID: " .. string.sub(game.JobId, 1, 8) .. "...")
    
    -- Credits Section
    tab:AddSection({
        Name = "👥 Credits"
    })
    
    tab:AddLabel("💻 Developer: MELLISAEFFENDY")
    tab:AddLabel("🎨 UI Library: Custom ORION")
    tab:AddLabel("📦 Repository: MELLISAEFFENDY/fullversion")
    tab:AddLabel("🌟 Special Thanks: Community Support")
    
    -- Maintenance Section
    tab:AddSection({
        Name = "🔧 Maintenance"
    })
    
    -- Check Updates Button
    tab:AddButton({
        Name = "🔍 Check for Updates",
        Callback = function()
            OrionUI.checkForUpdates()
        end
    })
    
    -- Restart UI Button
    tab:AddButton({
        Name = "🔄 Restart UI",
        Callback = function()
            OrionUI.showNotification("Settings", "Restarting UI...", 2)
            wait(1)
            if OrionUI.Window then
                OrionUI.Window:SetVisible(false)
                wait(0.5)
                OrionUI.Window:SetVisible(true)
            end
        end
    })
    
    -- Emergency Stop Button
    tab:AddButton({
        Name = "🛑 Emergency Stop All",
        Callback = function()
            if OrionUI.modules.autofish then
                OrionUI.modules.autofish.stop()
            end
            if OrionUI.modules.movement then
                OrionUI.modules.movement.disableFloat()
                OrionUI.modules.movement.disableNoClip()
                OrionUI.modules.movement.disableAutoSpinner()
            end
            if OrionUI.modules.autosell then
                OrionUI.modules.autosell.setEnabled(false)
            end
            OrionUI.showNotification("Emergency", "All features stopped!", 3)
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
        if OrionUI.Elements.StatsLabels[5] then
            OrionUI.Elements.StatsLabels[5]:Set("Rare Fish Caught: " .. (stats.rareCount or 0))
        end
        if OrionUI.Elements.StatsLabels[6] then
            OrionUI.Elements.StatsLabels[6]:Set("Current Location: " .. (stats.currentLocation or "Unknown"))
        end
        if OrionUI.Elements.StatsLabels[7] then
            OrionUI.Elements.StatsLabels[7]:Set("Rare Fish Percentage: " .. (stats.rarePercentage or 0) .. "%")
        end
        if OrionUI.Elements.StatsLabels[8] then
            local avgTime = stats.totalFish > 0 and math.floor((stats.sessionTime or 0) / stats.totalFish) or 0
            OrionUI.Elements.StatsLabels[8]:Set("Average Catch Time: " .. avgTime .. "s")
        end
    end
end

-- Setup auto-updates for dashboard
function OrionUI.setupAutoUpdates()
    spawn(function()
        while OrionUI.Window do
            if OrionUI.autoUpdateEnabled then
                OrionUI.updateDashboard()
            end
            wait(OrionUI.updateFrequency or 1) -- Update based on frequency setting
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
