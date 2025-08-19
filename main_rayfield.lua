-- main_rayfield.lua
-- AutoFish Pro with Rayfield UI
-- Simple, reliable, and lightweight interface

print("🎣 AutoFish Pro - Rayfield Edition")
print("Loading with Rayfield UI...")

-- GitHub Repository Configuration
local GITHUB_BASE = "https://raw.githubusercontent.com/MELLISAEFFENDY/fullversion/main/"

-- Load Rayfield library first
local function loadRayfieldLib()
    print("📚 Loading Rayfield Library...")
    local success, rayfieldLib = pcall(function()
        local url = GITHUB_BASE .. "rayfield_lib.lua"
        print("🌐 Fetching from: " .. url)
        
        local rayfieldCode = game:HttpGet(url)
        if not rayfieldCode or rayfieldCode == "" then
            error("Empty response from Rayfield library URL")
        end
        
        print("📝 Rayfield code length: " .. #rayfieldCode .. " characters")
        
        local rayfieldFunc = loadstring(rayfieldCode)
        if not rayfieldFunc then
            error("Failed to compile Rayfield library code")
        end
        
        print("⚙️ Executing Rayfield library...")
        local lib = rayfieldFunc()
        if not lib then
            error("Rayfield library returned nil")
        end
        
        if not lib.CreateWindow then
            error("Rayfield library missing CreateWindow function")
        end
        
        print("🔍 Rayfield library type: " .. type(lib))
        print("🔍 CreateWindow type: " .. type(lib.CreateWindow))
        
        return lib
    end)
    
    if success and rayfieldLib then
        print("✅ Rayfield Library loaded successfully")
        getgenv().RayfieldLib = rayfieldLib -- Make it globally available
        return rayfieldLib
    else
        print("❌ Failed to load Rayfield Library: " .. tostring(rayfieldLib))
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
    "fish_tracker"
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
        
        -- Special handling for rayfield_ui failure - fallback to custom UI
        if moduleName == "rayfield_ui" then
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
    
    -- Load Rayfield library first (required for UI)
    local rayfieldLib = loadRayfieldLib()
    if not rayfieldLib then
        error("❌ Failed to load Rayfield library - UI cannot be created")
    end
    
    -- Load configuration
    local config = loadConfig()
    
    -- Load all modules except UI first
    for _, moduleName in ipairs(moduleNames) do
        modules[moduleName] = safeLoadModule(moduleName)
        wait(0.1) -- Small delay between loads
    end
    
    -- Load Rayfield UI module
    modules.rayfield_ui = safeLoadModule("rayfield_ui")
    
    -- Verify critical modules loaded
    local criticalModules = {"autofish"}
    for _, moduleName in ipairs(criticalModules) do
        if not modules[moduleName] then
            error("❌ Critical module failed to load: " .. moduleName)
        end
    end
    
    -- Check if we have UI module (either rayfield_ui or fallback ui)
    local uiModule = modules.rayfield_ui or modules.ui
    if not uiModule then
        error("❌ No UI module available")
    end
    
    -- Initialize modules with cross-references
    print("🔧 Initializing module systems...")
    
    -- Initialize modules in dependency order
    print("🔧 Initializing modules...")
    
    if modules.security then
        local ok, err = pcall(function() modules.security.initialize() end)
        print("Security init:", ok and "✅" or "❌ " .. tostring(err))
    end
    
    if modules.fish_tracker then
        local ok, err = pcall(function() modules.fish_tracker.initialize() end)
        print("Fish tracker init:", ok and "✅" or "❌ " .. tostring(err))
    end

    if modules.dashboard then
        local ok, err = pcall(function() 
            if modules.dashboard.initialize then
                modules.dashboard.initialize(modules)
            else
                print("❌ Dashboard has no initialize method")
            end
        end)
        print("Dashboard init:", ok and "✅" or "❌ " .. tostring(err))
    end
    
    if modules.movement then
        local ok, err = pcall(function() 
            if modules.movement.initialize then
                modules.movement.initialize()
            else
                print("❌ Movement has no initialize method")
            end
        end)
        print("Movement init:", ok and "✅" or "❌ " .. tostring(err))
    end
    
    if modules.autosell then
        local ok, err = pcall(function() 
            if modules.autosell.initialize then
                modules.autosell.initialize()
            else
                print("❌ Autosell has no initialize method")
            end
        end)
        print("Autosell init:", ok and "✅" or "❌ " .. tostring(err))
    end
    
    if modules.autofish then
        local ok, err = pcall(function() 
            if modules.autofish.initialize then
                modules.autofish.initialize()
            else
                print("❌ Autofish has no initialize method")
            end
        end)
        print("Autofish init:", ok and "✅" or "❌ " .. tostring(err))
    end    -- Initialize UI (Rayfield UI or fallback to custom UI)
    local uiModule = modules.rayfield_ui or modules.ui
    local uiType = modules.rayfield_ui and "Rayfield" or "Custom"
    
    if uiModule then
        pcall(function() uiModule.initialize(modules) end)
        
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
        
        -- Show error in simple UI if Rayfield fails
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
    if modules and modules.rayfield_ui then
        modules.rayfield_ui.destroy()
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
    version = "2.0-Rayfield",
    
    -- Quick access functions
    toggleAutoFish = function()
        if loadedModules and loadedModules.rayfield_ui and loadedModules.rayfield_ui.Elements.AutoFishToggle then
            local currentState = loadedModules.autofish and loadedModules.autofish.isRunning() or false
            loadedModules.rayfield_ui.Elements.AutoFishToggle:Set(not currentState)
        end
    end,
    
    getStats = function()
        if loadedModules and loadedModules.dashboard then
            return loadedModules.dashboard.getStats()
        end
        return {}
    end,
    
    showUI = function()
        if loadedModules and loadedModules.rayfield_ui and loadedModules.rayfield_ui.Window then
            if loadedModules.rayfield_ui.Window.Show then
                loadedModules.rayfield_ui.Window:Show()
                print("🎮 Rayfield UI restored")
            else
                print("🎮 Rayfield UI is already visible")
            end
        end
    end,
    
    hideUI = function()
        if loadedModules and loadedModules.rayfield_ui and loadedModules.rayfield_ui.Window then
            if loadedModules.rayfield_ui.Window.Minimize then
                loadedModules.rayfield_ui.Window:Minimize()
                print("🎮 Rayfield UI minimized")
            elseif loadedModules.rayfield_ui.Window.Destroy then
                loadedModules.rayfield_ui.Window:Destroy()
                print("🎮 Rayfield UI destroyed")
            end
        end
    end
}

print("🌟 AutoFish Pro with Rayfield UI ready!")
print("🎮 Access via: getgenv().AutoFishPro")
