-- Add or change (a) method(s) in the PradiptaCore.Functions table
local function SetMethod(methodName, handler)
    if type(methodName) ~= 'string' then
        return false, 'invalid_method_name'
    end
    if PradiptaCore.Functions[methodName] ~= nil then
        return false, 'method_exists'
    end
    PradiptaCore.Functions[methodName] = handler
    TriggerEvent('PradiptaCore:Server:UpdateObject')
    return true, 'success'
end

PradiptaCore.Functions.SetMethod = SetMethod
exports('SetMethod', SetMethod)

-- Add or change (a) field(s) in the PradiptaCore table
local function SetField(fieldName, data)
    if type(fieldName) ~= 'string' then
        return false, 'invalid_field_name'
    end
    if PradiptaCore[fieldName] ~= nil then
        return false, 'field_exists'
    end
    PradiptaCore[fieldName] = data
    TriggerEvent('PradiptaCore:Server:UpdateObject')
    return true, 'success'
end

PradiptaCore.Functions.SetField = SetField
exports('SetField', SetField)

-- Single add job function which should only be used if you planning on adding a single job
local function AddJob(jobName, job)
    if type(jobName) ~= 'string' then
        return false, 'invalid_job_name'
    end

    if PradiptaCore.Shared.Jobs[jobName] then
        return false, 'job_exists'
    end

    PradiptaCore.Shared.Jobs[jobName] = job

    TriggerClientEvent('PradiptaCore:Client:OnSharedUpdate', -1, 'Jobs', jobName, job)
    TriggerEvent('PradiptaCore:Server:UpdateObject')
    return true, 'success'
end

PradiptaCore.Functions.AddJob = AddJob
exports('AddJob', AddJob)

-- Multiple Add Jobs
local function AddJobs(jobs)
    for key, value in pairs(jobs) do
        if type(key) ~= 'string' then return false, 'invalid_job_name', value end
        if PradiptaCore.Shared.Jobs[key] then return false, 'job_exists', value end
    end
    for key, value in pairs(jobs) do
        PradiptaCore.Shared.Jobs[key] = value
    end
    TriggerClientEvent('PradiptaCore:Client:OnSharedUpdateMultiple', -1, 'Jobs', jobs)
    TriggerEvent('PradiptaCore:Server:UpdateObject')
    return true, 'success', nil
end

PradiptaCore.Functions.AddJobs = AddJobs
exports('AddJobs', AddJobs)

-- Single Remove Job
local function RemoveJob(jobName)
    if type(jobName) ~= 'string' then
        return false, 'invalid_job_name'
    end

    if not PradiptaCore.Shared.Jobs[jobName] then
        return false, 'job_not_exists'
    end

    PradiptaCore.Shared.Jobs[jobName] = nil

    TriggerClientEvent('PradiptaCore:Client:OnSharedUpdate', -1, 'Jobs', jobName, nil)
    TriggerEvent('PradiptaCore:Server:UpdateObject')
    return true, 'success'
end

PradiptaCore.Functions.RemoveJob = RemoveJob
exports('RemoveJob', RemoveJob)

-- Single Update Job
local function UpdateJob(jobName, job)
    if type(jobName) ~= 'string' then
        return false, 'invalid_job_name'
    end

    if not PradiptaCore.Shared.Jobs[jobName] then
        return false, 'job_not_exists'
    end

    PradiptaCore.Shared.Jobs[jobName] = job

    TriggerClientEvent('PradiptaCore:Client:OnSharedUpdate', -1, 'Jobs', jobName, job)
    TriggerEvent('PradiptaCore:Server:UpdateObject')
    return true, 'success'
end

PradiptaCore.Functions.UpdateJob = UpdateJob
exports('UpdateJob', UpdateJob)

-- Single add item
local function AddItem(itemName, item)
    if type(itemName) ~= 'string' then
        return false, 'invalid_item_name'
    end

    if PradiptaCore.Shared.Items[itemName] then
        return false, 'item_exists'
    end

    PradiptaCore.Shared.Items[itemName] = item

    TriggerClientEvent('PradiptaCore:Client:OnSharedUpdate', -1, 'Items', itemName, item)
    TriggerEvent('PradiptaCore:Server:UpdateObject')
    return true, 'success'
end

PradiptaCore.Functions.AddItem = AddItem
exports('AddItem', AddItem)

-- Single update item
local function UpdateItem(itemName, item)
    if type(itemName) ~= 'string' then
        return false, 'invalid_item_name'
    end
    if not PradiptaCore.Shared.Items[itemName] then
        return false, 'item_not_exists'
    end
    PradiptaCore.Shared.Items[itemName] = item
    TriggerClientEvent('PradiptaCore:Client:OnSharedUpdate', -1, 'Items', itemName, item)
    TriggerEvent('PradiptaCore:Server:UpdateObject')
    return true, 'success'
end

PradiptaCore.Functions.UpdateItem = UpdateItem
exports('UpdateItem', UpdateItem)

-- Multiple Add Items
local function AddItems(items)
    for key, value in pairs(items) do
        if type(key) ~= 'string' then return false, 'invalid_item_name', value end
        if PradiptaCore.Shared.Items[key] then return false, 'item_exists', value end
    end
    for key, value in pairs(items) do
        PradiptaCore.Shared.Items[key] = value
    end
    TriggerClientEvent('PradiptaCore:Client:OnSharedUpdateMultiple', -1, 'Items', items)
    TriggerEvent('PradiptaCore:Server:UpdateObject')
    return true, 'success', nil
end

PradiptaCore.Functions.AddItems = AddItems
exports('AddItems', AddItems)

-- Single Remove Item
local function RemoveItem(itemName)
    if type(itemName) ~= 'string' then
        return false, 'invalid_item_name'
    end

    if not PradiptaCore.Shared.Items[itemName] then
        return false, 'item_not_exists'
    end

    PradiptaCore.Shared.Items[itemName] = nil

    TriggerClientEvent('PradiptaCore:Client:OnSharedUpdate', -1, 'Items', itemName, nil)
    TriggerEvent('PradiptaCore:Server:UpdateObject')
    return true, 'success'
end

PradiptaCore.Functions.RemoveItem = RemoveItem
exports('RemoveItem', RemoveItem)

-- Single Add Gang
local function AddGang(gangName, gang)
    if type(gangName) ~= 'string' then
        return false, 'invalid_gang_name'
    end

    if PradiptaCore.Shared.Gangs[gangName] then
        return false, 'gang_exists'
    end

    PradiptaCore.Shared.Gangs[gangName] = gang

    TriggerClientEvent('PradiptaCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, gang)
    TriggerEvent('PradiptaCore:Server:UpdateObject')
    return true, 'success'
end

PradiptaCore.Functions.AddGang = AddGang
exports('AddGang', AddGang)

-- Multiple Add Gangs
local function AddGangs(gangs)
    for key, value in pairs(gangs) do
        if type(key) ~= 'string' then return false, 'invalid_gang_name', value end
        if PradiptaCore.Shared.Gangs[key] then return false, 'gang_exists', value end
    end
    for key, value in pairs(gangs) do
        PradiptaCore.Shared.Gangs[key] = value
    end
    TriggerClientEvent('PradiptaCore:Client:OnSharedUpdateMultiple', -1, 'Gangs', gangs)
    TriggerEvent('PradiptaCore:Server:UpdateObject')
    return true, 'success', nil
end

PradiptaCore.Functions.AddGangs = AddGangs
exports('AddGangs', AddGangs)

-- Single Remove Gang
local function RemoveGang(gangName)
    if type(gangName) ~= 'string' then
        return false, 'invalid_gang_name'
    end

    if not PradiptaCore.Shared.Gangs[gangName] then
        return false, 'gang_not_exists'
    end

    PradiptaCore.Shared.Gangs[gangName] = nil

    TriggerClientEvent('PradiptaCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, nil)
    TriggerEvent('PradiptaCore:Server:UpdateObject')
    return true, 'success'
end

PradiptaCore.Functions.RemoveGang = RemoveGang
exports('RemoveGang', RemoveGang)

-- Single Update Gang
local function UpdateGang(gangName, gang)
    if type(gangName) ~= 'string' then
        return false, 'invalid_gang_name'
    end

    if not PradiptaCore.Shared.Gangs[gangName] then
        return false, 'gang_not_exists'
    end

    PradiptaCore.Shared.Gangs[gangName] = gang

    TriggerClientEvent('PradiptaCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, gang)
    TriggerEvent('PradiptaCore:Server:UpdateObject')
    return true, 'success'
end

PradiptaCore.Functions.UpdateGang = UpdateGang
exports('UpdateGang', UpdateGang)

local resourceName = GetCurrentResourceName()
local function GetCoreVersion(InvokingResource)
    local resourceVersion = GetResourceMetadata(resourceName, 'version')
    if InvokingResource and InvokingResource ~= '' then
        print(('%s called pradiptacore version check: %s'):format(InvokingResource or 'Unknown Resource', resourceVersion))
    end
    return resourceVersion
end

PradiptaCore.Functions.GetCoreVersion = GetCoreVersion
exports('GetCoreVersion', GetCoreVersion)

local function ExploitBan(playerId, origin)
    local name = GetPlayerName(playerId)
    MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        name,
        PradiptaCore.Functions.GetIdentifier(playerId, 'license'),
        PradiptaCore.Functions.GetIdentifier(playerId, 'discord'),
        PradiptaCore.Functions.GetIdentifier(playerId, 'ip'),
        origin,
        2147483647,
        'Anti Cheat'
    })
    DropPlayer(playerId, Lang:t('info.exploit_banned', { discord = PradiptaCore.Config.Server.Discord }))
    TriggerEvent('pradipta-log:server:CreateLog', 'anticheat', 'Anti-Cheat', 'red', name .. ' has been banned for exploiting ' .. origin, true)
end

exports('ExploitBan', ExploitBan)
