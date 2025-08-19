-- Nama file hasil scan
local filename = "ScanResult.txt"

-- Hapus file lama biar bersih
if isfile and isfile(filename) then
    delfile(filename)
end

-- Fungsi helper tulis log ke file + output console
local function log(msg)
    print(msg)
    if writefile then
        if not isfile(filename) then
            writefile(filename, msg .. "\n")
        else
            appendfile(filename, msg .. "\n")
        end
    end
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game.Players.LocalPlayer

log("=== 🔍 SCANNER START ===")

-- 1. Scan ReplicatedStorage
log("\n📦 ReplicatedStorage:")
for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        log("  🔗 Remote Found: " .. obj:GetFullName())
    elseif obj:IsA("ModuleScript") then
        log("  📜 ModuleScript Found: " .. obj:GetFullName())
    end
end

-- 2. Scan PlayerGui
log("\n🖥️ PlayerGui:")
for _, gui in pairs(Player.PlayerGui:GetDescendants()) do
    if gui:IsA("ScreenGui") or gui:IsA("Frame") then
        log("  🖼️ GUI Found: " .. gui:GetFullName() .. " Visible: " .. tostring(gui.Visible))
    end
end

-- 3. Scan Backpack
log("\n👜 Backpack Tools:")
for _, tool in pairs(Player.Backpack:GetChildren()) do
    log("  🛠️ Tool Found: " .. tool.Name)
end

log("\n=== 🔍 SCANNER END ===")
log("\n=== 📡 START LOGGING REMOTES ===")

-- 4. Remote logger
for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
    if remote:IsA("RemoteEvent") then
        remote.OnClientEvent:Connect(function(...)
            local args = {...}
            local argText = ""
            for i, v in ipairs(args) do
                argText = argText .. tostring(v) .. (i < #args and ", " or "")
            end
            log("[RemoteEvent] " .. remote.Name .. " Args: " .. argText)
        end)
    elseif remote:IsA("RemoteFunction") then
        remote.OnClientInvoke = function(...)
            local args = {...}
            local argText = ""
            for i, v in ipairs(args) do
                argText = argText .. tostring(v) .. (i < #args and ", " or "")
            end
            log("[RemoteFunction] " .. remote.Name .. " Args: " .. argText)
        end
    end
end
