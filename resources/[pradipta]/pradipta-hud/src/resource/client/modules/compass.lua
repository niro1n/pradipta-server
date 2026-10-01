local NUI_ACTIONS        = (BabloHud and BabloHud.Constants and BabloHud.Constants.NUI_ACTIONS) or {}
local ACTION_COMPASS     = NUI_ACTIONS.UPDATE_COMPASS       or "updateCompass"
local ACTION_IN_VEHICLE  = NUI_ACTIONS.SET_COMPASS_IN_VEHICLE or "setCompassInVehicle"

local compassInVehicle  = false   
local compassThreadActive = false 

local lastHeading  = nil  
local lastStreet   = nil
local lastZone     = nil
local lastStreetCached = nil  

local CARDINAL_DIRECTIONS = { "N", "NE", "E", "SE", "S", "SW", "W", "NW" }

function GetCardinalDirection(heading)
    local normalised = heading % 360
    if normalised < 0 then normalised = normalised + 360 end
    local index = math.floor((normalised + 22.5) % 360 / 45) % 8
    return CARDINAL_DIRECTIONS[index + 1]
end

function SendCompassInVehicle(inVehicle)
    SendNUIMessage({
        action = ACTION_IN_VEHICLE,
        data   = inVehicle and true or false,
    })
end

function SendCompassUpdate(heading, street, zone)
    SendNUIMessage({
        action = ACTION_COMPASS,
        data   = { heading = heading, street = street, zone = zone },
    })
end

function ResolveLocationStrings(pos)
    local streetHash = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
    local street     = GetStreetNameFromHashKey(streetHash) or ""

    if street == "" then
        street = lastStreetCached
    else
        lastStreetCached = street
    end

    local zoneId = GetNameOfZone(pos.x, pos.y, pos.z)
    local zone   = (zoneId and GetLabelText(zoneId)) or ""

    if not street or street == "" then street = nil end

    return street, zone
end

function ShouldShowCompass()
    return compassInVehicle or (_G.BabloHudCompassShowOnFoot == true)
end

function StartCompassThread()
    if compassThreadActive then return end
    compassThreadActive = true

    CreateThread(function()
        local lastStreetRefreshTime = 0

        while compassThreadActive and _G.PradiptaHudActive do
            local ped = cache and cache.ped
            if ped and ShouldShowCompass() then
                local camRot  = GetGameplayCamRot(0)
                local heading = math.floor((360 - camRot.z % 360) % 360)

                local now = GetGameTimer()
                if now - lastStreetRefreshTime > 400 or lastStreet == nil then
                    lastStreetRefreshTime = now
                    local pos            = GetEntityCoords(ped)
                    lastStreet, lastZone = ResolveLocationStrings(pos)
                end

                if heading ~= lastHeading then
                    lastHeading = heading
                    SendCompassUpdate(heading, lastStreet, lastZone)
                end
            end

            Wait(16)
        end

        compassThreadActive = false
    end)
end

function EnterVehicleCompass()
    if compassInVehicle then return end
    compassInVehicle = true
    lastHeading = nil
    lastStreet  = nil
    lastZone    = nil
    SendCompassInVehicle(true)
    StartCompassThread()
end

function LeaveVehicleCompass()
    if not compassInVehicle then return end
    compassInVehicle = false
    lastHeading = nil
    lastStreet  = nil
    lastZone    = nil
    SendCompassInVehicle(false)
    StartCompassThread()
end

function RegisterCustomLocationNames()
    if Config and Config.CustomStreetNames then
        for hash, name in pairs(Config.CustomStreetNames) do
            AddTextEntryByHash(hash, name)
        end
    end

    if Config and Config.CustomZoneNames then
        for zoneName, label in pairs(Config.CustomZoneNames) do
            AddTextEntryByHash(GetHashKey(zoneName), label)
        end
    end
end

CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do Wait(200) end
    RegisterCustomLocationNames()
end)

AddEventHandler("pradipta-hud:playerLoaded", RegisterCustomLocationNames)

AddEventHandler("pradipta-hud:playerLoaded", function()
    CreateThread(function()
        Wait(600)
        if cache and cache.vehicle then
            EnterVehicleCompass()
        else
            SendCompassInVehicle(false)
        end
        StartCompassThread()
    end)
end)

lib.onCache("vehicle", function(vehicle)
    if not _G.PradiptaHudActive then return end
    if vehicle then
        EnterVehicleCompass()
    else
        LeaveVehicleCompass()
    end
end)

AddEventHandler("pradipta-hud:playerUnloaded", function()
    compassInVehicle    = false
    compassThreadActive = false
    SendCompassInVehicle(false)
end)

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    if compassInVehicle then
        SendCompassInVehicle(false)
    end
end)

