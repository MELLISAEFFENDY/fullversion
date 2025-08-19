-- main_orion.lua
-- AutoFish Pro with ORION UI
-- Modular system with enhanced interface

print("🎣 AutoFish Pro - ORION Edition")
print("Loading modules...")

-- GitHub Repository Configuration
local GITHUB_BASE = "https://raw.githubusercontent.com/MELLISAEFFENDY/fullversion/main/"

-- Load ORION library first
local function loadOrionLib()
    print("📚 Loading ORION Library...")
    local success, orionLib = pcall(function()
        local url = GITHUB_BASE .. "orion_lib.lua"
        print("🌐 Fetching from: " .. url)
        
        local orionCode = game:HttpGet(url)
        if not orionCode or orionCode == "" then
            error("Empty response from ORION library URL")
        end
        
        print("📝 ORION code length: " .. #orionCode .. " characters")
        
        local orionFunc = loadstring(orionCode)
        if not orionFunc then
            error("Failed to compile ORION library code")
        end
        
        print("⚙️ Executing ORION library...")
        local lib = orionFunc()
        if not lib then
            error("ORION library returned nil")
        end
        
        if not lib.MakeWindow then
            error("ORION library missing MakeWindow function")
        end
        
        print("🔍 ORION library type: " .. type(lib))
        print("🔍 MakeWindow type: " .. type(lib.MakeWindow))
        
        return lib
    end)
    
    if success and orionLib then
        print("✅ ORION Library loaded successfully")
        getgenv().OrionLib = orionLib -- Make it globally available
        return orionLib
    else
        print("❌ Failed to load ORION Library: " .. tostring(orionLib))
        return nil
    end
end

-- Modules to load
local modules = {}
local moduleNames = {
    "autofish",
    "movement", 
    "autosell",
    "security",
    "dashboard",
    "orion_ui"
}

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
        
        -- Special handling for orion_ui failure - fallback to custom UI
        if moduleName == "orion_ui" then
            print("🔄 Falling back to custom UI...")
            local fallbackSuccess, fallbackUI = pcall(function()
                local fallbackUrl = GITHUB_BASE .. "modules/ui.lua"
                local fallbackCode = game:HttpGet(fallbackUrl)
                if fallbackCode and fallbackCode ~= "" then
                    local fallbackFunc = loadstring(fallbackCode)
                    if fallbackFunc then
                        return fallbackFunc()
                    end
                end
                return nil
            end)
            
            if fallbackSuccess and fallbackUI then
                print("✅ Fallback UI loaded successfully")
                return fallbackUI
            end
        end
        
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
    
    -- Load ORION library first (required for UI)
    local orionLib = loadOrionLib()
    if not orionLib then
        error("❌ Failed to load ORION library - UI cannot be created")
    end
    
    -- Load configuration
    local config = loadConfig()
    
    -- Load all modules
    for _, moduleName in ipairs(moduleNames) do
        modules[moduleName] = safeLoadModule(moduleName)
        wait(0.1) -- Small delay between loads
    end
    
    -- Verify critical modules loaded
    local criticalModules = {"autofish"}
    for _, moduleName in ipairs(criticalModules) do
        if not modules[moduleName] then
            error("❌ Critical module failed to load: " .. moduleName)
        end
    end
    
    -- Check if we have UI module (either orion_ui or fallback ui)
    local uiModule = modules.orion_ui or modules.ui
    if not uiModule then
        error("❌ No UI module available")
    end
    
    -- Initialize modules with cross-references
    print("🔧 Initializing module systems...")
    
    -- Initialize modules in dependency order
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
    
    -- Initialize UI (ORION UI or fallback to custom UI)
    local uiModule = modules.orion_ui or modules.ui
    local uiType = modules.orion_ui and "ORION" or "Custom"
    
    if uiModule then
        uiModule.init(modules)
        
        -- Show welcome notification
        if uiModule.showNotification then
            uiModule.showNotification(
                "Welcome!",
                "AutoFish Pro loaded successfully with " .. uiType .. " UI!",
                5
            )
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
        
        -- Show error in simple UI if ORION fails
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
        
        return nil
    end
end

-- Auto-cleanup on script stop
local connection
connection = game.Players.LocalPlayer.AncestryChanged:Connect(function()
    if modules and modules.orion_ui then
        modules.orion_ui.destroy()
    end
    if connection then
        connection:Disconnect()
    end
end)

-- Initialize the system
local loadedModules = safeInit()

-- Export for external access
getgenv().AutoFishPro = {
    modules = loadedModules,
    version = "2.0-ORION",
    
    -- Quick access functions
    toggleAutoFish = function()
        if loadedModules and loadedModules.orion_ui and loadedModules.orion_ui.Elements.AutoFishToggle then
            local currentState = loadedModules.autofish and loadedModules.autofish.isRunning() or false
            loadedModules.orion_ui.Elements.AutoFishToggle:Set(not currentState)
        end
    end,
    
    getStats = function()
        if loadedModules and loadedModules.dashboard then
            return loadedModules.dashboard.getStats()
        end
        return {}
    end,
    
    showUI = function()
        if loadedModules and loadedModules.orion_ui and loadedModules.orion_ui.Window then
            loadedModules.orion_ui.Window:SetVisible(true)
        end
    end,
    
    hideUI = function()
        if loadedModules and loadedModules.orion_ui and loadedModules.orion_ui.Window then
            loadedModules.orion_ui.Window:SetVisible(false)
        end
    end
}

print("🌟 AutoFish Pro with ORION UI ready!")
print("🎮 Access via: getgenv().AutoFishPro")
