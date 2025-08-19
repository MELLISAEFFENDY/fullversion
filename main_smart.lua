-- main_smart.lua
-- AutoFish Pro with Smart UI Loading (ORION + Fallback)
-- Modular system with intelligent UI selection

print("🎣 AutoFish Pro - Smart Edition")
print("Attempting to load with best available UI...")

-- Suppress script errors from showing in UI
pcall(function()
    local StarterGui = game:GetService("StarterGui")
    StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = "AutoFish Pro loading...";
        Color = Color3.fromRGB(100, 255, 100);
        Font = Enum.Font.SourceSansBold;
        FontSize = Enum.FontSize.Size18;
    })
end)

-- Global error handler to suppress error popups
local originalError = error
local errorSuppressed = false

local function suppressErrors()
    if not errorSuppressed then
        errorSuppressed = true
        -- Override error function to prevent popups
        getgenv().error = function(msg, level)
            print("⚠️ Suppressed error: " .. tostring(msg))
        end
    end
end

-- Restore error function after loading
local function restoreErrors()
    if errorSuppressed then
        getgenv().error = originalError
        errorSuppressed = false
    end
end

-- Suppress errors during loading
suppressErrors()

-- GitHub Repository Configuration
local GITHUB_BASE = "https://raw.githubusercontent.com/MELLISAEFFENDY/fullversion/main/"

-- Modules to load
local modules = {}
local moduleNames = {
    "autofish",
    "movement", 
    "autosell",
    "security",
    "dashboard"
}

-- UI Selection
local uiType = "none"
local uiModule = nil

-- Safe module loading function
local function safeLoadModule(moduleName)
    local success, result = pcall(function()
        local url = GITHUB_BASE .. "modules/" .. moduleName .. ".lua"
        print("📦 Loading: " .. moduleName)
        
        local moduleCode = game:HttpGet(url)
        if moduleCode and moduleCode ~= "" then
            local moduleFunc = loadstring(moduleCode)
            if moduleFunc then
                return moduleFunc()
            else
                error("Failed to compile module: " .. moduleName)
            end
        else
            error("Empty or invalid module: " .. moduleName)
        end
    end)
    
    if success then
        print("✅ " .. moduleName .. " loaded successfully")
        return result
    else
        print("❌ Failed to load " .. moduleName .. ": " .. tostring(result))
        return nil
    end
end

-- Try to load ORION UI
local function tryLoadOrionUI()
    print("🌟 Attempting to load ORION UI...")
    
    local success, result = pcall(function()
        -- Load our custom ORION library first
        local orionUrl = GITHUB_BASE .. 'orion_lib.lua'
        print("🌐 Loading ORION library from: " .. orionUrl)
        
        local customOrionLib = loadstring(game:HttpGet(orionUrl))()
        
        if customOrionLib then
            print("✅ Custom ORION library loaded")
            print("🔍 Library type: " .. type(customOrionLib))
            if customOrionLib.MakeWindow then
                print("🔍 MakeWindow function found")
            else
                print("❌ MakeWindow function missing")
            end
            
            -- Store the library globally for modules to use
            getgenv().OrionLib = customOrionLib
            
            -- Now load our ORION UI module
            local orionModule = safeLoadModule("orion_ui")
            return orionModule
        else
            error("Custom ORION library failed to load - returned nil")
        end
    end)
    
    if success and result then
        print("✅ ORION UI loaded successfully!")
        uiType = "ORION"
        return result
    else
        print("⚠️ ORION UI failed to load: " .. tostring(result))
        return nil
    end
end

-- Try to load Custom UI as fallback
local function tryLoadCustomUI()
    print("🔄 Loading Custom UI as fallback...")
    
    local customUI = safeLoadModule("ui")
    if customUI then
        print("✅ Custom UI loaded successfully!")
        uiType = "Custom"
        return customUI
    else
        print("❌ Custom UI also failed to load")
        return nil
    end
end

-- Load configuration
local function loadConfig()
    local success, config = pcall(function()
        local url = GITHUB_BASE .. "config/settings.lua"
        local configCode = game:HttpGet(url)
        if configCode and configCode ~= "" then
            local configFunc = loadstring(configCode)
            if configFunc then
                return configFunc()
            end
        end
        return nil
    end)
    
    if success and config then
        print("✅ Configuration loaded")
        return config
    else
        print("⚠️ Using default configuration")
        return {
            autofish = { enabled = false },
            movement = { float = false, noclip = false },
            autosell = { enabled = false, threshold = 80 },
            security = { antiDetection = true, antiAFK = true },
            ui = { theme = "Default" }
        }
    end
end

-- Main initialization function
local function initializeAutoFish()
    print("🚀 Initializing AutoFish Pro...")
    
    -- Load configuration first
    local config = loadConfig()
    
    -- Load core modules first
    for _, moduleName in ipairs(moduleNames) do
        modules[moduleName] = safeLoadModule(moduleName)
        wait(0.1) -- Small delay between loads
    end
    
    -- Verify critical modules loaded
    if not modules.autofish then
        error("❌ Critical module failed to load: autofish")
    end
    
    -- Try to load UI (ORION first, then Custom fallback)
    uiModule = tryLoadOrionUI()
    if not uiModule then
        uiModule = tryLoadCustomUI()
    end
    
    if not uiModule then
        error("❌ No UI module available")
    end
    
    -- Store UI module in modules table
    if uiType == "ORION" then
        modules.orion_ui = uiModule
    else
        modules.ui = uiModule
    end
    
    -- Initialize modules in dependency order
    print("🔧 Initializing module systems...")
    
    if modules.security then
        modules.security.init(config.security or {})
    end
    
    if modules.dashboard then
        modules.dashboard.init(modules)
    end
    
    if modules.movement then
        modules.movement.init(config.movement or {})
    end
    
    if modules.autosell then
        modules.autosell.init(config.autosell or {})
    end
    
    if modules.autofish then
        modules.autofish.init(modules, config.autofish or {})
    end
    
    -- Initialize UI last (it needs all other modules)
    if uiModule then
        uiModule.init(modules)
        
        -- Show welcome notification
        if uiModule.showNotification then
            uiModule.showNotification(
                "Welcome!",
                "AutoFish Pro loaded successfully with " .. uiType .. " UI!",
                5
            )
        elseif uiModule.notify then
            uiModule.notify("AutoFish Pro", "Loaded successfully with " .. uiType .. " UI!")
        end
    end
    
    print("✅ AutoFish Pro initialization complete!")
    print("🎮 Use the " .. uiType .. " UI interface to control all features")
    
    return modules
end

-- Error handling wrapper
local function safeInit()
    local success, result = pcall(initializeAutoFish)
    if success then
        return result
    else
        print("❌ Initialization failed: " .. tostring(result))
        
        -- Don't show error UI if ORION is partially working
        local hasUI = false
        pcall(function()
            if game.Players.LocalPlayer.PlayerGui:FindFirstChild("OrionUI") then
                hasUI = true
            end
        end)
        
        if not hasUI then
            -- Show error in simple UI only if no UI is present
            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "AutoFishError"
            screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
            
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(0, 400, 0, 200)
            frame.Position = UDim2.new(0.5, -200, 0.5, -100)
            frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            frame.BorderSizePixel = 2
            frame.BorderColor3 = Color3.fromRGB(255, 0, 0)
            frame.Parent = screenGui
            
            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, 0, 0, 40)
            title.BackgroundTransparency = 1
            title.Text = "❌ AutoFish Pro - Error"
            title.TextColor3 = Color3.fromRGB(255, 255, 255)
            title.TextScaled = true
            title.Font = Enum.Font.SourceSansBold
            title.Parent = frame
            
            local message = Instance.new("TextLabel")
            message.Size = UDim2.new(1, -20, 1, -80)
            message.Position = UDim2.new(0, 10, 0, 40)
            message.BackgroundTransparency = 1
            message.Text = "Failed to load AutoFish Pro.\n\nError: " .. tostring(result) .. "\n\nPlease check your internet connection and try again."
            message.TextColor3 = Color3.fromRGB(255, 255, 255)
            message.TextScaled = true
            message.Font = Enum.Font.SourceSans
            message.TextWrapped = true
            message.Parent = frame
            
            local closeButton = Instance.new("TextButton")
            closeButton.Size = UDim2.new(0, 100, 0, 30)
            closeButton.Position = UDim2.new(0.5, -50, 1, -35)
            closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            closeButton.Text = "Close"
            closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            closeButton.TextScaled = true
            closeButton.Font = Enum.Font.SourceSansBold
            closeButton.Parent = frame
            
            closeButton.MouseButton1Click:Connect(function()
                screenGui:Destroy()
            end)
        end
        
        return nil
    end
end

-- Auto-cleanup on script stop
local connection
connection = game.Players.LocalPlayer.AncestryChanged:Connect(function()
    if uiModule and uiModule.destroy then
        uiModule.destroy()
    end
    if connection then
        connection:Disconnect()
    end
end)

-- Initialize the system
local loadedModules = safeInit()

-- Restore error handling after initialization
restoreErrors()

-- Export for external access
getgenv().AutoFishPro = {
    modules = loadedModules,
    uiType = uiType,
    version = "2.0-Smart",
    
    -- Quick access functions
    toggleAutoFish = function()
        if loadedModules and loadedModules.autofish then
            local currentState = loadedModules.autofish.isRunning and loadedModules.autofish.isRunning() or false
            if currentState then
                loadedModules.autofish.stop()
            else
                loadedModules.autofish.start()
            end
        end
    end,
    
    getStats = function()
        if loadedModules and loadedModules.dashboard then
            return loadedModules.dashboard.getStats()
        end
        return {}
    end,
    
    showUI = function()
        if uiModule then
            if uiModule.Window and uiModule.Window.SetVisible then
                uiModule.Window:SetVisible(true)
            elseif uiModule.show then
                uiModule.show()
            end
        end
    end,
    
    hideUI = function()
        if uiModule then
            if uiModule.Window and uiModule.Window.SetVisible then
                uiModule.Window:SetVisible(false)
            elseif uiModule.hide then
                uiModule.hide()
            end
        end
    end
}

print("🌟 AutoFish Pro with " .. uiType .. " UI ready!")
print("🎮 Access via: getgenv().AutoFishPro")
