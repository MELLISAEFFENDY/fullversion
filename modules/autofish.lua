-- modules/autofish.lua
-- Enhanced AutoFish Module with Smart and Secure Modes
-- Based on working implementation from old.lua

local AutoFish = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- State Variables
local autofish = false
local autofishSession = 0
local currentMode = "smart" -- "smart" or "secure"
local perfectCast = false
local safeModeChance = 70
local autoRecastDelay = 0.4
local fishCaught = 0
local sessionStartTime = tick()

-- Remote References (using same method as old.lua)
local net = nil
local rodRemote = nil
local miniGameRemote = nil
local finishRemote = nil
local equipRemote = nil
local unequipRemote = nil

-- Remote helper function (copied from old.lua)
local function FindNet()
    local ok, netResult = pcall(function()
        local packages = ReplicatedStorage:FindFirstChild("Packages")
        if not packages then return nil end
        local idx = packages:FindFirstChild("_Index")
        if not idx then return nil end
        local sleit = idx:FindFirstChild("sleitnick_net@0.2.0")
        if not sleit then return nil end
        return sleit:FindFirstChild("net")
    end)
    return ok and netResult or nil
end

local function ResolveRemote(name)
    if not net then return nil end
    local ok, rem = pcall(function() return net:FindFirstChild(name) end)
    return ok and rem or nil
end

-- Initialize remotes
local function initializeRemotes()
    print("🔧 AutoFish: Initializing remotes...")
    net = FindNet()
    if not net then
        print("❌ AutoFish: Net folder not found")
        return false
    end
    
    rodRemote = ResolveRemote("RF/ChargeFishingRod")
    miniGameRemote = ResolveRemote("RF/RequestFishingMinigameStarted")
    finishRemote = ResolveRemote("RE/FishingCompleted")
    equipRemote = ResolveRemote("RE/EquipToolFromHotbar")
    unequipRemote = ResolveRemote("RE/UnequipToolFromHotbar")
    
    print("🔧 AutoFish: Rod Remote:", rodRemote and "✅" or "❌")
    print("🔧 AutoFish: MiniGame Remote:", miniGameRemote and "✅" or "❌")
    print("🔧 AutoFish: Finish Remote:", finishRemote and "✅" or "❌")
    print("🔧 AutoFish: Equip Remote:", equipRemote and "✅" or "❌")
    print("🔧 AutoFish: Unequip Remote:", unequipRemote and "✅" or "❌")
    
    return rodRemote and miniGameRemote and finishRemote and equipRemote
end

-- Timing functions (based on old.lua)
local function GetRealisticTiming(phase)
    if phase == "charging" then
        return 0.4 + math.random() * 0.3 -- 0.4-0.7 seconds
    elseif phase == "casting" then
        return 0.2 + math.random() * 0.2 -- 0.2-0.4 seconds
    elseif phase == "waiting" then
        return 1.0 + math.random() * 2.0 -- 1.0-3.0 seconds
    elseif phase == "reeling" then
        return 0.3 + math.random() * 0.4 -- 0.3-0.7 seconds
    else
        return 0.5
    end
end

-- Perfect timing calculation (server time sync)
local function GetServerTime()
    return workspace:GetServerTimeNow()
end

-- Smart Fishing Cycle (high performance)
local function DoSmartCycle()
    print("🎣 AutoFish: Starting Smart Cycle")
    
    -- Phase 1: Equip rod
    if equipRemote then 
        local success = pcall(function() 
            equipRemote:FireServer(1) 
        end)
        if not success then
            print("❌ AutoFish: Failed to equip rod")
            return false
        end
        task.wait(GetRealisticTiming("charging"))
    end
    
    -- Phase 2: Charge rod
    local usePerfect = perfectCast or (math.random(1,100) <= safeModeChance)
    local timestamp = usePerfect and GetServerTime() or GetServerTime() + math.random()*0.5
    
    if rodRemote then
        local success = pcall(function() 
            if rodRemote:IsA("RemoteFunction") then
                rodRemote:InvokeServer(timestamp)
            else
                rodRemote:FireServer(timestamp)
            end
        end)
        if not success then
            print("❌ AutoFish: Failed to charge rod")
            return false
        end
    end
    
    task.wait(GetRealisticTiming("charging"))
    
    -- Phase 3: Cast (minigame)
    local x = usePerfect and -1.238 or (math.random(-1000,1000)/1000)
    local y = usePerfect and 0.969 or (math.random(0,1000)/1000)
    
    if miniGameRemote then
        local success = pcall(function() 
            if miniGameRemote:IsA("RemoteFunction") then
                miniGameRemote:InvokeServer(x, y)
            else
                miniGameRemote:FireServer(x, y)
            end
        end)
        if not success then
            print("❌ AutoFish: Failed to cast")
            return false
        end
    end
    
    task.wait(GetRealisticTiming("casting"))
    
    -- Phase 4: Wait for fish
    task.wait(GetRealisticTiming("waiting"))
    
    -- Phase 5: Complete fishing
    if finishRemote then
        local success = pcall(function() 
            finishRemote:FireServer()
        end)
        if not success then
            print("❌ AutoFish: Failed to finish")
            return false
        end
    end
    
    task.wait(GetRealisticTiming("reeling"))
    
    fishCaught = fishCaught + 1
    print("✅ AutoFish: Smart cycle completed - Fish caught:", fishCaught)
    return true
end

-- Secure Fishing Cycle (safe mode)
local function DoSecureCycle()
    print("🛡️ AutoFish: Starting Secure Cycle")
    
    -- Phase 1: Equip rod
    if equipRemote then 
        local success = pcall(function() 
            equipRemote:FireServer(1) 
        end)
        if not success then
            print("❌ AutoFish: Failed to equip rod (secure)")
            return false
        end
        task.wait(0.5 + math.random() * 0.3) -- Random delay for security
    end
    
    -- Phase 2: Charge rod with randomization
    local usePerfect = math.random(1,100) <= safeModeChance
    local timestamp = usePerfect and 9999999999 or (tick() + math.random())
    
    if rodRemote then
        local success = pcall(function() 
            if rodRemote:IsA("RemoteFunction") then
                rodRemote:InvokeServer(timestamp)
            else
                rodRemote:FireServer(timestamp)
            end
        end)
        if not success then
            print("❌ AutoFish: Failed to charge rod (secure)")
            return false
        end
    end
    
    task.wait(0.6 + math.random() * 0.4) -- Variable delay
    
    -- Phase 3: Cast with realistic variance
    local x = usePerfect and -1.238 or (math.random(-800,800)/1000)
    local y = usePerfect and 0.969 or (math.random(200,950)/1000)
    
    if miniGameRemote then
        local success = pcall(function() 
            if miniGameRemote:IsA("RemoteFunction") then
                miniGameRemote:InvokeServer(x, y)
            else
                miniGameRemote:FireServer(x, y)
            end
        end)
        if not success then
            print("❌ AutoFish: Failed to cast (secure)")
            return false
        end
    end
    
    task.wait(0.3 + math.random() * 0.3)
    
    -- Phase 4: Extended wait for security
    task.wait(1.5 + math.random() * 1.0)
    
    -- Phase 5: Complete fishing
    if finishRemote then
        local success = pcall(function() 
            finishRemote:FireServer()
        end)
        if not success then
            print("❌ AutoFish: Failed to finish (secure)")
            return false
        end
    end
    
    task.wait(0.4 + math.random() * 0.3)
    
    fishCaught = fishCaught + 1
    print("✅ AutoFish: Secure cycle completed - Fish caught:", fishCaught)
    return true
end

-- Main AutoFish Runner
local function AutofishRunner(mySession)
    print("🚀 AutoFish: Runner started (Session:", mySession, "Mode:", currentMode, ")")
    
    while autofish and autofishSession == mySession do
        local success = false
        local cycleError = nil
        
        local ok, err = pcall(function()
            if currentMode == "secure" then
                success = DoSecureCycle()
            else
                success = DoSmartCycle()
            end
        end)
        
        if not ok then
            cycleError = err
            print("❌ AutoFish: Cycle error:", err)
        end
        
        -- Handle cycle failures
        if not success then
            print("⚠️ AutoFish: Cycle failed, retrying in 2 seconds...")
            task.wait(2)
            continue
        end
        
        -- Smart delay between cycles
        local baseDelay = autoRecastDelay
        local delay = baseDelay
        
        if currentMode == "secure" then
            delay = 0.8 + math.random() * 0.6 -- 0.8-1.4 seconds for security
        else
            delay = baseDelay + (math.random() * 0.3 - 0.15) -- ±0.15 variance
        end
        
        if delay < 0.2 then delay = 0.2 end -- Minimum safe delay
        
        local elapsed = 0
        while elapsed < delay and autofish and autofishSession == mySession do
            task.wait(0.1)
            elapsed = elapsed + 0.1
        end
    end
    
    print("🛑 AutoFish: Runner stopped (Session:", mySession, ")")
end

-- AutoFish Functions
function AutoFish.start()
    if autofish then
        print("⚠️ AutoFish: Already running")
        return false
    end
    
    -- Initialize remotes if not done
    if not net then
        if not initializeRemotes() then
            print("❌ AutoFish: Failed to initialize remotes")
            return false
        end
    end
    
    autofish = true
    autofishSession = autofishSession + 1
    sessionStartTime = tick()
    fishCaught = 0
    
    print("✅ AutoFish: Started in", currentMode, "mode")
    
    task.spawn(function()
        AutofishRunner(autofishSession)
    end)
    
    return true
end

function AutoFish.stop()
    if not autofish then
        print("⚠️ AutoFish: Not running")
        return false
    end
    
    autofish = false
    autofishSession = autofishSession + 1
    
    -- Unequip rod when stopping
    if unequipRemote then
        pcall(function()
            unequipRemote:FireServer()
        end)
    end
    
    print("🛑 AutoFish: Stopped")
    
    local sessionTime = tick() - sessionStartTime
    local fishPerHour = sessionTime > 0 and math.floor((fishCaught / sessionTime) * 3600) or 0
    print("📊 AutoFish: Session stats - Fish:", fishCaught, "Time:", math.floor(sessionTime), "seconds, Rate:", fishPerHour, "fish/hour")
    
    return true
end

function AutoFish.isRunning()
    return autofish
end

function AutoFish.setMode(mode)
    if mode == "smart" or mode == "secure" then
        currentMode = mode
        print("🔧 AutoFish: Mode changed to", mode)
        return true
    else
        print("❌ AutoFish: Invalid mode:", mode)
        return false
    end
end

function AutoFish.getMode()
    return currentMode
end

function AutoFish.setCastPower(power)
    -- This is handled by the timing system
    print("🔧 AutoFish: Cast power concept noted:", power)
end

function AutoFish.setCastDelay(delay)
    autoRecastDelay = delay
    print("🔧 AutoFish: Recast delay set to:", delay)
end

function AutoFish.setPerfectCast(enabled)
    perfectCast = enabled
    print("🔧 AutoFish: Perfect cast:", enabled and "enabled" or "disabled")
end

function AutoFish.setSafeModeChance(chance)
    safeModeChance = chance
    print("🔧 AutoFish: Safe mode chance set to:", chance, "%")
end

function AutoFish.getStats()
    local sessionTime = tick() - sessionStartTime
    local fishPerHour = sessionTime > 0 and math.floor((fishCaught / sessionTime) * 3600) or 0
    
    return {
        fishCaught = fishCaught,
        sessionTime = sessionTime,
        fishPerHour = fishPerHour,
        mode = currentMode,
        isRunning = autofish
    }
end

-- Initialize function required by main system
function AutoFish.initialize()
    print("🎣 AutoFish: Module initializing...")
    
    local success = initializeRemotes()
    if success then
        print("✅ AutoFish: Initialization complete - All remotes loaded")
    else
        print("⚠️ AutoFish: Initialization warning - Some remotes missing, will retry on start")
    end
    
    return true
end

-- Configuration object for compatibility
AutoFish.config = {
    enabled = false,
    mode = "smart",
    safeModeChance = 70,
    autoRecastDelay = 0.4,
    perfectCast = false
}

-- Compatibility functions
function AutoFish.setAutoCast(enabled)
    print("🔧 AutoFish: Auto cast:", enabled and "enabled" or "disabled")
end

function AutoFish.setFishDetection(enabled)
    print("🔧 AutoFish: Fish detection:", enabled and "enabled" or "disabled")
end

function AutoFish.setAutoRecast(enabled)
    print("🔧 AutoFish: Auto recast:", enabled and "enabled" or "disabled")
end

print("🎣 AutoFish: Module loaded successfully")

return AutoFish
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
function AutoFish.initialize()
    print("🎣 AutoFish: Initializing...")
    -- Refresh remotes on initialization
    rodRemote, miniGameRemote, finishRemote, equipRemote = RefreshRemotes()
    print("🎣 AutoFish: Initialization complete")
end

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
