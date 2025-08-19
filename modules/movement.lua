-- Movement Enhancement Module
-- Part of Modern AutoFish Modular System

local Movement = {}

-- Configuration
Movement.config = {
    floatEnabled = false,
    noClipEnabled = false,
    spinnerEnabled = false,
    floatHeight = 16,
    spinnerSpeed = 2,
    spinnerDirection = 1
}

-- Internal state
local connections = {}
local originalProperties = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- Notification function
local function notify(title, text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 3
        })
    end)
    print(string.format("[Movement] %s: %s", title, text))
end

-- Float functions
function Movement.enableFloat()
    if Movement.config.floatEnabled then return false end
    
    local character = LocalPlayer.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return false end
    
    Movement.config.floatEnabled = true
    
    -- Implementation here (excerpt from your original code)
    notify("Float", "🚀 Float mode enabled!")
    return true
end

function Movement.disableFloat()
    if not Movement.config.floatEnabled then return false end
    
    Movement.config.floatEnabled = false
    
    -- Cleanup connections
    for name, connection in pairs(connections) do
        if name:find("float") then
            connection:Disconnect()
            connections[name] = nil
        end
    end
    
    notify("Float", "🛑 Float mode disabled")
    return true
end

-- NoClip functions
function Movement.enableNoClip()
    -- Implementation here
    Movement.config.noClipEnabled = true
    notify("NoClip", "👻 No Clip enabled!")
    return true
end

function Movement.disableNoClip()
    Movement.config.noClipEnabled = false
    notify("NoClip", "🛑 No Clip disabled")
    return true
end

-- Spinner functions  
function Movement.enableAutoSpinner()
    Movement.config.spinnerEnabled = true
    notify("Spinner", "🌪️ Auto Spinner enabled!")
    return true
end

function Movement.disableAutoSpinner()
    Movement.config.spinnerEnabled = false
    notify("Spinner", "🛑 Auto Spinner disabled")
    return true
end

-- Public API
function Movement.init(config)
    if config and config.movement then
        for key, value in pairs(config.movement) do
            if Movement.config[key] ~= nil then
                Movement.config[key] = value
            end
        end
    end
    
    print("🚀 Movement module initialized")
    return true
end

function Movement.cleanup()
    Movement.disableFloat()
    Movement.disableNoClip()
    Movement.disableAutoSpinner()
    
    for _, connection in pairs(connections) do
        if connection then
            connection:Disconnect()
        end
    end
    connections = {}
    
    print("🧹 Movement module cleaned up")
end

function Movement.getConfig()
    return Movement.config
end

function Movement.setConfig(newConfig)
    for key, value in pairs(newConfig) do
        if Movement.config[key] ~= nil then
            Movement.config[key] = value
        end
    end
end

-- New functions for ORION UI compatibility
function Movement.setFloat(enabled)
    if enabled then
        Movement.enableFloat()
    else
        Movement.disableFloat()
    end
end

function Movement.setNoClip(enabled)
    if enabled then
        Movement.enableNoClip()
    else
        Movement.disableNoClip()
    end
end

function Movement.setAutoSpinner(enabled)
    if enabled then
        Movement.enableAutoSpinner()
    else
        Movement.disableAutoSpinner()
    end
end

function Movement.setSpinnerSpeed(speed)
    if speed and speed >= 1 and speed <= 20 then
        Movement.config.spinnerSpeed = speed
        notify("Movement", "Spinner speed set to: " .. speed .. "x")
    end
end

-- Speed and Jump Power functions
function Movement.setSpeed(speed)
    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        humanoid.WalkSpeed = speed
        notify("Movement", "Walk speed set to: " .. speed)
    end)
end

function Movement.setJumpPower(power)
    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        humanoid.JumpPower = power
        notify("Movement", "Jump power set to: " .. power)
    end)
end

-- Store original values for restoration
function Movement.storeOriginalValues()
    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        if not originalProperties.WalkSpeed then
            originalProperties.WalkSpeed = humanoid.WalkSpeed
        end
        if not originalProperties.JumpPower then
            originalProperties.JumpPower = humanoid.JumpPower
        end
    end)
end

-- Auto-store values when character spawns
local function onCharacterAdded(character)
    character:WaitForChild("Humanoid")
    wait(1) -- Wait for everything to load
    Movement.storeOriginalValues()
end

function Movement.initialize()
    print("🏃 Movement: Initializing...")
    Movement.storeOriginalValues()
    print("🏃 Movement: Initialization complete")
end

if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

return Movement
