local CachedGroups = {}
local CachedStaff = {}
local IsCacheReady = false


function GetGroup(groupId)
    if not IsCacheReady then return nil end
    return CachedGroups[groupId]
end


function GetStaff(identifier)
    if not IsCacheReady then return nil end
    return CachedStaff[identifier]
end


function RefreshPermissionCache()
    IsCacheReady = false
    CachedGroups = {}
    CachedStaff = {}

    local groups = MySQL.query.await('SELECT * FROM xeno_admin_groups', {})
    if groups then
        for i = 1, #groups do
            local g = groups[i]
            if type(g.permissions) == "string" and g.permissions ~= "" then
                g.permissions = json.decode(g.permissions) or {}
            else
                g.permissions = {}
            end
            CachedGroups[g.id] = g
        end
    end

    local staff = MySQL.query.await('SELECT * FROM xeno_admin_staff', {})
    if staff then
        for i = 1, #staff do
            local s = staff[i]
            if type(s.permissions) == "string" and s.permissions ~= "" then
                s.permissions = json.decode(s.permissions) or {}
            else
                s.permissions = {}
            end
            CachedStaff[s.identifier] = s
        end
    end

    IsCacheReady = true
    DebugLog('^2[Xeno-AdminMenu] Permission Cache Refreshed ('..#groups..' groups, '..#staff..' staff).^0')
end


function ValidateStartup()
    
    Wait(4000)
    
    local ownerGroup = MySQL.query.await('SELECT id FROM xeno_admin_groups WHERE name = ?', {'owner'})
    if not ownerGroup or #ownerGroup == 0 then
        DebugLog('^3[Xeno-AdminMenu] Owner group not found. Creating default owner group...^0')
        MySQL.insert.await('INSERT INTO xeno_admin_groups (name, color, description, permissions) VALUES (?, ?, ?, ?)', {
            'owner', '#ef4444', 'System Owner (Protected)', json.encode({'*'})
        })
    end

    RefreshPermissionCache()
end

CreateThread(function()
    ValidateStartup()
end)


function GetPlayerAdminRole(src)
    if not src or src == 0 or src == "" then return 'god' end
    src = tonumber(src)
    if not src then return nil end

    -- 1. FiveM ACE Permissions (Highest Priority)
    if IsPlayerAceAllowed(src, 'command') or IsPlayerAceAllowed(src, 'pradiptacore.god') then
        return 'god'
    elseif IsPlayerAceAllowed(src, 'pradiptacore.admin') then
        return 'admin'
    elseif IsPlayerAceAllowed(src, 'pradiptacore.mod') then
        return 'mod'
    end

    -- 2. PradiptaCore Framework Permissions
    local PradiptaCore = Core
    if not PradiptaCore then
        pcall(function() PradiptaCore = exports['pradipta-core']:GetCoreObject() end)
    end
    if PradiptaCore and PradiptaCore.Functions and PradiptaCore.Functions.HasPermission then
        if PradiptaCore.Functions.HasPermission(src, 'god') then
            return 'god'
        elseif PradiptaCore.Functions.HasPermission(src, 'admin') then
            return 'admin'
        elseif PradiptaCore.Functions.HasPermission(src, 'mod') then
            return 'mod'
        end
    end

    -- 3. Fallback: Xeno DB Staff Database
    local identifier = GetPlayerIdentifierByType(src, 'license')
    if identifier then
        local staff = GetStaff(identifier)
        if staff and staff.status == 'approved' and (staff.is_active == 1 or staff.is_active == true) and staff.group_id ~= nil then
            local group = GetGroup(staff.group_id)
            if group and group.name then
                return group.name
            end
            return 'mod'
        end
    end

    return nil
end

function IsAdmin(src)
    if not src or src == 0 or src == "" then return true end
    local role = GetPlayerAdminRole(src)
    return role ~= nil
end

local ModAllowedPermissions = {
    ['spectate'] = true,
    ['goto'] = true,
    ['bring'] = true,
    ['heal'] = true,
    ['revive'] = true,
    ['freeze'] = true,
    ['slap'] = true,
    ['toggleDrunk'] = true,
    ['setWaypoint'] = true,
    ['kick'] = true,
    ['warn'] = true,
    ['reports'] = true,
    ['noclip'] = true,
    ['tpm'] = true,
    ['godmode'] = true,
    ['coords'] = true,
    ['playerIds'] = true,
    ['fixVehicle'] = true,
    ['repairVehicle'] = true,
    ['flipVehicle'] = true
}

function HasPermission(src, permission)
    if not src or src == 0 or src == "" then return true end
    local role = GetPlayerAdminRole(src)
    if not role then return false end

    -- God / Owner has unrestricted access to everything
    if role == 'god' or role == 'owner' then
        return true
    end

    -- Admin has access to all operational features except raw server console execution
    if role == 'admin' then
        if permission == 'console_command' then
            return false
        end
        return true
    end

    -- Moderator has access only to specific moderation actions
    if role == 'mod' then
        if ModAllowedPermissions[permission] == true then
            return true
        end
        return false
    end

    -- Fallback: Check custom granular permissions from DB
    local identifier = GetPlayerIdentifierByType(src, 'license')
    if identifier then
        local staff = GetStaff(identifier)
        if staff and staff.status == 'approved' and (staff.is_active == 1 or staff.is_active == true) and staff.group_id ~= nil then
            local group = GetGroup(staff.group_id)
            if group then
                for _, p in ipairs(group.permissions) do
                    if p == '*' or p == permission then
                        return true
                    end
                end
            end

            for _, p in ipairs(staff.permissions) do
                if p == '*' or p == permission then
                    return true
                end
            end
        end
    end

    return false
end

exports('IsAdmin', IsAdmin)
exports('HasPermission', HasPermission)
exports('GetPlayerAdminRole', GetPlayerAdminRole)
exports('GetStaff', GetStaff)
exports('GetGroup', GetGroup)
exports('RefreshPermissionCache', RefreshPermissionCache)


RegisterNetEvent('xeno_admin:permissionsUpdated', function()
    
    if source == '' or source == 0 then
        RefreshPermissionCache()
    end
end)
