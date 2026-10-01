Config                         = Config or {}

Config.Framework               = "auto" 
Config.Locale                  = "en-US" 

Config.WeaponImageInventory    = "pradipta-inventory"

Config.WeaponImages            = {
    
}

Config.DEBUG                   = false     

Config.HighlightColor          = "#f44336" 

Config.Currency = "$_"

Config.HighlightSecondaryColor = "#d32f2f" 

Config.Font                    = {
    enabled = false,
    family  = "Cairo",
    url     = "https://fonts.googleapis.com/css2?family=Cairo:wght@400;500;600;700&display=swap",
}

Config.HideNativeTexts         = {
    vehicleName  = true, 
    vehicleClass = true, 
    areaName     = true, 
    streetName   = true, 
}

Config.ServerLogo              = {
    enabled = true,              
    logo    = "assets/logo.png", 
    opacity = 1.0,
}

Config.MinimapTransition       = {
    enabled   = true,
    showLogo  = true,                                               
    logo      = "logo.png",                                
    logoScale = 0.5,                                                
    color     = "linear-gradient(180deg, #1c1b1f 0%, #2b2930 100%)", 
    style     = "slide",                                            
    timing    = { open = 320, hold = 260, close = 480 },
    
    inset     = { top = 0.012, right = 0.016, bottom = 0.004, left = -0.008 },
    
    circle    = { cx = 0.460, cy = 0.500, rx = 0.489, ry = 0.558 },
}

Config.Mileage                 = {
    provider     = "builtin",
    persistent   = true,
    saveInterval = 60, 
}

Config.VoiceIcon               = "lines"

Config.VoiceScript             = "pma-voice"

Config.SpeedUnit               = "kmh" 
Config.EngineToggleKey         = "L" 
Config.SeatbeltToggleKey       = "B" 

Config.Engine                  = {
    enabled = true,
}

Config.Nitro                   = {
    enabled = false,
}

Config.Seatbelt                = {
    enabled = true,

    showIndicator = true,   
    preventEjection = true, 
    audioMode = "native",   
    alarm = true,           
    
    ejection = {
        minSpeed = 100, 
        chance   = 50,  
    },
}

Config.Settings                = {
    enabled = true,

    command = "hudsettings", 
    keybind = {              
        enabled = true,
        defaultKey = "I",
    },
}

Config.VehicleControl          = {
    enabled = true, 

    command = {
        enabled = true,      
        name = "carcontrol", 
    },

    keybind = {
        enabled = true,   
        defaultKey = "M", 
    },

    binds = {
        enabled        = true,
        indicatorLeft  = "LEFT",  
        indicatorRight = "RIGHT", 
        hazards        = "DOWN",  
    },

    allowOnFoot = false, 
}

Config.DefaultSettings         = {
    
    minimap = {
        showOnFoot = true,          
        style = "square",           
        size = 1.0,                 
        widthScale = 0.88,          
        maxSize = 1.25,             
        showNorthIndicator = true,  
        showLongRangeBlips = false, 
        useCustomMask = true,       
        
        customMap = {
            enabled     = false, 
            radarZoom   = 1100,  
            refreshRate = 500,   
        },

        locked = false,         
        lockedPosition = false, 
    },

    status = {
        enabled = true,         
        design = "v3",          
        scale = nil,            
        locked = false,         
        lockedPosition = false, 

        colors = {
            health  = "#F64843",
            hunger  = "#FFC548",
            thirst  = "#38bdf8",
            armor   = "#A0A0A0",
            stress  = "#FF6DC6",
            stamina = "#C4FF48",
            oxygen  = "#85FF7A",
            nitro   = "#BA65FF",
        },
        visibility = {
            health  = true,
            hunger  = true,
            thirst  = true,
            armor   = true,
            stress  = true,
            stamina = true,
            oxygen  = true,
            nitro   = true,
        },
        
        autoHide = {
            health  = false,
            hunger  = false,
            thirst  = false,
            armor   = true,
            stress  = false,
            stamina = true,
            oxygen  = true,
            nitro   = true,
        },
    },

    notification = {
        enabled = true,         
        style = "linear",       
        theme = "colored",      
        sound = true,           
        volume = 50,            
        opacity = 100,          
        locked = false,         
        lockedPosition = false, 
    },

    playerInfo = {
        enabled = true,               
        opacity = 100,                
        accentColor = "4 90% 58%", 
        colors = {
            id = "#ffffff",           
            time = "#e6e1e5",         
            cash = "#FFFFFF",         
            bank = "#26D090",         
            job = "#ff8a65",          
            dirty = "#B23B3B",        
            gang = "#ffffff",         
        },
        showJob = true,               
        showId = true,                
        showTime = true,              
        timeSource = "ingame",        
        showBank = true,              
        showCash = true,              
        showDirtyMoney = true,        
        showGang = true,              
        showWeapon = true,            
        scale = 1.0,                  
        locked = false,               
        lockedPosition = false,       
    },

    compass = {
        enabled = true,         
        showOnFoot = false,     
        style = "default",      
        opacity = 100,          
        showDirection = true,   
        showStreet = true,      
        showZone = true,        
        scale = 1.0,            
        locked = false,         
        lockedPosition = false, 
    },

    voice = {
        location = "status", 
        color = "",          
    },

    progressBar = {
        enabled = true,         
        style = "linear-slim",  
        color = "primary",      
        borderRadius = "full",  
        scale = 1.0,            
        locked = false,         
        lockedPosition = false, 
    },

    speedometer = {
        enabled = true,                 
        style = "round-modern",         
        highlight = true,               
        highlightColor = "4 90% 58%", 
        scale = 1.0,                    
        locked = false,                 
        lockedPosition = false,         
    },
}

Config.ControlHints            = {
    enabled = false,
    position = "center-right", 
    hints = {
        { label = "Open Phone", key = "F1" },
        { label = "Inventory",  key = "TAB" },
    },
}

Config.Stress                  = {
    integrated = true,   
    decayPerMinute = 10, 
    minimumValue = 0,    
    maximumValue = 100,  

    jobWhitelist = { 'police', 'sheriff', 'ambulance', 'doctor' },

    driving = {
        enabled = true,
        speedUnit = 'kmh', 
        thresholds = {
            { minSpeed = 80,  perTick = 2 },
            { minSpeed = 120, perTick = 5 },
            { minSpeed = 180, perTick = 10 },
        },
        tickIntervalMs = 10000,
    },

    shooting = {
        enabled = true,
        perShot = 5,
        weaponBlacklist = {
            'weapon_petrolcan',
            'weapon_fireextinguisher',
            'weapon_flashlight',
        },
    },

    effects = {
        screenBlur             = true, 
        screenShake            = true, 
        vehicleAction          = true, 
        steerImpairment        = true, 
        healthRegenMultiplier  = true, 
        weaponDamageMultiplier = true, 
    },

    onTick = {
        {
            minValue = 50,
            interval = 60000,
            screenBlur = true,
            screenShake = nil,
            vehicleAction = false,
            healthRegenMultiplier = 0.5, 
        },
        {
            minValue = 75,
            interval = 12000, 
            screenBlur = true,
            screenShake = 0.07,
            vehicleAction = 80,            
            steerImpairment = 0.15,        
            healthRegenMultiplier = 0.25,
            weaponDamageMultiplier = 0.85, 
        },
        {
            minValue = 90,
            interval = 8000, 
            screenBlur = true,
            screenShake = 0.10,
            vehicleAction = true,        
            steerImpairment = 0.30,      
            healthRegenMultiplier = 0.0, 
            weaponDamageMultiplier = 0.7,
        },
    },
}

Config.PlayerInfo              = {
    tickInterval         = 5000,
    ammoTickInterval     = 250,
    ammoShootingInterval = 50,
    unarmedTickInterval  = 1000,
}

Config.HungerThirstAlert       = {
    enabled       = true,
    tiers         = {
        { threshold = 20, localeKey = "low" },
        { threshold = 10, localeKey = "medium" },
        { threshold = 5,  localeKey = "critical" },
    },
    minInterval   = 2000,
    checkInterval = 5000,
    sound         = {
        enabled = true,
        file    = "hungry.ogg",
        volume  = 0.1,
    },
}

Config.Cinematic               = {
    enabled = true,        
    command = "cinematic", 
    barHeightPercent = 12, 
    barColor = "#000000",  
    transitionMs = 700,    
    hideHud = true,        
    hideMinimap = true,    
    hideGameHud = true,    
}

Config.GlobalConfig            = {
    enabled = false,                 
    filename = "global-config.json", 
    allowEdit = false,               
}

Config.MinimapWatchdog         = {
    enabled              = false, 
    intervalMs           = 1000,  
    continuous           = false, 
    enforceFrameInterval = 300,   
}

Config.CustomMap               = {
    enabled     = true, 
    radarZoom   = 1100, 
    refreshRate = 500,  
}

Config.CustomPills = {
}

Config.CustomStatuses = {
}

Config.CustomStreetNames = {
    
}

Config.CustomZoneNames = {
    
}

