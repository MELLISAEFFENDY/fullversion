-- Modern AutoFish - Modular Version with GitHub Integration
-- Main loader script
-- Author: Spinner_xxx

print("🚀 Starting Modern AutoFish Modular...")

-- Configuration
local GITHUB_USER = "YourUsername"  -- Ganti dengan username GitHub Anda
local REPO_NAME = "AutoFishScript"  -- Ganti dengan nama repo Anda
local BRANCH = "main"
local BASE_URL = string.format("https://raw.githubusercontent.com/%s/%s/%s/", GITHUB_USER, REPO_NAME, BRANCH)

-- Module loader with error handling
local function loadModule(path, required)
    local url = BASE_URL .. path
    print("📥 Loading:", path)
    
    local success, result = pcall(function()
        local response = game:HttpGet(url)
        if response and #response > 0 then
            return loadstring(response)()
        else
            error("Empty response")
        end
    end)
    
    if success and result then
        print("✅ Loaded:", path)
        return result
    else
        local status = required and "❌ CRITICAL" or "⚠️ WARNING"
        print(string.format("%s Failed to load %s: %s", status, path, tostring(result)))
        
        if required then
            error("Critical module failed to load: " .. path)
        end
        return nil
    end
end

-- Fallback to local modules if GitHub fails
local function loadLocalModule(name)
    local success, result = pcall(function()
        return require("modules." .. name)
    end)
    
    if success then
        print("✅ Loaded local module:", name)
        return result
    else
        print("❌ Local module not found:", name)
        return nil
    end
end

-- Load modules with fallback
local function safeLoadModule(path, localName, required)
    local module = loadModule(path, false)
    
    if not module and localName then
        print("🔄 Falling back to local module:", localName)
        module = loadLocalModule(localName)
    end
    
    if not module and required then
        error("Critical module unavailable: " .. path)
    end
    
    return module
end

-- Load all modules
print("📦 Loading modules...")

local AutoFish = safeLoadModule("modules/autofish.lua", "autofish", true)
local Movement = safeLoadModule("modules/movement.lua", "movement", false)
local Dashboard = safeLoadModule("modules/dashboard.lua", "dashboard", false)
local AutoSell = safeLoadModule("modules/autosell.lua", "autosell", false)
local Security = safeLoadModule("modules/security.lua", "security", false)
local UI = safeLoadModule("modules/ui.lua", "ui", true)

-- Load configuration
local Config = safeLoadModule("config/settings.lua", "config", false)

-- Initialize system
print("🔧 Initializing modules...")

local initSuccess = true

if AutoFish then
    local ok = pcall(function() AutoFish.init(Config) end)
    if not ok then print("❌ AutoFish init failed") end
    initSuccess = initSuccess and ok
end

if Movement then
    local ok = pcall(function() Movement.init(Config) end)
    if not ok then print("❌ Movement init failed") end
end

if Dashboard then
    local ok = pcall(function() Dashboard.init(Config) end)
    if not ok then print("❌ Dashboard init failed") end
end

if AutoSell then
    local ok = pcall(function() AutoSell.init(Config) end)
    if not ok then print("❌ AutoSell init failed") end
end

if Security then
    local ok = pcall(function() Security.init(Config) end)
    if not ok then print("❌ Security init failed") end
end

if UI then
    local ok = pcall(function() 
        UI.createInterface({
            autofish = AutoFish,
            movement = Movement,
            dashboard = Dashboard,
            autosell = AutoSell,
            security = Security
        }) 
    end)
    if not ok then print("❌ UI init failed") end
    initSuccess = initSuccess and ok
end

if initSuccess then
    print("🎉 Modern AutoFish loaded successfully!")
    print("📍 Repository:", BASE_URL)
    print("🔧 All modules initialized")
else
    warn("⚠️ Some modules failed to initialize")
end

-- Global cleanup function
_G.ModernAutoFishCleanup = function()
    print("🧹 Cleaning up modules...")
    if AutoFish and AutoFish.cleanup then AutoFish.cleanup() end
    if Movement and Movement.cleanup then Movement.cleanup() end
    if Dashboard and Dashboard.cleanup then Dashboard.cleanup() end
    if AutoSell and AutoSell.cleanup then AutoSell.cleanup() end
    if Security and Security.cleanup then Security.cleanup() end
    if UI and UI.cleanup then UI.cleanup() end
    print("✅ Cleanup complete")
end

-- Version info
print("📋 Modern AutoFish Modular v2.0")
print("👤 by Spinner_xxx")
print("🔗 GitHub Integration Active")
