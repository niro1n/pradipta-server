local PradiptaCore = exports['pradipta-core']:GetCoreObject({ 'Functions' })
local sharedVehicles = exports['pradipta-core']:GetShared('Vehicles')
local OutsideVehicles = {}

-- Handler

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(100)
        if Config['AutoRespawn'] then
            MySQL.update('UPDATE player_vehicles SET state = 1 WHERE state = 0', {})
        else
            MySQL.update('UPDATE player_vehicles SET depotprice = 500 WHERE state = 0', {})
        end
    end
end)

-- Functions

local vehicleClasses = {
    compacts = 0,
    sedans = 1,
    suvs = 2,
    coupes = 3,
    muscle = 4,
    sportsclassics = 5,
    sports = 6,
    super = 7,
    motorcycles = 8,
    offroad = 9,
    industrial = 10,
    utility = 11,
    vans = 12,
    cycles = 13,
    boats = 14,
    helicopters = 15,
    planes = 16,
    service = 17,
    emergency = 18,
    military = 19,
    commercial = 20,
    trains = 21,
    openwheel = 22,
}

local function arrayToSet(array)
    local set = {}
    for _, item in ipairs(array) do
        set[item] = true
    end
    return set
end

local function filterVehiclesByCategory(vehicles, category)
    local filtered = {}
    local categorySet = arrayToSet(category)

    for _, vehicle in pairs(vehicles) do
        local vehicleData = sharedVehicles[vehicle.vehicle]
        local vehicleCategoryString = vehicleData and vehicleData.category or 'compacts'
        local vehicleCategoryNumber = vehicleClasses[vehicleCategoryString]

        if vehicleCategoryNumber and categorySet[vehicleCategoryNumber] then
            filtered[#filtered + 1] = vehicle
        end
    end

    return filtered
end

-- Callbacks

PradiptaCore.Functions.CreateCallback('pradipta-garages:server:getHouseGarage', function(_, cb, house)
    local houseInfo = MySQL.single.await('SELECT * FROM houselocations WHERE name = ?', { house })
    cb(houseInfo)
end)

PradiptaCore.Functions.CreateCallback('pradipta-garages:server:GetGarageVehicles', function(source, cb, garage, type, category)
    local Player = exports['pradipta-core']:GetPlayer(source)
    if not Player then return end
    local citizenId = Player.PlayerData.citizenid

    local vehicles

    if type == 'depot' then
        vehicles = MySQL.rawExecute.await('SELECT * FROM player_vehicles WHERE citizenid = ? AND depotprice > 0', { citizenId })
    elseif Config.SharedGarages then
        vehicles = MySQL.rawExecute.await('SELECT * FROM player_vehicles WHERE citizenid = ?', { citizenId })
    else
        vehicles = MySQL.rawExecute.await('SELECT * FROM player_vehicles WHERE citizenid = ? AND garage = ?', { citizenId, garage })
    end
    if #vehicles == 0 then
        cb(nil)
        return
    end
    if Config.ClassSystem then
        local filteredVehicles = filterVehiclesByCategory(vehicles, category)
        cb(filteredVehicles)
    else
        cb(vehicles)
    end
end)

-- Backwards Compat
local vehicleTypes = { -- https://docs.fivem.net/natives/?_0xA273060E
    motorcycles = 'bike',
    boats = 'boat',
    helicopters = 'heli',
    planes = 'plane',
    submarines = 'submarine',
    trailer = 'trailer',
    train = 'train'
}

local function GetVehicleTypeByModel(model)
    local vehicleData = sharedVehicles[model]
    if not vehicleData then return 'automobile' end
    local category = vehicleData.category
    local vehicleType = vehicleTypes[category]
    return vehicleType or 'automobile'
end
-- Backwards Compat

-- Spawns a vehicle and returns its network ID and properties.
PradiptaCore.Functions.CreateCallback('pradipta-garages:server:spawnvehicle', function(source, cb, plate, _, coords)
    local Player = exports['pradipta-core']:GetPlayer(source)
    if not Player then
        cb(nil, nil, nil)
        return
    end
    local ownedVehicle = MySQL.single.await('SELECT vehicle, mods FROM player_vehicles WHERE plate = ? AND citizenid = ? LIMIT 1', { plate, Player.PlayerData.citizenid })
    if not ownedVehicle then
        cb(nil, nil, nil)
        return
    end
    local vehType = sharedVehicles[ownedVehicle.vehicle] and sharedVehicles[ownedVehicle.vehicle].type or GetVehicleTypeByModel(ownedVehicle.vehicle)
    local hash = type(ownedVehicle.vehicle) == 'number' and ownedVehicle.vehicle or type(ownedVehicle.vehicle) == 'string' and GetHashKey(ownedVehicle.vehicle) or nil
    if not hash then
        cb(nil, nil, nil)
        return
    end
    local veh = CreateVehicleServerSetter(hash, vehType, coords.x, coords.y, coords.z, coords.w)
    local netId = NetworkGetNetworkIdFromEntity(veh)
    SetVehicleNumberPlateText(veh, plate)
    local vehProps = {}
    if ownedVehicle.mods then vehProps = json.decode(ownedVehicle.mods) end
    OutsideVehicles[plate] = { netID = netId, entity = veh }
    cb(netId, vehProps, plate)
end)

-- Checks if a vehicle can be spawned based on its type and location.
PradiptaCore.Functions.CreateCallback('pradipta-garages:server:IsSpawnOk', function(_, cb, plate, type)
    if OutsideVehicles[plate] and DoesEntityExist(OutsideVehicles[plate].entity) then
        cb(false)
        return
    end
    cb(true)
end)

PradiptaCore.Functions.CreateCallback('pradipta-garages:server:canDeposit', function(source, cb, plate, type, garage, state)
    local Player = exports['pradipta-core']:GetPlayer(source)
    local isOwned = MySQL.scalar.await('SELECT citizenid FROM player_vehicles WHERE plate = ? LIMIT 1', { plate })
    if isOwned ~= Player.PlayerData.citizenid then
        cb(false)
        return
    end
    if type == 'house' and (GetResourceState('pradipta-houses') ~= 'started' or not exports['pradipta-houses']:hasKey(Player.PlayerData.license, Player.PlayerData.citizenid, Config.Garages[garage].houseName)) then
        cb(false)
        return
    end
    if state == 1 then
        MySQL.update('UPDATE player_vehicles SET state = ?, garage = ? WHERE plate = ?', { state, garage, plate })
        cb(true)
    else
        cb(false)
    end
end)

-- Events

RegisterNetEvent('pradipta-garages:server:SaveVehicleProps', function(vehicleProps)
    local src = source
    local Player = exports['pradipta-core']:GetPlayer(src)
    if not Player or not vehicleProps or not vehicleProps.plate then return end
    MySQL.update('UPDATE player_vehicles SET mods = ? WHERE plate = ?', { json.encode(vehicleProps), vehicleProps.plate })
end)

RegisterNetEvent('pradipta-mechanicjob:server:SaveVehicleProps', function(vehicleProps)
    local src = source
    local Player = exports['pradipta-core']:GetPlayer(src)
    if not Player or not vehicleProps or not vehicleProps.plate then return end
    MySQL.update('UPDATE player_vehicles SET mods = ? WHERE plate = ?', { json.encode(vehicleProps), vehicleProps.plate })
end)

RegisterNetEvent('pradipta-garages:server:updateVehicleStats', function(plate, fuel, engine, body)
    local src = source
    local Player = exports['pradipta-core']:GetPlayer(src)
    if not Player then return end
    MySQL.update('UPDATE player_vehicles SET fuel = ?, engine = ?, body = ? WHERE plate = ? AND citizenid = ?', { fuel, engine, body, plate, Player.PlayerData.citizenid })
end)

RegisterNetEvent('pradipta-garages:server:updateVehicleState', function(state, plate)
    local src = source
    local Player = exports['pradipta-core']:GetPlayer(src)
    if not Player then return end
    MySQL.update('UPDATE player_vehicles SET state = ?, depotprice = ? WHERE plate = ? AND citizenid = ?', { state, 0, plate, Player.PlayerData.citizenid })
end)

RegisterNetEvent('pradipta-garages:server:UpdateOutsideVehicle', function(plate, vehicleNetID)
    OutsideVehicles[plate] = {
        netID = vehicleNetID,
        entity = NetworkGetEntityFromNetworkId(vehicleNetID)
    }
end)

RegisterNetEvent('pradipta-garages:server:trackVehicle', function(plate)
    local src = source
    local vehicleData = OutsideVehicles[plate]
    if vehicleData and DoesEntityExist(vehicleData.entity) then
        TriggerClientEvent('pradipta-garages:client:trackVehicle', src, GetEntityCoords(vehicleData.entity))
        TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('success.vehicle_tracked'), 'success')
    else
        TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('error.vehicle_not_tracked'), 'error')
    end
end)

RegisterNetEvent('pradipta-garages:server:PayDepotPrice', function(data)
    local src = source
    local Player = exports['pradipta-core']:GetPlayer(src)
    local cashBalance = Player.PlayerData.money['cash']
    local bankBalance = Player.PlayerData.money['bank']
    MySQL.scalar('SELECT depotprice FROM player_vehicles WHERE plate = ?', { data.plate }, function(result)
        if result then
            local depotPrice = result

            if cashBalance >= depotPrice then
                Player.RemoveMoney('cash', depotPrice, 'paid-depot')
                TriggerClientEvent('pradipta-garages:client:takeOutGarage', src, data)
            elseif bankBalance >= depotPrice then
                Player.RemoveMoney('bank', depotPrice, 'paid-depot')
                TriggerClientEvent('pradipta-garages:client:takeOutGarage', src, data)
            else
                TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('error.not_enough'), 'error')
            end
        end
    end)
end)

-- House Garages

RegisterNetEvent('pradipta-garages:server:syncGarage', function(updatedGarages)
    Config.Garages = updatedGarages
end)

--Call from pradipta-phone

PradiptaCore.Functions.CreateCallback('pradipta-garages:server:GetPlayerVehicles', function(source, cb)
    local Player = exports['pradipta-core']:GetPlayer(source)
    local Vehicles = {}

    MySQL.rawExecute('SELECT * FROM player_vehicles WHERE citizenid = ?', { Player.PlayerData.citizenid }, function(result)
        if result[1] then
            for _, v in pairs(result) do
                local VehicleData = sharedVehicles[v.vehicle]

                local VehicleGarage = Lang:t('error.no_garage')
                if v.garage ~= nil then
                    if Config.Garages[v.garage] ~= nil then
                        VehicleGarage = Config.Garages[v.garage].label
                    else
                        VehicleGarage = Lang:t('info.house')
                    end
                end

                local stateTranslation
                if v.state == 0 then
                    stateTranslation = Lang:t('status.out')
                elseif v.state == 1 then
                    stateTranslation = Lang:t('status.garaged')
                elseif v.state == 2 then
                    stateTranslation = Lang:t('status.impound')
                end

                local fullname
                if VehicleData and VehicleData['brand'] then
                    fullname = VehicleData['brand'] .. ' ' .. VehicleData['name']
                else
                    fullname = VehicleData and VehicleData['name'] or 'Unknown Vehicle'
                end

                Vehicles[#Vehicles + 1] = {
                    fullname = fullname,
                    brand = VehicleData and VehicleData['brand'] or '',
                    model = VehicleData and VehicleData['name'] or '',
                    plate = v.plate,
                    garage = VehicleGarage,
                    state = stateTranslation,
                    fuel = v.fuel,
                    engine = v.engine,
                    body = v.body
                }
            end
            cb(Vehicles)
        else
            cb(nil)
        end
    end)
end)

local function getAllGarages()
    local garages = {}
    for k, v in pairs(Config.Garages) do
        garages[#garages + 1] = {
            name = k,
            label = v.label,
            type = v.type,
            takeVehicle = v.takeVehicle,
            putVehicle = v.putVehicle,
            spawnPoint = v.spawnPoint,
            showBlip = v.showBlip,
            blipName = v.blipName,
            blipNumber = v.blipNumber,
            blipColor = v.blipColor,
            vehicle = v.vehicle
        }
    end
    return garages
end

exports('getAllGarages', getAllGarages)
