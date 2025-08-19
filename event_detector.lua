-- event_detector.lua
-- XSAN Event Detector System for Roblox Fishing Games
-- This file can be hosted on GitHub and loaded via HTTP

print("🔄 XSAN Event Detector initializing...")

-- Get required services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

-- Notification function
local function Notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = 4})
    end)
    print("[EventDetector]", title, text)
end

-- Main EventDetector object
EventDetector = {
    detectedEvents = {},
    eventLocations = {},
    adminEventsList = {
        ["Black Hole"] = {
            keywords = {"black", "hole", "blackhole", "black hole"},
            icon = "🕳️",
            rarity = "MYTHIC",
            description = "Fish in Black Hole for x5 Galaxy & Corrupt mutations!"
        },
        ["Ghost Shark Hunt"] = {
            keywords = {"ghost", "shark", "hunt", "ghostshark"},
            icon = "🦈",
            rarity = "LEGENDARY", 
            description = "Ghost Shark Hunt event active! Rare sharks available!"
        },
        ["Worm Hunt"] = {
            keywords = {"worm", "hunt", "wormhunt", "fishing event"},
            icon = "🪱",
            rarity = "EPIC",
            description = "Worm Hunt fishing event active!"
        },
        ["Ghost Worm"] = {
            keywords = {"ghost", "worm", "ghostworm"},
            icon = "👻",
            rarity = "LEGENDARY",
            description = "Limited 1 in 1,000,000 Ghost Worm Fish!"
        },
        ["Meteor Rain"] = {
            keywords = {"meteor", "rain", "meteorrain"},
            icon = "☄️",
            rarity = "LEGENDARY",
            description = "Fish in Meteor Rain area for x6 mutation chance!"
        },
        ["Kraken Event"] = {
            keywords = {"kraken", "tentacle"},
            icon = "🐙",
            rarity = "MYTHIC",
            description = "Legendary Kraken has appeared!"
        }
    },
    isScanning = false
}

-- Event Detection Function
function EventDetector.ScanForAdminEvents()
    if EventDetector.isScanning then return end
    EventDetector.isScanning = true
    
    pcall(function()
        local playerGui = LocalPlayer:WaitForChild("PlayerGui", 2)
        if not playerGui then 
            EventDetector.isScanning = false
            return 
        end
        
        for _, gui in pairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                for _, descendant in pairs(gui:GetDescendants()) do
                    if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
                        local success, text = pcall(function() 
                            return descendant.Text:lower() 
                        end)
                        
                        if success and text then
                            -- Check for event keywords
                            for eventName, eventData in pairs(EventDetector.adminEventsList) do
                                for _, keyword in pairs(eventData.keywords) do
                                    if text:find(keyword) and (text:find("event") or text:find("hunt") or text:find("hole") or text:find("shark") or text:find("worm")) then
                                        if not EventDetector.detectedEvents[eventName] then
                                            EventDetector.detectedEvents[eventName] = {
                                                startTime = tick(),
                                                detected = true,
                                                location = nil,
                                                gui = descendant
                                            }
                                            
                                            Notify("🚨 ADMIN EVENT DETECTED!", 
                                                eventData.icon .. " " .. eventName .. " ACTIVE!\n" ..
                                                "⭐ " .. eventData.rarity .. " Event\n" ..
                                                "📝 " .. eventData.description
                                            )
                                            
                                            print("XSAN: Admin Event Detected -", eventName)
                                        end
                                    end
                                end
                                
                                -- Special handling for Black Hole
                                if eventName == "Black Hole" and text:find("black") and text:find("hole") then
                                    if not EventDetector.detectedEvents[eventName] then
                                        EventDetector.detectedEvents[eventName] = {
                                            startTime = tick(),
                                            detected = true,
                                            location = CFrame.new(882, -3, 2542), -- Known Black Hole location
                                            gui = descendant
                                        }
                                        EventDetector.eventLocations[eventName] = CFrame.new(882, -3, 2542)
                                        
                                        Notify("🚨 BLACK HOLE EVENT!", "🕳️ BLACK HOLE DETECTED! Location: (882, -3, 2542)")
                                        print("XSAN: BLACK HOLE EVENT DETECTED!")
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    
    EventDetector.isScanning = false
end

-- Event Location Scanner
function ScanEventLocations()
    pcall(function()
        for eventName, eventInfo in pairs(EventDetector.detectedEvents) do
            if eventInfo.detected and not eventInfo.location then
                -- Default locations for events
                if eventName == "Black Hole" then
                    local blackHoleLocation = CFrame.new(882, -3, 2542)
                    eventInfo.location = blackHoleLocation
                    EventDetector.eventLocations[eventName] = blackHoleLocation
                    print("📍 Located " .. eventName .. " at: (882, -3, 2542)")
                elseif eventName == "Ghost Shark Hunt" then
                    local oceanLocation = CFrame.new(0, 100, 3000)
                    eventInfo.location = oceanLocation
                    EventDetector.eventLocations[eventName] = oceanLocation
                    print("📍 Located " .. eventName .. " at estimated ocean location")
                elseif eventName == "Worm Hunt" then
                    local wormLocation = CFrame.new(0, 50, 0)
                    eventInfo.location = wormLocation
                    EventDetector.eventLocations[eventName] = wormLocation
                    print("📍 Located " .. eventName .. " at estimated location")
                end
            end
        end
    end)
end

-- Teleport to Event Function
function TeleportToEvent(eventName)
    local eventInfo = EventDetector.detectedEvents[eventName]
    if eventInfo and eventInfo.detected and eventInfo.location then
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = eventInfo.location
                print("🚀 Teleported to " .. eventName .. "!")
                Notify("Event Teleport", "🚀 Teleported to " .. eventName .. "!")
            else
                print("❌ Character not found for teleportation")
                Notify("Event Teleport", "❌ Character not found!")
            end
        end)
    else
        print("❌ Event location not available for " .. eventName)
        Notify("Event Teleport", "❌ Event location not available!")
    end
end

-- Auto-scan system
spawn(function()
    wait(3) -- Wait for game to fully load
    while true do
        pcall(function()
            EventDetector.ScanForAdminEvents()
            wait(2)
            ScanEventLocations()
        end)
        wait(3)
    end
end)

print("✅ XSAN Event Detector System loaded successfully!")
print("🔍 Auto-scanning started - monitoring for admin events...")

-- Test function for manual testing
function TestEventDetection()
    -- Simulate Black Hole detection for testing
    EventDetector.detectedEvents["Black Hole"] = {
        startTime = tick(),
        detected = true,
        location = CFrame.new(882, -3, 2542),
        gui = nil
    }
    EventDetector.eventLocations["Black Hole"] = CFrame.new(882, -3, 2542)
    Notify("🧪 TEST EVENT", "🕳️ Black Hole (TEST) detected at (882, -3, 2542)!")
    print("🧪 Test event detection completed")
end
