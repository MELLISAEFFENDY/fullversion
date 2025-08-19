-- AutoFish Core Module
-- Part of Modern AutoFish Modular System

local AutoFish = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

-- Configuration
AutoFish.config = {
    mode = "smart",
    autoRecastDelay = 0.4,
    safeModeChance = 70,
    enabled = false,
    maxActionsPerMinute = 12000000,
    detectionCooldown = 5,
    fishDetection = true,
    autoCast = true,
    autoRecast = true,
    perfectCatch = false,
    castPower = 75
}

-- Internal state
local sessionId = 0
local Security = {
    actionsThisMinute = 0,
    lastMinuteReset = tick(),
    isInCooldown = false,
    suspicion = 0
}

-- Remote finding helper
local function FindNet()
    local ok, net = pcall(function()
        local packages = ReplicatedStorage:FindFirstChild("Packages")
        if not packages then return nil end
        local idx = packages:FindFirstChild("_Index")
        if not idx then return nil end
        local sleit = idx:FindFirstChild("sleitnick_net@0.2.0")
        if not sleit then return nil end
        return sleit:FindFirstChild("net")
    end)
    return ok and net or nil
end

local function ResolveRemote(name)
    local net = FindNet()
    if not net then return nil end
    local ok, rem = pcall(function() return net:FindFirstChild(name) end)
    return ok and rem or nil
end

-- Get remotes
local rodRemote = ResolveRemote("RF/ChargeFishingRod")
local miniGameRemote = ResolveRemote("RF/RequestFishingMinigameStarted")
local finishRemote = ResolveRemote("RE/FishingCompleted")
local equipRemote = ResolveRemote("RE/EquipToolFromHotbar")

-- Notification function
local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 4
        })
    end)
    print(string.format("[AutoFish] %s: %s", title, text))
end

-- Safe invoke helper
local function safeInvoke(remote, ...)
    if not remote then return false, "nil_remote" end
    if remote:IsA("RemoteFunction") then
        return pcall(function(...) return remote:InvokeServer(...) end, ...)
    else
        return pcall(function(...) remote:FireServer(...) return true end, ...)
    end
end

-- Security functions
local function inCooldown()
    local now = tick()
    if now - Security.lastMinuteReset > 60 then
        Security.actionsThisMinute = 0
        Security.lastMinuteReset = now
    end
    if Security.actionsThisMinute >= AutoFish.config.maxActionsPerMinute then
        Security.isInCooldown = true
        return true
    end
    return Security.isInCooldown
end

local function secureInvoke(remote, ...)
    if inCooldown() then return false, "cooldown" end
    Security.actionsThisMinute = Security.actionsThisMinute + 1
    task.wait(0.01 + math.random() * 0.05)
    local ok, res = safeInvoke(remote, ...)
    if not ok then
        Security.suspicion = Security.suspicion + 1
        if Security.suspicion > 8 then
            Security.isInCooldown = true
            task.spawn(function()
                notify("Security", "Entering cooldown due to repeated errors")
                task.wait(AutoFish.config.detectionCooldown)
                Security.suspicion = 0
                Security.isInCooldown = false
            end)
        end
    end
    return ok, res
end

-- Get server time
local function GetServerTime()
    local ok, st = pcall(function() return workspace:GetServerTimeNow() end)
    if ok and type(st) == "number" then return st end
    return tick()
end

-- Fishing cycles
local function DoSmartCycle()
    -- Equip rod
    if equipRemote then 
        pcall(function() equipRemote:FireServer(1) end)
        task.wait(0.1)
    end
    
    -- Smart mode logic
    local usePerfect = math.random(1,100) <= AutoFish.config.safeModeChance
    local timestamp = usePerfect and GetServerTime() or GetServerTime() + math.random()*0.5
    
    -- Charge rod
    if rodRemote and rodRemote:IsA("RemoteFunction") then 
        pcall(function() rodRemote:InvokeServer(timestamp) end)
    end
    
    task.wait(0.1)
    
    -- Mini-game
    local x = usePerfect and -1.238 or (math.random(-1000,1000)/1000)
    local y = usePerfect and 0.969 or (math.random(0,1000)/1000)
    
    if miniGameRemote and miniGameRemote:IsA("RemoteFunction") then 
        pcall(function() miniGameRemote:InvokeServer(x,y) end)
    end
    
    task.wait(1.3)
    
    -- Complete fishing
    if finishRemote then 
        pcall(function() finishRemote:FireServer() end)
    end
end

local function DoSecureCycle()
    if inCooldown() then task.wait(1); return end
    
    -- Equip rod
    if equipRemote then 
        local ok = pcall(function() equipRemote:FireServer(1) end)
        if not ok then print("[Secure Mode] Failed to equip") end
    end
    
    -- Safe mode logic
    local usePerfect = math.random(1,100) <= AutoFish.config.safeModeChance
    
    -- Charge rod
    local timestamp = usePerfect and 9999999999 or (tick() + math.random())
    if rodRemote then
        local ok = pcall(function() rodRemote:InvokeServer(timestamp) end)
        if not ok then print("[Secure Mode] Failed to charge") end
    end
    
    task.wait(0.1)
    
    -- Mini-game
    local x = usePerfect and -1.238 or (math.random(-1000,1000)/1000)
    local y = usePerfect and 0.969 or (math.random(0,1000)/1000)
    
    if miniGameRemote then
        local ok = pcall(function() miniGameRemote:InvokeServer(x, y) end)
        if not ok then print("[Secure Mode] Failed minigame") end
    end
    
    task.wait(1.3)
    
    -- Complete fishing
    if finishRemote then 
        local ok = pcall(function() finishRemote:FireServer() end)
        if not ok then print("[Secure Mode] Failed to finish") end
    end
end

-- Main fishing runner
local function AutofishRunner(mySession)
    notify("AutoFish", "Started (mode: " .. AutoFish.config.mode .. ")")
    
    while AutoFish.config.enabled and sessionId == mySession do
        local ok, err = pcall(function()
            if AutoFish.config.mode == "secure" then 
                DoSecureCycle() 
            else 
                DoSmartCycle()
            end
        end)
        
        if not ok then
            warn("AutoFish cycle error:", err)
            task.wait(0.4 + math.random()*0.5)
        end
        
        -- Delay between cycles
        local delay = AutoFish.config.autoRecastDelay + (math.random()*0.2 - 0.1)
        if delay < 0.15 then delay = 0.15 end
        
        local elapsed = 0
        while elapsed < delay do
            if not AutoFish.config.enabled or sessionId ~= mySession then break end
            task.wait(0.05)
            elapsed = elapsed + 0.05
        end
    end
    
    notify("AutoFish", "Stopped")
end

-- Public API
function AutoFish.start()
    if AutoFish.config.enabled then return false end
    
    AutoFish.config.enabled = true
    sessionId = sessionId + 1
    
    task.spawn(AutofishRunner, sessionId)
    return true
end

function AutoFish.stop()
    if not AutoFish.config.enabled then return false end
    
    AutoFish.config.enabled = false
    return true
end

function AutoFish.setMode(mode)
    if mode and (mode:lower() == "smart" or mode:lower() == "secure") then
        AutoFish.config.mode = mode:lower()
        notify("AutoFish", "Mode changed to: " .. mode)
        return true
    end
    return false
end

function AutoFish.getStatus()
    return {
        enabled = AutoFish.config.enabled,
        mode = AutoFish.config.mode,
        sessionId = sessionId,
        security = Security
    }
end

-- New functions for ORION UI compatibility
function AutoFish.isRunning()
    return AutoFish.config.enabled
end

function AutoFish.setCastPower(power)
    if power and power >= 50 and power <= 100 then
        AutoFish.config.castPower = power
        notify("AutoFish", "Cast power set to: " .. power .. "%")
    end
end

function AutoFish.setAutoRecast(enabled)
    AutoFish.config.autoRecast = enabled
    notify("AutoFish", "Auto re-cast: " .. (enabled and "enabled" or "disabled"))
end

function AutoFish.setPerfectCatch(enabled)
    AutoFish.config.perfectCatch = enabled
    notify("AutoFish", "Perfect catch mode: " .. (enabled and "enabled" or "disabled"))
end

function AutoFish.setCastDelay(delay)
    if delay and delay >= 0.1 and delay <= 5.0 then
        AutoFish.config.autoRecastDelay = delay
        notify("AutoFish", "Cast delay set to: " .. delay .. "s")
    end
end

function AutoFish.setFishDetection(enabled)
    AutoFish.config.fishDetection = enabled
    notify("AutoFish", "Fish detection: " .. (enabled and "enabled" or "disabled"))
end

function AutoFish.setAutoCast(enabled)
    AutoFish.config.autoCast = enabled
    notify("AutoFish", "Auto cast: " .. (enabled and "enabled" or "disabled"))
end

function AutoFish.setSafeModeChance(chance)
    if chance and chance >= 0 and chance <= 100 then
        AutoFish.config.safeModeChance = chance
        notify("AutoFish", "Perfect catch rate set to: " .. chance .. "%")
    end
end

function AutoFish.init(modules, config)
    -- Store reference to other modules
    AutoFish.modules = modules
    
    if config then
        for key, value in pairs(config) do
            if AutoFish.config[key] ~= nil then
                AutoFish.config[key] = value
            end
        end
    end
    
    print("🎣 AutoFish module initialized")
    return true
end

function AutoFish.cleanup()
    AutoFish.stop()
    print("🧹 AutoFish module cleaned up")
end

return AutoFish
