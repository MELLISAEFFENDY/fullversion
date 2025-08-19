-- Scanner + Remote Logger
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game.Players.LocalPlayer

print("=== 🔍 SCANNER START ===")

-- 1. Scan ReplicatedStorage (RemoteEvent, RemoteFunction, ModuleScript)
print("\n📦 ReplicatedStorage:")
for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        print("  🔗 Remote Found:", obj:GetFullName())
    elseif obj:IsA("ModuleScript") then
        print("  📜 ModuleScript Found:", obj:GetFullName())
    end
end

-- 2. Scan PlayerGui (cek hidden GUI)
print("\n🖥️ PlayerGui:")
for _, gui in pairs(Player.PlayerGui:GetDescendants()) do
    if gui:IsA("ScreenGui") or gui:IsA("Frame") then
        print("  🖼️ GUI Found:", gui:GetFullName(), "Visible:", gui.Visible)
    end
end

-- 3. Scan Backpack (tools senjata, item)
print("\n👜 Backpack Tools:")
for _, tool in pairs(Player.Backpack:GetChildren()) do
    print("  🛠️ Tool Found:", tool.Name)
end

print("\n=== 🔍 SCANNER END ===\n")

-- 4. RemoteEvent & RemoteFunction Logger
print("=== 📡 START LOGGING REMOTES ===")

-- Hook RemoteEvent
for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
    if remote:IsA("RemoteEvent") then
        remote.OnClientEvent:Connect(function(...)
            print("[RemoteEvent]", remote.Name, "Args:", ...)
        end)
    elseif remote:IsA("RemoteFunction") then
        remote.OnClientInvoke = function(...)
            print("[RemoteFunction]", remote.Name, "Args:", ...)
        end
    end
end
