Config = {}

Config.Debug = false

function DebugLog(...)
    if Config.Debug then
        print(...)
    end
end

Config.MenuCommand = 'admin'
Config.MenuKey = 'F11'
Config.NoclipKey = 'PAGEUP'
Config.Framework = 'pradiptacore'


Config.WarnsToBan = 3
Config.AutoBanDuration = 3


Config.Bans = {
    AppealURL = "https://discord.gg/pradipta",
    ServerName = "PRADIPTA PRIVATE",
    LogoURL = "nui://pradipta_loading/assets/logo/pradipta-logo-animation.gif",
    DefaultReason = "No reason specified."
}


Config.Registration = {
    CooldownMinutes = 30,
    MinReasonLength = 10,
    MaxReasonLength = 500,
    MaxRejectReasonLength = 500,
}


Config.WeatherSync = {
    Enabled = false,                    -- Disabled to prevent duplicate weather loops with pradipta-weathersync
    UsePRADIPTAWeatherSync = true,            -- Forward all admin weather/time actions to pradipta-weathersync
    Debug = false,
    DefaultWeather = "CLEAR",
    DefaultTime = { hour = 12, minute = 0 }
}
