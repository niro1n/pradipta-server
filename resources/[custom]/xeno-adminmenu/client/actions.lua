local isSpectating = false
local lastSpectateCoord = nil

local standardActions = {
    'spectate', 'heal', 'fixVehicle', 'freeze', 'goto', 'bring', 'kill', 'slap', 'toggleDrunk'
}

for _, action in ipairs(standardActions) do
    RegisterNUICallback(action, function(data, cb)
        TriggerServerEvent('xeno-adminmenu:server:Action', action, data.playerId)
        if cb then cb('ok') end
    end)
end

RegisterNUICallback('trollAction', function(data, cb)
    local targetId = data.playerId
    if not targetId then
        targetId = GetPlayerServerId(PlayerId())
    end
    TriggerServerEvent('xeno-adminmenu:server:Action', data.action, targetId)
    if cb then cb('ok') end
end)

RegisterNUICallback('noclip', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:ToggleNoClip')
    if cb then cb('ok') end
end)

local isGodmode = false
local isVehicleGodmode = false
local isInvisible = false
local isSuperJump = false
local isFastRun = false
local isInfiniteStamina = false
local showPlayerIds = false
local showCoords = false

RegisterNUICallback('godMode', function(data, cb)
    local ped = PlayerPedId()
    if data.type == 'vehicle' then
        isVehicleGodmode = data.state
        local veh = GetVehiclePedIsIn(ped, false)
        if veh ~= 0 then
            SetEntityInvincible(veh, isVehicleGodmode)
        end
    else
        isGodmode = data.state
        SetEntityInvincible(ped, isGodmode)
    end
    if cb then cb('ok') end
end)

RegisterNUICallback('invisibility', function(data, cb)
    local ped = PlayerPedId()
    isInvisible = data.state
    SetEntityVisible(ped, not isInvisible, false)
    if cb then cb('ok') end
end)

RegisterNUICallback('superJump', function(data, cb)
    isSuperJump = data.state
    if cb then cb('ok') end
end)

RegisterNUICallback('fastRun', function(data, cb)
    local ped = PlayerPedId()
    isFastRun = data.state
    if isFastRun then
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.49)
    else
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    end
    if cb then cb('ok') end
end)

RegisterNUICallback('infiniteStamina', function(data, cb)
    isInfiniteStamina = data.state
    if cb then cb('ok') end
end)

RegisterNUICallback('playerIds', function(data, cb)
    showPlayerIds = data.state
    if cb then cb('ok') end
end)

RegisterNUICallback('changeCoordsShowStatus', function(data, cb)
    showCoords = data.state
    if not showCoords then
        SendNUIMessage({
            action = 'updateCoords',
            visible = false
        })
    end
    if cb then cb('ok') end
end)

local function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 150)
    end
end

local function DrawText2D(x, y, text)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(0.4, 0.4)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

CreateThread(function()
    while true do
        local sleep = 1000

        if isSuperJump then
            sleep = 0
            SetSuperJumpThisFrame(PlayerId())
        end

        if isInfiniteStamina then
            sleep = 0
            RestorePlayerStamina(PlayerId(), 1.0)
        end

        if isVehicleGodmode then
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsIn(ped, false)
            if veh ~= 0 then
                sleep = 500
                SetEntityInvincible(veh, true)
                SetVehicleCanBreak(veh, false)
                SetVehicleCanYieldToExplosions(veh, false)
                SetVehicleExplodesOnHighExplosionDamage(veh, false)
                SetEntityOnlyDamagedByPlayer(veh, false)
            end
        end

        if showPlayerIds then
            sleep = 0
            for _, player in ipairs(GetActivePlayers()) do
                local targetPed = GetPlayerPed(player)
                if IsEntityVisible(targetPed) then
                    local coords = GetEntityCoords(targetPed)
                    local dist = #(GetEntityCoords(PlayerPedId()) - coords)
                    if dist < 50.0 then
                        DrawText3D(coords.x, coords.y, coords.z + 1.0, "["..GetPlayerServerId(player).."] " .. GetPlayerName(player))
                    end
                end
            end
        end

        if showCoords then
            if sleep > 50 then sleep = 50 end
            local coords = GetEntityCoords(PlayerPedId())
            local heading = GetEntityHeading(PlayerPedId())
            SendNUIMessage({
                action = 'updateCoords',
                visible = true,
                coords = { x = coords.x, y = coords.y, z = coords.z, h = heading }
            })
        end

        Wait(sleep)
    end
end)

RegisterNUICallback('setWaypoint', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:Action', 'setWaypoint', data.playerId)
    if cb then cb('ok') end
end)

RegisterNUICallback('getItems', function(data, cb)
    if cb then cb({}) end
end)

RegisterNUICallback('kick', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:ActionWithInput', 'kick', data.playerId, "Kicked by Admin")
    if cb then cb('ok') end
end)

RegisterNUICallback('banPlayer', function(data, cb)

    TriggerServerEvent('xeno-adminmenu:server:BanPlayer', data.playerId, data.isOffline, data.reason, data.durationHours)
    if cb then cb('ok') end
end)

RegisterNUICallback('fetchBans', function(data, cb)

    TriggerServerEvent('xeno-adminmenu:server:FetchBans', data.page, data.limit, data.search, data.filter)
    if cb then cb('ok') end
end)

RegisterNUICallback('unbanPlayer', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:UnbanPlayer', data.banId)
    if cb then cb('ok') end
end)

RegisterNUICallback('editBan', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:EditBan', data.banId, data.newData)
    if cb then cb('ok') end
end)



RegisterNUICallback('changeWarn', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:ChangeWarn', data.warnId, data.changeType, data.active)
    if cb then cb('ok') end
end)

RegisterNUICallback('setLiveDataStatus', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:SetLiveDataStatus', data.playerId, data.status)
    if cb then cb('ok') end
end)

RegisterNUICallback('giveItem', function(data, cb)
    local target = data.playerId or GetPlayerServerId(PlayerId())
    TriggerServerEvent('xeno-adminmenu:server:GiveItem', target, data.item, data.count or data.amount)
    if cb then cb('ok') end
end)

RegisterNUICallback('removeItem', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:RemoveItem', data.playerId, data.item, data.count)
    if cb then cb('ok') end
end)

RegisterNUICallback('inspectInventory', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:InspectInventory', data.playerId)
    if cb then cb(true) end
end)

RegisterNetEvent('xeno-adminmenu:client:OpenTargetInventory', function(targetId, invType)
    if invType == 'pradipta-inventory' or invType == 'ps-inventory' or invType == 'lj-inventory' or invType == 'qs-inventory' then
        TriggerServerEvent("inventory:server:OpenInventory", "otherplayer", targetId)
    end
end)

RegisterNUICallback('giveMoney', function(data, cb)
    local target = data.playerId or GetPlayerServerId(PlayerId())
    TriggerServerEvent('xeno-adminmenu:server:GiveMoney', target, data.account, data.amount)
    if cb then cb('ok') end
end)

RegisterNUICallback('clearInventory', function(data, cb)
    local target = data.playerId or GetPlayerServerId(PlayerId())
    TriggerServerEvent('xeno-adminmenu:server:ClearInventory', target)
    if cb then cb('ok') end
end)

RegisterNUICallback('healSelf', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:Action', 'heal', GetPlayerServerId(PlayerId()))
    if cb then cb('ok') end
end)

RegisterNUICallback('requestItemsList', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:RequestItemsList')
    if cb then cb('ok') end
end)

RegisterNUICallback('requestVehiclesList', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:RequestVehiclesList')
    if cb then cb('ok') end
end)

RegisterNUICallback('spawnVehicle', function(data, cb)
    TriggerEvent('xeno-adminmenu:client:SpawnVehicle', data.text)
    if cb then cb('ok') end
end)

RegisterNUICallback('repairVehicle', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        SetVehicleFixed(vehicle)
        SetVehicleDeformationFixed(vehicle)
        SetVehicleUndriveable(vehicle, false)
        SetVehicleEngineOn(vehicle, true, true)
    end
    if cb then cb('ok') end
end)

RegisterNUICallback('flipVehicle', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        local coords = GetEntityCoords(vehicle)
        SetEntityCoords(vehicle, coords.x, coords.y, coords.z + 1.0, false, false, false, false)
        SetVehicleOnGroundProperly(vehicle)
    end
    if cb then cb('ok') end
end)

RegisterNUICallback('upgradeVehicle', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        SetVehicleModKit(vehicle, 0)
        for i = 0, 49 do
            local max = GetNumVehicleMods(vehicle, i) - 1
            if max >= 0 then
                SetVehicleMod(vehicle, i, max, false)
            end
        end
        ToggleVehicleMod(vehicle, 18, true)
        ToggleVehicleMod(vehicle, 22, true)
    end
    if cb then cb('ok') end
end)

RegisterNUICallback('allAction', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:AllAction', data.type, data.reason)
    if cb then cb('ok') end
end)

RegisterNUICallback('tpm', function(data, cb)
    ExecuteCommand("tpm")
    if cb then cb('ok') end
end)

RegisterNUICallback('setWeather', function(data, cb)
    DebugLog('[WeatherSync TRACE] NUI callback setWeather received: ' .. tostring(data.weather))
    TriggerServerEvent('xeno-adminmenu:server:setWeather', data.weather)
    if cb then cb('ok') end
end)

RegisterNUICallback('setTime', function(data, cb)
    DebugLog('[WeatherSync TRACE] NUI callback setTime received: ' .. tostring(data.time))
    local timeStr = data.time
    local hour, minute = string.match(timeStr, "(%d+):(%d+)")
    if hour and minute then
        TriggerServerEvent('xeno-adminmenu:server:setTime', tonumber(hour), tonumber(minute))
    end
    if cb then cb('ok') end
end)

RegisterNUICallback('blackout', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:toggleBlackout', data.state)
    if cb then cb('ok') end
end)

RegisterNUICallback('dynamicWater', function(data, cb)
    if Config.WeatherSync.Enabled then
        TriggerServerEvent('xeno-adminmenu:server:toggleDynamicWater', data.state)
    end
    if cb then cb('ok') end
end)

RegisterNUICallback('dynamicWeather', function(data, cb)
    if Config.WeatherSync.Enabled then
        TriggerServerEvent('xeno-adminmenu:server:toggleDynamicWeather', data.state)
    end
    if cb then cb('ok') end
end)

RegisterNUICallback('instantWeather', function(data, cb)

    if Config.WeatherSync.Enabled then
        _G.XenoInstantWeather = data.state
        DebugLog('[WeatherSync] Instant weather set to: ' .. tostring(data.state))
    end
    if cb then cb('ok') end
end)

RegisterNUICallback('tsunami', function(data, cb)

    if data.state then
        SetWeatherTypeNowPersist('THUNDER')
        SetWeatherTypeNow('THUNDER')
        SetWeatherTypePersist('THUNDER')
        SetRainFxIntensity(1.0)
        SetDeepOceanScaler(30.0)
        SetWindSpeed(50.0)
        SetWindDirection(math.random() * 360.0)
        ShakeGameplayCam('MEDIUM_EXPLOSION_SHAKE', 0.15)
    else
        SetRainFxIntensity(-1.0)
        SetDeepOceanScaler(0.0)
        SetWindSpeed(0.0)
        ResetScenarioTypesEnabled()
        StopGameplayCamShaking(true)

        TriggerServerEvent('xeno-adminmenu:server:requestSyncState')
    end
    if cb then cb('ok') end
end)

RegisterNUICallback('deleteObjects', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:ClearArea', data.type)
    if cb then cb('ok') end
end)

RegisterNUICallback('changeSkin', function(data, cb)
    if GetResourceState('pradipta-clothing') == 'started' then
        TriggerEvent('pradipta-clothing:client:openOutfitMenu')
    elseif GetResourceState('illenium-appearance') == 'started' then
        TriggerEvent('illenium-appearance:client:openOutfitMenu')
    elseif GetResourceState('fivem-appearance') == 'started' then
        TriggerEvent('fivem-appearance:client:openOutfitMenu')
    end
    if cb then cb('ok') end
end)

RegisterNUICallback('clothingMenu', function(data, cb)
    if GetResourceState('pradipta-clothing') == 'started' then
        TriggerEvent('pradipta-clothing:client:openMenu')
    elseif GetResourceState('illenium-appearance') == 'started' then
        TriggerEvent('illenium-appearance:client:openClothingShopMenu')
    elseif GetResourceState('fivem-appearance') == 'started' then
        TriggerEvent('fivem-appearance:client:openClothingShopMenu')
    end
    if cb then cb('ok') end
end)

RegisterNUICallback('actionWithInput', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:ActionWithInput', data.action, data.playerId, data.input)
    if cb then cb('ok') end
end)

RegisterNUICallback('announcement', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:GlobalAnnouncement', data)
    if cb then cb('ok') end
end)

RegisterNetEvent('xeno-adminmenu:client:ShowAnnouncement', function(data)
    PlaySoundFrontend(-1, "5s_To_Event_Start_Countdown", "GTAO_FM_Events_Soundset", true)
    SendNUIMessage({
        action = "showAnnouncement",
        data = data
    })
end)

RegisterNUICallback('refreshDashboard', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:RequestDashboardStats')
    if cb then cb('ok') end
end)

RegisterNUICallback('resource_refresh', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:RequestResources')
    if cb then cb('ok') end
end)

RegisterNUICallback('resource_start', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:ResourceAction', 'start', data.resName)
    if cb then cb('ok') end
end)

RegisterNUICallback('resource_stop', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:ResourceAction', 'stop', data.resName)
    if cb then cb('ok') end
end)

RegisterNUICallback('resource_restart', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:ResourceAction', 'restart', data.resName)
    if cb then cb('ok') end
end)



RegisterNetEvent('xeno-adminmenu:client:TerminalLog', function(logType, message)
    SendNUIMessage({
        action = "terminal_log",
        log = {
            id = math.random(100000, 999999),
            type = logType,
            message = message
        }
    })
end)

RegisterNetEvent('xeno-adminmenu:client:ReceiveResources', function(resources)
    SendNUIMessage({
        action = 'setResources',
        resources = resources
    })
end)

RegisterNetEvent('xeno-adminmenu:client:Spectate', function(targetServerId)
    local myPed = PlayerPedId()
    local targetPlayer = GetPlayerFromServerId(targetServerId)
    local targetPed = GetPlayerPed(targetPlayer)

    if not isSpectating then
        isSpectating = true
        SetEntityVisible(myPed, false)
        SetEntityCollision(myPed, false, false)
        SetEntityInvincible(myPed, true)
        NetworkSetEntityInvisibleToNetwork(myPed, true)
        lastSpectateCoord = GetEntityCoords(myPed)
        NetworkSetInSpectatorMode(true, targetPed)
    else
        isSpectating = false
        NetworkSetInSpectatorMode(false, targetPed)
        NetworkSetEntityInvisibleToNetwork(myPed, false)
        SetEntityCollision(myPed, true, true)
        if lastSpectateCoord then
            SetEntityCoords(myPed, lastSpectateCoord)
        end
        SetEntityVisible(myPed, true)
        SetEntityInvincible(myPed, false)
        lastSpectateCoord = nil
    end
end)

local isDrunk = false
RegisterNetEvent('xeno-adminmenu:client:ReceiveWarns', function(warns)
    SendNUIMessage({
        action = 'loadWarns',
        warns = warns
    })
end)

RegisterNetEvent('xeno-adminmenu:client:ReceiveBans', function(bans, totalBans)
    SendNUIMessage({
        action = 'loadBans',
        bans = bans,
        totalBans = totalBans
    })
end)

RegisterNetEvent('xeno-adminmenu:client:ReceiveItemsList', function(items)
    SendNUIMessage({
        action = 'loadAllItems',
        items = items
    })
end)

RegisterNetEvent('xeno-adminmenu:client:ReceiveVehiclesList', function(vehicles)
    SendNUIMessage({
        action = 'loadAllVehicles',
        vehicles = vehicles
    })
end)

RegisterNetEvent('xeno-adminmenu:client:UpdateLiveData', function(targetId, data)
    SendNUIMessage({
        action = 'updateLiveData',
        playerId = targetId,
        data = data
    })
end)

RegisterNetEvent('xeno-adminmenu:client:ExecuteAction', function(action)
    local ped = PlayerPedId()
    if action == 'heal' then
        if IsEntityDead(ped) then
            local pCoords = GetEntityCoords(ped)
            local pHeading = GetEntityHeading(ped)
            NetworkResurrectLocalPlayer(pCoords.x, pCoords.y, pCoords.z, pHeading, true, false)
        end
        SetEntityHealth(ped, 200)
        ClearPedBloodDamage(ped)
        ResetPedVisibleDamage(ped)
        ClearPedLastWeaponDamage(ped)
        ClearPedTasksImmediately(ped)
    elseif action == 'freeze' then
        local isFrozen = IsEntityPositionFrozen(ped)
        FreezeEntityPosition(ped, not isFrozen)
    elseif action == 'kill' then
        SetEntityHealth(ped, 0)
    elseif action == 'slap' then
        ApplyForceToEntity(ped, 1, 0.0, 0.0, 100.0, 0.0, 0.0, 0.0, 0, false, false, false, false, false)
    elseif action == 'toggleDrunk' then
        isDrunk = not isDrunk
        if isDrunk then
            RequestAnimSet("move_m@drunk@verydrunk")
            while not HasAnimSetLoaded("move_m@drunk@verydrunk") do Wait(10) end
            SetPedMovementClipset(ped, "move_m@drunk@verydrunk", 1.0)
            SetTimecycleModifier("spectator5")
        else
            ResetPedMovementClipset(ped, 1.0)
            ClearTimecycleModifier()
        end
    elseif action == 'fixVehicle' then
        local veh = GetVehiclePedIsIn(ped, false)
        if veh ~= 0 then
            SetVehicleFixed(veh)
            SetVehicleDirtLevel(veh, 0.0)
        end
    end
end)

RegisterNetEvent('xeno-adminmenu:client:SetWaypoint', function(targetCoords)
    SetNewWaypoint(targetCoords.x, targetCoords.y)
end)

RegisterNetEvent('xeno-adminmenu:client:SpawnVehicle', function(model)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    if not model or model == "" then return end

    local PradiptaCore = exports['pradipta-core']:GetCoreObject()
    PradiptaCore.Functions.SpawnVehicle(model, function(veh)
        SetEntityHeading(veh, heading)
        TaskWarpPedIntoVehicle(ped, veh, -1)
        local plate = PradiptaCore.Functions.GetPlate(veh)
        TriggerEvent("vehiclekeys:client:SetOwner", plate)
        if GetResourceState('pradipta-fuel') == 'started' then
            exports['pradipta-fuel']:SetFuel(veh, 100.0)
        end
        SetVehicleEngineOn(veh, true, true)
    end, coords, true, true)
end)

RegisterNetEvent('xeno-adminmenu:client:copyVector', function(dataType)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local text = ""
    if dataType == 'coords2' then
        text = string.format("vector2(%.2f, %.2f)", coords.x, coords.y)
    elseif dataType == 'coords3' then
        text = string.format("vector3(%.2f, %.2f, %.2f)", coords.x, coords.y, coords.z)
    elseif dataType == 'coords4' then
        text = string.format("vector4(%.2f, %.2f, %.2f, %.2f)", coords.x, coords.y, coords.z, heading)
    elseif dataType == 'heading' then
        text = string.format("%.2f", heading)
    end
    SendNUIMessage({
        action = 'copyToClipboard',
        string = text,
        text = text
    })
    TriggerEvent('chat:addMessage', {
        color = { 212, 175, 55 },
        multiline = true,
        args = { '[PRADIPTA]', 'Copied to clipboard: ' .. text }
    })
end)



RegisterNetEvent('xeno-adminmenu:client:ShowWarn', function(reason, author)
    SendNUIMessage({
        action = 'warn',
        reason = reason,
        author = author
    })
end)


RegisterNetEvent('xeno-adminmenu:client:OpenReportForm', function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openReportForm"
    })
end)

RegisterNUICallback('closeReportForm', function(data, cb)
    SetNuiFocus(false, false)
    if cb then cb('ok') end
end)

RegisterNUICallback('submitReport', function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent('xeno-adminmenu:server:SubmitReport', data)
    if cb then cb('ok') end
end)

RegisterNetEvent('xeno-adminmenu:client:ReceiveReports', function(reports)
    SendNUIMessage({
        action = "loadReports",
        reports = reports
    })
end)

RegisterNUICallback('fetchReports', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:FetchReports')
    if cb then cb('ok') end
end)

RegisterNUICallback('updateReportStatus', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:UpdateReportStatus', data.reportId, data.status)
    if cb then cb('ok') end
end)

RegisterNUICallback('fetchMyReports', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:FetchMyReports')
    if cb then cb('ok') end
end)

RegisterNetEvent('xeno-adminmenu:client:ReceiveMyReports', function(reports)
    SendNUIMessage({
        action = "loadMyReports",
        reports = reports
    })
end)


RegisterNUICallback('fetchChatMessages', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:RequestChatMessages')
    if cb then cb('ok') end
end)

RegisterNUICallback('sendNewMessage', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:SendChatMessage', data)
    if cb then cb('ok') end
end)

RegisterNetEvent('xeno-adminmenu:client:ReceiveChatMessages', function(messages)
    SendNUIMessage({
        action = "setChatMessages",
        messages = messages
    })
end)
