local PradiptaCore = exports['pradipta-core']:GetCoreObject({ 'Functions', 'Commands' })
local trunkBusy = {}

function IsCloseToTarget(source, target)
    if not DoesPlayerExist(target) then return false end
    return #(GetEntityCoords(GetPlayerPed(source)) - GetEntityCoords(GetPlayerPed(target))) < 2.0
end

RegisterNetEvent('pradipta-radialmenu:trunk:server:Door', function(open, plate, door)
    local src = source
    local ped = GetPlayerPed(src)
    if ped <= 0 then return end

    local playerCoords = GetEntityCoords(ped)
    if not playerCoords then return end

    local vehicle = GetClosestVehicle(playerCoords.x, playerCoords.y, playerCoords.z, 10.0, 0, 70)
    if vehicle == 0 then return end

    local targetPlate = PradiptaCore.Shared.Trim(plate)
    local closestVehiclePlate = PradiptaCore.Shared.Trim(GetVehicleNumberPlateText(vehicle))
    if not targetPlate or not closestVehiclePlate or targetPlate ~= closestVehiclePlate then return end

    local vehicleCoords = GetEntityCoords(vehicle)
    if not vehicleCoords then return end
    if #(playerCoords - vehicleCoords) > 2.0 then return end

    TriggerClientEvent('pradipta-radialmenu:trunk:client:Door', -1, plate, door, open)
end)

RegisterNetEvent('pradipta-trunk:server:setTrunkBusy', function(plate, busy)
    trunkBusy[plate] = busy
end)

RegisterNetEvent('pradipta-trunk:server:KidnapTrunk', function(target, closestVehicle)
    local src = source
    if not IsCloseToTarget(src, target) then return end
    TriggerClientEvent('pradipta-trunk:client:KidnapGetIn', target, closestVehicle)
end)

PradiptaCore.Functions.CreateCallback('pradipta-trunk:server:getTrunkBusy', function(_, cb, plate)
    if trunkBusy[plate] then
        cb(true)
        return
    end
    cb(false)
end)

PradiptaCore.Commands.Add('getintrunk', Lang:t('general.getintrunk_command_desc'), {}, false, function(source)
    TriggerClientEvent('pradipta-trunk:client:GetIn', source)
end)

PradiptaCore.Commands.Add('putintrunk', Lang:t('general.putintrunk_command_desc'), {}, false, function(source)
    TriggerClientEvent('pradipta-trunk:server:KidnapTrunk', source)
end)
