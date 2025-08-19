-- main_clean.lua
-- AutoFish Pro - Clean Version (No Error Popups)
-- Modular system with intelligent UI selection and error suppression

print("🎣 AutoFish Pro - Clean Edition")
print("Loading with error suppression...")

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

-- Error suppression system
local function suppressErrorUI()
    -- Prevent error GUI from showing
    pcall(function()
        local coreCall = game:GetService("CoreGui").RobloxGui.Modules.ErrorPrompt
        if coreCall then
            coreCall.Parent = nil
        end
    end)
    
    -- Override error handling
    local originalWarn = warn
    getgenv().warn = function(...)
        -- Suppress warnings during loading
    end
    
    -- Restore after loading
    task.wait(10)
    getgenv().warn = originalWarn
end

-- Start error suppression
spawn(suppressErrorUI)

-- Safe module loading function with complete error handling
local function safeLoadModule(moduleName)
    local success, result = pcall(function()
        local url = GITHUB_BASE .. "modules/" .. moduleName .. ".lua"
        local moduleCode = game:HttpGet(url)
        if moduleCode and moduleCode ~= "" then
            local moduleFunc = loadstring(moduleCode)
            if moduleFunc then
                return moduleFunc()
            end
        end
        return nil
    end)
    
    if success and result then
        print("✅ " .. moduleName .. " loaded successfully")
        return result
    else
        print("❌ Failed to load " .. moduleName)
        return nil
    end
end

-- Try to load ORION UI with full error suppression
local function tryLoadOrionUI()
    print("🌟 Attempting to load ORION UI...")
    
    local success, result = pcall(function()
        -- Load our custom ORION library
        local libUrl = GITHUB_BASE .. "orion_lib.lua"
        local libCode = game:HttpGet(libUrl)
        if libCode and libCode ~= "" then
            local libFunc = loadstring(libCode)
            if libFunc then
                local OrionLib = libFunc()
                
                -- Load ORION UI module
                local orionModule = safeLoadModule("orion_ui")
                return orionModule
            end
        end
        return nil
    end)
    
    if success and result then
        print("✅ ORION UI loaded successfully!")
        uiType = "ORION"
        return result
    else
        print("⚠️ ORION UI not available, using fallback")
        return nil
    end
end

-- Try to load Custom UI as fallback
local function tryLoadCustomUI()
    print("🔄 Loading Custom UI...")
    
    local customUI = safeLoadModule("ui")
    if customUI then
        print("✅ Custom UI loaded successfully!")
        uiType = "Custom"
        return customUI
    else
        print("❌ No UI available")
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
        wait(0.05) -- Small delay between loads
    end
    
    -- Verify critical modules loaded
    if not modules.autofish then
        print("⚠️ AutoFish module not available, some features may not work")
    end
    
    -- Try to load UI (ORION first, then Custom fallback)
    uiModule = tryLoadOrionUI()
    if not uiModule then
        uiModule = tryLoadCustomUI()
    end
    
    if not uiModule then
        print("⚠️ No UI module available, running headless")
    end
    
    -- Store UI module in modules table
    if uiType == "ORION" then
        modules.orion_ui = uiModule
    else
        modules.ui = uiModule
    end
    
    -- Initialize modules in dependency order with error handling
    print("🔧 Initializing module systems...")
    
    pcall(function()
        if modules.security then
            modules.security.init(config.security or {})
        end
    end)
    
    pcall(function()
        if modules.dashboard then
            modules.dashboard.init(modules)
        end
    end)
    
    pcall(function()
        if modules.movement then
            modules.movement.init(config.movement or {})
        end
    end)
    
    pcall(function()
        if modules.autosell then
            modules.autosell.init(config.autosell or {})
        end
    end)
    
    pcall(function()
        if modules.autofish then
            modules.autofish.init(modules, config.autofish or {})
        end
    end)
    
    -- Initialize UI last with complete error handling
    pcall(function()
        if uiModule and uiModule.init then
            uiModule.init(modules)
            
            -- Show welcome notification
            if uiModule.showNotification then
                uiModule.showNotification(
                    "Welcome!",
                    "AutoFish Pro loaded with " .. uiType .. " UI!",
                    3
                )
            end
        end
    end)
    
    print("✅ AutoFish Pro initialization complete!")
    print("🎮 Using " .. uiType .. " interface")
    
    return modules
end

-- Ultra-safe initialization wrapper
local function ultraSafeInit()
    local success, result = pcall(function()
        return initializeAutoFish()
    end)
    
    if success then
        return result
    else
        print("⚠️ Some errors occurred during loading, but continuing...")
        -- Try to return partial modules if available
        return modules
    end
end

-- Auto-cleanup on script stop
local connection
connection = game.Players.LocalPlayer.AncestryChanged:Connect(function()
    pcall(function()
        if uiModule and uiModule.destroy then
            uiModule.destroy()
        end
    end)
    pcall(function()
        if connection then
            connection:Disconnect()
        end
    end)
end)

-- Initialize the system
local loadedModules = ultraSafeInit()

-- Export for external access
getgenv().AutoFishPro = {
    modules = loadedModules or {},
    uiType = uiType,
    version = "2.0-Clean",
    
    -- Quick access functions with error handling
    toggleAutoFish = function()
        pcall(function()
            if loadedModules and loadedModules.autofish then
                local currentState = (loadedModules.autofish.isRunning and loadedModules.autofish.isRunning()) or false
                if currentState then
                    if loadedModules.autofish.stop then
                        loadedModules.autofish.stop()
                    end
                else
                    if loadedModules.autofish.start then
                        loadedModules.autofish.start()
                    end
                end
            end
        end)
    end,
    
    getStats = function()
        local success, stats = pcall(function()
            if loadedModules and loadedModules.dashboard and loadedModules.dashboard.getStats then
                return loadedModules.dashboard.getStats()
            end
            return {}
        end)
        return success and stats or {}
    end,
    
    showUI = function()
        pcall(function()
            if uiModule then
                if uiModule.Window and uiModule.Window.SetVisible then
                    uiModule.Window:SetVisible(true)
                elseif uiModule.show then
                    uiModule.show()
                end
            end
        end)
    end,
    
    hideUI = function()
        pcall(function()
            if uiModule then
                if uiModule.Window and uiModule.Window.SetVisible then
                    uiModule.Window:SetVisible(false)
                elseif uiModule.hide then
                    uiModule.hide()
                end
            end
        end)
    end
}

print("🌟 AutoFish Pro Clean Edition ready!")
print("🎮 Access via: getgenv().AutoFishPro")
print("🛡️ Error suppression active - no popups!")
