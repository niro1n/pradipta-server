if not Config.WeatherSync.Enabled then return end

local currentState = {
    weather = Config.WeatherSync.DefaultWeather,
    hour = Config.WeatherSync.DefaultTime.hour,
    minute = Config.WeatherSync.DefaultTime.minute,
    blackout = false,
    dynamicWater = false
}

local hasLoaded = false

RegisterNetEvent('xeno-adminmenu:client:syncState', function(state)
    DebugLog('[WeatherSync TRACE CLIENT] syncState received: ' .. json.encode(state or {}))
    if not state then return end
    
    if state.weather and state.weather ~= currentState.weather then
        currentState.weather = state.weather
        if _G.XenoInstantWeather then
            
            SetWeatherTypeNowPersist(currentState.weather)
            SetWeatherTypeNow(currentState.weather)
            SetWeatherTypePersist(currentState.weather)
        else
            
            SetWeatherTypeOverTime(currentState.weather, 15.0)
            CreateThread(function()
                Wait(15000)
                SetWeatherTypeNowPersist(currentState.weather)
                SetWeatherTypeNow(currentState.weather)
                SetWeatherTypePersist(currentState.weather)
            end)
        end
    end
    
    if state.hour ~= nil and state.minute ~= nil then
        currentState.hour = state.hour
        currentState.minute = state.minute
        NetworkOverrideClockTime(currentState.hour, currentState.minute, 0)
    end
    
    if state.blackout ~= nil and state.blackout ~= currentState.blackout then
        currentState.blackout = state.blackout
        SetBlackout(currentState.blackout)
    end
    
    if state.dynamicWater ~= nil and state.dynamicWater ~= currentState.dynamicWater then
        currentState.dynamicWater = state.dynamicWater
        if currentState.dynamicWater then
            SetDeepOceanScaler(10.0)
        else
            SetDeepOceanScaler(0.0)
        end
    end
end)


local function requestInitialState()
    if hasLoaded then return end
    hasLoaded = true
    TriggerServerEvent('xeno-adminmenu:server:requestSyncState')
end


RegisterNetEvent('QBCore:Client:OnPlayerLoaded', requestInitialState)
RegisterNetEvent('esx:playerLoaded', requestInitialState)
RegisterNetEvent('playerSpawned', requestInitialState) 

CreateThread(function()
    
    Wait(5000)
    if not hasLoaded and NetworkIsPlayerActive(PlayerId()) then
        requestInitialState()
    end
end)


CreateThread(function()
    while true do
        Wait(2000)
        if hasLoaded then
            NetworkOverrideClockTime(currentState.hour, currentState.minute, 0)
            SetWeatherTypePersist(currentState.weather)
            SetWeatherTypeNowPersist(currentState.weather)
            SetWeatherTypeNow(currentState.weather)
        end
    end
end)
