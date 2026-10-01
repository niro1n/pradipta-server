local NUI_ACTIONS     = (BabloHud and BabloHud.Constants and BabloHud.Constants.NUI_ACTIONS) or {}
local WAYPOINT_ACTION = NUI_ACTIONS.UPDATE_WAYPOINT or "updateWaypoint"
local POLL_INTERVAL   = 500   

local waypointActive   = nil  
local waypointDistance = nil  

function SendWaypointState(active, distance)
    SendNUIMessage({
        action = WAYPOINT_ACTION,
        data   = {
            active   = active and true or false,
            distance = distance,
        },
    })
end

function UpdateWaypoint()
    local ped = cache and cache.ped
    if not ped or not DoesEntityExist(ped) then return end

    local waypointBlip = GetFirstBlipInfoId(8)

    if not DoesBlipExist(waypointBlip) then
        
        if waypointActive ~= false then
            waypointActive   = false
            waypointDistance = nil
            SendWaypointState(false, nil)
        end
        return
    end

    local pedPos  = GetEntityCoords(ped)
    local blipPos = GetBlipInfoIdCoord(waypointBlip)
    local dx      = pedPos.x - blipPos.x
    local dy      = pedPos.y - blipPos.y
    local dist    = math.floor(math.sqrt(dx * dx + dy * dy) + 0.5)

    if waypointActive == true and waypointDistance == dist then return end

    waypointActive   = true
    waypointDistance = dist
    SendWaypointState(true, dist)
end

CreateThread(function()
    while not _G.PradiptaHudActive do Wait(250) end

    while true do
        if _G.PradiptaHudActive then
            UpdateWaypoint()
        end
        Wait(POLL_INTERVAL)
    end
end)

AddEventHandler("pradipta-hud:playerUnloaded", function()
    waypointActive   = nil
    waypointDistance = nil
    SendWaypointState(false, nil)
end)

