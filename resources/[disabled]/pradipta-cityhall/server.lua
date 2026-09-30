local PradiptaCore = exports['pradipta-core']:GetCoreObject({ 'Functions', 'Shared', 'Commands' })
local availableJobs = Config.AvailableJobs

-- Exports

local function AddCityJob(jobName, toCH)
    if availableJobs[jobName] then return false, 'already added' end
    availableJobs[jobName] = {
        ['label'] = toCH.label,
        ['isManaged'] = toCH.isManaged
    }
    return true, 'success'
end

exports('AddCityJob', AddCityJob)

-- Functions

local function giveStarterItems()
    local Player = exports['pradipta-core']:GetPlayer(source)
    if not Player then return end
    for _, v in pairs(PradiptaCore.Shared.StarterItems) do
        local info = {}
        if v.item == 'id_card' then
            info.citizenid = Player.PlayerData.citizenid
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.gender = Player.PlayerData.charinfo.gender
            info.nationality = Player.PlayerData.charinfo.nationality
        elseif v.item == 'driver_license' then
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.type = 'Class C Driver License'
        end
        exports['pradipta-inventory']:AddItem(source, v.item, 1, false, info, 'pradipta-cityhall:giveStarterItems')
    end
end

-- Callbacks

PradiptaCore.Functions.CreateCallback('pradipta-cityhall:server:receiveJobs', function(_, cb)
    cb(availableJobs)
end)

PradiptaCore.Functions.CreateCallback('pradipta-cityhall:server:getIdentityData', function(source, cb, hallId)
    local Player = exports['pradipta-core']:GetPlayer(source)
    if not Player then return cb({}) end

    local licensesMeta = Player.PlayerData.metadata['licences']
    local availableLicenses = {}

    for license, data in pairs(Config.Cityhalls[hallId].licenses) do
        if not data.metadata or licensesMeta[data.metadata] then
            availableLicenses[license] = data
        end
    end

    cb(availableLicenses)
end)

-- Events

RegisterNetEvent('pradipta-cityhall:server:requestId', function(item, hall)
    local src = source
    local Player = exports['pradipta-core']:GetPlayer(src)
    if not Player then return end
    local itemInfo = Config.Cityhalls[hall].licenses[item]
    if not Player.RemoveMoney('cash', itemInfo.cost, 'cityhall id') then return TriggerClientEvent('PradiptaCore:Notify', src, ('You don\'t have enough money on you, you need %s cash'):format(itemInfo.cost), 'error') end
    local info = {}
    if item == 'id_card' then
        info.citizenid = Player.PlayerData.citizenid
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.gender = Player.PlayerData.charinfo.gender
        info.nationality = Player.PlayerData.charinfo.nationality
    elseif item == 'driver_license' then
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.type = 'Class C Driver License'
    elseif item == 'weaponlicense' then
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
    else
        return false
    end
    if not exports['pradipta-inventory']:AddItem(source, item, 1, false, info, 'pradipta-cityhall:server:requestId') then return end
    TriggerClientEvent('pradipta-inventory:client:ItemBox', src, PradiptaCore.Shared.Items[item], 'add')
end)

RegisterNetEvent('pradipta-cityhall:server:sendDriverTest', function(instructors)
    local src = source
    local Player = exports['pradipta-core']:GetPlayer(src)
    if not Player then return end
    for i = 1, #instructors do
        local citizenid = instructors[i]
        local SchoolPlayer = PradiptaCore.Functions.GetPlayerByCitizenId(citizenid)
        if SchoolPlayer then
            TriggerClientEvent('pradipta-cityhall:client:sendDriverEmail', SchoolPlayer.PlayerData.source, Player.PlayerData.charinfo)
        else
            local mailData = {
                sender = 'Township',
                subject = 'Driving lessons request',
                message = 'Hello,<br><br>We have just received a message that someone wants to take driving lessons.<br>If you are willing to teach, please contact them:<br>Name: <strong>' .. Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname .. '<br />Phone Number: <strong>' .. Player.PlayerData.charinfo.phone .. '</strong><br><br>Kind regards,<br>Township Los Santos',
                button = {}
            }
            exports['pradipta-phone']:sendNewMailToOffline(citizenid, mailData)
        end
    end
    TriggerClientEvent('PradiptaCore:Notify', src, 'An email has been sent to driving schools, and you will be contacted automatically', 'success', 5000)
end)

RegisterNetEvent('pradipta-cityhall:server:ApplyJob', function(job, cityhallCoords)
    local src = source
    local Player = exports['pradipta-core']:GetPlayer(src)
    if not Player then return end
    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)

    local data = {
        ['src'] = src,
        ['job'] = job
    }
    if #(pedCoords - cityhallCoords) >= 20.0 or not availableJobs[job] then
        return false
    end
    local JobInfo = PradiptaCore.Shared.Jobs[job]
    Player.SetJob(data.job)
    TriggerClientEvent('PradiptaCore:Notify', data.src, Lang:t('info.new_job', { job = JobInfo.label }))
end)

RegisterNetEvent('pradipta-cityhall:server:getIDs', giveStarterItems)

-- Commands

PradiptaCore.Commands.Add('drivinglicense', 'Give a drivers license to someone', { { 'id', 'ID of a person' } }, true, function(source, args)
    local Player = exports['pradipta-core']:GetPlayer(source)
    local SearchedPlayer = exports['pradipta-core']:GetPlayer(tonumber(args[1]))
    if SearchedPlayer then
        if not SearchedPlayer.PlayerData.metadata['licences']['driver'] then
            for i = 1, #Config.DrivingSchools do
                for id = 1, #Config.DrivingSchools[i].instructors do
                    if Config.DrivingSchools[i].instructors[id] == Player.PlayerData.citizenid then
                        SearchedPlayer.PlayerData.metadata['licences']['driver'] = true
                        SearchedPlayer.Functions.SetMetaData('licences', SearchedPlayer.PlayerData.metadata['licences'])
                        TriggerClientEvent('PradiptaCore:Notify', SearchedPlayer.PlayerData.source, 'You have passed! Pick up your drivers license at the town hall', 'success', 5000)
                        TriggerClientEvent('PradiptaCore:Notify', source, ('Player with ID %s has been granted access to a driving license'):format(SearchedPlayer.PlayerData.source), 'success', 5000)
                        break
                    end
                end
            end
        else
            TriggerClientEvent('PradiptaCore:Notify', source, "Can't give permission for a drivers license, this person already has permission", 'error')
        end
    else
        TriggerClientEvent('PradiptaCore:Notify', source, 'Player Not Online', 'error')
    end
end)
