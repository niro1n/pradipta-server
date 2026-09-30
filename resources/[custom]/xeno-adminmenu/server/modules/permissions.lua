local PradiptaCore = exports['pradipta-core']:GetCoreObject()

RegisterNetEvent('xeno-adminmenu:server:TryOpenQuickMenu', function()
    local src = source
    DebugLog('TryOpenQuickMenu triggered by ' .. tostring(src))
    local isAdmin = exports['xeno-adminmenu']:IsAdmin(src)
    DebugLog('IsAdmin result:', isAdmin)
    if isAdmin then
        TriggerClientEvent('xeno-adminmenu:client:ToggleQuickMenu', src)
    end
end)


RegisterNetEvent('xeno-adminmenu:server:RequestGroups', function(targetSrc)
    local src = targetSrc or source
    if not exports['xeno-adminmenu']:IsAdmin(src) then return end

    MySQL.query('SELECT * FROM xeno_admin_groups', {}, function(result)
        if result then
            for i=1, #result do
                if type(result[i].permissions) == "string" then
                    result[i].permissions = json.decode(result[i].permissions) or {}
                else
                    result[i].permissions = result[i].permissions or {}
                end
            end
            TriggerClientEvent('xeno-adminmenu:client:ReceiveGroups', src, result)
        end
    end)
end)

local function BroadcastGroupsUpdate()
    MySQL.query('SELECT * FROM xeno_admin_groups', {}, function(result)
        if result then
            for i=1, #result do
                if type(result[i].permissions) == "string" then
                    result[i].permissions = json.decode(result[i].permissions) or {}
                else
                    result[i].permissions = result[i].permissions or {}
                end
            end
            for _, playerId in ipairs(GetPlayers()) do
                if exports['xeno-adminmenu']:IsAdmin(tonumber(playerId)) then
                    TriggerClientEvent('xeno-adminmenu:client:ReceiveGroups', tonumber(playerId), result)
                end
            end
        end
    end)
end


RegisterNetEvent('xeno-adminmenu:server:SaveGroup', function(groupData)
    local src = source
    DebugLog('SaveGroup Triggered by: ' .. tostring(src))
    if not exports['xeno-adminmenu']:IsAdmin(src) then
        DebugLog('SaveGroup Failed: User is not admin')
        return
    end

    if groupData.name == 'owner' then
        DebugLog('SaveGroup Failed: Cannot edit owner group')
        return
    end

    local permissionsJson = json.encode(groupData.permissions or {})
    DebugLog('SaveGroup Data:', groupData.name, groupData.id, permissionsJson)

    if groupData.id and type(groupData.id) == "number" then
        DebugLog('SaveGroup: Updating existing group')
        MySQL.update('UPDATE xeno_admin_groups SET name = ?, color = ?, permissions = ?, description = ? WHERE id = ?', {groupData.name, groupData.color, permissionsJson, groupData.description, groupData.id}, function(affectedRows)
            CreateThread(function()
                exports['xeno-adminmenu']:RefreshPermissionCache()
                BroadcastGroupsUpdate()
                if AddLog then AddLog('group', 'Updated group: ' .. groupData.name, GetPlayerName(src), nil, { group = groupData.name }, 'group_updated') end
            end)
        end)
    else
        DebugLog('SaveGroup: Inserting new group')
        MySQL.insert('INSERT INTO xeno_admin_groups (name, color, permissions, description) VALUES (?, ?, ?, ?)', {groupData.name, groupData.color, permissionsJson, groupData.description}, function(insertId)
            CreateThread(function()
                exports['xeno-adminmenu']:RefreshPermissionCache()
                BroadcastGroupsUpdate()
                if AddLog then AddLog('group', 'Created group: ' .. groupData.name, GetPlayerName(src), nil, { group = groupData.name }, 'group_created') end
            end)
        end)
    end
end)


RegisterNetEvent('xeno-adminmenu:server:DeleteGroup', function(groupId)
    local src = source
    if not exports['xeno-adminmenu']:IsAdmin(src) then return end

    local group = exports['xeno-adminmenu']:GetGroup(groupId)
    if group and group.name == 'owner' then
        return
    end

    MySQL.update('DELETE FROM xeno_admin_groups WHERE id = ?', {groupId}, function(affectedRows)
        CreateThread(function()
            exports['xeno-adminmenu']:RefreshPermissionCache()
            BroadcastGroupsUpdate()
            if AddLog then AddLog('group', 'Deleted group with ID: ' .. groupId, GetPlayerName(src), nil, { groupId = groupId }, 'group_deleted') end
        end)
    end)
end)



RegisterNetEvent('xeno-adminmenu:server:RequestStaff', function(targetSrc)
    local src = targetSrc or source
    if not exports['xeno-adminmenu']:IsAdmin(src) then return end

    MySQL.query('SELECT s.*, g.name as group_name FROM xeno_admin_staff s LEFT JOIN xeno_admin_groups g ON s.group_id = g.id WHERE s.status != ?', {'disabled'}, function(result)
        if result then
            for i=1, #result do
                if type(result[i].permissions) == "string" then
                    result[i].permissions = json.decode(result[i].permissions) or {}
                else
                    result[i].permissions = result[i].permissions or {}
                end
                result[i].isActive = (result[i].is_active == 1 or result[i].is_active == true)
                result[i].group = result[i].group_name
                result[i].addedBy = result[i].added_by
                result[i].addedDate = result[i].created_at
            end
            TriggerClientEvent('xeno-adminmenu:client:ReceiveStaff', src, result)
        end
    end)
end)

local function BroadcastStaffUpdate()
    MySQL.query('SELECT s.*, g.name as group_name FROM xeno_admin_staff s LEFT JOIN xeno_admin_groups g ON s.group_id = g.id WHERE s.status != ?', {'disabled'}, function(result)
        if result then
            for i=1, #result do
                if type(result[i].permissions) == "string" then
                    result[i].permissions = json.decode(result[i].permissions) or {}
                else
                    result[i].permissions = result[i].permissions or {}
                end
                result[i].isActive = (result[i].is_active == 1 or result[i].is_active == true)
                result[i].group = result[i].group_name
                result[i].addedBy = result[i].added_by
                result[i].addedDate = result[i].created_at
            end
            for _, playerId in ipairs(GetPlayers()) do
                if exports['xeno-adminmenu']:IsAdmin(tonumber(playerId)) then
                    TriggerClientEvent('xeno-adminmenu:client:ReceiveStaff', tonumber(playerId), result)
                end
            end
        end
    end)
end


RegisterNetEvent('xeno-adminmenu:server:SaveStaff', function(staffData)
    local src = source
    if not exports['xeno-adminmenu']:IsAdmin(src) then return end

    local permissionsJson = json.encode(staffData.permissions or {})
    local adminName = GetPlayerName(src)


    local targetGroup = exports['xeno-adminmenu']:GetGroup(staffData.group_id)
    if targetGroup and targetGroup.name == 'owner' then
        DebugLog('^1[Xeno-AdminMenu] Cannot manually assign users to the owner group via UI.^0')
        return
    end

    if staffData.id and type(staffData.id) == "number" then
        MySQL.update('UPDATE xeno_admin_staff SET name = ?, identifier = ?, group_id = ?, permissions = ? WHERE id = ?', {staffData.name, staffData.identifier, staffData.group, permissionsJson, staffData.id}, function(affectedRows)
            CreateThread(function()
                exports['xeno-adminmenu']:RefreshPermissionCache()
                BroadcastStaffUpdate()
                if AddLog then AddLog('staff', 'Updated staff: ' .. staffData.name, adminName, staffData.name, { staff = staffData.name }, 'staff_updated') end
            end)
        end)
    else
        MySQL.insert('INSERT INTO xeno_admin_staff (name, identifier, group_id, permissions, added_by, status, is_active, approved_at, approved_by) VALUES (?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, ?)', {staffData.name, staffData.identifier, staffData.group, permissionsJson, adminName, 'approved', 1, adminName}, function(insertId)
            CreateThread(function()
                exports['xeno-adminmenu']:RefreshPermissionCache()
                BroadcastStaffUpdate()
                if AddLog then AddLog('staff', 'Added new staff: ' .. staffData.name, adminName, staffData.name, { staff = staffData.name }, 'staff_added') end
            end)
        end)
    end
end)


RegisterNetEvent('xeno-adminmenu:server:DeleteStaff', function(staffId)
    local src = source
    if not exports['xeno-adminmenu']:IsAdmin(src) then return end


    local staffResult = MySQL.query.await('SELECT group_id FROM xeno_admin_staff WHERE id = ?', {staffId})
    if staffResult and #staffResult > 0 then
        local gId = staffResult[1].group_id
        local g = exports['xeno-adminmenu']:GetGroup(gId)
        if g and g.name == 'owner' then
            return
        end
    end

    MySQL.update('DELETE FROM xeno_admin_staff WHERE id = ?', {staffId}, function(affectedRows)
        CreateThread(function()
            exports['xeno-adminmenu']:RefreshPermissionCache()
            BroadcastStaffUpdate()
            if AddLog then AddLog('staff', 'Removed staff with ID: ' .. staffId, GetPlayerName(src), nil, { staffId = staffId }, 'staff_deleted') end
        end)
    end)
end)
