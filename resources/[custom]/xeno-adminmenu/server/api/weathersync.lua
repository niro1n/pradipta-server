-- Pradipta Server Weather & Time Integration (Delegates directly to pradipta-weathersync)

RegisterNetEvent('xeno-adminmenu:server:setWeather', function(weather)
    local src = source
    if not IsPlayerAdmin(src) then return end
    if not weather or type(weather) ~= 'string' then return end

    if GetResourceState('pradipta-weathersync') == 'started' then
        exports['pradipta-weathersync']:setWeather(weather)
        TriggerEvent('pradipta-weathersync:server:setWeather', weather)
        if AddLog then AddLog('admin', 'Set weather to ' .. weather, GetPlayerName(src), nil, { weather = weather }, 'weather_change') end
    end
end)

RegisterNetEvent('xeno-adminmenu:server:setTime', function(hour, minute)
    local src = source
    if not IsPlayerAdmin(src) then return end
    hour = tonumber(hour)
    minute = tonumber(minute) or 0
    if not hour then return end

    if GetResourceState('pradipta-weathersync') == 'started' then
        exports['pradipta-weathersync']:setTime(hour, minute)
        TriggerEvent('pradipta-weathersync:server:setTime', hour, minute)
        if AddLog then AddLog('admin', string.format('Set time to %02d:%02d', hour, minute), GetPlayerName(src), nil, { hour = hour, minute = minute }, 'time_change') end
    end
end)

RegisterNetEvent('xeno-adminmenu:server:toggleBlackout', function(state)
    local src = source
    if not IsPlayerAdmin(src) then return end

    if GetResourceState('pradipta-weathersync') == 'started' then
        if state == nil then
            state = not exports['pradipta-weathersync']:getBlackoutState()
        end
        exports['pradipta-weathersync']:setBlackout(state)
        TriggerEvent('pradipta-weathersync:server:toggleBlackout', state)
        if AddLog then AddLog('admin', 'Toggled blackout: ' .. tostring(state), GetPlayerName(src), nil, { blackout = state }, 'blackout_toggle') end
    end
end)

RegisterNetEvent('xeno-adminmenu:server:toggleDynamicWeather', function(state)
    local src = source
    if not IsPlayerAdmin(src) then return end

    if GetResourceState('pradipta-weathersync') == 'started' then
        exports['pradipta-weathersync']:setDynamicWeather(state)
        TriggerEvent('pradipta-weathersync:server:toggleDynamicWeather', state)
    end
end)

RegisterNetEvent('xeno-adminmenu:server:toggleFreezeTime', function(state)
    local src = source
    if not IsPlayerAdmin(src) then return end

    if GetResourceState('pradipta-weathersync') == 'started' then
        exports['pradipta-weathersync']:setTimeFreeze(state)
        TriggerEvent('pradipta-weathersync:server:toggleFreezeTime', state)
    end
end)

-- Exports compatibility
local function GetWeather()
    if GetResourceState('pradipta-weathersync') == 'started' then
        return exports['pradipta-weathersync']:getWeatherState()
    end
    return "CLEAR"
end

local function SetWeather(weather)
    if not weather then return false end
    if GetResourceState('pradipta-weathersync') == 'started' then
        exports['pradipta-weathersync']:setWeather(weather)
        return true
    end
    return false
end

local function GetTime()
    if GetResourceState('pradipta-weathersync') == 'started' then
        local t = exports['pradipta-weathersync']:getTime()
        if type(t) == 'table' then
            return t.hour or 12, t.minute or 0
        end
    end
    return 12, 0
end

local function SetTime(hour, minute)
    if not hour then return false end
    if GetResourceState('pradipta-weathersync') == 'started' then
        exports['pradipta-weathersync']:setTime(tonumber(hour), tonumber(minute) or 0)
        return true
    end
    return false
end

local function IsBlackout()
    if GetResourceState('pradipta-weathersync') == 'started' then
        return exports['pradipta-weathersync']:getBlackoutState()
    end
    return false
end

local function SetBlackout(state)
    if GetResourceState('pradipta-weathersync') == 'started' then
        exports['pradipta-weathersync']:setBlackout(state)
        return true
    end
    return false
end

local function GetState()
    local h, m = GetTime()
    return {
        weather = GetWeather(),
        hour = h,
        minute = m,
        blackout = IsBlackout(),
        freezeTime = false,
        dynamicWeather = false,
        dynamicWater = false
    }
end

exports('GetWeather', GetWeather)
exports('SetWeather', SetWeather)
exports('GetTime', GetTime)
exports('SetTime', SetTime)
exports('GetState', GetState)
exports('IsBlackout', IsBlackout)
exports('SetBlackout', SetBlackout)
