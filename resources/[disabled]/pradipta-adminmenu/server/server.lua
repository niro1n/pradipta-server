-- Variables
local PradiptaCore = exports['pradipta-core']:GetCoreObject({ 'Functions', 'Commands' })
local sharedWeapons = exports['pradipta-core']:GetShared('Weapons')
local frozen = false
local permissions = {
    ['kill'] = 'admin',
    ['ban'] = 'admin',
    ['noclip'] = 'admin',
    ['kickall'] = 'admin',
    ['kick'] = 'admin',
    ['revive'] = 'admin',
    ['freeze'] = 'admin',
    ['goto'] = 'admin',
    ['spectate'] = 'admin',
    ['intovehicle'] = 'admin',
    ['bring'] = 'admin',
    ['inventory'] = 'admin',
    ['clothing'] = 'admin'
}

function GetPRADIPTAPlayers()
    local playerReturn = {}
    local players = PradiptaCore.Functions.GetPRADIPTAPlayers()

    for id, player in pairs(players) do
        local playerPed = GetPlayerPed(id)
        local name = (player.PlayerData.charinfo.firstname or '') .. ' ' .. (player.PlayerData.charinfo.lastname or '')
        playerReturn[#playerReturn + 1] = {
            name = name .. ' | (' .. (player.PlayerData.name or '') .. ')',
            id = id,
            coords = GetEntityCoords(playerPed),
            cid = name,
            citizenid = player.PlayerData.citizenid,
            sources = playerPed,
            sourceplayer = id
        }
    end
    return playerReturn
end

PradiptaCore.Functions.CreateCallback('test:getdealers', function(_, cb)
    if GetResourceState('pradipta-drugs') == 'started' then
        cb(exports['pradipta-drugs']:GetDealers())
    else
        cb({})
    end
end)

-- Get Players
PradiptaCore.Functions.CreateCallback('test:getplayers', function(_, cb) -- WORKS
    local players = GetPRADIPTAPlayers()
    cb(players)
end)

PradiptaCore.Functions.CreateCallback('pradipta-admin:isAdmin', function(src, cb) -- WORKS
    cb(PradiptaCore.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command'))
end)

PradiptaCore.Functions.CreateCallback('pradipta-admin:server:getrank', function(source, cb)
    if PradiptaCore.Functions.HasPermission(source, 'god') or IsPlayerAceAllowed(source, 'command') then
        cb(true)
    else
        cb(false)
    end
end)

-- Functions
local function tablelength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

local function BanPlayer(src)
    MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        GetPlayerName(src),
        PradiptaCore.Functions.GetIdentifier(src, 'license'),
        PradiptaCore.Functions.GetIdentifier(src, 'discord'),
        PradiptaCore.Functions.GetIdentifier(src, 'ip'),
        'Trying to revive theirselves or other players',
        2147483647,
        'pradipta-adminmenu'
    })
    TriggerEvent('pradipta-log:server:CreateLog', 'adminmenu', 'Player Banned', 'red', string.format('%s was banned by %s for %s', GetPlayerName(src), 'pradipta-adminmenu', 'Trying to trigger admin options which they dont have permission for'), true)
    DropPlayer(src, 'You were permanently banned by the server for: Exploiting')
end

-- Events
RegisterNetEvent('pradipta-admin:server:GetPlayersForBlips', function()
    local src = source
    local players = GetPRADIPTAPlayers()
    TriggerClientEvent('pradipta-admin:client:Show', src, players)
end)

RegisterNetEvent('pradipta-admin:server:kill', function(player)
    local src = source
    if PradiptaCore.Functions.HasPermission(src, permissions['kill']) or IsPlayerAceAllowed(src, 'command') then
        TriggerClientEvent('hospital:client:KillPlayer', player.id)
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('pradipta-admin:server:revive', function(player)
    local src = source
    if PradiptaCore.Functions.HasPermission(src, permissions['revive']) or IsPlayerAceAllowed(src, 'command') then
        TriggerClientEvent('hospital:client:Revive', player.id)
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('pradipta-admin:server:kick', function(player, reason)
    local src = source
    if PradiptaCore.Functions.HasPermission(src, permissions['kick']) or IsPlayerAceAllowed(src, 'command') then
        TriggerEvent('pradipta-log:server:CreateLog', 'bans', 'Player Kicked', 'red', string.format('%s was kicked by %s for %s', GetPlayerName(player.id), GetPlayerName(src), reason), true)
        DropPlayer(player.id, Lang:t('info.kicked_server') .. ':\n' .. reason .. '\n\n' .. Lang:t('info.check_discord') .. PradiptaCore.Config.Server.Discord)
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('pradipta-admin:server:ban', function(player, time, reason)
    local src = source
    if PradiptaCore.Functions.HasPermission(src, permissions['ban']) or IsPlayerAceAllowed(src, 'command') then
        time = tonumber(time)
        local banTime = tonumber(os.time() + time)
        if banTime > 2147483647 then
            banTime = 2147483647
        end
        local timeTable = os.date('*t', banTime)
        MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            GetPlayerName(player.id),
            PradiptaCore.Functions.GetIdentifier(player.id, 'license'),
            PradiptaCore.Functions.GetIdentifier(player.id, 'discord'),
            PradiptaCore.Functions.GetIdentifier(player.id, 'ip'),
            reason,
            banTime,
            GetPlayerName(src)
        })
        TriggerClientEvent('chat:addMessage', -1, {
            template = "<div class=chat-message server'><strong>ANNOUNCEMENT | {0} has been banned:</strong> {1}</div>",
            args = { GetPlayerName(player.id), reason }
        })
        TriggerEvent('pradipta-log:server:CreateLog', 'bans', 'Player Banned', 'red', string.format('%s was banned by %s for %s', GetPlayerName(player.id), GetPlayerName(src), reason), true)
        if banTime >= 2147483647 then
            DropPlayer(player.id, Lang:t('info.banned') .. '\n' .. reason .. Lang:t('info.ban_perm') .. PradiptaCore.Config.Server.Discord)
        else
            DropPlayer(player.id, Lang:t('info.banned') .. '\n' .. reason .. Lang:t('info.ban_expires') .. timeTable['day'] .. '/' .. timeTable['month'] .. '/' .. timeTable['year'] .. ' ' .. timeTable['hour'] .. ':' .. timeTable['min'] .. '\n🔸 Check our Discord for more information: ' .. PradiptaCore.Config.Server.Discord)
        end
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('pradipta-admin:server:spectate', function(player)
    local src = source
    if PradiptaCore.Functions.HasPermission(src, permissions['spectate']) or IsPlayerAceAllowed(src, 'command') then
        local targetped = GetPlayerPed(player.id)
        local coords = GetEntityCoords(targetped)
        TriggerClientEvent('pradipta-admin:client:spectate', src, player.id, coords)
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('pradipta-admin:server:freeze', function(player)
    local src = source
    if PradiptaCore.Functions.HasPermission(src, permissions['freeze']) or IsPlayerAceAllowed(src, 'command') then
        local target = GetPlayerPed(player.id)
        if not frozen then
            frozen = true
            FreezeEntityPosition(target, true)
        else
            frozen = false
            FreezeEntityPosition(target, false)
        end
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('pradipta-admin:server:goto', function(player)
    local src = source
    if PradiptaCore.Functions.HasPermission(src, permissions['goto']) or IsPlayerAceAllowed(src, 'command') then
        local admin = GetPlayerPed(src)
        local coords = GetEntityCoords(GetPlayerPed(player.id))
        SetEntityCoords(admin, coords)
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('pradipta-admin:server:intovehicle', function(player)
    local src = source
    if PradiptaCore.Functions.HasPermission(src, permissions['intovehicle']) or IsPlayerAceAllowed(src, 'command') then
        local admin = GetPlayerPed(src)
        local targetPed = GetPlayerPed(player.id)
        local vehicle = GetVehiclePedIsIn(targetPed, false)
        local seat = -1
        if vehicle ~= 0 then
            for i = 0, 8, 1 do
                if GetPedInVehicleSeat(vehicle, i) == 0 then
                    seat = i
                    break
                end
            end
            if seat ~= -1 then
                SetPedIntoVehicle(admin, vehicle, seat)
                TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('sucess.entered_vehicle'), 'success', 5000)
            else
                TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('error.no_free_seats'), 'danger', 5000)
            end
        end
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('pradipta-admin:server:bring', function(player)
    local src = source
    if PradiptaCore.Functions.HasPermission(src, permissions['bring']) or IsPlayerAceAllowed(src, 'command') then
        local admin = GetPlayerPed(src)
        local coords = GetEntityCoords(admin)
        local target = GetPlayerPed(player.id)
        SetEntityCoords(target, coords)
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('pradipta-admin:server:inventory', function(player)
    local src = source
    if PradiptaCore.Functions.HasPermission(src, permissions['inventory']) or IsPlayerAceAllowed(src, 'command') then
        exports['pradipta-inventory']:OpenInventoryById(src, player.id)
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('pradipta-admin:server:cloth', function(player)
    local src = source
    if PradiptaCore.Functions.HasPermission(src, permissions['clothing']) or IsPlayerAceAllowed(src, 'command') then
        TriggerClientEvent('pradipta-clothing:client:openMenu', player.id)
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('pradipta-admin:server:setPermissions', function(targetId, group)
    local src = source
    if PradiptaCore.Functions.HasPermission(src, 'god') or IsPlayerAceAllowed(src, 'command') then
        PradiptaCore.Functions.AddPermission(targetId, group[1].rank)
        TriggerClientEvent('PradiptaCore:Notify', targetId, Lang:t('info.rank_level') .. group[1].label)
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('pradipta-admin:server:SendReport', function(name, targetSrc, msg)
    local src = source
    if PradiptaCore.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command') then
        if PradiptaCore.Functions.IsOptin(src) then
            TriggerClientEvent('chat:addMessage', src, {
                color = { 255, 0, 0 },
                multiline = true,
                args = { Lang:t('info.admin_report') .. name .. ' (' .. targetSrc .. ')', msg }
            })
        end
    end
end)

RegisterServerEvent('pradipta-admin:giveWeapon', function(weapon)
    local src = source
    if PradiptaCore.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command') then
        exports['pradipta-inventory']:AddItem(src, weapon, 1, false, false, 'pradipta-admin:giveWeapon')
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('pradipta-admin:server:SaveCar', function(mods, vehicle, _, plate)
    local src = source
    if PradiptaCore.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command') then
        local Player = exports['pradipta-core']:GetPlayer(src)
        local result = MySQL.query.await('SELECT plate FROM player_vehicles WHERE plate = ?', { plate })
        if result[1] == nil then
            MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)', {
                Player.PlayerData.license,
                Player.PlayerData.citizenid,
                vehicle.model,
                vehicle.hash,
                json.encode(mods),
                plate,
                0
            })
            TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('success.success_vehicle_owner'), 'success', 5000)
        else
            TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('error.failed_vehicle_owner'), 'error', 3000)
        end
    else
        BanPlayer(src)
    end
end)

-- Commands

PradiptaCore.Commands.Add('maxmods', Lang:t('desc.max_mod_desc'), {}, false, function(source)
    local src = source
    TriggerClientEvent('pradipta-admin:client:maxmodVehicle', src)
end, 'admin')

PradiptaCore.Commands.Add('blips', Lang:t('commands.blips_for_player'), {}, false, function(source)
    local src = source
    TriggerClientEvent('pradipta-admin:client:toggleBlips', src)
end, 'admin')

PradiptaCore.Commands.Add('names', Lang:t('commands.player_name_overhead'), {}, false, function(source)
    local src = source
    TriggerClientEvent('pradipta-admin:client:toggleNames', src)
end, 'admin')

PradiptaCore.Commands.Add('coords', Lang:t('commands.coords_dev_command'), {}, false, function(source)
    local src = source
    TriggerClientEvent('pradipta-admin:client:ToggleCoords', src)
end, 'admin')

PradiptaCore.Commands.Add('noclip', Lang:t('commands.toogle_noclip'), {}, false, function(source)
    local src = source
    TriggerClientEvent('pradipta-admin:client:ToggleNoClip', src)
end, 'admin')

PradiptaCore.Commands.Add('admincar', Lang:t('commands.save_vehicle_garage'), {}, false, function(source, _)
    TriggerClientEvent('pradipta-admin:client:SaveCar', source)
end, 'admin')

PradiptaCore.Commands.Add('announce', Lang:t('commands.make_announcement'), {}, false, function(_, args)
    local msg = table.concat(args, ' ')
    if msg == '' then return end
    TriggerClientEvent('chat:addMessage', -1, {
        color = { 255, 0, 0 },
        multiline = true,
        args = { 'Announcement', msg }
    })
end, 'admin')

PradiptaCore.Commands.Add('admin', Lang:t('commands.open_admin'), {}, false, function(source, _)
    TriggerClientEvent('pradipta-admin:client:openMenu', source)
end, 'admin')

PradiptaCore.Commands.Add('report', Lang:t('info.admin_report'), { { name = 'message', help = 'Message' } }, true, function(source, args)
    local src = source
    local msg = table.concat(args, ' ')
    local Player = exports['pradipta-core']:GetPlayer(source)
    TriggerClientEvent('pradipta-admin:client:SendReport', -1, GetPlayerName(src), src, msg)
    TriggerEvent('pradipta-log:server:CreateLog', 'report', 'Report', 'green', '**' .. GetPlayerName(source) .. '** (CitizenID: ' .. Player.PlayerData.citizenid .. ' | ID: ' .. source .. ') **Report:** ' .. msg, false)
end)

PradiptaCore.Commands.Add('staffchat', Lang:t('commands.staffchat_message'), { { name = 'message', help = 'Message' } }, true, function(source, args)
    local msg = table.concat(args, ' ')
    local name = GetPlayerName(source)

    local plrs = GetPlayers()

    for _, plr in ipairs(plrs) do
        plr = tonumber(plr)
        if plr then
            if PradiptaCore.Functions.HasPermission(plr, 'admin') or IsPlayerAceAllowed(plr, 'command') then
                if PradiptaCore.Functions.IsOptin(plr) then
                    TriggerClientEvent('chat:addMessage', plr, {
                        color = { 255, 0, 0 },
                        multiline = true,
                        args = { Lang:t('info.staffchat') .. name, msg }
                    })
                end
            end
        end
    end
end, 'admin')

PradiptaCore.Commands.Add('givenuifocus', Lang:t('commands.nui_focus'), { { name = 'id', help = 'Player id' }, { name = 'focus', help = 'Set focus on/off' }, { name = 'mouse', help = 'Set mouse on/off' } }, true, function(_, args)
    local playerid = tonumber(args[1])
    local focus = args[2]
    local mouse = args[3]
    TriggerClientEvent('pradipta-admin:client:GiveNuiFocus', playerid, focus, mouse)
end, 'admin')

PradiptaCore.Commands.Add('warn', Lang:t('commands.warn_a_player'), { { name = 'ID', help = 'Player' }, { name = 'Reason', help = 'Mention a reason' } }, true, function(source, args)
    local targetPlayer = exports['pradipta-core']:GetPlayer(tonumber(args[1]))
    local senderPlayer = exports['pradipta-core']:GetPlayer(source)
    table.remove(args, 1)
    local msg = table.concat(args, ' ')
    local warnId = 'WARN-' .. math.random(1111, 9999)
    if targetPlayer ~= nil then
        TriggerClientEvent('chat:addMessage', targetPlayer.PlayerData.source, { args = { 'SYSTEM', Lang:t('info.warning_chat_message') .. GetPlayerName(source) .. ',' .. Lang:t('info.reason') .. ': ' .. msg }, color = 255, 0, 0 })
        TriggerClientEvent('chat:addMessage', source, { args = { 'SYSTEM', Lang:t('info.warning_staff_message') .. GetPlayerName(targetPlayer.PlayerData.source) .. ', for: ' .. msg }, color = 255, 0, 0 })
        MySQL.insert('INSERT INTO player_warns (senderIdentifier, targetIdentifier, reason, warnId) VALUES (?, ?, ?, ?)', {
            senderPlayer.PlayerData.license,
            targetPlayer.PlayerData.license,
            msg,
            warnId
        })
    else
        TriggerClientEvent('PradiptaCore:Notify', source, Lang:t('error.not_online'), 'error')
    end
end, 'admin')

PradiptaCore.Commands.Add('checkwarns', Lang:t('commands.check_player_warning'), { { name = 'id', help = 'Player' }, { name = 'Warning', help = 'Number of warning, (1, 2 or 3 etc..)' } }, false, function(source, args)
    if args[2] == nil then
        local targetPlayer = exports['pradipta-core']:GetPlayer(tonumber(args[1]))
        local result = MySQL.query.await('SELECT * FROM player_warns WHERE targetIdentifier = ?', { targetPlayer.PlayerData.license })
        TriggerClientEvent('chat:addMessage', source, 'SYSTEM', 'warning', targetPlayer.PlayerData.name .. ' has ' .. tablelength(result) .. ' warnings!')
    else
        local targetPlayer = exports['pradipta-core']:GetPlayer(tonumber(args[1]))
        local warnings = MySQL.query.await('SELECT * FROM player_warns WHERE targetIdentifier = ?', { targetPlayer.PlayerData.license })
        local selectedWarning = tonumber(args[2])
        if warnings[selectedWarning] ~= nil then
            local sender = exports['pradipta-core']:GetPlayer(warnings[selectedWarning].senderIdentifier)
            TriggerClientEvent('chat:addMessage', source, 'SYSTEM', 'warning', targetPlayer.PlayerData.name .. ' has been warned by ' .. sender.PlayerData.name .. ', Reason: ' .. warnings[selectedWarning].reason)
        end
    end
end, 'admin')

PradiptaCore.Commands.Add('delwarn', Lang:t('commands.delete_player_warning'), { { name = 'id', help = 'Player' }, { name = 'Warning', help = 'Number of warning, (1, 2 or 3 etc..)' } }, true, function(source, args)
    local targetPlayer = exports['pradipta-core']:GetPlayer(tonumber(args[1]))
    local warnings = MySQL.query.await('SELECT * FROM player_warns WHERE targetIdentifier = ?', { targetPlayer.PlayerData.license })
    local selectedWarning = tonumber(args[2])
    if warnings[selectedWarning] ~= nil then
        TriggerClientEvent('chat:addMessage', source, 'SYSTEM', 'warning', 'You have deleted warning (' .. selectedWarning .. ') , Reason: ' .. warnings[selectedWarning].reason)
        MySQL.query('DELETE FROM player_warns WHERE warnId = ?', { warnings[selectedWarning].warnId })
    end
end, 'admin')

PradiptaCore.Commands.Add('reportr', Lang:t('commands.reply_to_report'), { { name = 'id', help = 'Player' }, { name = 'message', help = 'Message to respond with' } }, false, function(source, args)
    local src = source
    local playerId = tonumber(args[1])
    table.remove(args, 1)
    local msg = table.concat(args, ' ')
    local OtherPlayer = exports['pradipta-core']:GetPlayer(playerId)
    if msg == '' then return end
    if not OtherPlayer then return TriggerClientEvent('PradiptaCore:Notify', src, 'Player is not online', 'error') end
    if not PradiptaCore.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command') ~= 1 then return end
    TriggerClientEvent('chat:addMessage', playerId, {
        color = { 255, 0, 0 },
        multiline = true,
        args = { 'Admin Response', msg }
    })
    TriggerClientEvent('chat:addMessage', src, {
        color = { 255, 0, 0 },
        multiline = true,
        args = { 'Report Response (' .. playerId .. ')', msg }
    })
    TriggerClientEvent('PradiptaCore:Notify', src, 'Reply Sent')
    TriggerEvent('pradipta-log:server:CreateLog', 'report', 'Report Reply', 'red', '**' .. GetPlayerName(src) .. '** replied on: **' .. OtherPlayer.PlayerData.name .. ' **(ID: ' .. OtherPlayer.PlayerData.source .. ') **Message:** ' .. msg, false)
end, 'admin')

PradiptaCore.Commands.Add('setmodel', Lang:t('commands.change_ped_model'), { { name = 'model', help = 'Name of the model' }, { name = 'id', help = 'Id of the Player (empty for yourself)' } }, false, function(source, args)
    local model = args[1]
    local target = tonumber(args[2])
    if model ~= nil or model ~= '' then
        if target == nil then
            TriggerClientEvent('pradipta-admin:client:SetModel', source, tostring(model))
        else
            local Trgt = exports['pradipta-core']:GetPlayer(target)
            if Trgt ~= nil then
                TriggerClientEvent('pradipta-admin:client:SetModel', target, tostring(model))
            else
                TriggerClientEvent('PradiptaCore:Notify', source, Lang:t('error.not_online'), 'error')
            end
        end
    else
        TriggerClientEvent('PradiptaCore:Notify', source, Lang:t('error.failed_set_model'), 'error')
    end
end, 'admin')

PradiptaCore.Commands.Add('setspeed', Lang:t('commands.set_player_foot_speed'), {}, false, function(source, args)
    local speed = args[1]
    if speed ~= nil then
        TriggerClientEvent('pradipta-admin:client:SetSpeed', source, tostring(speed))
    else
        TriggerClientEvent('PradiptaCore:Notify', source, Lang:t('error.failed_set_speed'), 'error')
    end
end, 'admin')

PradiptaCore.Commands.Add('reporttoggle', Lang:t('commands.report_toggle'), {}, false, function(source, _)
    local src = source
    PradiptaCore.Functions.ToggleOptin(src)
    if PradiptaCore.Functions.IsOptin(src) then
        TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('success.receive_reports'), 'success')
    else
        TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('error.no_receive_report'), 'error')
    end
end, 'admin')

PradiptaCore.Commands.Add('kickall', Lang:t('commands.kick_all'), {}, false, function(source, args)
    local src = source
    if src > 0 then
        local reason = table.concat(args, ' ')
        if PradiptaCore.Functions.HasPermission(src, 'god') or IsPlayerAceAllowed(src, 'command') then
            if reason and reason ~= '' then
                local players = GetPlayers()
                for _, playerId in ipairs(players) do
                    DropPlayer(playerId, reason)
                end
            else
                TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('info.no_reason_specified'), 'error')
            end
        end
    else
        local players = GetPlayers()
        for _, playerId in ipairs(players) do
            DropPlayer(playerId, Lang:t('info.server_restart') .. PradiptaCore.Config.Server.Discord)
        end
    end
end, 'god')

PradiptaCore.Commands.Add('setammo', Lang:t('commands.ammo_amount_set'), { { name = 'amount', help = 'Amount of bullets, for example: 20' } }, false, function(source, args)
    local src = source
    local ped = GetPlayerPed(src)
    local amount = tonumber(args[1])
    local weapon = GetSelectedPedWeapon(ped)
    if weapon and amount then
        SetPedAmmo(ped, weapon, amount)
        TriggerClientEvent('PradiptaCore:Notify', src, Lang:t('info.ammoforthe', { value = amount, weapon = sharedWeapons[weapon]['label'] }), 'success')
    end
end, 'admin')

PradiptaCore.Commands.Add('vector2', 'Copy vector2 to clipboard (Admin only)', {}, false, function(source)
    local src = source
    TriggerClientEvent('pradipta-admin:client:copyToClipboard', src, 'coords2')
end, 'admin')

PradiptaCore.Commands.Add('vector3', 'Copy vector3 to clipboard (Admin only)', {}, false, function(source)
    local src = source
    TriggerClientEvent('pradipta-admin:client:copyToClipboard', src, 'coords3')
end, 'admin')

PradiptaCore.Commands.Add('vector4', 'Copy vector4 to clipboard (Admin only)', {}, false, function(source)
    local src = source
    TriggerClientEvent('pradipta-admin:client:copyToClipboard', src, 'coords4')
end, 'admin')

PradiptaCore.Commands.Add('heading', 'Copy heading to clipboard (Admin only)', {}, false, function(source)
    local src = source
    TriggerClientEvent('pradipta-admin:client:copyToClipboard', src, 'heading')
end, 'admin')
