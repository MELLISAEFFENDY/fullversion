-- Quick Test Loader for Modern AutoFish Modular
-- Test script to verify GitHub integration works

print("🧪 Testing Modern AutoFish Modular System...")
print("📡 Loading from GitHub: https://github.com/MELLISAEFFENDY/fullversion")

-- Test URL
local testUrl = "https://raw.githubusercontent.com/MELLISAEFFENDY/fullversion/main/main_modular.lua"

print("🔄 Attempting to load main_modular.lua...")

local success, result = pcall(function()
    local response = game:HttpGet(testUrl)
    if response and #response > 0 then
        print("✅ Successfully downloaded script (" .. #response .. " characters)")
        return loadstring(response)()
    else
        error("Empty response from GitHub")
    end
end)

if success then
    print("🎉 Modern AutoFish Modular loaded successfully!")
    print("📋 All modules should now be initialized")
else
    warn("❌ Failed to load from GitHub:", tostring(result))
    print("🔄 Trying fallback to local file...")
    
    -- Fallback to local file
    local localSuccess, localResult = pcall(function()
        return loadfile("main_modular.lua")()
    end)
    
    if localSuccess then
        print("✅ Loaded from local file successfully!")
    else
        warn("❌ Local fallback also failed:", tostring(localResult))
        print("💡 Make sure the files are in the correct location")
    end
end

print("🏁 Test completed")
