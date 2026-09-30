local PradiptaCore = exports['pradipta-core']:GetCoreObject({ 'Commands' })
local Races = {}

-- Functions

local function GetCreatedRace(identifier)
    for key in pairs(Races) do
        if Races[key] ~= nil and Races[key].creator == identifier and not Races[key].started then
            return key
        end
    end
    return 0
end

local function CancelRace(source)
    local RaceId = GetCreatedRace(source)
    local Player = exports['pradipta-core']:GetPlayer(source)
    if RaceId ~= 0 then
        for key in pairs(Races) do
            if Races[key] ~= nil and Races[key].creator == source then
                if not Races[key].started then
                    for _, iden in pairs(Races[key].joined) do
                        local xdPlayer = exports['pradipta-core']:GetPlayer(iden)
                        xdPlayer.Functions.AddMoney('cash', Races[key].amount, 'Race')
                        TriggerClientEvent('PradiptaCore:Notify', xdPlayer.PlayerData.source, 'Race Has Ended, You Got Back ' .. Config.Currency .. Races[key].amount .. '', 'error')
                        TriggerClientEvent('pradipta-streetraces:StopRace', xdPlayer.PlayerData.source)
                    end
                else
                    TriggerClientEvent('PradiptaCore:Notify', Player.PlayerData.source, 'The Race Has Already Started', 'error')
                end
                TriggerClientEvent('PradiptaCore:Notify', source, 'Race Stopped!', 'error')
                Races[key] = nil
            end
        end
        TriggerClientEvent('pradipta-streetraces:SetRace', -1, Races)
    else
        TriggerClientEvent('PradiptaCore:Notify', source, 'You Have Not Started A Race!', 'error')
    end
end

local function UpdateRaceInfo(race)
    for _, src in pairs(race.joined) do
        TriggerClientEvent('pradipta-streetraces:UpdateRaceInfo', src, #race.joined, race.pot)
    end
end

function RemoveFromRace(identifier)
    for key in pairs(Races) do
        if Races[key] ~= nil and not Races[key].started then
            for i, iden in pairs(Races[key].joined) do
                if iden == identifier then
                    table.remove(Races[key].joined, i)
                end
            end
        end
    end
end

local function GetJoinedRace(identifier)
    for key in pairs(Races) do
        if Races[key] ~= nil and not Races[key].started then
            for _, iden in pairs(Races[key].joined) do
                if iden == identifier then
                    return key
                end
            end
        end
    end
    return 0
end

-- Events

RegisterNetEvent('pradipta-streetraces:NewRace', function(RaceTable)
    local src = source
    local RaceId = math.random(1000, 9999)
    local xPlayer = exports['pradipta-core']:GetPlayer(src)
    if xPlayer.Functions.RemoveMoney('cash', RaceTable.amount, 'streetrace-created') then
        Races[RaceId] = RaceTable
        Races[RaceId].creator = src
        Races[RaceId].joined[#Races[RaceId].joined + 1] = src
        TriggerClientEvent('pradipta-streetraces:SetRace', -1, Races)
        TriggerClientEvent('pradipta-streetraces:SetRaceId', src, RaceId)
        TriggerClientEvent('PradiptaCore:Notify', src, 'You joined the race for ' .. Config.Currency .. Races[RaceId].amount .. '.', 'success')
        UpdateRaceInfo(Races[RaceId])
    else
        TriggerClientEvent('PradiptaCore:Notify', src, 'You do not have ' .. Config.Currency .. RaceTable.amount .. '.', 'error')
    end
end)

RegisterNetEvent('pradipta-streetraces:RaceWon', function(RaceId)
    local src = source
    local xPlayer = exports['pradipta-core']:GetPlayer(src)
    xPlayer.Functions.AddMoney('cash', Races[RaceId].pot, 'race-won')
    TriggerClientEvent('PradiptaCore:Notify', src, 'You won the race and ' .. Config.Currency .. Races[RaceId].pot .. ',- recieved', 'success')
    TriggerClientEvent('pradipta-streetraces:SetRace', -1, Races)
    TriggerClientEvent('pradipta-streetraces:RaceDone', -1, RaceId, GetPlayerName(src))
end)

RegisterNetEvent('pradipta-streetraces:JoinRace', function(RaceId)
    local src = source
    local xPlayer = exports['pradipta-core']:GetPlayer(src)
    local zPlayer = exports['pradipta-core']:GetPlayer(Races[RaceId].creator)
    if zPlayer ~= nil then
        if xPlayer.Functions.RemoveMoney('cash', Races[RaceId].amount, 'streetrace-joined') then
            Races[RaceId].pot = Races[RaceId].pot + Races[RaceId].amount
            Races[RaceId].joined[#Races[RaceId].joined + 1] = src
            TriggerClientEvent('pradipta-streetraces:SetRace', -1, Races)
            TriggerClientEvent('pradipta-streetraces:SetRaceId', src, RaceId)
            TriggerClientEvent('PradiptaCore:Notify', src, 'You joined the race', 'primary')
            TriggerClientEvent('PradiptaCore:Notify', Races[RaceId].creator, GetPlayerName(src) .. ' Joined the race', 'primary')
            UpdateRaceInfo(Races[RaceId])
        else
            TriggerClientEvent('PradiptaCore:Notify', src, 'You dont have enough cash', 'error')
        end
    else
        TriggerClientEvent('PradiptaCore:Notify', src, 'The person wo made the race is offline!', 'error')
        Races[RaceId] = {}
    end
end)

-- Commands

PradiptaCore.Commands.Add(Config.Commands.CreateRace, 'Start A Street Race', { { name = 'amount', help = 'The Stake Amount For The Race.' } }, false, function(source, args)
    local src = source
    local amount = tonumber(args[1])

    if not amount then return TriggerClientEvent('PradiptaCore:Notify', src, 'Usage: /' .. Config.Commands.CreateRace .. ' [AMOUNT]', 'error') end
    if amount < Config.MinimumStake then
        return TriggerClientEvent('PradiptaCore:Notify', src, 'The minimum stake is ' .. Config.Currency .. Config.MinimumStake, 'error')
    end
    if amount > Config.MaximumStake then
        return TriggerClientEvent('PradiptaCore:Notify', src, 'The maximum stake is ' .. Config.Currency .. Config.MaximumStake, 'error')
    end


    if GetJoinedRace(src) == 0 then
        TriggerClientEvent('pradipta-streetraces:CreateRace', src, amount)
    else
        TriggerClientEvent('PradiptaCore:Notify', src, 'You Are Already In A Race', 'error')
    end
end)

PradiptaCore.Commands.Add(Config.Commands.CancelRace, 'Stop The Race You Created', {}, false, function(source, _)
    CancelRace(source)
end)

PradiptaCore.Commands.Add(Config.Commands.QuitRace, 'Leave A Race', {}, false, function(source, _)
    local src = source
    local RaceId = GetJoinedRace(src)
    if RaceId ~= 0 then
        if GetCreatedRace(src) ~= RaceId then
            local xPlayer = exports['pradipta-core']:GetPlayer(src)
            xPlayer.Functions.AddMoney('cash', Races[RaceId].amount, 'Race Quit')

            Races[RaceId].pot = Races[RaceId].pot - Races[RaceId].amount
            TriggerClientEvent('pradipta-streetraces:SetRace', -1, Races)

            TriggerClientEvent('pradipta-streetraces:StopRace', src)
            RemoveFromRace(src)
            TriggerClientEvent('PradiptaCore:Notify', src, 'You Have Stepped Out Of The Race!', 'error')
            UpdateRaceInfo(Races[RaceId])
        else
            TriggerClientEvent('PradiptaCore:Notify', src, '/' .. Config.Commands.CancelRace .. ' To Stop The Race', 'error')
        end
    else
        TriggerClientEvent('PradiptaCore:Notify', src, 'You Are Not In A Race ', 'error')
    end
end)

PradiptaCore.Commands.Add(Config.Commands.StartRace, 'Start The Race', {}, false, function(source)
    local src = source
    local RaceId = GetCreatedRace(src)

    if RaceId ~= 0 then
        Races[RaceId].started = true
        TriggerClientEvent('pradipta-streetraces:SetRace', -1, Races)
        TriggerClientEvent('pradipta-streetraces:StartRace', -1, RaceId)
    else
        TriggerClientEvent('PradiptaCore:Notify', src, 'You Have Not Started A Race', 'error')
    end
end)
