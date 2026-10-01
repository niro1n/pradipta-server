local lastAliveCoords = nil
local lastAliveHeading = 0.0
local isDeadHandled = false

-- Traffic and Ped density control
CreateThread(function()
    while true do
        Wait(0)
        SetPedDensityMultiplierThisFrame(0.0)
        SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)
        SetVehicleDensityMultiplierThisFrame(0.0)
        SetRandomVehicleDensityMultiplierThisFrame(0.0)
        SetParkedVehicleDensityMultiplierThisFrame(0.0)
    end
end)

-- NPC cleanup
CreateThread(function()
    while true do
        Wait(2000)
        local playerPed = PlayerPedId()

        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and ped ~= playerPed and not IsPedAPlayer(ped) then
                if not IsEntityAMissionEntity(ped) and not (Entity(ped).state and Entity(ped).state.isCharPed) then
                    DeleteEntity(ped)
                end
            end
        end

        for _, veh in ipairs(GetGamePool('CVehicle')) do
            if DoesEntityExist(veh) and not IsEntityAMissionEntity(veh) then
                local hasPlayer = false
                for seat = -1, 7 do
                    local occupant = GetPedInVehicleSeat(veh, seat)
                    if occupant ~= 0 and IsPedAPlayer(occupant) then
                        hasPlayer = true
                        break
                    end
                end
                if not hasPlayer then
                    DeleteEntity(veh)
                end
            end
        end
    end
end)

-- Continuously track last safe alive position and heading
CreateThread(function()
    while true do
        Wait(250)
        local ped = PlayerPedId()
        if DoesEntityExist(ped) then
            SetPedDropsWeaponsWhenDead(ped, false)
            if not IsEntityDead(ped) and not IsPedFatallyInjured(ped) then
                local coords = GetEntityCoords(ped)
                if coords.x ~= 0.0 or coords.y ~= 0.0 then
                    lastAliveCoords = coords
                    lastAliveHeading = GetEntityHeading(ped)
                end
            end
        end
    end
end)

-- Core function to respawn player at last location
local function RespawnAtLastLocation(forcedCoords, forcedHeading)
    if isDeadHandled then return end
    isDeadHandled = true

    CreateThread(function()
        local ped = PlayerPedId()
        local currentCoords = DoesEntityExist(ped) and GetEntityCoords(ped)

        -- Determine target coords: forcedCoords > ground death coords > lastAliveCoords
        local targetCoords = forcedCoords
        if not targetCoords then
            if currentCoords and (currentCoords.x ~= 0.0 or currentCoords.y ~= 0.0) then
                targetCoords = vector3(currentCoords.x, currentCoords.y, currentCoords.z + 0.15)
            elseif lastAliveCoords then
                targetCoords = lastAliveCoords
            else
                targetCoords = currentCoords
            end
        end

        local targetHeading = forcedHeading or (DoesEntityExist(ped) and GetEntityHeading(ped)) or lastAliveHeading or 0.0

        -- Brief pause for death animation
        Wait(1500)

        DoScreenFadeOut(500)
        while not IsScreenFadedOut() do
            Wait(50)
        end

        ped = PlayerPedId()

        -- Leave vehicle if dead inside one
        if IsPedInAnyVehicle(ped, true) then
            local veh = GetVehiclePedIsIn(ped, true)
            TaskLeaveVehicle(ped, veh, 16)
            Wait(100)
        end

        -- Clear any GTA V death screen effects / timecycles
        ClearTimecycleModifier()
        StopScreenEffect('DeathFailMP01')
        StopScreenEffect('DeathFailNeutralIn')
        StopScreenEffect('DeathFailOut')

        -- Preload collisions around last location
        if targetCoords then
            RequestCollisionAtCoord(targetCoords.x, targetCoords.y, targetCoords.z)
            NetworkResurrectLocalPlayer(targetCoords.x, targetCoords.y, targetCoords.z, targetHeading, true, true, false)
            SetEntityCoordsNoOffset(ped, targetCoords.x, targetCoords.y, targetCoords.z, false, false, false, true)
            SetEntityHeading(ped, targetHeading)
        end

        SetEntityHealth(ped, 200)
        ClearPedTasksImmediately(ped)
        ClearPedBloodDamage(ped)
        ClearPedInjuredExpression(ped)

        -- Trigger framework revive and HUD events
        TriggerEvent('hospital:client:Revive')
        TriggerEvent('pradipta-core:client:OnPlayerLoaded')
        TriggerEvent('hud:client:ToggleHealth')
        TriggerEvent('hud:client:UpdateNeeds', 100, 100)

        -- Keep spawnmanager auto-spawn disabled so it never random-spawns player
        if exports.spawnmanager then
            exports.spawnmanager:setAutoSpawn(false)
        end

        Wait(500)
        DoScreenFadeIn(600)

        Wait(1000)
        isDeadHandled = false
    end)
end

-- Override spawnmanager so it never sends player to random spawn points
local function configureSpawnManager()
    if exports.spawnmanager then
        exports.spawnmanager:setAutoSpawnCallback(function()
            RespawnAtLastLocation()
        end)
        exports.spawnmanager:setAutoSpawn(false)
    end
end

CreateThread(function()
    Wait(500)
    configureSpawnManager()
end)

AddEventHandler('onClientMapStart', function()
    Wait(500)
    configureSpawnManager()
end)

-- Active thread detecting player death immediately
CreateThread(function()
    while true do
        Wait(150)
        local ped = PlayerPedId()
        if DoesEntityExist(ped) and (IsEntityDead(ped) or IsPedFatallyInjured(ped)) and not isDeadHandled then
            RespawnAtLastLocation()
        end
    end
end)

-- baseevents hooks as additional fallbacks
AddEventHandler('baseevents:onPlayerDied', function(_, coords)
    local target = (coords and vector3(coords[1], coords[2], coords[3])) or nil
    RespawnAtLastLocation(target)
end)

AddEventHandler('baseevents:onPlayerKilled', function(_, killData)
    RespawnAtLastLocation()
end)

AddEventHandler('baseevents:onPlayerWasted', function(coords)
    local target = (coords and vector3(coords[1], coords[2], coords[3])) or nil
    RespawnAtLastLocation(target)
end)
