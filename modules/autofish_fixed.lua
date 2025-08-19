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

local function ResolveRemote(path)
    local net = FindNet()
    if not net then return nil end
    
    local ok, remote = pcall(function()
        local parts = path:split("/")
        local current = net
        for i, part in ipairs(parts) do
            current = current:FindFirstChild(part)
            if not current then return nil end
        end
        return current
    end)
    return ok and remote or nil
end

-- Get server time
local function GetServerTime()
    return workspace:GetServerTimeNow()
end

-- Remotes
local rodRemote, miniGameRemote, finishRemote, equipRemote

-- Refresh remotes function
local function RefreshRemotes()
    local rod = ResolveRemote("RF/RequestFishingRodCast")
    local miniGame = ResolveRemote("RF/RequestFishingMinigameStarted") 
    local finish = ResolveRemote("RE/FishingCompleteNotification")
    local equip = ResolveRemote("RE/ChangeToolEvent")
    
    print("[AutoFish] Remote status:")
    print("  Rod:", rod and "✓" or "✗")
    print("  MiniGame:", miniGame and "✓" or "✗") 
    print("  Finish:", finish and "✓" or "✗")
    print("  Equip:", equip and "✓" or "✗")
    
    return rod, miniGame, finish, equip
end

-- Initialize remotes
rodRemote, miniGameRemote, finishRemote, equipRemote = RefreshRemotes()

-- Notification helper
local function notify(title, text)
    if StarterGui then
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 3
        })
    end
end

-- Security functions
local function resetActionsIfNeeded()
    local now = tick()
    if now - Security.lastMinuteReset >= 60 then
        Security.actionsThisMinute = 0
        Security.lastMinuteReset = now
    end
end

local function isActionAllowed()
    resetActionsIfNeeded()
    return Security.actionsThisMinute < AutoFish.config.maxActionsPerMinute
end

local function recordAction()
    Security.actionsThisMinute = Security.actionsThisMinute + 1
end

local function inCooldown()
    return Security.isInCooldown or tick() - Security.lastMinuteReset < AutoFish.config.detectionCooldown
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
    
    -- Smart mode logic - use perfectCatch toggle OR safeModeChance
    local usePerfect
    if AutoFish.config.perfectCatch then
        usePerfect = true  -- Force perfect if toggle enabled
        print("[Smart Mode] Perfect catch mode ENABLED - forcing perfect")
    else
        usePerfect = math.random(1,100) <= AutoFish.config.safeModeChance
        print("[Smart Mode] Using perfect catch rate:", AutoFish.config.safeModeChance .. "%")
    end
    
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

-- Main runner
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

-- Debug function
function AutoFish.getStatus()
    return {
        enabled = AutoFish.config.enabled,
        mode = AutoFish.config.mode,
        sessionId = sessionId,
        remotes = {
            rod = rodRemote ~= nil,
            miniGame = miniGameRemote ~= nil,
            finish = finishRemote ~= nil,
            equip = equipRemote ~= nil
        }
    }
end

return AutoFish
