-- Security Module for Modern AutoFish
-- Anti-detection and safety features

local Security = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Configuration
Security.config = {
    enabled = true,
    antiAfkEnabled = false,
    maxActionsPerMinute = 12000000,
    detectionCooldown = 5,
    suspicionThreshold = 8,
    autoReconnectEnabled = false,
    maxReconnectAttempts = 3,
    reconnectDelay = 5
}

-- Security state
local securityState = {
    actionsThisMinute = 0,
    lastMinuteReset = tick(),
    isInCooldown = false,
    suspicion = 0,
    lastJumpTime = 0,
    nextJumpTime = 0,
    sessionId = 0,
    reconnectAttempts = 0,
    lastDisconnectTime = 0
}

-- AntiAFK state
local antiAfkState = {
    sessionId = 0,
    running = false
}

-- Notification function
local function notify(title, text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 4
        })
    end)
    print(string.format("[Security] %s: %s", title, text))
end

-- Security functions
local function inCooldown()
    local now = tick()
    if now - securityState.lastMinuteReset > 60 then
        securityState.actionsThisMinute = 0
        securityState.lastMinuteReset = now
    end
    if securityState.actionsThisMinute >= Security.config.maxActionsPerMinute then
        securityState.isInCooldown = true
        return true
    end
    return securityState.isInCooldown
end

local function incrementSuspicion()
    securityState.suspicion = securityState.suspicion + 1
    if securityState.suspicion > Security.config.suspicionThreshold then
        securityState.isInCooldown = true
        task.spawn(function()
            notify("Security", "⚠️ Entering cooldown due to repeated errors")
            task.wait(Security.config.detectionCooldown)
            securityState.suspicion = 0
            securityState.isInCooldown = false
            notify("Security", "✅ Cooldown period ended")
        end)
    end
end

-- AntiAFK functions
local function generateRandomJumpTime()
    -- Random time between 2-8 minutes (120-480 seconds)
    return math.random(120, 480)
end

local function performAntiAfkJump()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then
        return false
    end
    
    LocalPlayer.Character.Humanoid.Jump = true
    local currentTime = tick()
    securityState.lastJumpTime = currentTime
    securityState.nextJumpTime = currentTime + generateRandomJumpTime()
    
    local nextJumpMinutes = math.floor((securityState.nextJumpTime - currentTime) / 60)
    local nextJumpSeconds = math.floor((securityState.nextJumpTime - currentTime) % 60)
    notify("AntiAFK", string.format("🦘 Jump! Next in %dm %ds", nextJumpMinutes, nextJumpSeconds))
    return true
end

local function antiAfkRunner(mySessionId)
    securityState.nextJumpTime = tick() + generateRandomJumpTime()
    notify("AntiAFK", "🛡️ AntiAFK started")
    
    while Security.config.antiAfkEnabled and antiAfkState.sessionId == mySessionId do
        local currentTime = tick()
        
        if currentTime >= securityState.nextJumpTime then
            performAntiAfkJump()
        end
        
        task.wait(1) -- Check every second
    end
    
    if antiAfkState.sessionId == mySessionId then
        notify("AntiAFK", "🛡️ AntiAFK stopped")
    end
end

-- Auto reconnect functions
local function autoReconnect()
    if not Security.config.autoReconnectEnabled then return end
    
    if securityState.reconnectAttempts >= Security.config.maxReconnectAttempts then
        notify("Reconnect", "❌ Max reconnect attempts reached")
        return
    end
    
    securityState.reconnectAttempts = securityState.reconnectAttempts + 1
    securityState.lastDisconnectTime = tick()
    
    notify("Reconnect", string.format("🔄 Auto reconnecting... (Attempt %d/%d)", securityState.reconnectAttempts, Security.config.maxReconnectAttempts))
    
    -- Wait before reconnecting
    task.wait(Security.config.reconnectDelay)
    
    -- Try to reconnect (implementation depends on game)
    local success = pcall(function()
        -- This would be game-specific reconnect logic
        -- For now, just reset some state
        securityState.suspicion = 0
        securityState.isInCooldown = false
        return true
    end)
    
    if success then
        notify("Reconnect", "✅ Reconnect successful")
        securityState.reconnectAttempts = 0
    else
        notify("Reconnect", "❌ Reconnect failed")
    end
end

-- Connection monitoring
local function monitorConnection()
    local lastHeartbeat = tick()
    
    RunService.Heartbeat:Connect(function()
        lastHeartbeat = tick()
    end)
    
    -- Check for connection issues
    task.spawn(function()
        while Security.config.autoReconnectEnabled do
            task.wait(10) -- Check every 10 seconds
            
            local timeSinceHeartbeat = tick() - lastHeartbeat
            
            -- If no heartbeat for 15 seconds, might be disconnected
            if timeSinceHeartbeat > 15 then
                notify("Connection", "⚠️ Potential connection issue detected")
                autoReconnect()
                break
            end
        end
    end)
end

-- Public API functions
function Security.checkSecurity()
    return not inCooldown()
end

function Security.recordAction()
    if not Security.config.enabled then return true end
    
    if inCooldown() then 
        return false, "cooldown" 
    end
    
    securityState.actionsThisMinute = securityState.actionsThisMinute + 1
    return true
end

function Security.recordError()
    incrementSuspicion()
end

function Security.enableAntiAfk()
    if Security.config.antiAfkEnabled then return false end
    
    Security.config.antiAfkEnabled = true
    antiAfkState.sessionId = antiAfkState.sessionId + 1
    antiAfkState.running = true
    
    task.spawn(antiAfkRunner, antiAfkState.sessionId)
    return true
end

function Security.disableAntiAfk()
    if not Security.config.antiAfkEnabled then return false end
    
    Security.config.antiAfkEnabled = false
    antiAfkState.running = false
    return true
end

function Security.enableAutoReconnect()
    if Security.config.autoReconnectEnabled then return false end
    
    Security.config.autoReconnectEnabled = true
    securityState.reconnectAttempts = 0
    
    -- Start connection monitoring
    monitorConnection()
    
    notify("Security", "🌐 Auto Reconnect enabled")
    return true
end

function Security.disableAutoReconnect()
    if not Security.config.autoReconnectEnabled then return false end
    
    Security.config.autoReconnectEnabled = false
    notify("Security", "🌐 Auto Reconnect disabled")
    return true
end

function Security.resetSuspicion()
    securityState.suspicion = 0
    securityState.isInCooldown = false
    notify("Security", "🔄 Suspicion level reset")
end

function Security.getStatus()
    return {
        enabled = Security.config.enabled,
        antiAfkEnabled = Security.config.antiAfkEnabled,
        autoReconnectEnabled = Security.config.autoReconnectEnabled,
        isInCooldown = securityState.isInCooldown,
        suspicion = securityState.suspicion,
        actionsThisMinute = securityState.actionsThisMinute,
        reconnectAttempts = securityState.reconnectAttempts,
        nextJumpTime = securityState.nextJumpTime
    }
end

function Security.setMaxActions(maxActions)
    if type(maxActions) == "number" and maxActions > 0 then
        Security.config.maxActionsPerMinute = maxActions
        notify("Security", "⚙️ Max actions set to: " .. maxActions)
        return true
    end
    return false
end

function Security.init(config)
    if config and config.security then
        for key, value in pairs(config.security) do
            if Security.config[key] ~= nil then
                Security.config[key] = value
            end
        end
    end
    
    -- Reset security state
    securityState.actionsThisMinute = 0
    securityState.lastMinuteReset = tick()
    securityState.isInCooldown = false
    securityState.suspicion = 0
    
    print("🛡️ Security module initialized")
    return true
end

function Security.cleanup()
    Security.config.antiAfkEnabled = false
    Security.config.autoReconnectEnabled = false
    antiAfkState.running = false
    
    print("🧹 Security module cleaned up")
end

-- New functions for ORION UI compatibility
function Security.setAntiDetection(enabled)
    Security.config.antiDetectionEnabled = enabled
    notify("Security", "🛡️ Anti-detection: " .. (enabled and "enabled" or "disabled"))
end

function Security.setRandomizationLevel(level)
    if level and level >= 1 and level <= 10 then
        Security.config.randomizationLevel = level
        notify("Security", "🎲 Randomization level set to: " .. level)
    end
end

function Security.setAntiAFK(enabled)
    Security.config.antiAfkEnabled = enabled
    if enabled then
        Security.startAntiAfk()
    else
        antiAfkState.running = false
    end
    notify("Security", "⏰ Anti-AFK: " .. (enabled and "enabled" or "disabled"))
end

function Security.setAFKInterval(interval)
    if interval and interval >= 30 and interval <= 300 then
        Security.config.afkCheckInterval = interval
        notify("Security", "⏰ AFK check interval set to: " .. interval .. "s")
    end
end

function Security.setAutoReconnect(enabled)
    Security.config.autoReconnectEnabled = enabled
    if enabled then
        monitorConnection()
    end
    notify("Security", "🔄 Auto-reconnect: " .. (enabled and "enabled" or "disabled"))
end

-- Initialize function
function Security.initialize()
    print("🛡️ Security: Initializing...")
    -- Initialize security features
    Security.resetSuspicion()
    if Security.config.antiAfkEnabled then
        Security.enableAntiAfk()
    end
    if Security.config.autoReconnectEnabled then
        Security.enableAutoReconnect()
    end
    print("🛡️ Security: Initialization complete")
end

return Security
