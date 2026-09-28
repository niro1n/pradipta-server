if not Config.WeatherSync.Enabled then return end

local validWeathers = {
    ["CLEAR"] = true,
    ["EXTRASUNNY"] = true,
    ["CLOUDS"] = true,
    ["OVERCAST"] = true,
    ["RAIN"] = true,
    ["CLEARING"] = true,
    ["THUNDER"] = true,
    ["SMOG"] = true,
    ["FOGGY"] = true,
    ["XMAS"] = true,
    ["SNOWLIGHT"] = true,
    ["BLIZZARD"] = true,
}


local internalState = {
    weather = Config.WeatherSync.DefaultWeather,
    hour = Config.WeatherSync.DefaultTime.hour,
    minute = Config.WeatherSync.DefaultTime.minute,
    blackout = false,
    freezeTime = false,
    dynamicWeather = Config.WeatherSync.DynamicWeather.Enabled,
    dynamicWater = false
}


if Config.WeatherSync.Persistence then
    local savedState = GetResourceKvpString('xeno_weather_state')
    if savedState then
        local decoded = json.decode(savedState)
        if type(decoded) == 'table' then
            if validWeathers[decoded.weather] then internalState.weather = decoded.weather end
            if type(decoded.hour) == 'number' then internalState.hour = decoded.hour end
            if type(decoded.minute) == 'number' then internalState.minute = decoded.minute end
            if type(decoded.blackout) == 'boolean' then internalState.blackout = decoded.blackout end
            if type(decoded.freezeTime) == 'boolean' then internalState.freezeTime = decoded.freezeTime end
            if type(decoded.dynamicWeather) == 'boolean' then internalState.dynamicWeather = decoded.dynamicWeather end
            if type(decoded.dynamicWater) == 'boolean' then internalState.dynamicWater = decoded.dynamicWater end
            DebugLog('^2[xeno-adminmenu] [WeatherSync] Loaded persisted state.^0')
        end
    end
end


local function BuildPublicState()
    return {
        weather = internalState.weather,
        hour = internalState.hour,
        minute = internalState.minute,
        blackout = internalState.blackout,
        dynamicWater = internalState.dynamicWater
    }
end


GlobalState.xenoWeather = BuildPublicState()

local function SaveState()
    if Config.WeatherSync.Persistence then
        SetResourceKvp('xeno_weather_state', json.encode(internalState))
    end
end

local function LogDebug(msg)
    if Config.WeatherSync.Debug then
        DebugLog("^3[xeno-adminmenu] [WeatherSync] ^7" .. msg)
    end
end


local function BroadcastState()
    GlobalState.xenoWeather = BuildPublicState()
    TriggerClientEvent('xeno-adminmenu:client:syncState', -1, internalState)
end


local updateQueue = {}
local isProcessingQueue = false

local function ProcessUpdateQueue()
    if isProcessingQueue then return end
    isProcessingQueue = true

    while #updateQueue > 0 do
        local item = table.remove(updateQueue, 1)
        local partialState = item.state
        local sourceLabel = item.label

        local changed = false
        local weatherChanged = false
        local timeChanged = false
        local blackoutChanged = false

        if partialState.weather then
            local w = string.upper(tostring(partialState.weather))
            if validWeathers[w] then
                if internalState.weather ~= w then
                    internalState.weather = w
                    changed = true
                    weatherChanged = true
                end
            else
                LogDebug("Rejected invalid weather: " .. tostring(partialState.weather) .. " from " .. (sourceLabel or "Unknown"))
            end
        end

        if type(partialState.hour) == 'number' then
            local h = math.floor(partialState.hour)
            if h >= 0 and h <= 23 and internalState.hour ~= h then
                internalState.hour = h
                changed = true
                timeChanged = true
            end
        end

        if type(partialState.minute) == 'number' then
            local m = math.floor(partialState.minute)
            if m >= 0 and m <= 59 and internalState.minute ~= m then
                internalState.minute = m
                changed = true
                timeChanged = true
            end
        end

        if type(partialState.blackout) == 'boolean' and internalState.blackout ~= partialState.blackout then
            internalState.blackout = partialState.blackout
            changed = true
            blackoutChanged = true
        end

        if type(partialState.freezeTime) == 'boolean' and internalState.freezeTime ~= partialState.freezeTime then
            internalState.freezeTime = partialState.freezeTime
            changed = true
        end

        if type(partialState.dynamicWeather) == 'boolean' and internalState.dynamicWeather ~= partialState.dynamicWeather then
            internalState.dynamicWeather = partialState.dynamicWeather
            changed = true
        end

        if type(partialState.dynamicWater) == 'boolean' and internalState.dynamicWater ~= partialState.dynamicWater then
            internalState.dynamicWater = partialState.dynamicWater
            changed = true
        end

        if changed then
            BroadcastState()
            SaveState()
            LogDebug("State updated by " .. (sourceLabel or "System") .. ": " .. json.encode(internalState))

            if weatherChanged then 
                TriggerEvent('xeno-adminmenu:server:weatherChanged', internalState.weather)
                if AddLog then AddLog('weather', 'Weather changed to ' .. internalState.weather, sourceLabel or 'System', nil, { weather = internalState.weather }) end
            end
            if timeChanged then 
                TriggerEvent('xeno-adminmenu:server:timeChanged', internalState.hour, internalState.minute) 
                if AddLog then AddLog('weather', 'Time changed to ' .. internalState.hour .. ':' .. string.format("%02d", internalState.minute), sourceLabel or 'System', nil, { hour = internalState.hour, minute = internalState.minute }) end
            end
            if blackoutChanged then 
                TriggerEvent('xeno-adminmenu:server:blackoutChanged', internalState.blackout) 
                if AddLog then AddLog('weather', 'Blackout changed to ' .. tostring(internalState.blackout), sourceLabel or 'System', nil, { blackout = internalState.blackout }) end
            end
        end
    end

    isProcessingQueue = false
end

local function UpdateState(partialState, sourceLabel)
    table.insert(updateQueue, { state = partialState, label = sourceLabel })
    ProcessUpdateQueue()
    return true
end
_G.XenoUpdateWeatherState = UpdateState


RegisterNetEvent('xeno-adminmenu:server:requestSyncState', function()
    local src = source
    if src and src > 0 then
        TriggerClientEvent('xeno-adminmenu:client:syncState', src, internalState)
        LogDebug("Sent full state to player " .. src)
    end
end)


AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        local conflicts = { "qb-weathersync", "cd_easytime", "vSync" }
        for _, v in ipairs(conflicts) do
            if GetResourceState(v) == "started" then
                DebugLog("^1[WARNING] [xeno-adminmenu] Conflicting resource detected: " .. v .. "^7")
                DebugLog("^1[WARNING] Please stop/disable " .. v .. " to avoid weather/time flickering.^7")
            end
        end
        
        BroadcastState()
        DebugLog("^2[xeno-adminmenu] [WeatherSync] System started. Weather: " .. internalState.weather .. " Time: " .. internalState.hour .. ":" .. internalState.minute .. "^0")
    end
end)


AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        SaveState()
        DebugLog("^2[xeno-adminmenu] [WeatherSync] State saved on shutdown.^0")
    end
end)


CreateThread(function()
    while true do
        Wait(Config.WeatherSync.TimeScale * 1000)
        if not internalState.freezeTime then
            internalState.minute = internalState.minute + 1
            if internalState.minute >= 60 then
                internalState.minute = 0
                internalState.hour = internalState.hour + 1
                if internalState.hour >= 24 then
                    internalState.hour = 0
                end
            end
            
            GlobalState.xenoWeather = BuildPublicState()
        end
    end
end)


CreateThread(function()
    while true do
        Wait((Config.WeatherSync.DynamicWeather.Interval or 20) * 60000)
        if internalState.dynamicWeather then
            local allowed = Config.WeatherSync.DynamicWeather.AllowedWeather
            if allowed and #allowed > 0 then
                local nextWeather = internalState.weather
                local attempts = 0
                while nextWeather == internalState.weather and attempts < 10 do
                    nextWeather = allowed[math.random(1, #allowed)]
                    attempts = attempts + 1
                end
                UpdateState({ weather = nextWeather }, "DynamicWeather")
            end
        end
    end
end)


CreateThread(function()
    while true do
        Wait((Config.WeatherSync.SafetyResyncInterval or 60) * 1000)
        BroadcastState()
        SaveState()
    end
end)


local lastAction = {}
local function isRateLimited(src)
    local now = GetGameTimer()
    if not lastAction[src] then
        lastAction[src] = 0
    end
    if now - lastAction[src] < 500 then 
        return true
    end
    lastAction[src] = now
    return false
end


RegisterNetEvent('xeno-adminmenu:server:setWeather', function(weather)
    local src = source
    if not IsPlayerAdmin(src) then
        LogDebug("Non-admin " .. src .. " tried to set weather")
        return
    end
    if isRateLimited(src) then return end
    if type(weather) ~= 'string' then
        LogDebug("Invalid weather type from " .. src .. ": " .. type(weather))
        return
    end
    UpdateState({ weather = weather }, "Admin " .. src)
end)

RegisterNetEvent('xeno-adminmenu:server:setTime', function(hour, minute)
    local src = source
    if not IsPlayerAdmin(src) then
        LogDebug("Non-admin " .. src .. " tried to set time")
        return
    end
    if isRateLimited(src) then return end
    UpdateState({ hour = tonumber(hour), minute = tonumber(minute) or 0 }, "Admin " .. src)
end)

RegisterNetEvent('xeno-adminmenu:server:toggleBlackout', function(state)
    local src = source
    if not IsPlayerAdmin(src) then return end
    if isRateLimited(src) then return end
    if state == nil then state = not internalState.blackout end
    UpdateState({ blackout = state }, "Admin " .. src)
end)

RegisterNetEvent('xeno-adminmenu:server:toggleFreezeTime', function(state)
    local src = source
    if not IsPlayerAdmin(src) then return end
    if isRateLimited(src) then return end
    if state == nil then state = not internalState.freezeTime end
    UpdateState({ freezeTime = state }, "Admin " .. src)
end)

RegisterNetEvent('xeno-adminmenu:server:toggleDynamicWeather', function(state)
    local src = source
    if not IsPlayerAdmin(src) then return end
    if isRateLimited(src) then return end
    if state == nil then state = not internalState.dynamicWeather end
    UpdateState({ dynamicWeather = state }, "Admin " .. src)
end)

RegisterNetEvent('xeno-adminmenu:server:toggleDynamicWater', function(state)
    local src = source
    if not IsPlayerAdmin(src) then return end
    if isRateLimited(src) then return end
    if state == nil then state = not internalState.dynamicWater end
    UpdateState({ dynamicWater = state }, "Admin " .. src)
end)


RegisterCommand("weather", function(source, args)
    if source ~= 0 and not IsPlayerAdmin(source) then return end
    if args[1] then
        UpdateState({ weather = args[1] }, "Console")
    else
        DebugLog("[WeatherSync] Current weather: " .. internalState.weather)
    end
end, false)

RegisterCommand("time", function(source, args)
    if source ~= 0 and not IsPlayerAdmin(source) then return end
    if args[1] then
        UpdateState({ hour = tonumber(args[1]), minute = tonumber(args[2]) or 0 }, "Console")
    else
        DebugLog("[WeatherSync] Current time: " .. internalState.hour .. ":" .. string.format("%02d", internalState.minute))
    end
end, false)

RegisterCommand("blackout", function(source, args)
    if source ~= 0 and not IsPlayerAdmin(source) then return end
    if args[1] then
        UpdateState({ blackout = (args[1] == "on" or args[1] == "1" or args[1] == "true") }, "Console")
    else
        DebugLog("[WeatherSync] Blackout: " .. tostring(internalState.blackout))
    end
end, false)

RegisterCommand("freezetime", function(source, args)
    if source ~= 0 and not IsPlayerAdmin(source) then return end
    if args[1] then
        UpdateState({ freezeTime = (args[1] == "on" or args[1] == "1" or args[1] == "true") }, "Console")
    else
        DebugLog("[WeatherSync] Freeze time: " .. tostring(internalState.freezeTime))
    end
end, false)
