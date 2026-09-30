local isOwnerCommandLocked = false


RegisterCommand('xeno_make_owner', function(source, args, rawCommand)
    if source ~= 0 then
        DebugLog('^1This command can only be used from the server console!^0')
        return
    end

    if isOwnerCommandLocked then
        DebugLog('^1[Xeno-AdminMenu] The xeno_make_owner command is locked because an owner already exists!^0')
        return
    end

    local targetId = tonumber(args[1])
    if not targetId then
        DebugLog('^3Usage: xeno_make_owner <serverId>^0')
        return
    end

    local identifier = GetPlayerIdentifierByType(targetId, 'license')
    if not identifier then
        DebugLog('^1Could not find license for player ' .. targetId .. '^0')
        return
    end

    local playerName = GetPlayerName(targetId) or "Unknown"


    local ownerGroup = MySQL.query.await('SELECT id FROM xeno_admin_groups WHERE name = ?', {'owner'})
    if not ownerGroup or #ownerGroup == 0 then
        DebugLog('^1Critical Error: Owner group does not exist in the database.^0')
        return
    end
    local groupId = ownerGroup[1].id

    MySQL.insert.await([[
        INSERT INTO xeno_admin_staff (name, identifier, group_id, status, is_active, added_by, approved_at, approved_by)
        VALUES (?, ?, ?, 'approved', 1, 'Console', CURRENT_TIMESTAMP, 'Console')
        ON DUPLICATE KEY UPDATE
        group_id = ?, status = 'approved', is_active = 1, approved_at = CURRENT_TIMESTAMP, approved_by = 'Console'
    ]], {playerName, identifier, groupId, groupId})

    isOwnerCommandLocked = true
    DebugLog('^2[Xeno-AdminMenu] Successfully made ' .. playerName .. ' (' .. identifier .. ') an owner!^0')

    exports['xeno-adminmenu']:RefreshPermissionCache()
    TriggerEvent('xeno_admin:permissionsUpdated')
end, true)


CreateThread(function()
    Wait(3000)
    local ownerGroup = MySQL.query.await('SELECT id FROM xeno_admin_groups WHERE name = ?', {'owner'})
    if ownerGroup and #ownerGroup > 0 then
        local owners = MySQL.query.await('SELECT id FROM xeno_admin_staff WHERE group_id = ? AND status = ?', {ownerGroup[1].id, 'approved'})
        if owners and #owners > 0 then
            isOwnerCommandLocked = true
        end
    end
end)


RegisterNetEvent('xeno-adminmenu:server:CheckRegistrationStatus', function()
    local src = source
    if exports['xeno-adminmenu']:IsAdmin(src) then
        TriggerClientEvent('xeno-adminmenu:client:RegistrationStatus', src, { status = 'approved' })
        return
    end

    local identifier = GetPlayerIdentifierByType(src, 'license')
    if not identifier then return end

    local staff = exports['xeno-adminmenu']:GetStaff(identifier)
    if not staff then
        TriggerClientEvent('xeno-adminmenu:client:RegistrationStatus', src, { status = 'none' })
        return
    end

    TriggerClientEvent('xeno-adminmenu:client:RegistrationStatus', src, {
        status = staff.status,
        reason = staff.reject_reason
    })
end)


RegisterNetEvent('xeno-adminmenu:server:SubmitRegistration', function(reason)
    local src = source
    local identifier = GetPlayerIdentifierByType(src, 'license')
    if not identifier then return end

    if type(reason) ~= 'string' or string.len(reason) < (Config.Registration.MinReasonLength or 10) then
        return
    end

    if string.len(reason) > (Config.Registration.MaxReasonLength or 500) then
        reason = string.sub(reason, 1, Config.Registration.MaxReasonLength or 500)
    end

    local playerName = GetPlayerName(src)


    local existing = MySQL.query.await('SELECT status, rejected_at FROM xeno_admin_staff WHERE identifier = ?', {identifier})

    if existing and #existing > 0 then
        local status = existing[1].status
        if status == 'pending' or status == 'approved' or status == 'disabled' then

            return
        elseif status == 'rejected' then

            if existing[1].rejected_at then



            end

            MySQL.update.await('UPDATE xeno_admin_staff SET status = ?, apply_reason = ?, reject_reason = NULL, name = ? WHERE identifier = ?', {'pending', reason, playerName, identifier})
            if AddLog then AddLog('staff', 'Re-submitted registration application', playerName, nil, { reason = reason }, 'staff_added') end
        end
    else
        MySQL.insert.await('INSERT INTO xeno_admin_staff (name, identifier, status, apply_reason) VALUES (?, ?, ?, ?)', {playerName, identifier, 'pending', reason})
        if AddLog then AddLog('staff', 'Submitted registration application', playerName, nil, { reason = reason }, 'staff_added') end
    end


    TriggerClientEvent('xeno-adminmenu:client:RegistrationStatus', src, { status = 'pending' })


    for _, playerId in ipairs(GetPlayers()) do
        if exports['xeno-adminmenu']:IsAdmin(playerId) then
            TriggerClientEvent('xeno-adminmenu:client:Notify', playerId, 'New admin registration application from ' .. playerName, 'info')
        end
    end
end)


RegisterNetEvent('xeno-adminmenu:server:GetPendingRegistrations', function()
    local src = source
    if not exports['xeno-adminmenu']:IsAdmin(src) then return end

    MySQL.query('SELECT id, name, identifier, status, apply_reason, created_at, updated_at FROM xeno_admin_staff WHERE status = ?', {'pending'}, function(results)
        TriggerClientEvent('xeno-adminmenu:client:ReceivePendingRegistrations', src, results)
    end)
end)


RegisterNetEvent('xeno-adminmenu:server:ApproveRegistration', function(identifier)
    local src = source
    if not exports['xeno-adminmenu']:IsAdmin(src) then return end

    local adminName = GetPlayerName(src)

    MySQL.update('UPDATE xeno_admin_staff SET status = ?, approved_at = CURRENT_TIMESTAMP, approved_by = ? WHERE identifier = ?',
    {'approved', adminName, identifier}, function(affectedRows)
        if affectedRows > 0 then
            exports['xeno-adminmenu']:RefreshPermissionCache()
            TriggerEvent('xeno_admin:permissionsUpdated')
            if AddLog then AddLog('staff', 'Approved registration for ' .. identifier, adminName, nil, { targetIdentifier = identifier }, 'staff_added') end


            MySQL.query('SELECT id, name, identifier, status, apply_reason, created_at, updated_at FROM xeno_admin_staff WHERE status = ?', {'pending'}, function(results)
                TriggerClientEvent('xeno-adminmenu:client:ReceivePendingRegistrations', src, results)
            end)
        end
    end)
end)


RegisterNetEvent('xeno-adminmenu:server:RejectRegistration', function(identifier, reason)
    local src = source
    if not exports['xeno-adminmenu']:IsAdmin(src) then return end

    if type(reason) ~= 'string' then reason = "No reason provided." end
    if string.len(reason) > (Config.Registration.MaxRejectReasonLength or 500) then
        reason = string.sub(reason, 1, (Config.Registration.MaxRejectReasonLength or 500))
    end

    local adminName = GetPlayerName(src)

    MySQL.update('UPDATE xeno_admin_staff SET status = ?, reject_reason = ?, rejected_at = CURRENT_TIMESTAMP, rejected_by = ? WHERE identifier = ?',
    {'rejected', reason, adminName, identifier}, function(affectedRows)
        if affectedRows > 0 then
            if AddLog then AddLog('staff', 'Rejected registration for ' .. identifier, adminName, nil, { targetIdentifier = identifier, reason = reason }, 'staff_deleted') end


            MySQL.query('SELECT id, name, identifier, status, apply_reason, created_at, updated_at FROM xeno_admin_staff WHERE status = ?', {'pending'}, function(results)
                TriggerClientEvent('xeno-adminmenu:client:ReceivePendingRegistrations', src, results)
            end)
        end
    end)
end)
