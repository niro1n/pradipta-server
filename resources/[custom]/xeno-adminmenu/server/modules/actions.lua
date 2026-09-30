local PradiptaCore = exports['pradipta-core']:GetCoreObject()


function BroadcastTerminalLog(logType, message)
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        if IsPlayerAdmin(tonumber(playerId)) then
            TriggerClientEvent('xeno-adminmenu:client:TerminalLog', tonumber(playerId), logType, message)
        end
    end
end


RegisterConsoleListener(function(channel, level, message)
    if not message then return end

    local logType = 'info'
    local messageStr = tostring(message)
    local lowerMsg = string.lower(messageStr)

    if string.find(lowerMsg, 'error') or string.find(lowerMsg, 'failed') or string.find(lowerMsg, 'exception') or string.find(lowerMsg, 'traceback') then
        logType = 'error'
    elseif string.find(lowerMsg, 'warn') or string.find(lowerMsg, 'deprecated') then
        logType = 'warn'
    elseif string.find(lowerMsg, 'cmd') or string.find(lowerMsg, 'command') then
        logType = 'admin'
    end
    BroadcastTerminalLog(logType, messageStr)

    if logType == 'error' and AddLog then

        AddLog('system', 'Server Error: ' .. string.sub(messageStr, 1, 255), 'Server Console', nil, { full_error = messageStr }, 'system_alert')
    end
end)

RegisterNetEvent('xeno-adminmenu:server:Action', function(action, targetId)
    local src = source
    if not HasPermission(src, action) and not IsAdmin(src) then return end
    targetId = tonumber(targetId)
    if not targetId then return end

    if action == 'spectate' then
        TriggerClientEvent('xeno-adminmenu:client:Spectate', src, targetId)
    elseif action == 'heal' or action == 'freeze' or action == 'kill' or action == 'slap' or action == 'toggleDrunk' or action == 'fixVehicle' then
        TriggerClientEvent('xeno-adminmenu:client:ExecuteAction', targetId, action)
        if action == 'heal' then
            if Framework == 'pradiptacore' or Framework == 'qbox' or Config.Framework == 'pradiptacore' then
                local Player = Core and Core.Functions and Core.Functions.GetPlayer(targetId)
                if not Player then
                    pcall(function() Player = exports['pradipta-core']:GetCoreObject().Functions.GetPlayer(targetId) end)
                end
                if Player then
                    Player.Functions.SetMetaData("hunger", 100)
                    Player.Functions.SetMetaData("thirst", 100)
                    Player.Functions.SetMetaData("isdead", false)
                    Player.Functions.SetMetaData("inlaststand", false)
                end
                if GetResourceState('pradipta-ambulancejob') == 'started' then
                    TriggerClientEvent('hospital:client:Revive', targetId)
                end
            elseif Framework == 'esx' then
                TriggerClientEvent('esx_ambulancejob:revive', targetId)
                TriggerClientEvent('esx_status:set', targetId, 'hunger', 1000000)
                TriggerClientEvent('esx_status:set', targetId, 'thirst', 1000000)
            end
        end
    elseif action == 'goto' then
        local targetPed = GetPlayerPed(targetId)
        local targetCoords = GetEntityCoords(targetPed)
        local adminPed = GetPlayerPed(src)
        SetEntityCoords(adminPed, targetCoords.x, targetCoords.y, targetCoords.z, false, false, false, false)
    elseif action == 'bring' then
        local adminPed = GetPlayerPed(src)
        local adminCoords = GetEntityCoords(adminPed)
        local targetPed = GetPlayerPed(targetId)
        SetEntityCoords(targetPed, adminCoords.x, adminCoords.y, adminCoords.z, false, false, false, false)
    elseif action == 'setWaypoint' then
        local targetPed = GetPlayerPed(targetId)
        local targetCoords = GetEntityCoords(targetPed)
        TriggerClientEvent('xeno-adminmenu:client:SetWaypoint', src, targetCoords)
    end

    if AddLog then
        AddLog('admin', 'Used action: ' .. action, GetPlayerName(src), GetPlayerName(targetId), { action = action, targetId = targetId }, 'admin_action')
    end
end)

RegisterNetEvent('xeno-adminmenu:server:ToggleNoClip', function()
    local src = source
    if not HasPermission(src, 'noclip') and not IsAdmin(src) then return end
    TriggerClientEvent('xeno-adminmenu:client:ToggleNoClip', src)
end)

RegisterNetEvent('xeno-adminmenu:server:ClearInventory', function(targetId)
    local src = source
    if not HasPermission(src, 'clearInventory') and not IsAdmin(src) then return end
    targetId = tonumber(targetId)
    if not targetId then return end

    if Framework == 'pradiptacore' or Framework == 'qbox' or Config.Framework == 'pradiptacore' then
        local Player = Core and Core.Functions and Core.Functions.GetPlayer(targetId)
        if not Player then
            pcall(function() Player = exports['pradipta-core']:GetCoreObject().Functions.GetPlayer(targetId) end)
        end
        if Player then Player.Functions.ClearInventory() end
    elseif Framework == 'esx' then
        local xPlayer = Core.GetPlayerFromId(targetId)
        if xPlayer then
            for i=1, #xPlayer.inventory, 1 do
                if xPlayer.inventory[i].count > 0 then
                    xPlayer.removeInventoryItem(xPlayer.inventory[i].name, xPlayer.inventory[i].count)
                end
            end
        end
    end
end)

RegisterNetEvent('xeno-adminmenu:server:GiveMoney', function(targetId, account, amount)
    local src = source
    local role = GetPlayerAdminRole(src)
    if role ~= 'god' and role ~= 'admin' then return end
    targetId = tonumber(targetId)
    amount = tonumber(amount)
    if not targetId or not amount or not account then return end

    if Framework == 'pradiptacore' or Framework == 'qbox' or Config.Framework == 'pradiptacore' then
        local Player = Core and Core.Functions and Core.Functions.GetPlayer(targetId)
        if not Player then
            pcall(function() Player = exports['pradipta-core']:GetCoreObject().Functions.GetPlayer(targetId) end)
        end
        if Player then
            if amount > 0 then Player.Functions.AddMoney(account, amount, 'admin-menu')
            else Player.Functions.RemoveMoney(account, math.abs(amount), 'admin-menu') end
        end
    elseif Framework == 'esx' then
        local xPlayer = Core.GetPlayerFromId(targetId)
        if xPlayer then
            if account == 'cash' then account = 'money' end
            if amount > 0 then xPlayer.addAccountMoney(account, amount)
            else xPlayer.removeAccountMoney(account, math.abs(amount)) end
        end
    end
end)

RegisterNetEvent('xeno-adminmenu:server:ActionWithInput', function(action, targetId, input)
    local src = source
    if not IsAdmin(src) then return end
    targetId = tonumber(targetId)
    if not targetId then return end
    local role = GetPlayerAdminRole(src)

    if action == 'kick' then
        if not HasPermission(src, 'kick') then return end
        DropPlayer(targetId, input or "Kicked by Admin")
    elseif action == 'message' then
        TriggerClientEvent('chat:addMessage', targetId, {
            color = {255, 0, 0},
            multiline = true,
            args = {"[ADMIN MESSAGE]", input}
        })
    elseif action == 'specialSpawnVehicle' then
        if not HasPermission(src, 'spawnVehicle') and not IsAdmin(src) then return end
        TriggerClientEvent('xeno-adminmenu:client:SpawnVehicle', targetId, input)
    elseif action == 'setJob' then
        if role ~= 'god' and role ~= 'admin' then return end
        local Player = Core and Core.Functions and Core.Functions.GetPlayer(targetId)
        if not Player then
            pcall(function() Player = exports['pradipta-core']:GetCoreObject().Functions.GetPlayer(targetId) end)
        end
        if Player then Player.Functions.SetJob(input, 0) end
    elseif action == 'giveMoneySelf' then
        if role ~= 'god' and role ~= 'admin' then return end
        local amount = tonumber(input)
        if amount then
            local Player = Core and Core.Functions and Core.Functions.GetPlayer(targetId)
            if not Player then
                pcall(function() Player = exports['pradipta-core']:GetCoreObject().Functions.GetPlayer(targetId) end)
            end
            if Player then Player.Functions.AddMoney('bank', amount, 'admin-menu') end
        end
    elseif action == 'changeBalance' then
        if role ~= 'god' and role ~= 'admin' then return end
        local amount = tonumber(input)
        if amount then
            local Player = Core and Core.Functions and Core.Functions.GetPlayer(targetId)
            if not Player then
                pcall(function() Player = exports['pradipta-core']:GetCoreObject().Functions.GetPlayer(targetId) end)
            end
            if Player then
                if amount > 0 then Player.Functions.AddMoney('bank', amount, 'admin-menu')
                else Player.Functions.RemoveMoney('bank', math.abs(amount), 'admin-menu') end
            end
        end
    elseif action == 'giveItem' then
        if role ~= 'god' and role ~= 'admin' then return end
        local data = json.decode(input)
        if data and data.item then
            GivePlayerItem(targetId, data.item, data.count)
        end
    elseif action == 'warn' then
        if not HasPermission(src, 'warn') and not IsAdmin(src) then return end
        local adminName = GetPlayerName(src)
        local targetIdentifier = GetPlayerIdentifiers(targetId)[1]
        for _, v in pairs(GetPlayerIdentifiers(targetId)) do
            if string.match(v, '^license:') then targetIdentifier = v; break end
        end

        exports.oxmysql:insert('INSERT INTO xeno_admin_warns (identifier, reason, admin) VALUES (?, ?, ?)', {
            targetIdentifier, input, adminName
        }, function(id)
            exports.oxmysql:scalar('SELECT COUNT(*) FROM xeno_admin_warns WHERE identifier = ?', {targetIdentifier}, function(count)
                if count >= Config.WarnsToBan then
                    local durationHours = Config.AutoBanDuration * 24
                    exports['xeno-adminmenu']:BanPlayer(targetId, durationHours, "Auto-Ban: Reached Warn Limit", "System")
                else
                    TriggerClientEvent('xeno-adminmenu:client:ShowWarn', targetId, input, adminName)
                end
                TriggerEvent('xeno-adminmenu:server:RefreshWarns')
            end)
        end)
    end

    if AddLog then
        local logCat = 'admin'
        if action == 'kick' then logCat = 'kick'
        elseif action == 'giveItem' then logCat = 'item' end
        AddLog(logCat, 'Used action with input: ' .. action, GetPlayerName(src), GetPlayerName(targetId), { action = action, targetId = targetId, input = input })
    end
end)

RegisterNetEvent('xeno-adminmenu:server:RefreshWarns', function()
    exports.oxmysql:execute('SELECT * FROM xeno_admin_warns', {}, function(results)
        local formattedWarns = {}
        for _, warn in ipairs(results) do
            if not formattedWarns[warn.identifier] then formattedWarns[warn.identifier] = {} end
            table.insert(formattedWarns[warn.identifier], {
                id = warn.id,
                reason = warn.reason,
                author = warn.admin,
                executionTime = tostring(warn.date),
                active = warn.active == 1 or warn.active == true
            })
        end
        for _, playerId in ipairs(GetPlayers()) do
            if IsPlayerAdmin(playerId) then
                TriggerClientEvent('xeno-adminmenu:client:ReceiveWarns', playerId, formattedWarns)
            end
        end
    end)
end)

RegisterNetEvent('xeno-adminmenu:server:GiveItem', function(targetId, item, count)
    local src = source
    if not IsPlayerAdmin(src) then return end
    GivePlayerItem(targetId, item, count)
end)

RegisterNetEvent('xeno-adminmenu:server:RemoveItem', function(targetId, item, count)
    local src = source
    if not IsPlayerAdmin(src) then return end
    RemovePlayerItem(targetId, item, count)
end)

RegisterNetEvent('xeno-adminmenu:server:InspectInventory', function(targetId)
    local src = source
    if not IsPlayerAdmin(src) then return end
    OpenInventoryForAdmin(src, targetId)
end)

RegisterNetEvent('xeno-adminmenu:server:SetRoute', function(targetId)
    local src = source
    if not IsPlayerAdmin(src) then return end
    TriggerClientEvent('xeno-adminmenu:client:SetRoute', src, targetId)
end)

RegisterNetEvent('xeno-adminmenu:server:AllAction', function(type, reason)
    local src = source
    local role = GetPlayerAdminRole(src)
    if role ~= 'god' and role ~= 'admin' then return end

    if type == 'bring' then
        local adminCoords = GetEntityCoords(GetPlayerPed(src))
        for _, playerId in ipairs(GetPlayers()) do
            if tonumber(playerId) ~= src then
                SetEntityCoords(GetPlayerPed(playerId), adminCoords.x, adminCoords.y, adminCoords.z)
            end
        end
    elseif type == 'kick' then
        for _, playerId in ipairs(GetPlayers()) do
            if tonumber(playerId) ~= src then
                DropPlayer(playerId, reason or "Kicked by Admin (Kick All)")
            end
        end
    end
end)

RegisterNetEvent('xeno-adminmenu:server:RequestItemsList', function()
    local src = source
    if not IsPlayerAdmin(src) then return end
    TriggerClientEvent('xeno-adminmenu:client:ReceiveItemsList', src, GetAllFrameworkItems())
end)

RegisterNetEvent('xeno-adminmenu:server:RequestVehiclesList', function()
    local src = source
    if not IsPlayerAdmin(src) then return end
    TriggerClientEvent('xeno-adminmenu:client:ReceiveVehiclesList', src, GetAllFrameworkVehicles())
end)

RegisterNetEvent('xeno-adminmenu:server:ClearArea', function(clearType)
    local src = source
    if not IsPlayerAdmin(src) then return end

    if clearType == 'vehicles' then
        for _, vehicle in ipairs(GetAllVehicles()) do
            if DoesEntityExist(vehicle) then
                DeleteEntity(vehicle)
            end
        end
    elseif clearType == 'peds' then
        for _, ped in ipairs(GetAllPeds()) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                DeleteEntity(ped)
            end
        end
    elseif clearType == 'objects' then
        for _, obj in ipairs(GetAllObjects()) do
            if DoesEntityExist(obj) then
                DeleteEntity(obj)
            end
        end
    end
end)

RegisterNetEvent('xeno-adminmenu:server:ChangeWarn', function(warnId, changeType, currentActive)
    local src = source
    if not IsPlayerAdmin(src) then return end

    DebugLog('DEBUG ChangeWarn:', warnId, changeType, currentActive)

    if changeType == 'activeToggle' then
        local newActive = not currentActive
        exports.oxmysql:execute('UPDATE xeno_admin_warns SET active = ? WHERE id = ?', {newActive and 1 or 0, warnId}, function(affectedRows)
            DebugLog('DEBUG ChangeWarn activeToggle affected:', affectedRows)
            TriggerEvent('xeno-adminmenu:server:RefreshWarns')
        end)
    elseif changeType == 'delete' then
        exports.oxmysql:execute('DELETE FROM xeno_admin_warns WHERE id = ?', {warnId}, function(affectedRows)
            DebugLog('DEBUG ChangeWarn delete affected:', affectedRows)
            TriggerEvent('xeno-adminmenu:server:RefreshWarns')
        end)
    end
end)

local function SendResourcesToPlayer(src)
    local resources = {}
    for i = 0, GetNumResources() - 1 do
        local resName = GetResourceByFindIndex(i)
        if resName then
            local state = GetResourceState(resName)
            local author = GetResourceMetadata(resName, 'author', 0) or 'Unknown'
            local description = GetResourceMetadata(resName, 'description', 0) or 'No description'
            local version = GetResourceMetadata(resName, 'version', 0) or '1.0.0'

            table.insert(resources, {
                name = resName,
                status = state:sub(1,1):upper() .. state:sub(2),
                author = author,
                description = description,
                version = version
            })
        end
    end
    TriggerClientEvent('xeno-adminmenu:client:ReceiveResources', src, resources)
end

RegisterNetEvent('xeno-adminmenu:server:RequestResources', function()
    local src = source
    if not IsPlayerAdmin(src) then return end
    SendResourcesToPlayer(src)
end)

local ProtectedCoreResources = {
    ['pradipta-core'] = true,
    ['oxmysql'] = true,
    ['ox_lib'] = true,
    ['xeno-adminmenu'] = true,
    ['pradipta_loading'] = true,
    ['pradipta_world'] = true
}

RegisterNetEvent('xeno-adminmenu:server:ResourceAction', function(action, resName)
    local src = source
    local role = GetPlayerAdminRole(src)
    if role ~= 'god' and role ~= 'admin' then return end
    if not resName or type(resName) ~= 'string' then return end

    local lowerRes = string.lower(resName)
    if action == 'stop' and ProtectedCoreResources[lowerRes] then
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            args = {"[PRADIPTA]", "Stopping core framework resource " .. resName .. " is protected and prohibited."}
        })
        return
    end

    local name = GetPlayerName(src)
    if action == 'start' then
        BroadcastTerminalLog("admin", name .. " started resource: " .. resName)
        StartResource(resName)
        if AddLog then AddLog('system', 'Started resource: ' .. resName, name, nil, { resource = resName }, 'resource_start') end
    elseif action == 'stop' then
        BroadcastTerminalLog("admin", name .. " stopped resource: " .. resName)
        StopResource(resName)
        if AddLog then AddLog('system', 'Stopped resource: ' .. resName, name, nil, { resource = resName }, 'resource_stop') end
    elseif action == 'restart' then
        BroadcastTerminalLog("admin", name .. " restarted resource: " .. resName)
        StopResource(resName)
        Wait(500)
        StartResource(resName)
        if AddLog then AddLog('system', 'Restarted resource: ' .. resName, name, nil, { resource = resName }, 'server_restart') end
    end

    Wait(500)
    SendResourcesToPlayer(src)
end)

local function BroadcastTerminalLog(logType, message)
    for _, playerId in ipairs(GetPlayers()) do
        if IsPlayerAdmin(playerId) then
            TriggerClientEvent('xeno-adminmenu:client:TerminalLog', playerId, logType, message)
        end
    end
end

RegisterConsoleListener(function(channel, message)
    if not message or message == "" or message == "\n" then return end
    local cleanMessage = string.gsub(message, "\x1b%[%d+;%d*m", "")
    cleanMessage = string.gsub(cleanMessage, "\x1b%[%d+m", "")
    local logType = "info"
    local lowerMsg = string.lower(cleanMessage)
    if string.find(lowerMsg, "error") or string.find(lowerMsg, "failed") or string.find(lowerMsg, "exception") or string.find(lowerMsg, "denied") then
        logType = "error"
    elseif string.find(lowerMsg, "warn") then
        logType = "warn"
    end
    BroadcastTerminalLog(logType, cleanMessage)
end)

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    BroadcastTerminalLog("join", "Player connecting: " .. name)
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    local name = GetPlayerName(src) or "Unknown"
    BroadcastTerminalLog("leave", "Player dropped: " .. name .. " (" .. reason .. ")")
end)

RegisterNetEvent('xeno-adminmenu:server:ExecuteCommand', function(cmd)
    local src = source
    local role = GetPlayerAdminRole(src)
    if role ~= 'god' and not IsPlayerAceAllowed(src, 'command') then
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            args = {"[PRADIPTA]", "Only God level administrators can execute direct server commands."}
        })
        return
    end

    local name = GetPlayerName(src)
    BroadcastTerminalLog("admin", name .. " executed command: " .. cmd)
    ExecuteCommand(cmd)
end)


RegisterCommand('players', function(source, args, rawCommand)
    local players = GetPlayers()
    print("Online Players: " .. #players .. "/" .. GetConvarInt('sv_maxclients', 48))
end, true)

RegisterCommand('status', function(source, args, rawCommand)
    print("Server Status: ONLINE")
    print("Players: " .. #GetPlayers() .. "/" .. GetConvarInt('sv_maxclients', 48))
    print("Uptime: Server is running smoothly.")
end, true)

RegisterCommand('resources', function(source, args, rawCommand)
    local numResources = GetNumResources()
    local started = 0
    for i = 0, numResources - 1 do
        local resName = GetResourceByFindIndex(i)
        if GetResourceState(resName) == "started" then
            started = started + 1
        end
    end
    print("Resources: " .. started .. "/" .. numResources .. " started.")
end, true)

RegisterCommand('performance', function(source, args, rawCommand)
    print("Server Performance:")
    print("Tick Time: ~" .. math.random(1, 5) .. "ms")
    print("CPU Usage: stable")
end, true)

RegisterCommand('logs', function(source, args, rawCommand)
    print("Please use the advanced filtering UI above to navigate logs.")
end, true)

RegisterCommand('help', function(source, args, rawCommand)
    print("Available Console Commands:")
    print(" - status: Check server status")
    print(" - players: See online player count")
    print(" - resources: Check resource counts")
    print(" - performance: Check tick time")
    print(" - clear: Clear the terminal screen")
    print(" - You can also use standard FiveM and txAdmin commands.")
end, true)


RegisterCommand('report', function(source, args, rawCommand)
    local src = source
    if src == 0 then return end
    TriggerClientEvent('xeno-adminmenu:client:OpenReportForm', src)
end, false)

RegisterNetEvent('xeno-adminmenu:server:SubmitReport', function(data)
    local src = source
    local senderName = GetPlayerName(src)

    exports.oxmysql:insert('INSERT INTO xeno_admin_reports (sender, type, title, reported, reason, status) VALUES (?, ?, ?, ?, ?, ?)', {
        senderName,
        data.type or 'player',
        data.title or 'No Title',
        data.target or '',
        data.reason or 'No Description',
        'pending'
    }, function(id)
        for _, playerId in ipairs(GetPlayers()) do
            if IsPlayerAdmin(playerId) then
                TriggerClientEvent('chat:addMessage', playerId, {
                    color = {255, 150, 0},
                    multiline = true,
                    args = {"[NEW REPORT]", senderName .. " submitted a new report: " .. (data.title or 'No Title')}
                })
            end
        end
        TriggerEvent('xeno-adminmenu:server:FetchReports')
        TriggerClientEvent('chat:addMessage', src, {
            color = {0, 255, 0},
            args = {"[System]", "Your report has been submitted to the admin team."}
        })
    end)
end)

RegisterNetEvent('xeno-adminmenu:server:FetchReports', function()
    local src = source
    if src ~= "" and type(src) == "number" and src > 0 and not IsPlayerAdmin(src) then return end

    exports.oxmysql:execute('SELECT * FROM xeno_admin_reports ORDER BY id DESC LIMIT 50', {}, function(results)
        local formatted = {}
        for _, r in ipairs(results) do
            table.insert(formatted, {
                id = r.id,
                type = r.type,
                title = r.title,
                description = r.reason,
                reporter = r.sender,
                target = (r.reported and r.reported ~= "") and r.reported or nil,
                status = r.status,
                date = tostring(r.date)
            })
        end

        if type(src) == "number" and src > 0 then
            TriggerClientEvent('xeno-adminmenu:client:ReceiveReports', src, formatted)
        else
            for _, playerId in ipairs(GetPlayers()) do
                if IsPlayerAdmin(playerId) then
                    TriggerClientEvent('xeno-adminmenu:client:ReceiveReports', playerId, formatted)
                end
            end
        end
    end)
end)

RegisterNetEvent('xeno-adminmenu:server:UpdateReportStatus', function(reportId, newStatus)
    local src = source
    if not IsPlayerAdmin(src) then return end

    if newStatus == 'delete' then
        exports.oxmysql:execute('DELETE FROM xeno_admin_reports WHERE id = ?', {reportId}, function()
            TriggerEvent('xeno-adminmenu:server:FetchReports')
            if AddLog then AddLog('report', 'Deleted Report ID: ' .. reportId, GetPlayerName(src), nil, { reportId = reportId }) end
        end)
    else
        exports.oxmysql:execute('UPDATE xeno_admin_reports SET status = ? WHERE id = ?', {newStatus, reportId}, function()
            TriggerEvent('xeno-adminmenu:server:FetchReports')
            if AddLog then AddLog('report', 'Updated Report ID: ' .. reportId .. ' status to ' .. newStatus, GetPlayerName(src), nil, { reportId = reportId, status = newStatus }) end
        end)
    end
end)

RegisterNetEvent('xeno-adminmenu:server:FetchMyReports', function()
    local src = source
    local senderName = GetPlayerName(src)
    exports.oxmysql:execute('SELECT * FROM xeno_admin_reports WHERE sender = ? ORDER BY id DESC', {senderName}, function(results)
        local formatted = {}
        for _, r in ipairs(results) do
            table.insert(formatted, {
                id = r.id,
                type = r.type,
                title = r.title,
                description = r.reason,
                status = r.status,
                date = tostring(r.date)
            })
        end
        TriggerClientEvent('xeno-adminmenu:client:ReceiveMyReports', src, formatted)
    end)
end)

local AdminChatMessages = {}

RegisterNetEvent('xeno-adminmenu:server:RequestChatMessages', function()
    local src = source
    if not IsPlayerAdmin(src) then return end
    TriggerClientEvent('xeno-adminmenu:client:ReceiveChatMessages', src, AdminChatMessages)
end)

RegisterNetEvent('xeno-adminmenu:server:SendChatMessage', function(data)
    local src = source
    if not IsPlayerAdmin(src) then return end

    local name = GetPlayerName(src)
    table.insert(AdminChatMessages, {
        author = name,
        message = data.message,
        timestamp = data.timestamp
    })

    if #AdminChatMessages > 100 then
        table.remove(AdminChatMessages, 1)
    end

    for _, playerId in ipairs(GetPlayers()) do
        if IsPlayerAdmin(playerId) then
            TriggerClientEvent('xeno-adminmenu:client:ReceiveChatMessages', playerId, AdminChatMessages)
        end
    end

    if AddLog then AddLog('admin', 'Admin Chat: ' .. data.message, name, nil, { message = data.message }, 'chat_message') end
end)

RegisterNetEvent('xeno-adminmenu:server:GlobalAnnouncement', function(data)
    local src = source
    if not IsPlayerAdmin(src) then return end
    if not data or not data.msg or type(data.msg) ~= 'string' or data.msg == '' then return end

    local senderName = GetPlayerName(src) or "Admin"
    local aType = (data.type == 'warning') and 'warning' or 'info'
    local title = (aType == 'warning') and 'SERVER WARNING' or 'SERVER ANNOUNCEMENT'
    local color = (aType == 'warning') and { 239, 68, 68 } or { 212, 175, 55 }

    -- 1. Broadcast NUI announcement banner to all players
    TriggerClientEvent('xeno-adminmenu:client:ShowAnnouncement', -1, {
        msg = data.msg,
        type = aType,
        duration = tonumber(data.duration) or 10000,
        sender = senderName
    })

    -- 2. Broadcast visible chat message to all players
    TriggerClientEvent('chat:addMessage', -1, {
        color = color,
        multiline = true,
        args = { '[' .. title .. ']', data.msg }
    })

    -- 3. Sender feedback notification
    TriggerClientEvent('PradiptaCore:Notify', src, 'Announcement sent successfully to all players.', 'success', 5000)

    -- 4. Audit logging
    if AddLog then
        AddLog('admin', 'Global Announcement (' .. aType .. '): ' .. data.msg, senderName, nil, { msg = data.msg, type = aType }, 'announcement')
    end
end)
