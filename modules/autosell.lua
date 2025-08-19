-- Auto Sell Module for Modern AutoFish
-- Part of Modern AutoFish Modular System

local AutoSell = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- Configuration
AutoSell.config = {
    enabled = false,
    threshold = 50,
    isCurrentlySelling = false,
    allowedRarities = {
        COMMON = true,
        UNCOMMON = true,
        RARE = false,
        EPIC = false,
        LEGENDARY = false,
        MYTHIC = false
    },
    sellCount = {
        COMMON = 0,
        UNCOMMON = 0,
        RARE = 0,
        EPIC = 0,
        LEGENDARY = 0,
        MYTHIC = 0
    },
    lastSellTime = 0,
    sellCooldown = 5,
    -- Server sync variables
    serverThreshold = 50,
    lastSyncTime = 0,
    syncCooldown = 2,
    isThresholdSynced = false,
    syncRetries = 0,
    maxSyncRetries = 3
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
    print(string.format("[AutoSell] %s: %s", title, text))
end

-- Remote helper
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

-- Get sell remote
local sellRemote = ResolveRemote("RF/SellAllItems")

-- Helper functions
local function getTotalFishForSell()
    local total = 0
    for rarity, count in pairs(AutoSell.config.sellCount) do
        if AutoSell.config.allowedRarities[rarity] then
            total = total + count
        end
    end
    return total
end

local function resetSellCounts()
    for rarity, _ in pairs(AutoSell.config.sellCount) do
        AutoSell.config.sellCount[rarity] = 0
    end
end

local function shouldSellFish(rarity)
    return AutoSell.config.allowedRarities[rarity] or false
end

-- Server sync functions
local function syncAutoSellThresholdWithServer(newThreshold)
    local now = tick()
    if now - AutoSell.config.lastSyncTime < AutoSell.config.syncCooldown then
        return false, "sync_cooldown"
    end
    
    local updateThresholdRemote = ResolveRemote("RF/UpdateAutoSellThreshold")
    if not updateThresholdRemote then
        return false, "remote_not_found"
    end
    
    AutoSell.config.lastSyncTime = now
    
    local success, result = pcall(function()
        return updateThresholdRemote:InvokeServer(newThreshold)
    end)
    
    if success then
        AutoSell.config.serverThreshold = newThreshold
        AutoSell.config.isThresholdSynced = true
        AutoSell.config.syncRetries = 0
        notify("Sync", string.format("✅ Threshold synced: %d", newThreshold))
        return true, result
    else
        AutoSell.config.syncRetries = AutoSell.config.syncRetries + 1
        AutoSell.config.isThresholdSynced = false
        notify("Sync", string.format("❌ Sync failed (Attempt %d/%d)", AutoSell.config.syncRetries, AutoSell.config.maxSyncRetries))
        
        -- Retry logic
        if AutoSell.config.syncRetries < AutoSell.config.maxSyncRetries then
            task.spawn(function()
                task.wait(AutoSell.config.syncCooldown * 2)
                syncAutoSellThresholdWithServer(newThreshold)
            end)
        end
        
        return false, result
    end
end

-- Main auto sell function
local function checkAndAutoSell()
    if not AutoSell.config.enabled or AutoSell.config.isCurrentlySelling then
        return
    end
    
    local totalFishToSell = getTotalFishForSell()
    if totalFishToSell < AutoSell.config.threshold then
        return
    end
    
    -- Check cooldown
    local now = tick()
    if now - AutoSell.config.lastSellTime < AutoSell.config.sellCooldown then
        return
    end
    
    AutoSell.config.isCurrentlySelling = true
    AutoSell.config.lastSellTime = now
    
    pcall(function()
        if not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then 
            AutoSell.config.isCurrentlySelling = false
            return 
        end

        -- Save original position
        local originalCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        
        -- Try to find NPC or use fallback coordinates
        local sellNpc = nil
        local npcContainer = ReplicatedStorage:FindFirstChild("NPC")
        if npcContainer then
            sellNpc = npcContainer:FindFirstChild("Alex") or npcContainer:FindFirstChild("Shop")
        end

        -- Teleport to seller
        if sellNpc and sellNpc.WorldPivot then
            LocalPlayer.Character.HumanoidRootPart.CFrame = sellNpc.WorldPivot
        else
            -- Fallback coordinates for shop
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-31.10, 4.84, 2899.03)
        end

        notify("Auto Sell", string.format("🚀 Auto selling %d fish (Threshold: %d)", totalFishToSell, AutoSell.config.threshold))
        task.wait(1.5)

        -- Execute sell
        if sellRemote then
            local success = pcall(function()
                if sellRemote:IsA("RemoteFunction") then 
                    return sellRemote:InvokeServer() 
                else 
                    sellRemote:FireServer() 
                end
            end)
            
            if success then
                notify("Auto Sell", "✅ Auto sell successful!")
                resetSellCounts()
            else
                notify("Auto Sell", "❌ Auto sell failed!")
            end
        else
            notify("Auto Sell", "❌ Sell remote not found!")
        end

        task.wait(1.5)

        -- Return to original position
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = originalCFrame
        end
        
        notify("Auto Sell", "🏠 Returned to fishing spot")
        AutoSell.config.isCurrentlySelling = false
    end)
end

-- Public API functions
function AutoSell.enable()
    AutoSell.config.enabled = true
    notify("Auto Sell", "✅ Auto Sell enabled")
    return true
end

function AutoSell.disable()
    AutoSell.config.enabled = false
    notify("Auto Sell", "❌ Auto Sell disabled")
    return true
end

function AutoSell.setThreshold(newThreshold)
    if type(newThreshold) == "number" and newThreshold > 0 and newThreshold <= 1000 then
        AutoSell.config.threshold = newThreshold
        syncAutoSellThresholdWithServer(newThreshold)
        notify("Auto Sell", "🎯 Threshold set to: " .. newThreshold)
        return true
    end
    return false
end

function AutoSell.getThreshold()
    return AutoSell.config.threshold
end

function AutoSell.sellNow()
    if AutoSell.config.isCurrentlySelling then
        notify("Auto Sell", "⚠️ Already selling!")
        return false
    end
    
    -- Force sell regardless of threshold
    local originalThreshold = AutoSell.config.threshold
    AutoSell.config.threshold = 0
    
    -- Add some fish to trigger sell
    AutoSell.config.sellCount.COMMON = 1
    
    checkAndAutoSell()
    
    -- Restore original threshold
    task.wait(5) -- Wait for sell to complete
    AutoSell.config.threshold = originalThreshold
    
    return true
end

function AutoSell.setRarityFilter(rarity, allowed)
    if AutoSell.config.allowedRarities[rarity] ~= nil then
        AutoSell.config.allowedRarities[rarity] = allowed
        notify("Auto Sell", string.format("%s fish: %s", rarity, allowed and "Allowed" or "Blocked"))
        return true
    end
    return false
end

function AutoSell.getStatus()
    return {
        enabled = AutoSell.config.enabled,
        threshold = AutoSell.config.threshold,
        isCurrentlySelling = AutoSell.config.isCurrentlySelling,
        totalFish = getTotalFishForSell(),
        allowedRarities = AutoSell.config.allowedRarities,
        sellCounts = AutoSell.config.sellCount
    }
end

function AutoSell.addFish(fishName, rarity)
    if AutoSell.config.sellCount[rarity] then
        AutoSell.config.sellCount[rarity] = AutoSell.config.sellCount[rarity] + 1
    end
    
    -- Check if we should auto sell
    if AutoSell.config.enabled then
        checkAndAutoSell()
    end
end

function AutoSell.resetCounts()
    resetSellCounts()
    notify("Auto Sell", "🔄 Fish counts reset")
end

function AutoSell.init(config)
    if config and config.autosell then
        for key, value in pairs(config.autosell) do
            if AutoSell.config[key] ~= nil then
                AutoSell.config[key] = value
            end
        end
    end
    
    -- Initialize server sync
    task.spawn(function()
        task.wait(2) -- Wait for game to fully load
        syncAutoSellThresholdWithServer(AutoSell.config.threshold)
    end)
    
    print("🛒 AutoSell module initialized")
    return true
end

function AutoSell.cleanup()
    AutoSell.config.enabled = false
    AutoSell.config.isCurrentlySelling = false
    print("🧹 AutoSell module cleaned up")
end

-- New functions for ORION UI compatibility
function AutoSell.setEnabled(enabled)
    AutoSell.config.enabled = enabled
    notify("Auto Sell", enabled and "✅ Enabled" or "❌ Disabled")
end

function AutoSell.setThreshold(threshold)
    if threshold and threshold >= 10 and threshold <= 100 then
        AutoSell.config.threshold = threshold
        syncAutoSellThresholdWithServer(threshold)
        notify("Auto Sell", "📊 Threshold set to: " .. threshold .. "%")
    end
end

function AutoSell.setSellCommon(enabled)
    AutoSell.config.allowedRarities.COMMON = enabled
    AutoSell.config.allowedRarities.UNCOMMON = enabled -- Include uncommon with common
    notify("Auto Sell", "🐟 Common fish selling: " .. (enabled and "enabled" or "disabled"))
end

function AutoSell.setSellRare(enabled)
    AutoSell.config.allowedRarities.RARE = enabled
    AutoSell.config.allowedRarities.EPIC = enabled -- Include epic with rare
    notify("Auto Sell", "🌟 Rare fish selling: " .. (enabled and "enabled" or "disabled"))
end

function AutoSell.setSellLegendary(enabled)
    AutoSell.config.allowedRarities.LEGENDARY = enabled
    AutoSell.config.allowedRarities.MYTHIC = enabled -- Include mythic with legendary
    notify("Auto Sell", "👑 Legendary fish selling: " .. (enabled and "enabled" or "disabled"))
end

return AutoSell
