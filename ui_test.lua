-- Quick UI Test - Modern AutoFish v2.0
-- Test the new enhanced UI with all features

print("🧪 Testing Enhanced Modern AutoFish UI...")
print("📡 Repository: https://github.com/MELLISAEFFENDY/fullversion")

-- Test main loader
local success, result = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/MELLISAEFFENDY/fullversion/main/main_modular.lua"))()
end)

if success then
    print("🎉 Enhanced UI loaded successfully!")
    print("📋 New features:")
    print("   🎣 AutoFishing with Smart/Secure modes")
    print("   🚀 Movement Enhancement (Float, NoClip, Spinner)")
    print("   📊 Real-time Dashboard with statistics")
    print("   🛒 Auto Sell System with threshold control")
    print("   ⚙️ Security Settings (AntiAFK, Auto Reconnect)")
    print("   🎈 Floating Button for quick access")
    print("")
    print("💡 Features in new UI:")
    print("   • Dashboard shows live fish count & session stats")
    print("   • Auto Sell with +/- threshold controls")
    print("   • Floating button (🎣) you can drag and click")
    print("   • All toggles are now functional")
    print("   • Larger scrollable interface")
    print("")
    print("🎮 How to use:")
    print("   1. Click floating 🎣 button to toggle UI")
    print("   2. Enable AutoFish and select Smart/Secure mode")
    print("   3. Check Dashboard for real-time statistics")
    print("   4. Configure Auto Sell threshold as needed")
    print("   5. Enable AntiAFK for extended sessions")
else
    warn("❌ Failed to load enhanced UI:", tostring(result))
    print("🔄 Check internet connection and try again")
end

print("🏁 UI test completed")
