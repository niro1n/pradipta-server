Framework = nil
Core = nil

CreateThread(function()
    if Config.Framework == 'autodetect' then
        if GetResourceState('qbx_core') == 'started' then
            Framework = 'qbox'
        elseif GetResourceState('qb-core') == 'started' then
            Framework = 'qbcore'
        elseif GetResourceState('es_extended') == 'started' then
            Framework = 'esx'
        else
            Framework = 'standalone'
        end
    else
        Framework = Config.Framework
    end

    if Framework == 'qbcore' then
        Core = exports['qb-core']:GetCoreObject()
    elseif Framework == 'esx' then
        Core = exports['es_extended']:getSharedObject()
    elseif Framework == 'qbox' then
        Core = exports.qbx_core
    end
    
    DebugLog('^2[Xeno-AdminMenu] Framework initialized: ' .. Framework .. '^0')
end)

function SQLQuery(query)
    local p = promise.new()
    local resolved = false
    exports.oxmysql:execute(query, {}, function(result)
        if not resolved then
            resolved = true
            p:resolve(result)
        end
    end)
    SetTimeout(5000, function()
        if not resolved then
            resolved = true
            DebugLog('^1[Xeno-AdminMenu] SQL Query timed out: ' .. query .. '^0')
            p:resolve(nil)
        end
    end)
    return Citizen.Await(p)
end

function GetTotalEconomy()
    local total = 0
    if Framework == 'qbcore' or Framework == 'qbox' then
        local result = SQLQuery('SELECT money FROM players')
        if result then
            for i=1, #result do
                if result[i].money then
                    local money = json.decode(result[i].money)
                    if money then
                        total = total + (money.cash or 0) + (money.bank or 0)
                    end
                end
            end
        end
    elseif Framework == 'esx' then
        local result = SQLQuery('SELECT accounts FROM users')
        if result then
            for i=1, #result do
                if result[i].accounts then
                    local accs = json.decode(result[i].accounts)
                    if accs then
                        total = total + (accs.money or 0) + (accs.bank or 0)
                    end
                end
            end
        end
    end
    return total
end

function GetRichestPlayer()
    local richest = "Unknown"
    local maxMoney = -1
    
    if Framework == 'qbcore' or Framework == 'qbox' then
        local result = SQLQuery('SELECT charinfo, money FROM players')
        if result then
            for i=1, #result do
                if result[i].money and result[i].charinfo then
                    local money = json.decode(result[i].money)
                    local charinfo = json.decode(result[i].charinfo)
                    if money and charinfo then
                        local pMoney = (money.cash or 0) + (money.bank or 0)
                        if pMoney > maxMoney then
                            maxMoney = pMoney
                            richest = (charinfo.firstname or 'Unknown') .. ' ' .. (charinfo.lastname or '')
                        end
                    end
                end
            end
        end
    elseif Framework == 'esx' then
        local result = SQLQuery('SELECT firstname, lastname, accounts FROM users')
        if result then
            for i=1, #result do
                if result[i].accounts then
                    local accs = json.decode(result[i].accounts)
                    if accs then
                        local pMoney = (accs.money or 0) + (accs.bank or 0)
                        if pMoney > maxMoney then
                            maxMoney = pMoney
                            local fname = result[i].firstname or 'Unknown'
                            local lname = result[i].lastname or ''
                            richest = fname .. ' ' .. lname
                        end
                    end
                end
            end
        end
    end
    return richest
end

function IsPlayerAdmin(src)
    return IsAdmin(src)
end

function GetPlayerFrameworkData(src)
    local data = {
        name = GetPlayerName(src),
        job = 'unemployed',
        jobLabel = 'Unemployed',
        money = 0,
        bank = 0,
        isStaff = IsPlayerAdmin(src),
        gang = 'none',
        gangLabel = 'None',
        id = tonumber(src),
        hunger = 100,
        thirst = 100
    }

    if Framework == 'qbcore' then
        local Player = Core.Functions.GetPlayer(src)
        if Player then
            data.name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
            data.job = Player.PlayerData.job.name
            data.jobLabel = Player.PlayerData.job.label
            data.money = Player.PlayerData.money['cash'] or 0
            data.bank = Player.PlayerData.money['bank'] or 0
            data.gang = Player.PlayerData.gang.name
            data.gangLabel = Player.PlayerData.gang.label
            data.hunger = Player.PlayerData.metadata['hunger'] or 100
            data.thirst = Player.PlayerData.metadata['thirst'] or 100
        end
    elseif Framework == 'esx' then
        local xPlayer = Core.GetPlayerFromId(src)
        if xPlayer then
            data.name = xPlayer.getName()
            data.job = xPlayer.job.name
            data.jobLabel = xPlayer.job.label
            data.money = xPlayer.getMoney()
            data.bank = xPlayer.getAccount('bank') and xPlayer.getAccount('bank').money or 0
        end
    elseif Framework == 'qbox' then
        local Player = exports.qbx_core:GetPlayer(src)
        if Player then
            data.name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
            data.job = Player.PlayerData.job.name
            data.jobLabel = Player.PlayerData.job.label
            data.money = Player.PlayerData.money['cash'] or 0
            data.bank = Player.PlayerData.money['bank'] or 0
            data.gang = Player.PlayerData.gang.name
            data.gangLabel = Player.PlayerData.gang.label
            data.hunger = Player.PlayerData.metadata['hunger'] or 100
            data.thirst = Player.PlayerData.metadata['thirst'] or 100
        end
    end

    return data
end

function GetAllFrameworkVehicles()
    local vehicles = {}
    if Framework == 'qbcore' or Framework == 'qbox' then
        local Shared = Core and Core.Shared
        if not Shared then
            Shared = exports['qb-core']:GetCoreObject().Shared
        end
        if Shared and Shared.Vehicles then
            for k, v in pairs(Shared.Vehicles) do
                table.insert(vehicles, {
                    name = v.model or k,
                    label = v.name or v.model or k,
                    brand = v.brand or 'Unknown'
                })
            end
        end
    elseif Framework == 'esx' then
        local result = SQLQuery('SELECT * FROM vehicles')
        if result then
            for i=1, #result do
                table.insert(vehicles, {
                    name = result[i].model,
                    label = result[i].name,
                    brand = 'Unknown'
                })
            end
        end
    end
    table.sort(vehicles, function(a, b) return tostring(a.label) < tostring(b.label) end)
    
    return vehicles
end
