local CachedPlaytimes = {}

CreateThread(function()
    Wait(3000)
    local result = SQLQuery('SELECT identifier, playtime FROM xeno_admin_playtime')
    if result then
        for i=1, #result do
            CachedPlaytimes[result[i].identifier] = result[i].playtime
        end
    end

    while true do
        Wait(60000) 
        local players = GetPlayers()
        for i=1, #players do
            local src = tonumber(players[i])
            local identifier = GetPlayerIdentifier(src, 0)
            if identifier then
                CachedPlaytimes[identifier] = (CachedPlaytimes[identifier] or 0) + 1
                exports.oxmysql:execute('UPDATE xeno_admin_playtime SET playtime = ? WHERE identifier = ?', {CachedPlaytimes[identifier], identifier}, function(affectedRows)
                    if affectedRows == 0 then
                        exports.oxmysql:execute('INSERT IGNORE INTO xeno_admin_playtime (identifier, playtime) VALUES (?, ?)', {identifier, CachedPlaytimes[identifier]})
                    end
                end)
            end
        end
    end
end)

RegisterNetEvent('xeno-adminmenu:server:RequestPlayersData', function()
    local src = source
    if not IsPlayerAdmin(src) then return end
    
    local players = GetPlayers()
    local playersList = {}
    
    local totalMoneySum = 0
    local jobsCount = {}
    local policeCount = 0
    
    for i=1, #players do
        local pSrc = tonumber(players[i])
        local data = GetPlayerFrameworkData(pSrc)
        local ping = GetPlayerPing(pSrc)
        local identifiers = GetPlayerIdentifiers(pSrc)
        
        local playerIdentifier = GetPlayerIdentifier(pSrc, 0)
        local pTime = 0
        if playerIdentifier and CachedPlaytimes[playerIdentifier] then
            pTime = CachedPlaytimes[playerIdentifier]
        end

        local pTimeStr = pTime .. "m"
        if pTime >= 60 then
            pTimeStr = math.floor(pTime / 60) .. "h " .. (pTime % 60) .. "m"
        end

        table.insert(playersList, {
            id = pSrc,
            name = data.name,
            ping = ping,
            identifiers = identifiers,
            isStaff = data.isStaff,
            isDead = false,
            items = GetPlayerItems(pSrc) or {},
            liveData = {
                job = data.jobLabel,
                grade = '',
                cash = data.money,
                bank = data.bank,
                gang = data.gangLabel,
                playtime = pTimeStr
            }
        })
        
        totalMoneySum = totalMoneySum + data.money + data.bank
        
        
        if string.lower(data.job) == 'police' then
            policeCount = policeCount + 1
        end
        
        
        if data.job and string.lower(data.job) ~= 'unemployed' then
            if not jobsCount[data.jobLabel] then
                jobsCount[data.jobLabel] = 0
            end
            jobsCount[data.jobLabel] = jobsCount[data.jobLabel] + 1
        end
    end
    
    local averageMoney = 0
    if #players > 0 then
        averageMoney = math.floor(totalMoneySum / #players)
    end
    
    local mostCommonJob = "Unknown"
    local maxJobCount = 0
    for job, count in pairs(jobsCount) do
        if count > maxJobCount then
            maxJobCount = count
            mostCommonJob = job
        end
    end
    if mostCommonJob == "Unknown" and #players > 0 then
        mostCommonJob = "Unemployed"
    end
    
    
    local function formatMoney(amount)
        local formatted = tostring(math.floor(amount))
        while true do  
            formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
            if (k==0) then break end
        end
        return '$'..formatted
    end

    
    local totalPlaytime = 0
    local pCount = 0
    for i=1, #players do
        local pSrc = tonumber(players[i])
        local identifier = GetPlayerIdentifier(pSrc, 0)
        if identifier and CachedPlaytimes[identifier] then
            totalPlaytime = totalPlaytime + CachedPlaytimes[identifier]
            pCount = pCount + 1
        end
    end
    
    local averagePlaytime = 0
    if pCount > 0 then
        averagePlaytime = math.floor(totalPlaytime / pCount)
    end
    
    local avgStr = averagePlaytime .. "m"
    if averagePlaytime >= 60 then
        avgStr = math.floor(averagePlaytime / 60) .. "h " .. (averagePlaytime % 60) .. "m"
    end
    
    TriggerClientEvent('xeno-adminmenu:client:ReceivePlayersData', src, {
        players = playersList,
        averageMoney = formatMoney(averageMoney),
        policeOfficers = policeCount,
        mostCommonJob = mostCommonJob,
        averagePlaytime = avgStr
    })
end)

local ActiveLiveDataWatchers = {}

RegisterNetEvent('xeno-adminmenu:server:SetLiveDataStatus', function(targetId, status)
    local src = source
    if not IsPlayerAdmin(src) then return end
    if status and targetId then
        ActiveLiveDataWatchers[src] = targetId
    else
        ActiveLiveDataWatchers[src] = nil
    end
end)

CreateThread(function()
    while true do
        Wait(1000)
        for adminSrc, targetSrc in pairs(ActiveLiveDataWatchers) do
            if GetPlayerPing(adminSrc) > 0 and GetPlayerPing(targetSrc) > 0 then
                local targetPed = GetPlayerPed(targetSrc)
                local data = GetPlayerFrameworkData(targetSrc)
                
                local health = 0
                local armor = 0
                if targetPed ~= 0 then
                    health = math.floor((GetEntityHealth(targetPed) - 100) / 100 * 100)
                    if health < 0 then health = 0 end
                    if health > 100 then health = 100 end
                    armor = GetPedArmour(targetPed)
                end
                
                local coords = GetEntityCoords(targetPed)
                local posStr = "Unknown"
                if targetPed ~= 0 then
                    posStr = string.format("X: %.1f, Y: %.1f, Z: %.1f", coords.x, coords.y, coords.z)
                end
                
                TriggerClientEvent('xeno-adminmenu:client:UpdateLiveData', adminSrc, targetSrc, {
                    health = health,
                    armor = armor,
                    hunger = math.floor(data.hunger or 100),
                    thirst = math.floor(data.thirst or 100),
                    ping = GetPlayerPing(targetSrc),
                    position = posStr
                })
            else
                ActiveLiveDataWatchers[adminSrc] = nil
            end
        end
    end
end)
