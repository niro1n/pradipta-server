Framework = Framework or {}

CreateThread(function()
    if Config.Framework ~= "qbcore" then return end

    local coreName = (GetResourceState("pradipta-core") == "started" or GetResourceState("pradipta-core") == "starting") and "pradipta-core" or "qb-core"
    local qbExports = exports[coreName]
    local QBCore = qbExports and qbExports:GetCoreObject()

    Framework.isAdmin = function(_, playerId)
        local id = tonumber(playerId)
        if not id then return false end

        if QBCore and QBCore.Functions and QBCore.Functions.HasPermission then
            if QBCore.Functions.HasPermission(id, "admin")
            or QBCore.Functions.HasPermission(id, "god") then
                return true
            end
        end

        return IsPlayerAceAllowed(id, "command") == true
    end
end)
