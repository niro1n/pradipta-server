local deadCoords = nil
local isDeadHandled = false

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

AddEventHandler('baseevents:onPlayerDied', function(_, coords)
    if isDeadHandled then return end
    isDeadHandled = true
    deadCoords = vector3(coords[1], coords[2], coords[3])
    ReviveAtLocation(deadCoords)
end)

AddEventHandler('baseevents:onPlayerKilled', function(_, killData)
    if isDeadHandled then return end
    isDeadHandled = true
    local pos = killData.killerpos
    local ped = PlayerPedId()
    deadCoords = GetEntityCoords(ped)
    ReviveAtLocation(deadCoords)
end)

AddEventHandler('baseevents:onPlayerWasted', function(coords)
    if isDeadHandled then return end
    isDeadHandled = true
    deadCoords = vector3(coords[1], coords[2], coords[3])
    ReviveAtLocation(deadCoords)
end)

function ReviveAtLocation(coords)
    CreateThread(function()
        Wait(3000)

        local ped = PlayerPedId()

        DoScreenFadeOut(300)
        Wait(600)

        NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
        SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
        SetEntityHealth(ped, 200)
        ClearPedBloodDamage(ped)
        ClearPedInjuredExpression(ped)

        Wait(500)
        DoScreenFadeIn(400)

        isDeadHandled = false
        deadCoords = nil
    end)
end
