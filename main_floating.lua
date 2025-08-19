-- main_floating.lua
-- AutoFish Pro with Modern Floating Button
-- Clean interface with quick access floating controls

print("🎣 AutoFish Pro - Floating Button Edition")
print("Loading with modern floating interface...")

-- GitHub Repository Configuration
local GITHUB_BASE = "https://raw.githubusercontent.com/MELLISAEFFENDY/fullversion/main/"

-- Load floating button library
local function loadFloatingButton()
    print("🎮 Loading Floating Button...")
    local success, floatingLib = pcall(function()
        local url = GITHUB_BASE .. "floating_button.lua"
        print("🌐 Fetching from: " .. url)
        
        local floatingCode = game:HttpGet(url)
        if not floatingCode or floatingCode == "" then
            error("Empty response from floating button URL")
        end
        
        print("📝 Floating button code length: " .. #floatingCode .. " characters")
        
        local floatingFunc = loadstring(floatingCode)
        if not floatingFunc then
            error("Failed to compile floating button code")
        end
        
        print("⚙️ Executing floating button library...")
        local lib = floatingFunc()
        if not lib then
            error("Floating button library returned nil")
        end
        
        print("🔍 Floating button library type: " .. type(lib))
        
        return lib
    end)
    
    if success and floatingLib then
        print("✅ Floating Button Library loaded successfully")
        return floatingLib
    else
        print("❌ Failed to load Floating Button Library: " .. tostring(floatingLib))
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
    "dashboard"
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
            ui = { theme = "FloatingButton" }
        }
    end
end

-- Main initialization function
local function initializeAutoFish()
    print("🚀 Initializing AutoFish Pro...")
    
    -- Load configuration
    local config = loadConfig()
    
    -- Load all core modules first
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
    
    -- Load and create floating button
    local floatingButton = loadFloatingButton()
    if floatingButton then
        modules.floating_button = floatingButton.create(modules)
        print("🎮 Floating button interface ready!")
    else
        print("⚠️ Floating button failed to load, continuing without UI")
    end
    
    print("✅ AutoFish Pro initialization complete!")
    print("🎮 Use the floating button to control all features")
    
    return modules
end

-- Error handling wrapper
local function safeInit()
    local success, result = pcall(initializeAutoFish)
    if success then
        return result
    else
        print("❌ Initialization failed: " .. tostring(result))
        
        -- Show simple error notification
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "AutoFishError"
        screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        
        local notification = Instance.new("Frame")
        notification.Size = UDim2.new(0, 300, 0, 100)
        notification.Position = UDim2.new(1, -320, 0, 20)
        notification.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
        notification.BorderSizePixel = 0
        notification.Parent = screenGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = notification
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -20, 0, 30)
        title.Position = UDim2.new(0, 10, 0, 5)
        title.BackgroundTransparency = 1
        title.Text = "❌ AutoFish Pro - Error"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 14
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = notification
        
        local message = Instance.new("TextLabel")
        message.Size = UDim2.new(1, -20, 1, -35)
        message.Position = UDim2.new(0, 10, 0, 30)
        message.BackgroundTransparency = 1
        message.Text = "Failed to initialize. Check console for details."
        message.TextColor3 = Color3.fromRGB(255, 255, 255)
        message.TextSize = 12
        message.Font = Enum.Font.Gotham
        message.TextXAlignment = Enum.TextXAlignment.Left
        message.TextYAlignment = Enum.TextYAlignment.Top
        message.TextWrapped = true
        message.Parent = notification
        
        -- Auto-hide notification
        wait(5)
        if screenGui then
            screenGui:Destroy()
        end
        
        return nil
    end
end

-- Auto-cleanup on script stop
local connection
connection = game.Players.LocalPlayer.AncestryChanged:Connect(function()
    if modules and modules.floating_button then
        modules.floating_button.destroy()
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
    version = "2.0-Floating",
    
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
        if loadedModules and loadedModules.floating_button then
            if not loadedModules.floating_button.menuOpen then
                loadedModules.floating_button.toggleMenu()
            end
        end
        print("🎮 Use the floating button for quick access")
    end,
    
    hideUI = function()
        if loadedModules and loadedModules.floating_button then
            if loadedModules.floating_button.menuOpen then
                loadedModules.floating_button.toggleMenu()
            end
        end
    end,
    
    destroyFloatingButton = function()
        if loadedModules and loadedModules.floating_button then
            loadedModules.floating_button.destroy()
        end
    end
}

print("🌟 AutoFish Pro with Floating Button ready!")
print("🎮 Access via: getgenv().AutoFishPro")
print("🖱️ Click the floating button for quick controls!")
