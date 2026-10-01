local NUI_ACTIONS = (BabloHud and BabloHud.Constants and BabloHud.Constants.NUI_ACTIONS) or {}

local HEALTH_MIN = 100   
local HEALTH_MAX = 200   

local lastStatus = {}
local running    = false

function ClampStat(value)
    return math.max(0, math.min(100, math.floor(value)))
end

function HasStatusChanged(newStatus, threshold)
    threshold = threshold or 1
    for key, value in pairs(newStatus) do
        if type(value) == "number" then
            local prev = lastStatus[key] or -999
            if math.abs(value - prev) >= threshold then return true end
        elseif type(value) == "boolean" then
            if lastStatus[key] ~= value then return true end
        end
    end
    return false
end

function ReadNitro()
    if not (Config and Config.Nitro and Config.Nitro.enabled) then return 0 end
    if not (Framework and Framework.getNitro) then return 0 end
    local raw = tonumber(Framework:getNitro()) or 0
    return ClampStat(raw)
end

function ReadStress()
    if Config and Config.Stress and Config.Stress.integrated then
        if Bablo and Bablo.Stress then
            return ClampStat(Bablo.Stress:Get())
        end
    elseif Framework and Framework.getStress then
        return ClampStat(tonumber(Framework:getStress()) or 0)
    end
    return 0
end

function ReadOxygen(ped, playerId)
    if not IsPedSwimmingUnderWater(ped) then return 100 end
    local remaining = GetPlayerUnderwaterTimeRemaining(playerId) * 10
    return ClampStat(remaining)
end

function CollectStatus()
    local ped = PlayerPedId()
    if not DoesEntityExist(ped) then return nil end

    local playerId = PlayerId()

    local rawHealth = GetEntityHealth(ped)
    local health    = ClampStat((rawHealth - HEALTH_MIN) / (HEALTH_MAX - HEALTH_MIN) * 100)

    local armor   = GetPedArmour(ped)

    local stamina = ClampStat(100 - GetPlayerSprintStaminaRemaining(playerId))

    local oxygen     = ReadOxygen(ped, playerId)
    local inVehicle  = IsPedInAnyVehicle(ped, false) and true or false
    local isUnderwater = IsPedSwimmingUnderWater(ped)

    local hunger = 100
    local thirst = 100
    if Framework and Framework.getHunger then
        hunger = ClampStat(tonumber(Framework:getHunger()) or 100)
    end
    if Framework and Framework.getThirst then
        thirst = ClampStat(tonumber(Framework:getThirst()) or 100)
    end

    local stress = ReadStress()
    local nitro  = ReadNitro()

    return {
        health      = health,
        armor       = armor,
        stamina     = stamina,
        oxygen      = oxygen,
        hunger      = hunger,
        thirst      = thirst,
        stress      = stress,
        nitro       = nitro,
        isUnderwater = isUnderwater,
        inVehicle   = inVehicle,
    }
end

function SendStatus(status)
    if not status then return end
    SendNUIMessage({
        action = NUI_ACTIONS.UPDATE_STATUS or "updateStatus",
        data   = status,
    })
end

function StartStatusModule()
    if running then return end
    running = true
    Info("Status module started")

    CreateThread(function()
        local warmupFrames = 10

        while running do
            local status = CollectStatus()

            if status then
                if warmupFrames > 0 then
                    SendStatus(status)
                    lastStatus   = status
                    warmupFrames = warmupFrames - 1
                elseif HasStatusChanged(status, 1) then
                    SendStatus(status)
                    lastStatus = status
                end
            end

            local fastPoll = status and status.stamina < 95
            Wait(fastPoll and 250 or 500)
        end
    end)
end

function ForceRefresh()
    if not running then return end
    local status = CollectStatus()
    if not status then return end
    SendStatus(status)
    lastStatus = status
end

AddEventHandler("pradipta-hud:status:refresh", ForceRefresh)

AddEventHandler("pradipta-hud:playerLoaded", function()
    StartStatusModule()
end)

AddEventHandler("pradipta-hud:playerUnloaded", function()
    running    = false
    lastStatus = {}
end)
