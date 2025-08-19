-- 📊 Fish Statistics Tracker
-- Real-time fish catch monitoring and analytics
-- Berdasarkan remote events yang terdeteksi

local FishTracker = {}

-- 📊 Update Callback
local updateCallback = nil

-- 📊 Statistics Storage
local Stats = {
    fishCaught = 0,
    totalValue = 0,
    sessionStart = tic-- 🛑 Cleanup
function FishTracker.cleanup()
    for name, connection in pairs(RemoteConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    RemoteConnections = {}
    print("🛑 Fish Tracker: Cleaned up")
end

-- Export module
return FishTrackerlastFishTime = 0,
    rareCount = 0,
    commonCount = 0,
    fishTypes = {},
    averageTime = 0,
    bestFish = {name = "None", value = 0}
}

-- 🎣 Remote Events for Fish Tracking
local RemoteConnections = {}

-- 🔧 Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- 📡 Initialize Fish Monitoring
function FishTracker.initialize()
    print("📊 Fish Tracker: Initializing...")
    
    -- Try to hook into FishCaught event
    pcall(function()
        local fishCaughtEvent = ReplicatedStorage:FindFirstChild("Packages")
        if fishCaughtEvent then
            fishCaughtEvent = fishCaughtEvent:FindFirstChild("_Index")
            if fishCaughtEvent then
                fishCaughtEvent = fishCaughtEvent:FindFirstChild("sleitnick_net@0.2.0")
                if fishCaughtEvent then
                    fishCaughtEvent = fishCaughtEvent:FindFirstChild("net")
                    if fishCaughtEvent then
                        fishCaughtEvent = fishCaughtEvent:FindFirstChild("RE")
                        if fishCaughtEvent then
                            fishCaughtEvent = fishCaughtEvent:FindFirstChild("FishCaught")
                            
                            if fishCaughtEvent then
                                RemoteConnections.FishCaught = fishCaughtEvent.OnClientEvent:Connect(function(...)
                                    FishTracker.onFishCaught(...)
                                end)
                                print("✅ Fish Tracker: Hooked into FishCaught event")
                            end
                        end
                    end
                end
            end
        end
    end)
    
    -- Try to hook into TextNotification for fish notifications
    pcall(function()
        local textNotificationEvent = ReplicatedStorage:FindFirstChild("Packages")
        if textNotificationEvent then
            textNotificationEvent = textNotificationEvent:FindFirstChild("_Index")
            if textNotificationEvent then
                textNotificationEvent = textNotificationEvent:FindFirstChild("sleitnick_net@0.2.0")
                if textNotificationEvent then
                    textNotificationEvent = textNotificationEvent:FindFirstChild("net")
                    if textNotificationEvent then
                        textNotificationEvent = textNotificationEvent:FindFirstChild("RE")
                        if textNotificationEvent then
                            textNotificationEvent = textNotificationEvent:FindFirstChild("TextNotification")
                            
                            if textNotificationEvent then
                                RemoteConnections.TextNotification = textNotificationEvent.OnClientEvent:Connect(function(message)
                                    FishTracker.onTextNotification(message)
                                end)
                                print("✅ Fish Tracker: Hooked into TextNotification event")
                            end
                        end
                    end
                end
            end
        end
    end)
    
    -- Fallback: Monitor player's backpack for new fish
    spawn(function()
        FishTracker.monitorBackpack()
    end)
    
    -- Alternative: Monitor fishing animation states
    spawn(function()
        FishTracker.monitorFishingStates()
    end)
    
    print("✅ Fish Tracker: Initialization complete")
end

-- 🎣 Handle Fish Caught Event
function FishTracker.onFishCaught(fishData)
    pcall(function()
        print("🐟 Fish caught event detected:", fishData)
        
        local currentTime = tick()
        Stats.fishCaught = Stats.fishCaught + 1
        Stats.lastFishTime = currentTime
        
        -- Calculate time between catches
        if Stats.fishCaught > 1 then
            local timeDiff = currentTime - Stats.lastFishTime
            Stats.averageTime = (Stats.averageTime + timeDiff) / 2
        end
        
        -- Process fish data if available
        if type(fishData) == "table" then
            local fishName = fishData.name or fishData.Name or "Unknown Fish"
            local fishValue = fishData.value or fishData.Value or 100
            local fishRarity = fishData.rarity or fishData.Rarity or "Common"
            
            -- Update statistics
            Stats.totalValue = Stats.totalValue + fishValue
            
            -- Track fish types
            Stats.fishTypes[fishName] = (Stats.fishTypes[fishName] or 0) + 1
            
            -- Track rarity
            if fishRarity == "Rare" or fishRarity == "Epic" or fishRarity == "Legendary" then
                Stats.rareCount = Stats.rareCount + 1
            else
                Stats.commonCount = Stats.commonCount + 1
            end
            
            -- Track best fish
            if fishValue > Stats.bestFish.value then
                Stats.bestFish = {name = fishName, value = fishValue}
            end
            
            print(string.format("🎣 Caught: %s (%s) - Value: %d", fishName, fishRarity, fishValue))
        else
            -- Generic fish caught
            Stats.totalValue = Stats.totalValue + 100
            Stats.commonCount = Stats.commonCount + 1
            print("🐟 Fish caught (generic)")
        end
        
        -- Notify UI update using callback system
        if updateCallback then
            updateCallback(FishTracker.getStats())
        end
        
        -- Legacy notification method
        if getgenv().RayfieldUI and getgenv().RayfieldUI.updateFishStats then
            getgenv().RayfieldUI.updateFishStats(Stats)
        end
    end)
end

-- 📝 Handle Text Notification Event
function FishTracker.onTextNotification(message)
    pcall(function()
        if type(message) == "string" then
            -- Look for fish-related notifications
            if message:find("caught") or message:find("fish") or message:find("🐟") then
                print("🎣 Fish notification:", message)
                
                -- Increment basic counter
                Stats.fishCaught = Stats.fishCaught + 1
                Stats.lastFishTime = tick()
                Stats.totalValue = Stats.totalValue + 100 -- Estimated value
                Stats.commonCount = Stats.commonCount + 1
                
                -- Notify UI update using callback system
                if updateCallback then
                    updateCallback(FishTracker.getStats())
                end
                
                -- Legacy notification method
                if getgenv().RayfieldUI and getgenv().RayfieldUI.updateFishStats then
                    getgenv().RayfieldUI.updateFishStats(Stats)
                end
            end
        end
    end)
end

-- 🎒 Monitor Backpack for New Items
function FishTracker.monitorBackpack()
    if not LocalPlayer then return end
    
    local lastItemCount = 0
    
    while true do
        wait(2)
        pcall(function()
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            if backpack then
                local currentItemCount = #backpack:GetChildren()
                
                -- Check if new items were added
                if currentItemCount > lastItemCount then
                    local newItems = currentItemCount - lastItemCount
                    
                    -- Assume new items are fish (simplified)
                    Stats.fishCaught = Stats.fishCaught + newItems
                    Stats.totalValue = Stats.totalValue + (newItems * 100)
                    Stats.commonCount = Stats.commonCount + newItems
                    Stats.lastFishTime = tick()
                    
                    print(string.format("🎒 Detected %d new items in backpack", newItems))
                    
                    -- Notify UI update using callback system
                    if updateCallback then
                        updateCallback(FishTracker.getStats())
                    end
                    
                    -- Legacy notification method
                    if getgenv().RayfieldUI and getgenv().RayfieldUI.updateFishStats then
                        getgenv().RayfieldUI.updateFishStats(Stats)
                    end
                end
                
                lastItemCount = currentItemCount
            end
        end)
    end
end

-- 🎣 Monitor Fishing Animation States
function FishTracker.monitorFishingStates()
    if not LocalPlayer then return end
    
    local lastFishingState = false
    
    while true do
        wait(1)
        pcall(function()
            local character = LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    -- Check for fishing animations or tools
                    local fishingTool = character:FindFirstChildOfClass("Tool")
                    local isCurrentlyFishing = false
                    
                    if fishingTool and (fishingTool.Name:find("Rod") or fishingTool.Name:find("rod")) then
                        isCurrentlyFishing = true
                    end
                    
                    -- Detect fishing completion (was fishing, now not)
                    if lastFishingState and not isCurrentlyFishing then
                        -- Fishing likely completed, assume fish caught
                        Stats.fishCaught = Stats.fishCaught + 1
                        Stats.totalValue = Stats.totalValue + 100
                        Stats.commonCount = Stats.commonCount + 1
                        Stats.lastFishTime = tick()
                        
                        print("🎣 Fishing completion detected")
                        
                        -- Notify UI update using callback system
                        if updateCallback then
                            updateCallback(FishTracker.getStats())
                        end
                        
                        -- Legacy notification method
                        if getgenv().RayfieldUI and getgenv().RayfieldUI.updateFishStats then
                            getgenv().RayfieldUI.updateFishStats(Stats)
                        end
                    end
                    
                    lastFishingState = isCurrentlyFishing
                end
            end
        end)
    end
end

-- 📊 Get Current Statistics
function FishTracker.getStats()
    local sessionTime = tick() - Stats.sessionStart
    local fishPerHour = 0
    
    if sessionTime > 0 then
        fishPerHour = math.floor((Stats.fishCaught / sessionTime) * 3600)
    end
    
    return {
        fishCaught = Stats.fishCaught,
        totalValue = Stats.totalValue,
        sessionTime = math.floor(sessionTime),
        fishPerHour = fishPerHour,
        rareCount = Stats.rareCount,
        commonCount = Stats.commonCount,
        averageTime = math.floor(Stats.averageTime * 10) / 10,
        bestFish = Stats.bestFish,
        fishTypes = Stats.fishTypes
    }
end

-- 🔄 Reset Statistics
function FishTracker.reset()
    Stats = {
        fishCaught = 0,
        totalValue = 0,
        sessionStart = tick(),
        lastFishTime = 0,
        rareCount = 0,
        commonCount = 0,
        fishTypes = {},
        averageTime = 0,
        bestFish = {name = "None", value = 0}
    }
    print("📊 Fish statistics reset")
end

-- � Set Update Callback
function FishTracker.setUpdateCallback(callback)
    updateCallback = callback
    print("📡 Fish Tracker: Update callback set")
end

-- 🔄 Initialize module (alias for initialize)
function FishTracker.init()
    return FishTracker.initialize()
end

-- �🛑 Cleanup
function FishTracker.cleanup()
    for name, connection in pairs(RemoteConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    RemoteConnections = {}
    print("🛑 Fish Tracker: Cleaned up")
end

-- 🌐 Global Access
getgenv().FishTracker = FishTracker

return FishTracker
