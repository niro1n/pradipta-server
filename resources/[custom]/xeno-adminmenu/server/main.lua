
local QBCore = exports['qb-core']:GetCoreObject()

DebugLog('^2[Pradipta-AdminMenu] Server backend loaded successfully.^0')

-- Register QBCore Admin Commands
QBCore.Commands.Add('admin', 'Open Administrative Console', {}, false, function(source)
    TriggerClientEvent('xeno-adminmenu:client:OpenMenuDirect', source)
end, 'admin')

QBCore.Commands.Add('adminmenu', 'Open Administrative Console', {}, false, function(source)
    TriggerClientEvent('xeno-adminmenu:client:OpenMenuDirect', source)
end, 'admin')

-- Preserved Developer Vector Commands
QBCore.Commands.Add('vector2', 'Copy vector2 to clipboard (Admin only)', {}, false, function(source)
    TriggerClientEvent('xeno-adminmenu:client:copyVector', source, 'coords2')
end, 'admin')

QBCore.Commands.Add('vector3', 'Copy vector3 to clipboard (Admin only)', {}, false, function(source)
    TriggerClientEvent('xeno-adminmenu:client:copyVector', source, 'coords3')
end, 'admin')

QBCore.Commands.Add('vector4', 'Copy vector4 to clipboard (Admin only)', {}, false, function(source)
    TriggerClientEvent('xeno-adminmenu:client:copyVector', source, 'coords4')
end, 'admin')

QBCore.Commands.Add('heading', 'Copy heading to clipboard (Admin only)', {}, false, function(source)
    TriggerClientEvent('xeno-adminmenu:client:copyVector', source, 'heading')
end, 'admin')

QBCore.Commands.Add('announce', 'Broadcast announcement to server (Admin only)', { { name = 'message', help = 'Announcement text' } }, true, function(source, args)
    local msg = table.concat(args, ' ')
    if msg == '' then return end
    TriggerEvent('xeno-adminmenu:server:GlobalAnnouncement', {
        msg = msg,
        type = 'info',
        duration = 10000
    })
end, 'admin')

RegisterNetEvent('xeno-adminmenu:server:RequestDashboardStats', function()
    local src = source
    if not IsPlayerAdmin(src) then 
        return
    end
    
    local players = GetPlayers()
    local onlinePlayers = #players
    local maxPlayers = GetConvarInt('sv_maxclients', 48)
    
    TriggerEvent('xeno-adminmenu:server:RefreshWarns')
    
    local activeAdmins = 0
    local totalPing = 0
    
    for i=1, onlinePlayers do
        local player = tonumber(players[i])
        if player then
            if IsPlayerAdmin(player) then
                activeAdmins = activeAdmins + 1
            end
            local ping = GetPlayerPing(players[i])
            if ping then
                totalPing = totalPing + ping
            end
        end
    end
    
    local averagePing = 0
    if onlinePlayers > 0 then
        averagePing = math.floor(totalPing / onlinePlayers)
    end
    
    local numResources = GetNumResources()
    local mapResources = 0
    for i=0, numResources-1 do
        local res = GetResourceByFindIndex(i)
        if GetResourceState(res) == 'started' then
            mapResources = mapResources + 1
        end
    end
    
    DebugLog('^2[Xeno-AdminMenu] Fetching total economy...^0')
    local totalMoney = GetTotalEconomy()
    DebugLog('^2[Xeno-AdminMenu] Total economy: '..tostring(totalMoney)..'^0')
    
    DebugLog('^2[Xeno-AdminMenu] Fetching richest player...^0')
    local richestPlayer = GetRichestPlayer()
    DebugLog('^2[Xeno-AdminMenu] Richest player: '..tostring(richestPlayer)..'^0')
    
    local function formatMoney(amount)
        local formatted = tostring(math.floor(amount))
        while true do  
            formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
            if (k==0) then
                break
            end
        end
        return formatted
    end
    
    local sName = GetConvar('sv_projectName', GetConvar('sv_hostname', 'Unknown Server'))
    local serverName = string.gsub(sName, "%^%d", "")
    
    local uptimeSeconds = math.floor(GetGameTimer() / 1000)
    local uptimeMinutes = math.floor(uptimeSeconds / 60)
    local serverUptime = uptimeMinutes .. 'm'
    if uptimeMinutes >= 60 then
        serverUptime = math.floor(uptimeMinutes / 60) .. 'h ' .. (uptimeMinutes % 60) .. 'm'
    end
    
    TriggerClientEvent('xeno-adminmenu:client:ReceiveDashboardStats', src, {
        onlinePlayers = onlinePlayers,
        activeAdmins = activeAdmins,
        maxPlayers = maxPlayers,
        averagePing = averagePing,
        mapResources = mapResources,
        totalMoney = formatMoney(totalMoney),
        richestPlayer = richestPlayer,
        serverName = serverName,
        serverUptime = serverUptime
    })
end)