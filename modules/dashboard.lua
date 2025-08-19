-- Dashboard Module for Modern AutoFish
-- Part of Modern AutoFish Modular System

local Dashboard = {}

-- Services
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

-- Configuration
Dashboard.config = {
    trackingEnabled = true,
    maxLogEntries = 1000,
    autoSaveInterval = 300 -- 5 minutes
}

-- Statistics data
Dashboard.sessionStats = {
    startTime = tick(),
    fishCount = 0,
    rareCount = 0,
    totalValue = 0,
    currentLocation = "Unknown"
}

Dashboard.fishCaught = {}
Dashboard.rareFishCaught = {}
Dashboard.locationStats = {}
Dashboard.heatmap = {}
Dashboard.optimalTimes = {}

-- Fish rarity categories
local FishRarity = {
    MYTHIC = {
        "Hawks Turtle", "Dotted Stingray", "Hammerhead Shark", "Manta Ray", 
        "Abyss Seahorse", "Blueflame Ray", "Prismy Seahorse", "Loggerhead Turtle"
    },
    LEGENDARY = {
        "Blue Lobster", "Greenbee Grouper", "Starjam Tang", "Yellowfin Tuna",
        "Chrome Tuna", "Magic Tang", "Enchanted Angelfish", "Lavafin Tuna", 
        "Lobster", "Bumblebee Grouper"
    },
    EPIC = {
        "Domino Damsel", "Panther Grouper", "Unicorn Tang", "Dorhey Tang",
        "Moorish Idol", "Cow Clownfish", "Astra Damsel", "Firecoal Damsel",
        "Longnose Butterfly", "Sushi Cardinal"
    },
    RARE = {
        "Scissortail Dartfish", "White Clownfish", "Darwin Clownfish", 
        "Korean Angelfish", "Candy Butterfly", "Jewel Tang", "Charmed Tang",
        "Kau Cardinal", "Fire Goby"
    },
    UNCOMMON = {
        "Maze Angelfish", "Tricolore Butterfly", "Flame Angelfish", 
        "Yello Damselfish", "Vintage Damsel", "Coal Tang", "Magma Goby",
        "Banded Butterfly", "Shrimp Goby"
    },
    COMMON = {
        "Orangy Goby", "Specked Butterfly", "Corazon Damse", "Copperband Butterfly",
        "Strawberry Dotty", "Azure Damsel", "Clownfish", "Skunk Tilefish",
        "Yellowstate Angelfish", "Vintage Blue Tang", "Ash Basslet", 
        "Volcanic Basslet", "Boa Angelfish", "Jennifer Dottyback", "Reef Chromis"
    }
}

-- Location mapping
local LocationMap = {
    ["Kohana Volcano"] = {x = -594, z = 149},
    ["Crater Island"] = {x = 1010, z = 5078},
    ["Kohana"] = {x = -650, z = 711},
    ["Lost Isle"] = {x = -3618, z = -1317},
    ["Stingray Shores"] = {x = 45, z = 2987},
    ["Esoteric Depths"] = {x = 1944, z = 1371},
    ["Weather Machine"] = {x = -1488, z = 1876},
    ["Tropical Grove"] = {x = -2095, z = 3718},
    ["Coral Reefs"] = {x = -3023, z = 2195}
}

-- Helper functions
local function GetFishRarity(fishName)
    for rarity, fishList in pairs(FishRarity) do
        for _, fish in pairs(fishList) do
            if string.find(string.lower(fishName), string.lower(fish)) then
                return rarity
            end
        end
    end
    return "COMMON"
end

local function DetectCurrentLocation()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return "Unknown"
    end
    
    local pos = LocalPlayer.Character.HumanoidRootPart.Position
    
    -- Location detection based on position ranges
    if pos.Z > 4500 then
        return "Crater Island"
    elseif pos.Z > 2500 then
        return "Stingray Shores"
    elseif pos.Z > 1500 then
        return "Esoteric Depths"
    elseif pos.Z > 700 then
        return "Kohana"
    elseif pos.Z > 3000 and pos.X < -2000 then
        return "Tropical Grove"
    elseif pos.Z > 1800 and pos.X < -3000 then
        return "Coral Reefs"
    elseif pos.X < -3500 then
        return "Lost Isle"
    elseif pos.X < -1400 and pos.Z > 1500 then
        return "Weather Machine"
    elseif pos.Z < 500 and pos.X < -500 then
        return "Kohana Volcano"
    else
        return "Unknown Area"
    end
end

-- Main logging function
local function LogFishCatch(fishName, location)
    if not Dashboard.config.trackingEnabled then return end
    
    local currentTime = tick()
    local rarity = GetFishRarity(fishName)
    
    print(string.format("[Dashboard] Fish caught: %s (Rarity: %s) at %s", fishName, rarity, location or "Unknown"))
    
    -- Log to main database
    table.insert(Dashboard.fishCaught, {
        name = fishName,
        rarity = rarity,
        location = location or Dashboard.sessionStats.currentLocation,
        timestamp = currentTime,
        hour = tonumber(os.date("%H", currentTime))
    })
    
    -- Keep log size manageable
    if #Dashboard.fishCaught > Dashboard.config.maxLogEntries then
        table.remove(Dashboard.fishCaught, 1)
    end
    
    -- Log rare fish separately
    if rarity ~= "COMMON" then
        table.insert(Dashboard.rareFishCaught, {
            name = fishName,
            rarity = rarity,
            location = location or Dashboard.sessionStats.currentLocation,
            timestamp = currentTime
        })
        Dashboard.sessionStats.rareCount = Dashboard.sessionStats.rareCount + 1
    end
    
    -- Update location stats
    local loc = location or Dashboard.sessionStats.currentLocation
    if not Dashboard.locationStats[loc] then
        Dashboard.locationStats[loc] = {total = 0, rare = 0, common = 0, lastCatch = 0}
    end
    Dashboard.locationStats[loc].total = Dashboard.locationStats[loc].total + 1
    Dashboard.locationStats[loc].lastCatch = currentTime
    
    if rarity ~= "COMMON" then
        Dashboard.locationStats[loc].rare = Dashboard.locationStats[loc].rare + 1
    else
        Dashboard.locationStats[loc].common = Dashboard.locationStats[loc].common + 1
    end
    
    -- Update session stats
    Dashboard.sessionStats.fishCount = Dashboard.sessionStats.fishCount + 1
    
    -- Update heatmap data
    if LocationMap[loc] then
        local key = loc
        if not Dashboard.heatmap[key] then
            Dashboard.heatmap[key] = {count = 0, rare = 0, efficiency = 0}
        end
        Dashboard.heatmap[key].count = Dashboard.heatmap[key].count + 1
        if rarity ~= "COMMON" then
            Dashboard.heatmap[key].rare = Dashboard.heatmap[key].rare + 1
        end
        Dashboard.heatmap[key].efficiency = Dashboard.heatmap[key].rare / Dashboard.heatmap[key].count
    end
    
    -- Update optimal times
    local hour = tonumber(os.date("%H", currentTime))
    if not Dashboard.optimalTimes[hour] then
        Dashboard.optimalTimes[hour] = {total = 0, rare = 0}
    end
    Dashboard.optimalTimes[hour].total = Dashboard.optimalTimes[hour].total + 1
    if rarity ~= "COMMON" then
        Dashboard.optimalTimes[hour].rare = Dashboard.optimalTimes[hour].rare + 1
    end
end

-- Location tracking
local function LocationTracker()
    while Dashboard.config.trackingEnabled do
        local newLocation = DetectCurrentLocation()
        if newLocation ~= Dashboard.sessionStats.currentLocation then
            Dashboard.sessionStats.currentLocation = newLocation
            print(string.format("[Dashboard] Location changed to: %s", newLocation))
        end
        task.wait(3)
    end
end

-- Public API functions
function Dashboard.getSessionStats()
    local sessionTime = tick() - Dashboard.sessionStats.startTime
    return {
        sessionTime = sessionTime,
        fishCount = Dashboard.sessionStats.fishCount,
        rareCount = Dashboard.sessionStats.rareCount,
        totalValue = Dashboard.sessionStats.totalValue or 0,
        currentLocation = Dashboard.sessionStats.currentLocation,
        fishPerHour = sessionTime > 0 and (Dashboard.sessionStats.fishCount / (sessionTime / 3600)) or 0,
        rarePercentage = Dashboard.sessionStats.fishCount > 0 and (Dashboard.sessionStats.rareCount / Dashboard.sessionStats.fishCount * 100) or 0
    }
end

function Dashboard.getLocationStats()
    return Dashboard.locationStats
end

function Dashboard.getRecentFish(count)
    count = count or 10
    local recent = {}
    local startIndex = math.max(1, #Dashboard.fishCaught - count + 1)
    
    for i = startIndex, #Dashboard.fishCaught do
        table.insert(recent, Dashboard.fishCaught[i])
    end
    
    return recent
end

function Dashboard.getBestLocation()
    local bestLoc = nil
    local bestEfficiency = 0
    
    for location, stats in pairs(Dashboard.locationStats) do
        if stats.total >= 5 then -- Minimum sample size
            local efficiency = stats.rare / stats.total
            if efficiency > bestEfficiency then
                bestEfficiency = efficiency
                bestLoc = location
            end
        end
    end
    
    return bestLoc, math.floor(bestEfficiency * 100)
end

function Dashboard.getBestFishingTime()
    local bestHour = 0
    local bestRatio = 0
    
    for hour, data in pairs(Dashboard.optimalTimes) do
        if data.total >= 5 then -- Minimum sample size
            local ratio = data.rare / data.total
            if ratio > bestRatio then
                bestRatio = ratio
                bestHour = hour
            end
        end
    end
    
    return bestHour, math.floor(bestRatio * 100)
end

function Dashboard.resetStats()
    Dashboard.sessionStats = {
        startTime = tick(),
        fishCount = 0,
        rareCount = 0,
        totalValue = 0,
        currentLocation = DetectCurrentLocation()
    }
    
    Dashboard.fishCaught = {}
    Dashboard.rareFishCaught = {}
    Dashboard.locationStats = {}
    Dashboard.heatmap = {}
    Dashboard.optimalTimes = {}
    
    print("[Dashboard] Statistics reset")
end

function Dashboard.exportData()
    return {
        sessionStats = Dashboard.sessionStats,
        fishCaught = Dashboard.fishCaught,
        locationStats = Dashboard.locationStats,
        exportTime = tick(),
        version = "2.0"
    }
end

function Dashboard.printSummary()
    local stats = Dashboard.getSessionStats()
    local bestLoc, bestLocEff = Dashboard.getBestLocation()
    local bestHour, bestHourEff = Dashboard.getBestFishingTime()
    
    print("=== Dashboard Summary ===")
    print(string.format("Session Time: %.1f minutes", stats.sessionTime / 60))
    print(string.format("Fish Caught: %d (%.1f/hour)", stats.fishCount, stats.fishPerHour))
    print(string.format("Rare Fish: %d (%.1f%%)", stats.rareCount, stats.rarePercentage))
    print(string.format("Current Location: %s", stats.currentLocation))
    print(string.format("Best Location: %s (%d%% rare)", bestLoc or "None", bestLocEff))
    print(string.format("Best Time: %02d:00 (%d%% rare)", bestHour, bestHourEff))
    print("========================")
end

-- Module initialization
function Dashboard.init(config)
    if config and config.dashboard then
        for key, value in pairs(config.dashboard) do
            if Dashboard.config[key] ~= nil then
                Dashboard.config[key] = value
            end
        end
    end
    
    -- Reset session stats
    Dashboard.sessionStats.startTime = tick()
    Dashboard.sessionStats.currentLocation = DetectCurrentLocation()
    
    -- Start location tracking
    task.spawn(LocationTracker)
    
    -- Make LogFishCatch globally accessible
    Dashboard.LogFishCatch = LogFishCatch
    _G.DashboardLogFish = LogFishCatch
    
    print("📊 Dashboard module initialized")
    return true
end

function Dashboard.cleanup()
    Dashboard.config.trackingEnabled = false
    print("🧹 Dashboard module cleaned up")
end

return Dashboard
