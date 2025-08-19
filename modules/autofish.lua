-- AutoFish Core Module
-- Part of Modern AutoFish Modular System

local AutoFish = {}

-- Services
local Players = game:GetService("Players")
local Replicate    -- Smart mode logic - use perfectCatch toggle OR safeModeChance
    local usePerfect
    if AutoFish.config.perfectCatch then
        usePerfect = true  -- Force perfect if toggle enabled
        print("[Smart Mode] Perfect catch mode ENABLED - forcing perfect")
    else
        usePerfect = math.random(1,100) <= AutoFish.config.safeModeChance
        print("[Smart Mode] Using perfect catch rate:", AutoFish.config.safeModeChance .. "%")
    end
    
    local timestamp = usePerfect and GetServerTime() or GetServerTime() + math.random()*0.5
    
    print("[Smart Mode] Using perfect:", usePerfect, "Timestamp:", timestamp)age = game:GetService("ReplicatedStorage")
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
local function RefreshRemotes()
    print("[AutoFish] Refreshing remotes...")
    local rodRemote = ResolveRemote("RF/ChargeFishingRod")
    local miniGameRemote = ResolveRemote("RF/RequestFishingMinigameStarted")
    local finishRemote = ResolveRemote("RE/FishingCompleted")
    local equipRemote = ResolveRemote("RE/EquipToolFromHotbar")
    
    print("[AutoFish] Remote status:")
    print("  Rod Remote:", rodRemote and "✅ Found" or "❌ Not found")
    print("  MiniGame Remote:", miniGameRemote and "✅ Found" or "❌ Not found")
    print("  Finish Remote:", finishRemote and "✅ Found" or "❌ Not found")
    print("  Equip Remote:", equipRemote and "✅ Found" or "❌ Not found")
    
    return rodRemote, miniGameRemote, finishRemote, equipRemote
end

local rodRemote, miniGameRemote, finishRemote, equipRemote = RefreshRemotes()

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
    print("[Smart Mode] Starting fishing cycle...")
    
    -- Refresh remotes if needed
    if not rodRemote or not miniGameRemote or not finishRemote or not equipRemote then
        print("[Smart Mode] Refreshing remotes...")
        rodRemote, miniGameRemote, finishRemote, equipRemote = RefreshRemotes()
    end
    
    -- Equip rod with cast power
    if equipRemote then 
        local castPower = AutoFish.config.castPower or 75
        local ok = pcall(function() 
            -- Try with cast power parameter
            equipRemote:FireServer(1, castPower) 
        end)
        if not ok then
            -- Fallback without cast power
            ok = pcall(function() equipRemote:FireServer(1) end)
        end
        
        if ok then
            print("[Smart Mode] Rod equipped with cast power:", castPower)
        else
            print("[Smart Mode] Failed to equip rod")
            return false
        end
        task.wait(0.3)
    else
        print("[Smart Mode] No equip remote found")
        return false
    end
    
    -- Smart mode logic
    local usePerfect = math.random(1,100) <= AutoFish.config.safeModeChance
    local timestamp = usePerfect and GetServerTime() or GetServerTime() + math.random()*0.5
    
    print("[Smart Mode] Using perfect:", usePerfect, "Timestamp:", timestamp)
    
    -- Charge rod
    if rodRemote and rodRemote:IsA("RemoteFunction") then 
        local ok = pcall(function() rodRemote:InvokeServer(timestamp) end)
        if ok then
            print("[Smart Mode] Rod charged")
        else
            print("[Smart Mode] Failed to charge rod")
            return false
        end
    else
        print("[Smart Mode] No rod remote found or wrong type")
        return false
    end
    
    task.wait(0.3)
    
    -- Mini-game
    local x = usePerfect and -1.238 or (math.random(-1000,1000)/1000)
    local y = usePerfect and 0.969 or (math.random(0,1000)/1000)
    
    print("[Smart Mode] Mini-game coordinates:", x, y)
    
    if miniGameRemote and miniGameRemote:IsA("RemoteFunction") then 
        local ok = pcall(function() miniGameRemote:InvokeServer(x,y) end)
        if ok then
            print("[Smart Mode] Mini-game started")
        else
            print("[Smart Mode] Failed to start mini-game")
            return false
        end
    else
        print("[Smart Mode] No mini-game remote found or wrong type")
        return false
    end
    
    task.wait(2.0) -- Increased wait time for mini-game to complete
    
    -- Complete fishing
    if finishRemote then 
        local ok = pcall(function() finishRemote:FireServer() end)
        if ok then
            print("[Smart Mode] Fishing completed successfully!")
            return true
        else
            print("[Smart Mode] Failed to complete fishing")
            return false
        end
    else
        print("[Smart Mode] No finish remote found")
        return false
    end
end

local function DoSecureCycle()
    if inCooldown() then 
        print("[Secure Mode] In cooldown, waiting...")
        task.wait(1)
        return false
    end
    
    print("[Secure Mode] Starting fishing cycle...")
    
    -- Refresh remotes if needed
    if not rodRemote or not miniGameRemote or not finishRemote or not equipRemote then
        print("[Secure Mode] Refreshing remotes...")
        rodRemote, miniGameRemote, finishRemote, equipRemote = RefreshRemotes()
    end
    
    -- Equip rod with cast power
    if equipRemote then 
        local castPower = AutoFish.config.castPower or 75
        local ok = pcall(function() 
            -- Try with cast power parameter
            equipRemote:FireServer(1, castPower) 
        end)
        if not ok then
            -- Fallback without cast power
            ok = pcall(function() equipRemote:FireServer(1) end)
        end
        
        if ok then
            print("[Secure Mode] Rod equipped with cast power:", castPower)
        else
            print("[Secure Mode] Failed to equip rod")
            return false
        end
        task.wait(0.3)
    else
        print("[Secure Mode] No equip remote found")
        return false
    end
    
    -- Secure mode with smart perfect catch logic
    local usePerfect
    if AutoFish.config.perfectCatch then
        usePerfect = true  -- Force perfect if toggle enabled
        print("[Secure Mode] Perfect catch mode ENABLED - forcing perfect")
    else
        -- Secure mode uses lower perfect rate for safety
        local secureRate = math.min(AutoFish.config.safeModeChance * 0.7, 50) -- Max 50% in secure
        usePerfect = math.random(1,100) <= secureRate
        print("[Secure Mode] Using reduced perfect rate:", secureRate .. "%")
    end
    
    -- Use perfect or humanized timing
    local timestamp
    if usePerfect then
        timestamp = GetServerTime()
        print("[Secure Mode] Using perfect timestamp")
    else
        timestamp = GetServerTime() + math.random(1,5)*0.1
        print("[Secure Mode] Using humanized timestamp:", timestamp)
    end
    
    -- Charge rod
    if rodRemote and rodRemote:IsA("RemoteFunction") then 
        local ok = pcall(function() rodRemote:InvokeServer(timestamp) end)
        if ok then
            print("[Secure Mode] Rod charged")
        else
            print("[Secure Mode] Failed to charge rod")
            return false
        end
    else
        print("[Secure Mode] No rod remote found or wrong type")
        return false
    end
    
    task.wait(0.3 + math.random()*0.2)
    
    -- Mini-game with perfect/humanized coordinates
    local x, y
    if usePerfect then
        x, y = -1.238, 0.969  -- Perfect coordinates
        print("[Secure Mode] Using perfect coordinates")
    else
        x = math.random(-800,800)/1000
        y = math.random(200,900)/1000
        print("[Secure Mode] Using human-like coordinates:", x, y)
    end
    
    if miniGameRemote and miniGameRemote:IsA("RemoteFunction") then 
        local ok = pcall(function() miniGameRemote:InvokeServer(x,y) end)
        if ok then
            print("[Secure Mode] Mini-game started")
        else
            print("[Secure Mode] Failed to start mini-game")
            return false
        end
    else
        print("[Secure Mode] No mini-game remote found or wrong type")
        return false
    end
    
    task.wait(2.0 + math.random()*1.0) -- Extended wait with randomization
    
    -- Complete fishing
    if finishRemote then 
        local ok = pcall(function() finishRemote:FireServer() end)
        if ok then
            print("[Secure Mode] Fishing completed successfully!")
            return true
        else
            print("[Secure Mode] Failed to complete fishing")
            return false
        end
    else
        print("[Secure Mode] No finish remote found")
        return false
    end
end

-- Main fishing runner
local function AutofishRunner(mySession)
    notify("AutoFish", "Started (mode: " .. AutoFish.config.mode .. ")")
    
    local cycleCount = 0
    local successCount = 0
    
    while AutoFish.config.enabled and sessionId == mySession do
        local cycleSuccess = false
        local ok, err = pcall(function()
            if AutoFish.config.mode == "secure" then 
                cycleSuccess = DoSecureCycle() 
            else 
                cycleSuccess = DoSmartCycle()
            end
        end)
        
        cycleCount = cycleCount + 1
        
        if not ok then
            warn("AutoFish cycle error:", err)
            print(string.format("[AutoFish] Cycle %d failed with error", cycleCount))
            task.wait(0.4 + math.random()*0.5)
        elseif cycleSuccess then
            successCount = successCount + 1
            print(string.format("[AutoFish] Cycle %d completed successfully! (%d/%d successful)", cycleCount, successCount, cycleCount))
        else
            print(string.format("[AutoFish] Cycle %d failed (%d/%d successful)", cycleCount, successCount, cycleCount))
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
    
    print(string.format("[AutoFish] Session ended. Total cycles: %d, Successful: %d (%.1f%%)", 
        cycleCount, successCount, cycleCount > 0 and (successCount/cycleCount*100) or 0))
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
    
    -- Unequip rod when stopping
    local unequipRemote = ResolveRemote("RE/UnequipTool")
    if unequipRemote then
        pcall(function() 
            unequipRemote:FireServer()
            print("[AutoFish] Rod unequipped")
        end)
    else
        -- Alternative method: try to unequip using different remote
        if equipRemote then
            pcall(function()
                equipRemote:FireServer(0) -- 0 typically unequips
                print("[AutoFish] Rod unequipped (alternative method)")
            end)
        end
    end
    
    notify("AutoFish", "Stopped and rod unequipped")
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
