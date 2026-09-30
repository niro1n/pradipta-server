-- Event Handler

AddEventHandler('chatMessage', function(_, _, message)
    if string.sub(message, 1, 1) == '/' then
        CancelEvent()
        return
    end
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    if not PradiptaCore.Players[src] then return end
    local player = PradiptaCore.Players[src]
    TriggerEvent('pradipta-log:server:CreateLog', 'joinleave', 'Dropped', 'red', '**' .. GetPlayerName(src) .. '** (' .. player.PlayerData.license .. ') left..' .. '\n **Reason:** ' .. reason)
    player.Functions.Save()
    TriggerEvent('PradiptaCore:Server:PlayerDropped', src)
    TriggerEvent('PradiptaCore:Server:OnPlayerUnload', src)
    PradiptaCore.Player_Buckets[player.PlayerData.license] = nil
    PradiptaCore.PlayersByCitizenId[player.PlayerData.citizenid] = nil
    PradiptaCore.Players[src] = nil
end)

AddEventHandler('onResourceStop', function(resName)
    for i, v in pairs(PradiptaCore.UsableItems) do
        if v.resource == resName then
            PradiptaCore.UsableItems[i] = nil
        end
    end
end)

-- Player Connecting
local readyFunction = MySQL.ready
local databaseConnected, bansTableExists = readyFunction == nil, readyFunction == nil
if readyFunction ~= nil then
    MySQL.ready(function()
        databaseConnected = true

        local DatabaseInfo = PradiptaCore.Functions.GetDatabaseInfo()
        if not DatabaseInfo or not DatabaseInfo.exists then return end

        local result = MySQL.query.await('SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = ? AND TABLE_NAME = "bans";', { DatabaseInfo.database })
        if result and result[1] then
            bansTableExists = true
        end
    end)
end

local function onPlayerConnecting(name, _, deferrals)
    local src = source
    deferrals.defer()

    if PradiptaCore.Config.Server.Closed and not IsPlayerAceAllowed(src, 'pradiptaadmin.join') then
        return deferrals.done(PradiptaCore.Config.Server.ClosedReason)
    end

    if not databaseConnected then
        return deferrals.done(Lang:t('error.connecting_database_error'))
    end

    if PradiptaCore.Config.Server.Whitelist then
        Wait(0)
        deferrals.update(string.format(Lang:t('info.checking_whitelisted'), name))
        if not PradiptaCore.Functions.IsWhitelisted(src) then
            return deferrals.done(Lang:t('error.not_whitelisted'))
        end
    end

    Wait(0)
    deferrals.update(string.format('Hello %s. Your license is being checked', name))
    local license = PradiptaCore.Functions.GetIdentifier(src, 'license')

    if not license then
        return deferrals.done(Lang:t('error.no_valid_license'))
    elseif PradiptaCore.Config.Server.CheckDuplicateLicense and PradiptaCore.Functions.IsLicenseInUse(license) then
        return deferrals.done(Lang:t('error.duplicate_license'))
    end

    Wait(0)
    deferrals.update(string.format(Lang:t('info.checking_ban'), name))

    if not bansTableExists then
        return deferrals.done(Lang:t('error.ban_table_not_found'))
    end

    local success, isBanned, reason = pcall(PradiptaCore.Functions.IsPlayerBanned, src)
    if not success then return deferrals.done(Lang:t('error.connecting_database_error')) end
    if isBanned then return deferrals.done(reason) end

    Wait(0)
    deferrals.update(string.format(Lang:t('info.join_server'), name))
    deferrals.done()

    TriggerClientEvent('PradiptaCore:Client:SharedUpdate', src, PradiptaCore.Shared)
end

AddEventHandler('playerConnecting', onPlayerConnecting)

-- Open & Close Server (prevents players from joining)

RegisterNetEvent('PradiptaCore:Server:CloseServer', function(reason)
    local src = source
    if PradiptaCore.Functions.HasPermission(src, 'admin') then
        reason = reason or 'No reason specified'
        PradiptaCore.Config.Server.Closed = true
        PradiptaCore.Config.Server.ClosedReason = reason
        for k in pairs(PradiptaCore.Players) do
            if not PradiptaCore.Functions.HasPermission(k, PradiptaCore.Config.Server.WhitelistPermission) then
                PradiptaCore.Functions.Kick(k, reason, nil, nil)
            end
        end
    else
        PradiptaCore.Functions.Kick(src, Lang:t('error.no_permission'), nil, nil)
    end
end)

RegisterNetEvent('PradiptaCore:Server:OpenServer', function()
    local src = source
    if PradiptaCore.Functions.HasPermission(src, 'admin') then
        PradiptaCore.Config.Server.Closed = false
    else
        PradiptaCore.Functions.Kick(src, Lang:t('error.no_permission'), nil, nil)
    end
end)

-- Callback Events --

-- Client Callback
RegisterNetEvent('PradiptaCore:Server:TriggerClientCallback', function(name, ...)
    local ClientCallback = PradiptaCore.ClientCallbacks[name .. source]
    if ClientCallback then
        ClientCallback.promise:resolve(...)

        if ClientCallback.callback then
            ClientCallback.callback(...)
        end

        PradiptaCore.ClientCallbacks[name .. source] = nil
    end
end)

-- Server Callback
RegisterNetEvent('PradiptaCore:Server:TriggerCallback', function(name, ...)
    if not PradiptaCore.ServerCallbacks[name] then return end

    local src = source

    PradiptaCore.ServerCallbacks[name](src, function(...)
        TriggerClientEvent('PradiptaCore:Client:TriggerCallback', src, name, ...)
    end, ...)
end)

-- Player

local updateCooldowns = {}
RegisterNetEvent('PradiptaCore:UpdatePlayer', function()
    local src = source
    local now = GetGameTimer()
    if updateCooldowns[src] and (now - updateCooldowns[src]) < 10000 then return end
    updateCooldowns[src] = now
    local Player = PradiptaCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.PlayerData.metadata['hunger'] = 100
    Player.PlayerData.metadata['thirst'] = 100
    Player.Functions.UpdateClient('metadata', Player.PlayerData.metadata)
    TriggerClientEvent('hud:client:UpdateNeeds', src, 100, 100)
    Player.Functions.Save()
end)

RegisterNetEvent('PradiptaCore:ToggleDuty', function()
    local src = source
    local Player = PradiptaCore.Functions.GetPlayer(src)
    if not Player then return end
    if Player.PlayerData.job.onduty then
        Player.Functions.SetJobDuty(false)
        TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('info.off_duty'))
    else
        Player.Functions.SetJobDuty(true)
        TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('info.on_duty'))
    end

    TriggerEvent('PradiptaCore:Server:SetDuty', src, Player.PlayerData.job.onduty)
    TriggerClientEvent('PradiptaCore:Client:SetDuty', src, Player.PlayerData.job.onduty)
end)

RegisterNetEvent('PradiptaCore:Server:OnPlayerLoaded', function()
    local src = source
    if not PradiptaCore.Players[src] then return end
    TriggerClientEvent('PradiptaCore:Client:OnPlayerLoaded', src)
end)

-- Central server-side data change handler — re-fires legacy events for backward compat
AddEventHandler('PradiptaCore:Server:OnPlayerUpdated', function(src, key, val)
    if key == 'job' then
        TriggerEvent('PradiptaCore:Server:OnJobUpdate', src, val)
    elseif key == 'gang' then
        TriggerEvent('PradiptaCore:Server:OnGangUpdate', src, val)
    elseif key == 'all' then
        TriggerEvent('PradiptaCore:Server:OnJobUpdate', src, val.job)
        TriggerEvent('PradiptaCore:Server:OnGangUpdate', src, val.gang)
    end
end)

-- BaseEvents

-- Vehicles
RegisterServerEvent('baseevents:enteringVehicle', function(veh, seat, modelName)
    local src = source
    local data = {
        vehicle = veh,
        seat = seat,
        name = modelName,
        event = 'Entering'
    }
    TriggerClientEvent('PradiptaCore:Client:VehicleInfo', src, data)
end)

RegisterServerEvent('baseevents:enteredVehicle', function(veh, seat, modelName)
    local src = source
    local data = {
        vehicle = veh,
        seat = seat,
        name = modelName,
        event = 'Entered'
    }
    TriggerClientEvent('PradiptaCore:Client:VehicleInfo', src, data)
end)

RegisterServerEvent('baseevents:enteringAborted', function()
    local src = source
    TriggerClientEvent('PradiptaCore:Client:AbortVehicleEntering', src)
end)

RegisterServerEvent('baseevents:leftVehicle', function(veh, seat, modelName)
    local src = source
    local data = {
        vehicle = veh,
        seat = seat,
        name = modelName,
        event = 'Left'
    }
    TriggerClientEvent('PradiptaCore:Client:VehicleInfo', src, data)
end)

-- Non-Chat Command Calling (ex: pradipta-adminmenu)

RegisterNetEvent('PradiptaCore:CallCommand', function(command, args)
    local src = source
    if not PradiptaCore.Commands.List[command] then return end
    local Player = PradiptaCore.Functions.GetPlayer(src)
    if not Player then return end
    local hasPerm = PradiptaCore.Functions.HasPermission(src, 'command.' .. PradiptaCore.Commands.List[command].name)
    if hasPerm then
        if PradiptaCore.Commands.List[command].argsrequired and #PradiptaCore.Commands.List[command].arguments ~= 0 and not args[#PradiptaCore.Commands.List[command].arguments] then
            TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('error.missing_args2'), 'error')
        else
            PradiptaCore.Commands.List[command].callback(src, args)
        end
    else
        TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('error.no_access'), 'error')
    end
end)

-- Use this for player vehicle spawning
-- Vehicle server-side spawning callback (netId)
-- use the netid on the client with the NetworkGetEntityFromNetworkId native
-- convert it to a vehicle via the NetToVeh native
PradiptaCore.Functions.CreateCallback('PradiptaCore:Server:SpawnVehicle', function(source, cb, model, coords, warp)
    local veh = PradiptaCore.Functions.SpawnVehicle(source, model, coords, warp)
    cb(DoesEntityExist(veh) and NetworkGetNetworkIdFromEntity(veh) or nil)
end)

-- Use this for long distance vehicle spawning
-- vehicle server-side spawning callback (netId)
-- use the netid on the client with the NetworkGetEntityFromNetworkId native
-- convert it to a vehicle via the NetToVeh native
PradiptaCore.Functions.CreateCallback('PradiptaCore:Server:CreateVehicle', function(source, cb, model, coords, warp)
    local veh = PradiptaCore.Functions.CreateAutomobile(source, model, coords, warp)
    cb(DoesEntityExist(veh) and NetworkGetNetworkIdFromEntity(veh) or nil)
end)

--PradiptaCore.Functions.CreateCallback('PradiptaCore:HasItem', function(source, cb, items, amount)
-- https://github.com/pradiptacore-framework/pradipta-inventory/blob/e4ef156d93dd1727234d388c3f25110c350b3bcf/server/main.lua#L2066
--end)
