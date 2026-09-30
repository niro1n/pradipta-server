local ActiveBansCache = {}


local function GetIdentifiersDict(src)
    local ids = {}
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if string.find(id, "license:") then ids.license = id
        elseif string.find(id, "license2:") then ids.license2 = id
        elseif string.find(id, "steam:") then ids.steam = id
        elseif string.find(id, "discord:") then ids.discord = id
        elseif string.find(id, "fivem:") then ids.fivem = id
        elseif string.find(id, "xbl:") then ids.xbl = id
        elseif string.find(id, "live:") then ids.live = id
        elseif string.find(id, "ip:") then ids.ip = id end
    end

    if not ids.ip then
        local ip = GetPlayerEndpoint(src)
        if ip then ids.ip = "ip:" .. string.gsub(ip, ":%d+", "") end
    end
    return ids
end

local function GenerateBanId()
    local charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local id = "BAN-"
    for i = 1, 6 do
        local rand = math.random(1, #charset)
        id = id .. string.sub(charset, rand, rand)
    end
    return id
end

local function FormatBanMessage(banData)
    local serverName = Config.Bans.ServerName or "Our Server"
    local appealUrl = Config.Bans.AppealURL or "Our Discord"

    local expireStr = "Permanent"
    if not banData.is_permanent then
        expireStr = os.date('%d %B %Y at %H:%M:%S', math.floor(banData.expire / 1000))
    end

    local msg = "\n"
    msg = msg .. "🛑 You are banned from " .. serverName .. " 🛑\n\n"
    msg = msg .. "📋 Ban ID: " .. banData.ban_id .. "\n"
    msg = msg .. "👤 Banned By: " .. banData.banned_by_name .. "\n"
    msg = msg .. "⏳ Expires: " .. expireStr .. "\n\n"
    msg = msg .. "📝 Reason:\n" .. (banData.reason or "No reason specified.") .. "\n\n"
    msg = msg .. "If you believe this was a mistake, you can appeal your ban here:\n"
    msg = msg .. appealUrl .. "\n"

    return msg
end


local function RefreshBansCache()
    exports.oxmysql:execute('SELECT * FROM xeno_admin_bans WHERE active = 1', {}, function(results)
        ActiveBansCache = {}
        for _, ban in ipairs(results) do

            local identifiers = {ban.license, ban.license2, ban.steam, ban.discord, ban.fivem, ban.xbl, ban.live, ban.ip}


            if not ban.is_permanent and ban.expire then

                if os.time() * 1000 > ban.expire then
                    exports.oxmysql:execute('UPDATE xeno_admin_bans SET active = 0, expired_at = CURRENT_TIMESTAMP WHERE id = ?', {ban.id})
                    goto continue
                end
            end

            for _, id in ipairs(identifiers) do
                if id and id ~= "" then
                    ActiveBansCache[id] = ban
                end
            end
            ::continue::
        end
    end)
end


CreateThread(function()
    Wait(2000)
    RefreshBansCache()
end)


AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local src = source
    deferrals.defer()
    Wait(0)
    deferrals.update(string.format("Hello %s. Checking your ban status...", name))

    local identifiers = GetIdentifiersDict(src)
    local isBanned = false
    local banData = nil

    for _, id in pairs(identifiers) do
        if ActiveBansCache[id] then
            isBanned = true
            banData = ActiveBansCache[id]
            break
        end
    end

    if isBanned then


        exports.oxmysql:execute('SELECT active, expire, is_permanent FROM xeno_admin_bans WHERE id = ?', {banData.id}, function(result)
            local dbBan = result[1]
            if dbBan and (dbBan.active == 1 or dbBan.active == true) then

                if not dbBan.is_permanent and dbBan.expire and (os.time() * 1000 > dbBan.expire) then

                    exports.oxmysql:execute('UPDATE xeno_admin_bans SET active = 0, expired_at = CURRENT_TIMESTAMP WHERE id = ?', {banData.id})
                    RefreshBansCache()
                    deferrals.done()
                else
                    deferrals.done(FormatBanMessage(banData))
                end
            else

                RefreshBansCache()
                deferrals.done()
            end
        end)
    else
        deferrals.done()
    end
end)


local function FetchOfflineIdentifiers(searchQuery, cb)
    if Framework == 'pradiptacore' or Config.Framework == 'pradiptacore' or Framework == 'qbox' then
        exports.oxmysql:execute('SELECT license FROM players WHERE citizenid = ? OR license = ?', {searchQuery, searchQuery}, function(result)
            if result[1] then cb({license = result[1].license}) else cb(nil) end
        end)
    elseif Framework == 'esx' or Config.Framework == 'esx' then
        exports.oxmysql:execute('SELECT identifier FROM users WHERE identifier = ?', {searchQuery}, function(result)
            if result[1] then cb({license = result[1].identifier}) else cb(nil) end
        end)
    else

        cb(nil)
    end
end


exports('IsPlayerBanned', function(identifiers)
    if type(identifiers) == "string" then identifiers = {identifiers} end
    for _, id in pairs(identifiers) do
        if ActiveBansCache[id] then return true, ActiveBansCache[id] end
    end
    return false, nil
end)

local function InsertBan(targetName, identifiers, reason, adminName, adminIdentifier, durationHours)
    local banId = GenerateBanId()
    local isPerm = (durationHours == 0)
    local expire = nil
    if not isPerm then
        expire = (os.time() + (durationHours * 3600)) * 1000
    end

    exports.oxmysql:insert([[
        INSERT INTO xeno_admin_bans
        (ban_id, player_name, license, license2, steam, discord, fivem, xbl, live, ip, reason, banned_by_name, banned_by_identifier, is_permanent, expire)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, FROM_UNIXTIME(?))
    ]], {
        banId, targetName,
        identifiers.license, identifiers.license2, identifiers.steam, identifiers.discord,
        identifiers.fivem, identifiers.xbl, identifiers.live, identifiers.ip,
        reason, adminName, adminIdentifier, isPerm, (isPerm and 0 or (os.time() + durationHours * 3600))
    }, function(id)
        -- Synchronize with PradiptaCore bans table for unified enforcement
        pcall(function()
            local pradiptaExpire = isPerm and 2147483647 or (os.time() + durationHours * 3600)
            MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
                targetName, identifiers.license or '', identifiers.discord or '', identifiers.ip or '', reason, pradiptaExpire, adminName
            })
        end)

        RefreshBansCache()
        DebugLog('^1[Pradipta-AdminMenu] Player '..targetName..' banned by '..adminName..'. Ban ID: '..banId..'^0')
        if AddLog then
            AddLog('ban', 'Banned ' .. targetName .. ' for: ' .. reason, adminName, targetName, { reason = reason, duration = durationHours, banId = banId }, 'player_ban')
        end
    end)
    return banId
end

exports('BanPlayer', function(targetId, durationHours, reason, adminName)
    local adminIdentifier = "System"
    local identifiers = GetIdentifiersDict(targetId)
    local targetName = GetPlayerName(targetId)

    local banId = InsertBan(targetName, identifiers, reason, adminName, adminIdentifier, durationHours)
    DropPlayer(targetId, "You have been banned from PRADIPTA PRIVATE.\nBan ID: " .. banId .. "\nReason: " .. reason)
    return banId
end)

exports('UnbanPlayer', function(banId, adminName)
    exports.oxmysql:execute('SELECT license FROM xeno_admin_bans WHERE ban_id = ? OR id = ?', {banId, tonumber(banId)}, function(result)
        local targetLicense = result and result[1] and result[1].license
        exports.oxmysql:execute('UPDATE xeno_admin_bans SET active = 0, expired_at = CURRENT_TIMESTAMP WHERE ban_id = ? OR id = ?', {banId, tonumber(banId)}, function(affected)
            if affected > 0 then
                if targetLicense then
                    pcall(function()
                        MySQL.query('DELETE FROM bans WHERE license = ?', {targetLicense})
                    end)
                end
                RefreshBansCache()
                DebugLog('^2[Pradipta-AdminMenu] Ban '..banId..' removed by '..adminName..'^0')
                if AddLog then
                    AddLog('ban', 'Unbanned player with Ban ID: ' .. banId, adminName, 'Unknown', { banId = banId }, 'admin_action')
                end
            end
        end)
    end)
end)


RegisterNetEvent('xeno-adminmenu:server:FetchBans', function(page, limit, search, filter)
    local src = source
    if not IsPlayerAdmin(src) then return end

    page = page or 1
    limit = limit or 10
    local offset = (page - 1) * limit

    local query = 'SELECT * FROM xeno_admin_bans WHERE 1=1'
    local params = {}

    if search and search ~= "" then
        query = query .. ' AND (player_name LIKE ? OR ban_id LIKE ? OR reason LIKE ? OR license LIKE ? OR discord LIKE ?)'
        local searchParam = '%' .. search .. '%'
        table.insert(params, searchParam)
        table.insert(params, searchParam)
        table.insert(params, searchParam)
        table.insert(params, searchParam)
        table.insert(params, searchParam)
    end

    if filter == 'Active' then
        query = query .. ' AND active = 1'
    elseif filter == 'Expired' then
        query = query .. ' AND active = 0'
    elseif filter == 'Permanent' then
        query = query .. ' AND is_permanent = 1'
    end

    query = query .. ' ORDER BY created_at DESC LIMIT ? OFFSET ?'
    table.insert(params, limit)
    table.insert(params, offset)

    exports.oxmysql:execute(query, params, function(results)

        local countQuery = 'SELECT COUNT(*) as total FROM xeno_admin_bans WHERE 1=1'
        local countParams = {}
        if search and search ~= "" then
            countQuery = countQuery .. ' AND (player_name LIKE ? OR ban_id LIKE ? OR reason LIKE ? OR license LIKE ? OR discord LIKE ?)'
            table.insert(countParams, '%' .. search .. '%')
            table.insert(countParams, '%' .. search .. '%')
            table.insert(countParams, '%' .. search .. '%')
            table.insert(countParams, '%' .. search .. '%')
            table.insert(countParams, '%' .. search .. '%')
        end
        if filter == 'Active' then countQuery = countQuery .. ' AND active = 1'
        elseif filter == 'Expired' then countQuery = countQuery .. ' AND active = 0'
        elseif filter == 'Permanent' then countQuery = countQuery .. ' AND is_permanent = 1' end

        exports.oxmysql:scalar(countQuery, countParams, function(total)
            TriggerClientEvent('xeno-adminmenu:client:ReceiveBans', src, results, total or 0)
        end)
    end)
end)

RegisterNetEvent('xeno-adminmenu:server:BanPlayer', function(targetId, isOffline, reason, durationHours)
    local src = source
    if not IsPlayerAdmin(src) then return end

    local adminName = GetPlayerName(src)
    local adminIdentifier = GetIdentifiersDict(src).license or "Unknown"

    if not isOffline then
        local target = tonumber(targetId)
        if not target then return end
        local identifiers = GetIdentifiersDict(target)
        local targetName = GetPlayerName(target)


        for _, id in pairs(identifiers) do
            if ActiveBansCache[id] then
                TriggerClientEvent('chat:addMessage', src, {args = {"^1[Admin]", "Player is already banned!"}})
                return
            end
        end

        local banId = InsertBan(targetName, identifiers, reason, adminName, adminIdentifier, durationHours)
        DropPlayer(target, "You have been banned. Ban ID: " .. banId .. "\nReason: " .. reason)
        TriggerClientEvent('chat:addMessage', src, {args = {"^2[Admin]", "Banned player successfully."}})
    else

        FetchOfflineIdentifiers(targetId, function(identifiers)
            if identifiers then
                local targetName = "Offline Player"

                for _, id in pairs(identifiers) do
                    if ActiveBansCache[id] then
                        TriggerClientEvent('chat:addMessage', src, {args = {"^1[Admin]", "Offline Player is already banned!"}})
                        return
                    end
                end
                InsertBan(targetName, identifiers, reason, adminName, adminIdentifier, durationHours)
                TriggerClientEvent('chat:addMessage', src, {args = {"^2[Admin]", "Banned offline player successfully."}})
            else
                TriggerClientEvent('chat:addMessage', src, {args = {"^1[Admin]", "Could not find offline identifiers for " .. targetId}})
            end
        end)
    end
end)

RegisterNetEvent('xeno-adminmenu:server:UnbanPlayer', function(banId)
    local src = source
    if not HasPermission(src, 'unban') and not IsAdmin(src) then return end
    local adminName = GetPlayerName(src)
    exports['xeno-adminmenu']:UnbanPlayer(banId, adminName)
    TriggerClientEvent('chat:addMessage', src, {args = {"^2[Admin]", "Successfully unbanned " .. banId}})
end)

RegisterNetEvent('xeno-adminmenu:server:EditBan', function(banId, newData)
    local src = source
    if not IsPlayerAdmin(src) then return end

    local query = 'UPDATE xeno_admin_bans SET '
    local params = {}

    if newData.reason then
        query = query .. 'reason = ?, '
        table.insert(params, newData.reason)
    end
    if newData.durationHours ~= nil then
        local isPerm = (newData.durationHours == 0)
        query = query .. 'is_permanent = ?, '
        table.insert(params, isPerm)
        if not isPerm then
            query = query .. 'expire = FROM_UNIXTIME(?), '
            table.insert(params, (os.time() + newData.durationHours * 3600))
        else
            query = query .. 'expire = NULL, '
        end
    end
    if newData.notes then
        query = query .. 'notes = ?, '
        table.insert(params, newData.notes)
    end

    query = string.sub(query, 1, -3) .. ' WHERE ban_id = ? OR id = ?'
    table.insert(params, banId)
    table.insert(params, tonumber(banId))

    exports.oxmysql:execute(query, params, function(affected)
        RefreshBansCache()
    end)
end)
