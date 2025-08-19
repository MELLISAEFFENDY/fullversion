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
    sessionStart = tick(),
    sessionFish = {},
    hourlyStats = {},
    bestCatch = {name = "None", value = 0},
    lastCatch = "None",
    lastFishTime = 0,
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
                        local fishRemote = fishCaughtEvent:FindFirstChild("RF"):FindFirstChild("RequestFishingMinigameStarted")
                        if fishRemote then
                            RemoteConnections["FishCaught"] = fishRemote.OnClientEvent:Connect(function(fishData)
                                FishTracker.recordCatch(fishData)
                            end)
                            print("✅ Fish Tracker: Connected to fish caught event")
                        end
                    end
                end
            end
        end
    end)
    
    print("📊 Fish Tracker: Initialization complete")
end

-- 📈 Record Fish Catch
function FishTracker.recordCatch(fishData)
    local currentTime = tick()
    
    -- Basic stats
    Stats.fishCaught = Stats.fishCaught + 1
    Stats.lastFishTime = currentTime
    
    -- Process fish data if available
    if fishData then
        local fishName = fishData.name or fishData.fishName or "Unknown Fish"
        local fishValue = fishData.value or fishData.price or 0
        local rarity = fishData.rarity or "common"
        
        -- Update stats
        Stats.totalValue = Stats.totalValue + fishValue
        Stats.lastCatch = fishName
        
        -- Track fish types
        if not Stats.fishTypes[fishName] then
            Stats.fishTypes[fishName] = {count = 0, totalValue = 0}
        end
        Stats.fishTypes[fishName].count = Stats.fishTypes[fishName].count + 1
        Stats.fishTypes[fishName].totalValue = Stats.fishTypes[fishName].totalValue + fishValue
        
        -- Update best catch
        if fishValue > Stats.bestCatch.value then
            Stats.bestCatch = {name = fishName, value = fishValue}
        end
        
        -- Rarity tracking
        if rarity == "rare" or rarity == "epic" or rarity == "legendary" then
            Stats.rareCount = Stats.rareCount + 1
        else
            Stats.commonCount = Stats.commonCount + 1
        end
        
        -- Add to session fish
        table.insert(Stats.sessionFish, {
            name = fishName,
            value = fishValue,
            rarity = rarity,
            time = currentTime
        })
        
        print(string.format("🎣 Caught: %s (Value: %d, Total: %d)", fishName, fishValue, Stats.fishCaught))
    else
        Stats.lastCatch = "Fish #" .. Stats.fishCaught
    end
    
    -- Calculate average time between catches
    if Stats.fishCaught > 1 then
        local sessionTime = currentTime - Stats.sessionStart
        Stats.averageTime = sessionTime / Stats.fishCaught
    end
    
    -- Update UI if callback is set
    if updateCallback then
        updateCallback(FishTracker.getStats())
    end
end

-- 📊 Get Current Statistics
function FishTracker.getStats()
    local sessionTime = tick() - Stats.sessionStart
    local fishPerHour = sessionTime > 0 and (Stats.fishCaught / (sessionTime / 3600)) or 0
    local valuePerHour = sessionTime > 0 and (Stats.totalValue / (sessionTime / 3600)) or 0
    
    return {
        fishCaught = Stats.fishCaught,
        totalValue = Stats.totalValue,
        sessionTime = sessionTime,
        fishPerHour = fishPerHour,
        valuePerHour = valuePerHour,
        lastCatch = Stats.lastCatch,
        bestCatch = Stats.bestCatch,
        averageTime = Stats.averageTime,
        rareCount = Stats.rareCount,
        commonCount = Stats.commonCount,
        fishTypes = Stats.fishTypes,
        sessionFish = Stats.sessionFish
    }
end

-- 📊 Set Update Callback
function FishTracker.setUpdateCallback(callback)
    updateCallback = callback
    print("📊 Fish Tracker: Update callback set")
end

-- 🎯 Get Detailed Fish Statistics
function FishTracker.getDetailedStats()
    local stats = FishTracker.getStats()
    
    -- Calculate additional metrics
    local topFish = {}
    for fishName, data in pairs(Stats.fishTypes) do
        table.insert(topFish, {
            name = fishName,
            count = data.count,
            totalValue = data.totalValue,
            avgValue = data.totalValue / data.count
        })
    end
    
    -- Sort by count
    table.sort(topFish, function(a, b) return a.count > b.count end)
    
    -- Get recent catches (last 10)
    local recentCatches = {}
    local startIdx = math.max(1, #Stats.sessionFish - 9)
    for i = startIdx, #Stats.sessionFish do
        table.insert(recentCatches, Stats.sessionFish[i])
    end
    
    return {
        basic = stats,
        topFish = topFish,
        recentCatches = recentCatches,
        rarePercentage = Stats.fishCaught > 0 and (Stats.rareCount / Stats.fishCaught * 100) or 0
    }
end

-- 🔄 Reset Statistics
function FishTracker.reset()
    Stats = {
        fishCaught = 0,
        totalValue = 0,
        sessionStart = tick(),
        sessionFish = {},
        hourlyStats = {},
        bestCatch = {name = "None", value = 0},
        lastCatch = "None",
        lastFishTime = 0,
        rareCount = 0,
        commonCount = 0,
        fishTypes = {},
        averageTime = 0,
        bestFish = {name = "None", value = 0}
    }
    
    print("📊 Fish Tracker: Statistics reset")
    
    -- Update UI if callback is set
    if updateCallback then
        updateCallback(FishTracker.getStats())
    end
end

-- 📊 Export Statistics to String
function FishTracker.exportStats()
    local stats = FishTracker.getDetailedStats()
    local output = {}
    
    table.insert(output, "=== FISH STATISTICS EXPORT ===")
    table.insert(output, string.format("Session Time: %.1f minutes", stats.basic.sessionTime / 60))
    table.insert(output, string.format("Total Fish: %d", stats.basic.fishCaught))
    table.insert(output, string.format("Total Value: %d", stats.basic.totalValue))
    table.insert(output, string.format("Fish/Hour: %.1f", stats.basic.fishPerHour))
    table.insert(output, string.format("Value/Hour: %.1f", stats.basic.valuePerHour))
    table.insert(output, string.format("Best Catch: %s (%d)", stats.basic.bestCatch.name, stats.basic.bestCatch.value))
    table.insert(output, string.format("Rare Fish: %d (%.1f%%)", stats.basic.rareCount, stats.rarePercentage))
    table.insert(output, "")
    
    table.insert(output, "=== TOP FISH BY COUNT ===")
    for i = 1, math.min(5, #stats.topFish) do
        local fish = stats.topFish[i]
        table.insert(output, string.format("%d. %s: %d caught (Avg: %.1f)", i, fish.name, fish.count, fish.avgValue))
    end
    
    return table.concat(output, "\n")
end

-- 📡 Enhanced Remote Detection
function FishTracker.detectRemotes()
    local detectedRemotes = {}
    
    pcall(function()
        local packages = ReplicatedStorage:FindFirstChild("Packages")
        if packages then
            local idx = packages:FindFirstChild("_Index")
            if idx then
                local net = idx:FindFirstChild("sleitnick_net@0.2.0")
                if net then
                    net = net:FindFirstChild("net")
                    if net then
                        -- Look for fishing-related remotes
                        local remotes = {"RF", "RE"}
                        for _, remoteType in pairs(remotes) do
                            local folder = net:FindFirstChild(remoteType)
                            if folder then
                                for _, remote in pairs(folder:GetChildren()) do
                                    local name = remote.Name:lower()
                                    if name:find("fish") or name:find("catch") or name:find("rod") then
                                        table.insert(detectedRemotes, {
                                            type = remoteType,
                                            name = remote.Name,
                                            path = string.format("%s/%s", remoteType, remote.Name)
                                        })
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    
    return detectedRemotes
end

-- 🎣 Advanced Fish Detection
function FishTracker.startAdvancedDetection()
    print("📊 Fish Tracker: Starting advanced detection...")
    
    local detectedRemotes = FishTracker.detectRemotes()
    print(string.format("📡 Detected %d fishing-related remotes", #detectedRemotes))
    
    for _, remote in pairs(detectedRemotes) do
        print(string.format("  📡 %s: %s", remote.type, remote.name))
    end
    
    -- Try to connect to multiple potential events
    local connectionAttempts = {
        "FishCaughtNotification",
        "FishingCompleteNotification", 
        "FishingResultEvent",
        "FishCatchEvent",
        "RequestFishingMinigameStarted"
    }
    
    for _, eventName in pairs(connectionAttempts) do
        pcall(function()
            local packages = ReplicatedStorage:FindFirstChild("Packages")
            if packages then
                local idx = packages:FindFirstChild("_Index")
                if idx then
                    local net = idx:FindFirstChild("sleitnick_net@0.2.0")
                    if net then
                        net = net:FindFirstChild("net")
                        if net then
                            local reFolder = net:FindFirstChild("RE")
                            local rfFolder = net:FindFirstChild("RF")
                            
                            local remote = (reFolder and reFolder:FindFirstChild(eventName)) or 
                                         (rfFolder and rfFolder:FindFirstChild(eventName))
                            
                            if remote then
                                if remote:IsA("RemoteEvent") then
                                    RemoteConnections[eventName] = remote.OnClientEvent:Connect(function(...)
                                        local args = {...}
                                        print(string.format("📡 %s triggered with %d args", eventName, #args))
                                        
                                        -- Try to extract fish data
                                        for i, arg in pairs(args) do
                                            if type(arg) == "table" and (arg.name or arg.fishName or arg.value) then
                                                FishTracker.recordCatch(arg)
                                                break
                                            end
                                        end
                                    end)
                                    print(string.format("✅ Connected to %s (RemoteEvent)", eventName))
                                elseif remote:IsA("RemoteFunction") then
                                    print(string.format("📡 Found %s (RemoteFunction) - cannot hook", eventName))
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end

-- 🛑 Cleanup
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
return FishTracker
