local NUI_ACTIONS = (BabloHud and BabloHud.Constants and BabloHud.Constants.NUI_ACTIONS) or {}

local alertActive       = false   
local lastAlertTime     = 0       
local firedThresholds   = {       
    hunger = {},
    thirst = {},
}

function GetAlertConfig()
    return Config and Config.HungerThirstAlert or nil
end

function IsAlertSuppressed()
    if Bablo and Bablo.Hud and Bablo.Hud.suppressed then return true end
    if Bablo and Bablo.Cinematic and Bablo.Cinematic:Get() then return true end

    local ped = PlayerPedId()
    if not DoesEntityExist(ped) or IsEntityDead(ped) then return true end

    return false
end

function PlayAlertSound(alertCfg)
    local sound = alertCfg and alertCfg.sound
    if not sound or sound.enabled == false then return end

    SendNUIMessage({
        action = NUI_ACTIONS.PLAY_ALERT_SOUND or "playAlertSound",
        data   = {
            file   = sound.file   or "hungry.ogg",
            volume = sound.volume or 0.05,
        },
    })
end

function SendAlertNotification(localeKey, stat)
    if type(localeKey) ~= "string" or localeKey == "" then return end

    local base  = "notifications.hungerAlert." .. localeKey .. "." .. stat
    local title = Locale.t(base .. ".title")
    local body  = Locale.t(base .. ".body")

    exports["pradipta-hud"]:Notify(title, body, "warning", 7500)
end

function BuildTierList(alertCfg)
    local tiers = alertCfg and alertCfg.tiers
    if type(tiers) ~= "table" then return {} end

    local result = {}

    for _, entry in ipairs(tiers) do
        if type(entry) == "number" then
            result[#result + 1] = {
                threshold = entry,
                localeKey = "tier" .. tostring(entry),
            }
        elseif type(entry) == "table" then
            local threshold = tonumber(entry.threshold)
            if threshold then
                local key = entry.localeKey
                if not key then
                    key = "tier" .. tostring(threshold)
                end
                result[#result + 1] = {
                    threshold = threshold,
                    localeKey = tostring(key),
                }
            end
        end
    end

    table.sort(result, function(a, b) return a.threshold < b.threshold end)
    return result
end

function CheckStatThresholds(stat, value, tiers, alertCfg, now)
    local fired = firedThresholds[stat]

    for _, tier in ipairs(tiers) do
        if value > tier.threshold then
            fired[tier.threshold] = nil
        end
    end

    for _, tier in ipairs(tiers) do
        if value <= tier.threshold then
            if not fired[tier.threshold] then
                fired[tier.threshold] = true

                local minInterval = tonumber(alertCfg.minInterval) or 2000
                if now - lastAlertTime >= minInterval then
                    SendAlertNotification(tier.localeKey, stat)
                    PlayAlertSound(alertCfg)
                    lastAlertTime = now
                end
            end
            return  
        end
    end
end

function RunAlertCheck()
    local alertCfg = GetAlertConfig()
    if not alertCfg or alertCfg.enabled == false then return end

    if not (Framework and type(Framework.getHunger) == "function"
                      and type(Framework.getThirst) == "function") then
        return
    end

    if IsAlertSuppressed() then return end

    local tiers = BuildTierList(alertCfg)
    if #tiers == 0 then return end

    local hunger = tonumber(Framework:getHunger()) or 100
    local thirst = tonumber(Framework:getThirst()) or 100
    local now    = GetGameTimer()

    CheckStatThresholds("hunger", hunger, tiers, alertCfg, now)
    CheckStatThresholds("thirst", thirst, tiers, alertCfg, now)
end

function ResetAlertState()
    firedThresholds = { hunger = {}, thirst = {} }
    lastAlertTime   = 0
end

function StartAlertModule()
    if alertActive then return end

    local alertCfg = GetAlertConfig()
    if not alertCfg or alertCfg.enabled == false then return end

    alertActive = true
    Info("HungerThirstAlert module started")

    CreateThread(function()
        while alertActive do
            RunAlertCheck()

            local interval = tonumber(GetAlertConfig() and GetAlertConfig().checkInterval) or 5000
            interval = math.max(interval, 1000)
            Wait(interval)
        end
    end)
end

AddEventHandler("pradipta-hud:playerLoaded", function()
    ResetAlertState()
    StartAlertModule()
end)

AddEventHandler("pradipta-hud:playerUnloaded", function()
    alertActive = false
    ResetAlertState()
end)

RegisterCommand("testhungeralert", function(source, args)
    local alertCfg = GetAlertConfig()
    if not alertCfg then
        Info("[hungerAlert] Config.HungerThirstAlert missing")
        return
    end

    local tierArg = (args[1] or "critical"):lower()
    local statArg = (args[2] or "hunger"):lower()

    if statArg ~= "hunger" and statArg ~= "thirst" then
        Info("[hungerAlert] unknown stat '" .. tostring(args[2]) .. "' (use hunger or thirst)")
        return
    end

    local availableKeys = {}
    local matchedTier   = nil

    if type(alertCfg.tiers) == "table" then
        for _, entry in ipairs(alertCfg.tiers) do
            if type(entry) == "table" and type(entry.localeKey) == "string" then
                availableKeys[#availableKeys + 1] = entry.localeKey
                if entry.localeKey:lower() == tierArg then
                    matchedTier = entry
                end
            end
        end
    end

    if not matchedTier then
        Info(string.format("[hungerAlert] unknown tier '%s' (available: %s)",
            tierArg, table.concat(availableKeys, ", ")))
        return
    end

    Info(string.format("[hungerAlert] test fire: tier=%s stat=%s", matchedTier.localeKey, statArg))
    SendAlertNotification(matchedTier.localeKey, statArg)
    PlayAlertSound(alertCfg)
end, false)

TriggerEvent("chat:addSuggestion", "/testhungeralert",
    "Fire a hunger/thirst alert for testing (sound + notify).", {
        { name = "tier", help = "low | medium | critical (default: critical)" },
        { name = "stat", help = "hunger | thirst (default: hunger)" },
    }
)
