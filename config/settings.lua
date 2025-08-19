-- Configuration file for Modern AutoFish
-- This file contains all user-configurable settings

local Config = {
    -- General settings
    version = "2.0",
    debug = false,
    
    -- AutoFish settings
    autofish = {
        mode = "smart", -- "smart", "secure", "fast"
        autoRecastDelay = 0.4,
        safeModeChance = 70,
        maxActionsPerMinute = 12000000,
        detectionCooldown = 5,
        enabled = false
    },
    
    -- Movement settings
    movement = {
        floatHeight = 16,
        floatSpeed = 0.1,
        spinnerSpeed = 2,
        spinnerDirection = 1
    },
    
    -- Auto Sell settings
    autosell = {
        threshold = 50,
        cooldown = 5,
        allowedRarities = {
            COMMON = true,
            UNCOMMON = true,
            RARE = false,
            EPIC = false,
            LEGENDARY = false,
            MYTHIC = false
        }
    },
    
    -- Security settings
    security = {
        antiAfkEnabled = false,
        maxRetries = 3,
        suspicionThreshold = 8
    },
    
    -- UI settings
    ui = {
        theme = "dark",
        position = {x = 10, y = 10},
        size = {width = 400, height = 500},
        transparency = 0.1
    },
    
    -- GitHub settings (for updates)
    github = {
        user = "MELLISAEFFENDY",
        repo = "fullversion", 
        branch = "main"
    }
}

return Config
