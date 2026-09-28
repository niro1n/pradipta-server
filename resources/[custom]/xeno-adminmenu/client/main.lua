local isMenuOpen = false
local isQuickMenuOpen = false

local function ToggleAdminMenu()
    isMenuOpen = not isMenuOpen
    
    if isMenuOpen then
        TriggerServerEvent('xeno-adminmenu:server:CheckRegistrationStatus')
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'setStatus',
            status = true
        })
    else
        SetNuiFocus(false, false)
        SendNUIMessage({
            action = 'setStatus',
            status = false
        })
    end
end

RegisterNetEvent('xeno-adminmenu:client:OpenMenuDirect', function()
    ToggleAdminMenu()
end)

RegisterCommand('admin', function()
    ToggleAdminMenu()
end, false)

RegisterCommand('adminmenu', function()
    ToggleAdminMenu()
end, false)

RegisterNetEvent('xeno-adminmenu:client:RegistrationStatus', function(data)
    SendNUIMessage({
        action = 'setRegistrationStatus',
        status = data.status,
        reason = data.reason
    })
    
    if data.status == 'approved' then
        TriggerServerEvent('xeno-adminmenu:server:RequestDashboardStats')
        TriggerServerEvent('xeno-adminmenu:server:RequestPlayersData')
        TriggerServerEvent('xeno-adminmenu:server:RequestResources')
    end
end)

RegisterCommand('quickmenu', function()
    DebugLog('QuickMenu command triggered')
    TriggerServerEvent('xeno-adminmenu:server:TryOpenQuickMenu')
end, false)

RegisterNetEvent('xeno-adminmenu:client:ToggleQuickMenu', function()
    DebugLog('ToggleQuickMenu triggered from server')
    isQuickMenuOpen = not isQuickMenuOpen
    
    if isQuickMenuOpen then
        TriggerServerEvent('xeno-adminmenu:server:RequestPlayersData')
        SetNuiFocus(true, false) 
        SendNUIMessage({
            action = 'setQuickMenuStatus',
            status = true
        })
    else
        SetNuiFocus(false, false)
        SendNUIMessage({
            action = 'setQuickMenuStatus',
            status = false
        })
    end
end)

RegisterNetEvent('xeno-adminmenu:client:ReceiveDashboardStats', function(stats)
    SendNUIMessage({
        action = 'changeStats',
        onlinePlayers = stats.onlinePlayers,
        activeAdmins = stats.activeAdmins,
        maxPlayers = stats.maxPlayers,
        averagePing = stats.averagePing,
        mapResources = stats.mapResources,
        serverName = stats.serverName,
        serverUptime = stats.serverUptime
    })
    
    SendNUIMessage({
        action = 'changeEconomyStatus',
        totalMoney = stats.totalMoney,
        richestPlayer = stats.richestPlayer
    })
end)

RegisterNetEvent('xeno-adminmenu:client:ReceivePlayersData', function(data)
    SendNUIMessage({
        action = 'setPlayers',
        players = data.players
    })
    
    SendNUIMessage({
        action = 'setPlayersDataStats',
        averageMoney = data.averageMoney,
        policeOfficers = data.policeOfficers,
        mostCommonJob = data.mostCommonJob,
        averagePlaytime = data.averagePlaytime
    })
end)


RegisterKeyMapping('adminmenu', 'Open Admin Menu', 'keyboard', Config.MenuKey)
RegisterKeyMapping('quickmenu', 'Open Quick Menu', 'keyboard', 'F10')
RegisterKeyMapping('noclip', 'Toggle NoClip', 'keyboard', Config.NoclipKey)

RegisterCommand('noclip', function()
    TriggerServerEvent('xeno-adminmenu:server:ToggleNoClip')
end, false)


RegisterNUICallback('getTranslations', function(data, cb)
    DebugLog("UI is requesting translations!")
    if Locales and Locales['en'] and Locales['en'].ui then
        DebugLog("Sending translations, sideBarHeader is: " .. tostring(Locales['en'].ui.sideBarHeader))
        cb(Locales['en'].ui)
    else
        DebugLog("Locales not found!")
        cb({})
    end
end)

RegisterNUICallback('setStatus', function(data, cb)
    if data.status == false then
        SetNuiFocus(false, false)
        isMenuOpen = false
    else
        isMenuOpen = true
        TriggerServerEvent('xeno-adminmenu:server:RequestDashboardStats')
        TriggerServerEvent('xeno-adminmenu:server:RequestPlayersData')
        TriggerServerEvent('xeno-adminmenu:server:RequestResources')
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'setStatus',
            status = true,
            activeTab = data.activeTab
        })
    end
    cb('ok')
end)

RegisterNUICallback('setQuickMenuStatus', function(data, cb)
    if data.status == false then
        SetNuiFocus(false, false)
        isQuickMenuOpen = false
        SendNUIMessage({
            action = 'setQuickMenuStatus',
            status = false
        })
    end
    cb('ok')
end)

RegisterNUICallback('setActionModalFocus', function(data, cb)
    SetNuiFocus(data.status, data.status)
    cb('ok')
end)

RegisterNUICallback('executeCommand', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:ExecuteCommand', data.command)
    cb('ok')
end)

RegisterNUICallback('resource_start', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:ResourceAction', 'start', data.resName)
    cb('ok')
end)

RegisterNUICallback('resource_stop', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:ResourceAction', 'stop', data.resName)
    cb('ok')
end)

RegisterNUICallback('resource_restart', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:ResourceAction', 'restart', data.resName)
    cb('ok')
end)

RegisterNetEvent('xeno-adminmenu:client:TerminalLog', function(logType, message)
    SendNUIMessage({
        action = 'terminalLog',
        type = logType,
        message = message
    })
end)


RegisterNUICallback('fetchGroups', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:RequestGroups')
    cb('ok')
end)

RegisterNetEvent('xeno-adminmenu:client:ReceiveGroups', function(groups)
    DebugLog('xeno-adminmenu:client:ReceiveGroups triggered! Count: ' .. tostring(#groups))
    SendNUIMessage({
        action = 'receiveGroups',
        groups = groups
    })
end)

RegisterNUICallback('saveGroup', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:SaveGroup', data.group)
    cb('ok')
end)

RegisterNUICallback('deleteGroup', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:DeleteGroup', data.groupId)
    cb('ok')
end)

RegisterNUICallback('fetchStaff', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:RequestStaff')
    cb('ok')
end)

RegisterNetEvent('xeno-adminmenu:client:ReceiveStaff', function(staff)
    SendNUIMessage({
        action = 'receiveStaff',
        staff = staff
    })
end)

RegisterNUICallback('saveStaff', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:SaveStaff', data.staff)
    cb('ok')
end)

RegisterNUICallback('getPendingRegistrations', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:GetPendingRegistrations')
    cb('ok')
end)

RegisterNUICallback('approveRegistration', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:ApproveRegistration', data.identifier, data.groupId)
    cb('ok')
end)

RegisterNUICallback('submitRegistration', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:SubmitRegistration', data.reason)
    cb('ok')
end)

RegisterNUICallback('rejectRegistration', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:RejectRegistration', data.identifier, data.reason)
    cb('ok')
end)

RegisterNetEvent('xeno-adminmenu:client:ReceivePendingRegistrations', function(registrations)
    SendNUIMessage({
        action = 'receivePendingRegistrations',
        data = registrations
    })
end)

RegisterNUICallback('deleteStaff', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:DeleteStaff', data.staffId)
    cb('ok')
end)


RegisterNUICallback('fetchWebhooks', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:RequestWebhooks')
    cb('ok')
end)

RegisterNetEvent('xeno-adminmenu:client:ReceiveWebhooks', function(webhooks)
    SendNUIMessage({
        action = 'receiveWebhooks',
        webhooks = webhooks
    })
end)

RegisterNUICallback('saveWebhook', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:SaveWebhook', data.webhook)
    cb('ok')
end)

RegisterNUICallback('deleteWebhook', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:DeleteWebhook', data.webhookId)
    cb('ok')
end)

RegisterNUICallback('toggleWebhook', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:ToggleWebhook', data.webhookId, data.isActive)
    cb('ok')
end)

RegisterNUICallback('testWebhook', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:TestWebhook', data.url)
    cb('ok')
end)

RegisterNetEvent('xeno-adminmenu:client:WebhookTestResult', function(success)
    SendNUIMessage({
        action = 'webhookTestResult',
        success = success
    })
end)


RegisterNUICallback('fetchLogs', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:RequestLogs', data.filter, data.page)
    cb('ok')
end)

RegisterNetEvent('xeno-adminmenu:client:ReceiveLogs', function(logs, page)
    SendNUIMessage({
        action = 'receiveLogs',
        logs = logs,
        page = page
    })
end)

RegisterNUICallback('clearLogs', function(data, cb)
    TriggerServerEvent('xeno-adminmenu:server:ClearLogs')
    cb('ok')
end)
